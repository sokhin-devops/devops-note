#!/bin/bash
set -e

# The private key is bind-mounted from the host. On Windows, bind-mounted
# files usually don't carry Linux permission bits SSH is happy with, so
# copy it into the container's own filesystem and set 0600 there instead
# of pointing ssh straight at the mount (which fails with "UNPROTECTED
# PRIVATE KEY FILE").
mkdir -p /root/.ssh
cp /run/lab-secrets/id_ed25519 /root/.ssh/id_ed25519
chmod 600 /root/.ssh/id_ed25519

exec "$@"
