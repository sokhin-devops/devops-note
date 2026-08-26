# Demonstrates the lesson's per-environment tfvars pattern (section 16) —
# this is NOT something to apply casually.
#
# Applying this against the SAME state as dev.tfvars does not create a
# second server: it's the same resource addresses in the same state file,
# so Terraform would REPLACE the dev instance with a prod-sized one. Real
# side-by-side dev/prod needs a separate Terraform workspace too:
#
#   terraform workspace new prod
#   terraform apply -var-file=environments/prod.tfvars
#   terraform workspace select default   # back to dev's state
#
# ~$10/month while the instance exists.

region      = "sgp"
plan        = "vc2-1c-2gb"
label       = "devops-lab-tf-prod"
environment = "prod"
