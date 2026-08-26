# Cloud Serverless Lab — Cloudflare Workers

The hands-on companion to [D6.cloud-serverless.md](../../D6.cloud-serverless.md),
built around section 8 (Cloudflare Workers) and section 12 (common patterns),
using your real domain: **sokhin.site**.

Like the Vultr lab, this one touches real infrastructure — in this case, a
live domain's nameservers. Unlike the Vultr lab, **everything here fits in
Cloudflare's free tier**: no billing starts, and there is nothing to
"destroy" for cost reasons. `99-cleanup.sh` exists to tidy up, not to stop
a bill.

## What you build

```text
   your laptop
        |
        |  Cloudflare API v4  (curl + jq)   +   wrangler (via npx)
        v
   +-----------------------------------------------------+
   |  Cloudflare                                         |
   |                                                      |
   |   zone: sokhin.site                                  |
   |      |                                                |
   |      +-- existing records, imported as-is            |
   |      |     (your current A record, www, etc.)         |
   |      |                                                |
   |      +-- edge.sokhin.site  --Custom Domain-->  Worker |
   |                                                  |    |
   |                                                  v    |
   |                                        Workers KV      |
   |                                        (rate limiter)  |
   +-----------------------------------------------------+
        ^
        |  the nameserver change, done by hand at Hostinger
   Hostinger (registrar for sokhin.site)
```

The root domain and everything currently on it are left exactly as they
are. This lab only ever adds one new subdomain: `edge.sokhin.site`.

## Before you start: what sokhin.site looks like today

`./01-check.sh` queries this itself and saves a snapshot, but it's worth
knowing going in: **sokhin.site is not a blank domain.** It already has a
live `A` record. If that points at a server you're using — including a VM
from the [Vultr lab](../5-cloud-providers/) — Cloudflare's import (which
this lab uses deliberately) should carry it over automatically, but you
are the one who has to confirm that before you trust the domain again.
This is exactly why `03-wait-for-activation.sh` diffs before-and-after.

## Prerequisites

- A Cloudflare account (free tier is enough)
- Your Hostinger login, to change nameservers by hand — **this cannot be
  scripted.** No script here has your Hostinger credentials, and a live
  domain's nameservers are not something to automate even if it could be.
