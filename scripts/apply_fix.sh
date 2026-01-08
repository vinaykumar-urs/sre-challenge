#!/bin/bash
set -e

echo "============================================"
echo "   SRE Challenge - Phase 3: The Fixes       "
echo "   Namespace: fixed                         "
echo "============================================"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MANIFESTS_DIR="$SCRIPT_DIR/../manifests/fixed"

echo "Creating 'fixed' namespace..."
kubectl apply -f "$MANIFESTS_DIR/namespace.yaml"

echo "Deploying FIXED resources..."
kubectl apply -f "$MANIFESTS_DIR/"

echo "Waiting for pods to start..."
sleep 2
kubectl wait --for=condition=available deployment/frontend --timeout=60s -n fixed || echo "Waiting..."
kubectl wait --for=condition=available deployment/backend --timeout=60s -n fixed || echo "Waiting..."

echo ""
echo "============================================"
echo "   FIXED Environment Deployed!"
echo "============================================"
echo "1. Check Pods (Should be Running, NOT crashing):"
echo "   kubectl get pods -n fixed"
echo ""
echo "2. Check Backend Endpoints (Should have IPs):"
echo "   kubectl get endpoints backend-svc -n fixed"
echo ""
echo "3. Verify DNS (Should work):"
echo "   kubectl run -i --rm --restart=Never busybox-fix --image=busybox:1.28 -n fixed -- nslookup backend-svc.fixed"
echo "============================================"
