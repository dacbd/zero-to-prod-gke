# GCP variables
variable "project_id" {
  description = "The project ID to host the cluster in"
  default     = "zero-to-prod-gke"
}

variable "region" {
  description = "The region the cluster in"
  default     = "us-west1"
}

# Cloudflare variables
variable "cloudflare_api_token" {
  description = "Cloudflare API token"
}

variable "cloudflare_zone_id" {
  description = "Zone Id found on the right side panel of the cloudflare dashboard in the overview section"
}
