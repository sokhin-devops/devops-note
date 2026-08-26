#!/bin/bash
# Creates the KV namespace the rate limiter needs, renders wrangler.toml,
# and deploys the Worker. This does NOT need the zone to be active yet —
# it only needs your Cloudflare account, so you can run this while you're
# still waiting on ./03-wait-for-activation.sh.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib/cloudflare.sh"
load_env

account_id="$(state_require ACCOUNT_ID "./01-check.sh")"

step "1. KV namespace for the rate limiter"
kv_id="$(state_get KV_NAMESPACE_ID)"
if [ -n "$kv_id" ]; then
  info "reusing KV namespace $kv_id"
else
  title="${WORKER_NAME}-rate-limit"
  existing="$(api GET "/accounts/$account_id/storage/kv/namespaces?per_page=100" \
    | jq -r --arg t "$title" '.[] | select(.title == $t) | .id' | head -1)"
  if [ -n "$existing" ]; then
    kv_id="$existing"
    info "found existing KV namespace '$title' ($kv_id)"
  else
    kv_id="$(api POST "/accounts/$account_id/storage/kv/namespaces" \
      "$(jq -n --arg t "$title" '{title: $t}')" | jq -r '.id')"
    ok "created KV namespace '$title' ($kv_id)"
  fi
fi
state_set KV_NAMESPACE_ID "$kv_id"

step "2. Rendering wrangler.toml"
template="$(cat "$LAB_DIR/worker/wrangler.toml.template")"
rendered="${template//__WORKER_NAME__/$WORKER_NAME}"
rendered="${rendered//__ACCOUNT_ID__/$account_id}"
rendered="${rendered//__KV_NAMESPACE_ID__/$kv_id}"
printf '%s\n' "$rendered" > "$LAB_DIR/worker/wrangler.toml"
ok "wrote worker/wrangler.toml (gitignored — holds real ids)"

step "3. Deploying"
echo "  The first run downloads wrangler via npx; that can take a minute."
echo

deploy_log="$(mktemp)"
(
  cd "$LAB_DIR/worker"
  CLOUDFLARE_API_TOKEN="$CLOUDFLARE_API_TOKEN" \
  CLOUDFLARE_ACCOUNT_ID="$account_id" \
    npx --yes wrangler@latest deploy
) 2>&1 | tee "$deploy_log" | sed 's/^/  /'

worker_url="$(grep -oE 'https://[a-zA-Z0-9.-]+\.workers\.dev' "$deploy_log" | head -1)"
rm -f "$deploy_log"

if [ -z "$worker_url" ]; then
  warn "could not find the workers.dev URL in wrangler's output above"
  warn "look for it in the Cloudflare dashboard under Workers & Pages"
else
  state_set WORKER_URL "$worker_url"
  ok "deployed to $worker_url"
fi

step "4. Quick check"
if [ -n "$worker_url" ]; then
  code="$(curl -s -o /dev/null -m 10 -w '%{http_code}' "$worker_url/health")"
  [ "$code" = "200" ] \
    && ok "GET $worker_url/health -> $code" \
    || warn "GET $worker_url/health -> $code (Workers can take a few seconds to go live)"
fi

cat <<NEXT

  Try it now, no domain required:

    curl $worker_url/health
    curl $worker_url/api/hello?name=You
    curl $worker_url/api/whoami

  Next:
    ./05-route-domain.sh   (needs the zone to be active — see ./03)
    ./06-verify.sh         (works against workers.dev right now)
NEXT
