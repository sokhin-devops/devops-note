# Networking & Protocols Lab

The hands-on companion to [D4.networking-and-protocols.md](../../D4.networking-and-protocols.md).

The lesson explains DNS, IP, ports, TCP/UDP, HTTP, ICMP and Docker
networking one section at a time. This lab builds a small network where all
of them are real, so you can run the lesson's commands and watch them answer.

## Architecture

```text
                        HOST
                          |
        :8080 -> web:80   |   :8081 -> api:3000     (port mapping / NAT)
                          |
   +----------------------+------------------------+
   |         Docker bridge network "netlab"         |
   |                172.30.0.0/24                   |
   |              gateway 172.30.0.1                |
   |                                                |
   |  client        dns          web         api    |
   |  .100          .53          .10         .20    |
   |  toolbox     CoreDNS      nginx:80  nginx:3000 |
   +------------------------------------------------+
```

| Container | Address | What it is |
|---|---|---|
| `client` | 172.30.0.100 | Your workstation. `nicolaka/netshoot` — `ip`, `ss`, `dig`, `curl`, `ping`, `nc`, `traceroute`, `tcpdump`. Its `/etc/resolv.conf` points at `dns` |
| `dns` | 172.30.0.53 | CoreDNS, authoritative for the `lab.internal` zone, forwarding everything else to Docker's resolver |
| `web` | 172.30.0.10:80 | HTTP service on the standard port, with endpoints that return specific status codes |
| `api` | 172.30.0.20:3000 | A second HTTP service on a non-standard port |

## What maps to which lesson section

| Lesson | In this lab |
|---|---|
| 4–8 Private / public IP | Fixed addresses in the private range `172.30.0.0/24` |
| 9–11 MAC, interfaces, loopback | `ip -brief link`, `ip -brief addr` inside `client` |
| 12–13 IP + port | `web` on `:80` and `api` on `:3000` — same idea, different service |
| 14–17 TCP vs UDP | The same DNS query sent with `dig +notcp` and `dig +tcp` |
| 18–20 DNS and record types | The `lab.internal` zone: A, AAAA, CNAME, MX, TXT, NS |
| 21–23 HTTP request / response / status codes | `/`, `/whoami`, `/redirect`, `/status/404`, `/status/500`, `/status/503` |
| 30 ICMP | `ping web.lab.internal` vs `ping 172.30.0.199` |
| 32–34 Gateway, subnet, CIDR | `ip route` showing `default via 172.30.0.1` |
| 35, 37 NAT and port mapping | `docker port web`, and `http://localhost:8080` from the host |
| 36, 38 Docker networking | Container-to-container by name on a user-defined network |
| 39–44 The command set and troubleshooting | `explore.sh`, and the `mail.lab.internal` trap below |
| 47 A complete web request | `curl -w 'dns=%{time_namelookup} connect=%{time_connect} total=%{time_total}'` |

## Prerequisites

- Docker and Docker Compose
- `curl` on the host (for the port-mapping checks)
- Ports 8080 and 8081 free

## Run

```bash
./run.sh
```

The script waits until DNS answers for `lab.internal` and the web service
responds, then prints the address of every container.

Or manually:

```bash
docker compose up -d
docker compose ps
```

## Explore

```bash
./explore.sh
```

A guided tour in 15 steps: it runs the lesson's commands inside the `client`
container and prints their output, in the order the lesson introduces them.
Nothing is changed — read it, then run the commands yourself.

## Test

```bash
./test.sh
```

Twenty checks covering addressing, routing, ICMP, every DNS record type, DNS
over both UDP and TCP, open and closed ports, HTTP status codes, and host
port mapping. It ends by printing the last DNS queries CoreDNS answered.

## Exercises

Everything below runs from the client container:

```bash
docker exec -it client bash
```

### 1. Where am I on the network?

```bash
ip -brief addr        # my address
ip route              # my way out
ping -c 2 172.30.0.1  # the gateway
```

