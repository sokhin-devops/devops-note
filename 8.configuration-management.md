# Configuration Management

## Chef, Salt & Ansible

Configuration Management automates the deployment, configuration, and management of servers and applications across your infrastructure.

The main configuration management tools covered in this guide are:

* Chef
* Salt
* Ansible

---

# 1. What Is Configuration Management?

## Manual Configuration (The Old Way)

```text
New Server Deployed
     │
     ▼
SSH into each server
     │
     ├── sudo apt update
     ├── sudo apt install nginx
     ├── sudo systemctl start nginx
     ├── Edit /etc/nginx/nginx.conf
     ├── Create user accounts
     ├── Setup firewall rules
     ├── Install SSL certificates
     └── Run application setup
     
Problems:
├── Repetitive & slow
├── Error-prone (typos)
├── Inconsistent across servers
├── Hard to reproduce
├── Nightmare for large fleets
└── Takes hours per server
```

## Configuration Management (The New Way)

```text
Write Configuration Code
     │
     ├── install nginx
     ├── configure firewall
     ├── setup SSL
     └── deploy application
     │
     ▼
Run on all 100 servers
     │
     └── Automatically configured
         └── Identically
         └── In minutes
         └── Reproducible
```

## Benefits of Configuration Management

```text
CM ADVANTAGES:

Consistency:      All servers configured identically
Speed:            Deploy to 100s of servers instantly
Reproducibility:  Same code = same configuration
Version Control:  Track all changes in git
Scalability:      Add 10 servers = same effort as 1
Self-healing:     Enforce desired state automatically
Disaster Recovery: Rebuild servers from code instantly
Compliance:       Enforce standards everywhere
Auditability:     Know exactly what changed and when
```

---

# 2. Configuration Management: Push vs. Pull

## Agent-based (Pull Model)

```text
Server with Agent
     │
     ├── Polls Central Server every N minutes
     │
     ▼
Central Configuration Server
     │
     └── "Here's your config for this server"
     
Example: Chef, Puppet
     
PROS:
✓ Automatic enforcement
✓ Runs on schedule
✓ Immediate fix if config drifts
✓ Server is independent
     
CONS:
✗ Agent to install on each server
✗ More complex setup
✗ More overhead on servers
```

## Agentless (Push Model)

```text
Control Machine (your laptop/CI server)
     │
     ├── SSH to target servers
     │
     ▼
Run commands/configuration
     │
     └── Done
     
Example: Ansible, Salt SSH mode
     
PROS:
✓ NO agent to install
✓ Simple setup (just SSH)
✓ Easy to learn & debug
✓ Lower server overhead
✓ SSH already everywhere
     
CONS:
✗ Manual trigger needed
✗ No automatic enforcement
✗ Slower for large fleets
```

---

# 3. Quick Comparison: Chef vs. Salt vs. Ansible

```text
┌──────────────┬──────────────┬──────────────┬──────────────┐
│   Feature    │ Ansible      │ Chef         │ Salt         │
├──────────────┼──────────────┼──────────────┼──────────────┤
│ Language     │ YAML         │ Ruby         │ Python/YAML  │
│ Model        │ Push/Agentless│ Pull/Agent  │ Push/Pull    │
│ Learning     │ EASY ✓       │ Hard         │ Medium       │
│ Setup        │ SSH only ✓   │ Agent needed │ Agent needed │
│ Cost         │ FREE ✓       │ FREE/Paid    │ FREE ✓       │
│ Community    │ HUGE ✓       │ Large        │ Growing      │
│ Job Market   │ MOST ✓       │ Some         │ Few          │
│ Syntax       │ Simple ✓     │ Complex      │ Complex      │
│ Features     │ Essential    │ Advanced     │ Advanced     │
│ Scalability  │ Good         │ Excellent    │ Excellent    │
│ Best For     │ Everything ✓ │ Large orgs   │ Scale        │
│ Maturity     │ Stable       │ Very stable  │ Stable       │
└──────────────┴──────────────┴──────────────┴──────────────┘
```

---

# 4. My Recommendation: Ansible

## Why Choose Ansible?

