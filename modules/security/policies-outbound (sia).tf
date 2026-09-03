resource "fortisase_security_outbound_policy" "DNS_Agentless" {
  primary_key           = "DNS_Agentless"
  enabled               = true
  scope                 = "specify"
  users                 = []
  captive_portal_exempt = true
  destinations = [
    {
      primary_key = "all"
      datasource  = "network/hosts"
    }
  ]
  services = [
    {
      primary_key = "DNS"
      datasource  = "security/services"
    }
  ]
  action      = "accept"
  log_traffic = "all"
  profile_group = {
    group = {
      primary_key = fortisase_security_profile_group.unisase_sia.primary_key
      datasource  = "security/profile-groups"
    }
    force_cert_inspection = false
  }
  sources = [{
    primary_key = fortisase_network_host_group.ot_hosts.primary_key
    datasource  = "network/host-groups"
  }]
  schedule = {
    primary_key = "always"
    datasource  = "security/recurring-schedules"
  }
  comments = ""
}

resource "fortisase_security_outbound_policy" "DNS_Agents" {
  primary_key = "DNS_Agents"
  enabled     = true
  scope       = "all"
  users       = []
  destinations = [
    {
      primary_key = "all"
      datasource  = "network/hosts"
    }
  ]
  services = [
    {
      primary_key = "DNS"
      datasource  = "security/services"
    }
  ]
  action      = "accept"
  log_traffic = "all"
  profile_group = {
    group = {
      primary_key = fortisase_security_profile_group.unisase_sia.primary_key
      datasource  = "security/profile-groups"
    }
    force_cert_inspection = false
  }
  sources = []
  schedule = {
    primary_key = "always"
    datasource  = "security/recurring-schedules"
  }
  comments = ""
}

resource "fortisase_security_outbound_policy" "Authentication_Traffic" {
  primary_key           = "Authentication_Traffic"
  count                 = length(var.auth_resources) > 0 ? 1 : 0
  enabled               = true
  scope                 = "specify"
  users                 = []
  captive_portal_exempt = true
  destinations = [
    {
      primary_key = fortisase_network_host_group.auth_hosts.primary_key
      datasource  = "network/host-groups"
    }
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
  sources = [{
    primary_key = fortisase_network_host.gall.primary_key
    datasource  = "network/hosts"
    }
  ]
  schedule = {
    primary_key = "always"
    datasource  = "security/recurring-schedules"
  }
  comments = ""
}

resource "fortisase_security_outbound_policy" "Authentication_Public" {
  primary_key           = "Authentication_Public"
  enabled               = true
  scope                 = "specify"
  users                 = []
  captive_portal_exempt = true
  destinations = [
    {
      primary_key = "Microsoft-Azure.AD"
      datasource  = "network/internet-services"
    }
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
    force_cert_inspection = false
  }
  sources = [{
    primary_key = fortisase_network_host.gall.primary_key
    datasource  = "network/hosts"
    }
  ]
  schedule = {
    primary_key = "always"
    datasource  = "security/recurring-schedules"
  }
  comments = ""
}

resource "fortisase_security_outbound_policy" "bor_iOT" {
  primary_key           = "bor_iOT"
  enabled               = true
  scope                 = "specify"
  captive_portal_exempt = true
  users                 = []
  destinations = [
    {
      primary_key = "all"
      datasource  = "network/hosts"
    }
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
      primary_key = fortisase_security_profile_group.iOT.primary_key
      datasource  = "security/profile-groups"
    }
    force_cert_inspection = true
  }
  sources = [
    {
      primary_key = fortisase_network_host_group.ot_hosts.primary_key
      datasource  = "network/host-groups"
    }
  ]

  schedule = {
    primary_key = "always"
    datasource  = "security/recurring-schedules"
  }
  comments = ""
}



resource "fortisase_security_outbound_policy" "Agent_non_compliant" {
  primary_key = "Agent_non_compliant"
  enabled     = true
  scope       = "vpn-user"
  users       = []
  destinations = [
    {
      primary_key = "all"
      datasource  = "network/hosts"
    }
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
      primary_key = fortisase_security_profile_group.non_compliant.primary_key
      datasource  = "security/profile-groups"
    }
    force_cert_inspection = true
  }
  sources = []
  captive_portal_exempt = false

  schedule = {
    primary_key = "always"
    datasource  = "security/recurring-schedules"
  }
  comments = ""
}


resource "fortisase_security_outbound_policy" "Agent_compliant" {
  primary_key = "Agent_compliant"
  enabled     = true
  scope       = "vpn-user"
  users       = []
  destinations = [
    {
      primary_key = "all"
      datasource  = "network/hosts"
    }
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
      primary_key = fortisase_security_profile_group.unisase_sia.primary_key
      datasource  = "security/profile-groups"
    }
    force_cert_inspection = true
  }
  sources = []
  captive_portal_exempt = false

  schedule = {
    primary_key = "always"
    datasource  = "security/recurring-schedules"
  }
  comments = ""
}



resource "fortisase_security_outbound_policy" "BOR_all_users" {
  primary_key = "BOR_all_users"
  enabled     = true
  scope       = "specify"
  users       = []
  destinations = [
    {
      primary_key = "all"
      datasource  = "network/hosts"
    }
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
      primary_key = fortisase_security_profile_group.unisase_sia.primary_key
      datasource  = "security/profile-groups"
    }
    force_cert_inspection = true
  }

  sources = [
    {
      primary_key = fortisase_network_host_group.bor_hosts.primary_key
      datasource  = "network/host-groups"
    }
  ]
  captive_portal_exempt = false

  schedule = {
    primary_key = "always"
    datasource  = "security/recurring-schedules"
  }
  comments = ""
}
