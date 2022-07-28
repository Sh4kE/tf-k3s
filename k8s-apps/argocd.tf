resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "kubernetes_manifest" "argocd-vault-plugin-credentials-secret" {
  manifest = yamldecode(file("./k8s-projects/argocd/manifests/argocd-vault-plugin-credentials.yaml"))

  depends_on = [kubernetes_namespace.argocd]
}

#resource "kubernetes_manifest" "argocd-install" {
#  manifest = yamldecode(file("./k8s-projects/argocd/manifests/install.yaml"))
#}

resource "kubernetes_manifest" "argocd-install" {
  # Create a map { "kind--name" => yaml_doc } from the multi-document yaml text.
  # Each element is a separate kubernetes resource.
  # Must use \n---\n to avoid splitting on strings and comments containing "---".
  # YAML allows "---" to be the first and last line of a file, so make sure
  # raw yaml begins and ends with a newline.
  # The "---" can be followed by spaces, so need to remove those too.
  # Skip blocks that are empty or comments-only in case yaml began with a comment before "---".
  for_each = {
    for value in [
      for yaml in split(
        "\n---\n",
        "\n${file("./k8s-projects/argocd/manifests/install.yaml")}\n"
      ) :
      yamldecode(yaml)
      if trimspace(replace(yaml, "/(?m)(^[[:blank:]]*(#.*)?$)+/", "")) != ""
    ] : "${value["kind"]}--${value["metadata"]["name"]}" => value
  }
  manifest = each.value
  depends_on = [kubernetes_namespace.argocd]
}

resource "time_sleep" "wait_for_argocd_api" {
  create_duration = "90s"
  destroy_duration = "30s"
  depends_on  = [
    kubernetes_manifest.argocd-install
  ]
}

/*data "kubernetes_secret" "argocd-initial-admin-secret" {
  metadata {
    name = "argocd-initial-admin-secret"
    namespace = "argocd"
  }
  depends_on = [
    time_sleep.wait_for_argocd_api,
  ]
}

output "argocd-initial-admin-secret" {
  value = data.kubernetes_secret.argocd-initial-admin-secret
  sensitive = true
}*/

resource "kubernetes_manifest" "argocd-ingress" {
  manifest = yamldecode(file("./k8s-projects/argocd/manifests/ingress.yaml"))

  depends_on = [kubernetes_namespace.argocd, kubernetes_manifest.nginx-argocd-application]
}

/*module "argocd-apps" {
  source = "./argocd-apps"

  depends_on = [kubernetes_manifest.nginx-argocd-application]
}*/

