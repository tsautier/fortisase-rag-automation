# Note Default profile is built-in and has to be imported first.action
# See /import.terraform

resource "fortisase_endpoint_connection_profile" "Default" {
  primary_key           = "Default"
  connect_to_fortisase  = "automatically"
  show_disconnect_btn   = "disable"

  available_vpns = []
  secure_internet_access = {
    authenticate_with_sso       = "enable"
    external_browser_saml_login = "disable"
    allow_fido_auth             = "disable"
    failover_sequence           = []
    enable_local_lan            = "enable"
    posture_check = {
      action               = "prohibit"
      tag                  = fortisase_endpoint_ztna_tag_rule.compliant.primary_key
      check_failed_message = "Your endpoint is not compliant and therefore not allowed to connect to FortiSASE"
    }
  }
  on_fabric_rule_set = {
    datasource  = "endpoint/on-net-rules"
    primary_key = fortisase_endpoint_on_net_rule.on_net.primary_key
  }
  endpoint_on_net_bypass = true
}

resource "fortisase_endpoint_protection_profile" "Default" {
  primary_key        = "Default"
  antivirus          = "enable"
  antiransomware     = "disable"
  vulnerability_scan = "enable"
  scheduled_scan = {
    repeat = "weekly"
    time   = "00:00"
    day    = 1
  }
  antivirus_scan = "enable"
  scheduled_antivirus_scan = {
    scan_type = "full"
    repeat    = "daily"
    time      = "00:00"
  }
  event_based_scanning                = "enable"
  automatically_patch_vulnerabilities = "enable"
  automatic_vulnerability_patch_level = "medium"
  default_action                      = "monitor"
  notify_endpoint_of_blocks           = "enable"
}

# Sandbox

resource "fortisase_endpoint_sandbox_profile" "Default" {
  primary_key                      = "Default"
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

resource "fortisase_endpoint_setting_profile" "Default" {
  primary_key             = "Default"
  allow_config_backup     = "disable"
  show_tag_forti_client   = "enable"
  show_notifications      = "disable"
  notify_vpn_issue        = "enable"
  users_can_disconnect    = "disable"
  ems_disconnect_password = "disable"
}
