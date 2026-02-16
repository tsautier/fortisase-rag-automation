resource "fortisase_endpoint_policies" "sase_strict" {
  primary_key                           = "SASE strict"
  enabled                               = true
  skip_off_net_profile_creation_on_edit = true
}

# Connection

resource "fortisase_endpoint_connection_profiles" "sase_strict" {
  primary_key = fortisase_endpoint_policies.sase_strict.primary_key
  lockdown = {
    grace_period = 600
    detect_captive_portal = {
      status = "enable"
    }
    status = "enable"
  }
  connect_to_forti_sase = "automatically"
  show_disconnect_btn   = "disable"
  secure_internet_access = {
    authenticate_with_sso       = "enable"
    external_browser_saml_login = "disable"
    allow_fido_auth             = "disable"
    failover_sequence           = []
    posture_check = {
      action               = "prohibit"
      tag                  = fortisase_endpoint_ztna_tags.non_compliant.primary_key
      check_failed_message = "your endpoint is not compliant and therefore not allowed to connect to FortiSASE"
    }
    enable_local_lan = "enable"
  }
  on_fabric_rule_set = {
    datasource  = "endpoint/on-net-rules"
    primary_key = fortisase_endpoint_on_net_rules.on_net.primary_key
  }
  endpoint_on_net_bypass = true
}

# Protection

resource "fortisase_endpoint_protection_profiles" "sase_strict" {
  primary_key    = fortisase_endpoint_policies.sase_strict.primary_key
  antivirus      = "enable"
  antiransomware = "enable"
  antivirus_scan = "enable"
  scheduled_antivirus_scan = {
    scan_type = "quick"
    repeat    = "daily"
    time      = "00:00"
  }
  protected_folders_path = [
    "%USERPROFILE%\\Documents\\",
    "%USERPROFILE%\\Pictures\\"
  ]
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
  depends_on = [ fortisase_endpoint_connection_profiles.sase_strict ]
}

# Sandbox

resource "fortisase_endpoint_sandbox_profiles" "sase_strict" {
  primary_key                      = fortisase_endpoint_policies.sase_strict.primary_key
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

resource "fortisase_endpoint_setting_profiles" "sase_strict" {
  primary_key             = fortisase_endpoint_policies.sase_strict.primary_key
  allow_config_backup     = "disable"
  show_tag_forti_client   = "enable"
  show_notifications      = "disable"
  notify_vpn_issue        = "enable"
  users_can_disconnect    = "disable"
  ems_disconnect_password = "disable"
}
