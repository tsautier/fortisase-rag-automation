resource "fortisase_auth_user_group" "Marketing" {
  primary_key        = "Marketing"
  group_type         = "firewall"
  local_users        = []
  remote_user_groups = []
}
