resource "fortisase_private_access_network_configuration" "bgp" {
  count = var.BGP.bypass ? 0 : 1

  bgp_design            = "loopback"
  bgp_router_ids_subnet = var.BGP.bgp_rid_subnet
  as_number             = var.BGP.asn
  sdwan_rule_enable     = true
  sdwan_health_check_vm = var.BGP.hc_ip
  recursive_next_hop    = true
}

# ###### Warning ######
# Service Connections cannot be created in a loop because FSS API requires each SC to be created at a time.
# If it's placed in a loop, all SCs will be created at the same time and it will fail.
# And Terraform doesn't allow dynamic dependencies so that an element in a loop depends on the previous iteration. 
resource "fortisase_private_access_service_connections" "sc_1" {

  depends_on = [fortisase_private_access_network_configuration.bgp]

  type                 = "loopback"
  alias                = "${var.SC[0].name}-ISP1"
  ipsec_remote_gw      = var.SC[0].ipsec_remote_gw[0] # primary GW
  ipsec_ike_version    = "2"
  auth                 = "psk"
  ipsec_pre_shared_key = var.ipsec_pre_shared_key
  route_map_tag        = var.SC[0].route_map_tag
  bgp_peer_ip          = var.SC[0].bgp_peer_ip
  overlay_network_id   = var.SC[0].overlay_network_id[0] # primary od ID

  backup_links = var.SC[0].backup_link ? [
    {
      create = [
        {
          alias                = "${var.SC[0].name}-ISP2"
          ipsec_remote_gw      = var.SC[0].ipsec_remote_gw[1]
          ipsec_ike_version    = var.SC[0].ipsec_ike_version
          auth                 = var.SC[0].auth
          ipsec_pre_shared_key = var.SC[0].ipsec_pre_shared_key
          overlay_network_id   = var.SC[0].overlay_network_id[1]
        }
      ]
    }
  ] : []
}

resource "fortisase_private_access_service_connections_region_cost" "sc_1_cost" {

  entries = tomap({
    for region in sort(keys(fortisase_private_access_service_connections.sc_1.config.region_cost)) :
    region => tomap({
      (fortisase_private_access_service_connections.sc_1.id) : var.SC[0].priority
    })
  })

  depends_on = [fortisase_private_access_service_connections.sc_1]
}

resource "fortisase_private_access_service_connections" "sc_2" {

  depends_on = [fortisase_private_access_service_connections_region_cost.sc_1_cost]

  type                 = "loopback"
  alias                = "${var.SC[1].name}-ISP1"
  ipsec_remote_gw      = var.SC[1].ipsec_remote_gw[0] # primary GW
  ipsec_ike_version    = "2"
  auth                 = "psk"
  ipsec_pre_shared_key = var.ipsec_pre_shared_key
  route_map_tag        = var.SC[1].route_map_tag
  bgp_peer_ip          = var.SC[1].bgp_peer_ip
  overlay_network_id   = var.SC[1].overlay_network_id[0] # primary od ID

  backup_links = var.SC[0].backup_link ? [
    {
      create = [
        {
          alias                = "${var.SC[1].name}-ISP2"
          ipsec_remote_gw      = var.SC[1].ipsec_remote_gw[1]
          ipsec_ike_version    = var.SC[1].ipsec_ike_version
          auth                 = var.SC[1].auth
          ipsec_pre_shared_key = var.SC[1].ipsec_pre_shared_key
          overlay_network_id   = var.SC[1].overlay_network_id[1]
        }
      ]
    }
  ] : []
}

resource "fortisase_private_access_service_connections_region_cost" "sc_2_cost" {

  entries = tomap({
    for region in sort(keys(fortisase_private_access_service_connections.sc_2.config.region_cost)) :
    region => tomap({
      (fortisase_private_access_service_connections.sc_2.id) : var.SC[1].priority
    })
  })

  depends_on = [fortisase_private_access_service_connections.sc_2]
}