- A Cloudflare API token from
  <https://dash.cloudflare.com/profile/api-tokens> — "Create Custom Token"
  with:

  | Resource | Permission |
  |---|---|
  | Account &rarr; Workers Scripts | Edit |
  | Account &rarr; Workers KV Storage | Edit |
  | Account &rarr; Workers Routes | Edit |
  | Zone &rarr; Zone | Edit |
  | Zone &rarr; DNS | Edit |

  Zone Resources: use "All zones from an account" for the first run (the
  zone doesn't exist yet), then you can narrow the token to just
  sokhin.site afterward if you want.
- Node.js (for `npx wrangler`) — anything recent works, `wrangler` is
  fetched on demand and not pinned to a version in this lab
- `curl`, `jq`

## Setup

```bash
cp .env.example .env
```

Edit `.env` and paste your API token. `.env` and `state/` are gitignored —
**never commit either.** So is the generated `worker/wrangler.toml`, since
`04-deploy-worker.sh` writes real ids into it.

## The scripts

| Script | Does | Reversible? |
|---|---|---|
| `01-check.sh` | Validates the token, snapshots sokhin.site's current DNS | read-only |
| `02-add-zone.sh` | Adds sokhin.site to Cloudflare, imports existing DNS, prints the nameservers to enter at Hostinger | creates a zone; the nameserver change itself is manual |
| *(you, at Hostinger)* | Change nameservers to the two Cloudflare gave you | **do this yourself, carefully** |
| `03-wait-for-activation.sh` | Polls until Cloudflare confirms the change, diffs records before/after | read-only |
| `04-deploy-worker.sh` | Creates a KV namespace, renders `wrangler.toml`, deploys the Worker | free; can re-run any time |
| `05-route-domain.sh` | Attaches the Worker to `edge.sokhin.site` via Workers Custom Domains | adds one subdomain, nothing else |
| `06-verify.sh` | Tests both the `workers.dev` URL and the custom domain, including the rate limiter | read-only |
| `99-cleanup.sh` | Removes the custom domain, the Worker, and the KV namespace | leaves the zone and your original DNS alone |

Run in order:

```bash
./01-check.sh
./02-add-zone.sh
# ... change nameservers at Hostinger, using the two it just printed ...
./03-wait-for-activation.sh
./04-deploy-worker.sh          # doesn't need the zone active — try it early
./05-route-domain.sh           # needs the zone active
./06-verify.sh
```

`02` and `99` both stop and ask before doing anything. Every id created
along the way lands in `state/lab.env`; don't delete that file while any
of this is live, since `99-cleanup.sh` reads it to know what to remove.

## What maps to which lesson section

| Lesson | In this lab |
|---|---|
| 1–3 What serverless is, when to use it | The Worker itself: no VM, no provisioning, `06-verify.sh`'s timing test shows no cold start |
| 8 Cloudflare Workers | `worker/src/index.js` — the exact `fetch(request, env, ctx)` shape from the lesson |
| 9 Comparison table | `/api/whoami` reports the data center that answered you — the "<100ms, 200+ locations" claim, made checkable |
| 10 Your accounts: Vercel & Cloudflare | This lab is the Cloudflare half; nothing here needs Vercel |
| 12 Pattern 3: rate limiting | `/api/limited`, implemented with `env.RATE_LIMIT_KV`, exactly as the lesson's example |
| 13 Debugging & monitoring | `wrangler tail` (see Exercises) is the lesson's real-time log command |
| 14 Cost | Everything here stays under the 100k requests/day free tier |

## Exercises

```bash
# Watch the Worker's logs live while you hit it from another terminal
cd worker && npx wrangler@latest tail
```

```bash
# The lesson's own example, verbatim
curl "https://edge.sokhin.site/api/hello?name=Sokhin"

# Which of Cloudflare's 200+ data centers answered you
curl https://edge.sokhin.site/api/whoami

# Trip the rate limiter on purpose
for i in $(seq 1 12); do curl -s -o /dev/null -w '%{http_code}\n' https://edge.sokhin.site/api/limited; done
```

Then try changing something and redeploying:

1. Edit `worker/src/index.js` — change the rate limit from 10 to 3, or add
   a new route.
2. `cd worker && npx wrangler@latest deploy`
3. Re-run `./06-verify.sh`.

Notice there is no build step, no container, and no server to restart —
you edited a function and it's live everywhere in seconds.

## Notes

- **Why Custom Domains instead of a manual DNS record + Worker Route.**
  Older guides have you create a dummy `A` record pointed at a throwaway
  IP and a separate Worker Route matching its hostname. Workers Custom
  Domains (used in `05-route-domain.sh`, via `PUT
  /accounts/:id/workers/domains`) does both steps — and the TLS
  certificate — as one API call. It is Cloudflare's current recommended
  approach and there's no reason to hand-roll the older pattern.
- **`jump_start: true` in `02-add-zone.sh`** is what makes this safe to run
  on a domain that already has real records. It tells Cloudflare to scan
  Hostinger's current DNS and copy what it finds into the new zone before
  you ever touch a nameserver. It's a best-effort scan, not a guarantee —
  which is exactly why `03-wait-for-activation.sh` shows you a before/after
  diff instead of just declaring success.
- **Nameserver propagation time varies.** `03-wait-for-activation.sh` gives
  up after 15 minutes and tells you to re-run it later; that is normal and
  not a failure of anything. There is no harm in checking once a day until
  it flips to active.
- **`WORKER_HOSTNAME` is always a subdomain, never the bare domain.** The
  root `sokhin.site` and whatever answers there today are never reassigned
  to the Worker. If you want the Worker to eventually front the whole
  domain, that's a deliberate later decision — change `WORKER_SUBDOMAIN` to
  an empty value and re-run `05`, only once you're sure that's what you want.
- **No cold start, concretely.** The lesson claims Cloudflare Workers never
  cold-start; `06-verify.sh` fires 5 sequential requests and prints each
  timing so you can see the first one is not the outlier it would be on
  Lambda or Azure Functions.
- **KV eventual consistency.** `RATE_LIMIT_KV` reads can occasionally see a
  value a few seconds stale across different data centers — fine for a rate
  limiter (worst case, a client gets one or two extra requests), wrong for
  anything that needs a single source of truth. That trade-off is KV's, not
  a bug in this Worker.
- **Cleanup deliberately stops short of undoing everything.** `99-cleanup.sh`
  removes what it created but leaves sokhin.site on Cloudflare's
  nameservers, because that part is genuinely useful to keep (free CDN and
  SSL on your existing A record) and reverting it means another manual
  nameserver change at Hostinger for no real benefit.
