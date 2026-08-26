#!/bin/bash
# Polls until Cloudflare sees the nameserver change at Hostinger and marks
# the zone "active". Read-only. Safe to Ctrl-C and re-run any time.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib/cloudflare.sh"
load_env

zone_id="$(state_require ZONE_ID "./02-add-zone.sh")"

step "1. Current nameservers for $LAB_DOMAIN, as seen from the internet"
ns_now="$(doh "$LAB_DOMAIN" NS)"
printf '%s' "$ns_now" | jq -r '.[].data' | sed 's/^/  /'

step "2. Waiting for Cloudflare to confirm activation"
echo "  Nameserver changes at Hostinger are often fast, but can take from a"
echo "  few minutes up to a few hours to be visible everywhere. This polls"
echo "  for up to 15 minutes; if it times out, just run it again later —"
echo "  nothing here is destructive, and there's no harm in checking daily."
echo

status="pending"
for i in $(seq 1 30); do
  status="$(api GET "/zones/$zone_id" | jq -r '.status')"
  printf '\r  status=%s   attempt %s/30   ' "$status" "$i"
  [ "$status" = "active" ] && break
  sleep 30
done
echo

if [ "$status" != "active" ]; then
  warn "still '$status' after 15 minutes"
  echo "  Check the nameservers you see above against what ./02-add-zone.sh"
  echo "  printed. If they don't match yet, the change hasn't been saved at"
  echo "  Hostinger, or hasn't propagated. Re-run this script later:"
  echo "    ./03-wait-for-activation.sh"
  exit 1
fi

ok "zone is active — Cloudflare is now authoritative for $LAB_DOMAIN"

step "3. Comparing imported records against the pre-migration snapshot"
snapshot="$LAB_DIR/state/pre-migration-dns.json"
if [ -f "$snapshot" ]; then
  echo "  Before (Hostinger, from ./01-check.sh):"
  jq -r '
    (.a[]?   | "    A    \(.name) -> \(.data)"),
    (.www[]? | select(.type==1) | "    A    \(.name) -> \(.data)"),
    (.mx[]?  | "    MX   \(.name) -> \(.data)")
  ' "$snapshot" 2>/dev/null | sort -u
  [ -s "$snapshot" ] || echo "    (no snapshot found — run ./01-check.sh next time before migrating)"
else
  warn "no pre-migration snapshot found at state/pre-migration-dns.json"
fi

echo
echo "  Now (Cloudflare):"
api GET "/zones/$zone_id/dns_records?per_page=100" | jq -r \
  '.[] | select(.type=="A" or .type=="MX") | "    \(.type)\t\(.name) -> \(.content)"'

cat <<NEXT

  If anything you relied on before is missing above, add it in the
  Cloudflare dashboard (DNS -> Records) before treating the migration as
  finished. This lab only ever adds a new subdomain — it never removes
  or edits an existing record.

  Next: ./04-deploy-worker.sh
NEXT
