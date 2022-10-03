resource "kubernetes_manifest" "openstack-cinder-csi-argocd-application" {
  manifest = yamldecode(file("./k8s-projects/openstack-cinder-csi/application.${terraform.workspace}.yaml"))

  depends_on = [null_resource.wait_for_argocd_api, module.argocd-apps]
}
