resource "fortisase_infra_ssid" "guest_wifi" {
  primary_key    = "guest-wifi"
  broadcast_ssid = "enable"
  security_mode  = "wpa2-only-personal"
  pre_shared_key = "1234567890"
  wifi_ssid      = "guest-wifi"
  client_limit   = 100
}