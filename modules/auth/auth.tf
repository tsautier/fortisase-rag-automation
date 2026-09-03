resource "fortisase_auth_vpn_saml_server" "sase-global" {
  idp_entity_id   = var.idp_entity_id
  idp_sign_on_url = var.idp_sign_on_url
  idp_log_out_url = var.idp_log_out_url
  sp_cert = {
    datasource  = "system/certificate/local-certificates"
    primary_key = "FortiSASE Default Certificate"
  }
  # Note the certificate must be uploaded in advance
  idp_certificate = {
    datasource  = "system/certificate/remote-certificates"
    primary_key = fortisase_system_certificate.remote_cert.primary_key
  }
  username         = "username"
  group_name       = "group"
  group_id         = ""
  digest_method    = "sha256"
  entra_id_enabled = false
  scim_enabled     = false
}
