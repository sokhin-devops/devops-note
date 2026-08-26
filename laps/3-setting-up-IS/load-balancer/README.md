# Nginx Load Balancer Lab

A simple professional Docker-based lab for learning how a load balancer
spreads incoming requests across a pool of identical backends — and what
happens to that pool when one backend dies.

## Architecture

```text
Client / curl
     |
     | HTTP :8080
     v
+---------------------+
|   Nginx Load        |
|   Balancer          |
|   round robin :80   |
+----------+----------+
           |
   +-------+-------+-------+
   |       |               |
   v       v               v
+--------+ +--------+ +--------+
|backend1| |backend2| |backend3|
|  :80   | |  :80   | |  :80   |
+--------+ +--------+ +--------+
```

Unlike the reverse-proxy lab — where each path goes to a *different*
service — every backend here is **interchangeable**. They serve the same
page from the same mounted files; only their identity differs. That is the
whole point of load balancing: any backend can answer any request, so the
pool can grow, shrink, or lose a member without the client noticing.

Each request is answered by the next backend in the rotation:

- `/` -> a page stamped with the name and colour of whichever backend served it
- `/whoami` -> plain text: the backend's name (what the tests count)
- `/health` -> per-backend health check
- `/lb-health` -> answered by the load balancer itself, without touching a backend

## Prerequisites

- Docker and Docker Compose
- `curl` (for testing)
- Port 8080 free — the sibling labs in this folder also publish on 8080,
  so run one lab at a time

## Run

Start the stack with the helper script (resets any previous run, then waits
until the balancer is both listening and reaching the pool):

```bash
./run.sh
```

Or manually:

```bash
docker compose up -d
docker compose ps
docker compose logs -f load-balancer
```

## Test

Run the automated checks (requires the stack to already be running via
`./run.sh`):

```bash
./test.sh
```

The script checks the balancer's own health endpoint, confirms responses
carry an `X-Backend` header, sends 9 requests and asserts they landed 3 on
each backend, then **stops `backend2`** to prove requests keep succeeding
and none are sent to the dead backend, and finally brings it back and
confirms it rejoins the pool. It ends by printing the last few access log
lines, which name the upstream that served each request.

Note that the failover test stops and starts a container, so the lab is
briefly degraded while it runs; it restores the pool before it exits.

### Manual tests

```bash
# Watch round robin cycle through the pool
for i in $(seq 1 6); do curl -s http://localhost:8080/whoami; done

# See the chosen backend in the response headers
curl -sI http://localhost:8080/ | grep -i -E 'x-backend|x-upstream'

# The balancer's own health, answered without a backend
curl -s http://localhost:8080/lb-health
```

Or open <http://localhost:8080/> in a browser and reload — the page name and
colour change as each request is routed to the next backend.

### Watch a failure by hand

```bash
docker compose stop backend1
for i in $(seq 1 6); do curl -s http://localhost:8080/whoami; done   # only 2 and 3 answer
docker compose start backend1
docker compose restart load-balancer                                  # see the note below
```

### Inspect logs

```bash
docker compose exec load-balancer tail -f /var/log/nginx/access.log
```

The custom `lb` log format prints `upstream=<ip:port>` and
`upstream_time=<seconds>` on every line, so you can see the rotation and
spot a slow backend directly in the log.

## Stop / cleanup

```bash
docker compose down
```

## Notes

- **Round robin is the default.** The `upstream backend_pool` block in
  `nginx/nginx.conf` declares no method, so Nginx cycles through the
  servers in order. Add `least_conn;` to send each request to the backend
  with the fewest active connections, or `ip_hash;` to pin each client IP
  to one backend (crude session stickiness) — then re-run `./test.sh` and
  watch the even 3/3/3 split change.
- **`max_fails` / `fail_timeout` are passive health checks.** Nginx OSS has
  no active health probing: it only learns a backend is down by failing a
  real request. After `max_fails=3` failures within `fail_timeout=10s`, the
  backend is taken out of rotation for 10s, then retried. The `/health`
  endpoints exist for you and your monitoring to call — Nginx OSS does not
  poll them on its own.
- **`proxy_next_upstream` is what makes failover invisible.** Without it a
  request that hit the dead backend would return `502`. With it, Nginx
  silently retries the next server in the pool, which is why the tests still
  see `200` with `backend2` stopped.
- **Nginx resolves upstream hostnames once, at config load.** If a backend
  container comes back with a *different* IP, Nginx keeps dialling the old
  one until it is reloaded — hence the `docker compose restart
  load-balancer` in the recovery step. In production this is why pools are
  usually driven by a resolver or a service-discovery reload.
- **The backends share one set of files.** `backend/html/index.html` and
  `backend/default.conf.template` are mounted read-only into all three
  containers; the Nginx image's `envsubst` entrypoint renders the template
  with each container's `BACKEND_NAME`/`BACKEND_COLOR`, and `sub_filter`
  stamps the same two values into the served HTML. To add a `backend4`,
  copy a service block in `compose.yaml`, add it to the `upstream` block,
  and recreate the stack — no new files needed.
- Config files are mounted read-only; after editing `nginx/nginx.conf`,
  apply changes with `docker compose restart load-balancer`.
