# GCP app platform template

Reusable layout to build a container, push it to Artifact Registry, and deploy it to GKE.
Fill in config, point Cloud Build at `ci/cloudbuild.yaml`, replace or keep the sample app.

## Layout

```text
app/                  Sample application (Flask) + Dockerfile  ← replace with yours
deploy/k8s/
  base/               Generic Namespace + Deployment + Service
  overlays/default/   Example values (name, namespace, image, port)
infra/terraform/      GKE cluster + node SA/IAM + Shared VPC wiring + Artifact Registry
ci/cloudbuild.yaml    Build → push → Kustomize render → deploy
config.env.example    Human-readable settings (mirror in Cloud Build substitutions)
```

## Naming

| Thing | Pattern | Example |
|--------|---------|---------|
| App name | short slug | `gcpdevops` |
| Image | `{region}-docker.pkg.dev/$PROJECT_ID/{repo}/{app}` | `.../gcpdevops` |
| K8s resources | `{app}-app` (Kustomize `namePrefix`) | `gcpdevops-app` |
| Labels | `app.kubernetes.io/name: {app}` | `gcpdevops` |

## Quick start (new user)

### 1. App

Put your code in `app/` with a `Dockerfile`. Or keep the Flask sample.

### 2. Deploy config

```bash
cp config.env.example config.env
# edit APP_NAME, cluster, namespace, registry

cp -r deploy/k8s/overlays/default deploy/k8s/overlays/myapp
# edit overlays/myapp/kustomization.yaml (namespace, namePrefix, image, port)
```

Set `_KUSTOMIZE_OVERLAY=deploy/k8s/overlays/myapp` in Cloud Build if you use a new overlay.

### 3. Infra (once per environment)

```bash
cd infra/terraform
cp backend.hcl.example backend.hcl              # state bucket + prefix
cp terraform.tfvars.example terraform.tfvars    # project, VPC, cluster (commented)
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```

Every `[REQUIRED]` field in `terraform.tfvars.example` says **where to get the value** (Console / gcloud).

This also creates the Artifact Registry repo and grants push access to the
identities in `image_pusher_members`, so there are no Console clicks before the
first build. Set `create_artifact_registry = false` if the repo already exists.

### 4. CI

1. Create/connect a Cloud Build trigger on this repo.
2. Set the build config path to **`ci/cloudbuild.yaml`** (not the old root file).
3. Set substitutions to match `config.env` (`_APP_NAME`, `_AR_REPO`, …).
4. Run as the SA you listed in `image_pusher_members`; it also needs
   `roles/container.developer` to deploy to GKE.
5. Custom SA builds need `CLOUD_LOGGING_ONLY` (already set).

### 5. Verify

```bash
kubectl get deploy,svc -n <K8S_NAMESPACE>
```

## Local render (optional)

```bash
kubectl kustomize deploy/k8s/overlays/default
```

## Tear down

```bash
kubectl delete -k deploy/k8s/overlays/default
cd infra/terraform && terraform destroy
```

## Migration note

Older manifests used `gcpdevops` / `gcpdevops-service`.
This template renders **`gcpdevops-app`** for both Deployment and Service.
Delete the old objects once when you cut over.
