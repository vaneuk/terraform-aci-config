variable "aciUser" {
  description = "If using a Domain with the User Remember to add apic#[domain]\\<username>"
  type        = string
  sensitive   = true
  default     = "admin"
}


variable "aciPass" {
  description = "NEVER Store your USERNAME or PASSWORD in a Public Repository"
  type        = string
  sensitive   = true
}

variable "aciUrl" {
  description = "This can be the IP or Hostname of the ACI Host you will be configuring"
  type        = string
}

variable "dir" {
  description = "Directory with YAML configs"
  type        = string
}


locals {
  cfg_dir = "${path.module}/${var.dir}"
}
