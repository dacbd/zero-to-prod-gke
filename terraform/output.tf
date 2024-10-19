output "k8s_ingress_lb_global_static_ip" {
  value = google_compute_global_address.static.name
}
output "k8s_ingress_security_policy_name" {
  value = google_compute_security_policy.default.name
}
output "k8s_ingress_ssl_policy_name" {
  value = google_compute_ssl_policy.prod-ssl-policy.name
}

# If you decide to not use terraform to define your dns record copy/paste these.
output "dns_record_domain_name" {
  value = google_certificate_manager_dns_authorization.default.dns_resource_record.0.name
}
output "dns_record_type" {
  value = google_certificate_manager_dns_authorization.default.dns_resource_record.0.type
}
output "dns_record_value" {
  value = google_certificate_manager_dns_authorization.default.dns_resource_record.0.data
}

