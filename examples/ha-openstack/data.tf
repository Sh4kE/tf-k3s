data "k8sbootstrap_auth" "auth" {
  depends_on = [module.secgroup, module.server1, module.load-balancer, module.floating-ip-master-lb]
  server = module.server1.k3s_external_url
  token  = local.token
}
