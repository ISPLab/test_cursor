#!/bin/bash

set -e  # Останавливаем скрипт при ошибках

# Функция для логирования
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Функция для проверки результата
check_result() {
    if [ $? -ne 0 ]; then
        log "Error: $1"
        exit 1
    fi
}

# Функция для безопасной очистки порта
clean_port() {
    local port=$1
    log "Checking port $port..."
    
    # Получаем PID без ошибки если процесс не найден
    local pid=$(lsof -ti:$port 2>/dev/null || true)
    
    if [ ! -z "$pid" ]; then
        log "Found process using port $port (PID: $pid)"
        kill -9 $pid 2>/dev/null || true
        sleep 1
        
        # Проверяем, освободился ли порт
        if lsof -i:$port 2>/dev/null; then
            log "Warning: Failed to free port $port"
            return 1
        else
            log "Successfully freed port $port"
        fi
    else
        log "Port $port is already free"
    fi
}

# Функция для проверки Docker
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        log "Starting Docker Desktop..."
        open -a Docker
        for i in {1..30}; do
            if docker info > /dev/null 2>&1; then
                log "Docker is running!"
                return 0
            fi
            log "Waiting for Docker... ($i/30)"
            sleep 2
        done
        log "Failed to start Docker"
        return 1
    else
        log "Docker is already running"
        return 0
    fi
}

# 1. Подготовка окружения
log "Preparing environment..."

# Проверяем sudo права
if [ "$EUID" -ne 0 ]; then 
    log "Please run as root (use sudo)"
    exit 1
fi

# Очищаем порты и процессы
log "Cleaning up ports..."
failed_ports=()
for port in 6443 8000 9443; do
    if ! clean_port $port; then
        failed_ports+=($port)
    fi
done

if [ ${#failed_ports[@]} -ne 0 ]; then
    log "Error: Failed to free ports: ${failed_ports[*]}"
    log "Please free these ports manually and try again"
    exit 1
fi

# Очищаем Docker
log "Cleaning up Docker..."
docker ps -aq | xargs docker rm -f 2>/dev/null || true
docker network prune -f 2>/dev/null || true

# 2. Проверка зависимостей
log "Checking dependencies..."

# Проверяем Docker
if ! check_docker; then
    exit 1
fi

# Проверяем kind
if ! command -v kind &> /dev/null; then
    log "Installing kind..."
    brew install kind
    check_result "Failed to install kind"
fi

# Проверяем kubectl
if ! command -v kubectl &> /dev/null; then
    log "Installing kubectl..."
    brew install kubectl
    check_result "Failed to install kubectl"
fi

# 3. Создание кластера
log "Setting up cluster..."

# Удаляем старый кластер
log "Removing existing cluster..."
kind delete cluster || true

# Создаем новый кластер
log "Creating new cluster..."
kind create cluster --config kind-config.yaml

# Ждем готовности кластера
log "Waiting for cluster..."
kubectl wait --for=condition=ready node --all --timeout=90s

# 4. Установка Ingress
log "Setting up Ingress..."

# Устанавливаем NGINX Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Ждем готовности Ingress Controller
log "Waiting for Ingress Controller..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s

# 5. Деплой приложения
log "Deploying application..."

# Создаем namespace
kubectl create namespace app-namespace --dry-run=client -o yaml | kubectl apply -f -

# Собираем и загружаем образы
log "Building images..."
cd ../backend && docker build -t backend:latest .
cd ../frontend && docker build -t frontend:latest .
cd ../k8s

log "Loading images to kind..."
kind load docker-image backend:latest
kind load docker-image frontend:latest

# Применяем конфигурации
log "Applying configurations..."
kubectl apply -f configmap.yaml -n app-namespace
kubectl apply -f secret.yaml -n app-namespace
kubectl apply -f backend-deployment.yaml -n app-namespace
kubectl apply -f backend-service.yaml -n app-namespace
kubectl apply -f frontend-deployment.yaml -n app-namespace
kubectl apply -f frontend-service.yaml -n app-namespace
kubectl apply -f ingress.yaml -n app-namespace

# Ждем готовности подов
log "Waiting for pods..."
kubectl wait --for=condition=ready pod -l app=backend -n app-namespace --timeout=300s
kubectl wait --for=condition=ready pod -l app=frontend -n app-namespace --timeout=300s

# 6. Проверка работоспособности
log "Testing deployment..."

# Ждем готовности сервисов
sleep 10

# Проверяем доступность
log "Testing endpoints..."
curl -v --resolve app.local:8000:127.0.0.1 http://app.local:8000/api/health || true
curl -v --resolve app.local:8000:127.0.0.1 http://app.local:8000 || true

# Показываем статус
log "Deployment status:"
kubectl get all -n app-namespace
kubectl get ingress -n app-namespace

log "Deployment completed!"
echo "Access the application at:"
echo "- Frontend: http://app.local:8000"
echo "- Backend API: http://app.local:8000/api"
echo "- Health check: http://app.local:8000/api/health" 