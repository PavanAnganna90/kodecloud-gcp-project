# Docker repo that CI pushes app images to.
# Image path becomes: <location>-docker.pkg.dev/<project_id>/<repo>/<app>
# Set create_artifact_registry = false when the repo already exists or is
# owned centrally by another team.

locals {
  artifact_registry_location = coalesce(var.artifact_registry_location, var.region)
  artifact_registry_url      = "${local.artifact_registry_location}-docker.pkg.dev/${var.project_id}/${var.artifact_registry_repo}"
}

resource "google_artifact_registry_repository" "app_images" {
  count = var.create_artifact_registry ? 1 : 0

  project       = var.project_id
  location      = local.artifact_registry_location
  repository_id = var.artifact_registry_repo
  format        = "DOCKER"
  description   = "Container images for ${var.name_prefix} workloads"

  labels = {
    managed-by = "terraform"
  }

  # Untagged layers accumulate on every rebuild and are never pulled.
  cleanup_policies {
    id     = "delete-untagged"
    action = "DELETE"

    condition {
      tag_state  = "UNTAGGED"
      older_than = var.artifact_registry_untagged_retention
    }
  }

  depends_on = [google_project_service.required]
}

# Push access for CI identities, e.g. the Cloud Build service account.
# Nodes only need pull, which iam.tf grants at project level.
resource "google_artifact_registry_repository_iam_member" "writers" {
  for_each = toset(var.image_pusher_members)

  project    = var.project_id
  location   = local.artifact_registry_location
  repository = var.artifact_registry_repo
  role       = "roles/artifactregistry.writer"
  member     = each.value

  depends_on = [google_artifact_registry_repository.app_images]
}
