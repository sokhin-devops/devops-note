# No api_key here on purpose. The provider reads the VULTR_API_KEY
# environment variable automatically — see .env.example — so the key never
# has to be written into any .tf or .tfvars file.
provider "vultr" {}
