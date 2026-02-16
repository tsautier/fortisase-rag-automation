variable "idp_entity_id" {
  description = "Use to define entity Id of the Identity Provider"
  type        = string
  # Example   = "https://sts.windows.net/id/"
}

variable "idp_sign_on_url" {
  description = "Sign on url of Identity Provider"
  type        = string
  # Example   = "https://login.microsoftonline.com/id/saml2"
}

variable "idp_log_out_url" {
  description = "Sign on url of Identity Provider"
  type        = string
  # Example   = "https://login.microsoftonline.com/id/saml2"
}

variable "idp_certificate" {
  description = "Name of the identity provider certificate that is used in Auth SAML process"
  type        = string
  # Example   = "server"
}
