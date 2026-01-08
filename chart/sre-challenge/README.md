# SRE Challenge - Custom Helm Chart

Yes, this is a **Custom Helm Chart** that we built from scratch!

## 1. Where do the files live?
The chart is located at: `antlan/sre-challenge/chart/sre-challenge/`

Inside, you will find:
*   `Chart.yaml`: The ID card (Name: sre-challenge, Version: 1.0.0).
*   `values.yaml`: The **Configuration Hub**. This is where we set replicas, limits, and enable features like HPA.
*   `templates/`: The **Blueprints**. Helm takes values from `values.yaml` and fills in these templates.

## 2. What did we create?

### The Core App
*   **Frontend**: `templates/frontend-deployment.yaml` (Deploys the Python app)
*   **Backend**: `templates/backend.yaml` (Deploys Nginx + Service)
*   **Config**: `templates/configmap.yaml` (Decouples config from code)

### The SRE "Magic" (Phase 4)
*   **Autoscaler (HPA)**: `templates/hpa.yaml`
    *   *What it does:* Checks CPU every 15s. If usage > 70%, it adds more pods (up to 10).
*   **Availability (PDB)**: `templates/pdb.yaml`
    *   *What it does:* Prevents Kubernetes from draining the last node if it would kill the last pod.
*   **Security**: `templates/network-policy.yaml`
    *   *What it does:* Locks down traffic.
*   **Alerting**: `templates/prometheusrule.yaml`
    *   *What it does:* Tells Prometheus "Alert me if memory > 400MB".

## 3. How to modify it?
You don't edit the YAMLs in `templates/` usually. You edit `values.yaml`!

Example: Want 20 replicas max?
Change `values.yaml` -> `frontend.autoscaling.maxReplicas: 20`
Then run `helm upgrade ...`
