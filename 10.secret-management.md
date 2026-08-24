# Secret Management & Encryption

## Vault, Sealed Secrets, Cloud Tools, ESO & SOPS

Secret Management is the practice of securely storing, rotating, and controlling access to sensitive data like passwords, API keys, certificates, and encryption keys.

The main secret management tools covered in this guide are:

* HashiCorp Vault
* Sealed Secrets (for Kubernetes)
* Cloud-Specific Tools (AWS, Azure, GCP)
* External Secrets Operator (ESO)
* SOPS (Secrets Operations)

---

# 1. What Is Secret Management?

## The Problem: Storing Secrets Insecurely

```text
INSECURE WAYS TO STORE SECRETS (DON'T DO THIS):

❌ In source code (git)
   └── Disaster! Anyone with repo access has all secrets
   └── Can't rotate without code changes
   └── Exposed forever in git history

❌ In .env files
   └── Accidental commits to git
   └── Different per environment
   └── Hard to manage at scale

❌ On servers
   └── If server hacked, secrets exposed
   └── No audit trail
   └── Hard to rotate

❌ In configuration files
   └── Same problems as above
   └── No encryption

❌ Hardcoded in application
   └── Worst option
   └── Exposed in code reviews
   └── Can't be rotated
```

## The Solution: Secret Management System

```text
SECURE SECRET MANAGEMENT:

APPLICATION
     │
     ├─ Needs: Database password
     ├─ Needs: API key
     └─ Needs: JWT secret
     │
     ▼
     │ "Give me secret 'db-password'"
     │
VAULT / SECRET MANAGER
     ├─ Authenticate application
     ├─ Check permissions
     ├─ Audit log access
     ├─ Return secret
     └─ (Never stored in code!)
     │
     ▼
Application receives secret dynamically

Benefits:
✓ Secrets never in code/git
✓ Audit trail (who accessed what)
✓ Access control (only apps that need it)
✓ Rotation (change secrets without code)
✓ Encryption at rest
✓ Encryption in transit
✓ No manual management
```

---

# 2. Secret Management Architecture

```text
┌─────────────────────────────────────────────────────┐
│           SECRET MANAGEMENT SYSTEM                  │
└─────────────────────────────────────────────────────┘

SOURCES (Where secrets come from):
├── Passwords (database, SSH, etc)
├── API Keys (external services)
├── Certificates (SSL/TLS)
├── SSH Keys
├── OAuth tokens
├── Database credentials
├── Encryption keys
└── API Tokens

                    │
                    ▼

SECRET VAULT (Secure storage):
├── Database
├── Encryption layer
├── Access control
├── Audit logging
├── Automatic rotation
└── High availability

                    │
                    ▼

CONSUMERS (Who needs secrets):
├── Applications
├── Terraform (provision infra)
├── Ansible (configure servers)
├── Docker containers
├── Kubernetes pods
├── CI/CD pipelines
└── Developers (when needed)

                    │
                    ▼

DELIVERY METHODS:
├── Environment variables
├── File mounts
├── API calls
├── Database direct
└── Webhook injection
```

---

# 3. Quick Comparison: All 5 Tools

```text
┌──────────────┬──────────────┬──────────────┬──────────────┬──────────────┬──────────────┐
│   Feature    │ Vault        │ Sealed       │ Cloud Tools  │ ESO          │ SOPS         │
│              │              │ Secrets      │ (AWS/Azure)  │              │              │
├──────────────┼──────────────┼──────────────┼──────────────┼──────────────┼──────────────┤
│ Cost         │ FREE/Paid    │ FREE ✓       │ FREE/Pay     │ FREE ✓       │ FREE ✓       │
│ Setup        │ Complex      │ Medium       │ Easy         │ Medium       │ Easy         │
│ Learning     │ Medium       │ Medium       │ Easy         │ Hard         │ Easy         │
│ Platform     │ Any          │ Kubernetes   │ Specific     │ Kubernetes   │ Any          │
│ Rotation     │ YES ✓        │ NO           │ YES ✓        │ Depends      │ NO           │
│ Audit Log    │ YES ✓        │ Limited      │ YES ✓        │ YES ✓        │ Limited      │
│ HA/DR        │ YES ✓        │ Limited      │ YES ✓        │ Yes          │ Limited      │
│ Use Case     │ Everything ✓ │ K8s only     │ Cloud apps   │ K8s          │ File encryption
│ Enterprise   │ Strong       │ Medium       │ Strong       │ Growing      │ Growing      │
│ Community    │ HUGE ✓       │ Medium       │ Cloud team   │ Growing      │ Medium       │
└──────────────┴──────────────┴──────────────┴──────────────┴──────────────┴──────────────┘
```

