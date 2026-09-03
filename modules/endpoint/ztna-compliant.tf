resource "fortisase_endpoint_ztna_tag_rule" "compliant" {
  primary_key = "compliant"
  status      = "enable"
  description = "Tag for devices compliant with the defined security posture, allowing them to access more resources and services."
  rules = [
    {
      content = "AV Software is installed and running"
      id      = 1
      #negated = false
      os      = "windows"
      type    = "anti-virus"
    },
    {
      content = "FortiClient installed and Telemetry connected to EMS"
      id      = 2
      # negated = false
      os   = "windows"
      type = "ems-management"
    },
    {
      content = "AV Software is installed and running"
      id      = 3
      #negated = false
      os      = "macos"
      type    = "anti-virus"
    },
    {
      content = "FortiClient installed and Telemetry connected to EMS"
      id      = 4
      # negated = false
      os   = "macos"
      type = "ems-management"
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
  }
}
