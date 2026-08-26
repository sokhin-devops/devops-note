"""A tiny API that puts Redis in front of a deliberately slow 'database'.

Every product lookup follows the classic cache-aside pattern:

    look in Redis -> hit?  return it immediately
                  -> miss? query the slow store, write the result
                            into Redis with a TTL, then return it
"""

import json
import os
import time

import redis
from flask import Flask, jsonify, send_from_directory

REDIS_HOST = os.environ.get("REDIS_HOST", "redis")
REDIS_PORT = int(os.environ.get("REDIS_PORT", "6379"))
CACHE_TTL = int(os.environ.get("CACHE_TTL", "30"))
SLOW_QUERY_MS = int(os.environ.get("SLOW_QUERY_MS", "1000"))

CACHE_PREFIX = "product:"
HITS_KEY = "stats:hits"
MISSES_KEY = "stats:misses"

# Stands in for a real database table
PRODUCTS = {
    "1": {"id": "1", "name": "Mechanical Keyboard", "price": 89.00},
    "2": {"id": "2", "name": "27\" Monitor", "price": 249.00},
    "3": {"id": "3", "name": "Noise Cancelling Headphones", "price": 179.50},
}

app = Flask(__name__, static_folder="static", static_url_path="")
cache = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, decode_responses=True)


def slow_database_lookup(product_id):
    """The expensive call the cache exists to avoid."""
    time.sleep(SLOW_QUERY_MS / 1000.0)
    return PRODUCTS.get(product_id)


@app.get("/")
def index():
    return send_from_directory(app.static_folder, "index.html")


@app.get("/health")
def health():
    try:
        cache.ping()
    except redis.RedisError as exc:
        return jsonify(status="degraded", redis="unreachable", error=str(exc)), 503
    return jsonify(status="ok", redis="ok", cache_ttl_seconds=CACHE_TTL)


@app.get("/product/<product_id>")
def get_product(product_id):
    started = time.perf_counter()
    key = CACHE_PREFIX + product_id

    cached = cache.get(key)
    if cached is not None:
        # CACHE HIT: never touches the slow store
        cache.incr(HITS_KEY)
        product, status, source = json.loads(cached), "HIT", "redis"
    else:
        # CACHE MISS: pay the slow lookup once, then remember the answer
        cache.incr(MISSES_KEY)
        product = slow_database_lookup(product_id)
        if product is None:
            return jsonify(error="no such product", id=product_id), 404
        cache.setex(key, CACHE_TTL, json.dumps(product))
        status, source = "MISS", "database"

    elapsed_ms = round((time.perf_counter() - started) * 1000, 1)
    response = jsonify(
        product=product,
        cache=status,
        source=source,
        elapsed_ms=elapsed_ms,
        ttl_seconds=cache.ttl(key),
    )
    response.headers["X-Cache"] = status
    return response


@app.get("/stats")
def stats():
    hits = int(cache.get(HITS_KEY) or 0)
    misses = int(cache.get(MISSES_KEY) or 0)
    total = hits + misses
    return jsonify(
        hits=hits,
        misses=misses,
        total=total,
        hit_rate_percent=round(hits / total * 100, 1) if total else 0.0,
        # KEYS is fine for a lab this size; use SCAN against a real Redis
        cached_keys=len(cache.keys(CACHE_PREFIX + "*")),
        cache_ttl_seconds=CACHE_TTL,
    )


@app.delete("/cache")
def flush_cache():
    keys = cache.keys(CACHE_PREFIX + "*")
    removed = cache.delete(*keys) if keys else 0
    return jsonify(removed=removed)


@app.delete("/stats")
def reset_stats():
    cache.delete(HITS_KEY, MISSES_KEY)
    return jsonify(hits=0, misses=0)


if __name__ == "__main__":
    # Flask's built-in server: fine for a lab, never for production
    app.run(host="0.0.0.0", port=5000, threaded=True)
