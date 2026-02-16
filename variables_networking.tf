variable "BGP" {
  type = object({
    bgp_rid_subnet = string // bgp subnet needs to be large enough to accomodate all FortiSASE PoPs, including BOR nodes
    asn            = string // best practice is to use same ASN as the one on on-prem Hubs (iBGP)  
    hc_ip          = string // health-check loopback ip 
    bypass         = bool   // THIS IS ONLY FOR STAGING PURPOSE. REMOVE THE VARIABLE IN PRODUCTION. 
  })
}

variable "ipsec_pre_shared_key" {
  type        = string
  description = "PSK to be used for tunnels"
}

variable "SC" {
  type = list(object({
    name               = string
    backup_link        = bool
    ipsec_remote_gw    = list(string)
    overlay_network_id = list(string)
    route_map_tag      = string
    bgp_peer_ip        = string
    priority           = number
  }))
}
