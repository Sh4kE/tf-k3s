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

module "network" {
  source = "../../network"

  cidr                = var.intenal_subnet_cidr
  external_network_id = var.external_network_id
  router_name         = var.router_name
}

module "floating-ip-master-lb" {
  source = "../../k3s-openstack/floating-ip"

  floating_ip_pool = var.floating_ip_pool

  depends_on = [module.network]
}

module "server1" {
  source = "../../k3s-openstack"

  name               = "k3s-server-1.${var.sub_domain}.${var.root_domain}"
  image_name         = var.image_name
  image_visibility   = var.image_visibility
  flavor_name        = var.master1_flavor_name
  availability_zone  = var.availability_zones[0]
  keypair_name       = var.keypair_name != null ? var.keypair_name : openstack_compute_keypair_v2.k3s[0].name
  network_id         = module.network.network_id
  subnet_id          = module.network.subnet_id
  security_group_ids = [module.secgroup.id]
  data_volume_size   = var.data_volume_size
  data_volume_type   = var.data_volume_type
  ephemeral_data_volume = var.ephemeral_data_volume
  floating_ip_pool   = var.floating_ip_pool
  k3s_external_ip    = module.floating-ip-master-lb.floating_ip

  cluster_token          = random_password.cluster_token.result
  k3s_args               = concat(["server", "--cluster-init"],
                                  local.common_k3s_args,
                                  ["--node-label", "az=${var.availability_zones[0]}"],
                                  var.k3s_args
                           )
  bootstrap_token_id     = random_password.bootstrap_token_id.result
  bootstrap_token_secret = random_password.bootstrap_token_secret.result

  additional_address_pairs = [
    var.intenal_subnet_cidr,
    "192.168.178.0/24"
  ]
}

resource "openstack_networking_router_route_v2" "route_to_home_network_via_server1" {
  router_id        = module.network.router.id
  destination_cidr = var.local_subnet
  next_hop         = module.server1.node_ip
}

module "servers" {
  source = "../../k3s-openstack"

  count = var.server_count

  name               = "k3s-server-${count.index + 2}.${var.sub_domain}.${var.root_domain}"
  image_name         = var.image_name
  image_visibility   = var.image_visibility
  flavor_name        = var.masters_flavor_name
  availability_zone  = var.availability_zones[(count.index + 1) % length(var.availability_zones)]
  keypair_name       = var.keypair_name != null ? var.keypair_name : openstack_compute_keypair_v2.k3s[0].name
  network_id         = module.network.network_id
  subnet_id          = module.network.subnet_id
  security_group_ids = [module.secgroup.id]
  data_volume_size   = var.data_volume_size
  data_volume_type   = var.data_volume_type
  ephemeral_data_volume = var.ephemeral_data_volume
  k3s_external_ip    = module.floating-ip-master-lb.floating_ip

  k3s_join_existing = true
  k3s_url           = module.server1.k3s_url
  cluster_token     = random_password.cluster_token.result
  k3s_args          = concat(["server"],
                             local.common_k3s_args,
                             ["--node-label", "az=${var.availability_zones[(count.index + 1) % length(var.availability_zones)]}"],
                             var.k3s_args
                      )
}

module "agents" {
  source = "../../k3s-openstack"

  count = var.agent_count

  name               = "k3s-agent-${count.index + 1}.${var.sub_domain}.${var.root_domain}"
  image_name         = var.image_name
  image_visibility   = var.image_visibility
  flavor_name        = var.node_flavor_name
  availability_zone  = var.availability_zones[count.index % length(var.availability_zones)]
  keypair_name       = var.keypair_name != null ? var.keypair_name : openstack_compute_keypair_v2.k3s[0].name
  network_id         = module.network.network_id
  subnet_id          = module.network.subnet_id
  security_group_ids = [module.secgroup.id]
  data_volume_size   = var.data_volume_size
  data_volume_type   = var.data_volume_type
  ephemeral_data_volume = var.ephemeral_data_volume

  k3s_join_existing = true
  k3s_url           = module.server1.k3s_url
  cluster_token     = random_password.cluster_token.result
  k3s_args          = ["agent", "--node-label", "az=${var.availability_zones[count.index % length(var.availability_zones)]}"]
}

module "load-balancer" {
  source      = "../../k3s-openstack/load-balancer"
  floating_ip = module.floating-ip-master-lb.floating_ip
  subnet_id   = module.network.subnet_id
  security_group_ids = [module.secgroup.security_group_id]
  masters = {
    "k3s-server-1" = module.server1.node_ip
    "k3s-server-2" = module.servers[0].node_ip
    "k3s-server-3" = module.servers[1].node_ip
  }
  members = {
    "k3s-server-1" = module.server1.node_ip
    "k3s-server-2" = module.servers[0].node_ip
    "k3s-server-3" = module.servers[1].node_ip
    "k3s-agent-1" = module.agents[0].node_ip
    "k3s-agent-2" = module.agents[1].node_ip
  }
}

module "dns" {
  source = "../../dns"

  domain         = var.root_domain
  subdomain      = var.sub_domain
  lb_external_ip = module.floating-ip-master-lb.floating_ip
  server1_floating_ip = module.server1.node_floating_ip
}

resource "null_resource" "wait-for-k3s-external-url" {
  triggers = {
    wait_for_external_url = join(",", [jsonencode(module.server1), jsonencode(module.servers[0]), jsonencode(module.servers[1])])
  }

  provisioner "local-exec" {
    command = "curl -ks --retry-all-errors --retry 10 ${module.server1.k3s_external_url}"
  }

  depends_on = [module.server1, module.load-balancer, module.floating-ip-master-lb, module.dns]
}

module "k8s-helm-charts" {
  source = "../../k8s-helm-charts"

  providers = {
    helm = helm.kubeconfig
  }

  depends_on = [null_resource.wait-for-k3s-external-url]
}

module "k8s-apps" {
  source = "../../k8s-apps"

  lb_external_ip = module.floating-ip-master-lb.floating_ip
  sub_domain = var.sub_domain
  root_domain = var.root_domain

  # providers = {
  #   kubernetes = kubernetes.kubeconfig
  # }

  depends_on = [module.k8s-helm-charts]
}

