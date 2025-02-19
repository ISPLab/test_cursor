#!/bin/bash

echo "Stopping all Docker containers..."
docker stop $(docker ps -a -q) || true

echo "Removing all Docker containers..."
docker rm $(docker ps -a -q) || true

echo "Removing kind cluster..."
kind delete cluster || true

echo "Killing processes on ports..."
sudo lsof -ti:80,443,6443,8080,3000 | xargs kill -9 || true

echo "Cleaning up Docker networks..."
docker network prune -f

echo "Cleaning up /etc/hosts..."
sudo sed -i.bak '/app.local/d' /etc/hosts

echo "Cleanup completed!" 