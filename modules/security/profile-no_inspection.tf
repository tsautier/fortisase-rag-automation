resource "fortisase_security_profile_group" "no_inspection" {
  primary_key = "no_inspection"

  web_filter_profile = {
    status = "disable"
  }

  dlp_filter_profile = {
    status = "disable"
  }

  file_filter_profile = {
    status = "disable"
  }

  antivirus_profile = {
    status = "disable"
  }

  dns_filter_profile = {
    status = "disable"
  }

  application_control_profile = {
    status = "disable"
  }

  video_filter_profile = {
    status = "disable"
  } 

  intrusion_prevention_profile = {
    status = "disable"
  }
}
