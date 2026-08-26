#!/bin/bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

# clear any previous run
docker compose down
docker rm -f cache-api redis >/dev/null 2>&1 || true

# build and start
docker compose up -d --build

echo "Waiting for the API and Redis to be ready..."
for i in $(seq 1 30); do
  if curl -s -m 2 http://localhost:8080/health 2>/dev/null | grep -q '"redis": *"ok"'; then
    echo "cache-api is up on port 8080 and connected to Redis"
    exit 0
  fi
  sleep 1
done

echo "the stack did not become ready in time" >&2
docker compose logs api
exit 1
