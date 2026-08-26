#!/bin/bash
# Attaches the Worker to https://edge.sokhin.site (or whatever
# WORKER_SUBDOMAIN.LAB_DOMAIN resolves to in .env), using Cloudflare's
# Custom Domains for Workers. This creates the DNS record and certificate
# for you — it does not touch any record that already existed.
#
# Needs the zone to be active (./03-wait-for-activation.sh).
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib/cloudflare.sh"
load_env

account_id="$(state_require ACCOUNT_ID "./01-check.sh")"
zone_id="$(state_require ZONE_ID "./02-add-zone.sh")"
[ -n "$(state_get KV_NAMESPACE_ID)" ] || die "run ./04-deploy-worker.sh first"

status="$(api GET "/zones/$zone_id" | jq -r '.status')"
[ "$status" = "active" ] || die "zone status is '$status', not 'active' — run ./03-wait-for-activation.sh first"

step "1. Checking $WORKER_HOSTNAME doesn't already exist"
existing_record="$(api GET "/zones/$zone_id/dns_records?name=$WORKER_HOSTNAME" | jq -r '.[0].id // empty')"
if [ -n "$existing_record" ]; then
  warn "a DNS record for $WORKER_HOSTNAME already exists (id $existing_record)"
  confirm "Continue anyway? (Custom Domains manages its own record; this should be safe)" \
    || { info "stopping — nothing changed"; exit 0; }
fi

step "2. Attaching the Worker to $WORKER_HOSTNAME"
echo "  This uses Workers Custom Domains: Cloudflare creates the DNS record"
echo "  and TLS certificate for this one subdomain automatically. The root"
echo "  domain ($LAB_DOMAIN) and any record on it are untouched."
echo
confirm "Attach $WORKER_NAME to $WORKER_HOSTNAME now?" || { info "nothing changed"; exit 0; }

body="$(jq -n \
  --arg hostname "$WORKER_HOSTNAME" \
  --arg zone_id "$zone_id" \
  --arg service "$WORKER_NAME" \
  '{hostname: $hostname, zone_id: $zone_id, service: $service, environment: "production"}')"

domain="$(api PUT "/accounts/$account_id/workers/domains" "$body")"
domain_id="$(printf '%s' "$domain" | jq -r '.id')"
state_set WORKER_DOMAIN_ID "$domain_id"
ok "attached (id $domain_id)"

step "3. Waiting for the certificate"
for i in $(seq 1 20); do
  code="$(curl -s -o /dev/null -m 8 -w '%{http_code}' "https://$WORKER_HOSTNAME/health" 2>/dev/null || echo "000")"
  printf '\r  https://%s/health -> %s   attempt %s/20   ' "$WORKER_HOSTNAME" "$code" "$i"
  [ "$code" = "200" ] && break
  sleep 10
done
echo

if [ "$code" = "200" ]; then
  ok "https://$WORKER_HOSTNAME is live"
else
  warn "not answering 200 yet — certificates can take a few minutes; try again shortly:"
  echo "    curl https://$WORKER_HOSTNAME/health"
fi

cat <<NEXT

  Next: ./06-verify.sh
NEXT
