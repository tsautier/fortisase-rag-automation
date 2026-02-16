output "tags" {
  # These outputs are mainly intended to create dependencies between modules, their value is negligible.
  value = {
    compliant     = fortisase_endpoint_ztna_tags.compliant.primary_key
    non_compliant = fortisase_endpoint_ztna_tags.non_compliant.primary_key
  }
}
