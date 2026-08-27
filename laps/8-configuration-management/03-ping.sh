#!/bin/bash
# The lesson's section 8 "Common Ansible Commands" — connectivity and
# ad-hoc commands, run for real against the three containers.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
require_docker
cd "$LAB_DIR"

step "1. Inventory, as Ansible sees it"
ctl ansible-inventory --list | sed 's/^/  /'

step "2. ansible all -m ping"
ctl ansible all -m ping

step "3. ansible webservers --list-hosts"
ctl ansible webservers --list-hosts

step "4. Ad-hoc: uptime on every host"
ctl ansible all -m command -a "uptime"

step "5. Ad-hoc: gather facts, filtered"
ctl ansible all -m setup -a "filter=ansible_os_family"

cat <<NEXT

  Next: ./04-playbook.sh
NEXT
