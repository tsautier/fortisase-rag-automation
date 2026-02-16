resource "fortisase_endpoint_on_net_rules" "on_net" {
  primary_key = "on_net"
  public_ip   = join(";", var.on_net_known_public_ips)
  local_ip    = join(";", var.on_net_known_local_subnet)
}