---

# 4. My Recommendation: Vault

## Why Choose Vault?

```text
VAULT IS BEST FOR LEARNING BECAUSE:

✓ MOST POWERFUL & FLEXIBLE
  └── Works with any platform (not locked in)
  └── Can manage any type of secret
  └── Can run on-premise or cloud
  
✓ PRODUCTION-GRADE
  └── Used by Fortune 500 companies
  └── High availability & disaster recovery
  └── Audit logging & compliance
  └── Dynamic secrets & rotation
  
✓ LARGEST ECOSYSTEM
  └── Integrates with everything
  └── Terraform, Ansible, Kubernetes, Docker
  └── 100+ built-in integrations
  
✓ SKILL TRANSFERABILITY
  └── Learn Vault = learn enterprise standard
  └── Skills apply at any company
  └── HashiCorp products ecosystem
  
✓ COMPLETE SOLUTION
  └── Static secrets (passwords, keys)
  └── Dynamic secrets (auto-rotate)
  └── Encryption as a service
  └── Identity management
  
✓ WORKS WITH YOUR STACK
  └── Terraform can fetch from Vault
  └── Ansible can use Vault passwords
  └── Docker containers can get secrets
  └── GitHub Actions can fetch secrets
  └── Kubernetes can use Vault

ALTERNATIVE CONSIDERATIONS:

Cloud Tools (AWS/Azure/GCP):
├── Better if: Cloud-only infrastructure
├── Advantage: Easier if cloud native
└── Disadvantage: Locked to provider

Sealed Secrets / ESO:
├── Better if: Kubernetes-only
├── Advantage: Native K8s integration
└── Disadvantage: Limited to K8s

SOPS:
├── Better if: Git-based secret versioning
├── Advantage: Secrets in git (encrypted)
└── Disadvantage: Manual management
```

**FINAL ANSWER: Choose Vault for learning. Most powerful, most transferable.**

---

# 5. Quick Overview: Sealed Secrets

## What Are Sealed Secrets?

Sealed Secrets encrypt secrets at rest in Kubernetes. Secrets encrypted until they reach the pod.

## Simple Sealed Secrets Example

```bash
# Install Sealed Secrets controller
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.20.0/controller.yaml

# Seal a secret
echo -n "my-password" | kubectl create secret generic db-secret --dry-run=client --from-file=password=/dev/stdin -o yaml | \
  kubeseal -f - > db-secret-sealed.yaml

# Store sealed secret in git (safe!)
git add db-secret-sealed.yaml
git commit -m "Add sealed database secret"

# Deploy - K8s unseals it
kubectl apply -f db-secret-sealed.yaml

# Pod can use as normal secret
env:
  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: db-secret
        key: password
```

## Sealed Secrets Pros & Cons

```text
PROS:
✓ Kubernetes native
✓ Secrets can be in git (encrypted)
✓ Simple to use
✓ Works with kubectl

CONS:
✗ Kubernetes-only
✗ No rotation
✗ Limited audit trail
✗ Hard to manage at scale
✗ Key stored in cluster
```

---

# 6. Quick Overview: Cloud-Specific Tools

## AWS Secrets Manager

```text
Perfect for: AWS-only infrastructure
Cost: $0.40/secret/month + API calls

# Store secret
aws secretsmanager create-secret \
  --name prod/db/password \
  --secret-string "my-password"

# Retrieve secret
aws secretsmanager get-secret-value \
  --secret-id prod/db/password \
  --query SecretString

Features:
✓ Automatic rotation
✓ High availability
✓ Audit logging (CloudTrail)
✓ Encryption (KMS)
✓ VPC endpoints
✓ Cost tracking
```

## Azure Key Vault

```text
Perfect for: Azure infrastructure
Cost: $0.03/operation (10K free per month)

# Store secret
az keyvault secret set \
  --vault-name mykeyvault \
  --name db-password \
  --value "my-password"

# Retrieve secret
az keyvault secret show \
  --vault-name mykeyvault \
  --name db-password

Features:
✓ Automatic rotation
✓ HSM support
✓ Managed identity integration
✓ Soft delete
✓ Azure Monitor integration
```

## GCP Secret Manager

```text
Perfect for: GCP infrastructure
Cost: $0.06/million API calls

# Store secret
gcloud secrets create db-password \
  --replication-policy="automatic" \
  --data-file=-

# Retrieve secret
gcloud secrets versions access latest \
  --secret="db-password"

Features:
✓ Automatic rotation
✓ IAM integration
✓ Audit logging
✓ Multi-region replication
```

