#!/bin/bash
# No cloud cost here — everything lived in local containers. This just
# tears them down. Vault is dev-mode (in-memory), so every secret,
# policy, and lease created above disappears with it — nothing to clean
# up inside Vault itself.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
require_docker
cd "$LAB_DIR"

step "docker compose down"
docker compose --profile app down -v

ok "removed — Vault's in-memory state is gone with it"
echo "  ./01-kv-secrets.sh onward will need to be re-run from the top next time."
