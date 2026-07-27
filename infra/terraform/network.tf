# Looks up an EXISTING Shared VPC (not created here).
# User inputs: network_host_project_id, network_name, subnet_name, region
# Where to get them: see terraform.tfvars.example [REQUIRED] Shared VPC section.

data "google_compute_network" "shared" {
  name    = var.network_name
  project = var.network_host_project_id
}

data "google_compute_subnetwork" "shared" {
  name    = var.subnet_name
  region  = var.region
  project = var.network_host_project_id
}

locals {
  network_self_link    = data.google_compute_network.shared.self_link
  subnetwork_self_link = data.google_compute_subnetwork.shared.self_link
}
