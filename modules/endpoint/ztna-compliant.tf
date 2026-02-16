resource "fortisase_endpoint_ztna_tags" "compliant" {
  primary_key = "compliant"
}

# Rules

resource "fortisase_endpoint_ztna_rules" "compliant" {
  primary_key = fortisase_endpoint_ztna_tags.compliant.primary_key
  status      = "enable"
  rules = [
    {
      content = "AV Software is installed and running"
      id      = 1
      negated = false
      os      = "windows"
      type    = "anti-virus"
    },
    {
      content = "FortiClient installed and Telemetry connected to EMS"
      id      = 2
      os      = "windows"
      type    = "ems-management"
    },
    {
      content = "AV Software is installed and running"
      id      = 3
      negated = false
      os      = "macos"
      type    = "anti-virus"
    },
    {
      content = "FortiClient installed and Telemetry connected to EMS"
      id      = 4
      os      = "macos"
      type    = "ems-management"
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
    primary_key = fortisase_endpoint_ztna_tags.compliant.primary_key
  }
}