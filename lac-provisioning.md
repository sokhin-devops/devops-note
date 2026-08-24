# Infrastructure as Code (IaC) & Provisioning

## AWS CDK, CloudFormation, Pulumi & Terraform

Infrastructure as Code allows you to define and manage cloud infrastructure using code instead of clicking buttons in the cloud console.

The main provisioning tools covered in this guide are:

* AWS CDK (Cloud Development Kit)
* AWS CloudFormation
* Pulumi
* Terraform

---

# 1. What Is Infrastructure as Code?

## Manual Infrastructure (The Old Way)

```text
DevOps Engineer
     │
     ▼
Open AWS Console
     │
     ├── Click EC2
     ├── Launch Instance
     ├── Configure Security Groups
     ├── Attach Storage
     ├── Add Load Balancer
     ├── Setup Database
     └── Configure Networking
     
Problems:
├── Slow
├── Error-prone
├── Hard to reproduce
├── No version control
└── Takes hours to setup
```

## Infrastructure as Code (The New Way)

```text
Developer
     │
     ▼
Write Code (main.tf / cdk.py)
     │
     ├── Version control (git)
     ├── Code review
     └── Automated testing
     │
     ▼
Run: terraform apply / cdk deploy
     │
     ▼
Entire infrastructure provisioned
     │
     └── Seconds/minutes
     └── Reproducible
     └── Auditable
```

## Benefits of IaC

```text
IaC ADVANTAGES:

Speed:           Deploy infrastructure in minutes
Reproducibility: Same config = same infrastructure
Version Control: Track all changes in git
Code Review:     Team reviews infrastructure changes
Testing:         Validate infrastructure before deploy
Disaster Recovery: Rebuild entire stack from code
Cost Control:    Easy to tear down unused resources
Documentation:   Code IS the documentation
Scalability:     Copy code to scale
Compliance:      Enforce standards in code
```

---

# 2. Quick Comparison: All 4 Tools

```text
┌──────────────┬──────────────┬──────────────┬──────────────┬──────────────┐
│   Feature    │ Terraform    │ AWS CDK      │CloudFormation│   Pulumi     │
├──────────────┼──────────────┼──────────────┼──────────────┼──────────────┤
│ Language     │ HCL (custom) │ Python/JS/TS │ JSON/YAML    │ Python/Go/TS │
│ Cost         │ FREE ✓       │ FREE ✓       │ FREE ✓       │ Free/paid    │
│ Multi-cloud  │ YES ✓        │ AWS only     │ AWS only     │ YES ✓        │
│ Learning     │ Easy         │ Medium       │ Hard         │ Medium       │
│ Community    │ HUGE ✓       │ Growing      │ Declining    │ Growing      │
│ Jobs         │ MOST ✓       │ Many         │ Some         │ Few          │
│ State File   │ YES          │ YES          │ NO (backend) │ YES          │
│ Syntax       │ Readable ✓   │ Programmatic │ Verbose      │ Programmatic │
│ Modules      │ YES ✓        │ Constructs   │ Templates    │ Packages     │
│ Best For     │ Everything   │ AWS experts  │ AWS legacy   │ Multi-cloud  │
│ Maturity     │ Very stable  │ Stable       │ Mature       │ Growing      │
└──────────────┴──────────────┴──────────────┴──────────────┴──────────────┘
```

---

# 3. My Recommendation: Terraform (For You)

## Why Choose Terraform?

```text
TERRAFORM IS BEST FOR LEARNING BECAUSE:

✓ Completely FREE & open-source
✓ Largest community (most questions answered on StackOverflow)
✓ MOST job opportunities in DevOps/Cloud
✓ Works with ANY cloud provider (AWS, Azure, GCP, etc.)
✓ Skills transfer everywhere (not locked to AWS)
✓ Easy to learn (HCL is readable)
✓ Huge ecosystem of modules
✓ Fastest adoption rate in industry
✓ Perfect for multi-cloud strategies
✓ Your learning investment pays off in any job

ALTERNATIVE CONSIDERATIONS:

AWS CDK:
├── Better if: You're AWS-only long-term
├── Advantage: More powerful for complex AWS infrastructure
└── Learning curve: Steeper

Pulumi:
├── Better if: You want to code in Python/Go
├── Advantage: More programming language flexible
└── Community: Smaller than Terraform

CloudFormation:
├── Better if: You work exclusively with AWS
├── Advantage: None (use CDK or Terraform instead)
└── Status: Legacy, not recommended for new projects
```

