#!/bin/bash
# The lesson's section 12: dynamic, auto-rotating database credentials,
# proven against a real Postgres — not just "the API returned a response
# that looked right."
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
require_docker
load_env
cd "$LAB_DIR"

step "1. A demo table and a template 'readonly' role in Postgres"
pctl -v ON_ERROR_STOP=1 <<'SQL'
CREATE TABLE IF NOT EXISTS notes (id serial primary key, body text);
INSERT INTO notes (body) SELECT 'hello from the lab' WHERE NOT EXISTS (SELECT 1 FROM notes);
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'readonly') THEN
    CREATE ROLE readonly NOLOGIN;
  END IF;
END $$;
GRANT USAGE ON SCHEMA public TO readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO readonly;
SQL
ok "table + group role ready"

step "2. Enabling Vault's database secrets engine"
ctl labroot vault secrets list -format=json | grep -q '"database/"' \
  && info "already enabled" \
  || { ctl labroot vault secrets enable database; ok "enabled"; }

step "3. Pointing it at Postgres — same idea as the lesson's connection_url"
ctl labroot vault write database/config/postgresql \
  plugin_name=postgresql-database-plugin \
  allowed_roles="readonly" \
  connection_url="postgresql://{{username}}:{{password}}@postgres:5432/appdb?sslmode=disable" \
  username="vaultadmin" \
  password="$POSTGRES_ADMIN_PASSWORD"
ok "configured (note: ?sslmode=disable — this Postgres has no TLS cert, and"
echo "  the Go driver Vault uses, unlike psql, does not fall back on its own)"

step "4. The readonly role — a template for credentials Vault will mint on demand"
ctl labroot vault write database/roles/readonly \
  db_name=postgresql \
  creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' IN ROLE readonly;" \
  default_ttl="1h" \
  max_ttl="24h"
ok "role template written"

step "5. Minting credentials — twice, to prove they're generated, not fixed"
creds1_json="$(ctl labroot vault read -format=json database/creds/readonly)"
creds2_json="$(ctl labroot vault read -format=json database/creds/readonly)"

user1="$(echo "$creds1_json" | jq -r '.data.username')"
pass1="$(echo "$creds1_json" | jq -r '.data.password')"
lease1="$(echo "$creds1_json" | jq -r '.lease_id')"
user2="$(echo "$creds2_json" | jq -r '.data.username')"
pass2="$(echo "$creds2_json" | jq -r '.data.password')"

echo "  first  read: $user1"
echo "  second read: $user2"
if [ "$user1" != "$user2" ]; then
  ok "two reads of the same role produced two different usernames"
else
  warn "both reads produced the same username — that shouldn't happen"
fi

step "6. Proving the first credential is real, working, and actually read-only"
info "connecting as $user1 and reading the demo table:"
pctl_as "$user1" "$pass1" -c "select * from notes;"

info "attempting a write — this must fail:"
write_output="$(pctl_as "$user1" "$pass1" -c "insert into notes(body) values('should be rejected');" 2>&1 || true)"
echo "$write_output" | sed 's/^/  /'
if echo "$write_output" | grep -qi "permission denied"; then
  ok "write correctly rejected: permission denied"
else
  warn "the write did not fail the way it was expected to — see the output above"
fi

step "7. Revoking the first lease — proving the credential is actually temporary"
ctl labroot vault lease revoke "$lease1"
ok "lease revoked"

info "the same login should fail now:"
if pctl_as "$user1" "$pass1" -c "select 1;" 2>&1 | grep -qiE "password authentication failed|does not exist"; then
  ok "revoked credential no longer works"
else
  warn "the revoked credential still appears to work — investigate before trusting this pattern"
fi

step "8. What Postgres itself thinks exists right now"
pctl -c "\du" | sed 's/^/  /'

cat <<NEXT

  $user2's credential (from the second read) is still live — it will
  expire on its own after the 1h default_ttl, or revoke it by hand:
    docker compose exec client sh -c "VAULT_ADDR=http://vault:8200 VAULT_TOKEN=labroot vault lease revoke <lease_id>"

  Next:
    ./03-policies.sh
NEXT
