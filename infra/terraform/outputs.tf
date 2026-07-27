output "cluster_name" {
  description = "GKE cluster name."
  value       = google_container_cluster.primary.name
}

output "cluster_location" {
  description = "Cluster zone."
  value       = google_container_cluster.primary.location
}

output "cluster_endpoint" {
  description = "Public control plane endpoint."
  value       = google_container_cluster.primary.endpoint
}

output "node_service_account" {
  description = "Service account used by GKE nodes."
  value       = google_service_account.gke_nodes.email
}

output "network" {
  description = "Shared VPC network self link."
  value       = local.network_self_link
}

output "subnetwork" {
  description = "Shared VPC subnet self link."
  value       = local.subnetwork_self_link
}

output "artifact_registry_repo_url" {
  description = "Docker repo path. Append /<app>:<tag> to get a full image name."
  value       = local.artifact_registry_url
}

output "get_credentials_command" {
  description = "Command to fetch kubeconfig for this cluster."
  value       = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --zone ${google_container_cluster.primary.location} --project ${var.project_id}"
}
