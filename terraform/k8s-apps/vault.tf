resource "kubernetes_manifest" "vault-argocd-application" {
  manifest = yamldecode(file("./k8s-projects/vault/application.${terraform.workspace}.yaml"))

  depends_on = [
    null_resource.wait_for_argocd_api,
    module.argocd-apps,
    kubernetes_manifest.openstack-cinder-csi-argocd-application
  ]
}

resource "null_resource" "wait-for-vault" {
  triggers = {
    wait_for_vault = jsonencode(kubernetes_manifest.vault-argocd-application)
  }

  provisioner "local-exec" {
    command = "curl -ks --retry-all-errors --retry 20 vault.${var.sub_domain}.${var.root_domain}"
  }

  depends_on = [kubernetes_manifest.vault-argocd-application]
}

module "vault" {
  source = "./vault"

  depends_on = [null_resource.wait-for-vault]
}

