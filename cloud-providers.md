# Cloud Providers

## AWS, Google Cloud, Azure & Vultr

Cloud computing allows you to rent computing infrastructure over the Internet instead of buying and maintaining physical servers yourself.

The major cloud providers covered in this guide are:

* AWS
* Google Cloud
* Microsoft Azure
* Vultr

---

# 1. What Is Cloud Computing?

Without cloud computing:

```text
Your Company
     │
     ▼
Buy Physical Server
     │
     ├── CPU
     ├── RAM
     ├── Storage
     ├── Network
     └── Electricity
```

You must manage everything yourself.

With cloud computing:

```text
Your Company
     │
     │ Internet
     ▼
Cloud Provider
     │
     ▼
Virtual Server
```

You rent infrastructure from the cloud provider.

---

# 2. What Can You Rent From a Cloud Provider?

Cloud providers offer many different services.

For example:

```text
Compute
   ↓
Virtual Machines

Storage
   ↓
Files / Disks / Objects

Networking
   ↓
IP / DNS / Load Balancer / Firewall

Database
   ↓
PostgreSQL / MySQL / etc.

Containers
   ↓
Container Platforms

Kubernetes
   ↓
Container Orchestration

Monitoring
   ↓
Logs / Metrics / Alerts
```

---

# 3. The Four Cloud Providers

The providers in this learning path:

```text
                 CLOUD
                   │
       ┌───────────┼───────────┐
       │           │           │
       ▼           ▼           ▼
      AWS       Google Cloud  Azure
       │
       │
       └────────── Vultr
```

### AWS

Amazon Web Services.

One of the largest cloud platforms.

### Google Cloud

Google's cloud platform.

Strong in areas such as:

* Kubernetes
* Data
* AI/ML
* Networking

### Azure

Microsoft's cloud platform.

Strong integration with:

* Microsoft ecosystem
* Windows Server
* Active Directory / Entra ID
* Enterprise systems

### Vultr

A cloud infrastructure provider focused heavily on straightforward:

* Virtual machines
* Bare metal
* Block storage
* Networking
* Kubernetes
* Managed services

For your current DevOps learning, **Vultr is a perfectly good place to practise Linux, networking, Docker, reverse proxies, databases, and CI/CD.**

---

# 4. IaaS, PaaS and SaaS

These three concepts are very important in cloud computing.

## IaaS

Infrastructure as a Service.

You manage most of the operating system and application stack.

```text
Cloud Provider
    │
    ├── Physical Hardware
    ├── Networking
    └── Virtualization
             │
             ▼
          You manage
             │
             ├── OS
             ├── Docker
             ├── Application
             └── Configuration
```

Examples:

```text
AWS EC2
Google Compute Engine
Azure Virtual Machines
Vultr Cloud Compute
```

---

## PaaS

Platform as a Service.

The provider manages more of the infrastructure for you.

```text
Provider
   │
   ├── Hardware
   ├── OS
   ├── Runtime
   └── Infrastructure
          │
          ▼
        You
          │
          ▼
      Application
```

You focus more on the application.

---

## SaaS

Software as a Service.

You simply use the software.

Examples:

```text
Gmail
GitHub
Microsoft 365
Slack
```

You don't manage the underlying servers.

---

# 5. Cloud Shared Responsibility

A very important cloud concept is:

> You and the cloud provider share responsibility for security and operations.

For example, with a virtual machine:

```text
Cloud Provider
    │
    ├── Physical Data Center
    ├── Physical Server
    ├── Networking Hardware
    └── Virtualization
             │
             ▼
           You
             │
             ├── OS updates
             ├── SSH security
             ├── Firewall
             ├── Application
             ├── Docker
             └── Application data
```

The exact responsibility depends on the service you're using.

---

# 6. Cloud Region

A region is a geographic area containing cloud infrastructure.

For example:

```text
Asia
 ├── Singapore
 ├── Tokyo
 └── Other regions
```

A cloud provider may have many regions around the world.

You choose a region when creating infrastructure.

---

# 7. Why Does Region Matter?

Suppose your users are primarily in Cambodia.

You generally want infrastructure reasonably close to your users.

