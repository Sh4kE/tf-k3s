resource "openstack_networking_secgroup_v2" "k3s" {
  count       = var.security_group_id == null ? 1 : 0
  name        = var.security_group_name
  description = "allow k3s services"
}

locals {
  security_group_id = var.security_group_id == null ? openstack_networking_secgroup_v2.k3s[0].id : var.security_group_id
}

output "id" {
  value = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "internal_tcp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_group_id   = local.security_group_id
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "internal_udp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  remote_group_id   = local.security_group_id
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "internal_icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_group_id   = local.security_group_id
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.port_ssh
  port_range_max    = var.port_ssh
  remote_ip_prefix  = var.allow_remote_prefix
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.port_http
  port_range_max    = var.port_http
  remote_ip_prefix  = var.allow_remote_prefix
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "https" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.port_https
  port_range_max    = var.port_https
  remote_ip_prefix  = var.allow_remote_prefix
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "kubernetes_api" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.port_api
  port_range_max    = var.port_api
  remote_ip_prefix  = var.allow_remote_prefix
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "kubernetes_node_ports_tcp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.port_node_tcp_min
  port_range_max    = var.port_node_tcp_max
  remote_ip_prefix  = var.allow_remote_prefix
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "kubernetes_node_ports_udp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = var.port_node_udp_min
  port_range_max    = var.port_node_udp_max
  remote_ip_prefix  = var.allow_remote_prefix
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "kubernetes_wireguard_udp_in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = var.port_node_wireguard_udp
  port_range_max    = var.port_node_wireguard_udp
  remote_ip_prefix  = var.allow_remote_prefix
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "kubernetes_wireguard_udp_out" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = var.port_node_wireguard_udp
  port_range_max    = var.port_node_wireguard_udp
  remote_ip_prefix  = var.allow_remote_prefix
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "smtp_in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.port_smtp
  port_range_max    = var.port_smtp
  remote_ip_prefix  = var.allow_remote_prefix
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "smtp_out" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.port_smtp
  port_range_max    = var.port_smtp
  remote_ip_prefix  = var.allow_remote_prefix
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "esmtp_in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.port_esmtp
  port_range_max    = var.port_esmtp
  remote_ip_prefix  = var.allow_remote_prefix
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "esmtp_out" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.port_esmtp
  port_range_max    = var.port_esmtp
  remote_ip_prefix  = var.allow_remote_prefix
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "esmtp_starttls_in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.port_esmtp_starttls
  port_range_max    = var.port_esmtp_starttls
  remote_ip_prefix  = var.allow_remote_prefix
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "esmtp_starttls_out" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.port_esmtp_starttls
  port_range_max    = var.port_esmtp_starttls
  remote_ip_prefix  = var.allow_remote_prefix
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "imap_in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.port_imap
  port_range_max    = var.port_imap
  remote_ip_prefix  = var.allow_remote_prefix
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "imap_tls_in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.port_imap_tls
  port_range_max    = var.port_imap_tls
  remote_ip_prefix  = var.allow_remote_prefix
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "internal_tcp_v6" {
  count = var.enable_ipv6 ? 1 : 0

  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "tcp"
  remote_group_id   = local.security_group_id
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "internal_udp_v6" {
  count = var.enable_ipv6 ? 1 : 0

  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "udp"
  remote_group_id   = local.security_group_id
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "internal_icmp_v6" {
  count = var.enable_ipv6 ? 1 : 0

  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "ipv6-icmp"
  remote_group_id   = local.security_group_id
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "ssh_v6" {
  count = var.enable_ipv6 ? 1 : 0

  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "tcp"
  port_range_min    = var.port_ssh
  port_range_max    = var.port_ssh
  remote_ip_prefix  = var.allow_remote_prefix_v6
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "kubernetes_api_v6" {
  count = var.enable_ipv6 ? 1 : 0

  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "tcp"
  port_range_min    = var.port_api
  port_range_max    = var.port_api
  remote_ip_prefix  = var.allow_remote_prefix_v6
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "kubernetes_node_ports_tcp_v6" {
  count = var.enable_ipv6 ? 1 : 0

  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "tcp"
  port_range_min    = var.port_node_tcp_min
  port_range_max    = var.port_node_tcp_max
  remote_ip_prefix  = var.allow_remote_prefix_v6
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "kubernetes_node_ports_udp_v6" {
  count = var.enable_ipv6 ? 1 : 0

  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "udp"
  port_range_min    = var.port_node_udp_min
  port_range_max    = var.port_node_udp_max
  remote_ip_prefix  = var.allow_remote_prefix_v6
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "kubernetes_wireguard_udp_v6_in" {
  count = var.enable_ipv6 ? 1 : 0

  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "udp"
  port_range_min    = var.port_node_wireguard_udp
  port_range_max    = var.port_node_wireguard_udp
  remote_ip_prefix  = var.allow_remote_prefix_v6
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "kubernetes_wireguard_udp_v6_out" {
  count = var.enable_ipv6 ? 1 : 0

  direction         = "egress"
  ethertype         = "IPv6"
  protocol          = "udp"
  port_range_min    = var.port_node_wireguard_udp
  port_range_max    = var.port_node_wireguard_udp
  remote_ip_prefix  = var.allow_remote_prefix_v6
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "smtp_v6_in" {
  count = var.enable_ipv6 ? 1 : 0

  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "tcp"
  port_range_min    = var.port_smtp
  port_range_max    = var.port_smtp
  remote_ip_prefix  = var.allow_remote_prefix
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "smtp_v6_out" {
  count = var.enable_ipv6 ? 1 : 0

  direction         = "egress"
  ethertype         = "IPv6"
  protocol          = "tcp"
  port_range_min    = var.port_smtp
  port_range_max    = var.port_smtp
  remote_ip_prefix  = var.allow_remote_prefix
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "esmtp_v6_in" {
  count = var.enable_ipv6 ? 1 : 0

  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "tcp"
  port_range_min    = var.port_esmtp
  port_range_max    = var.port_esmtp
  remote_ip_prefix  = var.allow_remote_prefix
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "esmtp_v6_out" {
  count = var.enable_ipv6 ? 1 : 0

  direction         = "egress"
  ethertype         = "IPv6"
  protocol          = "tcp"
  port_range_min    = var.port_esmtp
  port_range_max    = var.port_esmtp
  remote_ip_prefix  = var.allow_remote_prefix
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "esmtp_starttls_v6_in" {
  count = var.enable_ipv6 ? 1 : 0

  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "tcp"
  port_range_min    = var.port_esmtp_starttls
  port_range_max    = var.port_esmtp_starttls
  remote_ip_prefix  = var.allow_remote_prefix
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "esmtp_starttls_v6_out" {
  count = var.enable_ipv6 ? 1 : 0

  direction         = "egress"
  ethertype         = "IPv6"
  protocol          = "tcp"
  port_range_min    = var.port_esmtp_starttls
  port_range_max    = var.port_esmtp_starttls
  remote_ip_prefix  = var.allow_remote_prefix
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "imap_v6_in" {
  count = var.enable_ipv6 ? 1 : 0

  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "tcp"
  port_range_min    = var.port_imap
  port_range_max    = var.port_imap
  remote_ip_prefix  = var.allow_remote_prefix
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "imap_tls_v6_in" {
  count = var.enable_ipv6 ? 1 : 0

  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "tcp"
  port_range_min    = var.port_imap_tls
  port_range_max    = var.port_imap_tls
  remote_ip_prefix  = var.allow_remote_prefix
  security_group_id = local.security_group_id
}
