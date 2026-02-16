resource "fortisase_security_profile_group" "unisase_guest" {
  primary_key = "unisase_guest"

  web_filter_profile = {
    status = "enable"
  }

  dlp_filter_profile = {
    status = "disable"
  }

  file_filter_profile = {
    status = "disable"
  }

  antivirus_profile = {
    status = "enable"
  }

  dns_filter_profile = {
    status = "enable"
  }

  application_control_profile = {
    status = "enable"
  }

  video_filter_profile = {
    status = "disable"
  }

  intrusion_prevention_profile = {
    status = "enable"
  }
}

resource "fortisase_security_ssl_ssh_profile" "unisase_guest" {
  primary_key                             = fortisase_security_profile_group.unisase_guest.primary_key
  inspection_mode                         = "certificate-inspection"
  expired_certificate_action              = "block"
  revoked_certificate_action              = "block"
  timed_out_validation_certificate_action = "allow"
  validation_failed_certificate_action    = "block"
  cert_probe_failure                      = "allow"
  ca_certificate = {
    primary_key = "Fortinet_CA_SSL"
    datasource  = "system/certificate/ca-certificates"
  }
  profile_protocol_options = {
    compressed_limit = 10
    oversized_action = "allow"
    uncompressed_limit = 10
    unknown_content_encoding = "inspect"
  }
}


resource "fortisase_security_web_filter_profile" "unisase_guest" {
  primary_key             = fortisase_security_profile_group.unisase_guest.primary_key
  use_fortiguard_filters  = "enable"
  block_invalid_url       = "disable"
  enforce_safe_search     = "disable"
  traffic_on_rating_error = "enable"
  content_filters         = []
  http_headers            = []
  url_filters             = []
  fortiguard_filters = local.fgd_restricted_categories
}

resource "fortisase_security_antivirus_profile" "unisase_guest" {
  primary_key = fortisase_security_profile_group.unisase_guest.primary_key
  http        = "enable"
  smtp        = "enable"
  pop3        = "enable"
  imap        = "enable"
  ftp         = "enable"
  cifs        = "enable"
}

resource "fortisase_security_dns_filter_profile" "unisase_guest" {
  primary_key                        = fortisase_security_profile_group.unisase_guest.primary_key
  use_fortiguard_filters             = "enable"
  fortiguard_filters                 = local.fgd_restricted_categories
  domain_filters                     = []
  dns_translation_entries            = []
  enable_botnet_blocking             = "enable"
  enable_all_logs                    = "disable"
  use_for_edge_devices               = false
  allow_dns_requests_on_rating_error = "enable"
  enable_safe_search                 = "disable"
  domain_threat_feed_filters         = []
}

# To configure this resource, please disable proxy configuration.
resource "fortisase_security_application_control_profile" "unisase_guest" {
  primary_key = fortisase_security_profile_group.unisase_guest.primary_key
  unknown_application_action          = "allow"
  network_protocol_enforcement        = "disable"
  network_protocols                   = []
  block_non_default_port_applications = "disable"
  # TODO: Review next setting: It doesn't set value properly. Bug reported, pending to be fixed
  controls = [{
    action     = "monitor"
    behavior   = ""
    technology = ""
    vendor     = ""
    popularity = ""
    protocols  = ""
    categories = [{
      datasource  = "security/application-categories"
      primary_key = "VoIP"
    }]
  }]
}

resource "fortisase_security_ips_profile" "unisase_guest" {
  primary_key               = fortisase_security_profile_group.unisase_guest.primary_key
  profile_type              = "recommended"
  custom_rule_groups        = []
  is_blocking_malicious_url = false
  botnet_scanning           = "block"
  is_extended_log_enabled   = false
  comment                   = "Recommended"
  entries = [
    {
      rule               = [],
      location           = "all",
      severity           = "all",
      protocol           = "all",
      os                 = "all",
      application        = "all",
      cve                = [],
      status             = "default",
      log                = "enable",
      log_packet         = "disable",
      log_attack_context = "disable",
      action             = "default",
      quarantine         = "none",
      exempt_ip          = [],
      vuln_type          = [],
      default_action     = "all",
      default_status     = "all"
    }
  ]
}
