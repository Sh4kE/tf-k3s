resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
    name      = "argocd"
    chart     = "./k8s-projects/argocd"
    namespace = "argocd"
    values    = [
        "${file("./k8s-projects/argocd/values.yaml")}",
        "${file("./k8s-projects/argocd/values.${terraform.workspace}.yaml")}",
    ]
    atomic           = true
    cleanup_on_fail  = true
    create_namespace = true
    lint             = true
    max_history      = 5
    timeout          = 300
    wait             = true
    dependency_update = true
    depends_on = [kubernetes_namespace.argocd]
}

data "tls_certificate" "argocd" {
    url = "https://argocd.${var.sub_domain}.${var.root_domain}"
    verify_chain = false
}

resource "null_resource" "wait_for_argocd_api" {
    triggers = {
        wait_for_argocd_api = jsonencode(data.tls_certificate.argocd)
    }
    provisioner "local-exec" {
        command = <<EOT
        for ((i = 0; i < 60; i++)); do
            echo | openssl s_client -connect argocd.${var.sub_domain}.${var.root_domain}:443 -quiet -verify_return_error && exit 0 || sleep 5
        done
        exit 1
        EOT
    }
    depends_on = [
        helm_release.argocd,
    ]
}

data "kubernetes_secret" "argocd-initial-admin-secret" {
  metadata {
    name = "argocd-initial-admin-secret"
    namespace = "argocd"
  }
  depends_on = [ null_resource.wait_for_argocd_api ]
}

output "argocd-initial-admin-secret" {
  value = data.kubernetes_secret.argocd-initial-admin-secret
  sensitive = true
}

module "argocd-apps" {
  source = "./argocd-apps"

  sub_domain = var.sub_domain
  root_domain = var.root_domain

  depends_on = [
    null_resource.wait_for_argocd_api,
  ]
}

