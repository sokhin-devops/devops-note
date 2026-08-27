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

# Runs a command inside the controller container, in /ansible.
ctl() {
  docker compose exec -T controller "$@"
}
