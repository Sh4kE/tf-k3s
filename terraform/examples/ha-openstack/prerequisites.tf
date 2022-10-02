resource "openstack_compute_keypair_v2" "k3s" {
  count = var.keypair_name != null ? 0 : 1
  name  = "k3s"
}
