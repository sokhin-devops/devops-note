#!/bin/bash
# Checks the deployment: HTTP, the firewall's allow/drop behavior (same
# refused-vs-timeout distinction as the Vultr lab), and what Terraform's
# own state says exists.
set -uo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
require_terraform
cd "$LAB_DIR"

env_name="${1:-dev}"
PASS=0
FAIL=0
pass() { echo "[PASS] $1"; PASS=$((PASS + 1)); }
fail() { echo "[FAIL] $1"; FAIL=$((FAIL + 1)); }

ip="$(terraform output -raw instance_ip 2>/dev/null)"
[ -n "$ip" ] || die "no instance_ip output — run ./03-apply.sh $env_name first"

probe_port() {
  local host="$1" port="$2" rc
  timeout 6 bash -c "exec 3<>/dev/tcp/$host/$port" >/dev/null 2>&1
  rc=$?
  if [ "$rc" -eq 0 ]; then echo "open"
  elif [ "$rc" -eq 124 ]; then echo "timeout"
  else echo "refused"; fi
}

echo "== Terraform + Vultr Lab Tests ($ip) =="

echo
echo "-- The application (proves Terraform variables reached the VM) --"
body="$(curl -s -m 10 "http://$ip/")"
code="$(curl -s -o /dev/null -m 10 -w '%{http_code}' "http://$ip/")"
[ "$code" = "200" ] && pass "GET http://$ip/ -> $code" || fail "GET http://$ip/ -> $code"

label_expected="$(grep -E '^\s*label\s*=' "environments/$env_name.tfvars" | head -1 | sed -E 's/.*"([^"]+)".*/\1/')"
echo "$body" | grep -q "$label_expected" \
  && pass "page shows label '$label_expected' from environments/$env_name.tfvars" \
  || fail "page did not contain '$label_expected' — got: $(echo "$body" | tr -d '\n' | head -c 120)"

echo "$body" | grep -q "environment: $env_name" \
  && pass "page shows environment: $env_name" \
  || fail "page did not show environment: $env_name"

echo
echo "-- Firewall, from the internet --"
p22="$(probe_port "$ip" 22)";  [ "$p22" = "open" ]  && pass "22/tcp  SSH  open"  || fail "22/tcp  SSH  $p22"
p80="$(probe_port "$ip" 80)";  [ "$p80" = "open" ]  && pass "80/tcp  HTTP open"  || fail "80/tcp  HTTP $p80"
p5432="$(probe_port "$ip" 5432)"
[ "$p5432" = "timeout" ] && pass "5432/tcp dropped by the firewall" || fail "5432/tcp answered '$p5432' — should be dropped"

echo
echo "-- What Terraform's state actually says exists --"
terraform state list | sed 's/^/  /'

echo
echo "== Results: $PASS passed, $FAIL failed =="
echo
info "compare this against the Vultr lab's 06-verify.sh (../5-cloud-providers) —"
info "same checks, but every id it needed came from 'terraform output'"
info "instead of a hand-maintained state/lab.env file."

exit $([ "$FAIL" -eq 0 ] && echo 0 || echo 1)
