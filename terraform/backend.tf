terraform {
  backend "gcs" {
    bucket = "prj-seed-74ba49-tfstate"
    prefix = "workloads/prj-mrdn-retail-dev/gke"
  }
}
