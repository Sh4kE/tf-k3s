resource "kubernetes_manifest" "openstack-cinder-csi-argocd-application" {
  manifest = yamldecode(file("./k8s-projects/openstack-cinder-csi/application.${terraform.workspace}.yaml"))

  depends_on = [kubernetes_manifest.argocd-install, module.argocd-apps]
}
