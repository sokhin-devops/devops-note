#!/bin/bash
# Copies app/ to the VM and starts it with Docker Compose (lesson 38, step 9).
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib/vultr.sh"
load_env

ip="$(state_require INSTANCE_IP "./04-status.sh")"
remote="/opt/lab-app"

step "1. Copying app/ to $ip:$remote"
lab_ssh "$ip" "mkdir -p $remote"
# shellcheck disable=SC2046
scp $(ssh_opts) -r "$LAB_DIR/app/." "root@$ip:$remote/" >/dev/null
ok "uploaded compose.yaml, default.conf and html/"

step "2. Stamping this deployment into the page"
deployed_at="$(date -u '+%Y-%m-%d %H:%M UTC')"
lab_ssh "$ip" "sed -i \
  -e 's|__SERVER_IP__|$ip|g' \
  -e 's|__REGION__|$VULTR_REGION|g' \
  -e 's|__DEPLOYED_AT__|$deployed_at|g' \
  $remote/html/index.html"
ok "page stamped with $ip / $VULTR_REGION / $deployed_at"

step "3. docker compose up"
lab_ssh "$ip" "cd $remote && docker compose up -d" 2>&1 | sed 's/^/  /'

step "4. What is running"
lab_ssh "$ip" "docker compose -f $remote/compose.yaml ps" | sed 's/^/  /'

step "5. Answering from the inside"
lab_ssh "$ip" "curl -s -o /dev/null -w 'localhost/health -> %{http_code}\n' http://localhost/health" | sed 's/^/  /'

cat <<NEXT

  Open it from your own browser:

    http://$ip/

  Next: ./06-verify.sh   (checks it from the outside, including the ports
                          the firewall is supposed to be blocking)
NEXT
