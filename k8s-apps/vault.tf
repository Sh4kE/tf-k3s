resource "kubernetes_manifest" "vault-argocd-application" {
  manifest = yamldecode(file("./k8s-projects/vault/application.yaml"))

  depends_on = [kubernetes_manifest.argocd-install]
}

resource "null_resource" "wait-for-vault" {
  triggers = {
    wait_for_vault = jsonencode(kubernetes_manifest.vault-argocd-application)
  }

  provisioner "local-exec" {
    command = "curl -ks --retry-all-errors --retry 20 ${var.vault_address}"
  }

  depends_on = [kubernetes_manifest.vault-argocd-application]
}

module "vault" {
  source = "./vault"

  depends_on = [null_resource.wait-for-vault]
}