### 2. Name to address

```bash
dig +short web.lab.internal A
dig +short www.lab.internal CNAME
dig +short lab.internal MX
dig +short lab.internal TXT
dig web.lab.internal          # the full answer, with all its sections
```

Then watch the server side of the same question:

```bash
docker compose logs -f dns
```

Every query you send appears there. That is what a DNS server's day looks
like.

### 3. The same question over two transports

```bash
dig +notcp web.lab.internal   # UDP — the default
dig +tcp   web.lab.internal   # TCP — same answer, different transport
```

Watch the packets while you do it:

```bash
tcpdump -n -i eth0 port 53
```

### 4. Which service is listening?

```bash
nc -z -v web.lab.internal 80     # open
nc -z -v web.lab.internal 81     # closed
nc -z -v api.lab.internal 3000   # open
nc -z -v api.lab.internal 80     # closed — api is not on 80
```

### 5. The trap worth remembering

```bash
dig +short mail.lab.internal   # resolves to 172.30.0.25
nc -z -v mail.lab.internal 25  # nothing answers
```

`mail.lab.internal` has a perfectly good A record, and an MX record pointing
at it, and **no container exists at that address**. A DNS record is a claim,
not a service. This is the most common false lead in real troubleshooting:
"DNS resolves, so the problem must be somewhere else."

### 6. HTTP, one layer at a time

```bash
curl -i http://web.lab.internal/whoami
curl -I http://web.lab.internal/
curl -o /dev/null -w '%{http_code}\n' http://web.lab.internal/status/404
curl -v http://web.lab.internal/redirect        # see the 301 and its Location
```

Split one request into its layers:

```bash
curl -s -o /dev/null \
  -w 'dns=%{time_namelookup}s connect=%{time_connect}s total=%{time_total}s\n' \
  http://web.lab.internal/
```

`time_namelookup` is DNS, `time_connect` is the TCP handshake, and the
remainder is HTTP. One command, three layers of the lesson.

### 7. Prove that DNS is a separate step

```bash
curl -s -o /dev/null -w '%{http_code}\n' http://web.lab.internal/   # by name
curl -s -o /dev/null -w '%{http_code}\n' http://172.30.0.10/        # by address
```

Same response. The name was only ever a lookup.

## Stop / cleanup

```bash
docker compose down
```

## Notes

- **The `client` container uses the lab's DNS server**, set through `dns:` in
  `compose.yaml`, which is why `dig web.lab.internal` works with no
  `@server`. CoreDNS forwards anything outside `lab.internal` to Docker's
  embedded resolver at `127.0.0.11`, so plain container names such as `web`
  and `api` keep working too. If the `dns` container is down, the client
  loses all name resolution — which is itself a realistic failure worth
  experiencing once.
- **CoreDNS logs every query** (`docker compose logs dns`). Very few labs let
  you watch both sides of a DNS lookup; use it.
- **The DNS server has no shell.** `coredns/coredns` is built `FROM scratch`,
  so `docker exec dns sh` will not work and it carries no healthcheck. Check
  it by querying it instead — that is what a DNS server is for.
- **`nc -z` is the port check** used throughout, because it separates "is
  something listening?" from "does the application work?". A port that is
  open while HTTP fails points at the application, not the network.
- **`ss` vs `netstat`:** the `client` image has the modern `ss`; the
  `nginx:alpine` containers only have busybox `netstat`. The lesson mentions
  both — here you see why you end up using whichever one the box actually
  has.
- **`172.30.0.199` is deliberately empty**, so `ping` has something to fail
  against. A failed ping inside your own subnet fails differently from one
  across the internet — the first is usually ARP, the second routing.
- **The AAAA record points into `2001:db8::/32`**, the documentation range.
  It resolves; nothing listens there. IPv6 is not enabled on this network.
- The bridge network is named `netlab` explicitly, so
  `docker network inspect netlab` works without the Compose project prefix.
