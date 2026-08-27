#!/bin/bash
set -e

# Same permission-mapping reason as controller/entrypoint.sh: install the
# key from the mounted secrets path rather than trusting the mount's own
# permission bits.
mkdir -p /home/ansible/.ssh
cp /run/lab-secrets/id_ed25519.pub /home/ansible/.ssh/authorized_keys
chmod 600 /home/ansible/.ssh/authorized_keys
chown ansible:ansible /home/ansible/.ssh/authorized_keys

# Hand off PID 1 to systemd (the base image's CMD) — exec, not a background
# start, because the systemd-in-Docker trick depends on it actually being
# PID 1.
exec "$@"
