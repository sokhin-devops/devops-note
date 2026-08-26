#!/bin/bash
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

PASS=0
FAIL=0

echo "== Firewall (UFW) Lab Tests =="
echo

echo "-- Active firewall rules on protected-server --"
docker exec protected-server ufw status verbose
echo

# 1. UFW must actually be active, not just configured
if docker exec protected-server ufw status | grep -q "Status: active"; then
  echo "[PASS] UFW is active on protected-server"
  PASS=$((PASS + 1))
else
  echo "[FAIL] UFW is not active on protected-server"
  FAIL=$((FAIL + 1))
fi

# 2. Trusted client (172.28.0.20) should be allowed through
code=$(docker exec client-trusted curl -s -o /dev/null -m 3 -w '%{http_code}' http://protected-server 2>/dev/null || echo "000")
if [ "$code" = "200" ]; then
  echo "[PASS] Trusted client allowed through firewall (got $code)"
  PASS=$((PASS + 1))
else
  echo "[FAIL] Trusted client should be allowed (got $code)"
  FAIL=$((FAIL + 1))
fi

# 3. Blocked client (172.28.0.30) should be silently dropped (times out)
if docker exec client-blocked curl -s -o /dev/null -m 3 http://protected-server 2>/dev/null; then
  echo "[FAIL] Blocked client should NOT reach protected-server, but it did"
  FAIL=$((FAIL + 1))
else
  echo "[PASS] Blocked client correctly denied by firewall (connection dropped/timed out)"
  PASS=$((PASS + 1))
fi

echo
echo "== Results: $PASS passed, $FAIL failed =="

exit $([ "$FAIL" -eq 0 ] && echo 0 || echo 1)
