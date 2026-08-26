#!/bin/bash
# terraform init downloads the Vultr provider plugin (versions.tf pins which
# one) and sets up the local backend. Safe to re-run any time.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
require_terraform
cd "$LAB_DIR"

step "1. terraform init"
terraform init -upgrade

step "2. terraform validate"
terraform validate

step "3. terraform fmt"
terraform fmt -recursive .
ok "formatted"

cat <<NEXT

  Next:
    ./02-plan.sh          # dev by default
    ./02-plan.sh prod     # see environments/prod.tfvars first — it warns you why
NEXT
