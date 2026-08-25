# iptables Firewall Lab

A simple professional Docker-based lab for learning how a host-based
firewall (`iptables`) filters traffic by source IP.

## Architecture

```text
client-trusted (172.28.0.20)  --allow-->  +-------------------+
                                           | protected-server  |
                                           | iptables + nginx  |
                                           | 172.28.0.10 : 80  |
client-blocked (172.28.0.30)  --DROP-->   +-------------------+
```

`protected-server` runs Nginx behind an `iptables` INPUT chain that
only accepts port-80 traffic from one trusted source IP
(`client-trusted`, 172.28.0.20) and silently drops everything else,
including `client-blocked` (172.28.0.30). All three containers sit on
a custom bridge network (`172.28.0.0/24`) with fixed IPs so the
firewall rule has a stable address to match against.

## Prerequisites

- Docker and Docker Compose
- The `protected-server` image needs `NET_ADMIN`/`NET_RAW` capabilities
  to manage `iptables` inside the container (already set in
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

This prints the active `iptables` rules on `protected-server`, then
confirms `client-trusted` can reach it and `client-blocked` cannot.

### Manual tests

```bash
# Allowed: trusted client reaches the server
docker exec client-trusted curl -v http://protected-server

# Blocked: this will hang until it times out (DROP, not REJECT)
docker exec client-blocked curl -v --max-time 5 http://protected-server
```

### Inspect the firewall rules

```bash
docker exec protected-server iptables -L INPUT -n --line-numbers
```

## Stop / cleanup

```bash
docker compose down
```

## Notes

- `protected-server` is published to the host at `http://localhost:8080`,
  but visiting it from your host/browser will also hang and time out —
  the host's source IP isn't `172.28.0.20`, so the same firewall rule
  drops it too. That's expected; use the `docker exec` commands above
  to test as the trusted/blocked containers.
- `DROP` vs `REJECT`: this lab uses `DROP`, so blocked traffic gets no
  response at all (the connection just hangs until the client's own
  timeout). Swapping the final rule in
  `protected-server/firewall.sh` to `REJECT --reject-with tcp-reset`
  would instead return an immediate "connection refused" — try it and
  compare the client behavior.
- `firewall.sh` runs once at container startup (via `entrypoint.sh`).
  To change the trusted IP, edit `TRUSTED_IP` in `compose.yaml` and
  recreate the container: `docker compose up -d --build --force-recreate`.
