resource "argocd_repository" "k8s-projects" {
  repo = "shake@git.sh4ke.rocks:sh4ke/k8s-projects.git"
  name = "k8s-projects"
  ssh_private_key = file("~/.ssh/gitea")
  # ToDo: add the private key as a secret
}
