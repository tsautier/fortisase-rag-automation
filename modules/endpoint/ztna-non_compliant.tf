resource "fortisase_endpoint_ztna_tag_rule" "non_compliant" {
  primary_key = "non_compliant"
  status      = "enable"
  description = "Tag for devices non-compliant with the defined security posture, restricting their access to resources and services to minimize potential risks."
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
      # negated = false
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
      # negated = false
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
  }
}
