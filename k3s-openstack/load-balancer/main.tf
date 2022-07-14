resource "openstack_lb_loadbalancer_v2" "k8s_api" {
  name = "K8s Master LB"
  vip_subnet_id = var.subnet_id
  security_group_ids    = var.security_group_ids
  admin_state_up = true
}

resource "openstack_networking_floatingip_associate_v2" "float_ip_association" {
  floating_ip = var.floating_ip
  port_id = openstack_lb_loadbalancer_v2.k8s_api.vip_port_id
}

resource "openstack_lb_pool_v2" "k8s_api" {
  name            = "K8s Master Pool API"
  protocol        = "HTTPS"
  lb_method       = "ROUND_ROBIN"
  loadbalancer_id = openstack_lb_loadbalancer_v2.k8s_api.id
  admin_state_up  = true
}

resource "openstack_lb_pool_v2" "https" {
  name            = "K8s Master Pool HTTPS"
  protocol        = "HTTPS"
  lb_method       = "ROUND_ROBIN"
  loadbalancer_id = openstack_lb_loadbalancer_v2.k8s_api.id
  admin_state_up  = true
}

resource "openstack_lb_pool_v2" "http" {
  name            = "K8s Master Pool HTTP"
  protocol        = "HTTP"
  lb_method       = "ROUND_ROBIN"
  loadbalancer_id = openstack_lb_loadbalancer_v2.k8s_api.id
  admin_state_up  = true
}

#resource "openstack_lb_pool_v2" "wireguard" {
#  name            = "K8s Pool Wireguard"
#  protocol        = "UDP"
#  lb_method       = "ROUND_ROBIN"
#  loadbalancer_id = openstack_lb_loadbalancer_v2.k8s_api.id
#  admin_state_up  = true
#}

resource "openstack_lb_listener_v2" "k8s_api" {
  name            = "K8s Master Listener API"
  protocol        = "HTTPS"
  protocol_port   = 6443
  loadbalancer_id = openstack_lb_loadbalancer_v2.k8s_api.id
  default_pool_id = openstack_lb_pool_v2.k8s_api.id
  admin_state_up  = true
}

resource "openstack_lb_listener_v2" "https" {
  name            = "K8s Master Listener HTTPS"
  protocol        = "HTTPS"
  protocol_port   = 443
  loadbalancer_id = openstack_lb_loadbalancer_v2.k8s_api.id
  default_pool_id = openstack_lb_pool_v2.https.id
  admin_state_up  = true
}

resource "openstack_lb_listener_v2" "http" {
  name            = "K8s Master Listener HTTP"
  protocol        = "HTTP"
  protocol_port   = 80
  loadbalancer_id = openstack_lb_loadbalancer_v2.k8s_api.id
  default_pool_id = openstack_lb_pool_v2.http.id
  admin_state_up  = true
}

resource "openstack_lb_member_v2" "k8s_api" {
  for_each       = var.masters

  name           = each.key
  pool_id        = openstack_lb_pool_v2.k8s_api.id
  address        = each.value
  protocol_port  = 6443
  admin_state_up = true
}

resource "openstack_lb_member_v2" "https" {
  for_each       = var.members

  name           = each.key
  pool_id        = openstack_lb_pool_v2.https.id
  address        = each.value
  protocol_port  = 443
  admin_state_up = true
}

resource "openstack_lb_member_v2" "http" {
  for_each       = var.members

  name           = each.key
  pool_id        = openstack_lb_pool_v2.http.id
  address        = each.value
  protocol_port  = 80
  admin_state_up = true
}

resource "openstack_lb_monitor_v2" "k8s_api" {
  name           = "K8s Master Health Monitor"
  pool_id        = openstack_lb_pool_v2.k8s_api.id
  type           = "TLS-HELLO"
  delay          = 5
  timeout        = 5
  max_retries    = 3
  admin_state_up = true
}

resource "openstack_lb_monitor_v2" "https" {
  name           = "K8s HTTPS Health Monitor"
  pool_id        = openstack_lb_pool_v2.https.id
  type           = "HTTPS"
  delay          = 5
  timeout        = 5
  max_retries    = 3
  admin_state_up = true
  expected_codes = "404"
}

resource "openstack_lb_monitor_v2" "http" {
  name           = "K8s HTTP Health Monitor"
  pool_id        = openstack_lb_pool_v2.http.id
  type           = "HTTP"
  delay          = 5
  timeout        = 5
  max_retries    = 3
  admin_state_up = true
  expected_codes = "404"
}
