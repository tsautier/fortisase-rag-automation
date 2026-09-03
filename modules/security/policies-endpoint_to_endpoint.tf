resource "fortisase_security_endpoint_to_endpoint_policy" "Agent_to_agent_intra_POP" {
  primary_key = "Agent_to_agent_intra_POP"
  enabled     = true
  services = [
    {
      primary_key = "ALL"
      datasource  = "security/services"
    }
  ]
  action      = "accept"
  log_traffic = "all"
  profile_group = {
    group = {
      primary_key = fortisase_security_profile_group.unisase_spa.primary_key
      datasource  = "security/profile-groups"
    }
    force_cert_inspection = true
  }
  sources = [
    {
      primary_key = var.tags.compliant
      datasource  = "endpoint/ztna-tag-rules"
    }
  ]
  schedule = {
    primary_key = "always"
    datasource  = "security/recurring-schedules"
  }
  comments = "Access to SPA and BOR resources for iOT devices connected present in BOR locations"
}
