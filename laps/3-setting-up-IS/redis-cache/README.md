# Redis Cache Lab

A simple professional Docker-based lab for learning how a cache sits in
front of a slow data store — and what "cache hit", "TTL", and "eviction"
actually mean when you can watch them happen.

## Architecture

```text
Client / curl
     |
     | HTTP :8080
     v
+---------------------+        1. look in the cache
|   cache-api         | -----------------------------> +-----------+
|   Flask, :5000      | <----------------------------- |   Redis   |
+----------+----------+        2. HIT: return it        |   :6379   |
           |                                            +-----------+
           | 3. MISS only: pay the slow lookup                 ^
           v                                                   |
+---------------------+                                        |
| "database"          |  4. write the result back with a TTL --+
| 1000 ms per query   |
+---------------------+
```

The API implements the **cache-aside** pattern, the one you will meet in
almost every real system:

1. Look for the key in Redis.
2. **Hit** — return it immediately, never touching the slow store.
3. **Miss** — run the expensive query, write the result into Redis with a
   TTL, then return it.

The "database" here is a `time.sleep()` of 1000 ms. That is the whole
trick of the lab: the slowness is obvious, so the value of the cache is
measurable rather than theoretical.

## Endpoints

| Endpoint | What it does |
|---|---|
| `GET /` | Interactive demo page — clears the cache, then times two identical requests |
| `GET /product/<id>` | Cache-aside lookup. Returns `cache: HIT\|MISS`, `elapsed_ms`, `ttl_seconds`, and an `X-Cache` header. Valid ids: `1`, `2`, `3` |
| `GET /stats` | Hit / miss counters, hit rate, number of cached keys |
| `GET /health` | API status plus Redis connectivity |
| `DELETE /cache` | Drop every cached product |
| `DELETE /stats` | Reset the hit / miss counters |

## Prerequisites

- Docker and Docker Compose
- `curl` (for testing)
- Port 8080 free — the sibling labs in this folder also publish on 8080,
  so run one lab at a time

## Run

Start the stack with the helper script (resets any previous run, then waits
until the API reports Redis as reachable):

```bash
./run.sh
```

Or manually:

```bash
docker compose up -d --build
docker compose ps
docker compose logs -f api
```

Then open <http://localhost:8080/>: pick a product, press **Request** to see
it come back from the database (~1000 ms), press it again to see the same
data come back from Redis in a millisecond or two, and press **Clear cache**
to make it slow again.

## Test

Run the automated checks (requires the stack to already be running via
`./run.sh`):

```bash
./test.sh
```

The script starts from an empty cache and zeroed counters, then asserts
that the first request is a `MISS` from the database, the second is a `HIT`
from Redis, the hit is at least 4x faster, the cached key carries a TTL, a
different product id is a separate key that misses on its own, the counters
read 1 hit / 2 misses, and a flushed cache sends the next request back to
the database. It finishes by printing the cached keys and Redis's own
`keyspace_hits` / `keyspace_misses`.

### Manual tests

```bash
# Slow: the cache is cold, so this pays for the database lookup
curl -s http://localhost:8080/product/1

# Fast: same request, now served from Redis
curl -s http://localhost:8080/product/1

# The cache decision is also in the response headers
curl -sI http://localhost:8080/product/1 | grep -i x-cache

# Hit rate so far
curl -s http://localhost:8080/stats

# Start over
curl -s -X DELETE http://localhost:8080/cache
```

Watch a key expire by itself (`CACHE_TTL` is 30 s):

```bash
curl -s http://localhost:8080/product/3 >/dev/null
docker compose exec redis redis-cli TTL product:3   # counts down
# wait 30 seconds
docker compose exec redis redis-cli GET product:3   # (nil) — expired
```

### Inspect Redis directly

```bash
docker compose exec redis redis-cli KEYS 'product:*'
docker compose exec redis redis-cli GET product:1
docker compose exec redis redis-cli TTL product:1
docker compose exec redis redis-cli INFO stats | grep keyspace
docker compose exec redis redis-cli MONITOR      # live stream of every command
```

`MONITOR` is the best way to *see* cache-aside working: run it in one
terminal, then send the same request twice in another. The miss shows a
`GET` followed by a `SETEX`; the hit shows only the `GET`.

## Stop / cleanup

```bash
docker compose down
```

Nothing survives the teardown — Redis is started with persistence off,
because a cache should always be safe to lose.

## Notes

- **TTL is the whole safety net.** `SETEX` writes the key with a 30 s
  expiry, so stale data corrects itself without any invalidation logic.
  Raise `CACHE_TTL` in `compose.yaml` for a higher hit rate and staler
  reads; lower it for the opposite. That trade-off is the entire design
  question in caching.
- **`allkeys-lru` is the eviction policy.** Redis is capped at 64 MB in
  `compose.yaml`; when it fills, the least recently used key is dropped to
  make room. Without a policy Redis would instead start refusing writes —
  correct for a database, wrong for a cache.
- **Persistence is off** (`--save "" --appendonly no`). A cache that
  survives a restart is usually a liability: it comes back full of data
  nobody validated. Losing it just causes one round of misses.
- **Two different hit counters exist.** `/stats` counts *application*
  decisions (did my code find the key?), while `redis-cli INFO stats`
  reports `keyspace_hits`/`keyspace_misses` — Redis's own view of every
  key lookup, including the ones this lab's stats endpoints make. They
  will not match, and understanding why is the point.
- **The miss path is the expensive one.** A cache does not make anything
  faster; it makes *repeats* faster. If every request is for a different
  key, you pay the slow lookup every time and Redis is pure overhead.
- **`KEYS` is used in `/stats` because this lab has three keys.** Against a
  real Redis it blocks the server while it scans every key — use `SCAN`.
- **Flask's development server** runs the API. It is fine for a lab and
  never for production; a real deployment would use gunicorn or uvicorn.
- After editing `api/app.py`, rebuild with
  `docker compose up -d --build api`.
