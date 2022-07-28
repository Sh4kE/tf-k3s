
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

/*
resource "vault_kubernetes_auth_backend_config" "openstack" {
  backend                = vault_auth_backend.kubernetes.path
  kubernetes_host        = "https://kubernetes.default.svc:443"
  disable_iss_validation = "true"
}

token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
*/
