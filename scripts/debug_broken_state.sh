#!/bin/bash
echo "==================================================="
echo "   SRE Challenge - Debugging & Troubleshooting     "
echo "   (Network, DNS, and Resource Analysis)           "
echo "==================================================="

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Assuming manifests are relative to script location if needed in future

echo ""
echo "--- 1. Troubleshoot Internal Networking (Service Discovery) ---"
echo "Goal: Verify if Frontend can resolve 'backend-svc'."
echo "Command: Checking Endpoints for 'backend-svc'..."
kubectl get endpoints backend-svc -n fixed
echo "ANALYSIS: "
echo "  - If ENDPOINTS is '<none>', the Service Selector does not match any Pods."
echo "  - This causes DNS resolution to fail or connection refused."

echo ""
echo "--- 2. Troubleshoot DNS & External Connectivity (NetworkPolicy) ---"
echo "Goal: Verify if Pods can reach CoreDNS (Port 53) and External Sites."
echo "Command: Launching temporary 'busybox' pod to run network tools..."

# Run a single pod to do multiple checks
kubectl run -i --rm --restart=Never debug-net-tools --image=busybox:1.28 -n fixed --timeout=20s -- sh -c '
    echo ""
    echo "[Test 2.1] Internal DNS Lookup (nslookup backend-svc):"
    nslookup backend-svc.fixed
    if [ $? -ne 0 ]; then echo "FAIL: DNS Lookup failed (UDP/53 blocked?)"; else echo "SUCCESS: DNS Resolved"; fi

    echo ""
    echo "[Test 2.2] External DNS Lookup (nslookup google.com):"
    nslookup google.com
    if [ $? -ne 0 ]; then echo "FAIL: External DNS failed (UDP/53 blocked)"; else echo "SUCCESS: External DNS Resolved"; fi

    echo ""
    echo "[Test 2.3] External Connectivity (wget google.com):"
    wget -q --spider --timeout=2 google.com
    if [ $? -ne 0 ]; then echo "FAIL: Cannot reach Internet (Egress blocked)"; else echo "SUCCESS: Internet Reachable"; fi
' || true

echo "ANALYSIS:"
echo "  - If DNS fails, NetworkPolicy might be blocking UDP/TCP Port 53."
echo "  - If External connect fails, NetworkPolicy Default-Deny is active."

echo ""
echo "--- 3. Troubleshoot Resource Issues (OOM) ---"
echo "Goal: Identify why Frontend is crashing."
echo "Command: Checking Pod Status and Events..."
kubectl get pods -n fixed -l app=frontend
echo ""
echo "Command: Checking Previous Termination State..."
kubectl get pod -l app=frontend -n fixed -o jsonpath='{.items[0].status.containerStatuses[0].lastState.terminated.reason}'
echo ""
echo "ANALYSIS:"
echo "  - 'OOMKilled' means the Pod hit its Memory Limit."
echo "  - Check Grafana Dashboard to see the memory spike."

echo ""
echo "==================================================="
echo "   Troubleshooting Complete."
echo "==================================================="