```text
ANSIBLE IS BEST FOR LEARNING BECAUSE:

✓ EASIEST TO LEARN
  └── YAML syntax (plain English-like)
  └── Not a programming language
  └── Steep learning curve: FLAT
  
✓ NO AGENT REQUIRED (Agentless)
  └── Works over SSH
  └── Every Linux server has SSH
  └── Just one requirement: Python on target
  
✓ COMPLETELY FREE & OPEN SOURCE
  └── No licensing costs
  └── No "enterprise" upsell
  └── Community-driven
  
✓ FASTEST TIME TO PRODUCTIVITY
  └── Configure servers in 30 minutes
  └── No complex setup
  └── SSH is your only tool
  
✓ PERFECT FOR BEGINNERS
  └── Write playbooks like recipes
  └── Test locally first
  └── Idempotent (safe to run multiple times)
  
✓ MOST JOB OPPORTUNITIES
  └── Most "configuration management" jobs are Ansible
  └── Still large Chef market
  └── Salt is niche
  
✓ PERFECT FOR TERRAFORM USERS
  └── You provision with Terraform
  └── Configure with Ansible
  └── Perfect pairing!

ALTERNATIVE CONSIDERATIONS:

Chef:
├── Better if: Large enterprises need advanced features
├── Advantage: Most powerful, best for complex workflows
└── Learning curve: Very steep (Ruby coding)

Salt:
├── Better if: You need agent-based + scale to 1000s
├── Advantage: Event-driven, fast for large fleets
└── Community: Smaller than Ansible
```

**FINAL ANSWER: Yes, choose Ansible. It's the easiest path to mastery.**

---

# 5. Quick Overview: Chef

## What Is Chef?

Chef is a powerful configuration management platform using Ruby-based recipes. Agent-based pull model with server coordination.

## Chef Terminology

```text
Recipe:      Individual configuration task
Cookbook:    Collection of recipes
Role:        Group of recipes for a server type
Attribute:   Configuration variable
Chef Server: Central management hub
Chef Client:  Agent running on each server
```

## Simple Chef Recipe Example

```ruby
# recipes/nginx.rb

package 'nginx' do
  action :install
end

service 'nginx' do
  action [:enable, :start]
end

cookbook_file '/etc/nginx/nginx.conf' do
  source 'nginx.conf'
  action :create
  notifies :restart, 'service[nginx]'
end
```

## Chef Pros & Cons

```text
PROS:
✓ Most powerful & flexible
✓ Large enterprise adoption
✓ Excellent for complex orchestration
✓ Strong ecosystem
✓ Good for large teams

CONS:
✗ Steep learning curve (Ruby)
✗ Complex setup (Chef Server needed)
✗ Requires agent on every server
✗ Harder to debug
✗ Verbose syntax
✗ Overkill for small deployments
```

---

# 6. Quick Overview: Salt

## What Is Salt?

Salt is a configuration management platform using Python. Fast, event-driven, scales to thousands of servers.

## Salt Terminology

```text
State File:  Configuration description (.sls)
Module:      Salt execution module
Minion:      Agent on target server
Master:      Central Salt server
Execution:   Direct command to minions
State:       Desired state of resource
```

## Simple Salt State Example

```yaml
# apache/init.sls

apache-server:
  pkg.installed:
    - name: apache2
  service.running:
    - name: apache2
    - enable: True
    - watch:
      - file: /etc/apache2/apache2.conf

/etc/apache2/apache2.conf:
  file.managed:
    - source: salt://apache/files/apache2.conf
    - user: root
    - group: root
    - mode: 644
```

## Salt Pros & Cons

```text
PROS:
✓ Very fast (event-driven)
✓ Scales to thousands
✓ Python-based (easier than Chef)
✓ Can work in push or pull mode
✓ Good for large deployments
✓ Lower overhead than Chef

CONS:
✗ Steeper learning curve than Ansible
✗ Smaller community than Ansible/Chef
✗ Fewer job opportunities
✗ Requires agent on servers
✗ Less beginner-friendly
✗ Complex syntax
```

---

# 7. Ansible: Detailed Guide

Since Ansible is the best choice for you, here's the detailed guide.

## What Is Ansible?

Ansible is a simple, agentless configuration management platform. Define infrastructure in YAML and automate deployment, configuration, and orchestration of servers.

## How Ansible Works

