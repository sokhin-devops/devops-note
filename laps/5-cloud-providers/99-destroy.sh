#!/bin/bash
# Deletes everything this lab created. Run it when you are done — the VM is
# billed by the hour until it is gone.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib/vultr.sh"
load_env

instance_id="$(state_get INSTANCE_ID)"
firewall_id="$(state_get FIREWALL_GROUP_ID)"
key_id="$(state_get SSH_KEY_ID)"
ip="$(state_get INSTANCE_IP)"

step "What will be deleted"
[ -n "$instance_id" ] && echo "  instance       $instance_id  ($ip)" || echo "  instance       ${C_DIM}none recorded${C_RESET}"
[ -n "$firewall_id" ] && echo "  firewall group $firewall_id" || echo "  firewall group ${C_DIM}none recorded${C_RESET}"
[ -n "$key_id" ]      && echo "  ssh key        $key_id" || echo "  ssh key        ${C_DIM}none recorded${C_RESET}"

if [ -z "$instance_id" ] && [ -z "$firewall_id" ] && [ -z "$key_id" ]; then
  info "state is empty — nothing to destroy"
  exit 0
fi

echo
warn "this cannot be undone; the VM and everything on it is erased"
confirm "Delete all of the above?" || { info "nothing deleted"; exit 0; }

# The instance must go first: Vultr will not delete a firewall group that is
# still attached to a server.
if [ -n "$instance_id" ]; then
  step "Deleting the instance"
  api DELETE "/instances/$instance_id" >/dev/null
  ok "instance $instance_id deleted — billing stops"

  info "waiting for it to disappear before removing the firewall group"
  for i in $(seq 1 20); do
    if ! curl -sS -o /dev/null -w '%{http_code}' \
        -H "Authorization: Bearer $VULTR_API_KEY" \
        "$VULTR_API/instances/$instance_id" | grep -q '^2'; then
      break
    fi
    sleep 5
  done
fi

if [ -n "$firewall_id" ]; then
  step "Deleting the firewall group"
  if api DELETE "/firewalls/$firewall_id" >/dev/null 2>&1; then
    ok "firewall group $firewall_id deleted"
  else
    warn "could not delete firewall group $firewall_id — it may still be attached."
    warn "wait a minute and run this script again, or remove it in the console."
  fi
fi

if [ -n "$key_id" ]; then
  step "The SSH key"
  echo "  The key '$LAB_LABEL' ($key_id) is still registered with Vultr."
  echo "  It costs nothing and is reused if you run the lab again."
  if confirm "  Delete it too?"; then
    api DELETE "/ssh-keys/$key_id" >/dev/null
    ok "ssh key deleted"
  else
    info "keeping the ssh key"
    keep_key=1
  fi
fi

step "Clearing local state"
if [ "${keep_key:-0}" = "1" ]; then
  state_clear
  state_set SSH_KEY_ID "$key_id"
  ok "state cleared (kept the ssh key id)"
else
  state_clear
  ok "state/lab.env removed"
fi

step "Confirming with the API"
remaining="$(api GET "/instances?tag=devops-lab" | jq -r '.instances | length')"
if [ "$remaining" = "0" ]; then
  ok "no instances tagged 'devops-lab' remain on the account"
else
  warn "$remaining instance(s) tagged 'devops-lab' still exist — check https://my.vultr.com"
fi

echo
echo "  Done. Verify your billing at https://my.vultr.com/billing/"
