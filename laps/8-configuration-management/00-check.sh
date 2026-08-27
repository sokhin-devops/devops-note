#!/bin/bash
# Read-only except for generating a throwaway SSH keypair if one doesn't
# exist yet. Creates no containers. Run this first.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
require_docker
cd "$LAB_DIR"

step "1. Docker"
docker version --format '  {{.Server.Version}}' 2>/dev/null || die "Docker daemon is not reachable"
ok "docker is up"

step "2. This lab's throwaway SSH keypair"
mkdir -p ssh
if [ -f ssh/id_ed25519 ] && [ -f ssh/id_ed25519.pub ]; then
  ok "ssh/id_ed25519(.pub) already exist — reusing them"
else
  command -v ssh-keygen >/dev/null 2>&1 || die "ssh-keygen not found"
  ssh-keygen -t ed25519 -N "" -C "ansible-lab" -f ssh/id_ed25519 -q
  ok "generated a fresh keypair in ./ssh/ (gitignored, used only inside these containers)"
fi

step "3. A vault password for ./02-vault-setup.sh"
if [ -f .vault_pass ]; then
  ok ".vault_pass already exists — reusing it"
else
  echo "lab-vault-password-not-a-real-secret" > .vault_pass
  ok "wrote a throwaway .vault_pass (gitignored) — see the README before assuming"
  echo "   this is how you'd handle a real vault password"
fi

cat <<NEXT

  Nothing has been built or started yet. Next:
    ./01-up.sh
NEXT
