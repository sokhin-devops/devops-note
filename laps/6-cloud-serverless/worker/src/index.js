// The Worker this lab deploys. Every route below maps to a numbered section
// of D6.cloud-serverless.md — see the README's table for which is which.
//
// No build step, no framework: this is exactly the module-worker shape from
// lesson section 8, extended with the rate-limiting pattern from section 12.

const RATE_LIMIT = 10;             // requests
const RATE_LIMIT_WINDOW = 60;      // seconds

function json(data, init = {}) {
  return new Response(JSON.stringify(data, null, 2), {
    ...init,
    headers: { "content-type": "application/json", ...(init.headers || {}) },
  });
}

function landingPage(request) {
  const cf = request.cf || {};
  return `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Cloudflare Worker</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
  :root {
    --accent: #f6821f;
    --accent-dark: #d16b0f;
    --bg-1: #fff7ed;
    --bg-2: #ffedd5;
    --ink: #1e293b;
    --muted: #64748b;
    --card: #ffffff;
    --line: #e2e8f0;
    --surface: #f8fafc;
  }
  * { box-sizing: border-box; }
  body {
    margin: 0; min-height: 100vh; display: flex; align-items: center;
    justify-content: center; padding: 2rem 1rem;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    background: linear-gradient(135deg, var(--bg-1), var(--bg-2));
    color: var(--ink);
  }
  .card {
    background: var(--card); border-radius: 20px; padding: 2.75rem 3rem;
    box-shadow: 0 20px 50px -12px rgba(246, 130, 31, 0.28);
    width: 100%; max-width: 560px; text-align: center;
  }
  .badge {
    display: inline-flex; align-items: center; justify-content: center;
    width: 64px; height: 64px; border-radius: 16px;
    background: linear-gradient(135deg, var(--accent), var(--accent-dark));
    color: white; font-size: 1.75rem; margin-bottom: 1.25rem;
  }
  h1 { margin: 0 0 0.5rem; font-size: 1.75rem; letter-spacing: -0.01em; }
  p { margin: 0.25rem 0; color: var(--muted); line-height: 1.5; }
  .facts {
    margin-top: 1.75rem; border: 1px solid var(--line); border-radius: 14px;
    overflow: hidden; text-align: left;
  }
  .fact {
    display: flex; align-items: baseline; justify-content: space-between;
    gap: 1rem; padding: 0.7rem 1rem; font-size: 0.88rem;
    background: var(--surface); border-bottom: 1px solid var(--line);
  }
  .fact:last-child { border-bottom: 0; }
  .fact .k { color: var(--muted); }
  .fact .v { font-weight: 600; font-variant-numeric: tabular-nums; }
  .routes {
    margin-top: 1.25rem; padding: 1rem; border-radius: 14px;
    background: var(--surface); border: 1px solid var(--line);
    font-size: 0.82rem; line-height: 1.9; color: var(--muted);
    text-align: left; white-space: pre; overflow-x: auto;
  }
  .routes strong { color: var(--accent-dark); }
  .tag {
    display: inline-block; margin-top: 1.5rem; padding: 0.35rem 0.9rem;
    border-radius: 999px; background: var(--bg-1); color: var(--accent-dark);
    font-size: 0.8rem; font-weight: 600; letter-spacing: 0.02em;
  }
</style>
</head>
<body>
  <div class="card">
    <div class="badge">&#9889;</div>
    <h1>Running at the edge</h1>
    <p>No server was provisioned for this response. Cloudflare ran this
       code at the data center nearest to you, with no cold start.</p>

    <div class="facts">
      <div class="fact"><span class="k">Data center</span><span class="v">${cf.colo || "unknown"}</span></div>
      <div class="fact"><span class="k">Country</span><span class="v">${cf.country || "unknown"}</span></div>
      <div class="fact"><span class="k">cf-ray</span><span class="v">${request.headers.get("cf-ray") || "n/a"}</span></div>
    </div>

    <div class="routes"><strong>GET  /api/hello?name=X</strong>   JSON greeting
<strong>GET  /api/whoami</strong>          which data center answered you
<strong>GET  /api/limited</strong>         10 requests / 60s per IP, via KV
<strong>GET  /health</strong>              plain "ok"</div>

    <span class="tag">TRY /api/whoami NEXT</span>
  </div>
</body>
</html>`;
}

async function handleHello(url) {
  const name = url.searchParams.get("name") || "World";
  return json({ message: `Hello, ${name}!` });
}

async function handleWhoami(request) {
  const cf = request.cf || {};
  return json({
    colo: cf.colo || null,
    country: cf.country || null,
    city: cf.city || null,
    cf_ray: request.headers.get("cf-ray") || null,
    your_ip: request.headers.get("cf-connecting-ip") || null,
  });
}

// The rate-limiting middleware pattern from lesson section 12, pattern 3.
async function handleLimited(request, env) {
  if (!env.RATE_LIMIT_KV) {
    return json(
      { error: "RATE_LIMIT_KV is not bound — see 04-deploy-worker.sh" },
      { status: 500 }
    );
  }

  const ip = request.headers.get("cf-connecting-ip") || "unknown";
  const key = `rate-limit:${ip}`;

  const current = parseInt((await env.RATE_LIMIT_KV.get(key)) || "0", 10);

  if (current >= RATE_LIMIT) {
    return json(
      {
        error: "rate limit exceeded",
        limit: RATE_LIMIT,
        window_seconds: RATE_LIMIT_WINDOW,
      },
      { status: 429, headers: { "retry-after": String(RATE_LIMIT_WINDOW) } }
    );
  }

  await env.RATE_LIMIT_KV.put(key, String(current + 1), {
    expirationTtl: RATE_LIMIT_WINDOW,
  });

  return json({
    ok: true,
    count_this_window: current + 1,
    limit: RATE_LIMIT,
    window_seconds: RATE_LIMIT_WINDOW,
  });
}

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);

    if (url.pathname === "/") {
      return new Response(landingPage(request), {
        headers: { "content-type": "text/html; charset=utf-8" },
      });
    }
    if (url.pathname === "/health") {
      return new Response("ok\n", { headers: { "content-type": "text/plain" } });
    }
    if (url.pathname === "/api/hello") {
      return handleHello(url);
    }
    if (url.pathname === "/api/whoami") {
      return handleWhoami(request);
    }
    if (url.pathname === "/api/limited") {
      return handleLimited(request, env);
    }

    return json({ error: "not found", path: url.pathname }, { status: 404 });
  },
};
