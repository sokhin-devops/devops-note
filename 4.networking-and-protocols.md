# Networking & Protocols

Networking is the foundation of DevOps.

When you use:

```text
Browser
Docker
SSH
Git
API
Database
Cloud Server
Kubernetes
```

they all depend on networking.

---

# 1. What Is Networking?

Networking is the communication between devices.

For example:

```text
Laptop
   │
   │ Network
   ▼
Router
   │
   │ Internet
   ▼
Server
```

Your laptop can communicate with:

* Another computer
* A server
* A database
* An API
* A cloud service
* A website

---

# 2. Basic Network Model

A simple network:

```text
Your Computer
      │
      ▼
   Router
      │
      ▼
  Internet
      │
      ▼
Web Server
```

When you open:

```text
https://google.com
```

your computer needs to figure out:

```text
Where is google.com?
How do I reach it?
Which port?
Which protocol?
How should the data be transferred?
```

Different networking protocols solve different parts of this problem.

---

# 3. What Is a Protocol?

A **protocol** is a set of rules that devices follow to communicate.

Think about human communication:

```text
Person A → speaks English → Person B
```

Both people need to understand the same language.

Computers similarly use protocols:

```text
Computer A → HTTP → Computer B
```

Examples:

| Protocol | Purpose                               |
| -------- | ------------------------------------- |
| HTTP     | Web communication                     |
| HTTPS    | Secure web communication              |
| SSH      | Remote server access                  |
| DNS      | Domain name → IP address              |
| TCP      | Reliable data transport               |
| UDP      | Fast connectionless transport         |
| FTP      | File transfer                         |
| SMTP     | Sending email                         |
| ICMP     | Network diagnostics                   |
| DHCP     | Automatically assign IP configuration |

---

# 4. IP Address

An IP address identifies a device/interface on a network.

Example:

```text
192.168.1.10
```

Another example:

```text
10.0.0.5
```

You can think of an IP address like a **network address**.

```text
Computer A
IP: 192.168.1.10

Computer B
IP: 192.168.1.20
```

They can communicate if the network configuration allows it.

---

# 5. IPv4

The most common IP format you'll encounter as a beginner is IPv4.

Example:

```text
192.168.1.100
```

It contains four numbers:

```text
192 . 168 . 1 . 100
```

Each section can range from:

```text
0 → 255
```

---

# 6. Private IP Addresses

Private IP addresses are commonly used inside local networks.

Important private ranges:

```text
10.0.0.0/8

172.16.0.0/12

192.168.0.0/16
```

Example:

```text
Laptop
192.168.1.10

Phone
192.168.1.11

Printer
192.168.1.20
```

These devices can communicate inside the local network.

---

# 7. Public IP Address

A public IP address is reachable through the Internet, subject to routing and firewall rules.

Example:

```text
Server
Public IP:
203.x.x.x
```

A cloud server such as a VPS normally has a public IP.

```text
Internet
    │
    ▼
203.x.x.x
    │
    ▼
Cloud Server
```

---

# 8. Local IP vs Public IP

Your laptop might have:

```text
Private IP:
192.168.1.10
```

Your router might have:

```text
Public IP:
203.x.x.x
```

Architecture:

```text
Laptop
192.168.1.10
     │
     ▼
Router
203.x.x.x
     │
     ▼
Internet
```

---

# 9. MAC Address

A MAC address identifies a network interface at the local network/link layer.

Example:

```text
A4:5E:60:12:34:56
```

Think of:

```text
IP address
    ↓
Network-level address

MAC address
    ↓
Local network interface address
```

You can see network interfaces with:

```bash
ip link
```

---

# 10. Network Interface

A network interface is how your computer connects to a network.

Examples:

```text
eth0
ens33
enp0s3
wlan0
```

On Linux:

```bash
ip link
```

or:

```bash
ip addr
```

Example:

```text
1: lo
2: eth0
3: docker0
```

---

# 11. Loopback

The loopback interface is:

```text
lo
```

The common loopback IP is:

```text
127.0.0.1
```

You will often hear:

```text
localhost
```

`localhost` normally refers to your own machine.

For example:

```bash
curl http://localhost:8080
```

means:

```text
Your Computer
     │
     ▼
127.0.0.1:8080
     │
     ▼
Service running locally
```

