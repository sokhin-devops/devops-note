variable "region" {
  type = string
}

variable "plan" {
  type = string
}

variable "os_id" {
  description = "Numeric OS id, resolved by data.vultr_os in the root module"
  type        = string
}

variable "label" {
  type = string
}

variable "environment" {
  type = string
}

variable "firewall_group_id" {
  type = string
}

variable "ssh_public_key_path" {
  type = string
}
