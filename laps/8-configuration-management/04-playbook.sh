#!/bin/bash
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
require_docker
cd "$LAB_DIR"

[ -f .vault_pass ] || die "no .vault_pass — run ./00-check.sh first"
VAULT_ARGS="--vault-password-file .vault_pass"

step "1. Syntax check"
ctl ansible-playbook playbooks/site.yml --syntax-check

step "2. Dry run (--check) — nothing on the containers changes yet"
ctl ansible-playbook playbooks/site.yml --check $VAULT_ARGS

step "3. Real run"
ctl ansible-playbook playbooks/site.yml $VAULT_ARGS

step "4. Re-run — idempotency (the lesson's 'safe to run multiple times')"
echo "  Watch the per-host summary lines below: 'changed=0' is the point."
rerun_log="$(mktemp)"
ctl ansible-playbook playbooks/site.yml $VAULT_ARGS | tee "$rerun_log"

echo
if grep -qE 'changed=[1-9]' "$rerun_log"; then
  warn "the second run still reported some changes — look at which task in"
  warn "the output above (not the summary line) shows 'changed'. A task"
  warn "that changes every single run, with nothing on the container"
  warn "actually different, is not truly idempotent — see the README's Notes."
else
  ok "second run: changed=0 everywhere — the play made no changes because"
  ok "everything was already in the state it describes"
fi
rm -f "$rerun_log"

cat <<NEXT

  Next: ./05-verify.sh
NEXT
