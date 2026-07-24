resource "google_container_cluster" "primary" {
  provider = google-beta

  name     = var.cluster_name
  project  = var.project_id
  location = var.zone

  network    = local.network_self_link
  subnetwork = local.subnetwork_self_link

  networking_mode = "VPC_NATIVE"

  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_secondary_range_name
    services_secondary_range_name = var.services_secondary_range_name
  }

  # Private nodes; public control plane for kubectl from a laptop.
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"
      display_name = "open-for-learning"
    }
  }

  release_channel {
    channel = var.release_channel
  }

  # Create an empty cluster; manage nodes via a separate pool.
  remove_default_node_pool = true
  initial_node_count       = 1

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  deletion_protection = false

  depends_on = [
    google_project_service.required,
    google_project_iam_member.nodes_network_user,
    google_project_iam_member.cloudservices_network_user,
    google_project_iam_member.gke_host_service_agent,
    google_project_iam_member.gke_network_user,
  ]
}

resource "google_container_node_pool" "primary" {
  name     = var.node_pool_name
  project  = var.project_id
  location = var.zone
  cluster  = google_container_cluster.primary.name

  node_count = var.enable_autoscaling ? null : var.node_count

  dynamic "autoscaling" {
    for_each = var.enable_autoscaling ? [1] : []
    content {
      min_node_count = var.min_node_count
      max_node_count = var.max_node_count
    }
  }

  node_config {
    machine_type    = var.machine_type
    disk_size_gb    = var.disk_size_gb
    service_account = google_service_account.gke_nodes.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }

    labels = {
      env = "dev"
    }

    tags = ["gke-node", "retail-dev"]
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  depends_on = [
    google_project_iam_member.nodes_artifact_registry,
    google_project_iam_member.nodes_log_writer,
    google_project_iam_member.nodes_metric_writer,
  ]
}
