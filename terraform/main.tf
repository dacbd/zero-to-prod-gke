terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.6.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.4"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = "us-west1"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
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

module "project-services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 17.0"

  project_id                  = var.project_id
  disable_services_on_destroy = false

  activate_apis = [
    "compute.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "container.googleapis.com",
    "certificatemanager.googleapis.com",
    "monitoring.googleapis.com",
  ]
}
