#!/bin/bash
set -e

echo "========================================================="
echo "   SRE Challenge - Production Resilience Test (Chaos)    "
echo "   Namespace: production                                 "
echo "========================================================="

echo ""
echo "--- 1. Test Self-Healing (ReplicaSet) ---"
POD=$(kubectl get pod -n production -l app.kubernetes.io/component=frontend -o jsonpath="{.items[0].metadata.name}")
echo "Deleting Pod: $POD"
kubectl delete pod $POD -n production
echo "Waiting for regeneration..."
sleep 2
kubectl get pods -n production -l app.kubernetes.io/component=frontend
echo "SUCCESS: You should see a new Pod (Age: <5s) replacing the old one."

echo ""
echo "--- 2. Test Network Policy (DNS Allow) ---"
echo "Verifying that Frontend can talk to Backend (DNS)..."
kubectl run -i --rm --restart=Never verify-net --image=busybox:1.28 -n production --timeout=20s -- nslookup backend-svc.production
echo "SUCCESS: DNS Resolution worked!"

echo ""
echo "--- 3. Test Memory Limits (OOM Protection) ---"
echo "Current Limit: 512Mi. We will patch a pod to use 600Mi."
echo "Expectation: Kubernetes should KILL the pod (OOMKilled)."

# Patch the deployment to run a "bomb" command
kubectl patch deployment sre-production-sre-challenge-frontend -n production --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/command", "value": ["python", "-c", "print(\"Allocating 600MB...\"); a = \"A\" * (1024*1024*600); import time; time.sleep(100)"]}]'

echo "Watching for OOMKilled (Wait 15s)..."
sleep 15
kubectl get pods -n production

echo ""
echo "--- RESETTING TO NORMAL ---"
echo "Reverting patch..."
kubectl rollout undo deployment sre-production-sre-challenge-frontend -n production
echo "Environment restored."

echo "========================================================="
echo "   Resilience Tests Completed!"
echo "========================================================="
