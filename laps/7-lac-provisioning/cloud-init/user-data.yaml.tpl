#cloud-config
# Rendered by Terraform's templatefile() in modules/compute/main.tf and
# passed straight into vultr_instance.user_data — Vultr's own provider docs
# show user_data as plain text (the provider base64-encodes it before
# calling the API), unlike some providers where you're expected to do that
# encoding yourself.
#
# This is the same bootstrap as the Vultr lab (../../5-cloud-providers):
# apt upgrade, UFW, Docker, a non-root user — plus one static page whose
# ${label} and ${environment} are Terraform values, baked in at apply time,
# so 04-verify.sh can prove this exact apply's variables reached the VM.

package_update: true
package_upgrade: true

packages:
  - ca-certificates
  - curl
  - ufw

users:
  - name: deploy
    sudo: "ALL=(ALL) NOPASSWD:ALL"
    shell: /bin/bash
    ssh_authorized_keys:
      - ${ssh_public_key}

write_files:
  - path: /var/lib/lab-web/index.html
    content: |
      <!doctype html>
      <html><head><title>${label}</title></head>
      <body style="font-family: monospace">
        <h1>${label}</h1>
        <p>environment: ${environment}</p>
        <p>provisioned by Terraform, not by hand</p>
      </body></html>

runcmd:
  - ufw default deny incoming
  - ufw default allow outgoing
  - ufw allow 22/tcp
  - ufw allow 80/tcp
  - ufw allow 443/tcp
  - ufw --force enable

  - curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
  - sh /tmp/get-docker.sh
  - usermod -aG docker deploy
  - systemctl enable --now docker

  - docker run -d --name lab-web --restart unless-stopped -p 80:80
    -v /var/lib/lab-web:/usr/share/nginx/html:ro
    nginx:alpine

  - docker --version > /var/log/lab-bootstrap.log 2>&1
  - ufw status verbose >> /var/log/lab-bootstrap.log 2>&1
  - touch /var/lib/lab-ready

final_message: "lab VM bootstrapped after $UPTIME seconds"
