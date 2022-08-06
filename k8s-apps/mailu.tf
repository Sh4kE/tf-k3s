resource "random_password" "mailu-secret-key" {
  length  = 64
  upper   = true
  special = true
  numeric = true
}

resource "random_password" "mailu-initial-admin-password" {
  length  = 32
  upper   = true
  special = true
  numeric = true
}

resource "random_password" "mailu-mysql-root-password" {
  length  = 32
  upper   = true
  special = true
  numeric = true
}

resource "random_password" "mailu-mysql-password" {
  length  = 32
  upper   = true
  special = true
  numeric = true
}

resource "random_password" "mailu-roundcube-password" {
  length  = 32
  upper   = true
  special = true
  numeric = true
}

resource "vault_kv_secret_v2" "mailu-secrets" {
  mount     = module.vault.kv_mount.path
  name      = "k3s/argocd/mailu"
  data_json = jsonencode(
    {
      secret_key = random_password.mailu-secret-key.result
      initial_admin_password = random_password.mailu-initial-admin-password.result
      mysql_root_password = random_password.mailu-mysql-root-password.result
      mysql_password = random_password.mailu-mysql-password.result
      roundcube_password = random_password.mailu-roundcube-password.result
    }
  )
}

#data "cloudflare_zone" "sh4ke-rocks" {
#  name = "sh4ke.rocks"
#}
#
#resource "cloudflare_record" "sh4ke-rocks" {
#  zone_id = data.cloudflare_zone.sh4ke-rocks.id
#  name    = "@"
#  value   = var.lb_external_ip
#  type    = "A"
#  ttl     = 300
#}

resource "kubernetes_manifest" "mailu-argocd-application" {
  manifest = yamldecode(file("./k8s-projects/mailu/application.yaml"))

  # depends_on = [kubernetes_manifest.argocd-install, vault_kv_secret_v2.mailu-secrets, cloudflare_record.sh4ke-rocks]
  depends_on = [kubernetes_manifest.argocd-install, vault_kv_secret_v2.mailu-secrets]
}
