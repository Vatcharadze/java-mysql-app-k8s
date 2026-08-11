#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo "Starting Kubernetes cleanup..."

echo "Deleting Ingress..."
kubectl delete -f java-k8s/java-mysql-app-ingress.yaml --ignore-not-found=true

echo "Deleting PHP Deployment..."
kubectl delete -f mysql-k8s/php-deployment.yaml --ignore-not-found=true

echo "Deleting Java Deployment..."
kubectl delete -f java-k8s/java-deployment.yaml --ignore-not-found=true

echo "Deleting Java App Secret..."
kubectl delete -f java-k8s/java-secret.yaml --ignore-not-found=true

echo "Deleting MySQL Deployment..."
kubectl delete -f mysql-k8s/mysql-deployment.yaml --ignore-not-found=true

echo "Deleting ConfigMap..."
kubectl delete -f mysql-k8s/db-configmap.yaml --ignore-not-found=true

echo "Deleting MySQL Persistent Volume Claim..."
kubectl delete -f mysql-k8s/mysql-pvc.yaml --ignore-not-found=true

echo "Deleting MySQL Secret..."
kubectl delete -f mysql-k8s/mysql-secret.yaml --ignore-not-found=true

echo -e "${GREEN}Cleanup Complete!${NC}"