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

data "cloudflare_zone" "sh4ke-rocks" {
  name = "sh4ke.rocks"
}

resource "cloudflare_record" "sh4ke-rocks" {
  zone_id = data.cloudflare_zone.sh4ke-rocks.id
  name    = "sh4ke.rocks"
  value   = var.lb_external_ip
  type    = "A"
  ttl     = 300
}

resource "kubernetes_manifest" "mailu-argocd-application" {
  manifest = yamldecode(file("./k8s-projects/mailu/application.yaml"))

  depends_on = [kubernetes_manifest.argocd-install, vault_kv_secret_v2.mailu-secrets, cloudflare_record.sh4ke-rocks]
}

resource "cloudflare_record" "sh4ke-rocks-mx" {
  zone_id  = data.cloudflare_zone.sh4ke-rocks.id
  name     = "@"
  value    = "mail.sh4ke.rocks"
  type     = "MX"
  ttl      = 600
  priority = 10

  depends_on = [kubernetes_manifest.mailu-argocd-application]
}

resource "cloudflare_record" "sh4ke-rocks-spf" {
  zone_id  = data.cloudflare_zone.sh4ke-rocks.id
  name     = "sh4ke.rocks"
  value    = "v=spf1 mx a:mail.sh4ke.rocks ~all"
  type     = "TXT"
  ttl      = 600

  depends_on = [kubernetes_manifest.mailu-argocd-application]
}

resource "cloudflare_record" "sh4ke-rocks-dkim" {
  zone_id  = data.cloudflare_zone.sh4ke-rocks.id
  name     = "dkim._domainkey.sh4ke.rocks"
  value    = "=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtN5rYIUnoxQjDUBUw3W8AC78OaL38Cczhf7ZgI5c10UMN0QLKVNBlaJdvLrErwZPAy8GF38XZrsL9xI3izZ/IIfn6I3BuVI69gPKCLsE4Q3Fvch7xZt6PLNhtqQT1UVA6+/I2J1Ne+O6aK7+DzZdIYPOsYsavmwjztsPNRuRr2iN60K4TNyGohXplRiaqCAeXvnLhkpDIPBAPvNmfewf0CebQ1v0Yq3K+OLIZxljRxxOD8uE8LqFR9AgG/cGerDIHZ3os0TZ7UJuDAQ/gtU4TkPbKCrReZqFfmWQDfDKjrLxsmNn5amhbKZPZJxwd0WxltLyOYqbqiCc1+NahO2fNQIDAQAB"
  type     = "TXT"
  ttl      = 600

  depends_on = [kubernetes_manifest.mailu-argocd-application]
}


resource "cloudflare_record" "sh4ke-rocks-dmarc" {
  zone_id  = data.cloudflare_zone.sh4ke-rocks.id
  name     = "_dmarc.sh4ke.rocks"
  value    = "v=DMARC1; p=reject; adkim=s; aspf=s"
  type     = "TXT"
  ttl      = 600

  depends_on = [kubernetes_manifest.mailu-argocd-application]
}

resource "cloudflare_record" "sh4ke-rocks-dmarc-report" {
  zone_id  = data.cloudflare_zone.sh4ke-rocks.id
  name     = "sh4ke.rocks._report._dmarc.sh4ke.rocks"
  value    = "v=DMARC1"
  type     = "TXT"
  ttl      = 600

  depends_on = [kubernetes_manifest.mailu-argocd-application]
}

resource "cloudflare_record" "sh4ke-rocks-dns-auto-config-submission" {
  zone_id  = data.cloudflare_zone.sh4ke-rocks.id
  name     = "_submission._tcp.sh4ke.rocks"
  type     = "SRV"
  ttl      = 600

  depends_on = [kubernetes_manifest.mailu-argocd-application]

  data {
    service  = "_submission"
    proto    = "_tcp"
    name     = "sh4ke.rocks"
    priority = 1
    weight   = 1
    port     = 587
    target   = "mail.sh4ke.rocks"
  }
}

resource "cloudflare_record" "sh4ke-rocks-dns-auto-config-imap" {
  zone_id  = data.cloudflare_zone.sh4ke-rocks.id
  name     = "_imap._tcp.sh4ke.rocks"
  type     = "SRV"
  ttl      = 600

  depends_on = [kubernetes_manifest.mailu-argocd-application]

  data {
    service  = "_imap"
    proto    = "_tcp"
    name     = "sh4ke.rocks"
    priority = 1
    weight   = 1
    port     = 143
    target   = "mail.sh4ke.rocks"
  }
}

resource "cloudflare_record" "sh4ke-rocks-dns-auto-config-pop3" {
  zone_id  = data.cloudflare_zone.sh4ke-rocks.id
  name     = "_pop3._tcp.sh4ke.rocks"
  type     = "SRV"
  ttl      = 600

  depends_on = [kubernetes_manifest.mailu-argocd-application]

  data {
    service  = "_pop3"
    proto    = "_tcp"
    name     = "sh4ke.rocks"
    priority = 1
    weight   = 1
    port     = 110
    target   = "mail.sh4ke.rocks"
  }
}

resource "cloudflare_record" "sh4ke-rocks-dns-auto-config-imaps" {
  zone_id  = data.cloudflare_zone.sh4ke-rocks.id
  name     = "_imaps._tcp.sh4ke.rocks"
  type     = "SRV"
  ttl      = 600

  depends_on = [kubernetes_manifest.mailu-argocd-application]

  data {
    service  = "_imaps"
    proto    = "_tcp"
    name     = "sh4ke.rocks"
    priority = 1
    weight   = 1
    port     = 993
    target   = "mail.sh4ke.rocks"
  }
}

resource "cloudflare_record" "sh4ke-rocks-dns-auto-config-pop3s" {
  zone_id  = data.cloudflare_zone.sh4ke-rocks.id
  name     = "_pop3s._tcp.sh4ke.rocks"
  type     = "SRV"
  ttl      = 600

  depends_on = [kubernetes_manifest.mailu-argocd-application]

  data {
    service  = "_pop3s"
    proto    = "_tcp"
    name     = "sh4ke.rocks"
    priority = 1
    weight   = 1
    port     = 995
    target   = "mail.sh4ke.rocks"
  }
}
