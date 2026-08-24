# CI/CD Tools & Automation Pipelines

## GitLab CI, CircleCI, Jenkins & GitHub Actions

CI/CD (Continuous Integration / Continuous Deployment) automates testing, building, and deploying your code whenever you push changes to git.

The main CI/CD tools covered in this guide are:

* GitLab CI
* CircleCI
* Jenkins
* GitHub Actions

---

# 1. What Is CI/CD?

## Manual Deployment (The Old Way)

```text
Developer
     │
     ├─ Write code
     ├─ git push
     ├─ SSH to server manually
     ├─ git pull
     ├─ Run tests manually
     ├─ Run builds manually
     ├─ Deploy manually
     └─ Pray nothing breaks
     
Problems:
├─ Slow (hours to deploy)
├─ Error-prone (human mistakes)
├─ Inconsistent environments
├─ Can't rollback easily
├─ No visibility into failures
└─ Requires DevOps babysitting
```

## CI/CD Automation (The New Way)

```text
Developer
     │
     ├─ Write code
     ├─ git commit
     ├─ git push to main
     │
     ▼
CI/CD Pipeline Auto-triggers
     │
     ├─ Lint code
     ├─ Run unit tests
     ├─ Build application
     ├─ Run integration tests
     ├─ Build Docker image
     ├─ Deploy to staging
     ├─ Run smoke tests
     ├─ Deploy to production
     └─ Notify team
     │
     ▼
Application live in 5 minutes
(Completely automated, zero human intervention)
```

## Benefits of CI/CD

```text
CI/CD ADVANTAGES:

Speed:           Deploy to production in minutes
Consistency:     Same process every time
Reliability:     Automated tests catch bugs
Quality:         Can't deploy without passing tests
Visibility:      See deployment status in real-time
Rollback:        Easy to revert to previous version
Confidence:      Automated checks = safe to deploy
Scaling:         Deploy 100 servers as easily as 1
Frequency:       Deploy multiple times per day
Documentation:   Pipeline IS the documentation
```

---

# 2. CI/CD Pipeline Stages

```text
┌──────────────────────────────────────────────────────────────┐
│                    TYPICAL CI/CD PIPELINE                    │
└──────────────────────────────────────────────────────────────┘

TRIGGER: Developer pushes to main branch
                    │
                    ▼
    ┌───────────────────────────────────┐
    │  BUILD STAGE (1-2 minutes)        │
    ├───────────────────────────────────┤
    │ ✓ Checkout code                   │
    │ ✓ Install dependencies            │
    │ ✓ Lint code (ESLint, Prettier)    │
    │ ✓ Type check (TypeScript)         │
    │ ✓ Unit tests                      │
    │ ✓ Build application               │
    │ ✓ Build Docker image              │
    └───────────────────────────────────┘
                    │
         (All pass? Continue)
                    │
                    ▼
    ┌───────────────────────────────────┐
    │  TEST STAGE (2-5 minutes)         │
    ├───────────────────────────────────┤
    │ ✓ Integration tests               │
    │ ✓ API tests                       │
    │ ✓ Database tests                  │
    │ ✓ Security scanning               │
    │ ✓ Code coverage check             │
    └───────────────────────────────────┘
                    │
         (All pass? Continue)
                    │
                    ▼
    ┌───────────────────────────────────┐
    │  DEPLOY STAGE (2-5 minutes)       │
    ├───────────────────────────────────┤
    │ ✓ Deploy to staging               │
    │ ✓ Run smoke tests                 │
    │ ✓ If staging OK:                  │
    │   Deploy to production            │
    │ ✓ Run post-deploy tests           │
    │ ✓ Notify team                     │
    └───────────────────────────────────┘
                    │
                    ▼
        Application is LIVE!
        Total time: 5-12 minutes
        Zero manual intervention
```

---

# 3. Quick Comparison: All 4 CI/CD Tools

```text
┌──────────────┬──────────────┬──────────────┬──────────────┬─────────────┐
│   Feature    │ GitHub       │ GitLab       │ CircleCI     │ Jenkins     │
│              │ Actions      │ CI           │              │             │
├──────────────┼──────────────┼──────────────┼──────────────┼─────────────┤
│ Platform     │ GitHub       │ GitLab       │ Cloud        │ Self-hosted │
│ Cost         │ FREE ✓       │ FREE ✓       │ FREE/Paid    │ FREE ✓      │
│ Setup        │ EASY ✓       │ Easy         │ Easy         │ Complex     │
│ Learning     │ EASIEST ✓    │ Easy         │ Easy         │ Hardest     │
│ Language     │ YAML         │ YAML         │ YAML         │ Groovy/YAML │
│ Community    │ HUGE ✓       │ Large        │ Medium       │ Large       │
│ Integrations │ 1000s ✓      │ Many         │ Many         │ 1000s       │
│ Docker       │ Native ✓     │ Native       │ Native       │ Need setup  │
│ Scaling      │ Unlimited    │ Unlimited    │ Paid         │ Your infra  │
│ Maintenance  │ None ✓       │ Minimal      │ None         │ High        │
│ Best For     │ Everyone ✓   │ GitLab users │ Cloud apps   │ Enterprises │
│ Job Market   │ HIGHEST ✓    │ High         │ Medium       │ High        │
└──────────────┴──────────────┴──────────────┴──────────────┴─────────────┘
```

