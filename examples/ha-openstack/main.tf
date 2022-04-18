resource "random_password" "cluster_token" {
  length  = 64
  special = false
}

resource "random_password" "bootstrap_token_id" {
  length  = 6
  upper   = false
  special = false
}

resource "random_password" "bootstrap_token_secret" {
  length  = 16
  upper   = false
  special = false
}

module "secgroup" {
  source = "../../k3s-openstack/security-group"
}

locals {
  token = "${random_password.bootstrap_token_id.result}.${random_password.bootstrap_token_secret.result}"
  common_k3s_args = [
    "--kube-apiserver-arg", "enable-bootstrap-token-auth",
    "--disable", "traefik"
  ]
}

data "k8sbootstrap_auth" "auth" {
  depends_on = [module.secgroup]

  server = module.server1.k3s_external_url
  token  = local.token
}

module "floating-ip-master-lb" {
  source = "../../k3s-openstack/floating-ip"

  floating_ip_pool = var.floating_ip_pool
}

module "server1" {
  source = "../../k3s-openstack"

  name               = "k3s-server-1"
  image_name         = var.image_name
  flavor_name        = var.master1_flavor_name
  availability_zone  = var.availability_zones[0]
  keypair_name       = var.keypair_name != null ? var.keypair_name : openstack_compute_keypair_v2.k3s[0].name
  network_id         = var.network_id
  subnet_id          = var.subnet_id
  security_group_ids = [module.secgroup.id]
  data_volume_size   = var.data_volume_size
  data_volume_type   = var.data_volume_type
  floating_ip_pool   = var.floating_ip_pool
  k3s_external_ip    = module.floating-ip-master-lb.floating_ip

  cluster_token          = random_password.cluster_token.result
  k3s_args               = concat(["server", "--cluster-init"], local.common_k3s_args, ["--node-label", "az=${var.availability_zones[0]}"])
  bootstrap_token_id     = random_password.bootstrap_token_id.result
  bootstrap_token_secret = random_password.bootstrap_token_secret.result
}

module "servers" {
  source = "../../k3s-openstack"

  count = var.server_count

  name               = "k3s-server-${count.index + 2}"
  image_name         = var.image_name
  flavor_name        = var.masters_flavor_name
  availability_zone  = var.availability_zones[count.index + 1 % length(var.availability_zones)]
  keypair_name       = var.keypair_name != null ? var.keypair_name : openstack_compute_keypair_v2.k3s[0].name
  network_id         = var.network_id
  subnet_id          = var.subnet_id
  security_group_ids = [module.secgroup.id]
  data_volume_size   = var.data_volume_size
  data_volume_type   = var.data_volume_type
  k3s_external_ip    = module.floating-ip-master-lb.floating_ip

  k3s_join_existing = true
  k3s_url           = module.server1.k3s_url
  cluster_token     = random_password.cluster_token.result
  k3s_args          = concat(["server"], local.common_k3s_args, ["--node-label", "az=${var.availability_zones[count.index + 1 % length(var.availability_zones)]}"])
}

module "agents" {
  source = "../../k3s-openstack"

  count = var.agent_count

  name               = "k3s-agent-${count.index + 1}"
  image_name         = var.image_name
  flavor_name        = var.node_flavor_name
  availability_zone  = var.availability_zones[count.index % length(var.availability_zones)]
  keypair_name       = var.keypair_name != null ? var.keypair_name : openstack_compute_keypair_v2.k3s[0].name
  network_id         = var.network_id
  subnet_id          = var.subnet_id
  security_group_ids = [module.secgroup.id]
  data_volume_size   = var.data_volume_size
  data_volume_type   = var.data_volume_type

  k3s_join_existing = true
  k3s_url           = module.server1.k3s_url
  cluster_token     = random_password.cluster_token.result
  k3s_args          = ["agent", "--node-label", "az=${var.availability_zones[count.index % length(var.availability_zones)]}"]
}

module "load-balancer" {
  source = "../../k3s-openstack/load-balancer"
  floating_ip = module.floating-ip-master-lb.floating_ip
  subnet_id = var.subnet_id
  members = {
    "k3s-server-1" = module.server1.node_ip
    "k3s-server-2" = module.servers[0].node_ip
    "k3s-server-3" = module.servers[1].node_ip
  }
}

output "cluster_token" {
  value     = random_password.cluster_token.result
  sensitive = true
}

output "k3s_url" {
  value = module.server1.k3s_url
}

output "k3s_external_url" {
  value = module.server1.k3s_external_url
}

output "server_ip" {
  value = module.server1.node_ip
}

output "server_external_ip" {
  value = module.server1.node_external_ip
}

output "server_user_data" {
  value     = module.server1.user_data
  sensitive = true
}

output "token" {
  value     = local.token
  sensitive = true
}

output "ca_crt" {
  value = data.k8sbootstrap_auth.auth.ca_crt
}

output "kubeconfig" {
  value     = data.k8sbootstrap_auth.auth.kubeconfig
  sensitive = true
}

provider "kubernetes" {
  host                   = module.server1.k3s_url
  token                  = local.token
  cluster_ca_certificate = data.k8sbootstrap_auth.auth.ca_crt
}

# Configure the OpenStack Provider
provider "openstack" {
}
