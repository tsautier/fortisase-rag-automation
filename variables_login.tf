variable "username" {
  description = "Your API username"
  type        = string
  sensitive   = true
  ephemeral   = true
}

variable "password" {
  description = "Your API password"
  type        = string
  sensitive   = true
  ephemeral   = true
}
