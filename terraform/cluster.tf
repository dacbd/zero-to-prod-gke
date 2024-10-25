resource "google_container_cluster" "primary" {
  depends_on        = [module.project-services]
  name              = "${local.cluster_type}-cluster"
  project           = var.project_id
  location          = var.region
  datapath_provider = "ADVANCED_DATAPATH"

  network         = "projects/${var.project_id}/global/networks/${module.prod-vpc.network_name}"
  networking_mode = "VPC_NATIVE"
  subnetwork      = "projects/${var.project_id}/regions/${var.region}/subnetworks/${local.subnet_names[index(module.prod-vpc.subnets_names, local.subnet_name)]}"
  ip_allocation_policy {
    cluster_secondary_range_name  = local.pods_range_name
    services_secondary_range_name = local.svc_range_name
    stack_type                    = "IPV4"
    pod_cidr_overprovision_config {
      disabled = false
    }
  }

  deletion_protection = false
  enable_autopilot    = true

  enable_cilium_clusterwide_network_policy = false
  enable_kubernetes_alpha                  = false
  enable_l4_ilb_subsetting                 = false
  enable_legacy_abac                       = false
  enable_multi_networking                  = false
  enable_tpu                               = false


  addons_config {
    gce_persistent_disk_csi_driver_config {
      enabled = true
    }
    gcp_filestore_csi_driver_config {
      enabled = true
    }
    gcs_fuse_csi_driver_config {
      enabled = true
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
    http_load_balancing {
      disabled = false
    }
    ray_operator_config {
      enabled = false
    }
  }
  binary_authorization {
    evaluation_mode = "DISABLED"
  }

  cluster_autoscaling {
    auto_provisioning_locations = []
    autoscaling_profile         = "OPTIMIZE_UTILIZATION"

    auto_provisioning_defaults {
      image_type = "COS_CONTAINERD"
      oauth_scopes = [
        "https://www.googleapis.com/auth/devstorage.read_only",
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/monitoring",
        "https://www.googleapis.com/auth/service.management.readonly",
        "https://www.googleapis.com/auth/servicecontrol",
        "https://www.googleapis.com/auth/trace.append",
      ]
      service_account = "default"

      management {
        auto_repair  = true
        auto_upgrade = true
      }
    }
  }

  default_snat_status {
    disabled = false
  }
  dns_config {
    cluster_dns        = "CLOUD_DNS"
    cluster_dns_domain = "cluster.local"
    cluster_dns_scope  = "CLUSTER_SCOPE"
  }
  gateway_api_config {
    channel = "CHANNEL_STANDARD"
  }
  logging_config {
    enable_components = [
      "SYSTEM_COMPONENTS",
      "WORKLOADS",
    ]
  }

  monitoring_config {
    enable_components = [
      "SYSTEM_COMPONENTS",
      "STORAGE",
      "POD",
      "DEPLOYMENT",
      "STATEFULSET",
      "DAEMONSET",
      "HPA",
      "CADVISOR",
      "KUBELET",
    ]
    advanced_datapath_observability_config {
      enable_metrics = true
      enable_relay   = false
    }
    managed_prometheus {
      enabled = true
    }
  }

  node_pool_defaults {
    node_config_defaults {
      insecure_kubelet_readonly_port_enabled = "FALSE"
      logging_variant                        = "DEFAULT"
      gcfs_config {
        enabled = true
      }
    }
  }
  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true
    master_global_access_config {
      enabled = false
    }
  }
  release_channel {
    channel = "REGULAR"
  }
  secret_manager_config {
    enabled = false
  }
  security_posture_config {
    mode               = "BASIC"
    vulnerability_mode = "VULNERABILITY_DISABLED"
  }
  vertical_pod_autoscaling {
    enabled = true
  }
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}
