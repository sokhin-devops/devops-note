#!/bin/bash
# The lesson's section 11 (KV v2) run for real, against a path named the
# way the lesson's own "Complete Example" (section 21) names it:
# kv/blog/database.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
require_docker
load_env
cd "$LAB_DIR"

step "1. Enabling the KV v2 secrets engine at kv/"
if ctl labroot vault secrets list -format=json 2>/dev/null | grep -q '"kv/"'; then
  info "kv/ is already enabled"
else
  ctl labroot vault secrets enable -path=kv -version=2 kv
  ok "enabled"
fi

step "2. Storing the database credentials the app container will fetch"
ctl labroot vault kv put kv/blog/database \
  username="vaultadmin" \
  password="$POSTGRES_ADMIN_PASSWORD"
ok "wrote kv/blog/database"

step "3. Reading it back"
ctl labroot vault kv get kv/blog/database

step "4. A second version, to show KV v2 keeps history"
ctl labroot vault kv put kv/blog/database \
  username="vaultadmin" \
  password="$POSTGRES_ADMIN_PASSWORD" \
  rotated_at="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo
info "version 1 (no rotated_at field yet):"
ctl labroot vault kv get -version=1 kv/blog/database
echo
info "version 2 (current):"
ctl labroot vault kv get kv/blog/database

step "5. Other secrets from the lesson's Complete Example (section 21)"
ctl labroot vault kv put kv/blog/api \
  github_token="ghp_lab_placeholder_not_real" \
  sendgrid_api_key="SG.lab_placeholder_not_real"
ok "wrote kv/blog/api"

step "6. Listing what exists under kv/blog/"
ctl labroot vault kv list kv/blog/

step "7. Delete and undelete (soft delete — the lesson's exact commands)"
ctl labroot vault kv delete kv/blog/api
echo
warn "gone from a plain 'get':"
ctl labroot vault kv get kv/blog/api || true
echo
ctl labroot vault kv undelete kv/blog/api -versions=1
ok "restored:"
ctl labroot vault kv get kv/blog/api

cat <<NEXT

  Next:
    ./02-dynamic-db-secrets.sh
NEXT
