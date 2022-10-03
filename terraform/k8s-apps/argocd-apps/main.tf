
resource "argocd_repository" "k8s-projects" {
  repo = "shake@git.sh4ke.rocks:sh4ke/k8s-projects.git"
  name = "k8s-projects"
  ssh_private_key = file("~/.ssh/gitea")
  # ToDo: add the private key as a secret
}

/*
resource "argocd_repository" "k8s-projects-openstack" {
  repo = "shake@gitea.k3s.sh4ke.rocks:sh4ke/k8s-projects.git"
  name = "k8s-projects"
  ssh_private_key = file("~/.ssh/gitea")
  # ToDo: add the private key as a secret

  depends_on = [null_resource.wait_for_argocd_api]
}

resource "argocd_repository" "k8s-projects-wavestack" {
  repo = "shake@gitea.k3s.sh4ke.rocks:sh4ke/k8s-projects.git"
  name = "k8s-projects"
  ssh_private_key = file("~/.ssh/gitea")
  # ToDo: add the private key as a secret

  depends_on = [null_resource.wait_for_argocd_api]
}
*/