```text
1. WRITE PLAYBOOK
   └─ playbook.yml (YAML file)
   └─ Define tasks in plain language

2. CREATE INVENTORY
   └─ hosts.ini (list of target servers)
   └─ IP addresses or hostnames

3. RUN PLAYBOOK
   └─ ansible-playbook playbook.yml
   └─ Connects over SSH
   └─ Executes tasks on all servers

4. IDEMPOTENT EXECUTION
   └─ Run 100 times = same result
   └─ No "applying twice" problem
   └─ Safe to automate
```

## Ansible Architecture

```text
Control Machine (your laptop)
     │
     ├── Ansible installed
     ├── playbook.yml
     └── hosts.ini
     │
     ├─── SSH ───────→ Server 1 (Linux)
     │
     ├─── SSH ───────→ Server 2 (Linux)
     │
     └─── SSH ───────→ Server 3 (Linux)
     
Target Servers:
├── Just need: SSH access
├── Just need: Python installed
└── NO agent required!
```

## Core Concepts

```text
PLAYBOOK:    YAML file defining automation
PLAY:        Set of tasks for a group of hosts
TASK:        Single action (install, config, etc)
MODULE:      Ansible's execution unit
ROLE:        Reusable collection of tasks
INVENTORY:   List of target servers
HANDLER:     Task that runs on notification
VARIABLE:    Reusable value
```

## Ansible Installation

```bash
# macOS
brew install ansible

# Ubuntu/Debian
sudo apt update
sudo apt install ansible

# pip (all platforms)
pip install ansible

# Verify
ansible --version
```

## Simple Ansible Example

### 1. Create Inventory File: hosts.ini

```ini
[webservers]
server1 ansible_host=192.168.1.10 ansible_user=ubuntu
server2 ansible_host=192.168.1.11 ansible_user=ubuntu

[databases]
db1 ansible_host=192.168.1.20 ansible_user=ubuntu

[all:vars]
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_python_interpreter=/usr/bin/python3
```

### 2. Create Playbook: playbook.yml

```yaml
---
- name: Configure Web Servers
  hosts: webservers
  become: yes
  
  tasks:
    - name: Update package cache
      apt:
        update_cache: yes
        cache_valid_time: 3600
    
    - name: Install Nginx
      apt:
        name: nginx
        state: present
    
    - name: Start Nginx service
      service:
        name: nginx
        state: started
        enabled: yes
    
    - name: Copy Nginx config
      copy:
        src: ./files/nginx.conf
        dest: /etc/nginx/nginx.conf
        owner: root
        group: root
        mode: '0644'
      notify: restart nginx
  
  handlers:
    - name: restart nginx
      service:
        name: nginx
        state: restarted
```

### 3. Run Playbook

```bash
# Check what would be done (dry-run)
ansible-playbook playbook.yml --check

# Actually run it
ansible-playbook playbook.yml

# Run with extra verbosity
ansible-playbook playbook.yml -v

# Run on specific hosts
ansible-playbook playbook.yml --limit server1
```

## Ansible Modules (Most Common)

```text
FILE MANAGEMENT:
├── copy:          Copy files to servers
├── file:          Manage files/directories
├── lineinfile:    Edit lines in files
└── template:      Deploy template files

PACKAGES:
├── apt:           Debian/Ubuntu packages
├── yum:           RedHat/CentOS packages
├── pip:           Python packages
└── npm:           Node.js packages

SERVICES:
├── service:       Manage systemd services
├── systemd:       Advanced systemd control
└── supervisorctl: Supervisor management

EXECUTION:
├── command:       Run raw commands
├── shell:         Run shell commands
└── script:        Run scripts on target

USERS & GROUPS:
├── user:          Manage user accounts
├── group:         Manage groups
└── authorized_key: Manage SSH keys

NETWORKING:
├── ping:          Test connectivity
├── uri:           HTTP requests
└── wait_for:      Wait for condition

CLOUD:
├── ec2:           AWS EC2 instances
├── s3:            AWS S3 buckets
└── azure_vm:      Azure VMs
```

## Real-World Example: Deploy Flask App

### Directory Structure

```text
ansible-project/
├── playbooks/
│   └── deploy-flask.yml
├── roles/
│   ├── common/
│   │   ├── tasks/
│   │   │   └── main.yml
│   │   └── handlers/
│   │       └── main.yml
│   ├── nginx/
│   │   ├── tasks/
│   │   │   └── main.yml
│   │   ├── templates/
│   │   │   └── nginx.conf.j2
│   │   └── handlers/
│   │       └── main.yml
│   └── app/
│       ├── tasks/
│       │   └── main.yml
│       ├── templates/
│       │   └── app.service.j2
│       └── files/
│           └── requirements.txt
├── group_vars/
│   └── all.yml
├── host_vars/
│   └── server1.yml
├── hosts.ini
└── ansible.cfg
```

