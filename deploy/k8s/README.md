# Kustomize app manifests

- `base/` — generic Namespace + Deployment + Service (image placeholder `APP_IMAGE`)
- `overlays/default/` — sample Flask app wiring (namespace, namePrefix, image, port)

The overlay's `namespace:` field does double duty: it renames the base Namespace
object and sets `metadata.namespace` on everything else. So the namespace is
created by the deploy, and there is no `kubectl create namespace` step.
`namePrefix` is not applied to the Namespace, which is why its name stays clean.

```bash
kubectl kustomize overlays/default
kubectl apply -k overlays/default
```

To onboard another app: copy `overlays/default` → `overlays/<name>` and edit that folder only.