---

# 7. Quick Overview: External Secrets Operator (ESO)

## What Is ESO?

ESO syncs secrets from external systems into Kubernetes. Keep secrets in Vault/AWS, automatically sync to K8s.

## Simple ESO Example

```yaml
# Install ESO
helm repo add external-secrets https://charts.external-secrets.io
helm install external-secrets external-secrets/external-secrets -n external-secrets-system --create-namespace

# Configure Vault backend
---
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: vault-backend
spec:
  provider:
    vault:
      server: "https://vault.example.com:8200"
      path: "secret"
      auth:
        kubernetes:
          mountPath: "kubernetes"
          role: "default"

---
# Sync secret from Vault to Kubernetes
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: db-secret
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: vault-backend
    kind: SecretStore
  target:
    name: db-secret
    creationPolicy: Owner
  data:
    - secretKey: password
      remoteRef:
        key: database
        property: password
```

## ESO Pros & Cons

```text
PROS:
✓ Kubernetes-native
✓ Syncs from any backend
✓ Automatic refresh
✓ Multiple backends
✓ GitOps friendly

CONS:
✗ Kubernetes-only
✗ Complex setup
✗ Requires external system
✗ Steeper learning curve
```

---

# 8. Quick Overview: SOPS

## What Is SOPS?

SOPS encrypts individual files (YAML, JSON, etc) at rest. Secrets stay in git, encrypted.

## Simple SOPS Example

```bash
# Install SOPS
brew install sops

# Create .sops.yaml config
cat > .sops.yaml <<EOF
creation_rules:
  - provider: age
    age_key_file: ~/.sops/age-key.txt
EOF

# Generate age key
age-keygen -o ~/.sops/age-key.txt

# Create secrets file
cat > secrets.yaml <<EOF
db:
  password: my-super-secret-password
  username: admin
api:
  key: sk_live_abc123
EOF

# Encrypt it
sops -e -i secrets.yaml

# File is now encrypted
git add secrets.yaml
git commit -m "Add encrypted secrets"

# Edit encrypted file
sops secrets.yaml
# Opens in editor, decrypted
# Encrypts again when you save

# View encrypted file
sops -d secrets.yaml
```

## SOPS Pros & Cons

```text
PROS:
✓ Secrets in git (encrypted)
✓ GitOps friendly
✓ Simple to use
✓ Works with git workflow
✓ Multiple key types (age, GPG, AWS KMS)

CONS:
✗ No rotation
✗ File-level only
✗ Limited access control
✗ Manual key management
✗ Not for dynamic secrets
```

---

# 9. Vault: Detailed Guide

Since Vault is the best choice for you, here's the detailed guide.

## What Is HashiCorp Vault?

Vault is an enterprise-grade secrets management system. Manage, store, rotate, and audit access to secrets across your infrastructure.

## How Vault Works

```text
BASIC FLOW:

1. APPLICATION NEEDS SECRET
   └─ "I need database password"

2. AUTHENTICATE TO VAULT
   └─ Using: token, JWT, AWS IAM, Kubernetes, etc
   └─ Vault verifies identity

3. CHECK PERMISSIONS
   └─ Does this app have access?
   └─ Check policy

4. RETURN SECRET
   └─ Return password
   └─ Log access (audit)

5. APPLICATION USES SECRET
   └─ Connect to database
   └─ Execute query

KEY FEATURES:

✓ Static secrets: Passwords, API keys (stored)
✓ Dynamic secrets: Database, SSH keys (auto-created)
✓ Encryption: Encrypt/decrypt data
✓ Key rotation: Automatic secret rotation
✓ Audit logging: Who accessed what
✓ Access control: Fine-grained policies
✓ High availability: Clustering & failover
✓ Disaster recovery: Backup & restore
```

## Vault Architecture

