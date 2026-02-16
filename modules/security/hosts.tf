
resource "fortisase_network_hosts" "spa_resources" {
  for_each    = toset(var.spa_resources)
  primary_key = "spa_${replace(each.value, "/", "_")}"
  type        = "ipmask"
  location    = "internal"
  subnet      = each.value
}

resource "fortisase_network_hosts" "bor_resources" {
  for_each    = toset(var.bor_resources)
  primary_key = "bor_${replace(each.value, "/", "_")}"
  type        = "ipmask"
  location    = "internal"
  subnet      = each.value
}

resource "fortisase_network_hosts" "ot_resources" {
  for_each    = toset(var.ot_resources)
  primary_key = "ot_${replace(each.value, "/", "_")}"
  type        = "ipmask"
  location    = "internal"
  subnet      = each.value
}

resource "fortisase_network_hosts" "auth_resources" {
  for_each    = toset(var.auth_resources)
  primary_key = "auth_${replace(each.value, "/", "_")}"
  type        = "ipmask"
  location    = "internal"
  subnet      = each.value
}

resource "fortisase_network_hosts" "ipam_resources" {
  for_each    = toset(var.ipam_resources)
  primary_key = "ipam_${replace(each.value, "/", "_")}"
  type        = "ipmask"
  location    = "internal"
  subnet      = each.value
}

resource "fortisase_network_host_groups" "spa_hosts" {
  primary_key = "spa_hosts"
  members = [
    for host in var.spa_resources : {
      datasource  = "network/hosts"
      primary_key = "spa_${replace(host, "/", "_")}"
    }
  ]
  depends_on = [fortisase_network_hosts.spa_resources]
}

resource "fortisase_network_host_groups" "bor_hosts" {
  primary_key = "bor_hosts"
  members = [
    for host in var.bor_resources : {
      datasource  = "network/hosts"
      primary_key = "bor_${replace(host, "/", "_")}"
    }
  ]
  depends_on = [fortisase_network_hosts.bor_resources]
}

resource "fortisase_network_host_groups" "ot_hosts" {
  primary_key = "ot_hosts"
  members = [
    for host in var.ot_resources : {
      datasource  = "network/hosts"
      primary_key = "ot_${replace(host, "/", "_")}"
    }
  ]
  depends_on = [fortisase_network_hosts.ot_resources]
}

resource "fortisase_network_host_groups" "auth_hosts" {
  primary_key = "auth_hosts"
  members = [
    for host in var.auth_resources : {
      datasource  = "network/hosts"
      primary_key = "auth_${replace(host, "/", "_")}"
    }
  ]
  depends_on = [fortisase_network_hosts.auth_resources]
}

resource "fortisase_network_host_groups" "ipam_hosts" {
  primary_key = "ipam_hosts"
  members = [
    for host in var.ipam_resources : {
      datasource  = "network/hosts"
      primary_key = "ipam_${replace(host, "/", "_")}"
    }
  ]
  depends_on = [fortisase_network_hosts.ipam_resources]
}
