# Container Orchestration & Kubernetes

## GKE, EKS, AKS, Docker Swarm, Kubernetes & OpenShift

Container Orchestration automatically manages containerized applications across multiple machines. It handles deployment, scaling, networking, and self-healing.

The main container orchestration tools covered in this guide are:

* Kubernetes (open-source standard)
* GKE (Google Kubernetes Engine)
* EKS (Amazon Elastic Kubernetes Service)
* AKS (Azure Kubernetes Service)
* AWS ECS / Fargate (alternative)
* Docker Swarm (simpler alternative)
* OpenShift (Kubernetes distribution)

---

# 1. What Is Container Orchestration?

## Without Orchestration (Manual)

```text
Docker on single server:

docker run -d myapp:1.0
docker run -d myapp:1.0
docker run -d myapp:1.0

Problems:
├─ If server dies, all containers die
├─ Need to manually restart
├─ No load balancing
├─ Can't scale easily
├─ No rolling updates
├─ Can't manage secrets
├─ Network is manual
├─ Storage is manual
└─ Scaling is a nightmare
```

## With Orchestration (Kubernetes)

```text
Kubernetes cluster:

kubectl apply -f deployment.yaml

Kubernetes automatically:
├─ Schedules containers on nodes
├─ Ensures 3 replicas running
├─ Handles node failures
├─ Load balances traffic
├─ Scales up/down based on demand
├─ Rolls out updates zero-downtime
├─ Manages secrets securely
├─ Networks containers
├─ Manages storage
└─ Everything automated!
```

## Orchestration vs Single Server

```text
┌─────────────────────┬────────────────────────┬───────────────────────┐
│     Feature         │    Manual Docker       │    Kubernetes         │
├─────────────────────┼────────────────────────┼───────────────────────┤
│ Deployment          │ Manual docker run      │ Declarative YAML      │
│ Scaling             │ Manual (tedious)       │ Automatic (declarative)
│ Updates             │ Downtime required      │ Zero-downtime rolling │
│ Health checks       │ None                   │ Automatic self-healing│
│ Load balancing      │ Manual setup           │ Built-in              │
│ Networking          │ Port mapping           │ Pod networking        │
│ Storage             │ Manual volumes         │ Persistent volumes    │
│ Secrets             │ Environment vars       │ Secret objects        │
│ Multi-host          │ Manual coordination    │ Automatic             │
│ Rollback            │ Manual                 │ Automatic             │
│ Resource limits     │ None                   │ Built-in              │
│ High availability   │ Not guaranteed         │ Built-in              │
└─────────────────────┴────────────────────────┴───────────────────────┘
```

---

# 2. Quick Comparison: All 7 Tools

```text
┌──────────────┬──────────────┬──────────────┬──────────────┬──────────────┬──────────────┬──────────────┐
│   Feature    │ Kubernetes   │ GKE          │ EKS          │ AKS          │ ECS/Fargate  │ Docker Swarm │
├──────────────┼──────────────┼──────────────┼──────────────┼──────────────┼──────────────┼──────────────┤
│ Cost         │ FREE ✓       │ FREE (infra) │ FREE (infra) │ FREE (infra) │ Pay-per-use  │ FREE ✓       │
│ Learning     │ Medium       │ Medium       │ Medium       │ Medium       │ Easy         │ EASY ✓       │
│ Setup        │ Complex      │ Easy (GCP)   │ Easy (AWS)   │ Easy (Azure) │ Very easy    │ Very easy    │
│ Complexity   │ High         │ High         │ High         │ High         │ Low          │ Low          │
│ Scalability  │ Excellent    │ Excellent    │ Excellent    │ Excellent    │ Good         │ Limited      │
│ Features     │ Most ✓       │ Full K8s     │ Full K8s     │ Full K8s     │ Simplified   │ Basic        │
│ Multi-cloud  │ Yes ✓        │ GCP only     │ AWS only     │ Azure only   │ AWS only     │ Yes          │
│ Community    │ HUGE ✓       │ Large        │ Large        │ Large        │ Medium       │ Small        │
│ Job market   │ HIGHEST ✓    │ High         │ High         │ High         │ Medium       │ Low          │
│ Best for     │ Production   │ GCP users    │ AWS users    │ Azure users  │ Serverless   │ Learning     │
└──────────────┴──────────────┴──────────────┴──────────────┴──────────────┴──────────────┴──────────────┘

┌──────────────┬──────────────┐
│   Feature    │ OpenShift    │
├──────────────┼──────────────┤
│ Cost         │ Paid (Red Hat)
│ Learning     │ Hard         │
│ Setup        │ Complex      │
│ What is it   │ K8s + extras │
│ Best for     │ Enterprises  │
└──────────────┴──────────────┘
```

