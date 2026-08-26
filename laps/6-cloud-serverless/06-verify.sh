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
[ -n "$custom_url" ] && check_base "$custom_url" "custom domain"

echo
echo "-- No cold start (lesson section 8) --"
echo "  Five sequential requests to the same endpoint, timed:"
for i in 1 2 3 4 5; do
  t="$(curl -s -o /dev/null -m 10 -w '%{time_total}' "$worker_url/health")"
  echo "    request $i: ${t}s"
done
echo "  Compare the first request to the rest — with a cold-start platform"
echo "  the first would be noticeably slower. Here they should look similar."

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
