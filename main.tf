terraform {
  backend "gcs" {
    bucket = "dennyyyyyyy-secret"
    prefix = "terraform/state"
  }
}

module "github_repository" {
  source                   = "github.com/Dennyyyyyyy/tf-github-repository"
  github_owner             = var.GITHUB_OWNER
  github_token             = var.GITHUB_TOKEN
  repository_name          = var.FLUX_GITHUB_REPO
  public_key_openssh       = module.tls_private_key.public_key_openssh
  public_key_openssh_title = "flux"
}

module "tls_private_key" {
  source = "github.com/Dennyyyyyyy/tf-hashicorp-tls-keys"
  algorithm   = "RSA"
  }

module "kind_cluster" {
  source = "github.com/den-vasyliev/tf-kind-cluster?ref=cert_auth"
}

module "flux_bootstrap" {
  source            = "github.com/Dennyyyyyyy/tf-fluxcd-flux-bootstrap"
  github_repository = "${var.GITHUB_OWNER}/${var.FLUX_GITHUB_REPO}"
  private_key       = module.tls_private_key.private_key_pem
  config_path       = module.gke_cluster.kubeconfig
}
