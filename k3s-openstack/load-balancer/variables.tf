variable "subnet_id" {
  type = string
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}

variable "floating_ip" {
  type        = string
  description = "A floating ip will be assigned to the load balancer and registered as k3s_external_ip"
}

variable "members" {
  type = map(string)
}