### playbooks/deploy-flask.yml

```yaml
---
- name: Deploy Flask Application
  hosts: webservers
  become: yes
  
  roles:
    - common
    - nginx
    - app
```

### roles/common/tasks/main.yml

```yaml
---
- name: Update apt cache
  apt:
    update_cache: yes
    cache_valid_time: 3600

- name: Install common packages
  apt:
    name:
      - python3
      - python3-pip
      - python3-venv
      - git
      - curl
      - wget
    state: present

- name: Create app user
  user:
    name: appuser
    shell: /bin/bash
    home: /home/appuser
```

### roles/nginx/templates/nginx.conf.j2

```nginx
upstream flask_app {
    server 127.0.0.1:{{ flask_port }};
}

server {
    listen 80;
    server_name {{ server_name }};
    
    location / {
        proxy_pass http://flask_app;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### roles/nginx/tasks/main.yml

```yaml
---
- name: Install Nginx
  apt:
    name: nginx
    state: present

- name: Deploy Nginx config
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/sites-available/default
    owner: root
    group: root
    mode: '0644'
  notify: restart nginx

- name: Enable and start Nginx
  service:
    name: nginx
    state: started
    enabled: yes

- name: Open firewall port 80
  ufw:
    rule: allow
    port: '80'
    proto: tcp
```

### roles/app/tasks/main.yml

```yaml
---
- name: Clone application repository
  git:
    repo: "{{ app_repo }}"
    dest: "{{ app_path }}"
    version: main
  become_user: appuser

- name: Create virtual environment
  command: python3 -m venv {{ app_path }}/venv
  become_user: appuser
  args:
    creates: "{{ app_path }}/venv"

- name: Install Python dependencies
  pip:
    requirements: "{{ app_path }}/requirements.txt"
    virtualenv: "{{ app_path }}/venv"
  become_user: appuser

- name: Deploy systemd service file
  template:
    src: app.service.j2
    dest: /etc/systemd/system/flask-app.service
    owner: root
    group: root
    mode: '0644'
  notify: restart flask app

- name: Enable and start Flask app
  systemd:
    name: flask-app
    state: started
    enabled: yes
    daemon_reload: yes
```

### group_vars/all.yml

```yaml
---
flask_port: 5000
server_name: example.com
app_path: /opt/flask-app
app_repo: https://github.com/youruser/flask-app.git
ansible_python_interpreter: /usr/bin/python3
```

### Run the Playbook

```bash
# Dry-run first
ansible-playbook playbooks/deploy-flask.yml --check

# Deploy
ansible-playbook playbooks/deploy-flask.yml

# Re-run is safe (idempotent)
ansible-playbook playbooks/deploy-flask.yml
```

## Ansible Roles (Reusable)

Roles are the standard way to organize Ansible code.

### Generate Role Structure

```bash
ansible-galaxy init roles/nginx
# Creates:
# roles/nginx/
# ├── tasks/
# │   └── main.yml
# ├── handlers/
# │   └── main.yml
# ├── templates/
# ├── files/
# ├── vars/
# ├── defaults/
# └── README.md
```

### Using Galaxy Roles (Pre-built)

```bash
# Search for roles
ansible-galaxy search nginx

# Install community role
ansible-galaxy install geerlingguy.nginx

# Use in playbook
ansible-playbook -i hosts.ini playbook.yml
```

### requirements.yml (Dependency Management)

```yaml
---
- name: geerlingguy.nginx
  version: 3.9.0
  
- name: geerlingguy.docker
  version: 6.1.2
  
- name: geerlingguy.postgresql
  version: 3.4.0
```

Install dependencies:
```bash
ansible-galaxy install -r requirements.yml
```

## Ansible Variables & Facts

### Using Variables

```yaml
---
- name: Example with variables
  hosts: webservers
  
  vars:
    http_port: 80
    max_clients: 200
    domain: example.com
  
  tasks:
    - name: Install Nginx
      apt:
        name: nginx
        state: present
    
    - name: Show variable
      debug:
        msg: "Server is {{ domain }} on port {{ http_port }}"
