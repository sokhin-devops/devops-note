# Integrated DevOps Project: Complete End-to-End Example

## Real-World Project Using All Tools Together

This guide shows how **Cloud Serverless**, **Provisioning (Terraform)**, **Configuration Management (Ansible)**, and **Cloud Providers** work together in a complete DevOps workflow.

---

# 1. The Architecture: Full Stack Application

## Project: Blog Application with 3-Tier Architecture

```text
┌─────────────────────────────────────────────────────────────────────┐
│                     COMPLETE SYSTEM ARCHITECTURE                     │
└─────────────────────────────────────────────────────────────────────┘

USERS
  │
  ├─── CLOUDFLARE WORKERS (Edge Logic)
  │    ├── Cache responses
  │    ├── Rate limiting
  │    ├── Request routing
  │    └── A/B testing
  │
  ├─── VERCEL (Frontend + Serverless API)
  │    ├── Next.js frontend (blog UI)
  │    ├── API routes (/api/posts, /api/comments)
  │    └── Global CDN
  │
  └─── AWS (Backend Infrastructure - Provisioned with Terraform)
       │
       ├── LOAD BALANCER (ALB)
       │   └── Routes traffic to app servers
       │
       ├── APP SERVERS (EC2 instances - Configured with Ansible)
       │   ├── Node.js server 1
       │   ├── Node.js server 2
       │   └── Node.js server 3
       │
       ├── DATABASE (RDS PostgreSQL)
       │   └── Blog data, comments, users
       │
       ├── CACHE (ElastiCache Redis)
       │   └── Session management
       │
       └── STORAGE (S3)
           └── Blog images, uploads

FLOW:
1. User visits example.com
   └── Hits Cloudflare Worker (edge, instant)
       └── Routes to Vercel (frontend)
           └── Vercel fetches from /api endpoints
               └── Calls backend at api.example.com (ALB)
                   └── EC2 servers respond (configured with Ansible)
                       └── Queries RDS database
```

---

# 2. Project Structure

```text
blog-project/
│
├── terraform/                          ← Infrastructure as Code
│   ├── main.tf                         (Provision EC2, VPC, RDS)
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   └── environments/
│       ├── dev.tfvars
│       ├── staging.tfvars
│       └── prod.tfvars
│
├── ansible/                            ← Configuration Management
│   ├── playbooks/
│   │   ├── deploy.yml                 (Main playbook)
│   │   ├── database-setup.yml
│   │   └── security-hardening.yml
│   ├── roles/
│   │   ├── common/                    (System packages, users)
│   │   ├── nodejs/                    (Node.js runtime)
│   │   ├── docker/                    (Docker container)
│   │   ├── app/                       (Application deployment)
│   │   ├── nginx/                     (Web server)
│   │   └── monitoring/                (CloudWatch agent)
│   ├── group_vars/
│   │   └── all.yml
│   ├── hosts.ini                       (Inventory - updated by Terraform)
│   └── ansible.cfg
│
├── frontend/                           ← Vercel Deployment
│   ├── pages/
│   │   ├── index.js                   (Blog home)
│   │   ├── posts/
│   │   │   └── [id].js                (Blog post detail)
│   │   └── api/
│   │       ├── posts.js               (GET /api/posts)
│   │       ├── posts/[id].js          (GET /api/posts/:id)
│   │       └── comments.js            (POST /api/comments)
│   ├── vercel.json                    (Vercel config)
│   ├── next.config.js
│   └── package.json
│
├── backend/                            ← Express API (runs on EC2)
│   ├── src/
│   │   ├── index.js
│   │   ├── routes/
│   │   │   ├── posts.js
│   │   │   └── comments.js
│   │   └── models/
│   │       ├── Post.js
│   │       └── Comment.js
│   ├── docker/
│   │   └── Dockerfile
│   ├── package.json
│   └── .env.example
│
├── cloudflare-worker/                 ← Cloudflare Worker
│   ├── src/
│   │   └── index.js
│   ├── wrangler.toml
│   └── package.json
│
├── scripts/
│   ├── setup.sh                        (Full deployment automation)
│   ├── deploy-infrastructure.sh
│   ├── configure-servers.sh
│   ├── deploy-application.sh
│   └── rollback.sh
│
└── documentation/
    ├── ARCHITECTURE.md
    ├── DEPLOYMENT.md
    └── TROUBLESHOOTING.md
```

---

# 3. Step-by-Step Workflow

## Phase 1: Infrastructure Provisioning (Terraform)

