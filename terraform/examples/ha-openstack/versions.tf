terraform {
  backend "s3" {
    endpoint = "http://ganymed:9000"

    bucket = "terraform-state"
    key    = "terraform.tfstate"
    region = "eu-central-1"

    skip_credentials_validation = true
    skip_metadata_api_check = true
    skip_region_validation = true
    force_path_style = true
  }

  required_providers {
    k8sbootstrap = {
      source  = "nimbolus/k8sbootstrap"
      version = "~> 0.1"
    }
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.37"
    }
    argocd = {
      source = "oboukili/argocd"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
    }
  }
  required_version = ">= 0.13"
}