```

### Gathering Facts (Server Info)

```yaml
---
- name: Use server facts
  hosts: webservers
  
  tasks:
    - name: Print OS
      debug:
        msg: "OS is {{ ansible_os_family }}"
    
    - name: Print IP
      debug:
        msg: "IP is {{ ansible_default_ipv4.address }}"
    
    - name: Print CPU cores
      debug:
        msg: "CPU cores: {{ ansible_processor_vcpus }}"
```

Available facts: `ansible_os_family`, `ansible_distribution`, `ansible_hostname`, `ansible_memtotal_mb`, etc.

## Ansible Handlers (Notifications)

Handlers run when notified (great for service restarts).

```yaml
---
- name: Example with handlers
  hosts: webservers
  
  tasks:
    - name: Deploy config
      copy:
        src: app.conf
        dest: /etc/app/app.conf
      notify: restart app service
    
    - name: Deploy code
      git:
        repo: https://github.com/myapp.git
        dest: /opt/app
      notify: restart app service
  
  handlers:
    - name: restart app service
      service:
        name: app
        state: restarted
```

Important: Handler runs ONCE at end of play, even if notified multiple times.

## Ansible Conditionals

```yaml
---
- name: Conditional tasks
  hosts: webservers
  
  tasks:
    - name: Install Nginx on Debian
      apt:
        name: nginx
      when: ansible_os_family == "Debian"
    
    - name: Install Nginx on RedHat
      yum:
        name: nginx
      when: ansible_os_family == "RedHat"
    
    - name: Copy prod config
      copy:
        src: prod.conf
        dest: /etc/app.conf
      when: environment == "prod"
```

## Ansible Loops

```yaml
---
- name: Loop example
  hosts: webservers
  
  tasks:
    - name: Install multiple packages
      apt:
        name: "{{ item }}"
        state: present
      loop:
        - nginx
        - curl
        - git
        - vim
    
    - name: Create multiple users
      user:
        name: "{{ item.name }}"
        shell: "{{ item.shell }}"
      loop:
        - { name: 'user1', shell: '/bin/bash' }
        - { name: 'user2', shell: '/bin/bash' }
        - { name: 'user3', shell: '/bin/nologin' }
```

## Ansible Vault (Secrets Management)

Encrypt sensitive data (passwords, API keys, etc).

```bash
# Create encrypted file
ansible-vault create group_vars/all/secrets.yml

# Edit encrypted file
ansible-vault edit group_vars/all/secrets.yml

# View encrypted file
ansible-vault view group_vars/all/secrets.yml

# Run playbook with vault password
ansible-playbook playbook.yml --ask-vault-pass

# Or use vault password file
ansible-playbook playbook.yml --vault-password-file ~/.vault_pass
```

### Vault File Example

```yaml
---
db_password: super_secret_password
api_key: sk_live_abc123def456
aws_secret_key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

---

# 8. Common Ansible Commands

```bash
# Basic connectivity
ansible all -i hosts.ini -m ping

# Run ad-hoc commands
ansible webservers -i hosts.ini -m apt -a "name=nginx state=present"
ansible all -i hosts.ini -m command -a "uptime"

# Copy files
ansible webservers -i hosts.ini -m copy -a "src=/tmp/file.txt dest=/tmp/"

# Run playbooks
ansible-playbook playbook.yml                          # Run all hosts
ansible-playbook playbook.yml --limit webservers      # Specific hosts
ansible-playbook playbook.yml --check                 # Dry-run
ansible-playbook playbook.yml -v                      # Verbose output
ansible-playbook playbook.yml -vv                     # Very verbose
ansible-playbook playbook.yml -vvv                    # Debug output

# List hosts
ansible-inventory -i hosts.ini --list
ansible webservers -i hosts.ini --list-hosts

# Check syntax
ansible-playbook playbook.yml --syntax-check

# Run specific tags
ansible-playbook playbook.yml --tags "nginx"
ansible-playbook playbook.yml --skip-tags "slow"

# Gather facts
ansible webservers -i hosts.ini -m setup
ansible webservers -i hosts.ini -m setup -a "filter=ansible_os_family"

# Test connectivity
ansible all -i hosts.ini -m ping

# Run with extra variables
ansible-playbook playbook.yml -e "var=value"
ansible-playbook playbook.yml -e "@extra_vars.yml"

# Debug
ansible-playbook playbook.yml -vvv              # Maximum debug output
ansible-playbook playbook.yml --step            # Interactive (confirm each task)
```

