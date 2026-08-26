output "instance_id" {
  value = vultr_instance.this.id
}

output "main_ip" {
  value = vultr_instance.this.main_ip
}
