# GKE Standard (zonal) on existing Shared VPC

Infra only: cluster, node pool, and IAM. Network/NAT live in `prj-mrdn-network-prod`
and are **not** managed here.

## Prerequisites

1. ADC as yourself:

   ```bash
   gcloud auth application-default login
   ```

2. Permission to impersonate:

   `sa-tf-bootstrap-apply@prj-seed-74ba49.iam.gserviceaccount.com`

   Role: `roles/iam.serviceAccountTokenCreator` on that SA.

3. Copy tfvars:

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

## Apply

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

State: `gs://prj-seed-74ba49-tfstate/workloads/prj-mrdn-retail-dev/gke`

## After apply

```bash
# use the printed output, or:
gcloud container clusters get-credentials gke-retail-dev \
  --zone us-central1-a \
  --project prj-mrdn-retail-dev
```

App Deployment/Service is intentionally out of scope. Image to use later:

`us-central1-docker.pkg.dev/prj-mrdn-retail-dev/gcp-artifact-registry/gcpdevops:latest`

Flask listens on port **5000** by default.

## Destroy

Removes only what this root owns (GKE + IAM). Shared VPC/NAT stay.

```bash
terraform destroy
```
