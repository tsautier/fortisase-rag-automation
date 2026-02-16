resource "fortisase_endpoint_ztna_tags" "non_compliant" {
  primary_key = "non_compliant"
}

# Rules
resource "fortisase_endpoint_ztna_rules" "non_compliant" {
  primary_key = fortisase_endpoint_ztna_tags.non_compliant.primary_key
  status      = "enable"
  rules = [
    {
      content = "AV Software is installed and running"
      id      = 1
      negated = true
      os      = "windows"
      type    = "anti-virus"
    },
    {
      content = "Critical"
      id      = 2
      negated = false
      os      = "windows"
      type    = "vulnerable-devices"
    },
    {
      content = "AV Software is installed and running"
      id      = 3
      negated = true
      os      = "macos"
      type    = "anti-virus"
    },
    {
      content = "Critical"
      id      = 4
      negated = false
      os      = "macos"
      type    = "vulnerable-devices"
    }
  ]
  logic = {
    windows = jsonencode({
      op = "and"
      rules = [
        {
          id = 1
        },
        {
          id = 2
        }
      ]
    })
    macos = jsonencode({
      op = "and"
      rules = [
        {
          id = 3
        },
        {
          id = 4
        }
      ]
    })
    linux   = ""
    ios     = ""
    android = ""
  }

  tag = {
    datasource  = "endpoint/ztna-tags"
    primary_key = fortisase_endpoint_ztna_tags.non_compliant.primary_key
  }
}
