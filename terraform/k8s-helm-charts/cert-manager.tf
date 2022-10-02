# TODO: Ensure CRDs are installed first
resource "kubernetes_manifest" "cert-manager-crds" {
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
        "\n${file("./k8s-projects/cert-manager/manifests/crd.yaml")}\n"
      ) :
      yamldecode(yaml)
      if trimspace(replace(yaml, "/(?m)(^[[:blank:]]*(#.*)?$)+/", "")) != ""
    ] : "${value["kind"]}--${value["metadata"]["name"]}" => value
  }
  manifest = each.value

  # provider = kubernetes.kubeconfig
}

resource "helm_release" "cert-manager" {
  name      = "cert-manager"
  chart     = "./k8s-projects/cert-manager"
  namespace = "cert-manager"
  values    = [
    file("./k8s-projects/cert-manager/values.yaml")
  ]
  dependency_update = true
  atomic            = true
  cleanup_on_fail   = true
  create_namespace  = true
  lint              = true
  force_update      = true
  max_history       = 5
  timeout           = 300
  wait              = true

  depends_on = [kubernetes_manifest.cert-manager-crds]
}
