#!/bin/bash

# Функция для логирования
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Проверяем статус Docker
log "Checking Docker status..."
if ! docker info > /dev/null 2>&1; then
    log "Docker is not running. Attempting to start..."
    
    # Для macOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        log "Starting Docker Desktop..."
        open -a Docker
        
        # Ждем запуска Docker
        log "Waiting for Docker to start..."
        for i in {1..30}; do
            if docker info > /dev/null 2>&1; then
                log "Docker is now running!"
                break
            fi
            log "Still waiting... ($i/30)"
            sleep 2
        done
    else
        log "Please start Docker manually and try again"
        exit 1
    fi
fi

# Проверяем еще раз
if ! docker info > /dev/null 2>&1; then
    log "Failed to start Docker. Please start Docker Desktop manually"
    exit 1
fi

log "Docker is running properly"
docker version
docker info 