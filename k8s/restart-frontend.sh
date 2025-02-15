#!/bin/bash

# Проверяем и создаем builder
if ! docker buildx ls | grep -q "builder"; then
    echo "Creating Docker builder..."
    docker buildx create --name builder --use --bootstrap
fi

# Проверяем наличие kind
if ! command -v kind &> /dev/null; then
    echo "Error: kind is not installed"
    exit 1
fi

echo "Rebuilding frontend image..."
cd ../frontend
docker build -t frontend:latest .
echo "Loading frontend image to kind..."
kind load docker-image frontend:latest

echo "Restarting frontend deployment..."
cd ../k8s
kubectl rollout restart deployment/frontend-deployment -n app-namespace

echo "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=frontend -n app-namespace --timeout=300s || true

# Получаем имя пода
FRONTEND_POD=$(kubectl get pod -n app-namespace -l app=frontend -o jsonpath='{.items[0].metadata.name}')

echo "Pod status and logs:"
kubectl describe pod -n app-namespace $FRONTEND_POD
echo "---"
kubectl logs -n app-namespace $FRONTEND_POD --previous || true
echo "---"
kubectl logs -n app-namespace $FRONTEND_POD

echo "Checking nginx configuration..."
kubectl exec -n app-namespace $FRONTEND_POD -- nginx -t || true

echo "Current pods status:"
kubectl get pods -n app-namespace -l app=frontend

echo "Проверяем логи фронтенда..."
kubectl logs -n app-namespace $FRONTEND_POD

echo "Проверяем логи nginx..."
kubectl exec -n app-namespace $FRONTEND_POD -- cat /var/log/nginx/error.log || true
kubectl exec -n app-namespace $FRONTEND_POD -- cat /var/log/nginx/access.log || true

echo "Проверяем конфигурацию nginx..."
kubectl exec -n app-namespace $FRONTEND_POD -- cat /etc/nginx/conf.d/default.conf

echo "Удаляем старые port-forward процессы..."
pkill -f "kubectl port-forward"
sleep 2

echo -e "\nFrontend доступен по адресу:"
echo "http://localhost:8080"

# Запускаем port-forward в фоне
echo "Настраиваем проброс портов..."
kubectl port-forward service/frontend-service -n app-namespace 8080:80 > /dev/null 2>&1 &
kubectl port-forward service/backend-service -n app-namespace 3000:3000 > /dev/null 2>&1 &

# Даем время на установку соединений
sleep 2

echo "Проверяем доступность бэкенда..."
curl -v http://localhost:3000/health || echo "Бэкенд недоступен"

echo "Проверяем доступность фронтенда..."
curl -v http://localhost:8080 || echo "Фронтенд недоступен"

echo -e "\nПриложение доступно по адресу: http://localhost:8080"
echo "Для остановки нажмите Ctrl+C"

# Ждем завершения
wait 