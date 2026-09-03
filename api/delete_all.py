#!/usr/bin/env python3
import requests
import sys
import json
import logging
import os
import time
from enum import Enum


# ---------------------------------------------------------------------------
# Colored logging formatter
# ---------------------------------------------------------------------------

class ColorFormatter(logging.Formatter):
    CYAN   = '\033[0;36m'
    GREEN  = '\033[0;32m'
    YELLOW = '\033[1;33m'
    RED    = '\033[0;31m'
    BOLD   = '\033[1m'
    RESET  = '\033[0m'

    WHITE  = '\033[1;37m'

    _SUCCESS_KEYWORDS = ("successful", "deleted", "token received", "finished", "starting")

    def format(self, record):
        msg    = record.getMessage()
        ts     = self.formatTime(record, "%H:%M:%S")
        prefix = msg.lstrip()

        if record.levelno >= logging.ERROR:
            return f"{ts}  {self.RED}{self.BOLD}✖  {msg}{self.RESET}"

        if record.levelno == logging.WARNING:
            return f"{ts}  {self.YELLOW}⚠  {msg}{self.RESET}"

        # Section header lines start with **
        if prefix.startswith("**"):
            text = msg.lstrip("* ").capitalize()
            bar  = "─" * 52
            return f"\n{self.BOLD}{self.CYAN}{bar}\n{ts}  {text}\n{bar}{self.RESET}"

        # "Found X items: [a, b, c]" — color the list in white/bold
        if "found" in msg.lower() and ":" in msg:
            label, _, items = msg.partition(":")
            return f"{ts}     {label}:{self.WHITE}{items}{self.RESET}"

        # Success lines
        if any(kw in msg.lower() for kw in self._SUCCESS_KEYWORDS):
            return f"{ts}  {self.GREEN}✔  {msg}{self.RESET}"

        return f"{ts}     {msg}"


handler = logging.StreamHandler(sys.stdout)
handler.setFormatter(ColorFormatter())
logging.basicConfig(level=logging.INFO, handlers=[handler])


# ---------------------------------------------------------------------------
# Credentials
# ---------------------------------------------------------------------------

fss_api_username = os.getenv("TF_VAR_username")
fss_api_password = os.getenv("TF_VAR_password")

if fss_api_username is None or fss_api_password is None:
    logging.error("TF_VAR_username and TF_VAR_password environment variables are required")
    logging.error("These correspond to the FortiSASE API user credentials.")
    sys.exit(2)


# ---------------------------------------------------------------------------
# FortiSASE API client
# ---------------------------------------------------------------------------

