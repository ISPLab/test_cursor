#!/bin/bash

echo "Creating test pod..."
kubectl run test-pod --image=busybox -n app-namespace -- sleep 3600

echo "Waiting for pod to be ready..."
kubectl wait --for=condition=ready pod/test-pod -n app-namespace --timeout=60s

echo "Testing network from inside pod..."
kubectl exec -it test-pod -n app-namespace -- wget -qO- --timeout=2 http://localhost
kubectl exec -it test-pod -n app-namespace -- wget -qO- --timeout=2 http://backend-service:3000/health
kubectl exec -it test-pod -n app-namespace -- wget -qO- --timeout=2 http://frontend-service

echo "Checking DNS resolution..."
kubectl exec -it test-pod -n app-namespace -- nslookup backend-service
kubectl exec -it test-pod -n app-namespace -- nslookup frontend-service

echo "Cleaning up..."
kubectl delete pod test-pod -n app-namespace 