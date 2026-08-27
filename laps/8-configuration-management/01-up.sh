#!/bin/bash
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
require_docker
cd "$LAB_DIR"

[ -f ssh/id_ed25519 ] || die "no ./ssh/id_ed25519 — run ./00-check.sh first"

step "1. Building and starting the lab"
echo "  web1, web2 and db1 boot real systemd (privileged + cgroupns: host —"
echo "  see the README's Notes for why). First boot is the slowest part;"
echo "  expect a minute or so, more on a cold image pull."
docker compose up -d --build

step "2. Waiting for SSH on web1, web2, db1"
pinglog="$(mktemp)"
up=0
for i in $(seq 1 30); do
  if ctl ansible all -m ping >"$pinglog" 2>&1; then
    up=1
    break
  fi
  printf '\r  attempt %s/30...   ' "$i"
  sleep 5
done
echo
if [ "$up" != "1" ]; then
  warn "targets are not answering yet. Common cause: systemd hasn't reached"
  warn "multi-user.target yet — check with:"
  echo "    docker compose exec web1 systemctl is-system-running"
  sed 's/^/  /' "$pinglog"
  rm -f "$pinglog"
  exit 1
fi
sed 's/^/  /' "$pinglog"
rm -f "$pinglog"
ok "all three targets answered ansible's ping module"

cat <<NEXT

  Next:
    ./02-vault-setup.sh   (one-time: encrypts group_vars/all/vault.yml)
    ./03-ping.sh          (ad-hoc commands from the lesson's section 8)
    ./04-playbook.sh      (runs playbooks/site.yml, twice, to show idempotency)
NEXT
