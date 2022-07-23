provider "k8sbootstrap" {
  # Configuration options
}

# Configure the OpenStack Provider
provider "openstack" {
}

provider "kubernetes" {
  host                   = module.server1.k3s_external_url
  token                  = local.token
  cluster_ca_certificate = data.k8sbootstrap_auth.auth.ca_crt
}

#provider "kubernetes" {
#    config_path = "~/.kube/config"
#    config_context = var.kubernetes_cluster_context
#}