---

# 9. Ansible Best Practices

```text
PLAYBOOK ORGANIZATION:

DO:
✓ Use roles for everything
✓ One role per concern (nginx, postgres, app)
✓ Keep playbooks simple (just call roles)
✓ Use group_vars and host_vars
✓ Use meaningful variable names
✓ Document roles with README.md
✓ Use tags for selective execution
✓ Use handlers for notifications
✓ Make tasks idempotent
✓ Use blocks for error handling
✓ Use vault for secrets

DON'T:
✗ Mix tasks and roles in playbook
✗ Put all tasks in one file
✗ Hardcode values
✗ Commit .vault_password to git
✗ Use root user (use become: yes)
✗ Ignore idempotency (run safe multiple times)
✗ Copy-paste code (use roles instead)
✗ Run Ansible commands manually
✗ Skip error checking

VARIABLES:

DO:
✓ Use descriptive names: app_port not p
✓ Use defaults in roles/defaults/main.yml
✓ Override with group_vars/host_vars
✓ Use vault for secrets
✓ Document variables with comments

DON'T:
✗ Use undefined variables
✗ Put sensitive data in playbooks
✗ Store passwords in files
✗ Use cryptic variable names

IDEMPOTENCY:

Make tasks safe to run multiple times:
✓ Use state: present/absent
✓ Check if file exists before creating
✓ Use handlers for restarts
✓ Avoid: command: rm -rf /

Example:
✓ GOOD:   service: name=nginx state=started
✗ BAD:    command: systemctl restart nginx
```

---

# 10. Ansible + Terraform: Perfect Pairing

```text
WORKFLOW:

Step 1: Provision with Terraform
   └── Create EC2 instances
   └── Create security groups
   └── Create VPC
   └── Terraform outputs IPs

Step 2: Configure with Ansible
   └── Wait for instances to boot
   └── Configure servers
   └── Install applications
   └── Deploy code

BENEFITS:
├── Terraform: Infrastructure (what)
├── Ansible: Configuration (how)
├── Separation of concerns
├── Easy to understand
├── Each tool does one thing well
```

## Integration Example

### Terraform: terraform/main.tf

```hcl
resource "aws_instance" "web" {
  count           = 3
  ami             = "ami-0c55b159cbfafe1f0"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.web.name]
  
  tags = {
    Name = "web-${count.index + 1}"
  }
}

resource "aws_security_group" "web" {
  name = "web-sg"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "web_ips" {
  value = aws_instance.web[*].public_ip
}
```

### Terraform: outputs.tf → Ansible inventory

```bash
# Generate Ansible inventory from Terraform output
terraform output -json web_ips | \
  jq -r '.value | to_entries | map("[webservers]\n\(.value)") | .[]' \
  > ansible/hosts.ini
```

### Ansible: Configure the instances

```yaml
---
- name: Configure web servers
  hosts: webservers
  become: yes
  
  roles:
    - common
    - nginx
    - app
```

### Complete Automation Script

```bash
#!/bin/bash
set -e

# 1. Provision infrastructure
cd terraform
terraform init
terraform plan
terraform apply -auto-approve

# 2. Get IPs from Terraform
IPS=$(terraform output -json web_ips | jq -r '.value[]')

# 3. Wait for instances to be ready
echo "Waiting for instances to boot..."
sleep 30

# 4. Create Ansible inventory
cat > ../ansible/hosts.ini <<EOF
[webservers]
EOF

for IP in $IPS; do
  echo "$IP ansible_user=ubuntu" >> ../ansible/hosts.ini
done

# 5. Run Ansible playbook
cd ../ansible
ansible-playbook -i hosts.ini playbooks/deploy.yml

echo "Infrastructure provisioned and configured!"
```

---

# 11. Learning Path for Ansible

## Week 1: Basics

```text
DAY 1:
├── Install Ansible
├── Create first inventory (hosts.ini)
├── Test connectivity (ping)
└── Run simple task

DAY 2:
├── Learn YAML syntax
├── Create simple playbook
├── Run ad-hoc commands
└── Install packages

DAY 3:
├── Learn common modules (apt, service, copy, file)
├── Create multi-task playbook
├── Use variables
└── Practice

DAY 4-5:
├── Learn handlers (notify/restart)
├── Learn conditionals (when)
├── Learn loops
└── Project: Deploy Nginx
```