---

# 3. My Recommendation: Kubernetes

## Why Choose Kubernetes?

```text
KUBERNETES IS BEST FOR LEARNING BECAUSE:

✓ INDUSTRY STANDARD
  └── Used by 96% of companies
  └── Largest adoption
  └── De facto container orchestration platform

✓ PLATFORM AGNOSTIC
  └── Works on any cloud (AWS, GCP, Azure)
  └── Works on-premise
  └── Works on your laptop
  └── Skills transfer everywhere

✓ MOST POWERFUL
  └── Most features of any orchestrator
  └── Most flexible
  └── Can do anything
  └── Enterprise-grade

✓ LARGEST ECOSYSTEM
  └── 1000s of tools integrate
  └── Prometheus, Elasticsearch, Vault
  └── Service meshes (Istio)
  └── Ingress controllers
  └── All major companies support

✓ MOST JOB OPPORTUNITIES
  └── Every cloud job asks for K8s
  └── Most DevOps jobs require K8s
  └── Skills directly monetizable
  └── Highest salary correlation

✓ WORKS WITH YOUR STACK
  └── Deploy Docker containers
  └── Prometheus monitors K8s
  └── Elasticsearch collects pod logs
  └── Vault integrates with K8s auth
  └── GitHub Actions deploys to K8s

✓ PERFECT FOR LEARNING
  └── Free locally (minikube, kind)
  └── Start in 30 minutes
  └── Understand fundamentals
  └── Scale to production

ALTERNATIVE CONSIDERATIONS:

ECS/Fargate:
├── Better if: AWS-only serverless containers
├── Advantage: Simpler than K8s
└── Disadvantage: AWS-locked, less features

Docker Swarm:
├── Better if: Very simple use case
├── Advantage: Easiest to learn
└── Disadvantage: Dying, no job market

GKE/EKS/AKS:
├── Better if: Using specific cloud
├── Advantage: Cloud-integrated K8s
└── Still learning: Same as Kubernetes core
```

**FINAL ANSWER: Choose Kubernetes. Most powerful, most jobs, most skills transfer.**

---

# 4. Quick Overview: Cloud Kubernetes (GKE, EKS, AKS)

## GKE (Google Kubernetes Engine)

```bash
# Create GKE cluster
gcloud container clusters create my-cluster \
  --zone us-central1-a \
  --num-nodes 3 \
  --machine-type n1-standard-2

# Get credentials
gcloud container clusters get-credentials my-cluster \
  --zone us-central1-a

# Deploy app
kubectl apply -f deployment.yaml

# Pricing: Pay for nodes + GCP infra
```

**Pros:** Easiest K8s setup, Kubernetes creator maintains it
**Cons:** GCP-only, more expensive

## EKS (Amazon Elastic Kubernetes Service)

```bash
# Create EKS cluster
eksctl create cluster --name my-cluster \
  --region us-east-1 \
  --nodegroup-name standard-nodes \
  --node-type t2.medium \
  --nodes 3

# Deploy app
kubectl apply -f deployment.yaml

# Pricing: $0.10/hour cluster + node costs
```

**Pros:** AWS integration, large community
**Cons:** AWS-only, complex setup initially

## AKS (Azure Kubernetes Service)

```bash
# Create AKS cluster
az aks create --resource-group myResourceGroup \
  --name myAKSCluster \
  --node-count 3 \
  --vm-set-type VirtualMachineScaleSets

# Deploy app
kubectl apply -f deployment.yaml

# Pricing: Free cluster + node costs
```

**Pros:** Azure integration, free cluster control plane
**Cons:** Azure-only

---

# 5. Quick Overview: AWS ECS / Fargate

