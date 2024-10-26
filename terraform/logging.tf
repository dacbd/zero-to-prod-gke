resource "random_string" "bucket_prefix" {
  length  = 6
  special = false
  upper   = false
}

# Define our logs bucket (different from regular s3 like buckets)
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_project_bucket_config
resource "google_logging_project_bucket_config" "k8s-logs" {
  project          = var.project_id
  location         = var.region
  retention_days   = 21
  enable_analytics = true
  bucket_id        = "${random_string.bucket_prefix.result}-${google_container_cluster.primary.name}-logs"
}

# Define what logs we want to route to our logging bucket
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_project_sink
resource "google_logging_project_sink" "k8s-sink" {
  name        = "${google_container_cluster.primary.name}-logs-sink"
  destination = "logging.googleapis.com/projects/${var.project_id}/locations/${var.region}/buckets/${google_logging_project_bucket_config.k8s-logs.bucket_id}"

  filter = <<-EOF
    resource.type="k8s_container"
    logName=("projects/${var.project_id}/logs/stderr" OR "projects/${var.project_id}/logs/stdout")
  EOF

  exclusions {
    name   = "remove-kube-system"
    filter = "resource.labels.namespace_name=\"kube-system\""
  }
}
