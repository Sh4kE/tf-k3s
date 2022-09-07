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
}

resource "argocd_repository" "k8s-projects" {
  repo = "shake@git.sh4ke.rocks:sh4ke/k8s-projects.git"
  name = "k8s-projects"
  ssh_private_key = file("~/.ssh/gitea")
  # ToDo: add the private key as a secret

  depends_on = [null_resource.wait_for_argocd_api]
}