---

# 12. Port

An IP address identifies a network endpoint, while a **port** identifies a service/application endpoint on that host.

Example:

```text
192.168.1.10:80
```

means:

```text
IP   = 192.168.1.10
Port = 80
```

Common ports:

| Port | Common Service                      |
| ---: | ----------------------------------- |
|   22 | SSH                                 |
|   53 | DNS                                 |
|   80 | HTTP                                |
|  443 | HTTPS                               |
|   25 | SMTP                                |
|  110 | POP3                                |
|  143 | IMAP                                |
| 3306 | MySQL                               |
| 5432 | PostgreSQL                          |
| 6379 | Redis                               |
| 8080 | Common alternative HTTP port        |
| 3000 | Common development application port |

---

# 13. IP + Port

Think:

```text
IP address = Which machine?
Port        = Which service?
```

For example:

```text
192.168.1.10:22
```

means:

```text
Machine: 192.168.1.10
Service: SSH
Port:    22
```

Another:

```text
192.168.1.10:5432
```

means a PostgreSQL service may be listening there.

---

# 14. TCP

TCP stands for:

```text
Transmission Control Protocol
```

TCP provides reliable, ordered delivery.

Conceptually:

```text
Client
  │
  │ Establish connection
  ▼
Server
  │
  │ Transfer data
  ▼
Client
```

TCP is commonly used by:

```text
HTTP
HTTPS
SSH
FTP
SMTP
PostgreSQL
MySQL
```

---

# 15. TCP Three-Way Handshake

Before normal TCP communication, a connection is established using a handshake.

Simplified:

```text
Client                    Server

  SYN  ──────────────────►

       ◄──────────────── SYN-ACK

  ACK  ──────────────────►

       Connection established
```

Remember:

```text
SYN
 ↓
SYN-ACK
 ↓
ACK
```

You don't normally manually perform this; the operating system handles it.

---

# 16. UDP

UDP stands for:

```text
User Datagram Protocol
```

UDP is connectionless and has less overhead than TCP.

Conceptually:

```text
Client
  │
  │ Data
  ├──────────────────►
  │ Data
  ├──────────────────►
  │ Data
  └──────────────────►
Server
```

UDP does not provide TCP-style guarantees that every packet arrives in order and is retransmitted automatically.

Common uses include:

```text
DNS
DHCP
VoIP
Streaming
Online games
QUIC
```

---

# 17. TCP vs UDP

| TCP                 | UDP                            |
| ------------------- | ------------------------------ |
| Connection-oriented | Connectionless                 |
| Reliable delivery   | No built-in delivery guarantee |
| Ordered data        | No built-in ordering           |
| More overhead       | Lower overhead                 |
| Common for web/SSH  | Common for DNS/media/games     |
| Handshake           | No TCP handshake               |

Easy memory:

```text
TCP = Reliability
UDP = Speed / Low overhead
```

This is simplified; actual protocol choice depends on the application.

---

# 18. DNS

DNS stands for:

```text
Domain Name System
```

DNS converts domain names into IP addresses.

For example:

```text
google.com
     │
     ▼
    DNS
     │
     ▼
IP Address
```

Without DNS, you would need to remember IP addresses instead of domain names.

---

# 19. DNS Example

You type:

```text
https://example.com
```

Your computer needs the IP address.

Conceptually:

```text
Browser
   │
   ▼
DNS
   │
   │ example.com ?
   ▼
IP Address
   │
   ▼
Web Server
```

Use:

```bash
nslookup example.com
```

or:

```bash
dig example.com
```

---

# 20. DNS Record Types

Important DNS records:

| Record | Purpose                        |
| ------ | ------------------------------ |
| A      | Domain → IPv4 address          |
| AAAA   | Domain → IPv6 address          |
| CNAME  | Alias to another hostname      |
| MX     | Mail server                    |
| TXT    | Text/configuration information |
| NS     | Authoritative name server      |
| PTR    | Reverse DNS                    |

Example:

```text
example.com
    │
    └── A → 203.0.113.10
```

---

# 21. HTTP

HTTP stands for:

```text
Hypertext Transfer Protocol
```

It is used for web communication.

Example:

```text
Browser
   │
   │ HTTP Request
   ▼
Web Server
   │
   │ HTTP Response
   ▼
Browser
```

---

# 22. HTTP Request

Example:

```http
GET /users HTTP/1.1
Host: example.com
```

The browser is essentially saying:

```text
Give me /users
```

Common HTTP methods:

| Method | Purpose               |
| ------ | --------------------- |
| GET    | Retrieve data         |
| POST   | Create/send data      |
| PUT    | Replace/update data   |
| PATCH  | Partially update data |
| DELETE | Delete data           |

---

# 23. HTTP Response

The server responds with a status code.

Examples:

```text
200 OK
201 Created
301 Moved Permanently
302 Found
400 Bad Request
401 Unauthorized
403 Forbidden
404 Not Found
500 Internal Server Error
502 Bad Gateway
503 Service Unavailable
```

Important groups:

```text
2xx → Success
3xx → Redirect
4xx → Client error
5xx → Server error
```

---

# 24. HTTPS

HTTPS means:

```text
HTTP + TLS encryption
```

Instead of:

```text
HTTP
Client ───────────── Server
```

HTTPS protects the connection with encryption:

```text
HTTPS

Client
  │
  │ Encrypted
  ▼
Internet
  │
  ▼
Server
```

HTTPS normally uses:

```text
Port 443
```

HTTP normally uses:

```text
Port 80
```

---

# 25. TLS

TLS stands for:

```text
Transport Layer Security
```

TLS provides security properties such as:

* Encryption
* Authentication of the server
* Integrity protection

When you visit:

```text
https://example.com
```

TLS is used to secure the HTTP communication.

---

# 26. SSH

SSH stands for:

```text
Secure Shell
```

SSH allows you to remotely access a server.

Example:

```bash
ssh user@203.0.113.10
```

Architecture:

```text
Your Computer
      │
      │ SSH
      │ Port 22
      ▼
Linux Server
```

After connecting:

```text
user@server:~$
```

You can run commands remotely.

---

# 27. SCP

SCP copies files over SSH.

Copy local → server:

```bash
scp app.zip user@server:/home/user/
```

Copy server → local:

```bash
scp user@server:/home/user/app.zip .
```

Architecture:

```text
Your Computer
      │
      │ SCP / SSH
      ▼
Server
```

---

# 28. SFTP

SFTP means:

```text
SSH File Transfer Protocol
```

It provides file transfer over SSH.

Example:

```bash
sftp user@server
```

Then:

```text
put file.txt
get file.txt
```

---

# 29. FTP

FTP stands for:

```text
File Transfer Protocol
```

It is an older file transfer protocol.

For modern secure file transfer, prefer:

```text
SFTP
```

or another secure transfer mechanism.

---

# 30. ICMP

ICMP is used for network control and diagnostics.

The most famous command using ICMP is:

```bash
ping google.com
```

Conceptually:

```text
Computer
   │
   │ ICMP Echo Request
   ▼
Server
   │
   │ ICMP Echo Reply
   ▼
Computer
```

Ping helps answer:

```text
Can I reach this host?
How long does the response take?
```

---

# 31. DHCP

DHCP stands for:

```text
Dynamic Host Configuration Protocol
```

It automatically provides network configuration to clients.

For example:

```text
Laptop
   │
   │ DHCP request
   ▼
DHCP Server
   │
   ├── IP address
   ├── Subnet mask
   ├── Default gateway
   └── DNS server
```

This is why you usually don't manually configure an IP address every time you connect to Wi-Fi.

---

# 32. Default Gateway

A default gateway is where your machine sends traffic destined for other networks.

Example:

```text
Laptop
192.168.1.10
      │
      ▼
Gateway
192.168.1.1
      │
      ▼
Internet
```

Check routes:

```bash
ip route
```

You may see:

```text
default via 192.168.1.1 dev eth0
```

This means:

```text
Default traffic
      ↓
192.168.1.1
```

---

# 33. Subnet

A subnet divides a network into smaller network ranges.

Example:

```text
192.168.1.0/24
```

A common `/24` IPv4 network has:

```text
Network:
192.168.1.0

Typical usable hosts:
192.168.1.1
...
192.168.1.254

Broadcast:
192.168.1.255
```

For now, focus on understanding the idea of:

```text
Network
   ↓
Subnet
   ↓
Hosts
```

---

# 34. CIDR

CIDR notation describes an IP network and its prefix length.

Examples:

```text
192.168.1.0/24
10.0.0.0/8
172.16.0.0/12
```

The `/24` tells you how many bits belong to the network prefix.

Common examples:

```text
/8
/16
/24
/32
```

`/32` represents a single IPv4 address.

For example:

```text
203.0.113.10/32
```

means exactly that one address.

---

# 35. NAT

NAT stands for:

```text
Network Address Translation
```

NAT commonly allows private network addresses to communicate through a public IP.

Example:

```text
Laptop
192.168.1.10
      │
      ▼
Router
Public IP
203.x.x.x
      │
      ▼
Internet
```

The router translates between private and public addressing.

---

# 36. Docker Networking

Docker creates networks for containers.

List networks:

```bash
docker network ls
```

Example:

```text
NETWORK ID     NAME
abc123        bridge
def456        host
ghi789        none
```

Create a network:

```bash
docker network create app-network
```

Run:

```bash
docker run -d \
  --name backend \
  --network app-network \
  nginx
```

Another container:

```bash
docker run -d \
  --name frontend \
  --network app-network \
  nginx
```

Containers on the same user-defined Docker network can communicate using container/service names.

---

# 37. Docker Port Mapping

Suppose Nginx listens inside the container on port 80.

You run:

```bash
docker run -d -p 8080:80 nginx
```

This means:

```text
HOST PORT : CONTAINER PORT

8080 : 80
```

Architecture:

```text
Browser
   │
   │ localhost:8080
   ▼
Host
   │
   │ Docker port mapping
   ▼
Container :80
   │
   ▼
Nginx
```

---

# 38. Docker Container-to-Container Networking

Suppose:

```text
Frontend
    │
    ▼
Backend
    │
    ▼
PostgreSQL
```

Create network:

```bash
docker network create app-network
```

Run PostgreSQL:

```bash
docker run -d \
  --name database \
  --network app-network \
  postgres
```

Run backend:

```bash
docker run -d \
  --name backend \
  --network app-network \
  my-backend
```

The backend can connect to:

```text
database:5432
```

Instead of:

```text
localhost:5432
```

Important:

> Inside a container, `localhost` means **that container itself**, not another container.

---

# 39. Common Networking Commands

## Show IP addresses

```bash
ip addr
```

Short form:

```bash
ip a
```

---

## Show network interfaces

```bash
ip link
```

---

## Show routing table

```bash
ip route
```

---

## Test connectivity

```bash
ping google.com
```

---

## DNS lookup

```bash
nslookup google.com
```

---

## Detailed DNS lookup

```bash
dig google.com
```

---

## HTTP request

```bash
curl https://example.com
```

---

## Download a file

```bash
wget https://example.com/file.zip
```

---

## Show listening ports

Modern Linux:

```bash
ss -tuln
```

Older systems:

```bash
netstat -tuln
```

---

## Trace network path

```bash
traceroute google.com
```

---

# 40. `ss` Command

`ss` is especially useful for DevOps.

Run:

```bash
ss -tuln
```

Meaning:

```text
-t → TCP
-u → UDP
-l → Listening
-n → Numeric addresses/ports
```

You might see:

```text
LISTEN 0 128 0.0.0.0:22
LISTEN 0 511 0.0.0.0:80
LISTEN 0 128 0.0.0.0:443
```

This tells you services are listening on:

```text
22
80
443
```

---

# 41. `curl`

`curl` is one of the most useful DevOps networking tools.

Simple request:

```bash
curl https://example.com
```

Show headers:

```bash
curl -I https://example.com
```

GET request:

```bash
curl -X GET https://api.example.com/users
```

POST request:

```bash
curl -X POST https://api.example.com/users
```

Send JSON:

```bash
curl \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"name":"Sokhin"}' \
  https://api.example.com/users
```

---

# 42. `ping` vs `curl`

These commands answer different questions.

### ping

```bash
ping example.com
```

Main question:

```text
Can I reach this host using ICMP?
```

### curl

```bash
curl https://example.com
```

Main question:

```text
Can I communicate with this HTTP/HTTPS service?
```