## Week 2: Intermediate

```text
DAY 6-7:
├── Create first role
├── Learn role structure
├── Move playbook to role
└── Understand defaults/vars

DAY 8-9:
├── Learn group_vars/host_vars
├── Create multiple roles
├── Complex playbook
└── Practice

DAY 10-12:
├── Learn Jinja2 templates
├── Deploy application
├── Use facts
└── Project: Full stack deployment
```

## Week 3: Advanced

```text
DAY 13-14:
├── Learn Vault (secrets)
├── Secure playbooks
├── Production best practices
└── Error handling

DAY 15:
├── Integrate with CI/CD
├── GitHub Actions + Ansible
├── Automated deployments
└── Project: Production deployment
```

## Project Ideas

```text
PROJECT 1 (Week 1):
└── Deploy Nginx to 3 servers

PROJECT 2 (Week 2):
├── Deploy 3-tier app
├── Web servers (Nginx)
├── App servers (Node.js)
└── Database (PostgreSQL)

PROJECT 3 (Week 3):
├── Terraform provisions
├── Ansible configures
├── Full automation script
└── CI/CD integration

PROJECT 4 (Week 3+):
├── Multi-environment (dev/staging/prod)
├── Vault secrets
├── Role library
└── Production-ready deployment
```

---

# 12. Ansible Playbook Template

```yaml
---
# playbooks/main.yml

- name: Configure Application Servers
  hosts: all
  become: yes
  
  vars:
    app_name: myapp
    app_version: 1.0.0
  
  pre_tasks:
    - name: Validate variables
      assert:
        that:
          - app_name is defined
          - app_version is defined
    
    - name: Display play info
      debug:
        msg: "Deploying {{ app_name }} v{{ app_version }}"
  
  roles:
    - common
    - security
    - monitoring
    - application
  
  post_tasks:
    - name: Verify deployment
      uri:
        url: "http://{{ inventory_hostname }}"
        status_code: 200
      register: result
      retries: 3
      delay: 10
      until: result.status == 200
    
    - name: Send notification
      debug:
        msg: "Deployment successful!"
  
  handlers:
    - name: restart application
      service:
        name: "{{ app_name }}"
        state: restarted
```

---

# 13. Ansible Tower (Optional)

Ansible Tower (AWX - open source) provides UI, RBAC, and advanced features.

```text
Ansible CLI:        ✓ For DevOps engineers
Ansible Tower:      ✓ For teams & enterprises
AWX:                ✓ Open-source Tower alternative

Benefits:
├── Web UI (no CLI needed)
├── Role-based access control
├── Job scheduling
├── Inventory management
├── Credential management
├── Audit logging
├── API
└── Team collaboration
```

For beginners: Start with Ansible CLI, then explore Tower/AWX.

---

# 14. Ansible vs. Chef vs. Salt Detailed Comparison

```text
SCENARIO: Learning configuration management

Chef:
├── Steep learning curve
├── Requires Ruby knowledge
├── Complex setup
└── NOT recommended for beginners

Salt:
├── Medium learning curve
├── Python/YAML knowledge helpful
├── Requires agent installation
└── Good if scaling to 1000s

Ansible:
├── Flattest learning curve
├── YAML is simple
├── SSH only, no agent
└── BEST for beginners ✓✓✓

─────────────────────────────────

SCENARIO: Deploy 5 servers

Chef:
├── Setup Chef Server: 2 hours
├── Install agents: 30 min
├── Write recipes: 1 hour
└── Total: 3.5 hours

Salt:
├── Setup Salt Master: 1 hour
├── Install minions: 30 min
├── Write states: 1 hour
└── Total: 2.5 hours

Ansible:
├── Install Ansible: 5 min
├── Create inventory: 5 min
├── Write playbook: 30 min
└── Total: 40 minutes ✓

─────────────────────────────────

SCENARIO: Job market

Chef:
├── Medium demand
├── Enterprise support
└── ~10% of CM jobs

Salt:
├── Low demand
├── Niche use cases
└── ~5% of CM jobs

Ansible:
├── High demand
├── Most popular
└── ~85% of CM jobs ✓✓✓

─────────────────────────────────

VERDICT: Choose Ansible
```

