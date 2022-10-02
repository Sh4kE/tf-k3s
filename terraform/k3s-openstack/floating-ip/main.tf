resource "openstack_networking_floatingip_v2" "k8s_api" {
  pool  = var.floating_ip_pool
}
