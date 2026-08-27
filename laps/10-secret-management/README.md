# Secret Management Lab — HashiCorp Vault

The hands-on companion to [D10.secret-management.md](../../D10.secret-management.md).

Free and fully local — Vault in dev mode, a real Postgres, and a toolbox
container, all in Docker. No cloud account, no cost, no `99-destroy.sh`
stopping a bill.

## What you build

```text
client (vault CLI + psql + curl + jq)
     │
     ├──────────────→ vault    (dev mode, auto-unsealed, root token: labroot)
     │                    │
     │                    │ database secrets engine manages real roles in →
     │                    ▼
     └──────────────→ postgres (appdb, bootstrapped as user 'vaultadmin')

app (started separately, once a secret exists — section 17)
     │
     └── fetches kv/blog/database from vault at boot, then connects to
         postgres using exactly what it fetched
```

## Prerequisites

- Docker and Docker Compose

Nothing else — the Vault CLI lives inside `client` and `app`, copied from
HashiCorp's own official image rather than a hand-downloaded release zip.

## Setup & run

```bash
./00-check.sh              # .env with a random Postgres password, brings up vault+postgres+client
./01-kv-secrets.sh         # KV v2: put/get/versions/list/delete/undelete (lesson section 11)
./02-dynamic-db-secrets.sh # dynamic Postgres credentials, minted and proven twice (section 12)
./03-policies.sh           # a read-only token, proven to be denied everything else (section 13)
./04-docker-app.sh         # a container that fetches its own secret at boot (section 17)
./05-verify.sh             # asserts all of the above actually happened
./99-down.sh               # tear down (nothing was billed)
```

Vault's UI is reachable from your own browser once `./00-check.sh` has
run: <http://localhost:8200/ui> (token: `labroot`).

## What maps to which lesson section

| Lesson | In this lab |
|---|---|
| 1–2 The problem, and the shape of a real solution | The `app` container never has a password in its image, its compose config, or an `.env` — only in Vault |
| 9 How Vault works, seal/unseal | Dev mode auto-unseals — `./00-check.sh` polls `vault status` for real |
| 10 Dev mode | `compose.yaml`'s `vault` service — `VAULT_DEV_ROOT_TOKEN_ID`, `VAULT_DEV_LISTEN_ADDRESS`, the lesson's own docker-compose pattern (section 17) |
| 11 KV v2: put/get/versions/list/delete/undelete | `./01-kv-secrets.sh`, run command-for-command |
| 12 Dynamic database secrets | `./02-dynamic-db-secrets.sh` — proven against a real Postgres, not just a Vault API response |
| 13 Policies | `policies/app-policy.hcl`, `./03-policies.sh` — three denials proven, not just described |
| 17 Docker + Vault | `app/entrypoint.sh`, matching the lesson's `docker-entrypoint.sh` example almost line for line |
| 15, 16, 18 Terraform / Ansible / Kubernetes integration | Documented below, deliberately not wired up — see Notes |

## Exercises

```bash
# Watch every request Vault serves, live
docker compose exec client sh -c "VAULT_ADDR=http://vault:8200 VAULT_TOKEN=labroot vault audit enable file file_path=/tmp/audit.log"
docker compose exec vault cat /tmp/audit.log | tail -20

# Mint a credential and watch it expire on its own (default_ttl is 1h in
# this lab — shorten it to watch this happen quickly)
docker compose exec client sh -c "
  VAULT_ADDR=http://vault:8200 VAULT_TOKEN=labroot \
  vault write database/roles/readonly db_name=postgresql \
    creation_statements='CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '\''{{password}}'\'' IN ROLE readonly;' \
    default_ttl=1m max_ttl=5m
"

# Try the exact denial from ./03-policies.sh yourself, by hand
docker compose exec client sh
export VAULT_ADDR=http://vault:8200
export VAULT_TOKEN=$(VAULT_TOKEN=labroot vault token create -policy=app-policy -field=token)
vault kv get kv/blog/database      # works
vault kv put kv/blog/other x=y     # permission denied
```

## Stop / cleanup

```bash
./99-down.sh
```

Vault's dev mode stores everything in memory — tearing the container down
erases every secret, policy, and lease this lab created. That's expected,
and exactly why dev mode is never appropriate outside of learning.

## Notes

- **This lab uses HashiCorp's real, current major version, `hashicorp/vault:2.0`** —
  not the `1.14.0` the lesson's own examples reference. Vault's version line
  has moved on since the lesson was written; basic KV v2 and the database
  secrets engine used here are long-stable surfaces unaffected by that,
  but it's worth knowing the lesson's exact output examples (version
  numbers, some CLI banners) won't match what you see.
- **`connection_url` needs `?sslmode=disable` explicitly.** This Postgres
  has no TLS certificate configured, and the Go database driver Vault's
  postgresql plugin uses does not fall back the way `psql`'s own client
  does — omitting this parameter makes `database/config/postgresql` fail
  outright, not just warn.
- **KV v2 policies need a `data/` segment the CLI hides from you.**
  `vault kv get kv/blog/database` looks like it reads the path
  `kv/blog/database`, but KV v2's actual API — and therefore any policy
  governing it — operates on `kv/data/blog/database`. Write a policy
  against the bare path from `vault kv get` and it silently protects
  nothing. `policies/app-policy.hcl` uses the correct `kv/data/...` form;
  this is one of the most commonly hit Vault surprises in the wild.
- **`app` doesn't use a scoped token, on purpose.** It runs with the same
  `labroot` root token as every setup script, which is exactly the
  anti-pattern lesson section 19 warns against ("don't share tokens,"
  "use least privilege"). Giving `app` its own scoped token at boot would
  mean generating that token *before* the container starts and getting it
  in via a mounted file — a real pattern, but one more moving part than
  this lab needs when `./03-policies.sh` already proves least-privilege
  enforcement rigorously and in isolation. Treat `app` as "the shape of
  fetch-then-connect," and `./03-policies.sh` as "how access control
  actually works" — don't conflate the two.
- **Terraform, Ansible, and Kubernetes integration (lesson sections 15, 16,
  18) are documented, not wired up here.** The Terraform Vault provider
  and Ansible's Vault lookup both need a Vault address reachable from
  wherever they run — fine for `laps/7-lac-provisioning` and
  `laps/8-configuration-management` if they're taught to reach into this
  lab's Docker network, but that couples three labs' lifecycles together
  for a secondary point the lesson itself treats as an appendix, not the
  core lesson. One correction worth carrying forward if you do wire this
  up yourself: the lesson's Ansible example uses a lookup plugin named
  bare `hashi_vault` — that name has moved to the
  `community.hashi_vault` collection, and the specific lookup for a KV v2
  path is now `community.hashi_vault.vault_kv2_get`
  (`ansible-galaxy collection install community.hashi_vault`, plus the
  `hvac` Python package). Copying the lesson's exact lookup name today
  would fail to resolve.
