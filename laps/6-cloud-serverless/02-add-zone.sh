#!/bin/bash
# Adds sokhin.site to your Cloudflare account as a zone. Free, and it does
# NOT touch your domain yet — Hostinger is still authoritative until you
# change the nameservers by hand (step 2 of this script's output).
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib/cloudflare.sh"
load_env

zone_id="$(state_get ZONE_ID)"
if [ -z "$zone_id" ]; then
  zone_id="$(lookup_zone_id)"
fi

if [ -n "$zone_id" ]; then
  info "zone $zone_id already exists for $LAB_DOMAIN — not creating another one"
else
  step "1. Creating the zone"
  echo "  jump_start: true tells Cloudflare to scan Hostinger's current DNS"
  echo "  and copy what it finds — including the existing A record you saw"
  echo "  in ./01-check.sh — into the new zone automatically."
  echo
  confirm "Add $LAB_DOMAIN to Cloudflare now?" || { info "nothing created"; exit 0; }

  body="$(jq -n --arg name "$LAB_DOMAIN" --arg account_id "$CLOUDFLARE_ACCOUNT_ID" \
    '{name: $name, account: {id: $account_id}, jump_start: true}')"
  zone="$(api POST /zones "$body")"
  zone_id="$(printf '%s' "$zone" | jq -r '.id')"
  ok "zone created: $zone_id"
fi
state_set ZONE_ID "$zone_id"

step "2. What you need to do at Hostinger"
zone="$(api GET "/zones/$zone_id")"
status="$(printf '%s' "$zone" | jq -r '.status')"
ns1="$(printf '%s' "$zone" | jq -r '.name_servers[0]')"
ns2="$(printf '%s' "$zone" | jq -r '.name_servers[1]')"

cat <<INSTRUCTIONS
  Cloudflare assigned these nameservers to $LAB_DOMAIN:

      $ns1
      $ns2

  This part cannot be scripted — it's a manual change on a live domain,
  and only you should make it:

    1. Log in to Hostinger -> Domains -> $LAB_DOMAIN
    2. Find "Nameservers" (sometimes under DNS / Advanced)
    3. Switch from Hostinger's nameservers to "Custom nameservers"
    4. Enter the two Cloudflare nameservers above, save

  Current status of the zone: ${C_BOLD}$status${C_RESET}
  ("pending" until Cloudflare sees the nameserver change; this is normal
  right after creating the zone, before you've touched Hostinger at all)
INSTRUCTIONS

if [ "$(printf '%s' "$zone" | jq '.name_servers | length')" = "0" ]; then
  warn "no nameservers were returned — the zone may still be initializing, re-run this script in a minute"
fi

step "3. What got imported"
echo "  Compare this against state/pre-migration-dns.json from ./01-check.sh:"
echo
api GET "/zones/$zone_id/dns_records?per_page=100" | jq -r \
  '.[] | "  \(.type)\t\(.name)\t\(.content)\t\(if .proxied then "proxied" else "DNS only" end)"'

cat <<NEXT

  Once you've changed the nameservers at Hostinger:

    ./03-wait-for-activation.sh
NEXT
