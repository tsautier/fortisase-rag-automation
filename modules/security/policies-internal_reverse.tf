resource "fortisase_security_internal_reverse_policies" "Agent_to_BOR" {
  primary_key = "Agent_to_BOR"
  enabled     = true
  scope       = "thin-edge"
  destinations = []
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
      primary_key = fortisase_security_profile_group.no_inspection.primary_key
      datasource  = "security/profile-groups"
    }
    force_cert_inspection = true
  }
  sources = [
    {
      primary_key = fortisase_network_host_groups.ipam_hosts.primary_key
      datasource  = "network/host-groups"
    }
  ]
  schedule = {
    primary_key = "always"
    datasource  = "security/recurring-schedules"
  }
  comments = "Access to SPA and BOR resources for iOT devices connected present in BOR locations"
}

resource "fortisase_security_internal_reverse_policies" "Agent_to_agent" {
  primary_key = "Agent_to_agent"
  enabled     = true
  scope       = "vpn-user"
  destinations = [
  ]
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
      primary_key = fortisase_security_profile_group.no_inspection.primary_key
      datasource  = "security/profile-groups"
    }
    force_cert_inspection = true
  }
  sources = [
    {
      primary_key = fortisase_network_host_groups.ipam_hosts.primary_key
      datasource  = "network/host-groups"
    }
  ]
  schedule = {
    primary_key = "always"
    datasource  = "security/recurring-schedules"
  }
  comments = "Access to SPA and BOR resources for iOT devices connected present in BOR locations"
}

resource "fortisase_security_internal_reverse_policies" "SPA_to_BOR" {
  primary_key = "SPA_to_BOR"
  enabled     = true
  scope       = "thin-edge"
  destinations = [
  ]
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
      primary_key = fortisase_network_host_groups.spa_hosts.primary_key
      datasource  = "network/host-groups"
    }

  ]
  schedule = {
    primary_key = "always"
    datasource  = "security/recurring-schedules"
  }
  comments = "Access to SPA and BOR resources for iOT devices connected present in BOR locations"
}


resource "fortisase_security_internal_reverse_policies" "SPA_to_agents" {
  primary_key = "SPA_to_agents"
  enabled     = true
  scope       = "vpn-user"
  destinations = [
  ]
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
      primary_key = fortisase_network_host_groups.spa_hosts.primary_key
      datasource  = "network/host-groups"
    },
    {
      primary_key = fortisase_network_host_groups.bor_hosts.primary_key
      datasource  = "network/host-groups"
    }
  ]
  schedule = {
    primary_key = "always"
    datasource  = "security/recurring-schedules"
  }
  comments = "Access to SPA and BOR resources for iOT devices connected present in BOR locations"
}
