# java-mysql-app-k8s

Kubernetes manifests and helper scripts for deploying a **Java (Spring Boot) application** backed by a **MySQL** database, with **phpMyAdmin** included for easy database administration. Everything is designed to run locally on **Minikube**.

## Architecture

```
                        ┌─────────────────────────┐
   Ingress (nginx) ───▶ │  java-mysql-app-service │ ───▶ Java App (3 replicas)
   java-mysql-app.com   │        :8080             │      port 8080
                        └─────────────────────────┘
                                     │
                                     ▼
                        ┌─────────────────────────┐
                        │      mysql-service       │ ───▶ MySQL 8.0 Pod
                        │        :3306              │      (persistent storage)
                        └─────────────────────────┘
                                     ▲
                                     │
                        ┌─────────────────────────┐
                        │   phpmyadmin-service      │ ───▶ phpMyAdmin Pod
                        │        :8081               │      (port 80 internally)
                        └─────────────────────────┘
```

- **Java App** – Spring Boot application (`vatcharadze/java-kubernetes:1.0.0`) that connects to MySQL using credentials injected from a Kubernetes `Secret` and a `ConfigMap`.
- **MySQL** – `mysql:8.0` with a `PersistentVolumeClaim` for durable storage.
- **phpMyAdmin** – Web UI for browsing/administering the MySQL database.
- **Ingress** – Routes external traffic to the Java app via the `nginx` ingress controller.

## Repository structure

```
java-mysql-app-k8s/
├── java-k8s/
│   ├── java-deployment.yaml          # Deployment + Service for the Java app
│   ├── java-mysql-app-ingress.yaml   # Ingress exposing the Java app
│   └── java-secret.yaml              # DB credentials consumed by the Java app
├── mysql-k8s/
│   ├── db-configmap.yaml             # DB server hostname (used by app + phpMyAdmin)
│   ├── mysql-deployment.yaml         # Deployment + Service for MySQL
│   ├── mysql-pvc.yaml                # PersistentVolumeClaim for MySQL storage
│   ├── mysql-secret.yaml             # MySQL root/user credentials
│   └── php-deployment.yaml           # Deployment + Service for phpMyAdmin
├── run-script.sh                     # Applies all manifests (optionally starts Minikube)
└── cleanup.sh                        # Deletes all deployed resources
```

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Minikube](https://minikube.sigs.k8s.io/docs/start/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- The nginx Ingress addon (`minikube addons enable ingress`) if you want to use the Ingress resource

## Getting started

### 1. Start Minikube (if not already running)

```bash
minikube start
minikube addons enable ingress
```

### 2. Deploy the stack

The easiest way is to run the helper script, which optionally starts Minikube and applies all manifests in the correct order:

```bash
chmod +x run-script.sh
./run-script.sh
```

You'll be prompted whether to start Minikube; then it applies, in order:

1. `mysql-k8s/mysql-secret.yaml`
2. `mysql-k8s/mysql-pvc.yaml`
3. `mysql-k8s/db-configmap.yaml`
4. `mysql-k8s/mysql-deployment.yaml`
5. `java-k8s/java-secret.yaml`
6. `java-k8s/java-deployment.yaml`
7. `mysql-k8s/php-deployment.yaml`
8. `java-k8s/java-mysql-app-ingress.yaml`

**Or apply manifests manually**, in the same order:

```bash
# MySQL secret, storage, and config
kubectl apply -f mysql-k8s/mysql-secret.yaml
kubectl apply -f mysql-k8s/mysql-pvc.yaml
kubectl apply -f mysql-k8s/db-configmap.yaml
kubectl apply -f mysql-k8s/mysql-deployment.yaml

# Java app secret and deployment
kubectl apply -f java-k8s/java-secret.yaml
kubectl apply -f java-k8s/java-deployment.yaml

# phpMyAdmin
kubectl apply -f mysql-k8s/php-deployment.yaml

# Ingress
kubectl apply -f java-k8s/java-mysql-app-ingress.yaml
```

### 3. Check the deployment

```bash
kubectl get pods
kubectl get svc
kubectl get ingress
```

### 4. Access the services

**Java app** (via Ingress):

```bash
echo "$(minikube ip) java-mysql-app.com" | sudo tee -a /etc/hosts
curl http://java-mysql-app.com/
```

**phpMyAdmin** (via service port-forward, since it isn't in the Ingress):

```bash
kubectl port-forward svc/phpmyadmin-service 8081:8081
```

Then open `http://localhost:8081` and log in with the MySQL credentials from `mysql-k8s/mysql-secret.yaml` (server: `mysql-service`).

**MySQL** (direct access for debugging):

```bash
kubectl port-forward svc/mysql-service 3306:3306
```

## Configuration

| Resource | Key | Value / Source |
|---|---|---|
| `mysql-secret` | `MYSQL_ROOT_PASSWORD` | `password` |
| `mysql-secret` | `MYSQL_DATABASE` | `my-app-db` |
| `mysql-secret` | `MYSQL_USER` | `user` |
| `mysql-secret` | `MYSQL_PASSWORD` | `my-pass` |
| `java-secret` | `db_user`, `db_pwd`, `db_name`, `db_root_pwd` | base64-encoded, decode with `echo <value> | base64 -d` |
| `db-config` (ConfigMap) | `db-server` | `mysql-service` |

⚠️ **These are default/example credentials meant for local development only.** Replace them with your own values (and use a proper secrets manager) before using this in any shared or production environment.

## Scaling

The Java app deployment runs 3 replicas by default:

```bash
kubectl scale deployment/java-mysql-app-deployment --replicas=5
```

## Cleanup

Remove all deployed resources with:

```bash
chmod +x cleanup.sh
./cleanup.sh
```

Or manually:

```bash
kubectl delete -f java-k8s/java-mysql-app-ingress.yaml
kubectl delete -f mysql-k8s/php-deployment.yaml
kubectl delete -f java-k8s/java-deployment.yaml
kubectl delete -f java-k8s/java-secret.yaml
kubectl delete -f mysql-k8s/mysql-deployment.yaml
kubectl delete -f mysql-k8s/db-configmap.yaml
kubectl delete -f mysql-k8s/mysql-pvc.yaml
kubectl delete -f mysql-k8s/mysql-secret.yaml
```

## License

No license file is currently included in this repository. Add one (e.g. MIT, Apache-2.0) if you intend for others to reuse this code.