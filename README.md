# SRE Challenge: Kubernetes Troubleshooting & Production Engineering

This repository contains a complete **SRE Challenge** designed to test and teach Kubernetes troubleshooting, resilience, and production engineering skills.

It is structured into **3 Phases**, taking you from a broken cluster to a production-ready, auto-scaling environment.

## 🚀 Quick Start

**Prerequisites**: `minikube`, `kubectl`, `helm`.

```bash
# Start a fresh cluster
minikube start --nodes 3 # Recommended for HA (or just 'minikube start' for basic)
```

---

## 🛑 Phase 1: The Broken State (Simulation)
**Goal**: Simulate a "Production Outage" with multiple root causes.

### What we did:
*   Created a `broken` namespace.
*   Deployed a **Frontend** that crashes after processing specific data.
*   Deployed a **Backend** that is unreachable.
*   Blocked DNS and Egress traffic via **NetworkPolicy**.

### What to Check (Debugging):
Run the simulation and the debug script:
```bash
./scripts/start_simulation.sh
./scripts/debug_broken_state.sh
```
**You will observe:**
1.  **OOMKilled**: Frontend pod restarts repeatedly (Memory Limit: 256Mi vs Load: 300MB).
2.  **Service Failure**: Backend Service has no Endpoints (Label Mismatch).
3.  **DNS Failure**: `nslookup` times out (NetworkPolicy blocks UDP 53).

---

## ✅ Phase 2: The Fixes
**Goal**: Identify root causes and apply manual fixes.

### What we did:
*   Created a `fixed` namespace.
*   **Fix 1**: Increased Frontend Memory Limit to `512Mi`.
*   **Fix 2**: Corrected Backend Service Selector to `app: backend-api`.
*   **Fix 3**: Added `egress` rule to NetworkPolicy allowing Port 53 (DNS).

### What to Check (Verification):
Apply the fixes and verify:
```bash
./scripts/apply_fix.sh
```
**You will observe:**
1.  Pods are **Running** (Stable).
2.  Frontend can successfully resolve and talk to Backend.

---

## 🌟 Phase 3: Production Standards (Enhancements)
**Goal**: Transform the simple app into a resilient, scalable, observable Production system.

### What we did:
*   **Helm Chart**: Created a custom chart `sre-challenge` for reproducible deployments.
*   **Autoscaling (HPA)**: Configured Frontend to scale (2-10 pods) based on CPU > 70%.
*   **Availability (PDB)**: Added Pod Disruption Budgets to protect against node outages.
*   **Database (Redis)**: Added a StatefulSet with Persistent Storage (1Gi).
*   **Self-Healing**: Implemented Liveness Probes.
*   **Observability**: Added `ServiceMonitor` for Prometheus and Rules for Alerting.

### What to Check (Resilience):
Deploy the Production stack:
```bash
./scripts/setup_production.sh
```

**Run the Chaos/Resilience Tests:**
```bash
./scripts/test_production.sh
```
**You will observe:**
1.  **Self-Healing**: Deleting a pod instantly spawns a new one.
2.  **Resilience**: Traffic flows even if one node dies.
3.  **Visual Status**: Visit `http://localhost:8080` (after port-forward) to see the **Real-time Redis Connection Status**.

---

## 📂 Repository Structure

| Directory | Description |
|-----------|-------------|
| `manifests/broken` | YAMLs for Phase 1 (Faulty) |
| `manifests/fixed` | YAMLs for Phase 2 (Corrected) |
| `chart/sre-challenge` | Phase 3 Helm Chart (Production) |
| `scripts/` | Automation scripts (`start`, `fix`, `prod`, `debug`) |
| `SOLUTION_REPORT.md` | Detailed Root Cause Analysis & Diagrams |

---

*Created for SRE Challenge 2026.*