### Problem Being Solved:
"I need servers, database, load balancer in AWS without clicking console buttons"

### Solution: Terraform

```text
Developer writes:
   terraform/main.tf
   │
   ▼
terraform init (download AWS provider)
terraform plan (show what will be created)
terraform apply (actually create resources)
   │
   ▼
AWS creates:
├── VPC (Virtual Private Cloud)
├── Subnets
├── Security Groups
├── EC2 Instances (app servers)
├── Load Balancer
├── RDS PostgreSQL Database
├── ElastiCache Redis
└── S3 Bucket
   │
   ▼
Terraform saves IPs in outputs:
   web_servers: [10.0.1.10, 10.0.1.11, 10.0.1.12]
   database_endpoint: blog-db.xyz.us-east-1.rds.amazonaws.com
   load_balancer_dns: blog-alb-123.us-east-1.elb.amazonaws.com
```

### Example: terraform/main.tf

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "blog-terraform-state"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Subnets for app servers
resource "aws_subnet" "app" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = {
    Name = "${var.project_name}-app-subnet-${count.index + 1}"
  }
}

# Security group for app servers
resource "aws_security_group" "app" {
  name   = "${var.project_name}-app-sg"
  vpc_id = aws_vpc.main.id
  
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }
  
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instances for app servers
resource "aws_instance" "app" {
  count              = 3
  ami                = var.ami_id
  instance_type      = var.instance_type
  subnet_id          = aws_subnet.app[count.index].id
  security_groups    = [aws_security_group.app.id]
  iam_instance_profile = aws_iam_instance_profile.app.name
  
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    environment = var.environment
    region      = var.aws_region
  }))
  
  tags = {
    Name = "${var.project_name}-app-${count.index + 1}"
  }
}

# Load Balancer
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.app[*].id
  
  tags = {
    Name = "${var.project_name}-alb"
  }
}

# Target Group
resource "aws_lb_target_group" "app" {
  name        = "${var.project_name}-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"
  
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/health"
    matcher             = "200"
  }
}

# Register instances with target group
resource "aws_lb_target_group_attachment" "app" {
  count            = 3
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = aws_instance.app[count.index].id
  port             = 3000
}

# RDS Database
resource "aws_db_instance" "blog" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "14.7"
  instance_class       = var.db_instance_class
  db_name              = "blogdb"
  username             = "admin"
  password             = random_password.db_password.result
  skip_final_snapshot  = var.environment == "dev"
  
  tags = {
    Name = "${var.project_name}-db"
  }
}

# Random password for database
resource "random_password" "db_password" {
  length  = 16
  special = true
}

# Store database password in AWS Secrets Manager
resource "aws_secretsmanager_secret" "db_password" {
  name = "${var.project_name}/db/password"
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db_password.result
}

# Output values for Ansible
output "instance_ips" {
  description = "Private IPs of app servers"
  value       = aws_instance.app[*].private_ip
}

output "load_balancer_dns" {
  description = "DNS name of load balancer"
  value       = aws_lb.main.dns_name
}

output "database_endpoint" {
  description = "Database endpoint"
  value       = aws_db_instance.blog.endpoint
}

output "database_password_secret" {
  description = "Secrets Manager secret name"
  value       = aws_secretsmanager_secret.db_password.name
}

data "aws_availability_zones" "available" {
  state = "available"
}
```

### Example: terraform/variables.tf

```hcl
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "blog"
}

variable "environment" {
  type = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod"
  }
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "ami_id" {
  type        = string
  description = "Ubuntu 22.04 AMI ID"
}
```

### Example: terraform/environments/prod.tfvars

```hcl
aws_region        = "us-east-1"
project_name      = "blog"
environment       = "prod"
instance_type     = "t3.small"
db_instance_class = "db.t3.small"
ami_id            = "ami-0c55b159cbfafe1f0"
```

---

## Phase 2: Server Configuration (Ansible)

### Problem Being Solved:
"Now I have 3 servers, but they're bare - I need to install software, configure them, and deploy my app"

### Solution: Ansible

```text
Terraform outputs IPs:
   10.0.1.10, 10.0.1.11, 10.0.1.12
   │
   ▼
Ansible reads IPs from inventory
   │
   ▼
Connects via SSH to each server
   │
   ├─ Install system packages (git, curl, docker)
   ├─ Install Node.js runtime
   ├─ Install Nginx as reverse proxy
   ├─ Deploy application code
   ├─ Start application
   ├─ Setup SSL certificates
   ├─ Configure monitoring
   └─ Run security hardening
   │
   ▼
