output "network_id" {
  value = openstack_networking_network_v2.internal.id
}

output "subnet_id" {
  value = openstack_networking_subnet_v2.internal.id
}

output "router" {
  value = openstack_networking_router_v2.router
}
