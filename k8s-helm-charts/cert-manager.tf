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
}