```text
Cambodia Users
      │
      ▼
Nearby Cloud Region
      │
      ▼
Lower network latency
```

If you deploy extremely far away:

```text
Cambodia
    │
    │ Long network path
    ▼
US Server
```

latency can be higher.

Region selection can affect:

* Latency
* Availability
* Pricing
* Data residency
* Service availability

---

# 8. Availability Zone

Some cloud providers divide regions into availability zones.

Conceptually:

```text
Region
│
├── Availability Zone A
│
├── Availability Zone B
│
└── Availability Zone C
```

These help build highly available systems.

For example:

```text
                 Region
                   │
        ┌──────────┼──────────┐
        ▼          ▼          ▼
       AZ-A       AZ-B       AZ-C
        │          │          │
      Server     Server     Server
```

If one zone has a problem, another zone may continue serving traffic.

---

# 9. Virtual Machine

One of the first cloud services you should learn is the VM.

A VM is a virtual computer running in the cloud.

```text
Cloud
  │
  ▼
Virtual Machine
  │
  ├── CPU
  ├── RAM
  ├── Disk
  ├── Network
  └── Operating System
```

For DevOps, you will frequently use:

```text
Ubuntu
Docker
Nginx
Git
SSH
CI/CD
```

inside a VM.

---

# 10. Cloud VM Comparison

The service names differ between providers.

| Concept            | AWS                    | Google Cloud         | Azure                    | Vultr                   |
| ------------------ | ---------------------- | -------------------- | ------------------------ | ----------------------- |
| Virtual Machine    | EC2                    | Compute Engine       | Virtual Machines         | Cloud Compute           |
| Object Storage     | S3                     | Cloud Storage        | Blob Storage             | Object Storage          |
| Kubernetes         | EKS                    | GKE                  | AKS                      | Vultr Kubernetes Engine |
| Managed Database   | RDS                    | Cloud SQL            | Azure Database services  | Managed Databases       |
| Load Balancer      | Elastic Load Balancing | Cloud Load Balancing | Azure Load Balancer      | Load Balancers          |
| DNS                | Route 53               | Cloud DNS            | Azure DNS                | DNS                     |
| Container Registry | ECR                    | Artifact Registry    | Azure Container Registry | Container Registry      |
| Monitoring         | CloudWatch             | Cloud Monitoring     | Azure Monitor            | Monitoring              |

The names differ, but the underlying concepts are similar.

---

# 11. AWS EC2

AWS's main virtual machine service is:

```text
EC2
```

Conceptually:

```text
AWS
 │
 ▼
EC2
 │
 ├── CPU
 ├── RAM
 ├── Disk
 ├── Network
 └── OS
```

You can install:

```text
Ubuntu
Docker
Nginx
Node.js
PostgreSQL
```

etc.

---

# 12. Google Compute Engine

Google Cloud's VM service is:

```text
Compute Engine
```

Architecture:

```text
Google Cloud
      │
      ▼
Compute Engine
      │
      ├── VM
      ├── Disk
      ├── Network
      └── Firewall
```

---

# 13. Azure Virtual Machines

Azure provides:

```text
Azure Virtual Machines
```

Architecture:

```text
Azure
  │
  ▼
Virtual Machine
  │
  ├── CPU
  ├── RAM
  ├── Disk
  └── Network
```

You can run Linux or Windows workloads.

---

# 14. Vultr Cloud Compute

Vultr provides virtual cloud servers.

Conceptually:

```text
Vultr
  │
  ▼
Cloud Compute
  │
  ├── CPU
  ├── RAM
  ├── SSD
  ├── Public IP
  └── Private Network
```

You can install:

```text
Ubuntu
Docker
Nginx
PostgreSQL
Node.js
```

etc.

This is a good environment for practising the DevOps fundamentals you're currently learning.

---

# 15. Your First Cloud Server

Since you already have Vultr, your first practical goal should be:

```text
Your Computer
      │
      │ SSH
      ▼
Vultr VM
      │
      ├── Ubuntu
      ├── Docker
      └── Nginx
```

For example:

```text
Internet
    │
    ▼
Vultr Public IP
    │
    ▼
Ubuntu Server
    │
    ▼
Docker
    │
    ▼
Nginx Container
```