class FortiSASE:
    # Deleting these items returns HTTP 400 every now and then, but they are NOT
    # built-in resources: the 400 is transient (the backend is still releasing
    # references to them). Instead of skipping them, retry and, if they still
    # cannot be deleted, abort with EXIT_NOT_DELETED so the job stops.
    # Keys are (resource name as logged, primary key).
    RETRY_ON_400 = {
        ("ztna tag rules", "compliant"),
    }
    RETRY_400_ATTEMPTS = 6
    RETRY_400_DELAY    = 10     # seconds between attempts

    # Exit code reserved for "a resource that must be deleted could not be
    # deleted". The pipeline treats it as a hard failure.
    EXIT_NOT_DELETED = 3

    # The built-in 'Default' endpoint connection profile is never deleted, and while
    # it points at a ZTNA tag rule (posture check) or at an on-net rule (on-fabric
    # rule set), neither of those can be deleted: the API answers HTTP 400.
    DEFAULT_CONNECTION_PROFILE = "Default"

    # Values the API stores when the posture check is disabled. It does NOT accept
    # null here — the object must be present with an empty tag.
    POSTURE_CHECK_DISABLED = {"tag": "", "action": "allow", "checkFailedMessage": ""}

    def __init__(self):
        self.token   = ""
        self.TIMEOUT = 180
        self.RETRIES = 90
        self.base_urL = "https://portal.prod.fortisase.com"

    # Private method to perform generic retrieval of objects
    def __get_all_items(self, name: str, resource: str) -> list[str]:
        logging.info(f"** {name}")
        logging.info(f"   Fetching existing {name}...")

        url     = self.base_urL + resource
        headers = {"Authorization": self.token}
        try:
            resp = requests.get(url, headers=headers, timeout=self.TIMEOUT)
            if 200 <= resp.status_code < 300:
                resp_json = resp.json()
                item_keys = []
                if "data" in resp_json:
                    for item in resp_json['data']:
                        item_keys += [item['primaryKey']]
                    logging.info(f"   Found {len(item_keys)} {name}: {item_keys}")
                    return item_keys
                else:
                    logging.info(f"   No items found for {name}")
                    return []
            else:
                logging.error(f"   HTTP {resp.status_code} fetching {resource}")
                sys.exit(1)
        except requests.RequestException as e:
            logging.error(f"   Request failed: {e}")
            sys.exit(2)

    # Private method to perform generic removal of objects
    def __delete_all_items(self, name: str, resource: str, items: list[str]):
        logging.info(f"   Deleting {name}...")
        url     = self.base_urL + resource
        headers = {"Authorization": self.token}
        try:
            for item in items:
                item_url = url + "/" + item
                attempts = self.RETRY_400_ATTEMPTS if (name, item) in self.RETRY_ON_400 else 1

                for attempt in range(1, attempts + 1):
                    resp = requests.delete(item_url, headers=headers, timeout=self.TIMEOUT)
                    if 200 <= resp.status_code < 300:
                        logging.info(f"   Deleted: {item}")
                        break
                    elif resp.status_code == 400:
                        # Not in RETRY_ON_400: a 400 here means a built-in resource.
                        if attempts == 1:
                            logging.warning(f"   Skipped '{item}' — HTTP 400 (likely a built-in resource)")
                            break
                        logging.warning(f"   HTTP 400 deleting '{item}' (attempt {attempt}/{attempts}): {resp.text}")
                        if attempt < attempts:
                            logging.warning(f"   '{item}' is not built-in, retrying in {self.RETRY_400_DELAY}s...")
                            time.sleep(self.RETRY_400_DELAY)
                        else:
                            logging.error(f"   '{item}' ({name}) could not be deleted after {attempts} attempts.")
                            logging.error(f"   It is not a built-in resource, so the instance is left dirty. Aborting.")
                            sys.exit(self.EXIT_NOT_DELETED)
                    else:
                        logging.error(f"   HTTP {resp.status_code} deleting '{item}': {resp.text}")
                        sys.exit(1)
        except requests.RequestException as e:
            logging.error(f"   Request failed: {e}")
            sys.exit(2)

    # ── Public methods ────────────────────────────────────────────────────────

    def obtain_token(self):
        logging.info("** Requesting API token")
        url     = "https://customerapiauth.fortinet.com/api/v1/oauth/token/"
        payload = {
            "username":      fss_api_username,
            "password":      fss_api_password,
            "client_id":     "FortiSASE",
            "client_secret": "",
            "grant_type":    "password",
        }
        try:
            resp = requests.post(url, json=payload, timeout=self.TIMEOUT)
        except requests.RequestException as e:
            logging.error(f"   Request failed: {e}")
            sys.exit(2)
        if 200 <= resp.status_code < 300:
            data       = resp.json()
            self.token = "Bearer " + data['access_token']
            logging.info("   Token received")
        else:
            logging.error(f"   Could not obtain token (HTTP {resp.status_code}): {resp.text}")
            sys.exit(1)

    def delete_auth(self):
        logging.info("** Deleting SAML auth configuration (vpn-saml-server)")
        resource = "/resource-api/v2/auth/vpn-saml-server"
        url      = self.base_urL + resource
        headers  = {"Authorization": self.token}
        payload  = {"primary_key": "$sase-global", "enabled": False}
        try:
            resp = requests.put(url, headers=headers, json=payload, timeout=self.TIMEOUT)
            if 200 <= resp.status_code < 300:
                logging.info(f"   Deleted: {resource}")
            else:
                logging.error(f"   HTTP {resp.status_code} deleting {resource}: {resp.text}")
        except requests.RequestException as e:
            logging.error(f"   Request failed: {e}")
            sys.exit(2)

    def get_all_service_connections(self) -> list[str]:
        logging.info("** Service connections")
        logging.info("   Fetching existing service connections...")
        resource = "/resource-api/v1/private-access/service-connections"
        url      = self.base_urL + resource
        headers  = {"Authorization": self.token}
        try:
            resp = requests.get(url, headers=headers, timeout=self.TIMEOUT)
            if 200 <= resp.status_code < 300:
                sc     = resp.json()
                sc_ids = []
                if "hubs" in sc:
                    for hub in sc['hubs']:
                        sc_ids += [hub['id']]
                    logging.info(f"   Found {len(sc_ids)} service connection(s): {sc_ids}")
                    return sc_ids
                else:
                    logging.info(f"   No service connections found")
                    return []
            else:
                logging.error(f"   HTTP {resp.status_code} fetching {resource}")
                sys.exit(1)
        except requests.RequestException as e:
            logging.error(f"   Request failed: {e}")
            sys.exit(2)

    def delete_all_service_connections(self, service_connections: list[str]):
        logging.info("   Deleting service connections (asynchronous)...")
        resource = "/resource-api/v1/private-access/service-connections"
        url      = self.base_urL + resource
        headers  = {"Authorization": self.token}
        try:
            for sc in service_connections:
                url_sc    = url + "/" + sc
                iteration = self.RETRIES
                while iteration >= 0:
                    iteration -= 1
                    resp = requests.delete(url_sc, headers=headers, timeout=self.TIMEOUT)

                    if 200 <= resp.status_code < 300:
                        logging.info(f"   Delete accepted for SC '{sc}' — waiting for completion...")
                        count = self.RETRIES
                        while sc in self.get_all_service_connections() and count >= 0:
                            count -= 1
                            logging.info(f"   SC '{sc}' still present, waiting... ({count} attempts left)")
                            time.sleep(1)
                        if count < 0:
                            logging.error(f"   SC '{sc}' could not be deleted — timed out.")
                            sys.exit(2)
                        logging.info(f"   Deleted SC '{sc}'")
                        break
                    elif resp.status_code == 400:
                        logging.warning(f"   HTTP 400 on SC '{sc}' — another deletion may be in progress, retrying... ({iteration} left)")
                        logging.warning(f"   Response: {resp.text}")
                        time.sleep(1)
                    else:
                        logging.error(f"   HTTP {resp.status_code} deleting SC '{sc}': {resp.text}")
                        sys.exit(1)
                if iteration < 0:
                    logging.error(f"   SC '{sc}' could not be deleted — no more attempts.")
                    sys.exit(2)
        except requests.RequestException as e:
            logging.error(f"   Request failed: {e}")
            sys.exit(2)

    def get_network_bgp(self):
        logging.info("   Fetching BGP/network configuration...")
        resource = "/resource-api/v1/private-access/network-configuration"
        url      = self.base_urL + resource
        headers  = {"Authorization": self.token}
        try:
            resp = requests.get(url, headers=headers, timeout=self.TIMEOUT)
            if 200 <= resp.status_code < 300:
                if "data" in resp.json():
                    bgp_config = resp.json()
                    logging.info(f"   BGP config: {bgp_config}")
                    return bgp_config
                else:
                    logging.info(f"   No BGP configuration found")
                    return []
            else:
                logging.error(f"   HTTP {resp.status_code} fetching {resource}")
                sys.exit(1)
        except requests.RequestException as e:
            logging.error(f"   Request failed: {e}")
            sys.exit(2)

    def delete_network_bgp(self):
        logging.info("** BGP/network configuration")
        bgp_data = self.get_network_bgp().get('data', {})
        if not bgp_data:
            logging.info("   No BGP configuration found, skipping delete")
            return
        resource = "/resource-api/v1/private-access/network-configuration"
        url      = self.base_urL + resource
        headers  = {"Authorization": self.token}
        try:
            resp = requests.delete(url, headers=headers, timeout=self.TIMEOUT)

            if 200 <= resp.status_code < 300 or resp.status_code == 400:
                if resp.status_code == 400:
                    logging.warning(f"   HTTP 400 — already deleted or deletion in progress: {resp.text}")
                else:
                    logging.info(f"   Delete accepted — waiting for completion...")
                count = self.RETRIES
                while "config_state" in self.get_network_bgp().get('data', {}) and count >= 0:
                    count -= 1
                    logging.info(f"   BGP config still present, waiting... ({count} attempts left)")
                    time.sleep(1)
                if count < 0:
                    logging.error(f"   BGP config could not be deleted — timed out.")
                    sys.exit(2)
                logging.info(f"   Deleted BGP/network configuration")
            else:
                logging.error(f"   HTTP {resp.status_code} deleting {resource}: {resp.text}")
                sys.exit(1)
        except requests.RequestException as e:
            logging.error(f"   Request failed: {e}")
            sys.exit(2)

    class PolicyType(Enum):
        outbound = "outbound"
        internal = "internal"
        reverse  = "internal-reverse"
        ep2ep    = "endpoint2endpoint"

    def get_all_policies(self, policy_type: PolicyType) -> list[str]:
        match policy_type:
            case self.PolicyType.outbound:
                resource = "/resource-api/v2/security/outbound-policies"
            case self.PolicyType.internal:
                resource = "/resource-api/v2/security/internal-policies"
            case self.PolicyType.reverse:
                resource = "/resource-api/v2/security/internal-reverse-policies"
            case self.PolicyType.ep2ep:
                resource = "/resource-api/v2/security/endpoint-to-endpoint-policies"
            case _:
                logging.error("Invalid policy type")
                sys.exit(2)
        return self.__get_all_items(f"{policy_type.value} policies", resource)

    def delete_all_policies(self, policy_type: PolicyType, policies: list[str]):
        match policy_type:
            case self.PolicyType.outbound:
                resource = "/resource-api/v2/security/outbound-policies"
            case self.PolicyType.internal:
                resource = "/resource-api/v2/security/internal-policies"
            case self.PolicyType.reverse:
                resource = "/resource-api/v2/security/internal-reverse-policies"
            case self.PolicyType.ep2ep:
                resource = "/resource-api/v2/security/endpoint-to-endpoint-policies"
            case _:
                logging.error("Invalid policy type")
                sys.exit(2)
        return self.__delete_all_items(f"{policy_type.value} policies", resource, policies)

    def get_all_profile_groups(self) -> list[str]:
        return self.__get_all_items("profile groups", "/resource-api/v2/security/profile-groups")

    def delete_all_profile_groups(self, profile_groups: list[str]):
        return self.__delete_all_items("profile groups", "/resource-api/v2/security/profile-groups", profile_groups)

    def get_all_host_groups(self) -> list[str]:
        return self.__get_all_items("host groups", "/resource-api/v2/network/host-groups")

    def delete_all_host_groups(self, host_groups: list[str]):
        return self.__delete_all_items("host groups", "/resource-api/v2/network/host-groups", host_groups)

    def get_all_hosts(self) -> list[str]:
        return self.__get_all_items("hosts", "/resource-api/v2/network/hosts")

    def delete_all_hosts(self, hosts: list[str]):
        return self.__delete_all_items("hosts", "/resource-api/v2/network/hosts", hosts)

    def get_all_user_groups(self) -> list[str]:
        return self.__get_all_items("user groups", "/resource-api/v2/auth/user-groups")

    def delete_all_user_groups(self, user_groups: list[str]):
        return self.__delete_all_items("user groups", "/resource-api/v2/auth/user-groups", user_groups)

    def get_all_endpoint_profiles(self) -> list[str]:          # Modeled as endpoint policies in the API
        return self.__get_all_items("endpoint profiles", "/resource-api/v2/endpoint/policies")

    def delete_all_endpoint_profiles(self, endpoint_profiles: list[str]):
        return self.__delete_all_items("endpoint profiles", "/resource-api/v2/endpoint/policies", endpoint_profiles)

    def reset_default_connection_profile(self):
        """Disable the posture check and the on-fabric rule set of the built-in
        'Default' connection profile, which keep a ZTNA tag rule and an on-net rule
        in use and make their deletion fail."""
        profile  = self.DEFAULT_CONNECTION_PROFILE
        logging.info(f"** {profile} endpoint connection profile")
        resource = "/resource-api/v2/endpoint/connection-profiles/" + profile
        url      = self.base_urL + resource
        headers  = {"Authorization": self.token}

        try:
            logging.info(f"   Fetching connection profile '{profile}'...")
            resp = requests.get(url, headers=headers, timeout=self.TIMEOUT)
            if not 200 <= resp.status_code < 300:
                logging.error(f"   HTTP {resp.status_code} fetching {resource}: {resp.text}")
                sys.exit(1)

            data = resp.json().get("data")
            if isinstance(data, list):          # the API returns the profile in a list
                data = data[0] if data else None
            if not data:
                logging.warning(f"   Connection profile '{profile}' not found, skipping")
                return

            posture_tag = data.get("secureInternetAccess", {}).get("postureCheck", {}).get("tag", "")
            fabric_rule = data.get("onFabricRuleSet")
            if not posture_tag and not fabric_rule:
                logging.info(f"   Posture check and on-fabric rule set already disabled in '{profile}'")
                return

            logging.info(f"   Disabling posture check (tag: '{posture_tag}') and "
                         f"on-fabric rule set ({fabric_rule}) in '{profile}'...")

            # $meta is read-only and comes back with the pre-shared key masked, so it
            # cannot be written back. Everything else is echoed as received.
            data.pop("$meta", None)
            data.setdefault("secureInternetAccess", {})["postureCheck"] = dict(self.POSTURE_CHECK_DISABLED)
            data["onFabricRuleSet"] = None

            resp = requests.put(url, headers=headers, json=data, timeout=self.TIMEOUT)
            if 200 <= resp.status_code < 300:
                logging.info(f"   Connection profile '{profile}' reset to its default values")
            else:
                # Without this the ZTNA tag rule and the on-net rule cannot be
                # removed, so there is no point in going on.
                logging.error(f"   HTTP {resp.status_code} updating {resource}: {resp.text}")
                logging.error(f"   '{profile}' keeps the ZTNA tag rule / on-net rule in use. Aborting.")
                sys.exit(self.EXIT_NOT_DELETED)
        except requests.RequestException as e:
            logging.error(f"   Request failed: {e}")
            sys.exit(2)

    def get_all_ztna_tag_rules(self) -> list[str]:
        return self.__get_all_items("ztna tag rules", "/resource-api/v2/endpoint/ztna-tag-rules")

    def delete_all_ztna_tag_rules(self, ztna_tag_rules: list[str]):
        return self.__delete_all_items("ztna tag rules", "/resource-api/v2/endpoint/ztna-tag-rules", ztna_tag_rules)

    def get_all_on_net_rules(self) -> list[str]:
        return self.__get_all_items("on-net rules", "/resource-api/v2/endpoint/on-net-rules")

    def delete_all_on_net_rules(self, on_net_rules: list[str]):
        return self.__delete_all_items("on-net rules", "/resource-api/v2/endpoint/on-net-rules", on_net_rules)

    def get_all_remote_certs(self) -> list[str]:
        return self.__get_all_items("remote certificates", "/resource-api/v1/security/cert/remote-certs")

    def delete_all_remote_certs(self, certs: list[str]):
        return self.__delete_all_items("remote certificates", "/resource-api/v1/security/cert/remote-certs", certs)

    def get_all_remote_ca_certs(self) -> list[str]:
        return self.__get_all_items("remote CA certificates", "/resource-api/v1/security/cert/remote-ca-certs")

    def delete_all_remote_ca_certs(self, certs: list[str]):
        return self.__delete_all_items("remote CA certificates", "/resource-api/v1/security/cert/remote-ca-certs", certs)

    def get_all_local_certs(self) -> list[str]:
        return self.__get_all_items("local certificates", "/resource-api/v1/security/cert/local-certs")

    def delete_all_local_certs(self, certs: list[str]):
        return self.__delete_all_items("local certificates", "/resource-api/v1/security/cert/local-certs", certs)

    def get_all_ssids(self) -> list[str]:
        return self.__get_all_items("ssids", "/resource-api/v2/infra/ssids")

    def delete_all_ssids(self, ssids: list[str]):
        return self.__delete_all_items("ssids", "/resource-api/v2/infra/ssids", ssids)


