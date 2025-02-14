#!/bin/bash

echo "Rebuilding backend image..."
cd ../backend
docker build -t backend:latest .

echo "Loading image to minikube..."
minikube image load backend:latest

echo "Restarting backend deployment..."
cd ../k8s
kubectl rollout restart deployment/backend-deployment -n app-namespace

echo "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=backend -n app-namespace --timeout=300s

echo "Current pods status:"
kubectl get pods -n app-namespace -l app=backend