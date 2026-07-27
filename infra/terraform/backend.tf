# Backend block is empty on purpose (partial configuration).
# Values come from backend.hcl — see backend.hcl.example.
terraform {
  backend "gcs" {}
}