if __name__ == "__main__":

    logging.info("** Starting ")
    fss = FortiSASE()
    fss.obtain_token()

    # ── Auth ──────────────────────────────────────────────────────────────────
    fss.delete_auth()

    # ── Security ──────────────────────────────────────────────────────────────
    policies = fss.get_all_policies(FortiSASE.PolicyType.outbound)
    fss.delete_all_policies(FortiSASE.PolicyType.outbound, policies)
    policies = fss.get_all_policies(FortiSASE.PolicyType.internal)
    fss.delete_all_policies(FortiSASE.PolicyType.internal, policies)
    policies = fss.get_all_policies(FortiSASE.PolicyType.reverse)
    fss.delete_all_policies(FortiSASE.PolicyType.reverse, policies)
    policies = fss.get_all_policies(FortiSASE.PolicyType.ep2ep)
    fss.delete_all_policies(FortiSASE.PolicyType.ep2ep, policies)

    profile_groups = fss.get_all_profile_groups()
    fss.delete_all_profile_groups(profile_groups)

    host_groups = fss.get_all_host_groups()
    fss.delete_all_host_groups(host_groups)

    hosts = fss.get_all_hosts()
    fss.delete_all_hosts(hosts)

    user_groups = fss.get_all_user_groups()
    fss.delete_all_user_groups(user_groups)

    certs = fss.get_all_remote_certs()
    fss.delete_all_remote_certs(certs)

    certs = fss.get_all_remote_ca_certs()
    fss.delete_all_remote_ca_certs(certs)

    certs = fss.get_all_local_certs()
    fss.delete_all_local_certs(certs)

    # ── Endpoint ──────────────────────────────────────────────────────────────
    endpoint_profiles = fss.get_all_endpoint_profiles()
    fss.delete_all_endpoint_profiles(endpoint_profiles)

    # Must run before the ZTNA tag rules and the on-net rules are deleted: the
    # built-in Default profile keeps them in use and the API refuses to remove them.
    fss.reset_default_connection_profile()

    ztna_tag_rules = fss.get_all_ztna_tag_rules()
    fss.delete_all_ztna_tag_rules(ztna_tag_rules)

    on_net_rules = fss.get_all_on_net_rules()
    fss.delete_all_on_net_rules(on_net_rules)

    # ── Infra ─────────────────────────────────────────────────────────────────
    ssids = fss.get_all_ssids()
    fss.delete_all_ssids(ssids)

    # ── Networking ────────────────────────────────────────────────────────────
    scs = fss.get_all_service_connections()
    fss.delete_all_service_connections(scs)

    fss.delete_network_bgp()

    logging.info("** Finished ")
