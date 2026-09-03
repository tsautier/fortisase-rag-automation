provider "fortisase" {
  username = var.username
  password = var.password
}

module "auth" {
  source          = "./modules/auth"
  username        = var.username
  password        = var.password
  idp_entity_id   = var.idp_entity_id
  idp_sign_on_url = var.idp_sign_on_url
  idp_log_out_url = var.idp_log_out_url
  idp_certificate = var.idp_certificate
}

module "networking" {
  source               = "./modules/networking"
  username             = var.username
  password             = var.password
  BGP                  = var.BGP
  SC                   = var.SC
  ipsec_pre_shared_key = var.ipsec_pre_shared_key
}

module "endpoint" {
  source                    = "./modules/endpoint"
  username                  = var.username
  password                  = var.password
  on_net_known_public_ips   = var.on_net_known_public_ips
  on_net_known_local_subnet = var.on_net_known_local_subnet
}

module "security" {
  source                          = "./modules/security"
  username                        = var.username
  password                        = var.password
  webfilter_restricted_categories = var.webfilter_restricted_categories
  webfilter_restricted_sites      = var.webfilter_restricted_sites
  app_restricted_categories       = var.app_restricted_categories
  app_critical_apps               = var.app_critical_apps
  spa_resources                   = var.spa_resources
  bor_resources                   = var.bor_resources
  ot_resources                    = var.ot_resources
  ipam_resources                  = var.ipam_resources
  auth_resources                  = var.auth_resources
  tags                            = module.endpoint.tags
}
