resource "fortisase_endpoint_policy" "sse_standard" {
  primary_key                           = "SSE standard"
  enabled                               = true
  skip_off_net_profile_creation_on_edit = true
}

# Connection

resource "fortisase_endpoint_connection_profile" "sse_standard" {
  primary_key = fortisase_endpoint_policy.sse_standard.primary_key
  connect_to_fortisase  = "automatically"
  show_disconnect_btn   = "enable"
  secure_internet_access = {
    authenticate_with_sso       = "enable"
    external_browser_saml_login = "disable"
    allow_fido_auth             = "disable"
    failover_sequence           = []
    enable_local_lan = "enable"
  }
  on_fabric_rule_set = {
    datasource  = "endpoint/on-net-rules"
    primary_key = ""
  }
}

# Protection

resource "fortisase_endpoint_protection_profile" "sse_standard" {
  primary_key        = fortisase_endpoint_policy.sse_standard.primary_key
  antivirus          = "disable"
  antiransomware     = "disable"
  vulnerability_scan = "enable"
  scheduled_scan = {
    repeat = "daily"
    time   = "00:00"
  }
  event_based_scanning                = "enable"
  automatically_patch_vulnerabilities = "enable"
  automatic_vulnerability_patch_level = "medium"
  default_action                      = "monitor"
  notify_endpoint_of_blocks           = "enable"
}

# Sandbox

resource "fortisase_endpoint_sandbox_profile" "sse_standard" {
  primary_key                      = fortisase_endpoint_policy.sse_standard.primary_key
  sandbox_mode                     = "FortiSASE"
  timeout_awaiting_sandbox_results = 300
  file_submission_options = {
    all_files_removable_media       = "enable"
    all_files_mapped_network_drives = "enable"
    all_web_downloads               = "enable"
    all_email_downloads             = "enable"

  }
  notification_type       = 0
  remediation_actions     = "quarantine"
  detection_verdict_level = "Medium"
  exceptions = {
    exclude_files_from_trusted_sources = "disable"
    files                              = []
    folders                            = []
  }
}

# Forticlient GUI settings

resource "fortisase_endpoint_setting_profile" "sse_standard" {
  primary_key             = fortisase_endpoint_policy.sse_standard.primary_key
  allow_config_backup     = "disable"
  show_tag_forti_client   = "enable"
  show_notifications      = "disable"
  notify_vpn_issue        = "enable"
  users_can_disconnect    = "disable"
  ems_disconnect_password = "disable"
}
