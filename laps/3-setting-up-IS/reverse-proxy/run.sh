#!/bin/bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

# clear any previous run
docker compose down
docker rm -f reverse-proxy app1 app2 >/dev/null 2>&1 || true

# start compose
docker compose up -d

echo "Waiting for reverse-proxy to be ready..."
for i in $(seq 1 15); do
  if (exec 3<>/dev/tcp/127.0.0.1/8080) 2>/dev/null; then
    echo "reverse-proxy is up on port 8080"
    exit 0
  fi
  sleep 1
done

echo "reverse-proxy did not become ready in time" >&2
docker compose logs reverse-proxy
exit 1
