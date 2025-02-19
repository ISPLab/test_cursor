#!/bin/bash

echo "Checking Docker network..."
docker network ls
docker network inspect kind

echo "Checking container status..."
docker ps -a | grep kind

echo "Checking container IP and ports..."
docker inspect kind-control-plane | grep -A 20 "NetworkSettings"

echo "Checking ingress controller status..."
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx

echo "Checking ingress controller logs..."
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller

echo "Checking host network..."
netstat -tulpn | grep -E ':80|:443'

echo "Testing connection..."
curl -v --max-time 5 http://localhost/api/health
curl -v --max-time 5 http://app.local/api/health 