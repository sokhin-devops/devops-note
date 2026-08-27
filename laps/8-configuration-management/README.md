# Configuration Management Lab — Ansible

The hands-on companion to [D8.configuration-management.md](../../D8.configuration-management.md).

Free and fully local — three Docker containers standing in for "real
servers," no cloud account, no cost, no `99-destroy.sh` stopping a bill.

## Why Docker containers, and why they're unusual ones

Ansible's control machine needs SSH and Python — Windows has neither
natively, which is why `controller` is itself a container. That part is
ordinary.

The three targets are not. The lesson's `service`/`systemd` module examples
assume a real init system managing real services. A default Docker
container has none — it runs one process as PID 1, so `service: name=nginx
state=started` has nothing to talk to. Rather than fake that with a
`command`/`shell` workaround (and quietly teach the wrong module for the
job), `web1`, `web2`, and `db1` run **real systemd as PID 1**, using
[geerlingguy/docker-ubuntu2404-ansible](https://github.com/geerlingguy/docker-ubuntu2404-ansible)
— an image purpose-built for exactly this (geerlingguy is the same "trusted
contributor" the lesson names for pre-built Galaxy roles) — plus the
`privileged: true` / `cgroup: host` / `/sys/fs/cgroup` mount the image's
own docs specify. Its maintainer is explicit that this is for **testing,
not production**: "the settings and configuration used may not be suitable
for a secure and performant production environment." That warning is the
whole reason this pattern stays inside three disposable lab containers and
nowhere near a real server.

## What you build

```text
controller (ansible-core + ssh, no special privileges)
     │
     │  SSH, over the "labnet" Docker network
     │
     ├──────────────→ web1   (real systemd, nginx + templated page)
     │
     ├──────────────→ web2   (same role, different host_vars)
     │
     └──────────────→ db1    (gets the "common" role only)
```

Same `[webservers]` / `[databases]` split as the lesson's own first
inventory example (section 7) — just pointed at containers instead of IPs.

## Prerequisites

- Docker and Docker Compose
- `ssh-keygen` (Git Bash on Windows has it)

Nothing else — Ansible itself lives inside `controller`, not on your host.

## Setup & run

```bash
./00-check.sh         # generates a throwaway SSH keypair + vault password
./01-up.sh            # builds and starts all four containers
./02-vault-setup.sh   # encrypts group_vars/all/vault.yml (one-time)
./03-ping.sh          # connectivity + ad-hoc commands (lesson section 8)
./04-playbook.sh      # runs playbooks/site.yml, then re-runs it to prove idempotency
./05-verify.sh        # asserts what actually happened
./99-down.sh          # tears the containers down (nothing was billed)
```

First boot is the slow step — real systemd coming up inside a container
takes longer than a normal container start. `./01-up.sh` polls for it.

## What maps to which lesson section

| Lesson | In this lab |
|---|---|
| 2 Agentless / push model | `controller` SSHes out; nothing is installed on the targets ahead of time except SSH+Python (already in the base image) |
| 7 Inventory, `[group]` syntax | `inventory/hosts.ini` — the lesson's own `[webservers]`/`[databases]` split |
| 7 Playbook, roles, handlers | `playbooks/site.yml`, `roles/common`, `roles/nginx`, `roles/nginx/handlers/main.yml` |
| 7 group_vars / host_vars | `group_vars/all/main.yml`, `host_vars/web1.yml` vs `host_vars/web2.yml` — same group, different values |
| 7 Jinja2 templates | `roles/nginx/templates/nginx.conf.j2`, `roles/app/templates/index.html.j2` |
| 7 Facts | `roles/common/tasks/main.yml`'s `debug` task, and `ansible_os_family`/`ansible_distribution` used throughout |
| 7 Conditionals (`when`) | `roles/app/tasks/main.yml` — one task that runs, one that's built to always skip, so you see both outcomes |
| 7 Loops | `roles/app/tasks/main.yml`'s `demo_users` loop |
| 7 Vault | `group_vars/all/vault.yml` + `./02-vault-setup.sh`, run for real |
| 8 Ad-hoc commands | `./03-ping.sh` |
| 9 Idempotency | `./04-playbook.sh` runs the playbook twice and checks the second run's `changed` count |
| 12 pre_tasks / roles / post_tasks | `playbooks/site.yml`'s webservers play |

## Exercises

```bash
# Ansible's own view of the inventory
docker compose exec controller ansible-inventory --graph

# Ad-hoc, straight from the lesson's cheat sheet
docker compose exec controller ansible webservers -m shell -a "uptime"

# Watch systemd actually manage the service
docker compose exec web1 systemctl status nginx
docker compose exec controller ansible-playbook playbooks/site.yml --vault-password-file .vault_pass -v

# Break idempotency on purpose, then fix it
docker compose exec web1 rm /etc/nginx/nginx.conf
docker compose exec controller ansible-playbook playbooks/site.yml --vault-password-file .vault_pass
# -> that one task shows "changed", the rest still show "ok"

# See a task get skipped for real
docker compose exec controller ansible-playbook playbooks/site.yml --vault-password-file .vault_pass -v \
  | grep -A1 "RedHat-family-only"
```

Edit `host_vars/web2.yml`'s `deploy_env`, re-run `./04-playbook.sh`, and
`./05-verify.sh` should show you the new value came through.

## Stop / cleanup

```bash
./99-down.sh
```

Nothing here costs money, so this is just container cleanup — `./ssh/`,
`.vault_pass`, and the now-encrypted `group_vars/all/vault.yml` are left in
place, so `./01-up.sh` picks up exactly where you left off.

## Notes

- **`--privileged` and `cgroup: host` are real, broad grants** — contained
  to three throwaway containers inside Docker Desktop's own VM, never
  exposed to your host directly, and never something to reuse for an
  actual application container. It's the documented, maintainer-endorsed
  way to run genuine systemd in Docker; nothing about it is specific to
  this lab.
- **Compose's actual key is `cgroup: host`, not `cgroupns_mode: host`.**
  The latter doesn't exist in the compose-spec schema — confirmed by
  checking the schema directly while building this lab, after search
  results surfaced old GitHub issues claiming Compose had no equivalent
  key at all. Getting this one key wrong would have silently defeated the
  entire systemd setup.
- **A literal `{{ }}` inside a Jinja2 template is a syntax error**, even
  inside what looks like a harmless comment — Jinja2 parses the whole file
  for `{{`/`{%` delimiters and doesn't know nginx's `#` means "ignore this
  line." An early draft of `nginx.conf.j2` had exactly this bug in its own
  explanatory comment; the fix was to describe the syntax in words instead
  of writing it literally.
- **`deploy_env`, not `environment`.** `environment` is an Ansible
  reserved keyword (a task/play attribute for setting OS environment
  variables for that task's execution) — shadowing it with a same-named
  ordinary variable is a well-known footgun `ansible-lint` specifically
  flags. Real projects hit this; this lab avoids it from the start.
- **The private key is copied off its bind mount before use**, in both
  `controller/entrypoint.sh` and `managed-node/entrypoint.sh`, rather than
  pointed at directly. Bind-mounted files on Windows/Docker Desktop don't
  reliably carry the `0600` permissions SSH insists on, and SSH refuses a
  key file it considers "too open" — copying it into the container's own
  filesystem and `chmod`-ing it there sidesteps the mismatch entirely.
- **`ansible_python_interpreter` is set explicitly** in `inventory/hosts.ini`
  even though Ansible can usually auto-detect it, because the lesson's own
  example does the same — it avoids a discovery warning and a full-file
  scan of the remote `$PATH` on every single run.
- **This lab's `deploy_env` has no default anywhere** — `roles/app`'s
  `assert` task fails loudly if a host is missing its `host_vars` file,
  on purpose. The alternative (a default that silently deploys as the
  wrong environment) is worse than a playbook that refuses to run.