---

# 4. My Recommendation: GitHub Actions

## Why Choose GitHub Actions?

```text
GITHUB ACTIONS IS BEST FOR LEARNING BECAUSE:

✓ COMPLETELY FREE
  └── No limits on free tier
  └── 2000 minutes/month per private repo
  └── Unlimited for public repos
  
✓ EASIEST TO SETUP
  └── Already in your GitHub repo
  └── No external platform needed
  └── Create .github/workflows/*.yml
  
✓ SIMPLE YAML SYNTAX
  └── Not a programming language
  └── Steep learning curve: FLAT
  └── Easy to understand & modify
  
✓ NATIVE GITHUB INTEGRATION
  └── Pull requests show status
  └── Commit status visible
  └── Secrets management built-in
  └── GitHub Issues/Projects integration
  
✓ FASTEST TO START
  └── Create workflow in 5 minutes
  └── Deploy to production in 15 minutes
  └── No infrastructure setup needed
  
✓ PERFECT FOR YOUR STACK
  └── Works with Terraform
  └── Works with Ansible
  └── Works with Vercel
  └── Works with Cloudflare
  └── Integrated with GitHub
  
✓ LARGEST JOB MARKET
  └── Most "CI/CD" jobs mention GitHub Actions
  └── Every company using GitHub uses Actions
  └── Skills directly transferable

ALTERNATIVE CONSIDERATIONS:

GitLab CI:
├── Better if: Your code is in GitLab
├── Advantage: Similar to GitHub Actions
└── Learning curve: Slightly more complex

CircleCI:
├── Better if: Need more advanced features
├── Advantage: Good free tier, great docs
└── Learning curve: Medium

Jenkins:
├── Better if: Large enterprise with infrastructure
├── Advantage: Most powerful & flexible
└── Learning curve: Steepest (Groovy DSL)
```

**FINAL ANSWER: Yes, choose GitHub Actions. Easiest & most practical.**

---

# 5. Quick Overview: GitLab CI

## What Is GitLab CI?

GitLab CI is GitLab's built-in CI/CD platform. Similar to GitHub Actions but integrated with GitLab.

## Simple GitLab CI Example

```yaml
# .gitlab-ci.yml

stages:
  - build
  - test
  - deploy

variables:
  NODE_ENV: production

build:
  stage: build
  image: node:18
  script:
    - npm ci
    - npm run build
  artifacts:
    paths:
      - dist/
    expire_in: 1 day

test:
  stage: test
  image: node:18
  script:
    - npm ci
    - npm run test
  coverage: '/Coverage: \d+\.\d+%/'

deploy:
  stage: deploy
  image: alpine:latest
  script:
    - echo "Deploying..."
    - npm run deploy
  only:
    - main
```

## GitLab CI Pros & Cons

```text
PROS:
✓ Free open-source option
✓ Full source control + CI/CD integration
✓ Powerful and flexible
✓ Self-hosted option available
✓ Similar syntax to GitHub Actions

CONS:
✗ Only works with GitLab repos
✗ Steeper learning curve than GitHub Actions
✗ Smaller community than GitHub/Jenkins
✗ Less common in job market
```

---

# 6. Quick Overview: CircleCI

## What Is CircleCI?

CircleCI is a cloud-based CI/CD platform supporting GitHub and Bitbucket repos.

## Simple CircleCI Example

```yaml
# .circleci/config.yml

version: 2.1

jobs:
  build:
    docker:
      - image: cimg/node:18.0
    steps:
      - checkout
      - run: npm ci
      - run: npm run build
      - persist_to_workspace:
          root: .
          paths:
            - dist/

  test:
    docker:
      - image: cimg/node:18.0
    steps:
      - checkout
      - attach_workspace:
          at: .
      - run: npm ci
      - run: npm test

  deploy:
    docker:
      - image: cimg/base:stable
    steps:
      - run: echo "Deploying..."
      - run: npm run deploy

workflows:
  build_and_deploy:
    jobs:
      - build
      - test:
          requires:
            - build
      - deploy:
          requires:
            - test
          filters:
            branches:
              only: main
```

