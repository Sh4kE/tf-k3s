/*data "http" "volumesnapshotclasses" {
  url = "https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/${var.volume-snapshot-crd-version}/client/config/crd/snapshot.storage.k8s.io_volumesnapshotclasses.yaml"
}

data "http" "volumesnapshotcontents" {
  url = "https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/${var.volume-snapshot-crd-version}/client/config/crd/snapshot.storage.k8s.io_volumesnapshotcontents.yaml"
}

data "http" "volumesnapshots" {
  url = "https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/${var.volume-snapshot-crd-version}/client/config/crd/snapshot.storage.k8s.io_volumesnapshots.yaml"
}

resource "kubernetes_manifest" "crd-volumesnapshotclasses" {
  manifest = yamldecode(file("./k8s-projects/argocd/manifests/argocd-vault-plugin-credentials.yaml"))

  depends_on = [kubernetes_namespace.argocd]
}

resource "kubernetes_manifest" "crd-volumesnapshotcontents" {
  manifest = yamldecode(file("./k8s-projects/argocd/manifests/argocd-vault-plugin-credentials.yaml"))

  depends_on = [kubernetes_namespace.argocd]
}

resource "kubernetes_manifest" "crd-volumesnapshots" {
  manifest = yamldecode(file("./k8s-projects/argocd/manifests/argocd-vault-plugin-credentials.yaml"))

  depends_on = [kubernetes_namespace.argocd]
}*/

resource "kubernetes_manifest" "csi-driver-nfs-argocd-application" {
  manifest = yamldecode(file("./k8s-projects/csi-driver-nfs/application.yaml"))

  # depends_on = [kubernetes_manifest.argocd-install, kubernetes_manifest.crd-volumesnapshotclasses, kubernetes_manifest.crd-volumesnapshotcontents, kubernetes_manifest.crd-volumesnapshots]
  depends_on = [kubernetes_manifest.argocd-install]
}
