#!/bin/bash
# Read-only. Creates nothing. Run this first.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

step "1. Terraform"
require_terraform
terraform version | sed 's/^/  /'
ok "terraform is on PATH"

step "2. Your .env"
load_env
[ -f "$(expand_path "$SSH_PRIVATE_KEY")" ] || warn "SSH_PRIVATE_KEY ($SSH_PRIVATE_KEY) not found — needed by 03-apply.sh and 04-verify.sh"
ok ".env loaded"

step "3. Does the API key work?"
code="$(curl -s -o /dev/null -m 10 -w '%{http_code}' -H "Authorization: Bearer $VULTR_API_KEY" https://api.vultr.com/v2/account)"
case "$code" in
  200) ok "VULTR_API_KEY is valid" ;;
  401) die "HTTP 401 — the key in .env was rejected" ;;
  403) die "HTTP 403 — key rejected for this source IP (Vultr restricts API access by IP: https://my.vultr.com/settings/#settingsapi)" ;;
  *)   die "unexpected HTTP $code from api.vultr.com" ;;
esac

step "4. Your SSH public key"
pubkey_path="$(expand_path "~/.ssh/id_ed25519.pub")"
if [ -f "$pubkey_path" ]; then
  ok "found $pubkey_path (the default in variables.tf)"
else
  warn "no key at $pubkey_path — override ssh_public_key_path in environments/*.tfvars, or:"
  echo "    ssh-keygen -t ed25519"
fi

step "5. Terraform files"
terraform fmt -check -recursive . && ok "terraform fmt: no changes needed" \
  || warn "terraform fmt found formatting issues — run: terraform fmt -recursive ."

cat <<SUMMARY

Summary
------------------------------------------------------------
  terraform : $(terraform version -json 2>/dev/null | grep -o '"terraform_version":"[^"]*"' | cut -d'"' -f4)
  API key   : valid

  Nothing has been created. Next:
    ./01-init.sh
SUMMARY
