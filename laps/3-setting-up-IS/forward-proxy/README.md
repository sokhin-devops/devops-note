# Squid Forward Proxy Lab

A simple professional Docker-based lab for learning how a
Squid forward proxy works.

## Architecture

```text
Client / curl
     |
     | HTTP Proxy :3128
     v
+-------------------+
| Squid Forward     |
| Proxy             |
| :3128             |
+---------+---------+
          |
          | HTTP / HTTPS
          v
       Internet
```

## Prerequisites

- Docker and Docker Compose
- `curl` (for testing)

## Run

Start the proxy:

```bash
docker compose up -d
```

Check it's healthy:

```bash
docker compose ps
docker compose logs -f squid
```

## Test

Route a request through the proxy (HTTP):

```bash
curl -x http://localhost:3128 -v http://example.com
```

Route a request through the proxy (HTTPS, via CONNECT):

```bash
curl -x http://localhost:3128 -v https://example.com
```

A successful request shows Squid establishing the `CONNECT`/forwarding
and returning the upstream response. You should also see `X-Cache` /
`Via` style headers indicating the response passed through Squid.

### Verify access control

`squid.conf` only allows `Safe_ports` (80, 443) and denies `CONNECT`
to anything outside `SSL_ports` (443). Confirm a disallowed port is
blocked:

```bash
curl -x http://localhost:3128 -v http://example.com:8080
```

This should return a `403 Forbidden` from Squid (access denied),
proving the ACL rules in `squid/squid.conf` are being enforced.

### Inspect logs

Access logs are written inside the container to
`/var/log/squid/access.log`:

```bash
docker compose exec squid tail -f /var/log/squid/access.log
```

Each test request above should produce a corresponding log line.

## Stop / cleanup

```bash
docker compose down
```

To also remove the cached data volume:

```bash
docker compose down -v
```

## Notes

- The proxy only allows traffic from `localhost` and RFC1918 private
  networks (`10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`); all
  other sources are denied by the final `http_access deny all` rule.
- `squid.conf` is mounted read-only, so changes require editing the
  file on the host and restarting the container:
  `docker compose restart squid`.
