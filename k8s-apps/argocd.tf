resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "kubernetes_manifest" "argocd-vault-plugin-credentials-secret" {
  manifest = yamldecode(file("./k8s-projects/argocd/manifests/argocd-vault-plugin-credentials.yaml"))
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
}
