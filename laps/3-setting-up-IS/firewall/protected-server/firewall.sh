#!/bin/bash
set -e

TRUSTED_IP="${TRUSTED_IP:?TRUSTED_IP must be set}"

# Start from a clean, disabled ruleset so restarts are idempotent
ufw --force reset >/dev/null

# Default policy: nothing gets in, the server can still reach out
ufw default deny incoming
ufw default allow outgoing

# Only the trusted source may reach port 80
ufw allow from "$TRUSTED_IP" to any port 80 proto tcp

# The LOG target is unavailable in most container kernels
ufw logging off

ufw --force enable

echo "UFW rules applied (trusted source: $TRUSTED_IP):"
ufw status verbose
