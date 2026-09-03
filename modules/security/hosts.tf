
resource "fortisase_network_host" "spa_resources" {
  for_each    = toset(var.spa_resources)
  primary_key = "spa_${replace(each.value, "/", "_")}"
  type        = "ipmask"
  location    = "internal"
  subnet      = each.value
}

resource "fortisase_network_host" "bor_resources" {
  for_each    = toset(var.bor_resources)
  primary_key = "bor_${replace(each.value, "/", "_")}"
  type        = "ipmask"
  location    = "internal"
  subnet      = each.value
}

resource "fortisase_network_host" "ot_resources" {
  for_each    = toset(var.ot_resources)
  primary_key = "ot_${replace(each.value, "/", "_")}"
  type        = "ipmask"
  location    = "internal"
  subnet      = each.value
}

resource "fortisase_network_host" "auth_resources" {
  for_each    = toset(var.auth_resources)
  primary_key = "auth_${replace(each.value, "/", "_")}"
  type        = "ipmask"
  location    = "internal"
  subnet      = each.value
}

resource "fortisase_network_host" "ipam_resources" {
  for_each    = toset(var.ipam_resources)
  primary_key = "ipam_${replace(each.value, "/", "_")}"
  type        = "ipmask"
  location    = "internal"
  subnet      = each.value
}

resource "fortisase_network_host" "gall" {
  primary_key = "gall"
  type        = "ipmask"
  location    = "unspecified"
  subnet      = "0.0.0.0/0"
}

resource "fortisase_network_host_group" "spa_hosts" {
  primary_key = "spa_hosts"
  members = [
    for host in var.spa_resources : {
      datasource  = "network/hosts"
      primary_key = "spa_${replace(host, "/", "_")}"
    }
  ]
  depends_on = [fortisase_network_host.spa_resources]
}

resource "fortisase_network_host_group" "bor_hosts" {
  primary_key = "bor_hosts"
  members = [
    for host in var.bor_resources : {
      datasource  = "network/hosts"
      primary_key = "bor_${replace(host, "/", "_")}"
    }
  ]
  depends_on = [fortisase_network_host.bor_resources]
}

resource "fortisase_network_host_group" "ot_hosts" {
  primary_key = "ot_hosts"
  members = [
    for host in var.ot_resources : {
      datasource  = "network/hosts"
      primary_key = "ot_${replace(host, "/", "_")}"
    }
  ]
  depends_on = [fortisase_network_host.ot_resources]
}

resource "fortisase_network_host_group" "auth_hosts" {
  primary_key = "auth_hosts"
  members = [
    for host in var.auth_resources : {
      datasource  = "network/hosts"
      primary_key = "auth_${replace(host, "/", "_")}"
    }
  ]
  depends_on = [fortisase_network_host.auth_resources]
}

resource "fortisase_network_host_group" "ipam_hosts" {
  primary_key = "ipam_hosts"
  members = [
    for host in var.ipam_resources : {
      datasource  = "network/hosts"
      primary_key = "ipam_${replace(host, "/", "_")}"
    }
  ]
  depends_on = [fortisase_network_host.ipam_resources]
}