```text
┌──────────────────────────────────────────┐
│         VAULT CLUSTER (HA)               │
├──────────────────────────────────────────┤
│                                          │
│  ┌──────────────────────────────────┐   │
│  │  VAULT SERVER 1 (Leader)         │   │
│  │  ├─ Storage backend              │   │
│  │  └─ Encryption layer             │   │
│  └──────────────────────────────────┘   │
│                                          │
│  ┌──────────────────────────────────┐   │
│  │  VAULT SERVER 2 (Standby)        │   │
│  │  └─ Replicates from leader       │   │
│  └──────────────────────────────────┘   │
│                                          │
│  ┌──────────────────────────────────┐   │
│  │  VAULT SERVER 3 (Standby)        │   │
│  │  └─ Replicates from leader       │   │
│  └──────────────────────────────────┘   │
│                                          │
│  ┌──────────────────────────────────┐   │
│  │  STORAGE BACKEND                 │   │
│  │  ├─ Consul                       │   │
│  │  ├─ S3                           │   │
│  │  ├─ PostgreSQL                   │   │
│  │  └─ Integrated Storage (raft)    │   │
│  └──────────────────────────────────┘   │
│                                          │
└──────────────────────────────────────────┘

SEAL/UNSEAL:
├─ Server starts SEALED (encrypted)
├─ Operators unseal with key shares
├─ Uses master key to decrypt storage
├─ Now ready to serve requests
└─ Auto-unseal: Use AWS KMS, etc
```

## Vault Core Concepts

```text
SECRET ENGINE:       Generates/stores secrets (kv, database, ssh)
AUTH METHOD:        Authenticates users/apps (token, JWT, K8s)
POLICY:             Rules for access (who can do what)
PATH:               Location of secrets (secret/database/prod)
LEASE:              Time-to-live for secrets (TTL)
TOKEN:              Credential for accessing Vault
SEAL:               Encrypt/lock Vault data
UNSEAL:             Decrypt/unlock Vault to use
AUDIT LOG:          Record of all access
LEASE RENEWAL:      Extend lease before expiration
SECRET ROTATION:    Change secret automatically
```

---

# 10. Installing & Running Vault

## Install Vault (macOS)

```bash
# Install via Homebrew
brew tap hashicorp/tap
brew install hashicorp/tap/vault

# Verify
vault version
# Output: Vault v1.14.0
```

## Install Vault (Linux)

```bash
# Download
wget https://releases.hashicorp.com/vault/1.14.0/vault_1.14.0_linux_amd64.zip
unzip vault_1.14.0_linux_amd64.zip
sudo mv vault /usr/local/bin/

# Verify
vault version
```

## Start Vault (Development Mode)

```bash
# Dev mode - for learning only (no persistence)
vault server -dev

# Output:
# WARNING! dev mode is enabled!
# ...
# You may need to set the following environment variable:
# export VAULT_ADDR='http://127.0.0.1:8200'
# export VAULT_TOKEN='s.xxx'

# In another terminal
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='s.xxx'

# Test
vault status
```

## Start Vault (Production Mode)

```hcl
# vault-config.hcl

storage "raft" {
  path = "/opt/vault/data"
  node_id = "node1"
}

listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_cert_file = "/opt/vault/tls/vault.crt"
  tls_key_file  = "/opt/vault/tls/vault.key"
}

seal "awskms" {
  region     = "us-east-1"
  kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
}

ha_storage "consul" {
  address = "127.0.0.1:8500"
  path    = "vault"
}

ui = true
```

Start it:
```bash
vault server -config=vault-config.hcl
```

---

# 11. Vault Secrets: KV Store

## Store Static Secrets (Passwords, API Keys)

```bash
# Enable KV v2 secret engine
vault secrets enable -version=2 kv

# Store a secret
vault kv put kv/database/prod \
  username="admin" \
  password="super-secret-password"

# Read a secret
vault kv get kv/database/prod

# Output:
# ====== Secret Path ======
# kv/database/prod
#
# ====== Metadata ======
# Key                Value
# ---                -----
# created_time       2024-01-15T10:30:00Z
# deletion_time      n/a
# destroyed          false
# version            1
#
# ====== Data ======
# Key        Value
# ---        -----
# password   super-secret-password
# username   admin

# Get specific field
vault kv get -field=password kv/database/prod

# List secrets
vault kv list kv/database/

# Delete secret
vault kv delete kv/database/prod

# Undelete (soft delete)
vault kv undelete kv/database/prod -versions 1
```

---

# 12. Vault Dynamic Secrets (Auto-Rotation)

## Database Credentials (Auto-created & Rotated)

```bash
# Enable database secret engine
vault secrets enable database

# Configure PostgreSQL connection
vault write database/config/postgresql \
  plugin_name=postgresql-database-plugin \
  allowed_roles="readonly,readwrite" \
  connection_url="postgresql://{{username}}:{{password}}@postgres.example.com:5432/mydb" \
  username="vault_admin" \
  password="vault_admin_password"

# Create role for read-only access
vault write database/roles/readonly \
  db_name=postgresql \
  creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' IN ROLE readonly;" \
  default_ttl="1h" \
  max_ttl="24h"

# Create role for read-write access
vault write database/roles/readwrite \
  db_name=postgresql \
  creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' IN ROLE readwrite;" \
  default_ttl="1h" \
  max_ttl="24h"

# Get database credentials (auto-created!)
vault read database/creds/readonly

# Output:
# Key                Value
# ---                -----
# lease_id           database/creds/readonly/abc123...
# lease_duration     1h
# lease_renewable    true
# password           temp-password-auto-generated
# username           v-token-readonly-xyz

# Lease auto-rotates before expiration
# Old password automatically revoked
```