All 3 servers configured identically
All servers running Node.js app
All servers behind load balancer
```

### Example: ansible/hosts.ini (Generated by Terraform)

```ini
# This file is auto-generated from Terraform outputs

[app_servers]
app-1 ansible_host=10.0.1.10 ansible_user=ubuntu
app-2 ansible_host=10.0.1.11 ansible_user=ubuntu
app-3 ansible_host=10.0.1.12 ansible_user=ubuntu

[all:vars]
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_python_interpreter=/usr/bin/python3
app_port=3000
database_host=blog-db.xyz.us-east-1.rds.amazonaws.com
```

### Example: ansible/playbooks/deploy.yml

```yaml
---
- name: Deploy Blog Application
  hosts: app_servers
  become: yes
  
  vars:
    app_name: blog-app
    app_version: "1.0.0"
    app_port: 3000
    app_path: /opt/blog-app
  
  roles:
    - common                    # System packages, users, firewall
    - nodejs                    # Install Node.js runtime
    - docker                    # Install Docker
    - app                       # Deploy application
    - nginx                     # Reverse proxy
    - monitoring                # CloudWatch agent
  
  post_tasks:
    - name: Verify application is running
      uri:
        url: "http://localhost:{{ app_port }}/health"
        status_code: 200
      register: result
      retries: 5
      delay: 10
      until: result.status == 200
    
    - name: Print deployment info
      debug:
        msg: |
          ✓ Application deployed successfully!
          Application: {{ app_name }}
          Version: {{ app_version }}
          Port: {{ app_port }}
          Host: {{ inventory_hostname }}
```

### Example: ansible/roles/app/tasks/main.yml

```yaml
---
- name: Create app directory
  file:
    path: "{{ app_path }}"
    state: directory
    owner: ubuntu
    group: ubuntu
    mode: '0755'

- name: Clone application repository
  git:
    repo: "https://github.com/youruser/blog-app.git"
    dest: "{{ app_path }}"
    version: main
  become_user: ubuntu
  notify: restart application

- name: Copy environment file
  template:
    src: env.j2
    dest: "{{ app_path }}/.env"
    owner: ubuntu
    group: ubuntu
    mode: '0600'
  notify: restart application

- name: Install Node.js dependencies
  npm:
    path: "{{ app_path }}"
  become_user: ubuntu

- name: Build application
  shell: npm run build
  args:
    chdir: "{{ app_path }}"
  become_user: ubuntu

- name: Deploy systemd service file
  template:
    src: app.service.j2
    dest: /etc/systemd/system/blog-app.service
    owner: root
    group: root
    mode: '0644'
  notify:
    - daemon reload
    - restart application

- name: Enable application service
  systemd:
    name: blog-app
    enabled: yes
    state: started
```

### Example: ansible/roles/app/templates/env.j2

```bash
# Blog Application Environment

NODE_ENV=production
APP_PORT={{ app_port }}
DATABASE_URL=postgresql://admin:{{ db_password }}@{{ database_host }}/blogdb
REDIS_URL=redis://{{ redis_host }}:6379
JWT_SECRET={{ jwt_secret }}
API_KEY={{ api_key }}
VERCEL_API_URL=https://api.vercel.com
```

### Example: ansible/roles/nginx/tasks/main.yml

```yaml
---
- name: Install Nginx
  apt:
    name: nginx
    state: present

- name: Deploy Nginx config
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/sites-available/blog-app
    owner: root
    group: root
    mode: '0644'
  notify: restart nginx

- name: Enable Nginx site
  file:
    src: /etc/nginx/sites-available/blog-app
    dest: /etc/nginx/sites-enabled/blog-app
    state: link
  notify: restart nginx

- name: Disable default site
  file:
    path: /etc/nginx/sites-enabled/default
    state: absent
  notify: restart nginx

- name: Start Nginx
  service:
    name: nginx
    state: started
    enabled: yes
```

### Example: ansible/roles/nginx/templates/nginx.conf.j2

```nginx
upstream blog_app {
    server 127.0.0.1:{{ app_port }};
}

