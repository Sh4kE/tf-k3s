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
  manifest = yamldecode(data.http.volumesnapshotclasses.body)

  depends_on = [kubernetes_manifest.argocd-install]
}

resource "kubernetes_manifest" "crd-volumesnapshotcontents" {
  manifest = yamldecode(data.http.volumesnapshotcontents.body)

  depends_on = [kubernetes_manifest.argocd-install]
}

resource "kubernetes_manifest" "crd-volumesnapshots" {
  manifest = yamldecode(data.http.volumesnapshots.body)

  depends_on = [kubernetes_manifest.argocd-install]
}

variable "volume-snapshot-crd-version" {
  type = string
  default = "v6.0.1"
}*/

resource "kubernetes_manifest" "csi-driver-nfs-argocd-application" {
  manifest = yamldecode(file("./k8s-projects/csi-driver-nfs/application.yaml"))

  # depends_on = [kubernetes_manifest.argocd-install, kubernetes_manifest.crd-volumesnapshotclasses, kubernetes_manifest.crd-volumesnapshotcontents, kubernetes_manifest.crd-volumesnapshots]
  depends_on = [kubernetes_manifest.argocd-install]
}
