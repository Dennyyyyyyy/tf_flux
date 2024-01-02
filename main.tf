module "gke_cluster" {
  source         = "github.com/Dennyyyyyyy/tf-google-gke-cluster"
  GOOGLE_REGION  = var.GOOGLE_REGION
  GOOGLE_PROJECT = var.GOOGLE_PROJECT
  GKE_NUM_NODES  = 2
}

terraform {
  backend "gcs" {
    bucket = "Dennyyyyyyy-secret"
    prefix = "terraform/state"
  }
}