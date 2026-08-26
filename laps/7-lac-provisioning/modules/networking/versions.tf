# Every module that directly uses a "vultr_*" resource needs its own copy of
# this block — Terraform does not infer the source address for a non-
# hashicorp-namespaced provider from the root module. Omitting this made
# init default "vultr" to the legacy hashicorp/vultr namespace and fail.
terraform {
  required_providers {
    vultr = {
      source = "vultr/vultr"
    }
  }
}
