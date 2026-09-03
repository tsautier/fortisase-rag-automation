resource "fortisase_infra_ssid" "corp_wifi" {
  primary_key    = "corp-wifi"
  broadcast_ssid = "enable"
  security_mode  = "wpa2-only-personal"
  pre_shared_key = "1234567890"
  wifi_ssid      = "corp-wifi"
  client_limit   = 100
  security_groups = [{
    datasource  = "auth/user-groups"
    primary_key = fortisase_auth_user_group.Marketing.primary_key
  }]
}
