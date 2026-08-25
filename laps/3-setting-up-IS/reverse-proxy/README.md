# Nginx Reverse Proxy Lab

A simple professional Docker-based lab for learning how a reverse
proxy routes incoming requests to backend services.

## Architecture

```text
Client / curl
     |
     | HTTP :8080
     v
+-------------------+
| Nginx Reverse     |
| Proxy             |
| :80               |
+---------+---------+
          |
    +-----+-----+
    |           |
    v           v
+-------+   +-------+
| app1  |   | app2  |
| :80   |   | :80   |
+-------+   +-------+
```

The proxy listens on the host at `:8080` and routes requests by path:

- `/app1/` -> `app1` backend container
- `/app2/` -> `app2` backend container
- `/`      -> a plain status message from the proxy itself

## Prerequisites

- Docker and Docker Compose
- `curl` (for testing)

## Run

Start the stack with the helper script (resets any previous run, then
waits until the proxy is accepting connections on 8080):

```bash
./run.sh
```

Or manually:

```bash
docker compose up -d
docker compose ps
docker compose logs -f reverse-proxy
```

## Test

Run the automated checks (requires the stack to already be running via
`./run.sh`):

```bash
./test.sh
```

This requests `/`, `/app1/`, and `/app2/` through the proxy, checks
the response codes and that each path is served by the correct
backend, and prints the last few proxy access log entries.

### Manual tests

```bash
curl -v http://localhost:8080/
curl -v http://localhost:8080/app1/
curl -v http://localhost:8080/app2/
```

Each backend response should show `<h1>App 1</h1>` or `<h1>App 2</h1>`
depending on the path, proving Nginx is routing to the correct
upstream container.

### Inspect logs

```bash
docker compose exec reverse-proxy tail -f /var/log/nginx/access.log
```

Each test request above should produce a corresponding log line.

## Stop / cleanup

```bash
docker compose down
```

## Notes

- `nginx/nginx.conf` sets `X-Real-IP`, `X-Forwarded-For`, and
  `X-Forwarded-Proto` on proxied requests so backend apps can see the
  original client info instead of the proxy's.
- `app1` and `app2` are plain `nginx:alpine` containers serving static
  pages — swap them for real services to route to in a bigger lab.
- Config files are mounted read-only; after editing
  `nginx/nginx.conf`, apply changes with
  `docker compose restart reverse-proxy`.