## What Is ECS/Fargate?

AWS-specific container orchestration. Simpler than Kubernetes but less powerful.

```yaml
# Task Definition (like Pod)
family: app
containers:
  - name: app
    image: myapp:1.0
    memory: 512
    portMappings:
      - containerPort: 3000

# Service (manage tasks)
serviceName: app-service
desiredCount: 3
launchType: FARGATE
```

## ECS vs Kubernetes

```text
ECS (AWS-only):
├── Simpler to learn (not K8s)
├── Less features
├── AWS-specific
├── Cheaper initially
└── Smaller community

Kubernetes:
├── More complex (worth it)
├── More features (you'll need them)
├── Works anywhere
├── Better long-term
└── Huge community
```

---

# 6. Quick Overview: Docker Swarm

## What Is Docker Swarm?

Simpler container orchestration built into Docker.

```bash
# Initialize swarm
docker swarm init

# Create service (like K8s deployment)
docker service create --name web \
  --replicas 3 \
  --publish 80:3000 \
  myapp:1.0

# Scale
docker service scale web=5
```

## Swarm vs Kubernetes

```text
Docker Swarm:
├── EASIEST to learn
├── Fewest features
├── Deprecated (dying)
└── No job market

Kubernetes:
├── Harder to learn (but worth it)
├── Most features
├── Growing fast
└── All jobs require it
```

---

# 7. Quick Overview: OpenShift

## What Is OpenShift?

Red Hat's Kubernetes distribution with extras.

```text
OpenShift = Kubernetes + Red Hat features
├── Web console
├── Developer tools
├── CI/CD integration
├── Advanced security
└── Enterprise support
```

## OpenShift vs Kubernetes

```text
OpenShift:
├── Paid (Red Hat)
├── Enterprise features
├── Complex setup
└── Enterprise-only

Kubernetes:
├── FREE
├── Works with any tools
├── Simpler to learn
└── Better for starting out
```

---

# 8. Kubernetes: Detailed Guide

Since Kubernetes is the best choice for you, here's the detailed guide.

## What Is Kubernetes?

Kubernetes is an open-source container orchestration platform. Automatically manages containerized applications at scale.

## Kubernetes Architecture

```text
┌────────────────────────────────────────────┐
│       KUBERNETES CLUSTER                   │
├────────────────────────────────────────────┤
│                                            │
│  CONTROL PLANE (Master)                   │
│  ├── API Server (REST interface)          │
│  ├── Scheduler (assign pods to nodes)     │
│  ├── Controller Manager (maintain state)  │
│  ├── etcd (database - stores all config)  │
│  └── Cloud Controller (cloud integration) │
│                                            │
├────────────────────────────────────────────┤
│                                            │
│  NODE 1 (Worker)                          │
│  ├── kubelet (node agent)                 │
│  ├── kube-proxy (networking)              │
│  └── Container Runtime (Docker/containerd)│
│      ├── Pod 1 (App container)            │
│      ├── Pod 2 (App container)            │
│      └── Pod 3 (App container)            │
│                                            │
│  NODE 2 (Worker)                          │
│  ├── kubelet                              │
│  ├── kube-proxy                           │
│  └── Container Runtime                    │
│      ├── Pod 4                            │
│      ├── Pod 5                            │
│      └── Pod 6                            │
│                                            │
│  NODE 3 (Worker)                          │
│  ├── kubelet                              │
│  ├── kube-proxy                           │
│  └── Container Runtime                    │
│      ├── Pod 7                            │
│      ├── Pod 8                            │
│      └── Pod 9                            │
│                                            │
└────────────────────────────────────────────┘

ETCD Database stores:
├── Deployment configs
├── Service definitions
├── Secrets
├── ConfigMaps
└── Entire cluster state
```

## Kubernetes Core Concepts

```text
POD:              Smallest deployable unit (container wrapper)
DEPLOYMENT:       Manages replicas of pods
SERVICE:          Network endpoint for pods
INGRESS:          External HTTP/HTTPS routing
NAMESPACE:        Logical cluster partition
CONFIGMAP:        Non-secret configuration
SECRET:           Encrypted configuration
VOLUME:           Storage for pods
PERSISTENT VOLUME: Durable storage across pod restarts
NETWORK POLICY:   Firewall rules for pods
RBAC:             Role-based access control
```

