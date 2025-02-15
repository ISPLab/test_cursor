#!/bin/bash

# Проверяем наличие kind
if ! command -v kind &> /dev/null; then
    echo "Error: kind is not installed"
    exit 1
fi

echo "Rebuilding backend image..."
cd ../backend
docker build -t backend:latest .
echo "Loading backend image to kind..."
kind load docker-image backend:latest

echo "Restarting backend deployment..."
cd ../k8s
kubectl rollout restart deployment/backend-deployment -n app-namespace

echo "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=backend -n app-namespace --timeout=300s

echo "Current pods status:"
kubectl get pods -n app-namespace -l app=backend

# Показываем URL для доступа
echo -e "\nBackend API доступен по адресу:"
echo "http://localhost:3000"

# Пробрасываем порт для локального доступа
echo "Пробрасываем порт 3000..."
kubectl port-forward service/backend-service 3000:3000 -n app-namespace