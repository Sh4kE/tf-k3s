resource "random_password" "gitea-admin-password" {
  length  = 32
  upper   = true
  special = true
}

resource "random_password" "gitea-postgres-password" {
  length  = 32
  upper   = true
  special = true
}

resource "vault_kv_secret_v2" "gitea-secrets" {
  mount     = module.vault.kv_mount.path
  name      = "k3s/argocd/gitea"
  data_json = jsonencode(
    {
      giteaAdminPassword = random_password.gitea-admin-password.result
      giteaPostgresPassword = random_password.gitea-postgres-password.result
    }
  )
}

resource "kubernetes_manifest" "gitea-argocd-application" {
  manifest = yamldecode(file("./k8s-projects/gitea/application.${terraform.workspace}.yaml"))

  depends_on = [ null_resource.wait_for_argocd_api, vault_kv_secret_v2.gitea-secrets ]
}
