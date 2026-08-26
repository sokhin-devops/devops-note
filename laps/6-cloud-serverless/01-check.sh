#!/bin/bash
# Read-only. Creates nothing. Run this first, and re-run it any time you're
# unsure what state the domain or the account is in.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib/cloudflare.sh"
load_env

step "1. Does the API token work?"
verify="$(api GET /user/tokens/verify)"
echo "  status : $(printf '%s' "$verify" | jq -r '.status')"
ok "the token in .env is valid"

step "2. Which account(s) can it see?"
account_id="$(resolve_account_id)"
name="$(api GET "/accounts/$account_id" | jq -r '.name')"
echo "  account : $name ($account_id)"
state_set ACCOUNT_ID "$account_id"
ok "using account $account_id"

step "3. Node / npx / wrangler"
command -v node >/dev/null 2>&1 && echo "  node : $(node -v)" || warn "node not found — required to run wrangler"
echo "  wrangler will be fetched on demand via 'npx wrangler@latest' in 04-deploy-worker.sh"

step "4. What does $LAB_DOMAIN look like on the internet right now?"
echo "  (queried via Cloudflare's own resolver, so this works before the"
echo "   domain is anywhere near Cloudflare)"
echo
ns="$(doh "$LAB_DOMAIN" NS)"
a="$(doh "$LAB_DOMAIN" A)"
www="$(doh "www.$LAB_DOMAIN" A)"
mx="$(doh "$LAB_DOMAIN" MX)"
txt="$(doh "$LAB_DOMAIN" TXT)"

echo "  NS   : $(printf '%s' "$ns"  | jq -r '[.[].data] | join(", ")')"
echo "  A    : $(printf '%s' "$a"   | jq -r '[.[].data] | join(", ") // "(none)"')"
echo "  www  : $(printf '%s' "$www" | jq -r '[.[].data] | join(", ") // "(none)"')"
echo "  MX   : $(printf '%s' "$mx"  | jq -r 'if length==0 then "(none)" else [.[].data] | join(", ") end')"
echo "  TXT  : $(printf '%s' "$txt" | jq -r 'if length==0 then "(none)" else [.[].data] | join(", ") end')"

# Save this now, before anything changes, so 03-wait-for-activation.sh can
# show you exactly what existed beforehand next to what Cloudflare imports.
snapshot="$LAB_DIR/state/pre-migration-dns.json"
jq -n --argjson ns "$ns" --argjson a "$a" --argjson www "$www" --argjson mx "$mx" --argjson txt "$txt" \
  '{ns: $ns, a: $a, www: $www, mx: $mx, txt: $txt}' > "$snapshot"
ok "snapshot saved to state/pre-migration-dns.json"

echo
if [ "$(printf '%s' "$a" | jq 'length')" -gt 0 ]; then
  warn "$LAB_DOMAIN has a live A record. If that points at a server you use,"
  warn "double check it survives the import in step 3 of the README before"
  warn "you rely on the domain again."
fi

if [ "$(printf '%s' "$mx" | jq 'length')" -gt 0 ]; then
  warn "$LAB_DOMAIN has MX records — it receives email. Moving nameservers"
  warn "to Cloudflare does not stop mail delivery by itself, but you MUST"
  warn "confirm the MX records were imported before treating the move as done."
fi

step "5. Existing Cloudflare zone?"
existing_zone="$(lookup_zone_id)"
if [ -n "$existing_zone" ]; then
  status="$(api GET "/zones/$existing_zone" | jq -r '.status')"
  info "$LAB_DOMAIN is already a zone on this account (id $existing_zone, status: $status)"
  state_set ZONE_ID "$existing_zone"
else
  info "$LAB_DOMAIN is not yet a zone on this Cloudflare account"
fi

cat <<SUMMARY

Summary
------------------------------------------------------------
  domain   : $LAB_DOMAIN
  worker   : $WORKER_NAME  (will be served at $WORKER_HOSTNAME)
  account  : $account_id

  Nothing has been changed. Next:
    ./02-add-zone.sh
SUMMARY