## CircleCI Pros & Cons

```text
PROS:
✓ Free tier is generous
✓ Great documentation
✓ Works with GitHub & Bitbucket
✓ Good ecosystem
✓ Easy to use

CONS:
✗ Paid for advanced features
✗ Smaller community than GitHub Actions
✗ Fewer job opportunities
✗ Requires external platform
```

---

# 7. Quick Overview: Jenkins

## What Is Jenkins?

Jenkins is the most powerful CI/CD tool. Open-source, self-hosted, runs on your infrastructure.

## Simple Jenkins Example

```groovy
// Jenkinsfile

pipeline {
    agent any
    
    environment {
        NODE_ENV = 'production'
    }
    
    stages {
        stage('Build') {
            steps {
                sh 'npm ci'
                sh 'npm run build'
            }
        }
        
        stage('Test') {
            steps {
                sh 'npm test'
            }
        }
        
        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                sh 'npm run deploy'
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
```

## Jenkins Pros & Cons

```text
PROS:
✓ Most powerful & flexible
✓ Completely free (open-source)
✓ Huge plugin ecosystem (1000s)
✓ Works with any repo platform
✓ Full control over infrastructure
✓ Used in large enterprises
✓ Good job market

CONS:
✗ Steepest learning curve
✗ Requires infrastructure setup
✗ Requires maintenance & updates
✗ Complex Groovy DSL language
✗ Self-hosted = your responsibility
✗ Overkill for small projects
✗ DevOps intensive
```

---

# 8. GitHub Actions: Detailed Guide

Since GitHub Actions is the best choice for you, here's the detailed guide.

## What Is GitHub Actions?

GitHub Actions is GitHub's native CI/CD platform. Automate workflows directly in your GitHub repository using YAML files.

## How GitHub Actions Works

```text
1. WRITE WORKFLOW
   └─ Create .github/workflows/deploy.yml

2. TRIGGER EVENT
   └─ Push to main branch
   └─ Pull request opened
   └─ Schedule (cron)
   └─ Manual dispatch

3. RUN JOBS
   └─ Job 1: Build & test (parallel)
   └─ Job 2: Deploy (after job 1)

4. STEPS IN JOBS
   └─ Checkout code
   └─ Install dependencies
   └─ Run tests
   └─ Deploy

5. REPORT STATUS
   └─ Show in PR
   └─ Show in commit
   └─ Send notifications
```

## GitHub Actions File Structure

```text
.github/
└── workflows/
    ├── build.yml              ← Build & test workflow
    ├── deploy.yml             ← Deploy workflow
    ├── security-scan.yml      ← Security scanning
    └── cron-jobs.yml          ← Scheduled tasks
```

## Core Concepts

```text
WORKFLOW:      YAML file defining automation
TRIGGER:       Event that starts workflow (push, PR, schedule)
JOB:           Set of steps running on one runner
STEP:          Individual action or script
ACTION:        Reusable unit of code
RUNNER:        Machine executing the workflow
SECRET:        Encrypted environment variable
ARTIFACT:      Files to keep after job completes
CONTEXT:       Information available during workflow
```

## GitHub Actions Pricing

```text
FREE TIER:
├── 2,000 minutes/month per private repo
├── Unlimited for public repos
├── Unlimited jobs
├── Standard runners (Linux, Windows, macOS)
└── Perfect for learning & small projects

PAID:
├── $0.008 per minute beyond 2,000
├── Can buy larger runners
└── For companies with high CI/CD volume
```

---

# 9. Simple GitHub Actions Workflow

## Basic Example: Build & Test

```yaml
# .github/workflows/build.yml

name: Build & Test

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        node-version: [16, 18, 20]
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Setup Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v3
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Lint code
        run: npm run lint
      
      - name: Run tests
        run: npm test
      
      - name: Build application
        run: npm run build
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/coverage-final.json
      
      - name: Upload build artifacts
        uses: actions/upload-artifact@v3
        with:
          name: build-${{ matrix.node-version }}
          path: dist/
```

## Workflow Features Explained

```yaml
name: Build & Test                    # Workflow name shown in GitHub

on:                                   # Trigger events
  push:
    branches: [ main, develop ]       # Run on push to main/develop
  pull_request:
    branches: [ main ]                # Run on PR to main

jobs:
  build:                              # Job name
    runs-on: ubuntu-latest            # Runner OS (ubuntu/windows/macos)
    
    strategy:
      matrix:                         # Matrix for multiple versions
        node-version: [16, 18, 20]    # Test on 3 Node versions
    
    steps:                            # Steps in this job
      - uses: actions/checkout@v3     # Use a pre-built action
      - run: npm ci                   # Run shell command
```

