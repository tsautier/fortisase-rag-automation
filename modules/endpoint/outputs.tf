output "tags" {
  # These outputs are mainly intended to create dependencies between modules, their value is negligible.
  value = {
    compliant     = fortisase_endpoint_ztna_tag_rule.compliant.primary_key
    non_compliant = fortisase_endpoint_ztna_tag_rule.non_compliant.primary_key
  }
}
