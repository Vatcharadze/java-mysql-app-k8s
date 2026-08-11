#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo "Starting Kubernetes cleanup..."

echo "Deleting Ingress..."
kubectl delete -f app/java-mysql-app-ingress.yaml --ignore-not-found=true

echo "Deleting PHP Deployment..."
kubectl delete -f mysql/php-deployment.yaml --ignore-not-found=true

echo "Deleting Java Deployment..."
kubectl delete -f app/java-deployment.yaml --ignore-not-found=true

echo "Deleting Java App Secret..."
kubectl delete -f app/java-secret.yaml --ignore-not-found=true

echo "Deleting MySQL Deployment..."
kubectl delete -f mysql/mysql-deployment.yaml --ignore-not-found=true

echo "Deleting ConfigMap..."
kubectl delete -f mysql/db-configmap.yaml --ignore-not-found=true

echo "Deleting MySQL Persistent Volume Claim..."
kubectl delete -f mysql/mysql-pvc.yaml --ignore-not-found=true

echo "Deleting MySQL Secret..."
kubectl delete -f mysql/mysql-secret.yaml --ignore-not-found=true

echo -e "${GREEN}Cleanup Complete!${NC}"