resource "fortisase_security_internal_policies" "BOR_SPA_iOT" {
  primary_key = "BOR_SPA_iOT"
  enabled     = true
  scope       = "specify"
  users       = []
  destinations = [
    {
      primary_key = fortisase_network_host_groups.bor_hosts.primary_key
      datasource  = "network/host-groups"
    },
    {
      primary_key = fortisase_network_host_groups.spa_hosts.primary_key
      datasource  = "network/host-groups"
    }
  ]
  services = [
    {
      primary_key = "ALL"
      datasource  = "security/services"
    }
  ]
  captive_portal_exempt = false
  action                = "accept"
  log_traffic           = "all"
  profile_group = {
    group = {
      primary_key = fortisase_security_profile_group.unisase_spa.primary_key
      datasource  = "security/profile-groups"
    }
    force_cert_inspection = true
  }
  sources = [
    {
      primary_key = fortisase_network_host_groups.ot_hosts.primary_key
      datasource  = "network/host-groups"
    }
  ]
  schedule = {
    primary_key = "always"
    datasource  = "security/recurring-schedules"
  }
  comments = "Access to SPA and BOR resources for iOT devices connected present in BOR locations"
}


resource "fortisase_security_internal_policies" "Agent_to_agent_non_compliant" {
  primary_key = "Agent_to_agent_non_compliant"
  enabled     = true
  scope       = "vpn-user"
  users       = []
  destinations = [
    {
      primary_key = fortisase_network_host_groups.ipam_hosts.primary_key
      datasource  = "network/host-groups"
    }
  ]
  services = [
    {
      primary_key = "ALL"
      datasource  = "security/services"
    }
  ]
  captive_portal_exempt = false
  action                = "deny"
  log_traffic           = "all"
  profile_group = {
    group = {
      primary_key = fortisase_security_profile_group.unisase_spa.primary_key
      datasource  = "security/profile-groups"
    }
    force_cert_inspection = true
  }
  sources = [
    {
      primary_key = var.tags.non_compliant
      datasource  = "endpoint/ztna-tags"
    }
  ]
  schedule = {
    primary_key = "always"
    datasource  = "security/recurring-schedules"
  }
  comments = "Access to SPA and BOR resources for iOT devices connected present in BOR locations"
}


resource "fortisase_security_internal_policies" "Agent_to_agent_compliant" {
  primary_key = "Agent_to_agent_compliant"
  enabled     = true
  scope       = "vpn-user"
  users = [
    {
      primary_key = fortisase_auth_user_groups.Marketing.primary_key
      datasource  = "auth/user-groups"
    }
  ]
  destinations = [
    {
      primary_key = fortisase_network_host_groups.ipam_hosts.primary_key
      datasource  = "network/host-groups"
    }
  ]
  services = [
    {
      primary_key = "ALL"
      datasource  = "security/services"
    }
  ]
  captive_portal_exempt = false
  action                = "accept"
  log_traffic           = "all"
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
      datasource  = "endpoint/ztna-tags"
    }
  ]
  schedule = {
    primary_key = "always"
    datasource  = "security/recurring-schedules"
  }
  comments = "Access to SPA and BOR resources for iOT devices connected present in BOR locations"
}


resource "fortisase_security_internal_policies" "Agent_SPA_non_compliant" {
  primary_key = "Agent_SPA_non_compliant"
  enabled     = true
  scope       = "vpn-user"
  users       = []
  destinations = [
    {
      primary_key = fortisase_network_host_groups.spa_hosts.primary_key
      datasource  = "network/host-groups"
    },
    {
      primary_key = fortisase_network_host_groups.bor_hosts.primary_key
      datasource  = "network/host-groups"
    }
  ]
  services = [
    {
      primary_key = "ALL"
      datasource  = "security/services"
    }
  ]
  captive_portal_exempt = false
  action                = "deny"
  log_traffic           = "all"
  profile_group = {
    group = {
      primary_key = fortisase_security_profile_group.unisase_spa.primary_key
      datasource  = "security/profile-groups"
    }
    force_cert_inspection = true
  }
  sources = [
    {
      primary_key = var.tags.non_compliant
      datasource  = "endpoint/ztna-tags"
    }
  ]
  schedule = {
    primary_key = "always"
    datasource  = "security/recurring-schedules"
  }
  comments = "Access to SPA and BOR resources for iOT devices connected present in BOR locations"
}


resource "fortisase_security_internal_policies" "Agent_SPA_compliant" {
  primary_key = "Agent_SPA_compliant"
  enabled     = true
  scope       = "vpn-user"
  users = [
    {
      primary_key = fortisase_auth_user_groups.Marketing.primary_key
      datasource  = "auth/user-groups"
    }
  ]
  destinations = [
    {
      primary_key = fortisase_network_host_groups.spa_hosts.primary_key
      datasource  = "network/host-groups"
    },
    {
      primary_key = fortisase_network_host_groups.bor_hosts.primary_key
      datasource  = "network/host-groups"
    }
  ]
  services = [
    {
      primary_key = "ALL"
      datasource  = "security/services"
    }
  ]
  captive_portal_exempt = false
  action                = "accept"
  log_traffic           = "all"
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
      datasource  = "endpoint/ztna-tags"
    }
  ]
  schedule = {
    primary_key = "always"
    datasource  = "security/recurring-schedules"
  }
  comments = "Access to SPA and BOR resources for iOT devices connected present in BOR locations"
}
