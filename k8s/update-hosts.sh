#!/bin/bash

# Получаем IP адрес control-plane ноды
KIND_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' kind-control-plane)

if [ -n "$KIND_IP" ]; then
    echo "Kind cluster IP: $KIND_IP"
    
    # Очищаем DNS кэш
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sudo dscacheutil -flushcache
        sudo killall -HUP mDNSResponder
    else
        sudo systemd-resolve --flush-caches || true
    fi
    
    # Удаляем все записи с app.local
    sudo sed -i.bak '/app.local/d' /etc/hosts
    
    # Добавляем новую запись
    echo "127.0.0.1 app.local # Port 8000" | sudo tee -a /etc/hosts
    
    echo "Updated /etc/hosts with: 127.0.0.1 app.local # Port 8000"
    
    # Ждем обновления DNS
    sleep 5
    
    echo "Testing connection..."
    echo "Resolving app.local..."
    dig app.local +short
    
    echo "Testing HTTP connection..."
    curl -v http://app.local
else
    echo "Error: Could not get kind cluster IP"
    exit 1
fi 