#!/bin/bash
# The lesson's section 13 (policies) proven the way access control should
# always be proven: not by reading the policy file, but by watching an
# app-scoped token succeed at what it's allowed and get denied everything
# else.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
require_docker
load_env
cd "$LAB_DIR"

step "1. Writing an app policy — read-only on kv/blog/*, nothing else"
cat policies/app-policy.hcl
ctl labroot vault policy write app-policy - < policies/app-policy.hcl
ok "policy written"

step "2. Minting a token that carries only this policy"
token_json="$(ctl labroot vault token create -policy=app-policy -format=json -ttl=15m)"
app_token="$(echo "$token_json" | jq -r '.auth.client_token')"
echo "  app_token = $app_token  (a real, working token — not root)"

step "3. What this token IS allowed to do"
info "read kv/blog/database:"
ctl "$app_token" vault kv get kv/blog/database

step "4. What this token is NOT allowed to do"
info "write a new secret at kv/blog/other (should be denied):"
if ctl "$app_token" vault kv put kv/blog/other foo=bar 2>&1 | tee /dev/stderr | grep -qi "permission denied"; then
  ok "correctly denied — app-policy only grants 'read'"
else
  warn "that write did not get denied — check policies/app-policy.hcl"
fi

echo
info "read a completely different path, kv/blog/api (should also be denied —"
info "the policy names kv/blog/database specifically, not all of kv/blog/*):"
if ctl "$app_token" vault kv get kv/blog/api 2>&1 | tee /dev/stderr | grep -qi "permission denied"; then
  ok "correctly denied — this policy is scoped to one path, not a prefix"
else
  warn "that read did not get denied — check policies/app-policy.hcl"
fi

echo
info "mint another dynamic database credential using this token (should be denied —"
info "app-policy has no capabilities on database/creds/*):"
if ctl "$app_token" vault read database/creds/readonly 2>&1 | tee /dev/stderr | grep -qi "permission denied"; then
  ok "correctly denied — read-only KV access does not imply database access"
else
  warn "that read did not get denied — check policies/app-policy.hcl"
fi

step "5. Revoking this token (it had a 15m TTL anyway, but do it explicitly)"
ctl labroot vault token revoke "$app_token"
ok "revoked"

info "using it again now fails outright, not just 'permission denied':"
ctl "$app_token" vault kv get kv/blog/database 2>&1 | sed 's/^/  /' || true

cat <<NEXT

  Compare this token's blast radius to the root token every earlier
  script used: root can do anything to anything; this one can read one
  path and nothing else. That difference is the entire point of policies.

  Next:
    ./04-docker-app.sh
NEXT
