resource "helm_release" "nginx" {
  name      = "nginx"
  chart     = "./k8s-projects/nginx"
  namespace = "nginx"
  values    = [
    file("./k8s-projects/nginx/values.yaml")
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
