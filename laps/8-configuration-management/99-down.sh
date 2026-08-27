#!/bin/bash
# No cloud cost to stop here — this just tears the containers down.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
require_docker
cd "$LAB_DIR"

step "docker compose down"
docker compose down -v

ok "removed"
echo "  ./ssh/, .vault_pass, and group_vars/all/vault.yml's encrypted"
echo "  contents are left in place — ./01-up.sh picks up right where you left off."
