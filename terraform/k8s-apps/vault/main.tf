
resource "vault_mount" "kv-v2" {
  path    = "kv"
  type    = "kv"
  options = { version = "2" }
}

resource "vault_kv_secret_backend_v2" "config" {
  mount        = vault_mount.kv-v2.path
  max_versions = 10
}

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "openstack" {
  backend                = vault_auth_backend.kubernetes.path
  kubernetes_host        = "https://kubernetes.default.svc:443"
  disable_iss_validation = "true"
}

resource "vault_policy" "read_k3s_secrets" {
  name = "read_k3s_secrets"

  policy = <<EOF
path "kv/data/k3s/argocd/*" {
  capabilities = ["read"]
}
EOF
}

resource "vault_kubernetes_auth_backend_role" "argocd" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "argocd"
  bound_service_account_names      = ["*"]
  bound_service_account_namespaces = ["argocd"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.read_k3s_secrets.name]
}
