#!/bin/bash
# Shared helpers for the Vultr lab. Sourced by every numbered script.
#
# Nothing in here creates anything — it only loads configuration, talks to the
# Vultr API, and remembers the ids of what the other scripts created.

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_FILE="$LAB_DIR/state/lab.env"
VULTR_API="https://api.vultr.com/v2"

# ------------------------------------------------------------------ output --

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

# Ask before doing anything that costs money or destroys something.
confirm() {
  local reply=""
  printf '%s %s[y/N]%s ' "$1" "$C_DIM" "$C_RESET"
  # 2>/dev/null must come first: bash applies redirections left to right, so a
  # later one cannot suppress the error from opening /dev/tty on a machine
  # with no terminal (a CI run, or a piped invocation).
  read -r reply 2>/dev/null </dev/tty || reply=""
  case "$reply" in
    [yY] | [yY][eE][sS]) return 0 ;;
    *) return 1 ;;
  esac
}

# ------------------------------------------------------------ configuration --

expand_path() {
  case "$1" in
    "~/"*) printf '%s/%s' "$HOME" "${1#\~/}" ;;
    *) printf '%s' "$1" ;;
  esac
}

require_tools() {
  local missing=""
  for tool in curl jq ssh scp base64; do
    command -v "$tool" >/dev/null 2>&1 || missing="$missing $tool"
  done
  [ -z "$missing" ] || die "missing required tool(s):$missing"
}

load_env() {
  require_tools

  [ -f "$LAB_DIR/.env" ] || die "no .env file — copy .env.example to .env and fill it in"

  # shellcheck disable=SC1090
  set -a
  . "$LAB_DIR/.env"
  set +a

  [ -n "${VULTR_API_KEY:-}" ] || die "VULTR_API_KEY is empty in .env"

  VULTR_REGION="${VULTR_REGION:-sgp}"
  VULTR_PLAN="${VULTR_PLAN:-vc2-1c-1gb}"
  VULTR_OS_NAME="${VULTR_OS_NAME:-Ubuntu 24.04 LTS x64}"
  LAB_LABEL="${LAB_LABEL:-devops-lab}"

  SSH_PUBLIC_KEY="$(expand_path "${SSH_PUBLIC_KEY:-~/.ssh/id_ed25519.pub}")"
  SSH_PRIVATE_KEY="$(expand_path "${SSH_PRIVATE_KEY:-~/.ssh/id_ed25519}")"

  mkdir -p "$LAB_DIR/state"
}

# -------------------------------------------------------------------- state --

# The ids of everything the lab created live in state/lab.env, so a later
# script (and ./99-destroy.sh) knows what to act on.

state_set() {
  local key="$1" value="$2" tmp
  mkdir -p "$(dirname "$STATE_FILE")"
  touch "$STATE_FILE"
  tmp="$STATE_FILE.tmp"
  grep -v "^$key=" "$STATE_FILE" > "$tmp" 2>/dev/null || true
  echo "$key=$value" >> "$tmp"
  mv "$tmp" "$STATE_FILE"
}

state_get() {
  [ -f "$STATE_FILE" ] || return 0
  grep "^$1=" "$STATE_FILE" 2>/dev/null | tail -1 | cut -d= -f2-
  # A missing key is a normal answer, not an error. Without this, grep's exit
  # status 1 propagates through pipefail and kills any caller using `set -e`.
  return 0
}

state_require() {
  local value
  value="$(state_get "$1")"
  [ -n "$value" ] || die "$1 is not in state — run the earlier scripts first (${2:-})"
  printf '%s' "$value"
}

state_clear() { rm -f "$STATE_FILE"; }

# ---------------------------------------------------------------------- API --

# api METHOD PATH [JSON_BODY]
#
# Prints the response body on success and exits with a readable message on
# failure. Every other script goes through this one function.
api() {
  local method="$1" path="$2" body="${3:-}"
  local tmp status out
  tmp="$(mktemp)"

  if [ -n "$body" ]; then
    status="$(curl -sS -o "$tmp" -w '%{http_code}' -X "$method" \
      -H "Authorization: Bearer $VULTR_API_KEY" \
      -H "Content-Type: application/json" \
      --data "$body" "$VULTR_API$path")"
  else
    status="$(curl -sS -o "$tmp" -w '%{http_code}' -X "$method" \
      -H "Authorization: Bearer $VULTR_API_KEY" \
      "$VULTR_API$path")"
  fi

  out="$(cat "$tmp")"
  rm -f "$tmp"

  case "$status" in
    2*)
      printf '%s' "$out"
      return 0
      ;;
    401)
      die "HTTP 401 — the API key in .env was rejected"
      ;;
    403)
      die "HTTP 403 — key rejected for this source IP. Vultr restricts API
       access by IP: add your current public IP under
       https://my.vultr.com/settings/#settingsapi
       (your IP may have changed since you added it)"
      ;;
    429)
      die "HTTP 429 — rate limited by the Vultr API, wait a moment and retry"
      ;;
    *)
      die "$method $path failed (HTTP $status): $out"
      ;;
  esac
}

# ------------------------------------------------------------------ lookups --

# Resolve the OS id for VULTR_OS_NAME, so no numeric id is hard-coded here.
lookup_os_id() {
  local id
  id="$(api GET "/os?per_page=500" | jq -r --arg n "$VULTR_OS_NAME" \
    '.os[] | select(.name == $n) | .id' | head -1)"
  [ -n "$id" ] || die "no OS named '$VULTR_OS_NAME' — run ./01-check.sh to list them"
  printf '%s' "$id"
}

# The instance's public IP, once Vultr has assigned one.
instance_ip() {
  local id="$1"
  api GET "/instances/$id" | jq -r '.instance.main_ip'
}

instance_status() {
  local id="$1"
  api GET "/instances/$id" | jq -r '"\(.instance.status) \(.instance.server_status) \(.instance.power_status)"'
}

# ssh/scp into the lab VM with the lab's key, skipping the host-key prompt
# (the host is brand new every time, so its key is expected to be unknown).
ssh_opts() {
  printf '%s' "-i $SSH_PRIVATE_KEY -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -o ConnectTimeout=10"
}

lab_ssh() {
  local ip="$1"; shift
  # shellcheck disable=SC2046
  ssh $(ssh_opts) "root@$ip" "$@"
}
