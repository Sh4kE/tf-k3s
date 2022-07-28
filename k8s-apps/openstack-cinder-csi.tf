resource "kubernetes_manifest" "openstack-cinder-csi-argocd-application" {
  manifest = yamldecode(file("./k8s-projects/openstack-cinder-csi/application.yaml"))

#  depends_on = [kubernetes_manifest.argocd-install, module.argocd-apps]
  depends_on = [kubernetes_manifest.argocd-install]
}
