#!/bin/bash
set -uo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
require_docker
cd "$LAB_DIR"

PASS=0
FAIL=0
pass() { echo "[PASS] $1"; PASS=$((PASS + 1)); }
fail() { echo "[FAIL] $1"; FAIL=$((FAIL + 1)); }

echo "== Ansible Configuration Management Lab Tests =="

echo
echo "-- systemd actually running (not a single-process container) --"
for h in web1 web2 db1; do
  state="$(docker compose exec -T "$h" systemctl is-system-running 2>/dev/null || true)"
  case "$state" in
    running|degraded) pass "$h: systemctl is-system-running -> $state" ;;
    *) fail "$h: systemctl is-system-running -> '${state:-no answer}'" ;;
  esac
done

echo
echo "-- nginx, managed by the systemd 'service' module, on both webservers --"
for h in web1 web2; do
  code="$(docker compose exec -T "$h" curl -s -o /dev/null -m 5 -w '%{http_code}' http://localhost/nginx-health 2>/dev/null)"
  [ "$code" = "200" ] && pass "$h: /nginx-health -> $code" || fail "$h: /nginx-health -> ${code:-no answer}"
done

echo
echo "-- host_vars actually reached each host (not just group_vars) --"
web1_body="$(docker compose exec -T web1 curl -s -m 5 http://localhost/ 2>/dev/null)"
web2_body="$(docker compose exec -T web2 curl -s -m 5 http://localhost/ 2>/dev/null)"

echo "$web1_body" | grep -q "deploy_env: dev" \
  && pass "web1 rendered its own host_vars (deploy_env: dev)" \
  || fail "web1's page did not show deploy_env: dev"

echo "$web2_body" | grep -q "deploy_env: staging" \
  && pass "web2 rendered its own host_vars (deploy_env: staging)" \
  || fail "web2's page did not show deploy_env: staging"

if [ "$web1_body" != "$web2_body" ]; then
  pass "web1 and web2 rendered genuinely different pages from the same template"
else
  fail "web1 and web2 rendered identical pages — host_vars isn't differentiating them"
fi

echo
echo "-- the vault secret made it into the rendered page --"
echo "$web1_body" | grep -q "decrypted from an ansible-vault file" \
  && pass "vault_greeting was decrypted and rendered" \
  || fail "vault_greeting did not appear in web1's page"

echo
echo "-- databases group got 'common' only, not the web stack --"
db_nginx="$(docker compose exec -T db1 which nginx 2>/dev/null || true)"
if [ -z "$db_nginx" ]; then
  pass "db1 has no nginx installed — the group split in playbooks/site.yml worked"
else
  fail "db1 has nginx installed — it should have been skipped by hosts: webservers"
fi

echo
echo "== Results: $PASS passed, $FAIL failed =="

exit $([ "$FAIL" -eq 0 ] && echo 0 || echo 1)
