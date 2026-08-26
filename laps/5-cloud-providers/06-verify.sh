#!/bin/bash
# Checks the deployment from the outside, the way the internet sees it.
set -uo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib/vultr.sh"
load_env

# This script runs without `set -e`, so check the state explicitly rather than
# relying on state_require's exit (which would only kill the subshell).
ip="$(state_get INSTANCE_IP)"
[ -n "$ip" ] || die "INSTANCE_IP is not in state — run ./04-status.sh first"

PASS=0
FAIL=0
pass() { echo "[PASS] $1"; PASS=$((PASS + 1)); }
fail() { echo "[FAIL] $1"; FAIL=$((FAIL + 1)); }

# open | refused | timeout — the difference matters, see the notes below
probe_port() {
  local host="$1" port="$2" rc
  timeout 6 bash -c "exec 3<>/dev/tcp/$host/$port" >/dev/null 2>&1
  rc=$?
  if [ "$rc" -eq 0 ]; then echo "open"
  elif [ "$rc" -eq 124 ]; then echo "timeout"
  else echo "refused"; fi
}

echo "== Vultr Cloud Lab Tests ($ip) =="
echo

echo "-- The application --"
code="$(curl -s -o /dev/null -m 10 -w '%{http_code}' "http://$ip/")"
[ "$code" = "200" ] && pass "GET http://$ip/ (got $code)" || fail "GET http://$ip/ (expected 200, got $code)"

health="$(curl -s -m 10 "http://$ip/health")"
[ "$health" = "ok" ] && pass "health endpoint answers 'ok'" || fail "health endpoint returned '${health:-nothing}'"

body="$(curl -s -m 10 "http://$ip/")"
echo "$body" | grep -q "$ip" \
  && pass "the deployed page was stamped with the real public IP" \
  || fail "the page still has its placeholders — did 05-deploy.sh finish?"

echo
echo "-- Ports, from the internet (lesson 18-19) --"
p22="$(probe_port "$ip" 22)"
[ "$p22" = "open" ] && pass "22/tcp  SSH   open" || fail "22/tcp  SSH   $p22 (expected open)"

p80="$(probe_port "$ip" 80)"
[ "$p80" = "open" ] && pass "80/tcp  HTTP  open" || fail "80/tcp  HTTP  $p80 (expected open)"

p443="$(probe_port "$ip" 443)"
if [ "$p443" = "refused" ]; then
  pass "443/tcp HTTPS allowed by the firewall, but refused — nothing is listening yet"
elif [ "$p443" = "open" ]; then
  pass "443/tcp HTTPS open (you have already put something on it)"
else
  fail "443/tcp HTTPS timed out — the firewall rule for 443 is missing"
fi

p5432="$(probe_port "$ip" 5432)"
if [ "$p5432" = "timeout" ]; then
  pass "5432/tcp PostgreSQL dropped by the cloud firewall (no reply at all)"
else
  fail "5432/tcp PostgreSQL answered '$p5432' — it should be dropped"
fi

p6379="$(probe_port "$ip" 6379)"
if [ "$p6379" = "timeout" ]; then
  pass "6379/tcp Redis dropped by the cloud firewall"
else
  fail "6379/tcp Redis answered '$p6379' — it should be dropped"
fi

echo
echo "-- Inside the VM --"
if lab_ssh "$ip" "ufw status | grep -q '^Status: active'" 2>/dev/null; then
  pass "UFW is active inside the OS (the second layer)"
else
  fail "UFW is not active inside the OS"
fi

if lab_ssh "$ip" "docker ps --filter name=lab-web --filter status=running -q | grep -q ." 2>/dev/null; then
  pass "the lab-web container is running"
else
  fail "the lab-web container is not running"
fi

echo
echo "-- The cloud firewall, according to the API --"
fw="$(state_get FIREWALL_GROUP_ID)"
if [ -n "$fw" ]; then
  api GET "/firewalls/$fw/rules" | jq -r \
    '.firewall_rules[] | "  \(.protocol)/\(.port)\tfrom \(.subnet)/\(.subnet_size)\t\(.notes)"'
fi

echo
echo "== Results: $PASS passed, $FAIL failed =="
cat <<NOTE

  Note the difference between the two kinds of failure above:

    refused  the packet reached the VM and nothing was listening
    timeout  the packet was dropped before the VM ever saw it

  443 is refused because the firewall lets it through and no service answers.
  5432 times out because Vultr drops it at the edge. Same "it does not work",
  two completely different causes — and telling them apart is most of
  network troubleshooting.

  Remember: the VM keeps billing until you run ./99-destroy.sh
NOTE

exit $([ "$FAIL" -eq 0 ] && echo 0 || echo 1)
