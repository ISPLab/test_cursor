#!/bin/bash

# Проверяем, запущен ли Minikube
if ! minikube status > /dev/null 2>&1; then
    echo "Starting Minikube..."
    minikube start --driver=hyperkit
fi

# Проверяем, включен ли Ingress
if ! minikube addons list | grep -q "ingress: enabled"; then
    echo "Enabling Ingress..."
    minikube addons enable ingress
fi

# Создаем namespace если его нет
kubectl create namespace app-namespace --dry-run=client -o yaml | kubectl apply -f -

# Применяем конфигурации
echo "Applying configurations..."

# Применяем общие конфигурации
kubectl apply -f configmap.yaml -n app-namespace
kubectl apply -f secret.yaml -n app-namespace

# Применяем конфигурации бэкенда
kubectl apply -f backend-deployment.yaml -n app-namespace
kubectl apply -f backend-service.yaml -n app-namespace

# Применяем конфигурации фронтенда
kubectl apply -f frontend-deployment.yaml -n app-namespace
kubectl apply -f frontend-service.yaml -n app-namespace

# Применяем ingress
kubectl apply -f ingress.yaml -n app-namespace

# Ждем, пока все поды будут готовы
echo "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=backend -n app-namespace --timeout=300s
kubectl wait --for=condition=ready pod -l app=frontend -n app-namespace --timeout=300s

# Выводим информацию о доступе
echo "Deployment completed!"
echo "Access the application:"
echo "1. Add to /etc/hosts:"
echo "$(minikube ip) app.local"
echo "2. Open http://app.local in your browser"

# Проверяем статус
kubectl get all -n app-namespace 