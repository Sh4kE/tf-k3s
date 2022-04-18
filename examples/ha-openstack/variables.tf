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
