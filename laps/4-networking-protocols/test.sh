#!/bin/bash
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

PASS=0
FAIL=0

pass() { echo "[PASS] $1"; PASS=$((PASS + 1)); }
fail() { echo "[FAIL] $1"; FAIL=$((FAIL + 1)); }

# Run a command inside the client container and trim stray carriage returns
c()    { docker exec client "$@" 2>/dev/null | tr -d '\r'; }
quiet() { docker exec client "$@" >/dev/null 2>&1; }

expect_eq() {
  local desc="$1" expected="$2" actual="$3"
  if [ "$actual" = "$expected" ]; then
    pass "$desc ($actual)"
  else
    fail "$desc (expected '$expected', got '${actual:-nothing}')"
  fi
}

expect_match() {
  local desc="$1" needle="$2" haystack="$3"
  if echo "$haystack" | grep -q "$needle"; then
    pass "$desc"
  else
    fail "$desc (no '$needle' in '${haystack:-nothing}')"
  fi
}

http_code() { c curl -s -o /dev/null -m 5 -w '%{http_code}' "$1"; }

echo "== Networking & Protocols Lab Tests =="
echo

# ---------------------------------------------------------------- addressing
echo "-- Addressing and routing --"
expect_eq "client holds its assigned IPv4 address" \
  "172.30.0.100" "$(c ip -4 -brief addr show eth0 | awk '{print $3}' | cut -d/ -f1)"

expect_match "default route points at the bridge gateway" \
  "default via 172.30.0.1" "$(c ip route)"

# ---------------------------------------------------------------------- ICMP
echo
echo "-- ICMP --"
if quiet ping -c 2 -W 2 web.lab.internal; then
  pass "ping reaches web.lab.internal"
else
  fail "ping could not reach web.lab.internal"
fi

if quiet ping -c 1 -W 2 172.30.0.199; then
  fail "an unused address in the subnet answered ping"
else
  pass "unused address 172.30.0.199 does not answer (as expected)"
fi

# ----------------------------------------------------------------------- DNS
echo
echo "-- DNS records --"
expect_eq "A record    web.lab.internal"  "172.30.0.10"        "$(c dig +short web.lab.internal A)"
expect_eq "A record    api.lab.internal"  "172.30.0.20"        "$(c dig +short api.lab.internal A)"
expect_eq "CNAME       www.lab.internal"  "web.lab.internal."  "$(c dig +short www.lab.internal CNAME)"
expect_eq "AAAA record ipv6.lab.internal" "2001:db8::10"       "$(c dig +short ipv6.lab.internal AAAA)"
expect_match "MX record   lab.internal"   "mail.lab.internal." "$(c dig +short lab.internal MX)"
expect_match "TXT record  lab.internal"   "networking-protocols" "$(c dig +short lab.internal TXT)"

expect_eq "the CNAME resolves through to the A record" \
  "172.30.0.10" "$(c dig +short www.lab.internal A | tail -1)"

expect_match "an unknown name returns NXDOMAIN" \
  "NXDOMAIN" "$(c dig nope.lab.internal)"

echo
echo "-- DNS transport --"
expect_eq "same query over UDP (the default)" \
  "172.30.0.10" "$(c dig +short +notcp web.lab.internal A)"
expect_eq "same query forced over TCP" \
  "172.30.0.10" "$(c dig +short +tcp web.lab.internal A)"

expect_match "plain container names still resolve via Docker's resolver" \
  "172.30.0.10" "$(c getent hosts web)"

# --------------------------------------------------------------------- ports
echo
echo "-- Ports --"
if quiet nc -z -w 3 web.lab.internal 80; then
  pass "TCP 80 on web is open"
else
  fail "TCP 80 on web should be open"
fi

if quiet nc -z -w 3 web.lab.internal 81; then
  fail "TCP 81 on web should be closed"
else
  pass "TCP 81 on web is closed (nothing listening)"
fi

if quiet nc -z -w 3 api.lab.internal 3000; then
  pass "TCP 3000 on api is open"
else
  fail "TCP 3000 on api should be open"
fi

if quiet nc -z -w 3 api.lab.internal 80; then
  fail "api should NOT be listening on 80"
else
  pass "api is not listening on 80 (a port is a service, not a machine)"
fi

# A name that resolves but has no service behind it
expect_eq "mail.lab.internal resolves" "172.30.0.25" "$(c dig +short mail.lab.internal A)"
if quiet nc -z -w 3 mail.lab.internal 25; then
  fail "nothing should be listening on mail.lab.internal:25"
else
  pass "mail.lab.internal resolves but nothing answers (DNS is not proof of a service)"
fi

listening=$(docker exec web netstat -tuln 2>/dev/null | tr -d '\r')
if [ -z "$listening" ]; then
  echo "[SKIP] the web image has no netstat — use 'nc -z' from the client instead"
else
  expect_match "web reports port 80 in its own listening sockets" ":80" "$listening"
fi

# ---------------------------------------------------------------------- HTTP
echo
echo "-- HTTP --"
expect_eq "GET http://web.lab.internal/"           "200" "$(http_code http://web.lab.internal/)"
expect_eq "GET http://web.lab.internal/whoami"     "200" "$(http_code http://web.lab.internal/whoami)"
expect_eq "GET http://web.lab.internal/status/404" "404" "$(http_code http://web.lab.internal/status/404)"
expect_eq "GET http://web.lab.internal/status/500" "500" "$(http_code http://web.lab.internal/status/500)"
expect_eq "GET http://web.lab.internal/redirect"   "301" "$(http_code http://web.lab.internal/redirect)"

location_header=$(c curl -s -I -m 5 http://web.lab.internal/redirect | grep -i "^location:")
if [ -n "$location_header" ]; then
  pass "the redirect carries a Location header ($location_header)"
else
  fail "the 301 response has no Location header"
fi

expect_match "api answers with JSON on port 3000" \
  '"service":"api"' "$(c curl -s -m 5 http://api.lab.internal:3000/health)"

expect_eq "reaching web by IP works too (no DNS involved)" \
  "200" "$(http_code http://172.30.0.10/)"

# ------------------------------------------------------ port mapping and NAT
echo
echo "-- Docker port mapping (from the host) --"
expect_match "web is published to host port 8080" ":8080" "$(docker port web | tr -d '\r')"
expect_match "api is published to host port 8081" ":8081" "$(docker port api | tr -d '\r')"

expect_eq "GET http://localhost:8080 from the host" \
  "200" "$(curl -s -o /dev/null -m 5 -w '%{http_code}' http://localhost:8080)"
expect_eq "GET http://localhost:8081 from the host" \
  "200" "$(curl -s -o /dev/null -m 5 -w '%{http_code}' http://localhost:8081)"

expect_match "the lab network uses the expected subnet" \
  "172.30.0.0/24" "$(docker network inspect netlab --format '{{json .IPAM.Config}}' | tr -d '\r')"

echo
echo "== Results: $PASS passed, $FAIL failed =="
echo

echo "== Last 8 DNS queries answered by CoreDNS =="
docker compose logs --tail 8 dns 2>/dev/null || echo "(could not read the dns logs)"

exit $([ "$FAIL" -eq 0 ] && echo 0 || echo 1)
