output "instance_id" {
  description = "Vultr instance id"
  value       = module.compute.instance_id
}

output "instance_ip" {
  description = "Public IPv4 address of the instance"
  value       = module.compute.main_ip
}

output "ssh_command" {
  description = "Ready-to-paste SSH command"
  value       = "ssh root@${module.compute.main_ip}"
}

output "firewall_group_id" {
  description = "Vultr firewall group id (22, 80, 443 allowed; everything else dropped)"
  value       = module.networking.firewall_group_id
}

output "environment" {
  description = "Which environment this state represents"
  value       = var.environment
}
