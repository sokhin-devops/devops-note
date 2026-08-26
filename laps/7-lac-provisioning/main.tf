# Translates the OS name into the numeric id vultr_instance needs — the same
# job 01-check.sh's lookup_os_id() did with curl+jq in the Vultr lab
# (../5-cloud-providers), except the provider does the lookup for you.
data "vultr_os" "selected" {
  filter {
    name   = "name"
    values = [var.os_name]
  }
}

module "networking" {
  source = "./modules/networking"

  label = var.label
}

module "compute" {
  source = "./modules/compute"

  region              = var.region
  plan                = var.plan
  os_id               = data.vultr_os.selected.id
  label               = var.label
  environment         = var.environment
  firewall_group_id   = module.networking.firewall_group_id
  ssh_public_key_path = var.ssh_public_key_path
}
