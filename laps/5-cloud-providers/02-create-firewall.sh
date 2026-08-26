#!/bin/bash
# Creates a Vultr Cloud Firewall that allows only SSH, HTTP and HTTPS.
# Firewall groups are free — this script does not start any billing.
#
# Lesson 18-19: the cloud firewall is the outer layer. The VM will also run
# UFW inside the OS (installed by cloud-init), so traffic passes two filters.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib/vultr.sh"
load_env

existing="$(state_get FIREWALL_GROUP_ID)"
if [ -n "$existing" ]; then
  info "firewall group $existing already recorded in state — reusing it"
else
  step "Creating the firewall group"
  fw="$(api POST /firewalls "$(jq -n --arg d "$LAB_LABEL" '{description: $d}')")"
  existing="$(echo "$fw" | jq -r '.firewall_group.id')"
  [ -n "$existing" ] && [ "$existing" != "null" ] || die "could not read the new firewall id"
  state_set FIREWALL_GROUP_ID "$existing"
  ok "created firewall group $existing"
fi

# add_rule PORT NOTE
add_rule() {
  local port="$1" note="$2"
  local body
  body="$(jq -n --arg p "$port" --arg n "$note" \
    '{ip_type: "v4", protocol: "tcp", subnet: "0.0.0.0", subnet_size: 0, port: $p, notes: $n}')"
  api POST "/firewalls/$existing/rules" "$body" >/dev/null
  ok "allow tcp/$port from anywhere  ($note)"
}

step "Adding rules"
have_rules="$(api GET "/firewalls/$existing/rules" | jq -r '.firewall_rules | length')"
if [ "${have_rules:-0}" -gt 0 ]; then
  info "the group already has $have_rules rule(s) — not adding duplicates"
else
  add_rule 22  "SSH"
  add_rule 80  "HTTP"
  add_rule 443 "HTTPS"
fi

step "Current rules"
api GET "/firewalls/$existing/rules" | jq -r \
  '.firewall_rules[] | "  #\(.id)\t\(.protocol)/\(.port)\tfrom \(.subnet)/\(.subnet_size)\t\(.notes)"'

cat <<NOTE

  Everything not listed above is dropped before it reaches the VM.
  That is the whole point of lesson 19: PostgreSQL (5432), Redis (6379)
  and the Docker API (2375) are unreachable from the internet by default,
  and you will prove it in ./06-verify.sh.

  Next: ./03-create-instance.sh   (this one starts billing)
NOTE
