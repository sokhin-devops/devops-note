#!/bin/bash
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

BASE="http://localhost:8080"
PASS=0
FAIL=0

pass() { echo "[PASS] $1"; PASS=$((PASS + 1)); }
fail() { echo "[FAIL] $1"; FAIL=$((FAIL + 1)); }

# One request, headers and body together, so nothing is counted twice
fetch() { curl -s -m 15 -D - "$BASE$1"; }

# Pull a numeric field out of the JSON body
field() { echo "$1" | sed -n 's/.*"'"$2"'": *\([0-9.-]*\).*/\1/p' | head -1; }

# Pull the X-Cache response header
cache_header() {
  echo "$1" | tr -d '\r' | awk 'tolower($1) == "x-cache:" { print $2 }' | head -1
}

# Compare two floats: less_than A B
less_than() { awk -v a="$1" -v b="$2" 'BEGIN { exit !(a < b) }'; }

echo "== Redis Cache Lab Tests =="
echo

# 1. The API is up and can talk to Redis
health=$(curl -s -m 5 "$BASE/health")
if echo "$health" | grep -q '"redis": *"ok"'; then
  pass "API is healthy and connected to Redis"
else
  fail "API health check failed (got: $health)"
  echo
  echo "== Results: $PASS passed, $FAIL failed =="
  exit 1
fi

# Start from a known state: empty cache, zeroed counters
curl -s -m 5 -X DELETE "$BASE/cache" >/dev/null
curl -s -m 5 -X DELETE "$BASE/stats" >/dev/null

# 2. First request must be a MISS served by the slow database
first=$(fetch "/product/1")
first_status=$(cache_header "$first")
first_ms=$(field "$first" elapsed_ms)
if [ "$first_status" = "MISS" ]; then
  pass "First request is a cache MISS (${first_ms} ms, from the database)"
else
  fail "First request should be a MISS (got '${first_status:-none}')"
fi

# 3. Second request for the same product must be a HIT served by Redis
second=$(fetch "/product/1")
second_status=$(cache_header "$second")
second_ms=$(field "$second" elapsed_ms)
if [ "$second_status" = "HIT" ]; then
  pass "Second request is a cache HIT (${second_ms} ms, from Redis)"
else
  fail "Second request should be a HIT (got '${second_status:-none}')"
fi

# 4. The HIT has to be dramatically faster, or the cache is not earning its keep
if less_than "$second_ms" "$(awk -v m="$first_ms" 'BEGIN { print m / 4 }')"; then
  speedup=$(awk -v a="$first_ms" -v b="$second_ms" 'BEGIN { printf "%.0f", a / (b > 0 ? b : 0.1) }')
  pass "Cached response is ${speedup}x faster (${first_ms} ms -> ${second_ms} ms)"
else
  fail "Cached response was not meaningfully faster (${first_ms} ms -> ${second_ms} ms)"
fi

# 5. The cached key must carry a TTL so it expires on its own
ttl=$(docker compose exec -T redis redis-cli TTL product:1 2>/dev/null | tr -d '\r')
if [ "${ttl:-0}" -gt 0 ] 2>/dev/null; then
  pass "Cached key product:1 expires on its own (TTL ${ttl}s)"
else
  fail "Cached key product:1 has no TTL (got '${ttl:-none}')"
fi

# 6. A different product is its own cache entry, so it misses
third=$(fetch "/product/2")
if [ "$(cache_header "$third")" = "MISS" ]; then
  pass "A different product is a separate key and misses"
else
  fail "Product 2 should miss on its first request"
fi

# 7. Counters: 1 hit and 2 misses since the reset above
stats=$(curl -s -m 5 "$BASE/stats")
hits=$(field "$stats" hits)
misses=$(field "$stats" misses)
if [ "$hits" = "1" ] && [ "$misses" = "2" ]; then
  pass "Stats report 1 hit / 2 misses as expected"
else
  fail "Stats should report 1 hit / 2 misses (got $hits / $misses)"
fi

# 8. Flushing the cache sends the next request back to the database
curl -s -m 5 -X DELETE "$BASE/cache" >/dev/null
after_flush=$(fetch "/product/1")
if [ "$(cache_header "$after_flush")" = "MISS" ]; then
  pass "After flushing the cache the request misses again"
else
  fail "Request after a cache flush should be a MISS"
fi

echo
echo "== Results: $PASS passed, $FAIL failed =="
echo

echo "== Cache contents in Redis =="
docker compose exec -T redis redis-cli KEYS 'product:*' 2>/dev/null || \
  echo "(could not reach redis — is the container running?)"
echo
echo "== Redis keyspace hit/miss counters =="
docker compose exec -T redis redis-cli INFO stats 2>/dev/null | \
  grep -E 'keyspace_(hits|misses)' | tr -d '\r' || true

exit $([ "$FAIL" -eq 0 ] && echo 0 || echo 1)
