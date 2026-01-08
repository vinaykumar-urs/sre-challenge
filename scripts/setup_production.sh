#!/bin/bash
set -e

echo "========================================================="
echo "   SRE Challenge - Phase 4: Production (Helm Deploy)     "
echo "   Namespace: production                                 "
echo "========================================================="

echo "--- 1. Checking Cluster Capability ---"
NODE_COUNT=$(kubectl get nodes --no-headers | wc -l)
echo "Node Count: $NODE_COUNT"

if [ "$NODE_COUNT" -lt 2 ]; then
    echo "WARNING: You only have 1 Node!"
    echo "For true 'Production' HA (High Availability), you need at least 2 or 3 nodes."
    echo "To fix this later: delete minikube and run 'minikube start --nodes 3'"
    echo "Proceeding purely with software deployment for now..."
else
    echo "SUCCESS: Multi-node cluster detected. HA features will be effective."
fi

echo ""
echo "--- 2. Installing Production Chart ---"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CHART_DIR="$SCRIPT_DIR/../chart/sre-challenge"

echo "Creating 'production' namespace..."
kubectl create namespace production --dry-run=client -o yaml | kubectl apply -f -

echo "Deploying Helm Chart..."
helm upgrade --install sre-production "$CHART_DIR" \
  --namespace production \
  --atomic \
  --wait \
  --timeout 2m

echo ""
echo "--- 3. Verifying Deployment ---"
kubectl get svc,deploy,pods -n production


echo ""
echo "========================================================="
echo "   Production Environment Deployed!"
echo "========================================================="
echo "1. Verify HPA (Autoscaling):"
echo "   kubectl get hpa -n production"
echo "2. Verify PDB (Availability Protection):"
echo "   kubectl get pdb -n production"
echo "3. Verify Alerts:"
echo "   kubectl get prometheusrules -n monitoring"
echo "========================================================="
