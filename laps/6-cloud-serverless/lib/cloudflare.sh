#!/bin/bash
# Shared helpers for the Cloudflare lab. Sourced by every numbered script.
#
# Nothing in here changes anything by itself — it only loads configuration,
# talks to the Cloudflare API, resolves DNS over HTTPS, and remembers the ids
# of what the other scripts created.

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_FILE="$LAB_DIR/state/lab.env"
CF_API="https://api.cloudflare.com/client/v4"

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

# Ask before doing anything that touches a live domain or deletes something.
confirm() {
  local reply=""
  printf '%s %s[y/N]%s ' "$1" "$C_DIM" "$C_RESET"
  # 2>/dev/null must come first: bash applies redirections left to right, so a
  # later one cannot suppress the error from opening /dev/tty on a machine
  # with no terminal.
  read -r reply 2>/dev/null </dev/tty || reply=""
  case "$reply" in
    [yY] | [yY][eE][sS]) return 0 ;;
    *) return 1 ;;
  esac
}

# ------------------------------------------------------------ configuration --

require_tools() {
  local missing=""
  for tool in curl jq npx; do
    command -v "$tool" >/dev/null 2>&1 || missing="$missing $tool"
  done
  [ -z "$missing" ] || die "missing required tool(s):$missing (npx ships with Node.js)"
}

load_env() {
  require_tools

  [ -f "$LAB_DIR/.env" ] || die "no .env file — copy .env.example to .env and fill it in"

  # shellcheck disable=SC1090
  set -a
  . "$LAB_DIR/.env"
  set +a

  [ -n "${CLOUDFLARE_API_TOKEN:-}" ] || die "CLOUDFLARE_API_TOKEN is empty in .env"

  LAB_DOMAIN="${LAB_DOMAIN:-sokhin.site}"
  WORKER_SUBDOMAIN="${WORKER_SUBDOMAIN:-edge}"
  WORKER_NAME="${WORKER_NAME:-devops-lab-edge}"
  WORKER_HOSTNAME="$WORKER_SUBDOMAIN.$LAB_DOMAIN"

  mkdir -p "$LAB_DIR/state"

  if [ -z "${CLOUDFLARE_ACCOUNT_ID:-}" ]; then
    CLOUDFLARE_ACCOUNT_ID="$(state_get ACCOUNT_ID)"
  fi
}

# -------------------------------------------------------------------- state --

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
  # status 1 would propagate through `set -e -o pipefail` and kill the caller.
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
# Cloudflare can return HTTP 200 with "success": false, so both the HTTP
# status and the success field are checked. Prints .result on success.
api() {
  local method="$1" path="$2" body="${3:-}"
  local tmp status out success

  tmp="$(mktemp)"
  if [ -n "$body" ]; then
    status="$(curl -sS -o "$tmp" -w '%{http_code}' -X "$method" \
      -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
      -H "Content-Type: application/json" \
      --data "$body" "$CF_API$path")"
  else
    status="$(curl -sS -o "$tmp" -w '%{http_code}' -X "$method" \
      -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
      "$CF_API$path")"
  fi
  out="$(cat "$tmp")"
  rm -f "$tmp"

  case "$status" in
    401) die "HTTP 401 — the API token in .env was rejected" ;;
    403) die "HTTP 403 — token accepted, but lacks permission for $method $path
       (see the permission list in .env.example)" ;;
    429) die "HTTP 429 — rate limited by the Cloudflare API, wait a moment and retry" ;;
  esac

  success="$(printf '%s' "$out" | jq -r '.success')"
  if [ "$success" != "true" ]; then
    local msg
    msg="$(printf '%s' "$out" | jq -r '.errors[]? | "\(.code): \(.message)"')"
    die "$method $path failed: ${msg:-$out}"
  fi

  printf '%s' "$out" | jq -c '.result'
}

# ------------------------------------------------------------------- DNS-o-H --

# doh NAME TYPE — DNS over HTTPS via Cloudflare's own resolver at 1.1.1.1,
# queried by IP so it works even before this machine's own resolver has
# anything useful to say about the domain. Prints the "Answer" array, or
# "[]" if there is none.
doh() {
  local name="$1" type="$2"
  curl -sS -m 10 -H 'accept: application/dns-json' \
    "https://1.1.1.1/dns-query?name=$name&type=$type" \
    | jq -c '.Answer // []'
}

# ------------------------------------------------------------------ lookups --

resolve_account_id() {
  if [ -n "${CLOUDFLARE_ACCOUNT_ID:-}" ]; then
    printf '%s' "$CLOUDFLARE_ACCOUNT_ID"
    return 0
  fi

  local accounts count id
  accounts="$(api GET "/accounts?per_page=50")"
  count="$(printf '%s' "$accounts" | jq 'length')"

  if [ "$count" = "0" ]; then
    die "the token can see no accounts — check its permissions"
  elif [ "$count" != "1" ]; then
    printf '%s' "$accounts" | jq -r '.[] | "  \(.id)  \(.name)"' >&2
    die "the token can see $count accounts — set CLOUDFLARE_ACCOUNT_ID in .env to one of the ids above"
  fi

  id="$(printf '%s' "$accounts" | jq -r '.[0].id')"
  printf '%s' "$id"
}

lookup_zone_id() {
  api GET "/zones?name=$LAB_DOMAIN" | jq -r '.[0].id // empty'
}
