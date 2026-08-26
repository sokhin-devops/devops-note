#!/bin/bash
# Creates the Ubuntu VM. THIS STARTS BILLING and keeps billing until you run
# ./99-destroy.sh.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib/vultr.sh"
load_env

existing="$(state_get INSTANCE_ID)"
if [ -n "$existing" ]; then
  info "instance $existing is already recorded in state"
  info "run ./04-status.sh to check on it, or ./99-destroy.sh to remove it"
  exit 0
fi

firewall_id="$(state_require FIREWALL_GROUP_ID "./02-create-firewall.sh")"

step "1. Registering your SSH key with Vultr"
pubkey="$(cat "$SSH_PUBLIC_KEY")"
key_id="$(api GET "/ssh-keys?per_page=500" | jq -r --arg n "$LAB_LABEL" \
  '.ssh_keys[] | select(.name == $n) | .id' | head -1)"

if [ -n "$key_id" ]; then
  ok "reusing the key already named '$LAB_LABEL' (id $key_id)"
else
  key_id="$(api POST /ssh-keys "$(jq -n --arg n "$LAB_LABEL" --arg k "$pubkey" \
    '{name: $n, ssh_key: $k}')" | jq -r '.ssh_key.id')"
  ok "uploaded $SSH_PUBLIC_KEY as '$LAB_LABEL' (id $key_id)"
fi
state_set SSH_KEY_ID "$key_id"

step "2. Rendering cloud-init"
template="$(cat "$LAB_DIR/cloud-init/user-data.yaml")"
rendered="${template//__SSH_PUBLIC_KEY__/$pubkey}"
user_data="$(printf '%s' "$rendered" | base64 | tr -d '\n\r')"
ok "user-data prepared ($(printf '%s' "$rendered" | wc -l) lines)"
echo "  it will: apt upgrade, install Docker + Compose, enable UFW (22/80/443),"
echo "           and create a 'deploy' user holding the same SSH key"

step "3. What is about to be created"
os_id="$(lookup_os_id)"
monthly="$(api GET "/plans?type=vc2&per_page=500" | jq -r --arg p "$VULTR_PLAN" \
  '.plans[] | select(.id == $p) | .monthly_cost')"

cat <<PLAN
  region        : $VULTR_REGION
  plan          : $VULTR_PLAN
  os            : $VULTR_OS_NAME (id $os_id)
  label         : $LAB_LABEL
  firewall      : $firewall_id
  ssh key       : $key_id
  ${C_BOLD}cost          : about \$$monthly per month, billed hourly, from the moment
                  it boots until ./99-destroy.sh deletes it${C_RESET}
PLAN

echo
confirm "Create this VM now?" || { info "nothing created"; exit 0; }

step "4. Creating"
body="$(jq -n \
  --arg region "$VULTR_REGION" \
  --arg plan "$VULTR_PLAN" \
  --argjson os_id "$os_id" \
  --arg label "$LAB_LABEL" \
  --arg hostname "$LAB_LABEL" \
  --arg fw "$firewall_id" \
  --arg key "$key_id" \
  --arg ud "$user_data" \
  '{region: $region, plan: $plan, os_id: $os_id, label: $label,
    hostname: $hostname, firewall_group_id: $fw, sshkey_id: [$key],
    user_data: $ud, backups: "disabled", enable_ipv6: false,
    tags: ["devops-lab"]}')"

instance="$(api POST /instances "$body")"
instance_id="$(echo "$instance" | jq -r '.instance.id')"
[ -n "$instance_id" ] && [ "$instance_id" != "null" ] || die "could not read the new instance id"

state_set INSTANCE_ID "$instance_id"
ok "instance $instance_id created"

cat <<NEXT

  Vultr is now provisioning it, and cloud-init still has to run.
  Expect 2-4 minutes before SSH works.

  Next: ./04-status.sh   (polls until the VM is up and bootstrapped)
NEXT