## SSH Credentials (Auto-created)

```bash
# Enable SSH secret engine
vault secrets enable ssh

# Configure SSH CA (Certificate Authority)
vault write ssh/config/ca \
  generate_signing_key=true

# Create role for signing certificates
vault write ssh/roles/dev \
  key_type=ca \
  ttl=30m \
  allow_user_certificates=true \
  allowed_users="ec2-user,ubuntu,root"

# Get signed SSH certificate
vault write ssh/sign/dev \
  public_key=@~/.ssh/id_rsa.pub

# Output:
# Key             Value
# ---             -----
# signed_key      -----BEGIN OPENSSH CERTIFICATE-----
#                 ... (certificate data)
#                 -----END OPENSSH CERTIFICATE-----
# serial          1234567890
# ...

# Use certificate to SSH
ssh -i cert.pub -i ~/.ssh/id_rsa user@server
```

---

# 13. Vault Access Control (Policies)

Policies define what each user/app can access.

```hcl
# admin-policy.hcl
# Full access for admins

path "kv/*" {
  capabilities = ["create", "read", "update", "delete", "list", "destroy"]
}

path "database/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "secret/admin/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
```

```hcl
# app-policy.hcl
# Limited access for application

path "kv/database/prod" {
  capabilities = ["read"]
}

path "database/creds/readonly" {
  capabilities = ["read"]
}

path "secret/app/*" {
  capabilities = ["read"]
}
```

```hcl
# developer-policy.hcl
# Limited access for developers

path "kv/staging/*" {
  capabilities = ["read", "update"]
}

path "database/creds/readwrite" {
  capabilities = ["read"]
}
```

Apply policies:
```bash
# Write policy
vault policy write admin admin-policy.hcl
vault policy write app-policy app-policy.hcl
vault policy write developer developer-policy.hcl

# List policies
vault policy list

# View policy
vault policy read admin
```

---

# 14. Vault Authentication Methods

## Token Auth (Simple)

```bash
# Create token
vault token create -policy=default

# Use token
export VAULT_TOKEN="s.xxx"
vault kv get kv/database/prod
```

## Kubernetes Auth (For Pods)

```bash
# Enable Kubernetes auth
vault auth enable kubernetes

# Configure Kubernetes
vault write auth/kubernetes/config \
  kubernetes_host="https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT" \
  kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
  token_reviewer_jwt=@/var/run/secrets/kubernetes.io/serviceaccount/token

# Create role for app
vault write auth/kubernetes/role/app-role \
  bound_service_account_names=app \
  bound_service_account_namespaces=default \
  policies=app-policy \
  ttl=24h

# Pod authenticates automatically!
vault login -method=kubernetes role=app-role
```

## AWS IAM Auth (For EC2/ECS)

```bash
# Enable AWS IAM auth
vault auth enable aws

# Configure AWS
vault write auth/aws/config/client \
  access_key=AKIAIOSFODNN7EXAMPLE \
  secret_key=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

# Create role
vault write auth/aws/role/app-role \
  auth_type=iam \
  policies=app-policy \
  bound_account_id=123456789012

# EC2 instance authenticates using IAM role!
vault login -method=aws
```

## JWT/OIDC Auth (For Applications)

```bash
# Enable JWT auth
vault auth enable jwt

# Configure OIDC
vault write auth/jwt/config \
  oidc_discovery_url="https://accounts.google.com" \
  oidc_client_id="CLIENTID.apps.googleusercontent.com" \
  oidc_client_secret="secret"

# Create role
vault write auth/jwt/role/app-role \
  bound_audiences="app" \
  policies=app-policy \
  user_claim="email"

# App uses JWT token to authenticate
vault login -method=jwt role=app-role jwt=<token>
```

---

# 15. Integration: Terraform + Vault

Use Vault as secret source in Terraform.

## Terraform Configuration