---

# 10. Real-World: Deploy to Production

## Complete Deploy Workflow (Integrated with Your Stack)

```yaml
# .github/workflows/deploy.yml

name: Build, Test & Deploy

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}/blog-app

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    outputs:
      image-tag: ${{ steps.meta.outputs.tags }}
    
    permissions:
      contents: read
      packages: write
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Lint code
        run: npm run lint
      
      - name: Run unit tests
        run: npm run test
      
      - name: Build application
        run: npm run build
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      
      - name: Log in to Container Registry
        uses: docker/login-action@v2
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v4
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=semver,pattern={{version}}
            type=sha,prefix={{branch}}-
      
      - name: Build and push Docker image
        uses: docker/build-push-action@v4
        with:
          context: .
          push: ${{ github.event_name != 'pull_request' }}
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
      
      - name: Run integration tests
        run: npm run test:integration

  deploy-infrastructure:
    needs: build-and-test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.0
      
      - name: Terraform Init
        run: |
          cd terraform
          terraform init \
            -backend-config="bucket=${{ secrets.TF_STATE_BUCKET }}" \
            -backend-config="key=prod/terraform.tfstate" \
            -backend-config="region=us-east-1"
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      
      - name: Terraform Plan
        run: |
          cd terraform
          terraform plan \
            -var-file="environments/prod.tfvars" \
            -out=tfplan
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      
      - name: Terraform Apply
        run: |
          cd terraform
          terraform apply -auto-approve tfplan
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      
      - name: Get Terraform Outputs
        id: tf
        run: |
          cd terraform
          echo "instance_ips=$(terraform output -raw instance_ips)" >> $GITHUB_OUTPUT
          echo "load_balancer_dns=$(terraform output -raw load_balancer_dns)" >> $GITHUB_OUTPUT
      
      - name: Save outputs for Ansible
        run: |
          echo "${{ steps.tf.outputs.instance_ips }}" > /tmp/instance_ips.txt

  configure-servers:
    needs: deploy-infrastructure
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Setup Ansible
        run: |
          pip install ansible boto3
      
      - name: Setup SSH key
        run: |
          mkdir -p ~/.ssh
          echo "${{ secrets.ANSIBLE_SSH_KEY }}" > ~/.ssh/id_rsa
          chmod 600 ~/.ssh/id_rsa
          ssh-keyscan -H 10.0.1.10 >> ~/.ssh/known_hosts
          ssh-keyscan -H 10.0.1.11 >> ~/.ssh/known_hosts
          ssh-keyscan -H 10.0.1.12 >> ~/.ssh/known_hosts
      
      - name: Generate Ansible inventory
        run: |
          cat > ansible/inventory/hosts.ini <<EOF
          [app_servers]
          app-1 ansible_host=10.0.1.10 ansible_user=ubuntu
          app-2 ansible_host=10.0.1.11 ansible_user=ubuntu
          app-3 ansible_host=10.0.1.12 ansible_user=ubuntu
          
          [all:vars]
          ansible_ssh_private_key_file=~/.ssh/id_rsa
          database_host=${{ secrets.DB_HOST }}
          EOF
      
      - name: Run Ansible playbook
        run: |
          cd ansible
          ansible-playbook playbooks/deploy.yml \
            -i inventory/hosts.ini \
            -u ubuntu
        env:
          ANSIBLE_HOST_KEY_CHECKING: 'False'

  deploy-frontend:
    needs: build-and-test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Deploy to Vercel
        uses: vercel/action@master
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          production: true

  deploy-cloudflare-worker:
    needs: build-and-test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install Wrangler
        run: npm install -g wrangler
      
      - name: Deploy Worker
        run: |
          cd cloudflare-worker
          wrangler publish
        env:
          CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}

  smoke-tests:
    needs: [deploy-infrastructure, configure-servers, deploy-frontend]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Wait for deployment
        run: sleep 30
      
      - name: Test API health
        run: |
          curl -f https://api.example.com/health || exit 1
      
      - name: Test frontend
        run: |
          curl -f https://example.com || exit 1
      
      - name: Run smoke tests
        run: npm run test:smoke
      
      - name: Slack notification on success
        if: success()
        uses: slackapi/slack-github-action@v1
        with:
          webhook-url: ${{ secrets.SLACK_WEBHOOK }}
          payload: |
            {
              "text": "✅ Deployment successful!",
              "blocks": [
                {
                  "type": "section",
                  "text": {
                    "type": "mrkdwn",
                    "text": "✅ Production deployment successful!\nCommit: ${{ github.sha }}\nAuthor: ${{ github.actor }}"
                  }
                }
              ]
            }
      
      - name: Slack notification on failure
        if: failure()
        uses: slackapi/slack-github-action@v1
        with:
          webhook-url: ${{ secrets.SLACK_WEBHOOK }}
          payload: |
            {
              "text": "❌ Deployment failed!",
              "blocks": [
                {
                  "type": "section",
                  "text": {
                    "type": "mrkdwn",
                    "text": "❌ Production deployment FAILED!\nCommit: ${{ github.sha }}\nAuthor: ${{ github.actor }}\nCheck logs: ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}"
                  }
                }
              ]
            }
```

