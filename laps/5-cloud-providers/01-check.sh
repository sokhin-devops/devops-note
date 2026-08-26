#!/bin/bash
# Read-only. Creates nothing, costs nothing. Run this first.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib/vultr.sh"
load_env

step "1. Does the API key work?"
account="$(api GET /account)"
echo "$account" | jq -r '.account | "  account : \(.email)\n  balance : $\(.balance)\n  pending : $\(.pending_charges)"'
ok "the key in .env is valid"

step "2. Your SSH key"
[ -f "$SSH_PUBLIC_KEY" ] || die "no public key at $SSH_PUBLIC_KEY (create one with: ssh-keygen -t ed25519)"
[ -f "$SSH_PRIVATE_KEY" ] || die "no private key at $SSH_PRIVATE_KEY"
echo "  public  : $SSH_PUBLIC_KEY"
echo "  private : $SSH_PRIVATE_KEY"
ok "key pair found"

step "3. Regions (lesson 6-7: pick one close to your users)"
api GET "/regions?per_page=500" | jq -r \
  '.regions[] | "  \(.id)\t\(.city), \(.country)\t\(.continent)"' | sort | head -30
echo "  ${C_DIM}(showing the first 30)${C_RESET}"
echo
echo "  configured region: ${C_BOLD}$VULTR_REGION${C_RESET}"
api GET "/regions?per_page=500" | jq -e -r --arg r "$VULTR_REGION" \
  '.regions[] | select(.id == $r) | "  -> \(.city), \(.country)"' \
  || die "region '$VULTR_REGION' does not exist"

step "4. Plans available in $VULTR_REGION (lesson 37: know the price first)"
api GET "/plans?type=vc2&per_page=500" | jq -r --arg r "$VULTR_REGION" \
  '.plans[] | select(.locations | index($r)) |
   "  \(.id)\t\(.vcpu_count) vCPU\t\(.ram) MB\t\(.disk) GB\t$\(.monthly_cost)/mo"' | head -10

echo
plan_json="$(api GET "/plans?type=vc2&per_page=500" | jq -r --arg p "$VULTR_PLAN" '.plans[] | select(.id == $p)')"
[ -n "$plan_json" ] || die "plan '$VULTR_PLAN' does not exist"
echo "$plan_json" | jq -e -r --arg r "$VULTR_REGION" \
  'select(.locations | index($r)) | "  configured plan: \(.id) — $\(.monthly_cost)/month"' \
  || die "plan '$VULTR_PLAN' is not offered in region '$VULTR_REGION' — pick another from the list above"
ok "plan is available in your region"

step "5. Operating system"
os_id="$(lookup_os_id)"
echo "  $VULTR_OS_NAME -> os_id $os_id"
ok "OS found"

step "Summary"
monthly="$(echo "$plan_json" | jq -r '.monthly_cost')"
cat <<SUMMARY
  region   : $VULTR_REGION
  plan     : $VULTR_PLAN  (\$$monthly/month while it exists)
  os       : $VULTR_OS_NAME (id $os_id)
  label    : $LAB_LABEL

  Nothing has been created yet. Next:
    ./02-create-firewall.sh   (free)
    ./03-create-instance.sh   (starts billing)
SUMMARY
