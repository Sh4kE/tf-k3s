resource "kubernetes_manifest" "nginx-argocd-application" {
  manifest = yamldecode(file("./k8s-projects/nginx/application.yaml"))

  depends_on = [kubernetes_manifest.argocd-install]
}
