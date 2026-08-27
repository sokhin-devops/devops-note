#!/bin/bash
# The lesson's Vault section, run for real: encrypts
# group_vars/all/vault.yml in place. Safe to re-run — it's a no-op once
# the file is already encrypted.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
require_docker
cd "$LAB_DIR"

[ -f .vault_pass ] || die "no .vault_pass — run ./00-check.sh first"

if head -1 group_vars/all/vault.yml | grep -q '^\$ANSIBLE_VAULT'; then
  ok "group_vars/all/vault.yml is already encrypted — nothing to do"
else
  step "Encrypting group_vars/all/vault.yml"
  ctl ansible-vault encrypt group_vars/all/vault.yml --vault-password-file .vault_pass
  ok "encrypted in place"
fi

step "What's actually on disk now"
head -3 group_vars/all/vault.yml | sed 's/^/  /'

step "Decrypting it back, the same way the playbook will"
ctl ansible-vault view group_vars/all/vault.yml --vault-password-file .vault_pass | sed 's/^/  /'

cat <<NOTE

  That file is genuinely encrypted (AES256, per the \$ANSIBLE_VAULT header
  above) — not just renamed or base64'd. It's safe to commit to git in this
  state; .vault_pass (the key that unlocks it) is what must never be
  committed, and .gitignore already excludes it.

  Try editing it yourself:
    docker compose exec controller ansible-vault edit group_vars/all/vault.yml --vault-password-file .vault_pass

  Next: ./03-ping.sh
NOTE
