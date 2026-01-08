#!/bin/bash
set -e

echo "============================================"
echo "   SRE Challenge - Monitoring Setup (Helm)  "
echo "   Namespace: monitoring                    "
echo "============================================"

# Check Helm
if ! command -v helm &> /dev/null; then
    echo "Error: helm not found. Please install helm."
    exit 1
fi

echo "Adding Prometheus Community Repo..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

echo "Creating 'monitoring' namespace..."
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

echo "Installing kube-prometheus-stack (Prometheus + Grafana)..."
# We disable Alertmanager/Pushgateway to save resources on local laptop
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set alertmanager.enabled=false \
  --set prometheus-node-exporter.enabled=true \
  --set grafana.enabled=true \
  --wait

echo "============================================"
echo "   Monitoring Stack Deployed!"
echo "   To access Grafana run:"
echo "   kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring"
echo "   (Open browser -> http://localhost:3000)"
echo "   User: admin"
echo "   Pass: $(kubectl get secret monitoring-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 --decode)"
echo "============================================"
