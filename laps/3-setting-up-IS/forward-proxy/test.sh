#!/bin/bash
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

PROXY="http://localhost:3128"
PASS=0
FAIL=0

check() {
  local desc="$1"
  local expected="$2"
  local actual="$3"
  if [ "$actual" = "$expected" ]; then
    echo "[PASS] $desc (got $actual)"
    PASS=$((PASS + 1))
  elif [ "$actual" = "000" ]; then
    echo "[FAIL] $desc (no response — check the squid container is running and this host has outbound internet access)"
    FAIL=$((FAIL + 1))
  else
    echo "[FAIL] $desc (expected $expected, got $actual)"
    FAIL=$((FAIL + 1))
  fi
}

echo "== Squid Forward Proxy Tests =="
echo

# 1. HTTP request through the proxy should succeed
code=$(curl -s -o /dev/null -w '%{http_code}' -x "$PROXY" http://example.com)
check "HTTP request via proxy" "200" "$code"

# 2. HTTPS request through the proxy (CONNECT tunnel) should succeed
code=$(curl -s -o /dev/null -w '%{http_code}' -x "$PROXY" https://example.com)
check "HTTPS request via proxy (CONNECT)" "200" "$code"

# 3. Request to a non-safe port should be denied by ACL
code=$(curl -s -o /dev/null -w '%{http_code}' -x "$PROXY" http://example.com:8080)
check "Blocked port denied by ACL" "403" "$code"

echo
echo "== Results: $PASS passed, $FAIL failed =="
echo

echo "== Last 5 access log entries =="
docker compose exec -T squid tail -n 5 /var/log/squid/access.log 2>/dev/null || \
  echo "(could not read access log — is the container running?)"

exit $([ "$FAIL" -eq 0 ] && echo 0 || echo 1)
