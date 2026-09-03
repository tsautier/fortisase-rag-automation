locals {
  restricted_sites = [
    for site in var.webfilter_restricted_sites : {
      action = "block"
      status = "enable"
      type   = "simple"
      url    = site
    }
  ]
}