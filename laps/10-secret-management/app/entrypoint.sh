#!/bin/bash
# The lesson's docker-entrypoint.sh pattern (D10.secret-management.md,
# section 17): fetch secrets from Vault at container start, then use them.
#
# Simplified on purpose: this uses the same VAULT_TOKEN the rest of the lab
# uses (the dev-mode root token), not a scoped token. A real deployment
# should never boot a container with root — see ./03-policies.sh for where
# this lab actually demonstrates a least-privilege, read-only token. This
# container exists to show the *shape* of "fetch secret, then connect",
# and keeping the bootstrap simple is what makes that shape visible.
set -e

echo "[app] waiting for the kv/blog/database secret to exist in Vault..."
for i in $(seq 1 30); do
  if vault kv get -field=username kv/blog/database >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

DB_USER="$(vault kv get -field=username kv/blog/database)"
DB_PASSWORD="$(vault kv get -field=password kv/blog/database)"

if [ -z "$DB_USER" ]; then
  echo "[app] kv/blog/database still doesn't exist — run ./01-kv-secrets.sh first" >&2
  exit 1
fi

echo "[app] fetched credentials from Vault for db user: $DB_USER"

export PGPASSWORD="$DB_PASSWORD"
echo "[app] waiting for postgres..."
for i in $(seq 1 30); do
  pg_isready -h postgres -U "$DB_USER" -d appdb >/dev/null 2>&1 && break
  sleep 2
done

echo "[app] connecting as the user named in the Vault secret (not hardcoded):"
psql -h postgres -U "$DB_USER" -d appdb -c "select current_user, now();"

echo "[app] up. Nothing else to do — this container exists to prove the fetch worked."
exec sleep infinity