```hcl
# main.tf

terraform {
  required_providers {
    vault = {
      source = "hashicorp/vault"
      version = "~> 3.0"
    }
  }
}

provider "vault" {
  address = "https://vault.example.com:8200"
  # Auth via environment: VAULT_TOKEN or VAULT_ADDR
}

# Read secret from Vault
data "vault_generic_secret" "db_password" {
  path = "kv/database/prod"
}

# Use secret in Terraform
resource "aws_rds_cluster" "main" {
  cluster_identifier      = "my-rds-cluster"
  engine                  = "aurora-postgresql"
  database_name           = "mydb"
  master_username         = "admin"
  master_password         = data.vault_generic_secret.db_password.data["password"]
  # ...
}

# Read dynamic database credentials
data "vault_database_static_creds" "readonly" {
  backend = "database"
  role    = "readonly"
}

resource "aws_instance" "app" {
  # ...
  environment {
    DB_USER     = data.vault_database_static_creds.readonly.username
    DB_PASSWORD = data.vault_database_static_creds.readonly.password
  }
}
```

## In GitHub Actions

```yaml
# .github/workflows/deploy.yml

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Fetch secrets from Vault
        env:
          VAULT_ADDR: ${{ secrets.VAULT_ADDR }}
          VAULT_TOKEN: ${{ secrets.VAULT_TOKEN }}
        run: |
          DB_PASSWORD=$(vault kv get -field=password kv/database/prod)
          echo "::add-mask::$DB_PASSWORD"
          echo "DB_PASSWORD=$DB_PASSWORD" >> $GITHUB_ENV
      
      - name: Deploy with Terraform
        env:
          TF_VAR_db_password: ${{ env.DB_PASSWORD }}
        run: terraform apply -auto-approve
```

---

# 16. Integration: Ansible + Vault

Use Vault secrets in Ansible playbooks.

## Ansible Configuration

```yaml
# ansible/group_vars/all.yml
# Encrypted with: ansible-vault encrypt

vault_address: "https://vault.example.com:8200"
vault_token: "s.xxx"  # Or use auth method
```

## Ansible Playbook

```yaml
# ansible/playbooks/deploy.yml

- name: Deploy Application
  hosts: app_servers
  vars_files:
    - group_vars/all.yml
  
  pre_tasks:
    - name: Fetch secrets from Vault
      set_fact:
        db_password: "{{ lookup('hashi_vault', 'secret=kv/database/prod field=password') }}"
        api_key: "{{ lookup('hashi_vault', 'secret=kv/api/prod field=api_key') }}"
      environment:
        VAULT_ADDR: "{{ vault_address }}"
        VAULT_TOKEN: "{{ vault_token }}"
  
  tasks:
    - name: Deploy environment file
      template:
        src: .env.j2
        dest: /opt/app/.env
        owner: app
        group: app
        mode: '0600'
      vars:
        db_password: "{{ db_password }}"
        api_key: "{{ api_key }}"
```

## .env.j2 Template

```bash
DATABASE_URL=postgresql://admin:{{ db_password }}@db.example.com/mydb
API_KEY={{ api_key }}
```

---

# 17. Docker + Vault

Get secrets when container starts.

## Docker Container Entrypoint

```bash
#!/bin/bash
# docker-entrypoint.sh

# Authenticate to Vault
export VAULT_TOKEN=$(vault write -field=token auth/kubernetes/login role=myapp)

# Fetch secrets
export DB_PASSWORD=$(vault kv get -field=password kv/database/prod)
export API_KEY=$(vault kv get -field=key kv/api/prod)

# Start application
exec node index.js
```

## Dockerfile

```dockerfile
FROM node:18-alpine

RUN apk add --no-cache curl

# Install Vault CLI
RUN curl -fsSL https://releases.hashicorp.com/vault/1.14.0/vault_1.14.0_linux_amd64.zip | \
    unzip - -d /usr/local/bin/

WORKDIR /app

COPY . .
RUN npm ci --only=production

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
```

## Docker Compose

```yaml
version: '3'

services:
  vault:
    image: vault:latest
    ports:
      - "8200:8200"
    environment:
      VAULT_DEV_ROOT_TOKEN_ID: myroot
      VAULT_DEV_LISTEN_ADDRESS: 0.0.0.0:8200

  app:
    build: .
    ports:
      - "3000:3000"
    depends_on:
      - vault
    environment:
      VAULT_ADDR: http://vault:8200
      VAULT_TOKEN: myroot
```

---

# 18. Kubernetes + Vault

Use Vault with Kubernetes pods.

## Kubernetes Auth

