resource "vultr_ssh_key" "this" {
  name    = var.label
  ssh_key = file(pathexpand(var.ssh_public_key_path))
}

resource "vultr_instance" "this" {
  label    = var.label
  hostname = var.label
  region   = var.region
  plan     = var.plan
  os_id    = var.os_id

  ssh_key_ids       = [vultr_ssh_key.this.id]
  firewall_group_id = var.firewall_group_id
  backups           = "disabled"
  enable_ipv6       = false

  tags = ["devops-lab", "terraform", var.environment]

  user_data = templatefile("${path.module}/../../cloud-init/user-data.yaml.tpl", {
    ssh_public_key = file(pathexpand(var.ssh_public_key_path))
    label          = var.label
    environment    = var.environment
  })
}
