#!/bin/bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

# clear any previous run
docker compose down
docker rm -f load-balancer backend1 backend2 backend3 >/dev/null 2>&1 || true

# start compose
docker compose up -d

echo "Waiting for load-balancer to be ready..."
for i in $(seq 1 20); do
  if [ "$(curl -s -o /dev/null -m 2 -w '%{http_code}' http://localhost:8080/whoami 2>/dev/null)" = "200" ]; then
    echo "load-balancer is up on port 8080 and reaching the backend pool"
    exit 0
  fi
  sleep 1
done

echo "load-balancer did not become ready in time" >&2
docker compose logs load-balancer
exit 1
