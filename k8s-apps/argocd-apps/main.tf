

# TODO: This cannot work right now from scratch because there
# is no initial ingress controller installed before we have this repo
resource "argocd_repository" "k8s-projects" {
  repo = "shake@git.sh4ke.rocks:sh4ke/k8s-projects.git"
  name = "k8s-projects"
  ssh_private_key = file("~/.ssh/gitea")
}
