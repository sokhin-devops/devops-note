#!/bin/bash
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

BASE="http://localhost:8080"
PASS=0
FAIL=0

pass() { echo "[PASS] $1"; PASS=$((PASS + 1)); }
fail() { echo "[FAIL] $1"; FAIL=$((FAIL + 1)); }

# Send N requests to /whoami and print the backend name that answered each one
collect() {
  local n="$1"
  for _ in $(seq 1 "$n"); do
    curl -s -m 3 "$BASE/whoami" 2>/dev/null || echo "no-response"
  done
}

echo "== Nginx Load Balancer Tests =="
echo

# 1. The load balancer answers on its own health endpoint
code=$(curl -s -o /dev/null -m 3 -w '%{http_code}' "$BASE/lb-health")
[ "$code" = "200" ] && pass "Load balancer health endpoint (got $code)" \
                    || fail "Load balancer health endpoint (expected 200, got $code)"

# 2. A proxied request succeeds and reports which backend served it
headers=$(curl -s -m 3 -D - -o /dev/null "$BASE/whoami")
served_by=$(echo "$headers" | tr -d '\r' | awk -F': ' 'tolower($1)=="x-backend" {print $2}')
if [ -n "$served_by" ]; then
  pass "Response carries X-Backend header (served by $served_by)"
else
  fail "Response is missing the X-Backend header"
fi

# 3. Round robin: 9 requests should land 3 on each of the 3 backends
echo
echo "-- Distribution over 9 requests --"
counts=$(collect 9 | sort | uniq -c | sort -rn)
echo "$counts"
even=1
for name in backend1 backend2 backend3; do
  n=$(echo "$counts" | awk -v b="$name" '$2 == b {print $1}')
  [ "${n:-0}" -eq 3 ] || even=0
done
echo
if [ "$even" -eq 1 ]; then
  pass "Round robin spread 9 requests evenly (3 per backend)"
else
  fail "Round robin did not spread 9 requests evenly across the 3 backends"
fi

# 4. Failover: with backend2 stopped, traffic keeps flowing to the survivors
echo
echo "-- Stopping backend2 to test failover --"
docker compose stop backend2 >/dev/null 2>&1
sleep 1

results=$(collect 6)
if echo "$results" | grep -q "no-response"; then
  fail "Requests failed while backend2 was down (load balancer did not fail over)"
else
  pass "All 6 requests still succeeded with backend2 down"
fi

if echo "$results" | grep -q "^backend2$"; then
  fail "backend2 still served traffic after being stopped"
else
  pass "No traffic was sent to the stopped backend2"
fi

echo "-- Backends that answered while backend2 was down --"
echo "$results" | sort | uniq -c
echo

# 5. Recovery: bring backend2 back and confirm it rejoins the pool.
#    The load balancer is restarted so it re-resolves the backend DNS names.
echo "-- Restarting backend2 and reloading the pool --"
docker compose start backend2 >/dev/null 2>&1
docker compose restart load-balancer >/dev/null 2>&1
for i in $(seq 1 20); do
  [ "$(curl -s -o /dev/null -m 2 -w '%{http_code}' "$BASE/whoami" 2>/dev/null)" = "200" ] && break
  sleep 1
done

if collect 9 | grep -q "^backend2$"; then
  pass "backend2 rejoined the pool after recovery"
else
  fail "backend2 did not rejoin the pool after recovery"
fi

echo
echo "== Results: $PASS passed, $FAIL failed =="
echo

echo "== Last 5 access log entries (load-balancer) =="
docker compose exec -T load-balancer tail -n 5 /var/log/nginx/access.log 2>/dev/null || \
  echo "(could not read access log — is the container running?)"

exit $([ "$FAIL" -eq 0 ] && echo 0 || echo 1)
