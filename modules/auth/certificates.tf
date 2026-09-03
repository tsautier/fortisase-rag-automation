resource "fortisase_system_certificate" "remote_cert" {
  primary_key = var.idp_certificate
  certificate_type = "remote-certificate"
  file_content = base64encode(file("./${var.idp_certificate}.crt"))
}
