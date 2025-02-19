#!/bin/bash

echo "Checking API server..."
kubectl cluster-info

echo "Checking API server endpoints..."
kubectl get --raw /api/v1/namespaces

echo "Checking API server health..."
curl -k https://localhost:6443/healthz

echo "Checking API server ports..."
sudo lsof -i :6443

echo "Checking kube config..."
kubectl config view 