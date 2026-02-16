#!/usr/bin/env python3
import requests
import sys
import json
import logging
import os
import time
from pprint import pprint

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)

fss_api_username = os.getenv("TF_VAR_username")
fss_api_password = os.getenv("TF_VAR_password")

if fss_api_password is None or fss_api_password is None:
    logging.error("Need to have environment variables TF_VAR_username and TF_VAR_password to run")
    logging.error("Note these correspond to FortiSASE API user.")
    sys.exit(2)

class FortiSASE:
    def __init__(self):
        self.token = ""
        self.TIMEOUT = 180
        self.RETRIES = 90
        self.base_urL = "https://portal.prod.fortisase.com"

  # Private method to perform generic retrieval of objects
    def __get_all_items(self, name: str, resource: str) -> list[str]:
        logging.info(f"** Requesting all existing {name}")
 
        url = self.base_urL + resource
        headers = {
            "Authorization": self.token
        }
        try:
            resp = requests.get(url, headers=headers, timeout=self.TIMEOUT)
            if 200 <= resp.status_code < 300:
                resp_json = resp.json()
                logging.info(f"   Successful request. Extracting {name}")
                item_keys = []
                if "data" in resp_json:
                    for item in resp_json['data']:
                        item_keys += [item['primaryKey']]
                    logging.info(f"   Extracted data: {item_keys}")
                    return item_keys
                else:
                    logging.info(f"   No 'data' field in response from FSS")
                    return []
            else:
                logging.error(f"   Error {resp.status_code} getting {resource}")
                sys.exit(1)
        except requests.RequestException as e:
            logging.error(f"   Error: {e}", file=sys.stderr)
            sys.exit(2)

    # Private method to perform generic removal of objects
    def __delete_all_items(self, name:str, resource: str, items: list[str]):
        logging.info(f"** Requesting to delete all {name}")
        url = self.base_urL + resource
        headers = {
            "Authorization": self.token
        }
        try:
            for item in items:
                item_url = url + "/" + item
                resp = requests.delete(item_url, headers=headers, timeout=self.TIMEOUT)
                if 200 <= resp.status_code < 300:
                    logging.info(f"   Successful request. Deleted: {item_url}")
                elif resp.status_code == 400:
                    logging.info(f"   Returned 400 error deleting {item}: Probably it's built-in")
                else:
                    logging.error(f"   Error {resp.status_code} deleting {item_url}")
                    sys.exit(1)
        except requests.RequestException as e:
            logging.error(f"   Error: {e}", file=sys.stderr)
            sys.exit(2)

    # Public methods

    def obtain_token(self):
        logging.info("** Requesting token to FSS API")
        url = "https://customerapiauth.fortinet.com/api/v1/oauth/token/"
        payload = {
            "username": fss_api_username,
            "password": fss_api_password,
            "client_id": "FortiSASE",
            "client_secret": "",
            "grant_type": "password"
        }
        try:
            resp = requests.post(url, json=payload, timeout=self.TIMEOUT)
            logging.info(f"   Request finished")
        except requests.RequestException as e:
            logging.error(f"   Error: {e}", file=sys.stderr)
            sys.exit(2)
        try:
            if 200 <= resp.status_code < 300:
                data = resp.json()
                self.token = "Bearer " + data['access_token']
                logging.info(f"   Token received")
            else:
                logging.error(f"   Token not found.... exiting")
                sys.exit(1)
        except Exception:
            logging.error(f"   No token found in response {resp.text}")

    def delete_auth(self): 
        logging.info("** Deleting auth (vpn-saml-server) using FSS API")

        resource = "/resource-api/v2/auth/vpn-saml-server"
        url = self.base_urL + resource
        headers = {
            "Authorization": self.token
        }
        payload = { 
            "primary_key": "$sase-global",
            "enabled": False
        }
        try:
            resp = requests.put(url, headers=headers, json=payload, timeout=self.TIMEOUT)
            if 200 <= resp.status_code < 300:
                logging.info(f"   Successful request. Deleted: {resource}")
            else:
                logging.error(f"   Error {resp.status_code} deleting {resource}")
        except requests.RequestException as e:
            logging.error(f"   Error: {e}", file=sys.stderr)
            sys.exit(2)

    def get_all_service_connections(self) -> list[str]:
        logging.info("** Requesting all existing service connections")
        resource = "/resource-api/v1/private-access/service-connections"
        url = self.base_urL + resource
        headers = {
            "Authorization": self.token
        }
        try:
            resp = requests.get(url, headers=headers, timeout=self.TIMEOUT)
            if 200 <= resp.status_code < 300:
                sc = resp.json()
                logging.info(f"   Successful request. Extracting service connections")
                sc_ids = []
                if "hubs" in sc:
                    for hub in sc['hubs']:
                        sc_ids += [hub['id']]
                    logging.info(f"   Extracted data: {sc_ids}")
                    return sc_ids
                else:
                    logging.info(f"   No 'hubs' in response from FSS")
                    return []
            else:
                logging.error(f"   Error {resp.status_code} getting {resource}")
                sys.exit(1)
        except requests.RequestException as e:
            logging.error(f"   Error: {e}", file=sys.stderr)
            sys.exit(2)

    def delete_all_service_connections(self, service_connections: list[str]):
        # Note this request is asynchronous. Observe loops below
        logging.info("** Requesting to delete all service connections")
        resource = "/resource-api/v1/private-access/service-connections"
        url = self.base_urL + resource
        headers = {
            "Authorization": self.token
        }
        try:
            for sc in service_connections:
                url_sc = url + "/" + sc
                iteration = self.RETRIES
                while iteration >= 0:
                    iteration -= 1
                    resp = requests.delete(url_sc, headers=headers, timeout=self.TIMEOUT)
                    
                    if 200 <= resp.status_code < 300:
                        logging.info(f"   Successful request. SC is being deleted (asynchronous): {url_sc}")
                        count = self.RETRIES
                        while sc in self.get_all_service_connections() and count >= 0:
                            count -= 1
                            logging.info(f"   SC {sc} still present... Iteration: {count}")
                            time.sleep(1)
                        if count < 0:
                            logging.error(f"   SC {sc} couldn't be deleted. No more attempts.")
                            sys.exit(2)
                        break
                    elif resp.status_code == 400:
                        logging.info(f"   Returned {resp.status_code} when deleting {url_sc}")
                        logging.info(f"   Body text: {resp.text}")
                        logging.info(f"   Probably this or another sc is beign deleted. Retrying... Iteration: {iteration}")
                        time.sleep(1)
                    else:
                        logging.error(f"   Error {resp.status_code} deleting {url_sc}")
                        logging.error(f"   Error text: {resp.text}")
                        sys.exit(1)
                if iteration < 0:
                    logging.error(f"   Still getting error when deleting {sc}. No more attempts.")
                    sys.exit(2)
        except requests.RequestException as e:
            logging.error(f"   Error: {e}", file=sys.stderr)
            sys.exit(2)

    def get_network_bgp(self):
        logging.info("** Requesting network/BGP configuration status")
        resource = "/resource-api/v1/private-access/network-configuration"
        url = self.base_urL + resource
        headers = {
            "Authorization": self.token
        }
        try:
            resp = requests.get(url, headers=headers, timeout=self.TIMEOUT)
            if 200 <= resp.status_code < 300:
                logging.info(f"   Successful request. Extracting network/BGP configuration status")
                if "data" in resp.json():
                    bgp_config = resp.json()
                    logging.info(f"   Extracted data: {bgp_config}")
                    return bgp_config
                else:
                    logging.info(f"   No 'data' in response from FSS")
                    return []
            else:
                logging.error(f"   Error {resp.status_code} getting {resource}")
                sys.exit(1)
        except requests.RequestException as e:
            logging.error(f"   Error: {e}", file=sys.stderr)
            sys.exit(2)


    def delete_network_bgp(self):
        logging.info("** Requesting to delete network/BGP configuration")
        resource = "/resource-api/v1/private-access/network-configuration"
        url = self.base_urL + resource
        headers = {
            "Authorization": self.token
        }
        try:
            resp = requests.delete(url, headers=headers, timeout=self.TIMEOUT)

            if 200 <= resp.status_code < 300:
                logging.info(f"   Successful request. Deleted: {resource}")
                count = self.RETRIES
                while "config_state" in self.get_network_bgp()['data'] and count >= 0:
                    count -= 1
                    logging.info(f"   BGP config still present... Iteration: {count}")
                    time.sleep(1)
                if count < 0:
                    logging.error(f"   BGP config couldn't be deleted. No more attempts.")
                    sys.exit(2)
            elif resp.status_code == 400:
                logging.info(f"   Successful request. Network config was already deleted or in process of deleting: {resource} (HTTP 400)")
                logging.info(f"   Response given: {resp.text}")
                count = self.RETRIES
                while "config_state" in self.get_network_bgp()['data'] and count >= 0:
                    count -= 1
                    logging.info(f"   BGP config still present... Iteration: {count}")
                    time.sleep(1)
                if count < 0:
                    logging.error(f"   BGP config couldn't be deleted. No more attempts.")
                    sys.exit(2)
            else:
                logging.error(f"   Error {resp.status_code} deleting {resource}")
                sys.exit(1)
        except requests.RequestException as e:
            logging.error(f"   Error: {e}", file=sys.stderr)
            sys.exit(2)

    from enum import Enum
    class PolicyType(Enum):
        outbound  = "outbound"
        internal  = "internal"
        reverse   = "internal-reverse"
        ep2ep     = "endpoint2endpoint"

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
                logging.error("Policy Type not valid")
                sys.exit(2)
        return self.__get_all_items(f"{policy_type.value} policies",
            resource)

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
                logging.error("Policy Type not valid")
                sys.exit(2)
        return self.__delete_all_items(f"{policy_type.value} policies",
            resource,
            policies)

    def get_all_profile_groups(self) -> list[str]:
        return self.__get_all_items("profile groups",
            "/resource-api/v2/security/profile-groups")

    def delete_all_profile_groups(self, profile_groups: list[str]):
        return self.__delete_all_items("profile groups",
            "/resource-api/v2/security/profile-groups",
            profile_groups)

    def get_all_host_groups(self) -> list[str]:
        return self.__get_all_items("host groups",
            "/resource-api/v2/network/host-groups")

    def delete_all_host_groups(self, host_groups: list[str]):
        return self.__delete_all_items("host groups",
            "/resource-api/v2/network/host-groups",
            host_groups)

    def get_all_hosts(self) -> list[str]:
        return self.__get_all_items("hosts",
            "/resource-api/v2/network/hosts")

    def delete_all_hosts(self, hosts: list[str]):
        return self.__delete_all_items("hosts",
            "/resource-api/v2/network/hosts",
            hosts)

    def get_all_user_groups(self) -> list[str]:
        return self.__get_all_items("user groups",
            "/resource-api/v2/auth/user-groups")     

    def delete_all_user_groups(self, user_groups: list[str]):
        return self.__delete_all_items("user group",
            "/resource-api/v2/auth/user-groups",
            user_groups)

    def get_all_endpoint_profiles(self) -> list[str]:                          # Note this is modeled in the API as endpoint policies
        return self.__get_all_items("endpoint profiles",
            "/resource-api/v2/endpoint/policies")     

    def delete_all_endpoint_profiles(self, endpoint_profiles: list[str]):      # Note this is modeled in the API as endpoint policies
        return self.__delete_all_items("endpoint profiles",
            "/resource-api/v2/endpoint/policies",
            endpoint_profiles)

    def get_all_ztna_rules(self) -> list[str]:
        return self.__get_all_items("ztna rules",
            "/resource-api/v2/endpoint/ztna-rules")     

    def delete_all_ztna_rules(self, ztna_rules: list[str]):
        return self.__delete_all_items("ztna rules",
            "/resource-api/v2/endpoint/ztna-rules",
            ztna_rules)

    def get_all_ztna_tags(self) -> list[str]:
        return self.__get_all_items("ztna tags",
            "/resource-api/v2/endpoint/ztna-tags")     

    def delete_all_ztna_tags(self, ztna_tags: list[str]):
        return self.__delete_all_items("ztna tags",
            "/resource-api/v2/endpoint/ztna-tags",
            ztna_tags)

    def get_all_on_net_rules(self) -> list[str]:
        return self.__get_all_items("on-net rules",
            "/resource-api/v2/endpoint/on-net-rules")    

    def delete_all_on_net_rules(self, on_net_rules: list[str]):
        return self.__delete_all_items("on-net rules",
            "/resource-api/v2/endpoint/on-net-rules",
            on_net_rules)

if __name__ == "__main__":
    
    logging.info("******* Starting... *******")
    fss = FortiSASE()
    fss.obtain_token()

    # Auth 
    fss.delete_auth()
    
    # Security
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

    # Endpoint
    endpoint_profiles = fss.get_all_endpoint_profiles()
    fss.delete_all_endpoint_profiles(endpoint_profiles)
    ztna_rules = fss.get_all_ztna_rules()
    fss.delete_all_ztna_rules(ztna_rules)
    ztna_tags = fss.get_all_ztna_tags()
    fss.delete_all_ztna_tags(ztna_tags)

    on_net_rules = fss.get_all_on_net_rules()
    fss.delete_all_on_net_rules(on_net_rules)

    # Networking
    scs = fss.get_all_service_connections()
    fss.delete_all_service_connections(scs)
    fss.delete_network_bgp()

    logging.info("******* Finished. *******")
