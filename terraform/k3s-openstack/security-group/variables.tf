variable "security_group_id" {
  type    = string
  default = null
}

variable "security_group_name" {
  type    = string
  default = "allow-k3s"
}

variable "allow_remote_prefix" {
  default = "0.0.0.0/0"
}

variable "enable_ipv6" {
  default = false
}

variable "allow_remote_prefix_v6" {
  default = "::/0"
}

variable "port_ssh" { default = 22 }
variable "port_http" { default = 80 }
variable "port_https" { default = 443 }
variable "port_smtp" { default = 25 }
variable "port_esmtp" { default = 465 }
variable "port_esmtp_starttls" { default = 587 }
variable "port_imap" { default = 143 }
variable "port_imap_tls" { default = 993 }
variable "port_api" { default = 6443 }
variable "port_node_tcp_min" { default = 30000 }
variable "port_node_tcp_max" { default = 32767 }
variable "port_node_udp_min" { default = 30000 }
variable "port_node_udp_max" { default = 32767 }
variable "port_node_wireguard_udp" { default = 51820 }
