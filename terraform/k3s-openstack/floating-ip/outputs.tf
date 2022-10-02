output "floating_ip" {
  value = openstack_networking_floatingip_v2.k8s_api.address
}