---

# 15. Cost Comparison

```text
TOOL              COST                 NOTES
─────────────────────────────────────────────────
Ansible           FREE ✓               Open source, unlimited
Ansible Tower     Paid (per node)      Enterprise features
AWX               FREE ✓               Open source Tower
Chef              FREE Community       Paid for large orgs
Chef Server       Paid                 ~$137/node/year
Salt              FREE ✓               Open source
Salt Enterprise   Paid                 For large orgs
Puppet            FREE Community       Paid Enterprise

RECOMMENDATION:
└── Start with Ansible (FREE)
└── No licensing costs
└── No hidden fees
```

---

# 16. Quick Reference Cheat Sheet

```bash
# Installation
brew install ansible                          # macOS
sudo apt install ansible                      # Debian/Ubuntu
pip install ansible                           # Any OS

# Check version
ansible --version

# Connectivity
ansible all -i hosts.ini -m ping

# Run playbooks
ansible-playbook playbook.yml
ansible-playbook playbook.yml --check         # Dry-run
ansible-playbook playbook.yml -v              # Verbose
ansible-playbook playbook.yml --limit hosts   # Specific hosts
ansible-playbook playbook.yml --tags tag      # Specific tags

# Ad-hoc commands
ansible webservers -m ping
ansible webservers -m apt -a "name=nginx"
ansible webservers -m shell -a "uptime"
ansible webservers -m copy -a "src=file dest=/tmp/"

# List hosts/inventory
ansible-inventory -i hosts.ini --list
ansible webservers -i hosts.ini --list-hosts

# Vault (secrets)
ansible-vault create secrets.yml
ansible-vault edit secrets.yml
ansible-vault view secrets.yml
ansible-playbook playbook.yml --ask-vault-pass

# Galaxy (community roles)
ansible-galaxy search nginx
ansible-galaxy install geerlingguy.nginx
ansible-galaxy install -r requirements.yml

# Testing
ansible-playbook playbook.yml --syntax-check
ansible-playbook playbook.yml --check
ansible-playbook playbook.yml --step

# Debug
ansible-playbook playbook.yml -vvv           # Max debug

# Generate inventory from dynamic sources
ansible-inventory -i ec2.py --list
```

---

# Summary: Ansible Decision

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│  ✓ CHOICE: ANSIBLE                                 │
│  ✓ COST: FREE                                      │
│  ✓ LEARNING TIME: 1-2 weeks for basics            │
│  ✓ NO AGENTS: Just SSH                            │
│  ✓ CAREER VALUE: Highest in market                │
│  ✓ START: Today with ansible-playbook             │
│                                                     │
│  Why not Chef?                                     │
│  └─ Complex setup, steep learning curve           │
│                                                     │
│  Why not Salt?                                     │
│  └─ Requires agents, smaller community           │
│                                                     │
│  Perfect pairing: Terraform + Ansible             │
│  ├─ Terraform: Provision infrastructure           │
│  └─ Ansible: Configure servers                    │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

# Resources & Learning

## Official Documentation

- [Ansible Official Docs](https://docs.ansible.com/)
- [Ansible Modules Index](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/index.html)
- [Ansible Galaxy (roles)](https://galaxy.ansible.com/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)

## Learning Resources

- [Ansible Getting Started](https://docs.ansible.com/ansible/latest/user_guide/intro_getting_started.html)
- [Playbook Guide](https://docs.ansible.com/ansible/latest/user_guide/playbooks.html)
- [Roles Documentation](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html)
- [Jinja2 Templates](https://docs.ansible.com/ansible/latest/user_guide/playbooks_templating.html)

## Community

- [Ansible Community](https://www.ansible.com/community)
- [Ansible Forum](https://www.reddit.com/r/ansible/)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/ansible)
- [GitHub Issues](https://github.com/ansible/ansible)

## Pre-built Roles

- [Geerlingguy (trusted contributor)](https://github.com/geerlingguy?tab=repositories&type=source)
- [Ansible Galaxy Popular](https://galaxy.ansible.com/search)
- [Ansible Collections](https://docs.ansible.com/ansible/latest/collections/index.html)

---

**Last Updated:** August 24, 2026
**Curated for:** DevOps Learning Path
**Recommendation:** Choose Ansible & start today!
**Perfect Pairing:** Terraform (provision) + Ansible (configure)