---

# 9. Installing Kubernetes

## Local Kubernetes (Learning)

### Minikube

```bash
# Install Minikube
brew install minikube

# Start cluster
minikube start --cpus 4 --memory 8192

# Verify
kubectl get nodes
kubectl get pods --all-namespaces

# Access Minikube IP
minikube ip

# Stop
minikube stop
```

### Kind (Kubernetes in Docker)

```bash
# Install Kind
brew install kind

# Create cluster
kind create cluster --name dev

# Delete cluster
kind delete cluster --name dev
```

### Docker Desktop Kubernetes

```bash
# Enable Kubernetes in Docker Desktop:
# Settings → Kubernetes → Enable Kubernetes

# Verify
kubectl get nodes
```

## Production Kubernetes (EKS Example)

```bash
# Install eksctl
brew tap weaveworks/tap
brew install weaveworks/tap/eksctl

# Create cluster
eksctl create cluster --name prod \
  --region us-east-1 \
  --nodegroup-name standard-nodes \
  --node-type t3.medium \
  --nodes 3

# Get kubeconfig
eksctl utils write-kubeconfig \
  --cluster prod \
  --region us-east-1

# Verify
kubectl get nodes
```

---

# 10. Kubernetes Objects: YAML Configuration

## Pod (Simplest Unit)

```yaml
# pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
  labels:
    app: myapp
spec:
  containers:
  - name: app
    image: myapp:1.0
    ports:
    - containerPort: 3000
    env:
    - name: DATABASE_URL
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: url
    resources:
      requests:
        memory: "64Mi"
        cpu: "100m"
      limits:
        memory: "512Mi"
        cpu: "500m"

# Deploy it
kubectl apply -f pod.yaml
kubectl get pods
kubectl logs app-pod
kubectl delete pod app-pod
```

## Deployment (Manage Replicas)

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-deployment
  labels:
    app: myapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: app
        image: myapp:1.0
        ports:
        - containerPort: 3000
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - myapp
              topologyKey: kubernetes.io/hostname

# Deploy
kubectl apply -f deployment.yaml
kubectl get deployment
kubectl rollout status deployment/app-deployment
kubectl scale deployment app-deployment --replicas 5
kubectl set image deployment/app-deployment app=myapp:2.0
kubectl rollout undo deployment/app-deployment
```

## Service (Network Endpoint)

```yaml
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: app-service
spec:
  type: LoadBalancer
  selector:
    app: myapp
  ports:
  - protocol: TCP
    port: 80
    targetPort: 3000
  sessionAffinity: ClientIP

# Deploy
kubectl apply -f service.yaml
kubectl get service
kubectl describe service app-service
```

## ConfigMap & Secret (Configuration)

```yaml
# configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  LOG_LEVEL: "info"
  ENVIRONMENT: "production"

---
# secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
stringData:
  DATABASE_URL: "postgresql://user:pass@db.example.com/mydb"
  DATABASE_PASSWORD: "super-secret-password"

# Use in Pod
spec:
  containers:
  - name: app
    envFrom:
    - configMapRef:
        name: app-config
    - secretRef:
        name: db-secret
```

## Ingress (HTTP Routing)

```yaml
# ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - example.com
    secretName: app-tls-cert
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app-service
            port:
              number: 80

# Deploy
kubectl apply -f ingress.yaml
kubectl get ingress
```

---

# 11. Helm (Package Manager for Kubernetes)

Helm is the package manager for Kubernetes. Simplifies deployments.

## Install Helm

```bash
# macOS
brew install helm

# Verify
helm version
```

## Using Helm Charts

```bash
# Search for charts
helm search repo bitnami | grep nginx

# Install a chart
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-release bitnami/nginx

# List releases
helm list

# Upgrade
helm upgrade my-release bitnami/nginx --version 10.0.0

# Uninstall
helm uninstall my-release
```

## Create Your Own Helm Chart

```bash
# Generate chart
helm create mychart

