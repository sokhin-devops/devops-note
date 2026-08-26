variable "region" {
  description = "Vultr region id. sgp = Singapore, closest to Cambodia."
  type        = string
  default     = "sgp"
}

variable "plan" {
  description = "Vultr plan id (the instance size)."
  type        = string
  default     = "vc2-1c-1gb"
}

variable "os_name" {
  description = "OS name, matched against the Vultr OS catalogue by data.vultr_os."
  type        = string
  default     = "Ubuntu 24.04 LTS x64"
}

variable "label" {
  description = "Label applied to every resource this configuration creates."
  type        = string
  default     = "devops-lab-tf"
}

variable "ssh_public_key_path" {
  description = "Path to the public key uploaded to Vultr and installed on the instance."
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "environment" {
  description = "Which environment this apply represents."
  type        = string
  default     = "dev"

  # The exact validation block from D7.lac-provisioning.md, section 16.
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod."
  }
}
