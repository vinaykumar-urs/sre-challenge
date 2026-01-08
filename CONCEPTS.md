# SRE Challenge Concepts & Phase 1 Explanation

## 1. Why these Manifests?

### `backend.yaml` (Service + Deployment)
- **Deployment**: Creates the actual "Pods" (containers) that run the application code.
- **Service**: Creates a **Stable Address** (DNS Name).
    - **Why does Backend need a Service?** Because the Frontend needs a permanent address to talk to. If backend pods restart, their IP changes. The Service `backend-svc` gives a static name `http://backend-svc` that never changes.

### `frontend.yaml` (Deployment only?)
- **Deployment**: Runs the frontend code.
- **Why no Service?** In this broken simulation, we are focusing on *internal* crashes (OOM) and *outgoing* connections. We haven't created a Service for the frontend *yet* because the primary task is to stop it from crashing. In a real world, yes, you would add a Service (type LoadBalancer or Ingress) to let *Users* access it.

### `network.yaml` (The "Firewall")
- **NetworkPolicy**: Think of this as a Firewall inside the cluster.
- **Egress**: Rules for traffic *leaving* a pod.
- **The "Broken" Part**: It says "Manage traffic" but *fails* to allow traffic to the DNS Server (CoreDNS). If you can't talk to the DNS server, you can't translate `google.com` or `backend-svc` to an IP address.

## 2. The PDF Concepts

### "Depend on backend with DNS"
The PDF says the frontend fails to resolve the hostname of the backend.
- **Concept**: Kubernetes has a built-in DNS server called **CoreDNS** (you saw it in `kube-system`).
- **How it works**: When Frontend asks "Where is `backend-svc`?", it asks CoreDNS.
- **The Challenge**: The Frontend is crashing because it tries to reach Backend, but:
    1.  **NetworkPolicy** blocks the call to CoreDNS.
    2.  **Service Label Mismatch** means even if DNS worked, the Service points to "Nothing" (Empty endpoint).

## 3. "Ingress"
- **My Search**: I searched the PDF and found **0 mentions of 'Ingress'**.
- **Your Question**: "use frontend as ingress".
- **Clarification**: In Kubernetes, **Ingress** is a specific object (like an HTTP Router) that sits at the edge. The PDF focuses on *internal* complexity (Pod-to-Pod and Pod-to-External-DB). We can add an Ingress later in "Best Practices", but it is not a requirement to solve the internal crash loop.

---
**Summary of Phase 1 Simulation**
We rely on:
1.  **Deployment** (to crash)
2.  **Service** (to fail discovery)
3.  **NetworkPolicy** (to block DNS)
