#!/bin/bash

# Проверяем и создаем builder
if ! docker buildx ls | grep -q "builder"; then
    echo "Creating Docker builder..."
    docker buildx create --name builder --use --bootstrap
fi

echo "Rebuilding frontend image..."
cd ../frontend/
docker build -t frontend:latest .

echo "Loading image to kind..."
kind load docker-image frontend:latest

echo "Restarting frontend deployment..."
cd ../k8s
kubectl rollout restart deployment/frontend-deployment -n app-namespace

echo "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=frontend -n app-namespace --timeout=300s

echo "Current pods status:"
kubectl get pods -n app-namespace -l app=frontend 