#!/bin/bash
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

BASE="http://localhost:8080"
PASS=0
FAIL=0

check_status() {
  local desc="$1" expected="$2" actual="$3"
  if [ "$actual" = "$expected" ]; then
    echo "[PASS] $desc (got $actual)"
    PASS=$((PASS + 1))
  elif [ "$actual" = "000" ]; then
    echo "[FAIL] $desc (no response — check the reverse-proxy container is running)"
    FAIL=$((FAIL + 1))
  else
    echo "[FAIL] $desc (expected $expected, got $actual)"
    FAIL=$((FAIL + 1))
  fi
}

check_contains() {
  local desc="$1" needle="$2" body="$3"
  if echo "$body" | grep -q "$needle"; then
    echo "[PASS] $desc"
    PASS=$((PASS + 1))
  else
    echo "[FAIL] $desc (response did not contain \"$needle\")"
    FAIL=$((FAIL + 1))
  fi
}

echo "== Nginx Reverse Proxy Tests =="
echo

# 1. Root landing page
code=$(curl -s -o /dev/null -w '%{http_code}' "$BASE/")
check_status "Root landing page" "200" "$code"

# 2. /app1/ routes to the app1 backend
body=$(curl -s "$BASE/app1/")
code=$(curl -s -o /dev/null -w '%{http_code}' "$BASE/app1/")
check_status "GET /app1/ status" "200" "$code"
check_contains "GET /app1/ served by app1 backend" "App 1" "$body"

# 3. /app2/ routes to the app2 backend
body=$(curl -s "$BASE/app2/")
code=$(curl -s -o /dev/null -w '%{http_code}' "$BASE/app2/")
check_status "GET /app2/ status" "200" "$code"
check_contains "GET /app2/ served by app2 backend" "App 2" "$body"

echo
echo "== Results: $PASS passed, $FAIL failed =="
echo

echo "== Last 5 access log entries (reverse-proxy) =="
docker compose exec -T reverse-proxy tail -n 5 /var/log/nginx/access.log 2>/dev/null || \
  echo "(could not read access log — is the container running?)"

exit $([ "$FAIL" -eq 0 ] && echo 0 || echo 1)
