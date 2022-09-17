resource "random_password" "paperless-dbname" {
  length  = 16
  upper   = false
  special = false
  numeric = false
}

resource "random_password" "paperless-postgress-username" {
  length  = 10
  upper   = false
  special = false
  numeric = false
}

resource "random_password" "paperless-postgres-root-password" {
  length  = 64
  upper   = true
  special = true
}

resource "random_password" "paperless-postgres-password" {
  length  = 64
  upper   = true
  special = true
}

resource "random_password" "paperless-postgres-replication-password" {
  length  = 64
  upper   = true
  special = true
}

resource "random_password" "paperless-admin-username" {
  length  = 10
  upper   = false
  special = false
  numeric = false
}

resource "random_password" "paperless-admin-password" {
  length  = 32
  upper   = true
  special = true
}

resource "random_password" "paperless-secret-key" {
  length  = 64
  upper   = true
  special = true
}

resource "vault_kv_secret_v2" "paperless-secrets" {
  mount     = module.vault.kv_mount.path
  name      = "k3s/argocd/paperless"
  data_json = jsonencode(
    {
      dbname = random_password.paperless-dbname.result
      dbusername = random_password.paperless-postgress-username.result
      dbpassword = random_password.paperless-postgres-password.result
      postgresPassword = random_password.paperless-postgres-root-password.result
      replicationPassword = random_password.paperless-postgres-replication-password.result
      paperlessAdminUser = random_password.paperless-admin-username.result
      paperlessAdminPassword = random_password.paperless-admin-password.result
      secretKey = random_password.paperless-secret-key.result
    }
  )
}

resource "kubernetes_manifest" "paperless-argocd-application" {
  manifest = yamldecode(file("./k8s-projects/paperless/application.${terraform.workspace}.yaml"))

  depends_on = [kubernetes_manifest.argocd-install, vault_kv_secret_v2.paperless-secrets]
}
