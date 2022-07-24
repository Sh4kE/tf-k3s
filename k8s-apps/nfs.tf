resource "kubernetes_labels" "nfs-node-label" {
  api_version = "v1"
  kind        = "Node"

  metadata {
    name = "k3s-server-1"
  }

  labels = {
    "nfs-backup-enabled" = "true"
  }
}

