resource "fortisase_infra_ssid" "ot_wifi" {
  primary_key    = "ot-wifi"
  broadcast_ssid = "enable"
  security_mode  = "wpa2-only-personal"
  pre_shared_key = "1234567890"
  wifi_ssid      = "ot-wifi"
  client_limit   = 100
}