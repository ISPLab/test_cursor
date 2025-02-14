#!/bin/bash

# Создаем namespace если его нет
kubectl create namespace app-namespace --dry-run=client -o yaml | kubectl apply -f -

# Применяем конфигурации
kubectl apply -f configmap.yaml -n app-namespace
kubectl apply -f secret.yaml -n app-namespace
kubectl apply -f backend.yaml -n app-namespace
kubectl apply -f frontend.yaml -n app-namespace
kubectl apply -f ingress.yaml -n app-namespace

# Ждем, пока все поды будут готовы
kubectl wait --for=condition=ready pod -l app=backend -n app-namespace --timeout=300s
kubectl wait --for=condition=ready pod -l app=frontend -n app-namespace --timeout=300s

echo "Deployment completed!" 