---

# 11. GitHub Actions: Using Secrets

Secrets are encrypted environment variables for sensitive data.

## Setting Secrets in GitHub

```text
1. Go to GitHub repo settings
2. Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Add secret:
   └─ Name: AWS_ACCESS_KEY_ID
   └─ Value: AKIAIOSFODNN7EXAMPLE
5. Click "Add secret"
```

## Using Secrets in Workflow

```yaml
- name: Deploy to AWS
  run: terraform apply
  env:
    AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
    AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    TF_VAR_db_password: ${{ secrets.DB_PASSWORD }}
```

## Common Secrets to Store

```text
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
DATABASE_PASSWORD
API_KEYS
SSH_PRIVATE_KEY
SLACK_WEBHOOK
VERCEL_TOKEN
CLOUDFLARE_API_TOKEN
DOCKER_USERNAME
DOCKER_PASSWORD
```

## Never Commit

```bash
# .gitignore - Don't commit these

.env                    # Local environment variables
.env.local             # Local secrets
.env.production        # Production secrets
*.pem                  # Private keys
id_rsa                 # SSH keys
secrets/               # Secrets directory
```

---

# 12. Common GitHub Actions Patterns

## Pattern 1: Run on Schedule (Cron)

```yaml
name: Nightly Backup

on:
  schedule:
    - cron: '0 2 * * *'  # 2 AM daily
  workflow_dispatch:      # Manual trigger

jobs:
  backup:
    runs-on: ubuntu-latest
    steps:
      - name: Backup database
        run: |
          aws s3 cp database.backup.sql s3://backups/
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

## Pattern 2: Manual Trigger (Workflow Dispatch)

```yaml
name: Manual Deployment

on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Deployment environment'
        required: true
        default: 'staging'
        type: choice
        options:
          - staging
          - production

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to ${{ github.event.inputs.environment }}
        run: echo "Deploying to ${{ github.event.inputs.environment }}"
```

## Pattern 3: Conditional Jobs

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - run: npm test

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    steps:
      - run: echo "Deploying to production"
```

## Pattern 4: Reusable Workflows

```yaml
# .github/workflows/deploy.yml

name: Deploy Application

on: [push]

jobs:
  deploy:
    uses: ./.github/workflows/deploy-reusable.yml
    with:
      environment: production
    secrets:
      aws_access_key: ${{ secrets.AWS_ACCESS_KEY_ID }}
```

---

# 13. GitHub Actions Marketplace

GitHub Actions Marketplace provides pre-built actions for common tasks.

## Popular Actions

```text
CHECKOUT:
└── actions/checkout@v3
    Checks out your code

SETUP TOOLS:
├── actions/setup-node@v3        (Node.js)
├── actions/setup-python@v4      (Python)
├── hashicorp/setup-terraform@v2 (Terraform)
└── aws-actions/configure-aws-credentials@v2 (AWS)

BUILD & DEPLOY:
├── docker/build-push-action@v4  (Docker)
├── vercel/action@master         (Vercel)
└── actions/deploy-pages@v2      (GitHub Pages)

TESTING & COVERAGE:
├── codecov/codecov-action@v3    (Code coverage)
├── actions/upload-artifact@v3   (Artifacts)
└── dorny/test-reporter@v1       (Test reports)

NOTIFICATIONS:
├── slackapi/slack-github-action@v1 (Slack)
├── dawidd6/action-send-mail@v3     (Email)
└── ngneat/put-pr-comment-action@v2 (PR comments)
```

## Using Marketplace Actions

```yaml
steps:
  - name: Checkout code
    uses: actions/checkout@v3  # Marketplace action
  
  - name: Setup Node.js
    uses: actions/setup-node@v3
    with:
      node-version: '18'
      cache: 'npm'  # Parameters
  
  - name: Build Docker image
    uses: docker/build-push-action@v4
    with:
      context: .
      push: true
      tags: myimage:latest
```

