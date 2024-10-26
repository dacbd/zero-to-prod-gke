# Define our prod network
module "prod-vpc" {
  source     = "terraform-google-modules/network/google"
  version    = ">= 7.5"
  depends_on = [module.project-services]

  project_id   = var.project_id
  network_name = local.network_name

  subnets = [
    {
      subnet_name           = local.subnet_name
      subnet_ip             = "10.1.0.0/16"
      subnet_region         = var.region
      subnet_private_access = true
    },
    {
      subnet_name   = local.master_auth_subnetwork
      subnet_ip     = "10.2.0.0/16"
      subnet_region = var.region
    },
  ]

  secondary_ranges = {
    (local.subnet_name) = [
      {
        range_name    = local.pods_range_name
        ip_cidr_range = "10.3.0.0/18"
      },
      {
        range_name    = local.svc_range_name
        ip_cidr_range = "10.3.64.0/18"
      },
    ]
  }
}

# Define a Cloud NAT router for a our private vpc
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router
resource "google_compute_router" "router" {
  name    = "nat-router"
  network = module.prod-vpc.network_name
  region  = var.region
}

resource "google_compute_router_nat" "nat" {
  name                               = "nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
