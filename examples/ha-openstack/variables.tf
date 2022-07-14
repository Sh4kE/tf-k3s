variable "availability_zones" {
  type    = list(string)
  default = ["nova"]
}

variable "network_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "image_name" {
  default = "ubuntu-20.04-ansible"
}

variable "floating_ip_pool" {
  type    = string
  default = null
}

variable "master1_flavor_name" {
  type = string
}

variable "masters_flavor_name" {
  type = string
}

variable "node_flavor_name" {
  type = string
}

variable "data_volume_size" {
  type    = number
  default = 1
}

variable "data_volume_type" {
  type = string
  default = ""
}

variable "server_count" {
  type    = number
  default = 1
}

variable "agent_count" {
  type    = number
  default = 1
}

variable "keypair_name" {
  type    = string
  default = null
}

variable "image_visibility" {
  type        = string
  description = "The visibility of the image. Must be one of \"public\", \"private\", \"community\", or \"shared\"."
  default     = "private"
}

variable "ephemeral_data_volume" {
  default     = false
  description = "use an ephemeral disk for data, which will be deleted on instance termination"
}

variable "kubernetes_cluster_context" {
  type        = string
  default     = "k3s@k3s"
}
