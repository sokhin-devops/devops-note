#!/bin/bash
# Removes everything this lab created: the custom domain attachment, the
# Worker script, and the KV namespace.
#
# Deliberately does NOT touch:
#   - the zone (sokhin.site staying on Cloudflare is harmless and free,
#     and gives your existing A record free CDN/SSL as a side effect)
#   - the nameservers at Hostinger (reverting them is optional and manual —
#     see the README if you actually want to move back)
#   - any DNS record that existed before this lab touched anything
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib/cloudflare.sh"
load_env

account_id="$(state_get ACCOUNT_ID)"
domain_id="$(state_get WORKER_DOMAIN_ID)"
kv_id="$(state_get KV_NAMESPACE_ID)"

step "What will be removed"
[ -n "$domain_id" ] && echo "  custom domain   $WORKER_HOSTNAME (id $domain_id)" \
                     || echo "  custom domain   ${C_DIM}none recorded${C_RESET}"
echo "  worker script   $WORKER_NAME"
[ -n "$kv_id" ] && echo "  kv namespace    $kv_id" || echo "  kv namespace    ${C_DIM}none recorded${C_RESET}"

echo
echo "  ${C_DIM}left alone: the sokhin.site zone, its nameservers, and every"
echo "  DNS record that existed before this lab${C_RESET}"
echo
confirm "Remove the items listed above?" || { info "nothing removed"; exit 0; }

if [ -n "$domain_id" ] && [ -n "$account_id" ]; then
  step "Detaching the custom domain"
  if api DELETE "/accounts/$account_id/workers/domains/$domain_id" >/dev/null 2>&1; then
    ok "detached $WORKER_HOSTNAME"
  else
    warn "could not detach it via API — remove it in the dashboard under Workers & Pages -> Domains"
  fi
fi

if [ -n "$account_id" ]; then
  step "Deleting the Worker script"
  if api DELETE "/accounts/$account_id/workers/scripts/$WORKER_NAME" >/dev/null 2>&1; then
    ok "deleted $WORKER_NAME"
  else
    warn "could not delete it via API (it may already be gone) — check the dashboard"
  fi
fi

if [ -n "$kv_id" ] && [ -n "$account_id" ]; then
  step "The KV namespace"
  echo "  It only ever held rate-limit counters — nothing worth keeping."
  if confirm "  Delete it too?"; then
    api DELETE "/accounts/$account_id/storage/kv/namespaces/$kv_id" >/dev/null 2>&1 \
      && ok "deleted" \
      || warn "could not delete it via API — check the dashboard"
  else
    info "keeping the KV namespace"
  fi
fi

step "Clearing local state"
rm -f "$LAB_DIR/worker/wrangler.toml"
state_clear
ok "state cleared and worker/wrangler.toml removed"

cat <<NOTE

  Done. $LAB_DOMAIN is still a Cloudflare zone with your original DNS
  records imported — that part was never undone, because it's harmless
  and reverting it means yet another nameserver change at Hostinger.

  If you genuinely want $LAB_DOMAIN back on Hostinger's own nameservers:
    1. Hostinger -> Domains -> $LAB_DOMAIN -> Nameservers -> switch back
       to Hostinger's default nameservers
    2. Once that propagates, delete the zone in the Cloudflare dashboard
       (Cloudflare will not let the API or dashboard delete an active
       zone while it's still the one answering DNS for the domain)
NOTE