---

# 16. SSH to Your Cloud Server

After creating an Ubuntu VM, you'll typically receive a public IP.

Example:

```text
203.0.113.10
```

Connect:

```bash
ssh root@203.0.113.10
```

If using an SSH key:

```bash
ssh -i ~/.ssh/my-key root@203.0.113.10
```

The architecture is:

```text
Your Laptop
     │
     │ SSH :22
     ▼
Internet
     │
     ▼
Vultr
     │
     ▼
Ubuntu VM
```

---

# 17. Cloud Public IP

A cloud VM can have a public IP:

```text
Internet
    │
    ▼
203.0.113.10
    │
    ▼
Cloud VM
```

This allows Internet traffic to reach the VM when routing and firewall rules permit it.

---

# 18. Cloud Firewall

Cloud providers usually provide network firewall/security controls.

Example:

```text
Internet
    │
    ▼
Cloud Firewall
    │
    ├── Allow SSH :22
    ├── Allow HTTP :80
    ├── Allow HTTPS :443
    └── Block everything else
```

You may also have an operating-system firewall:

```text
Internet
    ↓
Cloud Firewall
    ↓
Ubuntu
    ↓
UFW
    ↓
Application
```

This creates multiple security layers.

---

# 19. Never Expose Everything

Bad example:

```text
Internet
    │
    ├── SSH
    ├── PostgreSQL
    ├── Redis
    ├── MySQL
    ├── Docker API
    └── Everything else
```

Better:

```text
Internet
    │
    ├── 80  → HTTP
    ├── 443 → HTTPS
    └── 22  → SSH
```

Your database should generally not be directly exposed to the public Internet unless there is a deliberate, secure architecture for doing so.

---

# 20. Cloud Storage

Cloud providers provide different types of storage.

## Block Storage

Looks like a disk attached to a VM.

```text
VM
 │
 └── Disk
```

Useful for:

* Databases
* Application files
* Persistent data

---

## Object Storage

Stores objects/files.

```text
Application
     │
     ▼
Object Storage
     │
     ├── image.jpg
     ├── report.pdf
     └── backup.zip
```

Examples:

```text
AWS S3
Google Cloud Storage
Azure Blob Storage
Vultr Object Storage
```

---

# 21. Object Storage vs VM Disk

| Block Storage               | Object Storage         |
| --------------------------- | ---------------------- |
| Looks like a disk           | Stores objects/files   |
| Attached to compute         | Accessed through APIs  |
| Good for OS/database        | Good for files/backups |
| Filesystem usually involved | Object-based           |

---

# 22. Managed Database

Instead of installing PostgreSQL yourself:

```text
VM
 │
 └── PostgreSQL
```

you can use a managed database:

```text
Cloud Provider
      │
      ▼
Managed PostgreSQL
```

The provider handles more infrastructure work such as:

* Provisioning
* Backups
* Patching
* Monitoring
* High availability options

The exact capabilities depend on the provider and service.

---

# 23. Self-Managed vs Managed Database

### Self-managed

```text
VM
 │
 └── PostgreSQL
```

You manage:

```text
OS
PostgreSQL
Updates
Backups
Security
Monitoring
```

### Managed

```text
Cloud
 │
 └── Managed PostgreSQL
```

The provider manages more of the infrastructure.

You still manage things such as:

```text
Database users
Schema
Queries
Application access
Data
```

---

# 24. Cloud Load Balancer

A cloud load balancer distributes traffic across servers.

```text
                Internet
                    │
                    ▼
              Load Balancer
                    │
          ┌─────────┼─────────┐
          ▼         ▼         ▼
       Server 1  Server 2  Server 3
```

This is similar to the Nginx load balancer you learned earlier.

The difference is:

```text
Nginx Load Balancer
       ↓
You operate it

Cloud Load Balancer
       ↓
Cloud provider operates the infrastructure
```

---

# 25. Cloud DNS

DNS connects your domain to your infrastructure.

Example:

```text
api.example.com
       │
       ▼
      DNS
       │
       ▼
203.0.113.10
       │
       ▼
Cloud Server
```