---

# 14. Complete .github Directory Structure

```text
.github/
├── workflows/
│   ├── build.yml                 # Build & test
│   ├── deploy.yml                # Deploy to production
│   ├── security-scan.yml         # Security checks
│   ├── cron-jobs.yml             # Scheduled tasks
│   └── nightly-backup.yml        # Nightly backup
│
├── ISSUE_TEMPLATE/
│   ├── bug_report.md
│   ├── feature_request.md
│   └── config.yml
│
└── pull_request_template.md

Plus at root:
├── .gitignore
├── .gitattributes
└── CODEOWNERS              # Code review approvals
```

---

# 15. Real-World Workflow: Blog Application

Complete workflow file integrating everything:

```yaml
# .github/workflows/deploy-complete.yml

name: Complete Deploy Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  workflow_dispatch:
    inputs:
      deploy_to:
        type: choice
        options: [staging, production]
        default: staging

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}/blog-app
  NODE_ENV: production

jobs:
  # ===== BUILD & TEST =====
  build:
    name: Build & Test
    runs-on: ubuntu-latest
    outputs:
      image-uri: ${{ steps.image.outputs.uri }}
    
    steps:
      - uses: actions/checkout@v3
      
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: npm
      
      - name: Install dependencies
        run: npm ci
      
      - name: Lint
        run: npm run lint
      
      - name: Type check
        run: npm run type-check
      
      - name: Run tests
        run: npm test -- --coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
      
      - name: Build application
        run: npm run build
      
      - name: Build Docker image
        uses: docker/setup-buildx-action@v2
      
      - name: Login to Registry
        uses: docker/login-action@v2
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Build & Push image
        id: image
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
          cache-from: type=registry,ref=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:buildcache
          cache-to: type=registry,ref=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:buildcache,mode=max
  
  # ===== SECURITY =====
  security:
    name: Security Scan
    runs-on: ubuntu-latest
    needs: build
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Run Trivy vulnerability scan
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ needs.build.outputs.image-uri }}
          format: 'sarif'
          output: 'trivy-results.sarif'
      
      - name: Upload Trivy results
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'
  
  # ===== TERRAFORM =====
  terraform:
    name: Terraform Plan
    runs-on: ubuntu-latest
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    outputs:
      instance-ips: ${{ steps.tf.outputs.instance_ips }}
    
    steps:
      - uses: actions/checkout@v3
      
      - uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.0
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      
      - name: Terraform Init
        working-directory: terraform
        run: terraform init
      
      - name: Terraform Plan
        id: plan
        working-directory: terraform
        run: terraform plan -var-file=environments/prod.tfvars -json > tfplan.json
      
      - name: Terraform Apply
        id: tf
        working-directory: terraform
        run: |
          terraform apply -auto-approve -var-file=environments/prod.tfvars
          echo "instance_ips=$(terraform output -raw instance_ips)" >> $GITHUB_OUTPUT
      
      - name: Comment PR with plan
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v6
        with:
          script: |
            const fs = require('fs');
            const plan = fs.readFileSync('terraform/tfplan.json', 'utf8');
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `Terraform Plan:\n\`\`\`\n${plan}\n\`\`\``
            })
  
  # ===== ANSIBLE =====
  ansible:
    name: Configure Servers
    runs-on: ubuntu-latest
    needs: terraform
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Install Ansible
        run: pip install ansible boto3
      
      - name: Setup SSH key
        run: |
          mkdir -p ~/.ssh
          echo "${{ secrets.ANSIBLE_SSH_KEY }}" > ~/.ssh/id_rsa
          chmod 600 ~/.ssh/id_rsa
          ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
      
      - name: Generate inventory
        run: |
          cat > ansible/inventory/hosts.ini << EOF
          [app_servers]
          ${{ needs.terraform.outputs.instance-ips }}
          
          [all:vars]
          ansible_python_interpreter=/usr/bin/python3
          database_host=${{ secrets.DB_HOST }}
          EOF
      
      - name: Run Ansible
        working-directory: ansible
        run: |
          ansible-playbook playbooks/deploy.yml \
            -i inventory/hosts.ini \
            -u ubuntu \
            -e "docker_image=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}"
        env:
          ANSIBLE_HOST_KEY_CHECKING: 'False'
  
  # ===== VERCEL =====
  deploy-frontend:
    name: Deploy Frontend
    runs-on: ubuntu-latest
    needs: build
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    
    steps:
      - uses: actions/checkout@v3
      
      - uses: vercel/action@master
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          production: true
          scope: ${{ secrets.VERCEL_ORG_ID }}
  
  # ===== CLOUDFLARE =====
  deploy-worker:
    name: Deploy Cloudflare Worker
    runs-on: ubuntu-latest
    needs: build
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    
    steps:
      - uses: actions/checkout@v3
      
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install Wrangler
        run: npm install -g wrangler
      
      - name: Deploy Worker
        working-directory: cloudflare-worker
        run: wrangler publish
        env:
          CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}
  
  # ===== SMOKE TESTS =====
  smoke-tests:
    name: Smoke Tests
    runs-on: ubuntu-latest
    needs: [ansible, deploy-frontend, deploy-worker]
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    
    steps:
      - uses: actions/checkout@v3
      
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - run: npm ci
      
      - name: Wait for deployment
        run: sleep 60
      
      - name: Health check
        run: |
          curl -f https://api.example.com/health || exit 1
          curl -f https://example.com || exit 1
      
      - name: Smoke tests
        run: npm run test:smoke
      
      - name: Notify Slack
        if: always()
        uses: slackapi/slack-github-action@v1
        with:
          webhook-url: ${{ secrets.SLACK_WEBHOOK }}
          payload: |
            {
              "text": "${{ job.status == 'success' && '✅' || '❌' }} Deployment ${{ job.status }}",
              "blocks": [
                {
                  "type": "section",
                  "text": {
                    "type": "mrkdwn",
                    "text": "*Deployment ${{ job.status }}*\n\nCommit: <${{ github.server_url }}/${{ github.repository }}/commit/${{ github.sha }}|${{ github.sha }}>\nAuthor: ${{ github.actor }}"
                  }
                }
              ]
            }