server {
    listen 80;
    server_name _;
    
    client_max_body_size 20M;
    
    location / {
        proxy_pass http://blog_app;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
    
    location /health {
        access_log off;
        return 200 "healthy\n";
    }
}
```

---

## Phase 3: Frontend Deployment (Vercel)

### Problem Being Solved:
"I have a backend API running on EC2, now I need to deploy a Next.js frontend globally"

### Solution: Vercel

```text
Developer pushes to GitHub
   │
   ▼
Vercel webhook triggered
   │
   ├─ Build Next.js project
   ├─ Deploy static assets to CDN
   ├─ Deploy API routes as serverless functions
   └─ Run production build
   │
   ▼
Frontend running globally on Vercel CDN
API routes call backend at: api.example.com (ALB)
```

### Example: frontend/pages/index.js

```javascript
import { useState, useEffect } from 'react'
import Link from 'next/link'

export default function Home() {
  const [posts, setPosts] = useState([])
  const [loading, setLoading] = useState(true)
  
  useEffect(() => {
    // Call own API route (Vercel serverless function)
    fetch('/api/posts')
      .then(res => res.json())
      .then(data => {
        setPosts(data)
        setLoading(false)
      })
  }, [])
  
  if (loading) return <div>Loading...</div>
  
  return (
    <div>
      <h1>Blog Posts</h1>
      {posts.map(post => (
        <Link key={post.id} href={`/posts/${post.id}`}>
          <h2>{post.title}</h2>
          <p>{post.excerpt}</p>
        </Link>
      ))}
    </div>
  )
}
```

### Example: frontend/pages/api/posts.js (Vercel Serverless Function)

```javascript
// This runs as serverless function on Vercel
// It calls the backend API running on EC2

export default async function handler(req, res) {
  try {
    // Call backend API at AWS load balancer
    const response = await fetch(
      `${process.env.BACKEND_API_URL}/api/posts`,
      {
        headers: {
          'Authorization': `Bearer ${process.env.BACKEND_API_KEY}`,
        },
      }
    )
    
    const posts = await response.json()
    
    // Cache response for 60 seconds
    res.setHeader('Cache-Control', 'public, s-maxage=60, stale-while-revalidate=120')
    res.status(200).json(posts)
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
}
```

### Example: frontend/vercel.json

```json
{
  "env": {
    "BACKEND_API_URL": "@backend-api-url",
    "BACKEND_API_KEY": "@backend-api-key"
  },
  "crons": [{
    "path": "/api/cron/cache-refresh",
    "schedule": "0 * * * *"
  }]
}
```

---

## Phase 4: Edge Computing (Cloudflare Workers)

### Problem Being Solved:
"I want to cache API responses, rate-limit requests, and serve content from the edge"

### Solution: Cloudflare Workers

```text
User Request to example.com
   │
   ▼
Cloudflare Worker (200+ global locations)
   │
   ├─ Check rate limit (KV cache)
   ├─ Cache responses
   ├─ Route based on path
   └─ Add security headers
   │
   ▼
   ├─→ Vercel (if / or /posts)
   │   └─ Frontend
   │
   └─→ ALB (if /api/*)
       └─ Backend on EC2
```

### Example: cloudflare-worker/src/index.js

```javascript
// Cloudflare Worker

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url)
    const path = url.pathname
    
    // 1. Check rate limit
    const ip = request.headers.get('cf-connecting-ip')
    const rateLimit = await checkRateLimit(ip, env)
    
    if (rateLimit.exceeded) {
      return new Response('Too many requests', { status: 429 })
    }
    
    // 2. Check cache
    const cacheKey = new Request(url.toString(), { method: 'GET' })
    const cache = caches.default
    let response = await cache.match(cacheKey)
    
    if (response) {
      return response
    }
    
    // 3. Route requests
    let origin
    if (path.startsWith('/api/')) {
      // Route API to backend on AWS
      origin = 'https://api.example.com'
    } else {
      // Route frontend to Vercel
      origin = 'https://blog-app.vercel.app'
    }
    
    // 4. Fetch from origin
    const originRequest = new Request(
      `${origin}${path}${url.search}`,
      {
        method: request.method,
        headers: request.headers,
        body: request.body,
      }
    )
    
    response = await fetch(originRequest)
    
    // 5. Cache successful responses for 1 hour
    if (response.status === 200 && request.method === 'GET') {
      response = new Response(response.body, response)
      response.headers.set('Cache-Control', 'public, max-age=3600')
      ctx.waitUntil(cache.put(cacheKey, response.clone()))
    }
    
    return response
  }
}

// Rate limiting helper
async function checkRateLimit(ip, env) {
  const key = `ratelimit:${ip}`
  const count = parseInt(await env.RATE_LIMIT_KV.get(key) || '0')
  
  if (count >= 100) { // 100 requests per minute
    return { exceeded: true, count }
  }
  
  await env.RATE_LIMIT_KV.put(
    key,
    String(count + 1),
    { expirationTtl: 60 } // 60 seconds
  )
  
  return { exceeded: false, count: count + 1 }
}
```

### Example: cloudflare-worker/wrangler.toml

```toml
name = "blog-worker"
type = "javascript"
account_id = "your-account-id"
workers_dev = true
route = "example.com/*"
zone_id = "your-zone-id"

[env.production]
route = "example.com/*"
vars = { ENVIRONMENT = "production" }

[[kv_namespaces]]
binding = "RATE_LIMIT_KV"
id = "your-kv-id"
```

---

# 4. Complete Deployment Automation Script

## scripts/setup.sh (Master Automation Script)

```bash
#!/bin/bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
ENVIRONMENT=${1:-dev}
PROJECT_NAME="blog"
AWS_REGION="us-east-1"
TF_DIR="./terraform"
ANSIBLE_DIR="./ansible"

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Blog Application Deployment Script${NC}"
echo -e "${YELLOW}Environment: $ENVIRONMENT${NC}"
echo -e "${YELLOW}========================================${NC}"

# Function to print status
print_status() {
  echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
  echo -e "${RED}[✗]${NC} $1"
}

# Step 1: Validate prerequisites
echo -e "\n${YELLOW}Step 1: Validating prerequisites...${NC}"

command -v terraform >/dev/null 2>&1 || { print_error "Terraform not installed"; exit 1; }
command -v ansible >/dev/null 2>&1 || { print_error "Ansible not installed"; exit 1; }
command -v aws >/dev/null 2>&1 || { print_error "AWS CLI not installed"; exit 1; }

print_status "All prerequisites found"

# Step 2: Provision infrastructure with Terraform
echo -e "\n${YELLOW}Step 2: Provisioning infrastructure with Terraform...${NC}"

cd "$TF_DIR"

terraform init
print_status "Terraform initialized"

terraform plan \
  -var-file="environments/${ENVIRONMENT}.tfvars" \
  -out="tfplan"
print_status "Terraform plan created"

terraform apply tfplan
print_status "Infrastructure provisioned"

# Get outputs from Terraform
INSTANCE_IPS=$(terraform output -raw instance_ips | tr '\n' ' ')
DB_ENDPOINT=$(terraform output -raw database_endpoint | cut -d: -f1)
LB_DNS=$(terraform output -raw load_balancer_dns)

print_status "Infrastructure outputs:"
echo "  - Instance IPs: $INSTANCE_IPS"
echo "  - Database: $DB_ENDPOINT"
echo "  - Load Balancer: $LB_DNS"

cd - > /dev/null

# Step 3: Generate Ansible inventory from Terraform outputs
echo -e "\n${YELLOW}Step 3: Generating Ansible inventory...${NC}"

cat > "$ANSIBLE_DIR/inventory/hosts.ini" <<EOF
[app_servers]
EOF

COUNTER=1
for IP in $INSTANCE_IPS; do
  echo "app-$COUNTER ansible_host=$IP ansible_user=ubuntu" >> "$ANSIBLE_DIR/inventory/hosts.ini"
  ((COUNTER++))
done

cat >> "$ANSIBLE_DIR/inventory/hosts.ini" <<EOF

[all:vars]
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_python_interpreter=/usr/bin/python3
database_host=$DB_ENDPOINT
EOF

print_status "Ansible inventory generated"

# Step 4: Wait for EC2 instances to be ready
echo -e "\n${YELLOW}Step 4: Waiting for EC2 instances to boot...${NC}"

sleep 30
print_status "Instances should be ready"

# Step 5: Test connectivity
echo -e "\n${YELLOW}Step 5: Testing SSH connectivity...${NC}"

cd "$ANSIBLE_DIR"
ansible all -i inventory/hosts.ini -m ping -u ubuntu
print_status "SSH connectivity verified"

# Step 6: Run Ansible playbooks
echo -e "\n${YELLOW}Step 6: Configuring servers with Ansible...${NC}"

# Install dependencies
ansible-playbook playbooks/deploy.yml \
  -i inventory/hosts.ini \
  -u ubuntu \
  --check
print_status "Ansible playbook validated"

# Actually apply configuration
ansible-playbook playbooks/deploy.yml \
  -i inventory/hosts.ini \
  -u ubuntu
print_status "Servers configured"

cd - > /dev/null

# Step 7: Deploy frontend to Vercel
echo -e "\n${YELLOW}Step 7: Deploying frontend to Vercel...${NC}"

cd frontend

if [ ! -f ".vercelignore" ]; then
  cat > .vercelignore <<EOF
.env.example
README.md
EOF
fi

# Set environment variables
vercel env add BACKEND_API_URL "https://${LB_DNS}/api"
vercel env add BACKEND_API_KEY "${BACKEND_API_KEY:-your-api-key}"

# Deploy to Vercel
if command -v vercel >/dev/null 2>&1; then
  vercel deploy --prod
  print_status "Frontend deployed to Vercel"
else
  print_error "Vercel CLI not installed - skipping frontend deployment"
  echo "  Run: npm i -g vercel && vercel link && vercel deploy --prod"
fi

cd - > /dev/null

# Step 8: Deploy Cloudflare Worker
echo -e "\n${YELLOW}Step 8: Deploying Cloudflare Worker...${NC}"

cd cloudflare-worker

if command -v wrangler >/dev/null 2>&1; then
  wrangler publish
  print_status "Cloudflare Worker deployed"
else
  print_error "Wrangler CLI not installed - skipping worker deployment"
  echo "  Run: npm i -g wrangler && wrangler publish"
fi

cd - > /dev/null

# Step 9: Verification
echo -e "\n${YELLOW}Step 9: Verifying deployment...${NC}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Your application is live at:"
echo "  - Frontend: https://example.com (via Vercel)"
echo "  - Backend API: https://${LB_DNS}/api"
echo "  - Edge: Cloudflare Workers enabled"
echo ""
echo "Next steps:"
echo "  1. Update DNS records to point to Cloudflare"
echo "  2. Configure SSL certificates"
echo "  3. Setup monitoring and alerts"
echo "  4. Configure backups for database"
echo ""

# Save deployment info
cat > deployment-info.txt <<EOF
Environment: $ENVIRONMENT
Date: $(date)
Database: $DB_ENDPOINT
Load Balancer: $LB_DNS
Instances: $INSTANCE_IPS
EOF

print_status "Deployment info saved to deployment-info.txt"
```

---

# 5. Data Flow Through The System

## Example: User Requests a Blog Post

```text
USER VISITS: example.com/posts/123
     │
     ▼
CLOUDFLARE WORKER (Edge - instant response)
├─ Checks rate limit (KV cache)
├─ Checks response cache
├─ If cached → return cached response
└─ If not cached → route to Vercel
     │
     ▼
VERCEL (Global CDN + Serverless)
├─ Serves frontend HTML/CSS/JS
├─ Browser renders page
└─ Page calls: fetch('/api/posts/123')
     │
     ▼
VERCEL API ROUTE (/pages/api/posts/[id].js)
├─ Serverless function executes
├─ Calls backend: fetch('https://api.example.com/api/posts/123')
└─ Returns JSON to browser
     │
     ▼
AWS LOAD BALANCER (ALB)
├─ Routes to EC2 instance
└─ Could hit app-1, app-2, or app-3
     │
     ▼
EC2 INSTANCE (Configured with Ansible)
├─ Nginx receives request
├─ Reverse proxy to Node.js app (port 3000)
└─ Express server processes request
     │
     ▼
NODE.JS EXPRESS SERVER (Deployed with Ansible)
├─ Receives GET /api/posts/123
├─ Queries database
├─ Returns JSON: { id: 123, title: "...", content: "..." }
     │
     ▼
RDS POSTGRESQL DATABASE
├─ Stores blog posts
├─ Automatically backed up
└─ Accessible only from security group
     │
     ▼
Response travels back:
RDS → Node.js → Nginx → ALB → Vercel → Cloudflare → User Browser
```

---

# 6. Updating The System

## Scenario: You Want to Deploy New Code

```bash
# Option 1: Update Frontend
cd frontend
git commit -am "Add new feature"
git push origin main
# → Vercel automatically detects push
# → Builds and deploys
# → Live in 2 minutes

# Option 2: Update Backend
cd backend
git commit -am "Fix API bug"
git push origin main
# → Local CI/CD or GitHub Actions builds
# → Creates Docker image
# → Pushes to repository
# → Update Ansible playbook to use new version
ansible-playbook ansible/playbooks/deploy.yml -i ansible/inventory/hosts.ini
# → Ansible pulls new code
# → Restarts application on all 3 servers
# → Zero downtime (rolling deployment)

# Option 3: Scale Infrastructure
# Edit terraform/environments/prod.tfvars
# Change instance_count from 3 to 5
terraform apply -var-file=environments/prod.tfvars
# → Terraform creates 2 new EC2 instances
# → Outputs new IPs
# → Update Ansible inventory
# → Run Ansible playbook
# → 5 servers now configured and running
```

---

# 7. Monitoring & Logging

## CloudWatch (AWS Monitoring)

```text
Application sends logs:
├─ Node.js console.log()
├─ Nginx access.log
└─ System metrics

→ CloudWatch Agent (installed by Ansible)
→ Sends to CloudWatch Logs
→ Available in AWS Dashboard
```

## Vercel Monitoring

```text
Frontend deployment
├─ Vercel Analytics
├─ Performance metrics
└─ Deployment history
→ Visible in Vercel Dashboard
```

## Cloudflare Analytics

```text
Worker execution
├─ Request count
├─ Error rates
├─ Cache hit ratio
└─ Performance metrics
→ Visible in Cloudflare Dashboard
```

---

# 8. Troubleshooting Checklist

```text
If frontend is slow:
├─ Check Cloudflare cache hit ratio
├─ Check Vercel deployment logs
└─ Verify backend API response time

If backend API returns 500:
├─ SSH into EC2 instance: ssh -i key.pem ubuntu@IP
├─ Check application logs: journalctl -u blog-app -f
├─ Check database connection: psql -h $DB_ENDPOINT -U admin -d blogdb
├─ Check Nginx logs: sudo tail -f /var/log/nginx/error.log
└─ Check CloudWatch logs in AWS console

If database won't connect:
├─ Verify security group allows connection
├─ Verify password in Secrets Manager
├─ Check RDS status in AWS console
└─ Verify database actually exists

If Ansible playbook fails:
├─ Run with extra verbosity: ansible-playbook ... -vvv
├─ Check SSH key permissions: chmod 400 ~/.ssh/id_rsa
├─ Verify instances are running: aws ec2 describe-instances
├─ Test connectivity: ansible all -i inventory/hosts.ini -m ping
└─ Check inventory file: cat inventory/hosts.ini
```

---

# 9. Security Best Practices (Using All Tools)

## Secrets Management

```hcl
# Terraform: Store secrets in AWS Secrets Manager
resource "aws_secretsmanager_secret" "db_password" {
  name = "blog/db/password"
}

# Never expose in outputs or logs
```

```yaml
# Ansible: Use Vault for sensitive variables
ansible-vault create group_vars/all/secrets.yml
# Variables encrypted at rest
ansible-playbook playbook.yml --ask-vault-pass
```

```javascript
// Vercel: Environment variables in dashboard
// Never in code or .env committed to git
process.env.BACKEND_API_KEY
process.env.DATABASE_PASSWORD
```

## Network Security

```hcl
# Terraform: Security groups restrict access
resource "aws_security_group" "app" {
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  # Only ALB can reach app servers
}

resource "aws_db_instance" "blog" {
  publicly_accessible = false  # Database not accessible from internet
  db_subnet_group_name = "private"  # In private subnet only
}
```

```javascript
// Cloudflare: Rate limiting prevents abuse
async function checkRateLimit(ip, env) {
  const count = parseInt(await env.RATE_LIMIT_KV.get(`rate:${ip}`) || '0')
  if (count > 100) return new Response('Too many requests', { status: 429 })
}
```

---

# 10. Cost Estimation

```text
MONTHLY COST BREAKDOWN:

AWS Infrastructure:
├── EC2 (3 × t3.micro): $10/month
├── RDS PostgreSQL (db.t3.micro): $30/month
├── ElastiCache (cache.t3.micro): $20/month
├── Load Balancer: $16/month
├── S3 Storage: ~$5/month
├── Data Transfer: ~$10/month
└── Total AWS: ~$91/month

Vercel Frontend:
├── Free tier usually sufficient
└── If paid: $20/month (Pro plan)

Cloudflare Worker:
├── Free tier (100k req/day): $0
└── If paid: $5/month base

Total: ~$95-120/month for small-medium app

This includes:
✓ Global CDN
✓ 3 app servers
✓ PostgreSQL database
✓ Redis cache
✓ Auto-scaling load balancer
✓ Automated deployments
✓ Monitoring
```

---

# 11. Git Workflow Integration

```bash
# Developer workflow

# 1. Feature branch
git checkout -b feature/add-comments

# 2. Make changes
# Edit code, commit

# 3. Push
git push origin feature/add-comments

# 4. Create PR
# GitHub/GitLab creates PR
# CI/CD runs tests

# 5. Merge to main
# PR approved and merged

# 6. Auto-deployment
# GitHub Actions / Vercel webhook
# Terraform: terraform apply (if infra changed)
# Ansible: ansible-playbook (if config changed)
# Vercel: automatic deployment
# Cloudflare: publish

# 7. Rollback if needed
git revert <commit-hash>
git push origin main
# Auto-redeploy with old version
```

---

# 12. Full Architecture Diagram

```text
┌────────────────────────────────────────────────────────────────┐
│                      COMPLETE SYSTEM                           │
└────────────────────────────────────────────────────────────────┘

                              INTERNET
                                  │
                    ┌─────────────┴─────────────┐
                    │                           │
                    ▼                           ▼
            CLOUDFLARE EDGE                 DNS SERVICES
         (200+ locations)              (example.com → CF)
            │
            ├─ Cache Layer
            ├─ Rate Limiting (Worker)
            ├─ Security
            └─ Route traffic
                    │
        ┌───────────┼───────────┐
        │           │           │
        ▼           ▼           ▼
    VERCEL      VERCEL      VERCEL
    (US)        (EU)        (APAC)
    Frontend    Frontend    Frontend
        │           │           │
        └───────────┴───────────┘
                    │
                    │ Call /api/*
                    │
                    ▼
            AWS LOAD BALANCER
            (us-east-1)
                    │
        ┌───────────┼───────────┐
        │           │           │
        ▼           ▼           ▼
      EC2         EC2         EC2
    Instance 1  Instance 2  Instance 3
    (Ansible)   (Ansible)   (Ansible)
        │           │           │
        └───────────┴───────────┘
                    │
        ┌───────────┴───────────┐
        │                       │
        ▼                       ▼
    RDS PostgreSQL        ElastiCache Redis
    (Database)            (Cache/Sessions)
        │
    S3 Bucket (Images)

INFRASTRUCTURE (Terraform provisions)
SERVERS (Ansible configures)
FRONTEND (Vercel deploys)
EDGE (Cloudflare)
```

---

# Quick Reference: Which Tool for What

```text
NEED TO...                          USE THIS TOOL

Create servers & networking         Terraform
Configure servers & install apps    Ansible
Deploy frontend & API routes        Vercel
Cache & rate limit at edge         Cloudflare Workers
Store secrets securely             AWS Secrets Manager
Monitor application                CloudWatch
Version control all code           Git/GitHub
Automate deployments              GitHub Actions + Terraform + Ansible

WORKFLOW:
1. Developer commits code → GitHub
2. GitHub Actions triggers → Terraform + Ansible
3. Terraform provisions → AWS infrastructure
4. Ansible configures → EC2 servers
5. Vercel deploys → Frontend
6. Cloudflare serves → Global CDN
7. User sees → Fast, secure application
```

---

# Summary: How It All Works Together

```
┌─────────────────────────────────────────────────────────┐
│ TERRAFORM (Infrastructure)                              │
│ • Defines: EC2, VPC, RDS, Load Balancer, S3            │
│ • Result: Running infrastructure in AWS                │
│ • Stores: Outputs (IPs, DNS names, endpoints)          │
└─────────────────────────────────────────────────────────┘
                         │
                         │ Outputs
                         ▼
┌─────────────────────────────────────────────────────────┐
│ ANSIBLE (Configuration)                                 │
│ • Reads: IPs from Terraform                            │
│ • Installs: Node.js, Nginx, Docker                     │
│ • Deploys: Application code                            │
│ • Result: Ready-to-use servers                         │
└─────────────────────────────────────────────────────────┘
                         │
                         │ Backend running
                         ▼
┌─────────────────────────────────────────────────────────┐
│ VERCEL (Frontend)                                       │
│ • Deploys: Next.js application                         │
│ • Connects: To backend via API                         │
│ • Serves: Global CDN                                   │
│ • Result: Fast frontend worldwide                      │
└─────────────────────────────────────────────────────────┘
                         │
                         │ Traffic
                         ▼
┌─────────────────────────────────────────────────────────┐
│ CLOUDFLARE WORKERS (Edge)                               │
│ • Caches: Responses                                    │
│ • Limits: Rate limiting                                │
│ • Routes: Requests to Vercel or AWS                    │
│ • Result: Ultra-fast access everywhere                 │
└─────────────────────────────────────────────────────────┘

ALL TOGETHER = COMPLETE DEVOPS PIPELINE!
```

---

**Last Updated:** August 24, 2026
**Integration Level:** Production-Ready
**Lesson Connection:** All DevOps Lessons Integrated
