locals {
  create_data_volume = var.data_volume_size > 0
  data_volume_name   = var.image_scsi_bus ? "/dev/sdb" : "/dev/vdb"
}

data "openstack_compute_flavor_v2" "k3s" {
  count = var.flavor_id == null ? 1 : 0

  name = var.flavor_name
}

data "openstack_images_image_v2" "k3s" {
  count = var.image_id == null ? 1 : 0

  name        = var.image_name
  most_recent = true
}

resource "openstack_blockstorage_volume_v3" "data" {
  count = local.create_data_volume && !var.ephemeral_data_volume ? 1 : 0

  name                 = "${var.name}-data"
  availability_zone    = var.availability_zone
  volume_type          = var.data_volume_type
  size                 = var.data_volume_size
  enable_online_resize = var.data_volume_enable_online_resize
}

module "k3s" {
  source = "../k3s"

  name                            = var.name
  k3s_join_existing               = var.k3s_join_existing
  cluster_token                   = var.cluster_token
  k3s_version                     = var.k3s_version
  k3s_channel                     = var.k3s_channel
  k3s_ip                          = openstack_networking_port_v2.mgmt.all_fixed_ips[0]
  k3s_url                         = var.k3s_url
  k3s_external_ip                 = var.k3s_external_ip != null ? var.k3s_external_ip : local.node_external_ip
  k3s_args                        = var.k3s_args
  custom_cloud_config_write_files = var.custom_cloud_config_write_files
  custom_cloud_config_runcmd      = var.custom_cloud_config_runcmd
  bootstrap_token_id              = var.bootstrap_token_id
  bootstrap_token_secret          = var.bootstrap_token_secret
  persistent_volume_dev           = local.create_data_volume ? local.data_volume_name : ""
}

resource "openstack_compute_instance_v2" "node" {
  name                = var.name
  image_id            = var.image_id == null ? data.openstack_images_image_v2.k3s.0.id : var.image_id
  flavor_id           = var.flavor_id == null ? data.openstack_compute_flavor_v2.k3s.0.id : var.flavor_id
  key_pair            = var.keypair_name
  metadata            = var.server_properties
  config_drive        = var.config_drive
  availability_zone   = var.availability_zone
  user_data           = module.k3s.user_data
  stop_before_destroy = var.server_stop_before_destroy

  scheduler_hints {
    group = var.server_group_id
  }

  network {
    port           = openstack_networking_port_v2.mgmt.id
    access_network = true
  }

  dynamic "network" {
    for_each = var.additional_port_ids
    content {
      port = network["value"]
    }
  }

  block_device {
    boot_index            = 0
    uuid                  = var.image_id == null ? data.openstack_images_image_v2.k3s.0.id : var.image_id
    delete_on_termination = true
    destination_type      = "local"
    source_type           = "image"
  }

  dynamic "block_device" {
    for_each = local.create_data_volume && var.ephemeral_data_volume ? { "data" = { "size" = var.data_volume_size } } : {}
    content {
      boot_index            = -1
      source_type           = "blank"
      destination_type      = "local"
      delete_on_termination = true
      volume_size           = block_device.value["size"]
    }
  }

  dynamic "block_device" {
    for_each = openstack_blockstorage_volume_v3.data
    content {
      boot_index            = -1
      uuid                  = block_device.value["id"]
      source_type           = "volume"
      destination_type      = "volume"
      delete_on_termination = false
    }
  }

  lifecycle {
    ignore_changes = [
      block_device.0.uuid
    ]
  }
}

resource "openstack_networking_port_v2" "mgmt" {
  name                  = var.name
  network_id            = var.network_id
  admin_state_up        = true
  security_group_ids    = var.security_group_ids
  port_security_enabled = true

  fixed_ip {
    subnet_id  = var.subnet_id
    ip_address = var.k3s_ip
  }
}

resource "openstack_networking_floatingip_v2" "node" {
  count = var.floating_ip_pool == null ? 0 : 1
  pool  = var.floating_ip_pool
}

resource "openstack_compute_floatingip_associate_v2" "node" {
  count       = length(openstack_networking_floatingip_v2.node) > 0 ? 1 : 0
  floating_ip = openstack_networking_floatingip_v2.node[0].address
  instance_id = openstack_compute_instance_v2.node.id
}

resource "openstack_networking_floatingip_v2" "k8s_api" {
  count = var.floating_ip_pool == null ? 0 : 1
  pool  = var.floating_ip_pool
}

resource "openstack_lb_loadbalancer_v2" "k8s_api" {
  count       = length(openstack_networking_floatingip_v2.k8s_api) > 0 ? 1 : 0
  vip_subnet_id = var.subnet_id
}

// resource "openstack_compute_floatingip_associate_v2" "k8s_api" {
//   count       = length(openstack_networking_floatingip_v2.k8s_api) > 0 ? 1 : 0
//   floating_ip = openstack_networking_floatingip_v2.k8s_api[0].address
//   instance_id = openstack_lb_loadbalancer_v2.lb_k8s_api.id
// }

resource "openstack_lb_pool_v2" "k8s_api" {
  name = "K8s Master Pool"
  protocol    = "HTTPS"
  lb_method   = "ROUND_ROBIN"
  loadbalancer_id = openstack_lb_loadbalancer_v2.k8s_api.id
  admin_state_up = true

  // listener_id = "d9415786-5f1a-428b-b35f-2f1523e146d2"
}

resource "openstack_lb_listener_v2" "k8s_api" {
  name            = "K8s Master Listener"
  protocol        = "HTTPS"
  protocol_port   = 6443
  loadbalancer_id = openstack_lb_loadbalancer_v2.k8s_api.id
  default_pool_id = openstack_lb_pool_v2.k8s_api.id
  admin_state_up = true
}

resource "openstack_lb_member_v2" "k8s_api" {
  pool_id       = openstack_lb_pool_v2.k8s_api.id
  address       = var.k3s_ip
  protocol_port = 6443
  admin_state_up = true
}

resource "openstack_lb_monitor_v2" "k8s_api" {
  name        = "K8s Master Health Monitor"
  pool_id     = openstack_lb_pool_v2.k8s_api.id
  type        = "TLS-HELLO"
  delay       = 5
  timeout     = 5
  max_retries = 3
  admin_state_up = true
}

// resource "openstack_networking_port_v2" "k8s_api" {
//   name                  = var.name
//   network_id            = var.network_id
//   admin_state_up        = true
//   security_group_ids    = var.security_group_ids
//   port_security_enabled = true
//
//   fixed_ip {
//     subnet_id  = var.subnet_id
//     ip_address = openstack_lb_loadbalancer_v2.lb_k8s_api.vip_address
//   }
// }

locals {
  node_ip          = openstack_compute_instance_v2.node.network.0.fixed_ip_v4
  node_ipv6        = openstack_compute_instance_v2.node.network.0.fixed_ip_v6
  node_external_ip = length(openstack_networking_floatingip_v2.node) > 0 ? openstack_networking_floatingip_v2.node[0].address : null
  k3s_url          = var.k3s_join_existing ? var.k3s_url : "https://${local.node_ip}:6443"
  k3s_external_url = (var.k3s_join_existing || local.node_external_ip == null) ? "" : "https://${local.node_external_ip}:6443"
}
