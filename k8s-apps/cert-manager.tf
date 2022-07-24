resource "kubernetes_manifest" "cert-manager-argocd-application" {
  manifest = yamldecode(file("./k8s-projects/cert-manager/application.yaml"))

  depends_on = [kubernetes_manifest.argocd-install]
}
