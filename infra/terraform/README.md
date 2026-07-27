# Infrastructure template — base GKE for your app
#
# Creates: GKE Standard (zonal), node pool, node SA + IAM, Shared VPC wiring,
#          and the Artifact Registry Docker repo that CI pushes to.
# Does not deploy the app container (use deploy/k8s + ci/cloudbuild.yaml).

## What you fill in (only two files)

| File | Purpose |
|------|---------|
| `backend.hcl` | GCS state bucket + prefix |
| `terraform.tfvars` | Project, network, cluster, sizing |

Both have `*.example` templates with comments on **where to get each value**.

## Steps

```bash
# 1) Login (ADC). You will impersonate the apply SA in tfvars.
gcloud auth application-default login

# 2) Remote state config
cd infra/terraform
cp backend.hcl.example backend.hcl          # edit bucket + prefix
cp terraform.tfvars.example terraform.tfvars  # edit REQUIRED sections

# 3) Init + apply
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```

## After apply

```bash
terraform output get_credentials_command
# run the printed gcloud command, then deploy the app via Kustomize / Cloud Build

terraform output artifact_registry_repo_url
# use this as _AR_REGION / _AR_REPO in ci/cloudbuild.yaml
```

## Adopting an Artifact Registry repo that already exists

Terraform fails with `already exists` on a repo it does not track. Either set
`create_artifact_registry = false`, or import it once:

```bash
terraform import \
  'google_artifact_registry_repository.app_images[0]' \
  projects/PROJECT_ID/locations/REGION/repositories/REPO_ID
```

## Destroy

```bash
terraform destroy
```

Leaves Shared VPC / NAT in the network host project alone.

## Tips

- **REQUIRED** vs **OPTIONAL** is labeled inside `terraform.tfvars.example`.
- Subnet must already have secondary ranges for Pods/Services (platform network team).
- Apply SA must be allowed to manage GKE in `project_id` and use the Shared VPC subnet.

## Firewall rules for LoadBalancer Services

There are none here on purpose. In a Shared VPC, GKE creates the host-project
rules for a `type: LoadBalancer` Service itself, scoped to the exact port and to
its own generated `gke-<cluster>-<hash>-node` tag. It can only do that once the
GKE service agent holds `container.hostServiceAgentUser` and
`compute.networkUser` on the host project, which `iam.tf` grants.

Writing these rules by hand is how you end up opening the whole NodePort range
`30000-32767` to `0.0.0.0/0`. If external traffic does not reach your Service,
check the service agent IAM before adding firewall rules.