# Chart structure
mychart/
├── Chart.yaml              # Chart metadata
├── values.yaml             # Default values
├── templates/
│   ├── deployment.yaml    # Deployment template
│   ├── service.yaml       # Service template
│   └── ingress.yaml       # Ingress template
└── charts/                # Dependencies

# Install chart
helm install my-app ./mychart \
  --values values-prod.yaml

# Template rendering (see generated YAML)
helm template my-app ./mychart
```

## Helm Values (Configuration)

```yaml
# values.yaml
image:
  repository: myapp
  tag: 1.0
  pullPolicy: IfNotPresent

replicaCount: 3

service:
  type: LoadBalancer
  port: 80
  targetPort: 3000

ingress:
  enabled: true
  hostname: example.com

resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "512Mi"
    cpu: "500m"

# Override values
helm install my-app ./mychart \
  --set replicaCount=5 \
  --set image.tag=2.0
```

---

# 12. Monitoring Kubernetes

## Prometheus in Kubernetes

```yaml
# Install Prometheus using Helm
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack

# Access Prometheus
kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090

# Query K8s metrics
# container_cpu_usage_seconds_total
# container_memory_usage_bytes
# node_cpu_seconds_total
```

## Elasticsearch in Kubernetes

```yaml
# Collect pod logs
helm repo add elastic https://helm.elastic.co
helm install elasticsearch elastic/elasticsearch
helm install kibana elastic/kibana

# Filebeat collects pod logs
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: filebeat
spec:
  selector:
    matchLabels:
      app: filebeat
  template:
    metadata:
      labels:
        app: filebeat
    spec:
      containers:
      - name: filebeat
        image: docker.elastic.co/beats/filebeat:8.9.0
        volumeMounts:
        - name: varlog
          mountPath: /var/log
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers
```

---

# 13. Kubernetes Best Practices

```text
DEPLOYMENT BEST PRACTICES:

DO:
✓ Use Deployments, not Pods directly
✓ Set resource requests & limits
✓ Use health checks (liveness, readiness)
✓ Use namespaces for isolation
✓ Use RBAC for access control
✓ Use NetworkPolicies for security
✓ Use PodDisruptionBudgets for HA
✓ Monitor with Prometheus
✓ Log with Elasticsearch/Loki
✓ Use health probes
✓ Implement graceful shutdown
✓ Use StatefulSets for databases
✓ Use Jobs for batch processing
✓ Use CronJobs for scheduled tasks
✓ Configure pod disruption budgets

DON'T:
✗ Use latest tag (specify versions)
✗ Run as root user
✗ Store secrets in code
✗ Use default namespace
✗ Deploy without resource limits
✗ Skip health checks
✗ Use host networking
✗ Mount node directories
✗ Hardcode configuration
✗ Ignore pod security policies
```

## Security Best Practices

```yaml
# Secure Pod configuration
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 2000
  containers:
  - name: app
    image: myapp:1.0
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
    resources:
      requests:
        memory: "128Mi"
        cpu: "100m"
      limits:
        memory: "512Mi"
        cpu: "500m"
    volumeMounts:
    - name: tmp
      mountPath: /tmp
  volumes:
  - name: tmp
    emptyDir: {}
```

---

# 14. Integration: Blog Application on Kubernetes

## Blog App Deployment

```yaml
# blog-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: blog-app
  labels:
    app: blog
spec:
  replicas: 3
  selector:
    matchLabels:
      app: blog
  template:
    metadata:
      labels:
        app: blog
    spec:
      containers:
      - name: app
        image: ghcr.io/myuser/blog-app:1.0
        ports:
        - containerPort: 3000
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: blog-secrets
              key: database-url
        - name: LOG_LEVEL
          valueFrom:
            configMapKeyRef:
              name: blog-config
              key: log-level
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - blog
              topologyKey: kubernetes.io/hostname

---
# blog-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: blog-service
spec:
  type: LoadBalancer
  selector:
    app: blog
  ports:
  - protocol: TCP
    port: 80
    targetPort: 3000

---
# blog-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: blog-ingress
spec:
  ingressClassName: nginx
  rules:
  - host: blog.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: blog-service
            port:
              number: 80
```

## Deploy Blog App

```bash
# Create secrets
kubectl create secret generic blog-secrets \
  --from-literal=database-url="postgresql://user:pass@db:5432/blog"