You can use a cloud provider's DNS service or another DNS provider.

---

# 26. Container Registry

A container registry stores Docker images.

Your development machine:

```text
Dockerfile
    ↓
docker build
    ↓
Docker Image
```

Push it:

```text
Docker Image
    ↓
Container Registry
```

Production:

```text
Production Server
       ↓
docker pull
       ↓
Container Registry
       ↓
Docker Image
       ↓
Container
```

Examples:

```text
AWS ECR
Google Artifact Registry
Azure Container Registry
Vultr Container Registry
```

---

# 27. Cloud Kubernetes

Kubernetes manages containers across infrastructure.

Instead of manually managing:

```text
Server 1
Server 2
Server 3
Server 4
```

Kubernetes can manage workloads across them.

Cloud Kubernetes services include:

```text
AWS
 ↓
EKS

Google Cloud
 ↓
GKE

Azure
 ↓
AKS

Vultr
 ↓
Vultr Kubernetes Engine
```

Don't jump into Kubernetes immediately.

First become comfortable with:

```text
Linux
Docker
Networking
Docker Compose
Cloud VM
```

---

# 28. Cloud Monitoring

Production systems need monitoring.

You want to know:

```text
CPU?
RAM?
Disk?
Network?
Application errors?
Request latency?
Container health?
```

Cloud providers have monitoring systems.

Examples:

```text
AWS
 ↓
CloudWatch

Google Cloud
 ↓
Cloud Monitoring

Azure
 ↓
Azure Monitor

Vultr
 ↓
Monitoring
```

---

# 29. Cloud Architecture

A simple production application might look like:

```text
                     INTERNET
                         │
                         ▼
                       DNS
                         │
                         ▼
                  Load Balancer
                         │
                         ▼
                  Reverse Proxy
                         │
              ┌──────────┼──────────┐
              ▼          ▼          ▼
           Server 1   Server 2   Server 3
              │          │          │
              └──────────┼──────────┘
                         │
                         ▼
                       Redis
                         │
                         ▼
                    PostgreSQL
                         │
                         ▼
                  Object Storage
```

Cloud services can provide many of these components.

---

# 30. Example: Deploying Your Docker App to Vultr

Your local development environment:

```text
Laptop
 │
 ├── Git
 ├── Docker
 └── Application
```

Build:

```bash
docker build -t my-app:1.0 .
```

Push to a registry:

```text
Docker Image
     ↓
Container Registry
```

Then:

```text
Vultr VM
   │
   ├── Ubuntu
   ├── Docker
   └── Nginx
```

Pull:

```bash
docker pull my-registry/my-app:1.0
```

Run:

```bash
docker run -d \
  --name my-app \
  -p 3000:3000 \
  my-registry/my-app:1.0
```

Architecture:

```text
Developer
    │
    │ Git Push
    ▼
GitHub / GitLab
    │
    ▼
CI/CD
    │
    ▼
Docker Build
    │
    ▼
Container Registry
    │
    ▼
Vultr VM
    │
    ▼
Docker Container
```

---

# 31. Cloud + CI/CD

A typical DevOps pipeline:

```text
Developer
    │
    ▼
Git Push
    │
    ▼
GitHub / GitLab
    │
    ▼
CI/CD
    │
    ├── Test
    ├── Build
    └── Docker Image
             │
             ▼
       Container Registry
             │
             ▼
        Cloud Server
             │
             ▼
          Deploy
```

This is one of the most important patterns you should learn as a DevOps engineer.

---

# 32. AWS vs Google Cloud vs Azure vs Vultr

These platforms overlap heavily, but their focus and product ecosystems differ.

|                                | AWS           | Google Cloud   | Azure             | Vultr             |
| ------------------------------ | ------------- | -------------- | ----------------- | ----------------- |
| Scale                          | Very large    | Very large     | Very large        | Smaller           |
| VM                             | EC2           | Compute Engine | Azure VM          | Cloud Compute     |
| Kubernetes                     | EKS           | GKE            | AKS               | VKE               |
| Object Storage                 | S3            | Cloud Storage  | Blob              | Object Storage    |
| Managed DB                     | RDS           | Cloud SQL      | Azure DB services | Managed DB        |
| Enterprise                     | Very strong   | Strong         | Very strong       | Less focused      |
| Learning simplicity            | Many services | Many services  | Many services     | Generally simpler |
| Good for learning Linux/Docker | Yes           | Yes            | Yes               | Yes               |
| Global ecosystem               | Very large    | Very large     | Very large        | Smaller           |