**FINAL ANSWER: Yes, choose Terraform. It's the industry standard.**

---

# 4. Quick Overview: AWS CDK

## What Is AWS CDK?

AWS CDK is a framework for building AWS infrastructure using programming languages like Python, JavaScript, or TypeScript.

```text
Write Python Code → CDK Synthesizes → CloudFormation Template → Deploy
```

## CDK Example (Python)

```python
from aws_cdk import (
    aws_ec2 as ec2,
    aws_s3 as s3,
    core
)

class MyStack(core.Stack):
    def __init__(self, scope: core.Construct, id: str, **kwargs):
        super().__init__(scope, id, **kwargs)
        
        # Create S3 bucket
        bucket = s3.Bucket(self, "MyBucket",
            versioned=True,
            removal_policy=core.RemovalPolicy.DESTROY
        )
        
        # Create EC2 instance
        vpc = ec2.Vpc(self, "MyVpc", max_azs=2)
        instance = ec2.Instance(self, "MyInstance",
            instance_type=ec2.InstanceType("t2.micro"),
            machine_image=ec2.AmazonLinuxImage(),
            vpc=vpc
        )

app = core.App()
MyStack(app, "my-stack")
app.synth()
```

## CDK Pros & Cons

```text
PROS:
✓ Full programming language power
✓ Excellent for AWS power users
✓ Type safety (TypeScript)
✓ AWS-native constructs
✓ No state file management

CONS:
✗ AWS-only (not multi-cloud)
✗ Steeper learning curve
✗ Less community support than Terraform
✗ Requires understanding CloudFormation
✗ Not ideal for beginners
```

---

# 5. Quick Overview: CloudFormation

## What Is CloudFormation?

CloudFormation is AWS's native IaC service. Infrastructure defined in JSON or YAML.

## CloudFormation Example

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Resources:
  MyBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: my-bucket-12345
      VersioningConfiguration:
        Status: Enabled
      
  MySecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: My security group
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 80
          ToPort: 80
          CidrIp: 0.0.0.0/0

Outputs:
  BucketName:
    Value: !Ref MyBucket
```

## CloudFormation Pros & Cons

```text
PROS:
✓ AWS-native
✓ No additional tool to learn
✓ Fine-grained control
✓ Well documented

CONS:
✗ Verbose JSON/YAML syntax
✗ Hard to read & maintain
✗ Limited reusability
✗ Steep learning curve
✗ AWS-only (not multi-cloud)
✗ Legacy (use CDK instead)
✗ NOT RECOMMENDED for new projects
```

---

# 6. Quick Overview: Pulumi

## What Is Pulumi?

Pulumi is infrastructure as code using real programming languages (Python, Go, TypeScript).

## Pulumi Example (Python)

```python
import pulumi
import pulumi_aws as aws

# Create S3 bucket
bucket = aws.s3.Bucket('my-bucket',
    versioning=aws.s3.BucketVersioningArgs(
        enabled=True,
    )
)

# Create EC2 instance
instance = aws.ec2.Instance('my-instance',
    ami='ami-0c55b159cbfafe1f0',
    instance_type='t2.micro'
)

# Export outputs
pulumi.export('bucket_name', bucket.id)
pulumi.export('instance_id', instance.id)
```

## Pulumi Pros & Cons

```text
PROS:
✓ Real programming languages
✓ Multi-cloud support
✓ Strong type checking (TypeScript)
✓ Good documentation
✓ Growing community

CONS:
✗ Smaller community than Terraform
✗ Fewer module/package ecosystem
✗ Fewer DevOps jobs requiring Pulumi
✗ State management similar to Terraform
✗ Less proven in production at scale
```

---

# 7. Terraform: Detailed Guide

Since Terraform is the best choice for you, here's the detailed guide.

## What Is Terraform?

Terraform is an open-source Infrastructure as Code tool by HashiCorp. Define infrastructure in HCL (HashiCorp Configuration Language) and deploy to any cloud.

## How Terraform Works

```text
1. WRITE
   └─ main.tf (Your infrastructure code)

