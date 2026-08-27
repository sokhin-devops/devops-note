#!/bin/bash
LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ -t 1 ]; then
  C_RESET=$'\033[0m'; C_DIM=$'\033[2m'; C_BOLD=$'\033[1m'
  C_RED=$'\033[31m'; C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'; C_BLUE=$'\033[34m'
else
  C_RESET=""; C_DIM=""; C_BOLD=""; C_RED=""; C_GREEN=""; C_YELLOW=""; C_BLUE=""
fi

info() { echo "${C_BLUE}==>${C_RESET} $*"; }
ok()   { echo "${C_GREEN}[ok]${C_RESET} $*"; }
warn() { echo "${C_YELLOW}[warn]${C_RESET} $*" >&2; }
die()  { echo "${C_RED}[error]${C_RESET} $*" >&2; exit 1; }

step() {
  echo
  echo "${C_BOLD}$*${C_RESET}"
  echo "${C_DIM}------------------------------------------------------------${C_RESET}"
}

require_docker() {
  command -v docker >/dev/null 2>&1 || die "docker is not on PATH"
}

load_env() {
  [ -f "$LAB_DIR/.env" ] || die "no .env file — copy .env.example to .env first"
  set -a
  . "$LAB_DIR/.env"
  set +a
  [ -n "${POSTGRES_ADMIN_PASSWORD:-}" ] || die "POSTGRES_ADMIN_PASSWORD is empty in .env"
}

# Runs a command inside the client container with an explicit Vault
# token — never an ambient default, so every call site says which token
# it's using. First argument is the token, the rest is the command:
#   ctl labroot vault kv get kv/blog/database
#   ctl "$APP_TOKEN" vault kv get kv/blog/database
ctl() {
  local token="$1"; shift
  docker compose exec -T -e VAULT_ADDR=http://vault:8200 -e VAULT_TOKEN="$token" client "$@"
}

# Runs psql inside the client container, authenticated as vaultadmin.
# pctl -c "select 1"
pctl() {
  docker compose exec -T -e PGPASSWORD="$POSTGRES_ADMIN_PASSWORD" client \
    psql -h postgres -U vaultadmin -d appdb "$@"
}

# Runs psql as an arbitrary user/password — used to prove dynamically
# generated credentials actually work (or, once revoked, don't).
# pctl_as USER PASSWORD -c "select 1"
pctl_as() {
  local user="$1" pass="$2"; shift 2
  docker compose exec -T -e PGPASSWORD="$pass" client \
    psql -h postgres -U "$user" -d appdb "$@"
}