---

# 33. Why Learn Vultr First?

Since you already have a Vultr account, use it.

You don't need four cloud accounts just to learn basic DevOps.

Start with:

```text
Vultr
 │
 └── Ubuntu VM
       │
       ├── SSH
       ├── Linux
       ├── Firewall
       ├── Docker
       ├── Docker Compose
       ├── Nginx
       ├── Reverse Proxy
       └── Deploy Application
```

Then learn how the same concepts map to AWS, Google Cloud, and Azure.

---

# 34. Cloud Provider Mental Model

Don't memorize:

```text
AWS command
Google command
Azure command
Vultr command
```

Instead learn the underlying concept:

```text
                 CLOUD CONCEPT

                    VM
                     │
       ┌─────────────┼─────────────┐
       ▼             ▼             ▼
    Network        Storage       Security
       │             │             │
       ▼             ▼             ▼
   Public IP      Disk/Object    Firewall
       │
       ▼
     DNS
       │
       ▼
Load Balancer
       │
       ▼
 Application
```

Then map the concept to each provider.

---

# 35. Cloud Service Mapping

Remember this table:

| Need               | AWS        | Google Cloud         | Azure                   | Vultr              |
| ------------------ | ---------- | -------------------- | ----------------------- | ------------------ |
| VM                 | EC2        | Compute Engine       | Virtual Machines        | Cloud Compute      |
| Object storage     | S3         | Cloud Storage        | Blob Storage            | Object Storage     |
| Kubernetes         | EKS        | GKE                  | AKS                     | VKE                |
| Database           | RDS        | Cloud SQL            | Azure Database services | Managed Databases  |
| Load Balancer      | ELB        | Cloud Load Balancing | Azure Load Balancer     | Load Balancer      |
| DNS                | Route 53   | Cloud DNS            | Azure DNS               | DNS                |
| Container Registry | ECR        | Artifact Registry    | ACR                     | Container Registry |
| Monitoring         | CloudWatch | Cloud Monitoring     | Azure Monitor           | Monitoring         |

The exact features, pricing, limits, and naming can change, so use the provider's current documentation when implementing production systems.

---

# 36. Cloud Security Basics

Never treat a cloud VM as automatically secure.

Start with:

```text
1. SSH keys
       ↓
2. Disable unnecessary services
       ↓
3. Firewall
       ↓
4. Regular updates
       ↓
5. Strong authentication
       ↓
6. Least privilege
       ↓
7. Backups
       ↓
8. Monitoring
```

For example:

```bash
sudo apt update
sudo apt upgrade
```

Configure firewall:

```bash
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 443
sudo ufw enable
```

---

# 37. Cloud Cost

Cloud resources cost money.

Typical billable resources can include:

```text
VM
Storage
Database
Load Balancer
Public IP
Bandwidth
Object Storage
Snapshots
```

Always understand:

```text
Hourly price
Monthly estimate
Storage cost
Network/bandwidth cost
```

before creating large infrastructure.

For learning, start small.

---

# 38. Your First Vultr Lab

Because you already have Vultr, your first cloud lab should be:

```text
Vultr
 │
 └── Ubuntu VM
       │
       ├── Public IP
       │
       ├── SSH
       │
       ├── UFW
       │
       ├── Docker
       │
       ├── Docker Compose
       │
       ├── Nginx
       │
       └── Your Application
```

### Step 1

Create an Ubuntu VM.

### Step 2

Connect using SSH:

```bash
ssh root@YOUR_SERVER_IP
```

### Step 3

Update Ubuntu:

```bash
apt update
apt upgrade
```

### Step 4

Install Docker.

### Step 5

Run Nginx:

```bash
docker run -d \
  --name nginx \
  -p 80:80 \
  nginx
```

### Step 6

Open:

```text
http://YOUR_SERVER_IP
```

### Step 7

Configure a firewall.

### Step 8

Install Docker Compose / use Docker Compose.

### Step 9

Deploy your own application.

---

# 39. Cloud Learning Roadmap

Follow this order:

```text
1. Cloud Concepts
       ↓
2. Virtual Machines
       ↓
3. SSH
       ↓
4. Public / Private IP
       ↓
5. Firewall
       ↓
6. Cloud Networking
       ↓
7. Storage
       ↓
8. Docker on Cloud VM
       ↓
9. Nginx
       ↓
10. Reverse Proxy
       ↓
11. Domain + DNS
       ↓
12. HTTPS / TLS
       ↓
13. Database
       ↓
14. Backups
       ↓
15. Monitoring
       ↓
16. CI/CD
       ↓
17. Container Registry
       ↓
18. Load Balancer
       ↓
19. Kubernetes
```

---

# 40. Your DevOps Journey So Far

You have now covered a very useful foundation:

```text
Linux
  ↓
Shell
  ↓
Git
  ↓
Docker
  ↓
Docker Compose
  ↓
Networking
  ↓
Protocols
  ↓
Forward Proxy
  ↓
Reverse Proxy
  ↓
Load Balancer
  ↓
Firewall
  ↓
Caching
  ↓
Cloud
```

The next practical level is:

```text
Cloud VM
   ↓
SSH
   ↓
Firewall
   ↓
Docker
   ↓
Docker Compose
   ↓
Nginx
   ↓
Domain
   ↓
HTTPS
   ↓
CI/CD
   ↓
Production Deployment
```

---

# 41. Most Important Cloud Concepts

Before moving to Kubernetes, make sure you can explain:

```text
Cloud Provider
    ↓
Region
    ↓
Availability Zone
    ↓
Virtual Machine
    ↓
Public IP
    ↓
Private IP
    ↓
Firewall
    ↓
Storage
    ↓
DNS
    ↓
Load Balancer
    ↓
Container
    ↓
Application
```

The most important mental model is:

```text
              CLOUD PROVIDER
                    │
                    ▼
                 REGION
                    │
                    ▼
                NETWORK
                    │
          ┌─────────┴─────────┐
          ▼                   ▼
      Public IP           Private Network
          │                   │
          ▼                   ▼
      Firewall              VM
                              │
                     ┌────────┼────────┐
                     ▼        ▼        ▼
                   Docker   Nginx   Database
                     │
                     ▼
                 Application
```

---

# 42. Final Cheat Sheet

```text
Cloud
→ Rent infrastructure/services over the Internet

Region
→ Geographic cloud location

Availability Zone
→ Isolated infrastructure area within a region

VM
→ Virtual computer

Public IP
→ Internet-routable address

Private IP
→ Internal network address

Firewall
→ Controls network traffic

Object Storage
→ Stores files/objects

Block Storage
→ Persistent disk-like storage

DNS
→ Domain name → IP

Load Balancer
→ Distributes traffic

Container Registry
→ Stores Docker images

Managed Database
→ Provider manages more database infrastructure

Kubernetes
→ Container orchestration

Monitoring
→ Metrics, logs and alerts

CI/CD
→ Automatically test, build and deploy
```

---

# 43. The Main Goal

Don't try to become an AWS expert, Azure expert, Google Cloud expert, and Vultr expert simultaneously.

First become good at **cloud concepts**.

Then:

```text
Concept
   ↓
Vultr Practice
   ↓
AWS Equivalent
   ↓
Google Cloud Equivalent
   ↓
Azure Equivalent
```

For your current learning path, a very practical progression is:

```text
Vultr
  ↓
Ubuntu VM
  ↓
SSH
  ↓
Firewall
  ↓
Docker
  ↓
Docker Compose
  ↓
Nginx
  ↓
Reverse Proxy
  ↓
Domain + DNS
  ↓
HTTPS
  ↓
CI/CD
  ↓
Production Application
```

Once you can deploy and operate a real application on your Vultr VM, moving to AWS/GCP/Azure becomes much easier because you'll already understand **what the cloud services are actually doing**, rather than just memorizing provider-specific names.