A server can respond to HTTP while blocking ICMP, so:

```text
ping fails
```

does not automatically mean:

```text
website is down
```

---

# 43. DNS Troubleshooting

Suppose:

```bash
curl https://api.example.com
```

fails.

Check DNS:

```bash
dig api.example.com
```

If DNS works, test the IP directly when appropriate:

```bash
curl https://203.0.113.10
```

For HTTPS, certificate/Host/SNI behavior can make direct-IP testing different from using the hostname.

General troubleshooting:

```text
Domain
  ↓
DNS
  ↓
IP
  ↓
Port
  ↓
Firewall
  ↓
Service
  ↓
Application
```

---

# 44. Network Troubleshooting Flow

When a service is unreachable, don't randomly try commands.

Follow a process:

```text
1. Is the application running?
          ↓
2. Is the service listening on the expected port?
          ↓
3. Is the IP address correct?
          ↓
4. Is DNS resolving correctly?
          ↓
5. Is the firewall allowing traffic?
          ↓
6. Is routing correct?
          ↓
7. Is Docker port mapping correct?
          ↓
8. Is the reverse proxy configured correctly?
```

Useful commands:

```bash
ps
ss -tuln
ip addr
ip route
ping
dig
curl
docker ps
docker logs
docker inspect
```

---

# 45. OSI Model

The OSI model is a way to understand networking in layers.

```text
7. Application
6. Presentation
5. Session
4. Transport
3. Network
2. Data Link
1. Physical
```

For DevOps, focus heavily on:

```text
Layer 7 → HTTP / HTTPS / DNS / SSH
Layer 4 → TCP / UDP
Layer 3 → IP / ICMP
Layer 2 → Ethernet / MAC
```

---

# 46. TCP/IP Model

In practical networking, you'll often work with the TCP/IP model:

```text
Application
     ↓
Transport
     ↓
Internet
     ↓
Link
```

Examples:

```text
Application
HTTP
DNS
SSH

Transport
TCP
UDP

Internet
IP
ICMP

Link
Ethernet
Wi-Fi
```

---

# 47. Complete Web Request

Let's understand what happens when you type:

```text
https://example.com
```

### Step 1 — DNS

```text
example.com
      ↓
DNS
      ↓
IP address
```

### Step 2 — Connection

The client connects to the server using the required transport protocol.

For traditional HTTPS:

```text
TCP :443
```

### Step 3 — TLS

TLS establishes a secure encrypted connection.

### Step 4 — HTTP

The browser sends:

```text
GET /
```

### Step 5 — Server Response

The server returns:

```text
HTTP/1.1 200 OK
```

and the content.

Overall:

```text
Browser
   │
   ▼
DNS
   │
   ▼
IP Address
   │
   ▼
TCP
   │
   ▼
TLS
   │
   ▼
HTTPS / HTTP
   │
   ▼
Web Server
```

---

# 48. How Proxies Fit Into Networking

You just learned proxies.

Now combine them with networking:

```text
CLIENT
   │
   ▼
Forward Proxy
   │
   ▼
Internet
```

For a server:

```text
Internet
   │
   ▼
Firewall
   │
   ▼
Reverse Proxy
   │
   ▼
Load Balancer
   │
   ├── Backend 1
   ├── Backend 2
   └── Backend 3
```

---

# 49. How Docker Fits Into Networking

Docker adds another network layer:

```text
Internet
    │
    ▼
Host Server
    │
    ▼
Docker Network
    │
    ├── Nginx
    │
    ├── Backend
    │
    ├── Redis
    │
    └── PostgreSQL
```

Example:

```text
Internet
   │
   │ :443
   ▼
Nginx Container
   │
   │ :3000
   ▼
Backend Container
   │
   │ :5432
   ▼
PostgreSQL Container
```

---

# 50. Networking Cheat Sheet

| Command                 | Purpose                      |
| ----------------------- | ---------------------------- |
| `ip addr`               | Show IP addresses            |
| `ip link`               | Show network interfaces      |
| `ip route`              | Show routing table           |
| `ping`                  | Test ICMP connectivity       |
| `curl`                  | Make HTTP/API requests       |
| `wget`                  | Download resources           |
| `ss`                    | Show sockets/listening ports |
| `netstat`               | Show network connections     |
| `dig`                   | DNS lookup                   |
| `nslookup`              | DNS lookup                   |
| `traceroute`            | Trace network path           |
| `ssh`                   | Remote server access         |
| `scp`                   | Copy files over SSH          |
| `sftp`                  | Transfer files over SSH      |
| `docker network ls`     | List Docker networks         |
| `docker network create` | Create Docker network        |
| `docker port`           | Show container port mappings |

