# UFW Firewall Lab

A simple professional Docker-based lab for learning how a host-based
firewall (`ufw`, the Uncomplicated Firewall) filters traffic by source IP.

## Architecture

```text
client-trusted (172.28.0.20)  --allow-->  +-------------------+
                                           | protected-server  |
                                           |    ufw + nginx    |
                                           | 172.28.0.10 : 80  |
client-blocked (172.28.0.30)  --DENY-->   +-------------------+
```

`protected-server` runs Nginx behind `ufw` with a `deny incoming`
default policy and a single allow rule for one trusted source IP
(`client-trusted`, 172.28.0.20). Everything else is silently denied,
including `client-blocked` (172.28.0.30). All three containers sit on
a custom bridge network (`172.28.0.0/24`) with fixed IPs so the
firewall rule has a stable address to match against.

`ufw` is a friendly front end over `iptables`: the rules you write in
`ufw` syntax are compiled into `iptables` chains (`ufw-user-input`,
`ufw-before-input`, ...), which is why the container still needs
netfilter capabilities.

## Prerequisites

- Docker and Docker Compose
- The `protected-server` image needs `NET_ADMIN`/`NET_RAW` capabilities
  so `ufw` can program netfilter inside the container (already set in
  `compose.yaml`)

## Run

Build and start the lab:

```bash
./run.sh
```

Or manually:

```bash
docker compose up -d --build
docker compose ps
docker compose logs -f protected-server
```

## Test

Run the automated checks (requires the lab to already be running via
`./run.sh`):

```bash
./test.sh
```

This prints the active `ufw` rules on `protected-server`, then confirms
`ufw` is enabled, `client-trusted` can reach it, and `client-blocked`
cannot.

### Manual tests

```bash
# Allowed: trusted client reaches the server
docker exec client-trusted curl -v http://protected-server

# Blocked: this will hang until it times out (deny = drop, not reject)
docker exec client-blocked curl -v --max-time 5 http://protected-server
```

### Inspect the firewall rules

```bash
# ufw's own view
docker exec protected-server ufw status verbose
docker exec protected-server ufw status numbered

# the iptables chains ufw generated underneath
docker exec protected-server iptables -L -n | less
```

## Stop / cleanup

```bash
docker compose down
```

## Notes

- `protected-server` is published to the host at `http://localhost:8080`,
  but visiting it from your host/browser will also hang and time out —
  after Docker's NAT the source IP isn't `172.28.0.20`, so the same
  firewall rule denies it too. That's expected; use the `docker exec`
  commands above to test as the trusted/blocked containers.
- `deny` vs `reject`: `ufw`'s `deny` drops packets with no response at
  all (the connection just hangs until the client's own timeout).
  Adding an explicit `ufw reject 80/tcp` after the allow rule in
  `protected-server/firewall.sh` would instead return an immediate
  "connection refused" — try it and compare the client behavior.
- You never have to allow loopback or established connections by hand
  the way you would with raw `iptables`: `ufw`'s built-in
  `/etc/ufw/before.rules` already accepts `lo` and
  `ESTABLISHED,RELATED` traffic before your rules are consulted.
- Running `ufw` inside a container needs a few adjustments, all done in
  the `Dockerfile`: the legacy `iptables` backend, `IPV6=no`, and
  disabling `ufw`'s `sysctl` tuning (`/proc/sys` is read-only in an
  unprivileged container). `firewall.sh` also runs `ufw logging off`,
  because the `LOG` target is usually unavailable in container kernels.
- `ufw --force enable` is used instead of `ufw enable` since the plain
  command prompts for confirmation and there is no TTY at startup.
- `firewall.sh` runs once at container startup (via `entrypoint.sh`) and
  begins with `ufw --force reset`, so restarts are idempotent. To change
  the trusted IP, edit `TRUSTED_IP` in `compose.yaml` and recreate the
  container: `docker compose up -d --build --force-recreate`.
