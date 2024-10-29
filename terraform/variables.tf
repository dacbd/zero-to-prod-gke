# GCP variables
variable "project_id" {
  description = "The project ID to host the cluster in"
  type        = string
  default     = "zero-to-prod-gke"
}

variable "region" {
  description = "The region the cluster in"
  type        = string
  default     = "us-west1"
}

# Cloudflare variables
variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Zone Id found on the right side panel of the cloudflare dashboard in the overview section"
  type        = string
}
