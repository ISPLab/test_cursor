#!/bin/bash

# Проверяем и создаем builder
if ! docker buildx ls | grep -q "builder"; then
    echo "Creating Docker builder..."
    docker buildx create --name builder --use --bootstrap
fi

echo "Rebuilding backend image..."
cd ../backend/
docker build -t backend:latest .

echo "Loading image to kind..."
kind load docker-image backend:latest

echo "Restarting backend deployment..."
cd ../k8s
kubectl rollout restart deployment/backend-deployment -n app-namespace

echo "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=backend -n app-namespace --timeout=300s

echo "Current pods status:"
kubectl get pods -n app-namespace -l app=backend