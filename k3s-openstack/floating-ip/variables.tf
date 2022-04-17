variable "floating_ip_pool" {
  type        = string
  description = "A floating ip will be assigned to the load balancer and registered as k3s_external_ip"
}
