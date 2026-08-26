#!/bin/bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

# clear any previous run
docker compose down
docker rm -f client dns web api >/dev/null 2>&1 || true

# start compose
docker compose up -d

echo "Waiting for DNS to answer for lab.internal..."
for i in $(seq 1 20); do
  if [ "$(docker exec client dig +short +time=2 +tries=1 @172.30.0.53 web.lab.internal A 2>/dev/null | tr -d '\r')" = "172.30.0.10" ]; then
    dns_ready=1
    break
  fi
  sleep 1
done

if [ "${dns_ready:-0}" != "1" ]; then
  echo "the DNS server did not become ready in time" >&2
  docker compose logs dns
  exit 1
fi

echo "Waiting for the web service..."
for i in $(seq 1 20); do
  if docker exec client curl -s -o /dev/null -m 2 http://web.lab.internal 2>/dev/null; then
    echo
    echo "Lab is up:"
    echo "  client  172.30.0.100   (run the exercises from here)"
    echo "  dns     172.30.0.53    (authoritative for lab.internal)"
    echo "  web     172.30.0.10:80    -> http://localhost:8080"
    echo "  api     172.30.0.20:3000  -> http://localhost:8081"
    echo
    echo "Next: ./explore.sh for the guided tour, or ./test.sh to verify everything."
    exit 0
  fi
  sleep 1
done

echo "the web service did not become ready in time" >&2
docker compose logs web
exit 1