```yaml
# vault-auth.yaml

apiVersion: v1
kind: ServiceAccount
metadata:
  name: vault-auth
  namespace: default

---

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: vault-auth
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
  - kind: ServiceAccount
    name: vault-auth
    namespace: default

---

apiVersion: v1
kind: Pod
metadata:
  name: vault-client
spec:
  serviceAccountName: vault-auth
  containers:
  - name: app
    image: myapp:latest
    env:
    - name: VAULT_ADDR
      value: http://vault.default:8200
    - name: VAULT_ROLE
      value: app-role
    volumeMounts:
    - name: jwt
      mountPath: /var/run/secrets/kubernetes.io/serviceaccount
  volumes:
  - name: jwt
    projected:
      sources:
      - serviceAccountToken:
          audience: vault
          expirationSeconds: 3600
          path: token
```

## Init Container (Fetch Secrets)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-with-secrets
spec:
  serviceAccountName: vault-auth
  initContainers:
  - name: vault-init
    image: vault:latest
    args:
      - /bin/sh
      - -c
      - |
        # Login to Vault
        export VAULT_TOKEN=$(vault write -field=token auth/kubernetes/login role=app-role)
        
        # Fetch secrets
        vault kv get -field=password kv/database/prod > /shared/db_password
        vault kv get -field=key kv/api/prod > /shared/api_key
    volumeMounts:
    - name: shared
      mountPath: /shared
    env:
    - name: VAULT_ADDR
      value: http://vault.default:8200
  
  containers:
  - name: app
    image: myapp:latest
    env:
    - name: DB_PASSWORD
      valueFrom:
        fieldRef:
          fieldPath: /shared/db_password
    - name: API_KEY
      valueFrom:
        fieldRef:
          fieldPath: /shared/api_key
    volumeMounts:
    - name: shared
      mountPath: /shared
  
  volumes:
  - name: shared
    emptyDir: {}
```

---

# 19. Vault Best Practices

```text
SECURITY:

DO:
✓ Use strong authentication
✓ Implement least privilege policies
✓ Rotate secrets regularly
✓ Use dynamic secrets where possible
✓ Enable audit logging
✓ Use TLS for all connections
✓ Implement HA/DR
✓ Backup unseal keys securely
✓ Use auto-unseal (AWS KMS, etc)
✓ Restrict network access to Vault
✓ Update Vault regularly

DON'T:
✗ Share tokens
✗ Store tokens in code
✗ Use overly permissive policies
✗ Disable audit logging
✗ Disable TLS
✗ Hardcode credentials
✗ Store unseal keys in code
✗ Expose Vault to internet
✗ Use dev mode in production

OPERATIONAL:

✓ Use namespaces for isolation
✓ Monitor lease expirations
✓ Document all policies
✓ Test disaster recovery
✓ Use version control for IaC
✓ Implement change management
✓ Monitor Vault metrics
✓ Set up alerting
✓ Regular backup strategy
✓ Secure seal key distribution
```

---

# 20. Vault Comparison: When to Use Each

```text
VAULT:
├── When: Need enterprise solution
├── When: Multi-cloud infrastructure
├── When: Need dynamic secrets & rotation
├── When: Need audit trail
└── When: Need encryption service

AWS SECRETS MANAGER:
├── When: AWS-only infrastructure
├── When: Already using AWS services
├── When: Want native AWS integration
└── When: Cost optimized for single cloud

SEALED SECRETS:
├── When: Kubernetes-only
├── When: Secrets must be in git
├── When: Simple use case
└── When: No external infrastructure

ESO:
├── When: Kubernetes
├── When: Want multiple backends
├── When: Complex syncing needed
└── When: GitOps workflow

SOPS:
├── When: Secrets in git (encrypted)
├── When: File-based approach
├── When: Simple key management
└── When: Development/staging only
```

---

# 21. Complete Example: Blog App Integration

```bash
# 1. Store secrets in Vault

# Database credentials
vault kv put kv/blog/database \
  host="rds-prod.xyz.us-east-1.rds.amazonaws.com" \
  username="admin" \
  password="prod-db-password-xyz"

# API keys
vault kv put kv/blog/api \
  github_token="ghp_xxx" \
  sendgrid_api_key="SG.xxx" \
  stripe_secret_key="sk_live_xxx"

# 2. Terraform fetches from Vault

# terraform/main.tf
data "vault_generic_secret" "db" {
  path = "kv/blog/database"
}

resource "aws_rds_instance" "main" {
  allocated_storage = 20
  db_name          = "blog"
  username         = data.vault_generic_secret.db.data["username"]
  password         = data.vault_generic_secret.db.data["password"]
}

# 3. Ansible configures servers

