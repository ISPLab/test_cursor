#!/bin/bash

echo "Checking Ingress Controller status..."
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx

echo -e "\nChecking Ingress resources..."
kubectl get ingress -n app-namespace
kubectl describe ingress app-ingress -n app-namespace

echo -e "\nChecking endpoints..."
kubectl get endpoints -n app-namespace

echo -e "\nChecking Ingress Controller logs..."
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller

echo -e "\nTesting connectivity..."
curl -v http://app.local 