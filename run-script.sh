#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

read -p "Do you want to start Minikube? (y/n): " answer

if [ "$answer" = "y" ]; then
    echo "Starting Minikube..."
    minikube start
fi

echo "Applying Kubernetes files..."

echo "Creating MySQL Secret..."
kubectl apply -f mysql-k8s/mysql-secret.yaml

echo "Creating MySQL Persistent Volume..."
kubectl apply -f mysql-k8s/mysql-pvc.yaml

echo "Creating ConfigMap..."
kubectl apply -f mysql-k8s/db-configmap.yaml

echo "Creating MySQL Deployment..."
kubectl apply -f mysql-k8s/mysql-deployment.yaml

echo "Creating Java App Secret..."
kubectl apply -f java-k8s/java-secret.yaml

echo "Creating Java Deployment..."
kubectl apply -f java-k8s/java-deployment.yaml

echo "Creating PHP Deployment..."
kubectl apply -f mysql-k8s/php-deployment.yaml

echo "Creating Ingress..."
kubectl apply -f java-k8s/java-mysql-app-ingress.yaml

echo -e "${GREEN}Deployment completed successfully!${NC}"