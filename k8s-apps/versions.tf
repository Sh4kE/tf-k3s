terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.12.1"
    }
#    cloudflare = {
##      source  = "cloudflare/cloudflare"
#      source = "registry.terraform.io/cloudflare/cloudflare"
#      version = "~> 3.0"
#    }
  }
}
