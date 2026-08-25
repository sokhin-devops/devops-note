#!/bin/bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

# clear any previous run
docker compose down
docker rm -f protected-server client-trusted client-blocked >/dev/null 2>&1 || true

# build and start
docker compose up -d --build

echo "Waiting for protected-server firewall + nginx to be ready..."
for i in $(seq 1 20); do
  if docker exec client-trusted curl -s -o /dev/null -m 2 http://protected-server 2>/dev/null; then
    echo "protected-server is up and reachable from the trusted client"
    exit 0
  fi
  sleep 1
done

echo "protected-server did not become ready in time" >&2
docker compose logs protected-server
exit 1
