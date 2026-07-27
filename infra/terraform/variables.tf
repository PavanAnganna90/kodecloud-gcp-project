# Variable contracts for this root module.
# Users normally edit terraform.tfvars (from terraform.tfvars.example), not this file.

# ----- Required (no defaults) -----

variable "project_id" {
  description = "[REQUIRED] Service project ID where GKE runs. Console project picker or: gcloud projects list"
  type        = string
}

variable "terraform_service_account" {
  description = "[REQUIRED] SA email to impersonate for apply. IAM → Service Accounts. User needs Token Creator on it."
  type        = string
}

variable "network_host_project_id" {
  description = "[REQUIRED] Shared VPC host project ID. From: gcloud compute shared-vpc get-host-project PROJECT_ID"
  type        = string
}

variable "network_name" {
  description = "[REQUIRED] Shared VPC network name in the host project. VPC network → VPC networks."
  type        = string
}

variable "subnet_name" {
  description = "[REQUIRED] Subnet name for nodes (same region). Must include GKE secondary ranges."
  type        = string
}

variable "cluster_name" {
  description = "[REQUIRED] GKE cluster name. You choose; unique per project/zone."
  type        = string
}

# ----- Optional (defaults provided) -----

variable "name_prefix" {
  description = "[OPTIONAL] Short prefix used in resource descriptions and labels. You choose."
  type        = string
  default     = "app"
}

variable "region" {
  description = "[OPTIONAL] Region for subnet / regional resources. Must match subnet region."
  type        = string
  default     = "us-central1"
}

variable "artifact_registry_repo" {
  description = "[OPTIONAL] Artifact Registry Docker repo ID for app images. Must match _AR_REPO in ci/cloudbuild.yaml."
  type        = string
  default     = "app-images"
}

variable "artifact_registry_location" {
  description = "[OPTIONAL] Artifact Registry location. Falls back to var.region when null; keep it near the cluster."
  type        = string
  default     = null
}

variable "create_artifact_registry" {
  description = "[OPTIONAL] Create the repo. Set false when it already exists or another team owns it."
  type        = bool
  default     = true
}

variable "artifact_registry_untagged_retention" {
  description = "[OPTIONAL] Age after which untagged images are deleted, as a duration string (e.g. 2592000s = 30d)."
  type        = string
  default     = "2592000s"
}

variable "image_pusher_members" {
  description = "[OPTIONAL] IAM members granted push on the repo, e.g. [\"serviceAccount:sa-cloudbuild@PROJECT.iam.gserviceaccount.com\"]."
  type        = list(string)
  default     = []
}

variable "zone" {
  description = "[OPTIONAL] Zone for zonal Standard GKE. Must be in var.region."
  type        = string
  default     = "us-central1-a"
}

variable "pods_secondary_range_name" {
  description = "[OPTIONAL] Subnet secondary range NAME for Pods. From subnet secondary IP ranges."
  type        = string
  default     = "gke-pods"
}

variable "services_secondary_range_name" {
  description = "[OPTIONAL] Subnet secondary range NAME for Services. From subnet secondary IP ranges."
  type        = string
  default     = "gke-services"
}

variable "node_pool_name" {
  description = "[OPTIONAL] Name of the primary node pool."
  type        = string
  default     = "default-pool"
}

variable "node_network_tags" {
  description = "[OPTIONAL] Extra GCE network tags on nodes, for your own firewall rules. GKE adds its own tag for LoadBalancer rules."
  type        = list(string)
  default     = ["gke-node"]
}

variable "machine_type" {
  description = "[OPTIONAL] Node machine type (e.g. e2-medium)."
  type        = string
  default     = "e2-medium"
}

variable "node_count" {
  description = "[OPTIONAL] Node count when autoscaling is disabled."
  type        = number
  default     = 1
}

variable "min_node_count" {
  description = "[OPTIONAL] Min nodes when autoscaling is enabled."
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "[OPTIONAL] Max nodes when autoscaling is enabled."
  type        = number
  default     = 2
}

variable "enable_autoscaling" {
  description = "[OPTIONAL] Enable node pool autoscaling."
  type        = bool
  default     = true
}

variable "disk_size_gb" {
  description = "[OPTIONAL] Boot disk size per node in GB."
  type        = number
  default     = 50
}

variable "release_channel" {
  description = "[OPTIONAL] GKE release channel: RAPID, REGULAR, or STABLE."
  type        = string
  default     = "REGULAR"
}
