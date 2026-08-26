#!/bin/bash
# terraform apply: creates or updates real infrastructure. THIS STARTS
# BILLING for a new instance and keeps billing until ./99-destroy.sh.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
require_terraform
load_env
cd "$LAB_DIR"

env_name="${1:-dev}"
varfile="$(resolve_varfile "$env_name")"

step "1. What this will cost"
plan_id="$(grep -E '^\s*plan\s*=' "$varfile" | head -1 | sed -E 's/.*"([^"]+)".*/\1/')"
monthly="$(curl -s -m 10 -H "Authorization: Bearer $VULTR_API_KEY" \
  "https://api.vultr.com/v2/plans?per_page=500" \
  | jq -r --arg p "$plan_id" '.plans[] | select(.id == $p) | .monthly_cost' 2>/dev/null || echo "")"
echo "  var-file : $varfile"
echo "  plan     : ${plan_id:-unknown}${monthly:+  (about \$$monthly/month, billed hourly, until ./99-destroy.sh)}"

if [ "$env_name" = "prod" ]; then
  warn "applying prod.tfvars against the SAME state as dev REPLACES the dev"
  warn "instance in place, unless you've run 'terraform workspace new prod' first."
fi

step "2. terraform apply"
if [ -f "$LAB_DIR/tfplan" ]; then
  info "applying the saved plan from ./02-plan.sh"
  terraform apply tfplan
  rm -f "$LAB_DIR/tfplan"
else
  info "no saved plan found — planning and applying together"
  confirm "Continue?" || { info "nothing applied"; exit 0; }
  terraform apply -var-file="$varfile"
fi

step "3. Outputs"
terraform output

ip="$(terraform output -raw instance_ip)"
[ -n "$ip" ] && [ "$ip" != "0.0.0.0" ] || die "instance has no IP yet — wait a moment and check: terraform refresh"

step "4. Waiting for the instance to finish booting"
wait_for_boot "$ip" || true

cat <<NEXT

  Open it: http://$ip/
  SSH in:  $(terraform output -raw ssh_command 2>/dev/null || echo "ssh root@$ip")

  Next: ./04-verify.sh $env_name
NEXT
