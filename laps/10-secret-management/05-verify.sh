#!/bin/bash
set -uo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
require_docker
load_env
cd "$LAB_DIR"

PASS=0
FAIL=0
pass() { echo "[PASS] $1"; PASS=$((PASS + 1)); }
fail() { echo "[FAIL] $1"; FAIL=$((FAIL + 1)); }

echo "== Secret Management (Vault) Lab Tests =="

echo
echo "-- Vault itself --"
if ctl labroot vault status >/dev/null 2>&1; then
  pass "vault status succeeds"
else
  fail "vault status failed — is ./00-check.sh done?"
fi

echo
echo "-- KV v2 (section 11) --"
kv_user="$(ctl labroot vault kv get -field=username kv/blog/database 2>/dev/null)"
if [ "$kv_user" = "vaultadmin" ]; then
  pass "kv/blog/database round-trips the expected username"
else
  fail "kv/blog/database returned '${kv_user:-nothing}', expected 'vaultadmin'"
fi

versions="$(ctl labroot vault kv metadata get -field=current_version kv/blog/database 2>/dev/null)"
if [ "${versions:-0}" -ge 2 ] 2>/dev/null; then
  pass "kv/blog/database has $versions versions — versioning is real, not cosmetic"
else
  fail "expected at least 2 versions of kv/blog/database, found '${versions:-none}'"
fi

echo
echo "-- Dynamic database secrets (section 12) --"
c1="$(ctl labroot vault read -format=json database/creds/readonly 2>/dev/null)"
c2="$(ctl labroot vault read -format=json database/creds/readonly 2>/dev/null)"
u1="$(echo "$c1" | jq -r '.data.username // empty')"
p1="$(echo "$c1" | jq -r '.data.password // empty')"
u2="$(echo "$c2" | jq -r '.data.username // empty')"
lease1="$(echo "$c1" | jq -r '.lease_id // empty')"
lease2="$(echo "$c2" | jq -r '.lease_id // empty')"

if [ -n "$u1" ] && [ "$u1" != "$u2" ]; then
  pass "two reads of database/creds/readonly minted two different usernames"
else
  fail "database/creds/readonly did not mint distinct credentials (got '$u1' / '$u2')"
fi

if [ -n "$u1" ] && pctl_as "$u1" "$p1" -c "select 1;" >/dev/null 2>&1; then
  pass "a freshly minted credential can actually log in to Postgres"
else
  fail "could not log in to Postgres with a freshly minted credential"
fi

write_result="$(pctl_as "$u1" "$p1" -c "insert into notes(body) values('verify-test');" 2>&1)"
if echo "$write_result" | grep -qi "permission denied"; then
  pass "the dynamically minted role is genuinely read-only"
else
  fail "the dynamically minted role could write — it should be read-only"
fi

# Clean up the two leases this test run minted, so repeated ./05-verify.sh
# runs don't accumulate roles in Postgres.
[ -n "$lease1" ] && ctl labroot vault lease revoke "$lease1" >/dev/null 2>&1
[ -n "$lease2" ] && ctl labroot vault lease revoke "$lease2" >/dev/null 2>&1

echo
echo "-- Policies (section 13) --"
scoped_token="$(ctl labroot vault token create -policy=app-policy -format=json -ttl=5m 2>/dev/null | jq -r '.auth.client_token // empty')"
if [ -n "$scoped_token" ]; then
  if ctl "$scoped_token" vault kv get kv/blog/database >/dev/null 2>&1; then
    pass "app-policy token can read its one allowed path"
  else
    fail "app-policy token could not read kv/blog/database — it should be allowed to"
  fi

  if ctl "$scoped_token" vault kv put kv/blog/other foo=bar 2>&1 | grep -qi "permission denied"; then
    pass "app-policy token is denied writing to a different path"
  else
    fail "app-policy token was NOT denied a write it shouldn't be able to do"
  fi

  if ctl "$scoped_token" vault read database/creds/readonly 2>&1 | grep -qi "permission denied"; then
    pass "app-policy token is denied minting database credentials"
  else
    fail "app-policy token was NOT denied database access it shouldn't have"
  fi

  ctl labroot vault token revoke "$scoped_token" >/dev/null 2>&1
else
  fail "could not mint an app-policy token — run ./03-policies.sh first"
fi

echo
echo "-- Docker + Vault integration (section 17) --"
if docker compose ps app 2>/dev/null | grep -q "Up\|running"; then
  app_log="$(docker compose logs app 2>&1)"
  if echo "$app_log" | grep -q "fetched credentials from Vault"; then
    pass "the app container's own log shows it fetched its secret from Vault"
  else
    fail "app container is running but its log doesn't show the expected fetch line"
  fi
  if echo "$app_log" | grep -q "current_user"; then
    pass "the app container connected to Postgres using the fetched credential"
  else
    fail "app container's log doesn't show a successful Postgres connection"
  fi
else
  fail "app container is not running — run ./04-docker-app.sh first"
fi

echo
echo "== Results: $PASS passed, $FAIL failed =="

exit $([ "$FAIL" -eq 0 ] && echo 0 || echo 1)