# Create configmap
kubectl create configmap blog-config \
  --from-literal=log-level=info

# Deploy
kubectl apply -f blog-deployment.yaml

# Scale
kubectl scale deployment blog-app --replicas 5

# Update image
kubectl set image deployment/blog-app \
  app=ghcr.io/myuser/blog-app:2.0

# Check status
kubectl get deployment
kubectl get pods
kubectl logs -f deployment/blog-app

# Expose via Ingress
kubectl apply -f blog-ingress.yaml
```

---

# 15. Learning Path for Kubernetes

## Week 1: Fundamentals

```text
DAY 1:
├── Install minikube
├── Start local cluster
├── kubectl basics (get, describe, logs)
└── First pod

DAY 2:
├── Learn Deployment
├── Create replicas
├── Scale deployments
└── Rolling updates

DAY 3:
├── Services (networking)
├── Ingress (HTTP routing)
├── DNS & service discovery
└── Port forwarding

DAY 4-5:
├── ConfigMap & Secrets
├── Volume mounts
├── Health checks
└── Project: Deploy simple app
```

## Week 2: Advanced

```text
DAY 6-7:
├── Namespaces
├── RBAC (access control)
├── Network policies
├── Resource quotas

DAY 8-9:
├── StatefulSets
├── DaemonSets
├── Jobs & CronJobs
├── Helm basics

DAY 10-12:
├── Persistent volumes
├── Storage classes
├── Monitoring with Prometheus
├── Logging with Elasticsearch
└── Project: Full stack deployment
```

## Week 3: Production

```text
DAY 13-14:
├── High availability
├── Multi-region
├── Disaster recovery
├── Performance tuning

DAY 15:
├── Production best practices
├── Security hardening
├── Team runbooks
└── Production ready!
```

## Project Ideas

```text
PROJECT 1 (Week 1):
└── Deploy app with 3 replicas locally

PROJECT 2 (Week 2):
├── Multi-container app
├── Database persistence
├── ConfigMaps & Secrets
└── Ingress routing

PROJECT 3 (Week 2-3):
├── Blog application on K8s
├── Monitoring (Prometheus)
├── Logging (Elasticsearch)
├── HA setup

PROJECT 4 (Week 3):
├── Production cluster (EKS/GKE)
├── Auto-scaling
├── Multi-environment
└── GitOps with ArgoCD
```

---

# 16. Kubernetes vs Alternatives

```text
SCENARIO: Container orchestration for learning

Kubernetes:
├── Most features
├── Most jobs
├── Most skills transfer
└── BEST ✓✓✓

ECS/Fargate:
├── Simpler than K8s
├── AWS-only
└── Less job market

Docker Swarm:
├── Easiest to learn
├── Deprecated
└── No job market

─────────────────────────────

SCENARIO: Speed to production

ECS/Fargate:
├── Fastest (least config)
└── If AWS-only

Kubernetes:
├── Initial setup harder
├── But worth long-term
└── Better for scale

─────────────────────────────

SCENARIO: Job opportunities

Kubernetes:
├── 96% job requirement
├── Highest salary
├── Most versatile
└── BEST ✓✓✓

ECS: Some AWS jobs
Swarm: Nearly gone
```

---

# 17. Quick Reference: kubectl Commands

```bash
# Cluster info
kubectl version
kubectl cluster-info
kubectl get nodes
kubectl describe node node-name

# Namespaces
kubectl get namespaces
kubectl create namespace prod
kubectl config set-context --current --namespace=prod

# Pods
kubectl get pods
kubectl describe pod pod-name
kubectl logs pod-name
kubectl logs -f pod-name               # Follow logs
kubectl exec -it pod-name -- /bin/bash # Shell into pod
kubectl delete pod pod-name

# Deployments
kubectl get deployment
kubectl describe deployment deploy-name
kubectl scale deployment deploy-name --replicas=5
kubectl set image deployment/deploy-name app=image:tag
kubectl rollout status deployment/deploy-name
kubectl rollout undo deployment/deploy-name

# Services
kubectl get service
kubectl describe service service-name
kubectl port-forward svc/service-name 8080:80

