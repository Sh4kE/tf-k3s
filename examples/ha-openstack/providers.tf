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

provider "kubernetes" {
  host                   = module.server1.k3s_external_url
  config_path            = "~/.kube/config"
  config_context         = terraform.workspace

  alias = "kubeconfig"
}

provider "vault" {
  address = "https://vault.${var.sub_domain}.${var.root_domain}"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "argocd" {
  server_addr = "argocd.${var.sub_domain}.${var.root_domain}"
  username    = "admin"
  password    = module.k8s-apps.argocd-initial-admin-secret.data.password
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    config_context = terraform.workspace
  }
}

provider "helm" {
  kubernetes {
    host                   = module.server1.k3s_external_url
    token                  = local.token
    cluster_ca_certificate = data.k8sbootstrap_auth.auth.ca_crt
  }

  alias = "kubeconfig"
}