2. INIT
   └─ terraform init
   └─ Downloads provider plugins (AWS, Azure, GCP, etc.)

3. PLAN
   └─ terraform plan
   └─ Shows what will be created/changed/destroyed

4. APPLY
   └─ terraform apply
   └─ Creates actual infrastructure in cloud

5. DESTROY
   └─ terraform destroy
   └─ Tears down all resources
```

## Terraform Core Concepts

```text
PROVIDER:        Where to provision (AWS, Azure, GCP, etc.)
RESOURCE:        Something to create (EC2, S3 bucket, etc.)
VARIABLE:        Input values (like function parameters)
OUTPUT:          Export values after creation
STATE FILE:      Terraform's memory (stores current state)
MODULE:          Reusable infrastructure code
BACKEND:         Where to store state file (S3, Terraform Cloud, etc.)
```

## Terraform File Structure

```text
project/
├── main.tf           ← Main configuration
├── variables.tf      ← Variable definitions
├── outputs.tf        ← Output definitions
├── terraform.tfvars  ← Variable values (local)
├── .terraform/       ← Downloaded plugins (auto-generated)
├── terraform.tfstate ← Current state (auto-generated)
└── README.md         ← Documentation
```

## Basic Terraform Example

### Setup: main.tf

```hcl
# Configure AWS provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Create S3 bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-unique-bucket-name-12345"
  
  tags = {
    Name        = "My Bucket"
    Environment = "dev"
  }
}

# Enable versioning
resource "aws_s3_bucket_versioning" "my_bucket_versioning" {
  bucket = aws_s3_bucket.my_bucket.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Create EC2 instance
resource "aws_instance" "my_instance" {
  ami           = "ami-0c55b159cbfafe1f0"  # Ubuntu 20.04 in us-east-1
  instance_type = "t2.micro"
  
  tags = {
    Name = "My Instance"
  }
}
```

### Define Variables: variables.tf

```hcl
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
  # No default - must be provided
}
```

### Define Outputs: outputs.tf

```hcl
output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.my_bucket.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.my_bucket.arn
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.my_instance.id
}

output "instance_public_ip" {
  description = "Public IP of the instance"
  value       = aws_instance.my_instance.public_ip
}
```

### Provide Values: terraform.tfvars

```hcl
aws_region   = "us-east-1"
environment  = "dev"
instance_type = "t2.micro"
bucket_name  = "my-unique-bucket-name-12345"
```

## Terraform Workflow

```bash
# 1. Initialize Terraform (download plugins)
terraform init

# 2. Preview what will be created
terraform plan

# 3. Review plan output, then apply
terraform apply

# 4. Terraform creates resources in AWS

# 5. View current state
terraform state list
terraform state show aws_s3_bucket.my_bucket

# 6. When done, destroy everything
terraform destroy
```

## Terraform State File

```text
STATE FILE: terraform.tfstate

Contains:
├── Resource IDs (created in cloud)
├── Resource properties
├── Dependencies between resources
└── Metadata

