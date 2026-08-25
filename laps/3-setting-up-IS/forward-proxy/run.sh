#!/bin/bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

# clear any previous run
docker compose down
docker rm -f squid-proxy >/dev/null 2>&1 || true

# start compose
docker compose up -d

echo "Waiting for squid to be ready..."
for i in $(seq 1 15); do
  if (exec 3<>/dev/tcp/127.0.0.1/3128) 2>/dev/null; then
    echo "squid-proxy is up on port 3128"
    exit 0
  fi
  sleep 1
done

echo "squid-proxy did not become ready in time" >&2
docker compose logs squid
exit 1