# ansible/playbooks/deploy.yml
- name: Deploy Blog App
  hosts: app_servers
  pre_tasks:
    - name: Fetch secrets from Vault
      set_fact:
        db_password: "{{ lookup('hashi_vault', 'secret=kv/blog/database field=password') }}"
        api_keys: "{{ lookup('hashi_vault', 'secret=kv/blog/api') }}"
  tasks:
    - name: Create .env file
      template:
        src: .env.j2
        dest: /opt/app/.env

# 4. GitHub Actions uses secrets

# .github/workflows/deploy.yml
- name: Fetch secrets from Vault
  env:
    VAULT_ADDR: ${{ secrets.VAULT_ADDR }}
    VAULT_TOKEN: ${{ secrets.VAULT_TOKEN }}
  run: |
    terraform apply -auto-approve

# RESULT: All secrets centralized in Vault
# No secrets in git, code, or configuration files
# Single source of truth for all sensitive data
```

---

# Quick Reference: Vault Commands

```bash
# Basic operations
vault status
vault login -method=oidc role=my-role
vault token revoke -self

# Secrets management
vault kv put secret/myapp key=value
vault kv get secret/myapp
vault kv list secret/
vault kv delete secret/myapp

# Dynamic secrets
vault read database/creds/readonly
vault renew -increment=1h lease_id

# Policies
vault policy write myapp myapp-policy.hcl
vault policy read myapp
vault policy list

# Audit logging
vault audit enable file file_path=/var/log/vault-audit.log
vault audit list

# Backup & restore
vault write -force sys/storage/raft/snapshot > raft.snap
vault write sys/storage/raft/snapshot-restore snapshot_file_path=/path/to/raft.snap

# HA status
vault status

# Unseal
vault operator unseal <key1>
vault operator unseal <key2>
vault operator unseal <key3>
```

---

# Summary: Secret Management Decision

```
┌──────────────────────────────────────────────┐
│                                              │
│  ✓ CHOICE: VAULT                            │
│  ✓ COST: FREE (open-source)                 │
│  ✓ LEARNING TIME: 2-3 weeks                 │
│  ✓ PLATFORM: Any (not locked in)            │
│  ✓ POWER: Most powerful solution            │
│  ✓ CAREER VALUE: Enterprise standard        │
│  ✓ START: Today with dev mode               │
│                                              │
│  INTEGRATION WITH YOUR STACK:               │
│  ├─ Terraform: Fetch secrets                │
│  ├─ Ansible: Dynamic credentials            │
│  ├─ GitHub Actions: Store tokens            │
│  ├─ Docker: Container secrets               │
│  ├─ Kubernetes: Pod authentication          │
│  └─ All tools working together!             │
│                                              │
│  COMPARED TO ALTERNATIVES:                  │
│  ├─ Vault: Most powerful ✓✓✓                │
│  ├─ AWS SM: Good if AWS-only                │
│  ├─ Sealed Secrets: K8s-only                │
│  ├─ ESO: Complex K8s setup                  │
│  └─ SOPS: File-based (limited)              │
│                                              │
└──────────────────────────────────────────────┘
```

---

# Resources & Learning

## Official Resources

- [Vault Official Docs](https://www.vaultproject.io/docs)
- [Vault API](https://www.vaultproject.io/api-docs)
- [Vault Learn](https://learn.hashicorp.com/vault)
- [Vault GitHub](https://github.com/hashicorp/vault)

## Integrations

- [Terraform Vault Provider](https://registry.terraform.io/providers/hashicorp/vault/latest/docs)
- [Ansible Vault Lookup](https://docs.ansible.com/ansible/latest/plugins/lookup/hashi_vault.html)
- [Vault Docker Image](https://hub.docker.com/_/vault)
- [Vault Kubernetes Auth](https://www.vaultproject.io/docs/auth/kubernetes)

## Learning Resources

- [Vault Getting Started](https://www.vaultproject.io/intro)
- [HashiCorp Learn - Vault](https://learn.hashicorp.com/collections/vault)
- [Vault in Production](https://www.vaultproject.io/docs/operating)
- [Community Vault Projects](https://www.vaultproject.io/community)

## Community

- [Vault Discussion Forum](https://discuss.hashicorp.com/c/vault/)
- [Vault GitHub Issues](https://github.com/hashicorp/vault/issues)
- [Stack Overflow #vault](https://stackoverflow.com/questions/tagged/vault)

---

**Last Updated:** August 24, 2026
**Curated for:** DevOps Learning Path
**Integration:** Terraform, Ansible, GitHub Actions, Docker, Kubernetes
**Recommendation:** Choose Vault & start today!
