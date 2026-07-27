# Shared VPC host firewalls so external LoadBalancer traffic can reach private nodes.
# GKE normally auto-creates these; on Shared VPC that often needs host firewall permissions.

resource "google_compute_firewall" "allow_lb_to_nodes" {
  name    = "fw-gke-retail-dev-allow-lb"
  project = var.network_host_project_id
  network = data.google_compute_network.shared.name

  description = "Allow internet traffic to GKE NodePorts for LoadBalancer Services"
  direction   = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["30000-32767"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["gke-node"]
}

resource "google_compute_firewall" "allow_hc_to_nodes" {
  name    = "fw-gke-retail-dev-allow-hc"
  project = var.network_host_project_id
  network = data.google_compute_network.shared.name

  description = "Allow Google LB health checks to GKE nodes"
  direction   = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["10256", "30000-32767"]
  }

  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16",
  ]
  target_tags = ["gke-node"]
}
