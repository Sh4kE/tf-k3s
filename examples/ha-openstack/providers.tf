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

/*provider "argocd" {
  server_addr = var.argocd_server_addr
  username    = var.argocd_server_user
#  password    = module.k8s-apps.argocd-initial-admin-secret.data.password
  password    = "BWxVDwh-BwXJGrkC"
}*/
