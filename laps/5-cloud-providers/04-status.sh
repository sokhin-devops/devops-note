#!/bin/bash
# Waits for the VM to boot, then for cloud-init to finish. Read-only.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib/vultr.sh"
load_env

instance_id="$(state_require INSTANCE_ID "./03-create-instance.sh")"

step "1. Waiting for Vultr to finish provisioning"
ip=""
for i in $(seq 1 40); do
  json="$(api GET "/instances/$instance_id")"
  status="$(echo "$json" | jq -r '.instance.status')"
  server="$(echo "$json" | jq -r '.instance.server_status')"
  power="$(echo "$json" | jq -r '.instance.power_status')"
  ip="$(echo "$json" | jq -r '.instance.main_ip')"

  printf '\r  status=%s server=%s power=%s ip=%s   ' "$status" "$server" "$power" "$ip"

  if [ "$status" = "active" ] && [ "$power" = "running" ] && [ "$ip" != "0.0.0.0" ]; then
    echo
    ok "VM is active at $ip"
    break
  fi
  sleep 10
done

[ -n "$ip" ] && [ "$ip" != "0.0.0.0" ] || die "the VM did not get a public IP in time"
state_set INSTANCE_IP "$ip"

step "2. Waiting for SSH on $ip:22"
ssh_up=0
for i in $(seq 1 30); do
  if lab_ssh "$ip" true 2>/dev/null; then
    ssh_up=1
    ok "SSH accepted the lab key"
    break
  fi
  printf '\r  attempt %s/30...   ' "$i"
  sleep 10
done
echo
[ "$ssh_up" = "1" ] || die "SSH never came up — check the console at https://my.vultr.com"

step "3. Waiting for cloud-init (apt upgrade + Docker install)"
ready=0
for i in $(seq 1 40); do
  if lab_ssh "$ip" "test -f /var/lib/lab-ready" 2>/dev/null; then
    ready=1
    ok "cloud-init finished"
    break
  fi
  printf '\r  still bootstrapping... %s/40   ' "$i"
  sleep 15
done
echo

if [ "$ready" != "1" ]; then
  warn "cloud-init has not finished yet. Watch it with:"
  echo "    ssh $(ssh_opts) root@$ip 'tail -f /var/log/cloud-init-output.log'"
  exit 1
fi

step "4. What the VM looks like now"
lab_ssh "$ip" "cat /var/log/lab-bootstrap.log" 2>/dev/null | sed 's/^/  /' || true
echo
lab_ssh "$ip" "echo '  uname   :' \$(uname -srm); echo '  uptime  :' \$(uptime -p)" 2>/dev/null || true

cat <<NEXT

  The VM is ready.

    ssh $(ssh_opts) root@$ip
    ssh $(ssh_opts) deploy@$ip     # the non-root user

  Next: ./05-deploy.sh   (copies app/ up and starts it with Docker Compose)
NEXT
