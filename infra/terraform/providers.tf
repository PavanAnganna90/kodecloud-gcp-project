# Providers — no user edits needed for a standard deploy.
# project / region / apply SA come from terraform.tfvars.

provider "google" {
  project                     = var.project_id
  region                      = var.region
  impersonate_service_account = var.terraform_service_account
}

provider "google-beta" {
  project                     = var.project_id
  region                      = var.region
  impersonate_service_account = var.terraform_service_account
}
