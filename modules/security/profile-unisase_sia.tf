resource "fortisase_security_profile_group" "unisase_sia" {
  primary_key = "unisase_sia"

  web_filter_profile = {
    status = "enable"
  }

  dlp_filter_profile = {
    status = "enable"
  }

  file_filter_profile = {
    status = "enable"
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

resource "fortisase_security_ssl_ssh_profile" "unisase_sia" {
  primary_key                             = fortisase_security_profile_group.unisase_sia.primary_key
  inspection_mode                         = "deep-inspection"
  expired_certificate_action              = "block"
  revoked_certificate_action              = "block"
  timed_out_validation_certificate_action = "allow"
  validation_failed_certificate_action    = "block"
  cert_probe_failure                      = "allow"
  ca_certificate = {
    primary_key = "Fortinet_CA_SSL"
    datasource  = "system/certificate/ca-certificates"
  }
  host_exemptions = [
    {
      primary_key = "FortiClient"
      datasource  = "network/hosts"
    },
    {
      primary_key = "Fortinet Services"
      datasource  = "network/host-groups"
    }
  ]
  url_category_exemptions = [
    {
      primary_key = "Finance and Banking"
      datasource  = "security/fortiguard-categories"
    },
    {
      primary_key = "Health and Wellness"
      datasource  = "security/fortiguard-categories"
    }
  ]
  profile_protocol_options = {
    compressed_limit         = 10
    oversized_action         = "block"
    uncompressed_limit       = 10
    unknown_content_encoding = "inspect"
  }
}

resource "fortisase_security_web_filter_profile" "unisase_sia" {
  primary_key             = fortisase_security_profile_group.unisase_sia.primary_key
  use_fortiguard_filters  = "enable"
  block_invalid_url       = "disable"
  enforce_safe_search     = "disable"
  traffic_on_rating_error = "disable"
  content_filters         = []
  http_headers            = []
  url_filters             = local.restricted_sites
  fortiguard_filters      = local.fgd_restricted_categories
}

resource "fortisase_security_dlp_profile" "unisase_sia" {
  primary_key = fortisase_security_profile_group.unisase_sia.primary_key
  dlp_rules   = []
}

resource "fortisase_security_file_filter_profile" "unisase_sia" {
  primary_key                    = fortisase_security_profile_group.unisase_sia.primary_key
  monitor                        = local.file_types
  block                          = []
  block_password_protected_files = false
}

resource "fortisase_security_antivirus_profile" "unisase_sia" {
  primary_key = fortisase_security_profile_group.unisase_sia.primary_key
  http        = "enable"
  smtp        = "enable"
  pop3        = "enable"
  imap        = "enable"
  ftp         = "enable"
  cifs        = "enable"
  cdr = {
    allow_error_transmission = true
    enable                   = true
    file_types               = ["pdf", "office"]
  }
}

resource "fortisase_security_dns_filter_profile" "unisase_sia" {
  primary_key                        = fortisase_security_profile_group.unisase_sia.primary_key
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
resource "fortisase_security_application_control_profile" "unisase_sia" {
  primary_key                         = fortisase_security_profile_group.unisase_sia.primary_key
  unknown_application_action          = "allow"
  network_protocol_enforcement        = "disable"
  network_protocols                   = []
  block_non_default_port_applications = "disable"
  controls = [{
    action     = "monitor"
    behavior   = "all"
    technology = "all"
    vendor     = "all"
    risk       = []
    protocols  = "all"
    popularity = [1, 2, 3, 4, 5]
    categories = [{
      datasource  = "security/application-categories"
      primary_key = "VoIP"
    }]
  }]
}

resource "fortisase_security_ips_profile" "unisase_sia" {
  primary_key               = fortisase_security_profile_group.unisase_sia.primary_key
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
