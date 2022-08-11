provider "k8sbootstrap" {
  # Configuration options
}

# Configure the OpenStack Provider
provider "openstack" {
}

provider "kubernetes" {
  host                   = module.server1.k3s_external_url
#  config_path            = "~/.kube/config"
  token                  = local.token
  cluster_ca_certificate = data.k8sbootstrap_auth.auth.ca_crt
}

provider "vault" {}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
