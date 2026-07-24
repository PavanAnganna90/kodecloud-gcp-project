variable "project_id" {
  description = "Service project where the GKE cluster runs."
  type        = string
}

variable "region" {
  description = "Primary region for regional resources."
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Zone for the zonal Standard GKE cluster."
  type        = string
  default     = "us-central1-a"
}

variable "terraform_service_account" {
  description = "Service account to impersonate for Terraform apply/plan."
  type        = string
}

variable "network_host_project_id" {
  description = "Shared VPC host project."
  type        = string
}

variable "network_name" {
  description = "Shared VPC network name in the host project."
  type        = string
}

variable "subnet_name" {
  description = "Shared VPC subnet name used by the cluster."
  type        = string
}

variable "pods_secondary_range_name" {
  description = "Secondary range name on the subnet for Pod IPs."
  type        = string
  default     = "gke-pods"
}

variable "services_secondary_range_name" {
  description = "Secondary range name on the subnet for Service IPs."
  type        = string
  default     = "gke-services"
}

variable "cluster_name" {
  description = "GKE cluster name."
  type        = string
  default     = "gke-retail-dev"
}

variable "node_pool_name" {
  description = "Primary node pool name."
  type        = string
  default     = "default-pool"
}

variable "machine_type" {
  description = "Machine type for the node pool."
  type        = string
  default     = "e2-medium"
}

variable "node_count" {
  description = "Initial / fixed node count for the pool."
  type        = number
  default     = 1
}

variable "min_node_count" {
  description = "Minimum nodes when autoscaling is enabled."
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum nodes when autoscaling is enabled."
  type        = number
  default     = 2
}

variable "enable_autoscaling" {
  description = "Enable node pool autoscaling."
  type        = bool
  default     = true
}

variable "disk_size_gb" {
  description = "Boot disk size for nodes."
  type        = number
  default     = 50
}

variable "release_channel" {
  description = "GKE release channel."
  type        = string
  default     = "REGULAR"
}
