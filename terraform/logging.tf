resource "google_storage_bucket" "k8s-logs" {
  name          = "${module.prod-gke.name}-logs"
  location      = var.region
  force_destroy = true

  public_access_prevention = "enforced"
  lifecycle_rule {
    condition {
      age = 21
    }
    action {
      type = "Delete"
    }
  }
}

locals {
  containers = ["backend", "client"]
}

resource "google_logging_project_bucket_config" "k8s-logs" {
  project          = var.project_id
  location         = var.region
  retention_days   = 21
  enable_analytics = true
  bucket_id        = "${module.prod-gke.name}-logs"
}

resource "google_logging_project_sink" "k8s-sink" {
  name = "${module.prod-gke.name}-logs-sink"

  # Can export to pubsub, cloud storage, bigquery, log bucket, or another project
  destination = "logging.googleapis.com/projects/${var.project_id}/locations/${var.region}/buckets/${google_logging_project_bucket_config.k8s-logs.bucket_id}"

  # Log all WARN or higher severity messages relating to instances
  filter = <<-EOF
resource.type="k8s_container"
logName=("projects/${var.project_id}/logs/stderr" OR "projects/${var.project_id}/logs/stdout")
resource.labels.container_name=(${join(" OR ", [for item in local.containers : format("\"%s\"", item)])})
EOF

  # Use a unique writer (creates a unique service account used for writing)
  unique_writer_identity = true
}