```

---

# 16. Learning Path for GitHub Actions

## Week 1: Basics

```text
DAY 1:
├── Create first workflow
├── Trigger on push
├── Run simple commands
└── See results

DAY 2:
├── Learn workflow syntax
├── Learn jobs & steps
├── Learn matrix builds
└── Test on multiple versions

DAY 3:
├── Learn secrets
├── Learn artifacts
├── Upload test results
└── Cache dependencies

DAY 4-5:
├── Learn Marketplace actions
├── Use setup-node, setup-python
├── Deploy to GitHub Pages
└── Project: Build & test workflow
```

## Week 2: Intermediate

```text
DAY 6-7:
├── Learn Docker in Actions
├── Build & push images
├── Deploy to AWS
├── Use Terraform

DAY 8-9:
├── Learn deployment workflows
├── Vercel deployment
├── Cloudflare deployment
└── Staging → production

DAY 10-12:
├── Complete CI/CD pipeline
├── Integrate all tools
├── Test, build, deploy
└── Project: Full pipeline
```

## Week 3: Advanced

```text
DAY 13-14:
├── Scheduled jobs (cron)
├── Manual triggers
├── Reusable workflows
├── Advanced notifications

DAY 15:
├── Production best practices
├── Security scanning
├── Performance optimization
└── Monitoring & observability
```

## Project Ideas

```text
PROJECT 1 (Week 1):
└── Build & test on every push

PROJECT 2 (Week 2):
├── Build, test, deploy to staging
└── Manual approval to production

PROJECT 3 (Week 2-3):
├── Full pipeline: Build → Test → Deploy (Infra + App)
├── Multiple environments
└── With notifications

PROJECT 4 (Week 3):
├── Blog application (from integrated lesson)
├── Terraform + Ansible + Vercel + Cloudflare
└── Complete CI/CD automation
```

---

# 17. GitHub Actions Best Practices

```text
WORKFLOW BEST PRACTICES:

DO:
✓ Use descriptive names for workflows & jobs
✓ Separate concerns into different workflows
✓ Use matrix builds for multiple versions
✓ Cache dependencies (npm, pip, etc)
✓ Use actions from Marketplace
✓ Keep secrets in GitHub Secrets
✓ Use environment variables for config
✓ Document your workflows
✓ Test workflows before production
✓ Use branch protection rules
✓ Require workflow status checks
✓ Use concurrency to prevent duplicates

DON'T:
✗ Hardcode secrets in workflows
✗ Run tests on every trivial change
✗ Make workflows too complex
✗ Commit .env files with secrets
✗ Use old/unmaintained actions
✗ Ignore workflow failures
✗ Remove security checks for speed
✗ Deploy without tests passing
✗ Manual deployment to production
✗ Ignore notifications

PERFORMANCE:

✓ Cache node_modules to save 2-3 minutes
✓ Parallelize jobs where possible
✓ Use matrix builds efficiently
✓ Cancel in-progress runs on new push
✓ Use smallest runners possible
✓ Keep steps simple and focused
```

## Example: Performance Optimized Workflow

```yaml
name: Fast CI/CD

