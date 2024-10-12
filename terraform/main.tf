
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.6.0"
    }
  }
}

provider "google" {
  # Configuration options
  project = "zero-to-prod-gke"
  region  = "us-west1"
}

locals {
  cluster_type           = "production-gke-autopilot"
  network_name           = "production"
  subnet_name            = "k8s-private-subnet"
  master_auth_subnetwork = "k8s-private-master-subnet"
  pods_range_name        = "ip-range-pods-private"
  svc_range_name         = "ip-range-svc-private"
  subnet_names           = [for subnet_self_link in module.prod-vpc.subnets_self_links : split("/", subnet_self_link)[length(split("/", subnet_self_link)) - 1]]
}

