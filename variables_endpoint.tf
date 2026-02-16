variable "on_net_known_public_ips" {
  description = "List of subnets from which an endpoint can connect to be classified as 'on-net'."
  type        = list(string)
  default     = []
  # example   = ["4.6.10.1", "7.10.6.120"]
}

variable "on_net_known_local_subnet" {
  description = "List of subnets from which an endpoint can connect to be classified as 'on-net'."
  type        = list(string)
  default     = []
  # example   = ["10.100.0.0/24", "10.140.0.0/16"]

}