# ConfigMaps & Secrets
kubectl create configmap name --from-literal=key=value
kubectl create secret generic name --from-literal=key=value
kubectl get configmap
kubectl get secret

# Apply configurations
kubectl apply -f file.yaml
kubectl apply -f directory/
kubectl delete -f file.yaml

# Debugging
kubectl get events
kubectl describe pod pod-name
kubectl logs pod-name
kubectl top nodes
kubectl top pods

# Labels & selectors
kubectl get pods -l app=myapp
kubectl label pod pod-name app=newapp
```

---

# Summary: Container Orchestration Decision

```
┌─────────────────────────────────────────┐
│                                         │
│  ✓ CHOICE: KUBERNETES                  │
│  ✓ COST: FREE ✓                        │
│  ✓ LEARNING TIME: 2-3 weeks            │
│  ✓ POWER: Most powerful platform       │
│  ✓ CAREER VALUE: Highest in market     │
│  ✓ START: Today with minikube          │
│                                         │
│  WHY KUBERNETES:                       │
│  ├─ Industry standard (96% usage)      │
│  ├─ Largest community & ecosystem      │
│  ├─ Works anywhere (cloud, on-prem)    │
│  ├─ Most job opportunities             │
│  ├─ Most features                      │
│  └─ Skills transfer everywhere         │
│                                         │
│  INTEGRATED WITH STACK:                │
│  ├─ Deploy: GitHub Actions             │
│  ├─ Secrets: Vault integration         │
│  ├─ Monitoring: Prometheus             │
│  ├─ Logging: Elasticsearch             │
│  ├─ Traffic: Ingress (nginx)           │
│  └─ Package: Helm                      │
│                                         │
└─────────────────────────────────────────┘
```

---

# Final Complete Learning Stack

```
1. ✅ cloud-serverless.md
   └─ WHERE to deploy (Vercel/Cloudflare)

2. ✅ provisioning.md
   └─ WHAT to provision (Terraform)

3. ✅ configuration-management.md
   └─ HOW to configure (Ansible)

4. ✅ ci-cd-tools.md
   └─ HOW to automate (GitHub Actions)

5. ✅ secret-management.md
   └─ HOW to secure (Vault)

6. ✅ infrastructure-monitoring.md
   └─ HOW to monitor metrics (Prometheus)

7. ✅ logs-management.md
   └─ HOW to aggregate logs (Elastic)

8. ✅ container-orchestration.md ← YOU ARE HERE
   └─ HOW to orchestrate containers (Kubernetes)

9. ✅ integrated-devops-project.md
   └─ HOW it ALL WORKS (blog application)

═══════════════════════════════════════════

COMPLETE ENTERPRISE DEVOPS MASTERY:
├─ Serverless deployments (Vercel)
├─ Cloud infrastructure (Terraform)
├─ Server configuration (Ansible)
├─ Continuous integration (GitHub Actions)
├─ Secret management (Vault)
├─ Metrics monitoring (Prometheus)
├─ Log aggregation (Elasticsearch)
├─ Container orchestration (Kubernetes)
└─ ALL INTEGRATED & PRODUCTION-READY! 🚀
```

---

# Resources & Learning

## Official Resources

- [Kubernetes Official Docs](https://kubernetes.io/docs)
- [Kubernetes API Reference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.27)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Helm Official Docs](https://helm.sh/docs/)

## Learning Resources

- [Kubernetes Interactive Tutorial](https://kubernetes.io/docs/tutorials)
- [Play with Kubernetes](https://labs.play-with-k8s.com/)
- [Minikube Getting Started](https://minikube.sigs.k8s.io/docs/start/)
- [Kubernetes for Developers](https://www.kubernetes.dev/)

## Community

- [Kubernetes Community](https://kubernetes.io/community/)
- [Kubernetes Slack](https://slack.k8s.io/)
- [Stack Overflow #kubernetes](https://stackoverflow.com/questions/tagged/kubernetes)
- [Kubernetes GitHub](https://github.com/kubernetes)

---

**Last Updated:** August 24, 2026
**Curated for:** DevOps Learning Path
**Integration:** Works with ALL previous lessons
**Recommendation:** Choose Kubernetes & start today!
**Perfect for:** Your complete DevOps mastery journey!
