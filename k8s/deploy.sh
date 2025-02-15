#!/bin/bash

# Проверяем наличие kind
if ! command -v kind &> /dev/null; then
    echo "Error: kind is not installed. Installing..."
    brew install kind
    
    echo "Creating kind cluster..."
    kind create cluster
fi

# Спрашиваем пользователя о необходимости очистки
read -p "Do you want to clean up all resources before deployment? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Cleaning up resources..."
    kubectl delete all --all -n app-namespace
    sleep 5
fi

# Очищаем старые процессы port-forward
echo "Cleaning up old port-forward processes..."
pkill -f "kubectl port-forward" || true
sleep 2

# Создаем namespace если его нет
kubectl create namespace app-namespace --dry-run=client -o yaml | kubectl apply -f -

# Собираем и загружаем образы
echo "Building and loading images..."

echo "Building backend image..."
cd ../backend
docker build -t backend:latest .
echo "Loading backend image to kind..."
kind load docker-image backend:latest

echo "Building frontend image..."
cd ../frontend
docker build -t frontend:latest .
echo "Loading frontend image to kind..."
kind load docker-image frontend:latest

cd ../k8s

# Применяем конфигурации
echo "Applying configurations..."

# Применяем общие конфигурации
kubectl apply -f configmap.yaml -n app-namespace
kubectl apply -f secret.yaml -n app-namespace

# Применяем конфигурации бэкенда и фронтенда
kubectl apply -f backend-deployment.yaml -n app-namespace
kubectl apply -f backend-service.yaml -n app-namespace
kubectl apply -f frontend-deployment.yaml -n app-namespace
kubectl apply -f frontend-service.yaml -n app-namespace
kubectl apply -f ingress.yaml -n app-namespace

# Ждем, пока все поды будут готовы
echo "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=backend -n app-namespace --timeout=300s
kubectl wait --for=condition=ready pod -l app=frontend -n app-namespace --timeout=300s

# Настраиваем проброс портов
echo "Setting up port forwarding..."
kubectl port-forward service/frontend-service -n app-namespace 8080:80 > /dev/null 2>&1 &
kubectl port-forward service/backend-service -n app-namespace 3000:3000 > /dev/null 2>&1 &

# Даем время на установку соединений
sleep 3

# Проверяем доступность сервисов
echo "Checking services availability..."
echo "Frontend: http://localhost:8080"
echo "Backend: http://localhost:3000"

curl -s http://localhost:3000/health > /dev/null && echo "Backend is accessible" || echo "Backend is not accessible"
curl -s http://localhost:8080 > /dev/null && echo "Frontend is accessible" || echo "Frontend is not accessible"

# Проверяем статус
echo -e "\nDeployment completed! Checking status..."
kubectl get all -n app-namespace

echo -e "\nPress Ctrl+C to stop port forwarding"
wait 