on: [push, pull_request]

concurrency:
  group: ${{ github.workflow }}-${{ github.head_ref || github.run_id }}
  cancel-in-progress: true

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0
      
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: npm
      
      - name: Install
        run: npm ci
      
      - name: Lint
        run: npm run lint
      
      - name: Test
        run: npm test
      
      - name: Build
        run: npm run build
```

---

# 18. Troubleshooting Common Issues

```text
WORKFLOW WON'T TRIGGER:
├── Check event triggers (on: push/pull_request)
├── Check branch filters (branches: [main])
├── Check commit message (if filtering on commit)
├── Verify workflow file in .github/workflows/
└── Restart workflow manually

JOBS FAILING:
├── Check step failure messages
├── Run workflow with debug logging
├── Test commands locally first
├── Check secret names are correct
├── Verify action versions (@v3 is latest)
└── Check GitHub Actions logs

SLOW WORKFLOW:
├── Add caching for dependencies
├── Parallelize jobs (needs:)
├── Use matrix efficiently
├── Check for timeouts
├── Use self-hosted runners for long jobs
└── Optimize Docker builds

SECRET NOT FOUND:
├── Verify secret name exactly
├── Check syntax: ${{ secrets.SECRET_NAME }}
├── Ensure secret set in repo settings
├── Check permissions for accessing secret
└── Verify workflow has correct scope
```

---

# Quick Reference: GitHub Actions Commands

```bash
# List workflows
gh workflow list

# View workflow status
gh run list --workflow=deploy.yml

# View run logs
gh run view <RUN_ID> --log

# Cancel a run
gh run cancel <RUN_ID>

# Trigger workflow manually
gh workflow run deploy.yml

# View job logs
gh run view <RUN_ID> --log --job=build

# List artifacts
gh run download <RUN_ID>

# View secrets
gh secret list

# Create secret
gh secret set SECRET_NAME --body "secret-value"

# Delete secret
gh secret delete SECRET_NAME
```

---

# Summary: GitHub Actions Decision

```
┌─────────────────────────────────────────────────┐
│                                                 │
│  ✓ CHOICE: GITHUB ACTIONS                      │
│  ✓ COST: FREE                                  │
│  ✓ LEARNING TIME: 1-2 weeks for basics        │
│  ✓ NO EXTERNAL PLATFORM: In your GitHub repo  │
│  ✓ CAREER VALUE: Highest (GitHub ubiquitous)  │
│  ✓ INTEGRATION: Perfect with Terraform,       │
│    Ansible, Vercel, Cloudflare, Docker        │
│  ✓ START: Today in .github/workflows/          │
│                                                 │
│  Why not GitLab CI?                            │
│  └─ Only for GitLab repos                      │
│                                                 │
│  Why not CircleCI?                             │
│  └─ Paid for advanced, less integrated        │
│                                                 │
│  Why not Jenkins?                              │
│  └─ Complex, needs infrastructure             │
│                                                 │
│  PERFECT INTEGRATION:                          │
│  ├─ GitHub Actions (this lesson)              │
│  ├─ Terraform (provision infra)               │
│  ├─ Ansible (configure servers)               │
│  ├─ Vercel (deploy frontend)                  │
│  ├─ Cloudflare (edge caching)                 │
│  └─ All connected in one pipeline!            │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

# Resources & Learning

## Official Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Actions Quickstart](https://docs.github.com/en/actions/quickstart)
- [Workflow Syntax Reference](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [GitHub Actions Marketplace](https://github.com/marketplace?type=actions)
- [GitHub Actions Best Practices](https://docs.github.com/en/actions/guides)

## Learning Resources

- [GitHub Skills - CI/CD](https://skills.github.com/)
- [Actions in the Real World](https://github.blog/category/actions/)
- [GitHub Actions Examples](https://github.com/actions)
- [Popular Actions](https://github.com/search?q=topic%3Agithub-actions&type=Repositories)

## Community

- [GitHub Discussions - Actions](https://github.com/github/community/discussions)
- [Stack Overflow #github-actions](https://stackoverflow.com/questions/tagged/github-actions)
- [GitHub Actions Slack Community](https://github-actions.slack.com/)

---

**Last Updated:** August 24, 2026
**Curated for:** DevOps Learning Path
**Integration:** Connects with Terraform, Ansible, Vercel, Cloudflare, AWS
**Recommendation:** Choose GitHub Actions & start today!
**Perfect for:** Your blog application from integrated-devops-project.md
