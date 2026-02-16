variable "webfilter_restricted_categories" {
  description = "List of website categories that should be blocked. Names need to match FortiGuard categories."
  type        = list(string)
  default     = []
  # example   = ["Gambling"]
  # blocked in unisase-sia profile
}

variable "webfilter_restricted_sites" {
  description = "List of websites that should be blocked"
  type        = list(string)
  default     = []
  # example   = ["nytimes.com"]
  # blocked in unisase-sia profile
}

variable "app_restricted_categories" {
  description = "List of app categories that should be blocked. Names need to match FortiGuard categories."
  type        = list(string)
  default     = []
  # example   = ["Social.Media"]
  # blocked in unisase-sia and non-compliant profiles
}

variable "app_critical_apps" {
  description = "Applications that are considered critical for the corporate and should be allowed only to 'compliant' users."
  type        = list(string)
  default     = []
  # example   = ["Github", "Amazon.AWS", Microsoft.365", "Salesforce"]
  # blocked in non-compliant security profile
}

variable "spa_resources" {
  description = "List of corporate resources that remote users need access to"
  type        = list(string)
  default     = []
  # example   = ["10.0.0.7/32", "10.1.100.0/24", "10.2.0.0/8"]
  # create individual host object for each of the item from the list, and then an address group that consildates all created objects inside it. 
}

variable "bor_resources" {
  description = "List of subnets behind onramp locations"
  type        = list(string)
  default     = []
  # example   = ["10.8.1.0/24", "10.8.101.0/24"]
  # create individual host object for each of the item from the list, and then an address group that consildates all created objects inside it.
}

variable "ot_resources" {
  description = "List of devices (userless) in branch on-ramp locations"
  type        = list(string)
  default     = []
  # example   = ["10.10.1.20/32"]
  # create individual host object for each of the item from the list, and then an address group that consildates all created objects inside it.
}

variable "auth_resources" {
  description = "List of servers used for authentication"
  type        = list(string)
  default     = []
  # example   = ["10.21.0.1/32", "10.21.0.2/32"]
}

variable "ipam_resources" {
  description = "List of private subnets used in private networks"
  type        = list(string)
  default     = []
  # example   = ["10.0.0.0/8", "172.16.0.0/24"]
}
