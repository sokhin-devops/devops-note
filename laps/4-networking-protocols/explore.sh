#!/bin/bash
# A guided tour: runs the lesson's commands inside the lab and shows the output.
# Nothing here changes anything — read the output, then try the commands yourself.
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

c() { docker exec client "$@"; }

step() {
  echo
  echo "------------------------------------------------------------"
  echo "$1"
  echo "------------------------------------------------------------"
}

run() {
  echo
  echo "\$ $*"
  "$@" 2>&1 | sed 's/^/  /'
}

echo "== Networking & Protocols — guided tour =="
echo "Every command below runs inside the 'client' container (172.30.0.100)."

step "1. Interfaces and addresses  (lesson 9-11)"
run c ip -brief link
run c ip -brief addr

step "2. Routing and the default gateway  (lesson 32)"
run c ip route
echo
echo "  'default via 172.30.0.1' is the bridge — every packet leaving"
echo "  172.30.0.0/24 goes there, and it is also what NATs your traffic."

step "3. ICMP: can I reach the host at all?  (lesson 30)"
run c ping -c 2 -W 2 web.lab.internal
echo
echo "  Now an address in our subnet with nothing on it:"
run c ping -c 1 -W 2 172.30.0.199

step "4. DNS: name to address  (lesson 18-20)"
run c dig +short web.lab.internal A
run c dig +short www.lab.internal CNAME
run c dig +short ipv6.lab.internal AAAA
run c dig +short lab.internal MX
run c dig +short lab.internal TXT
echo
echo "  The full answer, with the sections dig prints:"
run c dig web.lab.internal

step "5. DNS runs over UDP — but also TCP  (lesson 16-17)"
echo "  Same question, two transports. UDP first (the default):"
run c dig +short +notcp web.lab.internal
echo "  Now forced over TCP:"
run c dig +short +tcp web.lab.internal

step "6. Ports: which service, not which machine  (lesson 12-13)"
echo "  Open port (web is listening on 80):"
run c nc -z -v -w 2 web.lab.internal 80
echo "  Closed port (nothing is listening on 81):"
run c nc -z -v -w 2 web.lab.internal 81
echo "  The api service is on 3000, not 80 — same idea, different port:"
run c nc -z -v -w 2 api.lab.internal 3000
run c nc -z -v -w 2 api.lab.internal 80

step "7. DNS resolving is not the same as a service existing  (lesson 43-44)"
echo "  mail.lab.internal resolves perfectly well:"
run c dig +short mail.lab.internal A
echo "  ...but nothing is listening there, on any port:"
run c nc -z -v -w 2 mail.lab.internal 25
echo
echo "  This is why 'the DNS is fine' never means 'the service is up'."

step "8. Listening sockets, from the server's own point of view  (lesson 39-40)"
echo "  Inside the client (ss, the modern tool):"
run c ss -tuln
echo "  Inside the web container (busybox has netstat, not ss):"
run docker exec web netstat -tuln

step "9. HTTP: the request and the response  (lesson 21-23)"
run c curl -s -i http://web.lab.internal/whoami
echo
echo "  Headers only:"
run c curl -s -I http://web.lab.internal/
echo
echo "  Status codes on demand:"
run c curl -s -o /dev/null -w 'GET /            -> %{http_code}\n' http://web.lab.internal/
run c curl -s -o /dev/null -w 'GET /status/404  -> %{http_code}\n' http://web.lab.internal/status/404
run c curl -s -o /dev/null -w 'GET /status/500  -> %{http_code}\n' http://web.lab.internal/status/500
run c curl -s -o /dev/null -w 'GET /redirect    -> %{http_code}\n' http://web.lab.internal/redirect

step "10. The same request, timed at every stage  (lesson 47)"
run c curl -s -o /dev/null -w 'dns=%{time_namelookup}s connect=%{time_connect}s total=%{time_total}s\n' http://web.lab.internal/
echo
echo "  time_namelookup is DNS, time_connect is the TCP handshake,"
echo "  and the rest is HTTP. One command, three layers."

step "11. A second service on another port  (lesson 12-13, 38)"
run c curl -s http://api.lab.internal:3000/
echo
run c curl -s http://api.lab.internal:3000/health

step "12. Container-to-container by name  (lesson 36, 38)"
echo "  Plain container names work too — Docker's own resolver answers those:"
run c curl -s -o /dev/null -w 'http://web  -> %{http_code}\n' http://web
run c curl -s -o /dev/null -w 'http://api:3000 -> %{http_code}\n' http://api:3000

step "13. Port mapping and NAT, from the host  (lesson 35, 37)"
run docker port web
run docker port api
echo
echo "  From your host (not the container), the published ports work:"
run curl -s -o /dev/null -w 'http://localhost:8080 -> %{http_code}\n' http://localhost:8080
run curl -s -o /dev/null -w 'http://localhost:8081 -> %{http_code}\n' http://localhost:8081

step "14. The Docker network itself  (lesson 36)"
run docker network inspect netlab --format '{{json .IPAM.Config}}'
run docker network inspect netlab --format '{{range $k, $v := .Containers}}{{$v.Name}} {{$v.IPv4Address}}{{println}}{{end}}'

step "15. Who asked the DNS server what?  (lesson 18-19)"
echo "  CoreDNS logs every query it answered during this tour:"
run docker compose logs --tail 15 dns

echo
echo "== End of tour =="
echo "Run ./test.sh to check all of this automatically."