WARNING:
├── Never commit to git (contains sensitive data)
├── Add to .gitignore
├── Store remotely (S3, Terraform Cloud, etc.)
├── Team members need access to same state
└── Locking prevents concurrent modifications
```

## Example: .gitignore for Terraform

```
# Local .terraform directories
**/.terraform/*

# .tfstate files
*.tfstate
*.tfstate.*

# Crash dump logs
crash.log
crash.*.log

# Exclude all .tfvars files (local) but not .tfvars.example
*.tfvars
*.tfvars.json
!example.tfvars

# Ignore override files
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Ignore CLI configuration files
.terraformrc
terraform.rc
```

## More Complex Example: Full Web Stack

```hcl
# variables.tf
variable "app_name" {
  type    = string
  default = "myapp"
}

variable "environment" {
  type    = string
  default = "dev"
}

# main.tf
provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  
  tags = {
    Name = "${var.app_name}-vpc"
  }
}

# Subnet
resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  
  tags = {
    Name = "${var.app_name}-subnet"
  }
}

# Security Group
resource "aws_security_group" "web" {
  name   = "${var.app_name}-sg"
  vpc_id = aws_vpc.main.id
  
  # Allow HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${var.app_name}-sg"
  }
}

# EC2 Instance
resource "aws_instance" "web" {
  ami                    = "ami-0c55b159cbfafe1f0"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.web.id]
  
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    app_name = var.app_name
  }))
  
  tags = {
    Name = "${var.app_name}-instance"
  }
}

# RDS Database
resource "aws_db_instance" "postgres" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "14.7"
  instance_class       = "db.t3.micro"
  db_name              = "myapp"
  username             = "admin"
  password             = random_password.db_password.result
  skip_final_snapshot  = true
  
  tags = {
    Name = "${var.app_name}-db"
  }
}

# Generate random password
resource "random_password" "db_password" {
  length  = 16
  special = true
}

# outputs.tf
output "instance_ip" {
  value = aws_instance.web.public_ip
}

output "db_endpoint" {
  value = aws_db_instance.postgres.endpoint
}
```

---

# 8. Terraform Modules (Reusable Code)

Modules are reusable Terraform code blocks. Similar to functions.

## Module Structure

```text
modules/
├── networking/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
├── database/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
└── compute/
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
```

## Example Module: networking/main.tf

```hcl
# modules/networking/main.tf

variable "app_name" {
  type = string
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.app_name}-vpc"
  }
}

resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "${var.app_name}-subnet"
  }
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_id" {
  value = aws_subnet.main.id
}
```

## Using Modules: main.tf

```hcl
# main.tf - Using the networking module

module "network" {
  source = "./modules/networking"
  
  app_name = "myapp"
  vpc_cidr = "10.0.0.0/16"
}

# Now use module outputs
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = module.network.subnet_id
}
```

---

# 9. Terraform State Management

## Local State (Learning/Small Projects)

```hcl
# Just run terraform init and Terraform creates
# terraform.tfstate locally in your project
# 
# Simple but:
# ✗ Hard for teams
# ✗ Not backed up
# ✗ Sensitive data in plain text
```

## Remote State (Production Best Practice)

### Option 1: AWS S3 Backend

```hcl
# backend.tf or within main.tf

terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

Setup S3 backend:
```bash
# Create S3 bucket for state
aws s3api create-bucket --bucket my-terraform-state

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket my-terraform-state \
  --versioning-configuration Status=Enabled

# Block public access
aws s3api put-public-access-block \
  --bucket my-terraform-state \
  --public-access-block-configuration \
  "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
```

### Option 2: Terraform Cloud (FREE)

```hcl
# main.tf

terraform {
  cloud {
    organization = "your-org"
    
    workspaces {
      name = "my-workspace"
    }
  }
}
```

Benefits:
```text
✓ Free tier: 500MB state storage
✓ Team collaboration
✓ State locking (prevents conflicts)
✓ Run history
✓ Notifications
✓ VCS integration (GitHub, GitLab, etc.)
```

---

# 10. Installation & Getting Started

## Install Terraform (macOS with Homebrew)

```bash
# Install
brew install terraform

# Verify
terraform version

# Should output: Terraform v1.x.x
```

## Install Terraform (Other OS)

```bash
# Download from: https://www.terraform.io/downloads.html

# Or using package managers:
# Ubuntu/Debian:
wget https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Windows (Chocolatey):
choco install terraform
```

## Create Your First Project

```bash
# Create project directory
mkdir terraform-learning
cd terraform-learning

# Create main.tf
cat > main.tf << 'EOF'
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "example" {
  bucket = "my-example-bucket-${data.aws_caller_identity.current.account_id}"
  
  tags = {
    Name = "Example"
  }
}

data "aws_caller_identity" "current" {}

output "bucket_name" {
  value = aws_s3_bucket.example.id
}
EOF

# Initialize (download AWS provider)
terraform init

# Show what will be created
terraform plan

# Create the S3 bucket
terraform apply

# View outputs
terraform output

# Destroy when done
terraform destroy
```

---

# 11. Common Terraform Commands

```bash
# Initialize working directory
terraform init

# Format code (best practices)
terraform fmt

# Validate syntax
terraform validate

# Show what will change
terraform plan

# Apply changes
terraform apply

# Apply without confirmation
terraform apply -auto-approve

# Destroy resources
terraform destroy

# Show current state
terraform state list
terraform state show RESOURCE

# Refresh state from cloud
terraform refresh

# Import existing resource
terraform import aws_instance.example i-12345678

# Get outputs
terraform output
terraform output SPECIFIC_OUTPUT

# Show resource graph
terraform graph | dot -Tsvg > graph.svg
```

---

# 12. Terraform Best Practices

```text
DO:
✓ Use version control (git)
✓ Use remote state (S3, Terraform Cloud)
✓ Use modules for reusable code
✓ Use workspaces for dev/staging/prod
✓ Use .gitignore to exclude .tfstate files
✓ Use meaningful variable names
✓ Use outputs to expose important values
✓ Use tags for resource organization
✓ Test infrastructure locally first
✓ Use terraform fmt to format code
✓ Use terraform validate to check syntax
✓ Document your infrastructure
✓ Use semantic versioning for modules

DON'T:
✗ Commit .tfstate files to git
✗ Commit terraform.tfvars with secrets
✗ Run terraform commands without git
✗ Modify state files directly
✗ Use hardcoded values (use variables)
✗ Create resources outside of Terraform
✗ Use same workspace for dev/prod
✗ Forget to run destroy when testing
✗ Ignore Terraform errors/warnings
```

---

# 13. Terraform Workspaces (Dev/Staging/Prod)

Workspaces allow multiple states with same code.

```bash
# List workspaces
terraform workspace list

# Create new workspace
terraform workspace new prod

# Switch workspace
terraform workspace select prod

# Create resources in this workspace
terraform apply

# Switch back to dev
terraform workspace select default

# Destroy prod resources
terraform destroy
```

## Using Workspaces in Code

```hcl
locals {
  workspace_settings = {
    dev = {
      instance_type = "t2.micro"
      db_size       = 20
    }
    prod = {
      instance_type = "t3.medium"
      db_size       = 100
    }
  }
  
  settings = local.workspace_settings[terraform.workspace]
}

resource "aws_instance" "web" {
  instance_type = local.settings.instance_type
}
```

---

# 14. Cost Comparison: Terraform vs Alternatives

```text
TOOL              COST        WHY BEST FOR YOU
─────────────────────────────────────────────────
Terraform         FREE ✓      Open-source, no licensing
AWS CDK           FREE ✓      AWS service (no extra cost)
CloudFormation    FREE ✓      AWS service (no extra cost)
Pulumi Free       FREE ✓      Free tier sufficient
Pulumi Enterprise PAID        For large organizations

HIDDEN COSTS:
├── Time to learn (Terraform has most tutorials)
├── Team training (Terraform most common skill)
├── Support (Terraform: huge community)
└── State management (Terraform Cloud: free tier)

RECOMMENDATION: Terraform
└── Free, largest community, most job opportunities
```

---

# 15. Learning Path for Terraform

## Week 1: Basics

```text
DAY 1:
├── Install Terraform
├── Create AWS account
├── Create S3 bucket with Terraform
└── Destroy it

DAY 2:
├── Learn HCL syntax
├── Create variables.tf
├── Create outputs.tf
└── Use variables in resources

DAY 3:
├── Create VPC + Subnet
├── Create EC2 instance
├── Create security groups
└── SSH into instance

DAY 4-5:
├── Review and practice
└── Create small project (VPC + 2 EC2 + SG)
```

## Week 2: Intermediate

```text
DAY 6-7:
├── Learn Terraform state
├── Setup remote state (S3)
├── Use Terraform Cloud
└── Understand state locking

DAY 8-9:
├── Create modules
├── networking module
├── Create reusable code
└── Use modules in main config

DAY 10:
├── Project: Create reusable networking module
├── Use it in multiple projects
└── Practice

DAY 11-12:
├── Learn workspaces (dev/prod)
├── Create different configs per workspace
└── Practice deployment to multiple environments
```

## Week 3: Advanced

```text
DAY 13-14:
├── Create RDS database
├── Create auto-scaling groups
├── Create load balancers
└── Complex infrastructure

DAY 15:
├── Integrate with CI/CD
├── GitHub Actions + Terraform
├── Automated deployments
└── Project: Full infrastructure in CI/CD
```

## Project Ideas

```text
PROJECT 1 (Week 1):
└── Single EC2 instance with security groups

PROJECT 2 (Week 2):
└── VPC + 2 EC2 instances + Load Balancer

PROJECT 3 (Week 3):
├── VPC + EC2 + RDS + Auto-scaling
├── Reusable modules
└── Dev/Prod workspaces

PROJECT 4 (Week 3+):
├── Full 3-tier application
├── Web tier (EC2 + ALB)
├── App tier (Auto-scaling)
├── Database tier (RDS)
└── With all modules & workspaces
```

---

# 16. Real-World Example: Multi-Environment Setup

```hcl
# project structure
.
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
├── environments/
│   ├── dev.tfvars
│   ├── staging.tfvars
│   └── prod.tfvars
├── modules/
│   ├── networking/
│   │   ├── main.tf
│   │   └── outputs.tf
│   ├── compute/
│   │   └── main.tf
│   └── database/
│       └── main.tf
└── .gitignore
```

## main.tf

```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  cloud {
    organization = "my-org"
    workspaces {
      name = "${var.environment}-workspace"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Networking
module "networking" {
  source = "./modules/networking"
  
  app_name = var.app_name
  environment = var.environment
  vpc_cidr = var.vpc_cidr
}

# Database
module "database" {
  source = "./modules/database"
  
  app_name = var.app_name
  environment = var.environment
  db_instance_class = var.db_instance_class
  db_allocated_storage = var.db_allocated_storage
}

# Compute
module "compute" {
  source = "./modules/compute"
  
  app_name = var.app_name
  environment = var.environment
  instance_type = var.instance_type
  subnet_id = module.networking.subnet_id
}
```

## variables.tf

```hcl
variable "app_name" {
  type = string
}

variable "environment" {
  type = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "db_instance_class" {
  type = string
}

variable "db_allocated_storage" {
  type = number
}
```

## environments/dev.tfvars

```hcl
app_name              = "myapp"
environment           = "dev"
vpc_cidr              = "10.0.0.0/16"
instance_type         = "t2.micro"
db_instance_class     = "db.t3.micro"
db_allocated_storage  = 20
```

## environments/prod.tfvars

```hcl
app_name              = "myapp"
environment           = "prod"
vpc_cidr              = "10.0.0.0/16"
instance_type         = "t3.medium"
db_instance_class     = "db.t3.large"
db_allocated_storage  = 100
```

## Deploy with different configs

```bash
# Deploy to dev
terraform apply -var-file="environments/dev.tfvars"

# Deploy to prod
terraform apply -var-file="environments/prod.tfvars"
```

---

# 17. Terraform vs CloudFormation vs CDK vs Pulumi

```text
SCENARIO COMPARISON:

SCENARIO: Learning Infrastructure as Code
├── Terraform: ✓✓✓ (Best choice - skills transfer everywhere)
├── AWS CDK:   ✓✓  (If AWS-only, good for Python developers)
├── Pulumi:    ✓✓  (Good alternative, smaller community)
└── CloudFormation: ✗ (Avoid - use CDK instead)

SCENARIO: Multi-cloud infrastructure
├── Terraform: ✓✓✓ (Best choice)
├── AWS CDK:   ✗   (AWS only)
├── Pulumi:    ✓✓  (Good alternative)
└── CloudFormation: ✗ (AWS only)

SCENARIO: AWS-only, Python expertise
├── Terraform: ✓✓✓ (Always reliable)
├── AWS CDK:   ✓✓  (Great for Python)
├── Pulumi:    ✓✓  (Also Python)
└── CloudFormation: ✗ (Avoid)

SCENARIO: Job market / Career growth
├── Terraform: ✓✓✓ (Most DevOps jobs)
├── AWS CDK:   ✓   (Growing)
├── Pulumi:    ✗   (Few jobs)
└── CloudFormation: ✓ (Legacy systems)
```

---

# 18. Decision: Which to Choose?

## The Answer (For You)

```text
✓✓✓ CHOOSE TERRAFORM ✓✓✓

REASONS:

1. FREE
   └── No licensing cost, open-source

2. LEARN ONCE, USE EVERYWHERE
   └── AWS, Azure, GCP, Kubernetes, GitHub, etc.
   └── Skills transfer to any company

3. LARGEST COMMUNITY
   └── Most tutorials available
   └── Most Stack Overflow answers
   └── Most example code

4. MOST JOB OPPORTUNITIES
   └── DevOps jobs ask for Terraform first
   └── CDK second, Pulumi/CloudFormation rare

5. EASIEST TO LEARN
   └── HCL is readable (vs CDK code complexity)
   └── Simple workflow: init → plan → apply

6. BEST FOR YOUR CAREER
   └── Terraform knowledge = most marketable skill
   └── Every cloud company uses Terraform
   └── Not locked into AWS ecosystem

NEXT STEPS:
1. Install Terraform (5 minutes)
2. Create AWS account (free tier)
3. Create your first S3 bucket (15 minutes)
4. Follow Week 1 learning path above
5. You'll be productive in 1 week!
```

---

# Resources & Learning

## Official Resources

- [Terraform Official Docs](https://www.terraform.io/docs)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Module Registry](https://registry.terraform.io/)
- [Terraform Cloud Free Tier](https://app.terraform.io/signup/account)

## Tutorials & Courses

- [HashiCorp Terraform Getting Started](https://learn.hashicorp.com/terraform)
- [Terraform AWS Guide](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices.html)

## Community & Help

- [Terraform Community](https://www.terraform.io/community)
- [Terraform Discuss Forum](https://discuss.hashicorp.com/c/terraform/)
- [Terraform GitHub Issues](https://github.com/hashicorp/terraform)
- [StackOverflow #terraform](https://stackoverflow.com/questions/tagged/terraform)

## Modules to Start With

- [Terraform AWS Modules](https://github.com/terraform-aws-modules) (Official)
- [VPC Module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest)
- [Security Group Module](https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest)

---

# Quick Reference Cheat Sheet

```bash
# Installation
brew install terraform                    # macOS
terraform version                         # Check version

# Workflow
terraform init                            # Initialize
terraform fmt                             # Format code
terraform validate                        # Check syntax
terraform plan                            # Preview changes
terraform apply                           # Create resources
terraform apply -auto-approve             # Auto-approve
terraform destroy                         # Destroy all
terraform destroy -auto-approve           # Auto-approve destroy

# State
terraform state list                      # List resources
terraform state show RESOURCE             # Show resource
terraform state rm RESOURCE               # Remove from state
terraform import RESOURCE ID              # Import existing

# Debugging
terraform console                         # Interactive console
terraform validate                        # Check syntax
terraform plan -out=tfplan                # Save plan
terraform apply tfplan                    # Apply saved plan

# Workspaces
terraform workspace list                  # List workspaces
terraform workspace new NAME              # Create workspace
terraform workspace select NAME           # Switch workspace
terraform workspace delete NAME           # Delete workspace

# Variables
terraform apply -var="key=value"          # Pass variable
terraform apply -var-file="file.tfvars"   # Load from file
terraform output                          # Show outputs
terraform output KEY                      # Show specific output
```

---

**Recommendation Summary**

```
┌─────────────────────────────────────────────────┐
│                                                 │
│  ✓ CHOICE: TERRAFORM                           │
│  ✓ COST: FREE                                  │
│  ✓ LEARNING TIME: 1-2 weeks for basics         │
│  ✓ CAREER VALUE: Highest in market             │
│  ✓ START: Today with terraform init            │
│                                                 │
│  Why not AWS CDK?                              │
│  └─ Locked into AWS, complex, fewer jobs       │
│                                                 │
│  Why not Pulumi?                               │
│  └─ Smaller community, fewer examples          │
│                                                 │
│  Why not CloudFormation?                       │
│  └─ Verbose, legacy, use CDK instead           │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

**Last Updated:** August 24, 2026
**Curated for:** DevOps Learning Path
**Recommendation:** Choose Terraform & start today!
