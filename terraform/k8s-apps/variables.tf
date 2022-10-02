variable "vault_address" {
  type = string
  default = "https://vault.k3s.sh4ke.rocks"
}

variable "lb_external_ip" {
  type = string
}

variable "root_domain" {
  type = string
}

variable "sub_domain" {
  type = string
}
