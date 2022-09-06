resource "openstack_networking_network_v2" "internal" {
  name = "internal"
}

resource "openstack_networking_subnet_v2" "internal" {
  name            = replace(var.cidr, "/[^0-9]/", "-")
  network_id      = openstack_networking_network_v2.internal.id
  cidr            = var.cidr
  ip_version      = 4
  dns_nameservers = []
  enable_dhcp     = true
}

resource "openstack_networking_router_v2" "router" {
  name                = var.router_name
  admin_state_up      = true
  external_network_id = var.external_network_id
}

resource "openstack_networking_router_interface_v2" "router_interface_1" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.internal.id
}