---

# 51. Protocol Cheat Sheet

| Protocol   | Main Purpose          | Common Port |
| ---------- | --------------------- | ----------: |
| HTTP       | Web                   |          80 |
| HTTPS      | Secure Web            |         443 |
| SSH        | Remote administration |          22 |
| DNS        | Name resolution       |          53 |
| DHCP       | Network configuration |       67/68 |
| FTP        | File transfer         |          21 |
| SMTP       | Sending email         |          25 |
| IMAP       | Receiving email       |         143 |
| POP3       | Receiving email       |         110 |
| PostgreSQL | Database              |        5432 |
| MySQL      | Database              |        3306 |
| Redis      | Cache/data store      |        6379 |

---

# 52. Most Important Concepts to Memorize

Don't try to memorize everything.

First understand these:

```text
IP
 ↓
Identifies network endpoint

PORT
 ↓
Identifies service endpoint

DNS
 ↓
Domain → IP

TCP
 ↓
Reliable transport

UDP
 ↓
Connectionless transport

HTTP
 ↓
Web communication

HTTPS
 ↓
HTTP + TLS

SSH
 ↓
Remote server access

ICMP
 ↓
Network diagnostics

DHCP
 ↓
Automatic network configuration

NAT
 ↓
Address translation

Firewall
 ↓
Allow / block traffic
```

---

# 53. Your DevOps Networking Roadmap

Learn in this order:

```text
1. IP Address
       ↓
2. Private vs Public IP
       ↓
3. Ports
       ↓
4. TCP / UDP
       ↓
5. DNS
       ↓
6. HTTP / HTTPS
       ↓
7. SSH
       ↓
8. Subnet / CIDR
       ↓
9. Routing
       ↓
10. NAT
       ↓
11. Firewall
       ↓
12. Reverse Proxy
       ↓
13. Load Balancer
       ↓
14. Docker Networking
       ↓
15. Cloud Networking
       ↓
16. Kubernetes Networking
```

---

# 54. Practice Lab

Create three Docker containers:

```text
network-lab/
```

Create a network:

```bash
docker network create network-lab
```

Run a web server:

```bash
docker run -d \
  --name web \
  --network network-lab \
  nginx
```

Run another container:

```bash
docker run -it \
  --name client \
  --network network-lab \
  alpine sh
```

Inside the client:

```bash
ping web
```

Then try:

```bash
wget http://web
```

You are now practising **container-to-container networking**.

The architecture is:

```text
             Docker Network
                  │
          ┌───────┴───────┐
          │               │
          ▼               ▼
       client            web
                           │
                           ▼
                         Nginx
```

This is one of the most useful Docker networking exercises for a beginner.

---

# 55. Final Mental Model

When debugging networking, think:

```text
                    USER
                      │
                      ▼
                  DNS
                      │
                      ▼
                     IP
                      │
                      ▼
                    PORT
                      │
                      ▼
                  FIREWALL
                      │
                      ▼
                   ROUTING
                      │
                      ▼
               REVERSE PROXY
                      │
                      ▼
                LOAD BALANCER
                      │
                      ▼
                  CONTAINER
                      │
                      ▼
                 APPLICATION
```

And remember:

```text
DNS       → "Where is the server?"
IP        → "Which network endpoint?"
Port      → "Which service?"
TCP/UDP   → "How is data transported?"
HTTP      → "How do web applications communicate?"
HTTPS     → "How do we secure HTTP?"
SSH       → "How do I access the server remotely?"
Firewall  → "Is this traffic allowed?"
Proxy     → "Who is acting as the middleman?"
NAT       → "How are addresses translated?"
Docker    → "How do containers communicate?"
```

If you understand this flow, you'll have a strong foundation for **Docker networking, cloud networking, Kubernetes, CI/CD infrastructure, and production server troubleshooting**.
