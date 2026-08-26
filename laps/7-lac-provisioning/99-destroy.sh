#!/bin/bash
# terraform destroy: removes every resource this configuration's state
# knows about. Run this when you're done — billing continues until you do.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
require_terraform
load_env
cd "$LAB_DIR"

env_name="${1:-dev}"
varfile="$(resolve_varfile "$env_name")"

step "What terraform destroy will remove"
if ! terraform state list >/dev/null 2>&1 || [ -z "$(terraform state list 2>/dev/null)" ]; then
  info "state is empty — nothing to destroy"
  exit 0
fi
terraform state list | sed 's/^/  /'

echo
warn "this cannot be undone; the instance and everything on it is erased"
confirm "Run terraform destroy -var-file=$varfile ?" || { info "nothing destroyed"; exit 0; }

step "terraform destroy"
terraform destroy -var-file="$varfile"

ok "destroyed — billing stops here"

cat <<NOTE

  Verify at https://my.vultr.com/billing/ that nothing tagged
  'devops-lab' remains.

  rm -f tfplan   # if a stale saved plan is still lying around
NOTE
