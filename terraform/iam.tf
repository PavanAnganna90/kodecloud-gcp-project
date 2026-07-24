data "google_project" "service" {
  project_id = var.project_id
}

resource "google_service_account" "gke_nodes" {
  account_id   = "sa-gke-nodes"
  display_name = "GKE node pool service account"
  project      = var.project_id

  depends_on = [google_project_service.required]
}

resource "google_project_iam_member" "nodes_artifact_registry" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_project_iam_member" "nodes_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_project_iam_member" "nodes_metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

# Shared VPC: node SA must use the host subnet.
resource "google_project_iam_member" "nodes_network_user" {
  project = var.network_host_project_id
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

# Shared VPC: Google APIs service agent in the service project.
resource "google_project_iam_member" "cloudservices_network_user" {
  project = var.network_host_project_id
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:${data.google_project.service.number}@cloudservices.gserviceaccount.com"
}

# Shared VPC: GKE service agent needs hostServiceAgentUser + networkUser on host.
resource "google_project_iam_member" "gke_host_service_agent" {
  project = var.network_host_project_id
  role    = "roles/container.hostServiceAgentUser"
  member  = "serviceAccount:service-${data.google_project.service.number}@container-engine-robot.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "gke_network_user" {
  project = var.network_host_project_id
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:service-${data.google_project.service.number}@container-engine-robot.iam.gserviceaccount.com"
}
