#!/bin/bash
set -e

echo "============================================"
echo "   SRE Challenge - Phase 1: Simulation      "
echo "   Namespace: broken                        "
echo "============================================"

# Check Minikube status
if ! command -v minikube &> /dev/null; then
    echo "Error: minikube not found."
    exit 1
fi

status=$(minikube status -f='{{.Host}}' || echo "Stopped")
if [[ "$status" != "Running" ]]; then
    echo "Minikube is not running. Please run 'minikube start' first."
    exit 1
fi

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MANIFESTS_DIR="$SCRIPT_DIR/../manifests/broken"

echo "Cleaning up old 'broken' namespace..."
kubectl delete namespace broken --ignore-not-found --wait=true

echo "Creating 'broken' namespace..."
kubectl apply -f "$MANIFESTS_DIR/namespace.yaml"
# Wait for namespace to be active/usable
kubectl wait --for=jsonpath='{.status.phase}=Active' namespace/broken --timeout=10s

echo "Deploying BROKEN resources..."
# Apply the rest (Frontend, Backend, NetworkPolicy)
kubectl apply -f "$MANIFESTS_DIR/"

echo "Waiting for pods to start..."
sleep 5
kubectl get pods -n broken

echo "============================================"
echo "   Simulation Started in namespace: BROKEN"
echo "   1. Watch Crashes: kubectl get pods -n broken -w"
echo "   2. Check EP:      kubectl get endpoints backend-svc -n broken"
echo "============================================"
