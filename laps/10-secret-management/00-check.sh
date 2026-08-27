#!/bin/bash
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
require_docker
cd "$LAB_DIR"

step "1. .env"
if [ -f .env ]; then
  ok ".env already exists — reusing it"
else
  cp .env.example .env
  # A fresh random bootstrap password, not the placeholder from .env.example
  pw="$(head -c 24 /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c 24)"
  sed -i "s/^POSTGRES_ADMIN_PASSWORD=.*/POSTGRES_ADMIN_PASSWORD=$pw/" .env
  ok "created .env with a random POSTGRES_ADMIN_PASSWORD"
fi
load_env

step "2. Starting Vault, Postgres, and the client toolbox"
docker compose up -d --build vault postgres client

step "3. Waiting for Vault (dev mode auto-unseals, but still takes a moment)"
for i in $(seq 1 20); do
  if docker compose exec -T -e VAULT_ADDR=http://vault:8200 client vault status >/dev/null 2>&1; then
    ok "vault is up"
    break
  fi
  printf '\r  attempt %s/20...   ' "$i"
  sleep 2
done
echo
ctl labroot vault status | sed 's/^/  /'

step "4. Waiting for Postgres"
for i in $(seq 1 20); do
  docker compose exec -T postgres pg_isready -U vaultadmin -d appdb >/dev/null 2>&1 && break
  sleep 2
done
ok "postgres is up"

cat <<NEXT

  Vault dev root token: labroot
  Vault UI (from your browser): http://localhost:8200/ui  (token: labroot)

  Next:
    ./01-kv-secrets.sh
NEXT
