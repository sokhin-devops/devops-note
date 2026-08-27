#!/bin/bash
# Checks the deployed Worker: the workers.dev URL always, the custom domain
# if it's attached, and the rate limiter by deliberately tripping it.
set -uo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib/cloudflare.sh"
load_env

worker_url="$(state_get WORKER_URL)"
[ -n "$worker_url" ] || die "WORKER_URL is not in state — run ./04-deploy-worker.sh first"

custom_url=""
if [ -n "$(state_get WORKER_DOMAIN_ID)" ]; then
  custom_url="https://$WORKER_HOSTNAME"
fi

PASS=0
FAIL=0
pass() { echo "[PASS] $1"; PASS=$((PASS + 1)); }
fail() { echo "[FAIL] $1"; FAIL=$((FAIL + 1)); }

echo "== Cloudflare Workers Lab Tests =="

check_base() {
  local base="$1" label="$2"

  echo
  echo "-- $label ($base) --"

  code="$(curl -s -o /dev/null -m 10 -w '%{http_code}' "$base/health")"
  [ "$code" = "200" ] && pass "GET /health -> $code" || fail "GET /health -> $code (expected 200)"

  hello="$(curl -s -m 10 "$base/api/hello?name=Lab")"
  echo "$hello" | grep -q "Hello, Lab!" \
    && pass "GET /api/hello?name=Lab returned the right message" \
    || fail "GET /api/hello?name=Lab returned: $hello"

  whoami="$(curl -s -m 10 "$base/api/whoami")"
  colo="$(printf '%s' "$whoami" | jq -r '.colo // "unknown"')"
  if [ "$colo" != "unknown" ] && [ "$colo" != "null" ]; then
    pass "GET /api/whoami answered from data center '$colo'"
  else
    fail "GET /api/whoami did not report a data center: $whoami"
  fi

  code404="$(curl -s -o /dev/null -m 10 -w '%{http_code}' "$base/does-not-exist")"
  [ "$code404" = "404" ] && pass "unknown path -> 404" || fail "unknown path -> $code404 (expected 404)"
}

check_base "$worker_url" "workers.dev"

if [ -n "$custom_url" ]; then
  # DNS for a Custom Domain can take a few minutes to reach your own
  # resolver even after Cloudflare's edge is already serving it correctly
  # (its own resolvers, e.g. 1.1.1.1, are usually faster to update than
  # your ISP/OS resolver). Poll before judging it, the same way
  # ./05-route-domain.sh already does when it first attaches the domain.
  echo
  echo "-- waiting for $custom_url to resolve locally --"
  domain_up=0
  for i in $(seq 1 12); do
    code="$(curl -s -o /dev/null -m 5 -w '%{http_code}' "$custom_url/health" 2>/dev/null)"
    if [ "$code" = "200" ]; then
      domain_up=1
      break
    fi
    printf '\r  attempt %s/12 (got %s)...   ' "$i" "${code:-000}"
    sleep 5
  done
  echo

  if [ "$domain_up" = "1" ]; then
    check_base "$custom_url" "custom domain"
  else
    echo
    warn "$custom_url still isn't resolving from this machine after a minute of retries."
    warn "Cloudflare's own edge may already be serving it correctly — check with:"
    echo "    cf_ip=\$(curl -s -H 'accept: application/dns-json' \\"
    echo "      'https://1.1.1.1/dns-query?name=$WORKER_HOSTNAME&type=A' | jq -r '.Answer[0].data')"
    echo "    curl --resolve ${WORKER_HOSTNAME}:443:\$cf_ip https://$WORKER_HOSTNAME/health"
    warn "If that returns 200, this is purely local DNS caching: flush it"
    warn "(ipconfig /flushdns on Windows) or just wait — TTL is 300s, but"
    warn "ISP/OS resolvers sometimes cache the prior NXDOMAIN longer than that."
    fail "custom domain not reachable from this machine yet (see above — likely just propagation)"
  fi
fi

echo
echo "-- No cold start (lesson section 8) --"
echo "  Five requests reusing one curl connection (--next), so this times"
echo "  the Worker's own response, not a fresh DNS+TCP+TLS handshake each time:"
curl -s -o /dev/null -w '    request 1: %{time_total}s\n' "$worker_url/health" \
  --next -s -o /dev/null -w '    request 2: %{time_total}s\n' "$worker_url/health" \
  --next -s -o /dev/null -w '    request 3: %{time_total}s\n' "$worker_url/health" \
  --next -s -o /dev/null -w '    request 4: %{time_total}s\n' "$worker_url/health" \
  --next -s -o /dev/null -w '    request 5: %{time_total}s\n' "$worker_url/health"
echo "  Compare the first request to the rest — with a cold-start platform"
echo "  the first would be noticeably slower. Here they should look similar."
echo "  (An earlier version of this check ran five separate curl processes,"
echo "  which mostly measured network/TLS-handshake jitter per connection,"
echo "  not the Worker's own warmness — fixed to reuse one connection.)"

echo
echo "-- Rate limiting via KV (lesson section 12, pattern 3) --"
echo "  Firing 12 requests at /api/limited (limit is 10 per 60s per IP):"
tripped=0
for i in $(seq 1 12); do
  code="$(curl -s -o /dev/null -m 10 -w '%{http_code}' "$worker_url/api/limited")"
  echo "    request $i -> $code"
  [ "$code" = "429" ] && tripped=1
done

if [ "$tripped" = "1" ]; then
  pass "the rate limiter returned 429 before request 12"
else
  fail "12 requests never got a 429 — check RATE_LIMIT_KV is bound (see ./04-deploy-worker.sh)"
fi

echo
echo "== Results: $PASS passed, $FAIL failed =="

if [ -z "$custom_url" ]; then
  echo
  info "custom domain not attached yet — this only tested workers.dev."
  info "run ./05-route-domain.sh once the zone is active, then re-run this script."
fi

exit $([ "$FAIL" -eq 0 ] && echo 0 || echo 1)
