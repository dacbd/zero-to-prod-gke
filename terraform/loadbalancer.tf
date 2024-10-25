# an SSL policy our GCE load balancer will reference
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_ssl_policy
resource "google_compute_ssl_policy" "prod-ssl-policy" {
  name       = "production-ssl-policy"
  profile    = "MODERN"
  depends_on = [module.project-services]
}

# Create a DNS authorization to use a GCP managed ssl cert
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/certificate_manager_dns_authorization
resource "google_certificate_manager_dns_authorization" "default" {
  name        = "whoami-dacbd-dev-dns-auth"
  location    = "global"
  description = "The default dns"
  domain      = "whoami.dacbd.dev"
  depends_on  = [module.project-services]
}


# Reserve a Static IP address for the load balancer
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address
resource "google_compute_global_address" "static" {
  name         = "prod-lb-address"
  description  = "static IP address for whoami.dacbd.dev"
  address_type = "EXTERNAL"
  depends_on   = [module.project-services]
}



# Add DNS records for DNS authroization and Loadbalancer
# https://registry.terraform.io/providers/cloudflare/cloudflare/4.43.0/docs/resources/record
resource "cloudflare_record" "load-balancer-entry" {
  zone_id = var.cloudflare_zone_id
  name    = "whoami.dacbd.dev"
  content = google_compute_global_address.static.address
  type    = "A"
  ttl     = 1 # automatic
}
resource "cloudflare_record" "gcp-dns-authorization-entry" {
  zone_id = var.cloudflare_zone_id
  name    = google_certificate_manager_dns_authorization.default.dns_resource_record.0.name
  content = google_certificate_manager_dns_authorization.default.dns_resource_record.0.data
  type    = google_certificate_manager_dns_authorization.default.dns_resource_record.0.type
  ttl     = 1 # automatic
}

# Basic Security
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_security_policy
resource "google_compute_security_policy" "default" {
  depends_on  = [module.project-services]
  name        = "basic-policy"
  description = "basic global security policy"
  type        = "CLOUD_ARMOR"
}
# Country blocking example
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_security_policy_rule
resource "google_compute_security_policy_rule" "block_country" {
  security_policy = google_compute_security_policy.default.name
  priority        = "1000"
  action          = "deny(403)"
  match {
    expr {
      expression = "origin.region_code == \"IR\" || origin.region_code == \"KP\""
    }
  }
}
# Ratelimiting Example
resource "google_compute_security_policy_rule" "rate_limit" {
  security_policy = google_compute_security_policy.default.name
  priority        = "2000"
  action          = "rate_based_ban"
  match {
    versioned_expr = "SRC_IPS_V1"
    config {
      src_ip_ranges = ["*"]
    }
  }
  rate_limit_options {
    conform_action = "allow"
    exceed_action  = "deny(429)"
    rate_limit_threshold {
      count        = 120
      interval_sec = 60
    }
    ban_duration_sec = 3600 # ban for an hour
  }
}
