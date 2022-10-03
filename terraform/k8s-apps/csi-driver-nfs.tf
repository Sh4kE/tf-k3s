resource "kubernetes_manifest" "csi-driver-nfs-argocd-application" {
  manifest = yamldecode(file("./k8s-projects/csi-driver-nfs/application.yaml"))

  depends_on = [
    null_resource.wait_for_argocd_api,
  ]
}
