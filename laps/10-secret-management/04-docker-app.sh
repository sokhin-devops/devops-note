#!/bin/bash
# The lesson's section 17 (Docker + Vault) — a container that fetches its
# own secret at startup, run for real. Only makes sense once
# kv/blog/database actually exists.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
require_docker
load_env
cd "$LAB_DIR"

if ! ctl labroot vault kv get -field=username kv/blog/database >/dev/null 2>&1; then
  die "kv/blog/database doesn't exist yet — run ./01-kv-secrets.sh first"
fi

step "Starting the app container"
docker compose up -d --build app

step "Its own startup log — watch it fetch the secret and connect"
sleep 3
docker compose logs app | sed 's/^/  /'

cat <<NEXT

  Re-run this any time to see the same fetch-then-connect sequence again:
    docker compose restart app && docker compose logs -f app

  Next:
    ./05-verify.sh
NEXT
