#!/bin/bash
# terraform plan: shows exactly what would be created, changed, or
# destroyed, without touching anything. Run this before every apply.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
require_terraform
load_env
cd "$LAB_DIR"

varfile="$(resolve_varfile "${1:-dev}")"
info "using $varfile"

if [ "${1:-dev}" = "prod" ]; then
  warn "you're planning against environments/prod.tfvars — read the comment"
  warn "at the top of that file before you apply it."
fi

step "terraform plan"
terraform plan -var-file="$varfile" -out=tfplan

cat <<NEXT

  Review the plan above: '+' creates, '~' changes in place, '-/+' destroys
  and recreates, '-' destroys. Then:

    ./03-apply.sh ${1:-dev}
NEXT
