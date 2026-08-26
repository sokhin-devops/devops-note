#!/bin/bash
# Shared helpers for the numbered scripts. Deliberately thin — unlike the
# Vultr and Cloudflare labs, this one has no hand-rolled state tracking or
# API wrapper. Terraform's own state file is that same idea, done by the
# tool instead of by us; see the README's notes.

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

confirm() {
  local reply=""
  printf '%s %s[y/N]%s ' "$1" "$C_DIM" "$C_RESET"
  read -r reply 2>/dev/null </dev/tty || reply=""
  case "$reply" in
    [yY] | [yY][eE][sS]) return 0 ;;
    *) return 1 ;;
  esac
}

expand_path() {
  case "$1" in
    "~/"*) printf '%s/%s' "$HOME" "${1#\~/}" ;;
    *) printf '%s' "$1" ;;
  esac
}

load_env() {
  [ -f "$LAB_DIR/.env" ] || die "no .env file — copy .env.example to .env and fill it in"
  # shellcheck disable=SC1090
  set -a
  . "$LAB_DIR/.env"
  set +a

  [ -n "${VULTR_API_KEY:-}" ] || die "VULTR_API_KEY is empty in .env"
  export VULTR_API_KEY

  SSH_PRIVATE_KEY="$(expand_path "${SSH_PRIVATE_KEY:-~/.ssh/id_ed25519}")"
}

require_terraform() {
  command -v terraform >/dev/null 2>&1 || die "terraform is not on PATH — see README.md Prerequisites"
}

# Which var-file to use: ./03-apply.sh prod -> environments/prod.tfvars
# Defaults to dev, and refuses an unknown name outright.
resolve_varfile() {
  local env_name="${1:-dev}"
  local path="$LAB_DIR/environments/$env_name.tfvars"
  [ -f "$path" ] || die "no environments/$env_name.tfvars — expected 'dev' or 'prod'"
  printf '%s' "$path"
}

ssh_opts() {
  printf '%s' "-i $SSH_PRIVATE_KEY -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -o ConnectTimeout=10"
}

lab_ssh() {
  local ip="$1"; shift
  # shellcheck disable=SC2046
  ssh $(ssh_opts) "root@$ip" "$@"
}

# Waits for SSH, then for cloud-init to finish — the same two-stage wait as
# the Vultr lab's 04-status.sh, since terraform apply completing only means
# the API call succeeded, not that cloud-init has run yet.
wait_for_boot() {
  local ip="$1"

  info "waiting for SSH on $ip:22"
  local up=0
  for i in $(seq 1 30); do
    if lab_ssh "$ip" true 2>/dev/null; then up=1; break; fi
    printf '\r  attempt %s/30...   ' "$i"
    sleep 10
  done
  echo
  [ "$up" = "1" ] || die "SSH never came up on $ip"
  ok "SSH is answering"

  info "waiting for cloud-init"
  local ready=0
  for i in $(seq 1 40); do
    if lab_ssh "$ip" "test -f /var/lib/lab-ready" 2>/dev/null; then ready=1; break; fi
    printf '\r  still bootstrapping... %s/40   ' "$i"
    sleep 15
  done
  echo

  if [ "$ready" != "1" ]; then
    warn "cloud-init has not finished yet. Watch it with:"
    echo "    ssh $(ssh_opts) root@$ip 'tail -f /var/log/cloud-init-output.log'"
    return 1
  fi
  ok "cloud-init finished"
}
