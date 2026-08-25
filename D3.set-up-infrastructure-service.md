# Setting Up Infrastructure Services

This guide explains how to set up and understand:

* Forward Proxy
* Reverse Proxy
* Load Balancer
* Firewall
* Caching Server
* Web Server

The examples use **Docker** so you can practise everything locally.

---

# 1. Big Picture

Before learning each service individually, understand where they normally sit in an infrastructure:

```text
                         INTERNET
                             │
                             │
                        ┌────▼────┐
                        │ FIREWALL│
                        └────┬────┘
                             │
                             ▼
                     ┌──────────────┐
                     │Reverse Proxy │
                     │ / Load       │
                     │ Balancer     │
                     └──────┬───────┘
                            │
                  ┌─────────┼─────────┐
                  │         │         │
                  ▼         ▼         ▼
               Web 1     Web 2     Web 3
                  │         │         │
                  └─────────┼─────────┘
                            │
                            ▼
                         Database
```

A more complete production architecture might look like:

```text
                         USER
                           │
                           ▼
                      INTERNET
                           │
                           ▼
                     ┌──────────┐
                     │ Firewall │
                     └────┬─────┘
                          │
                          ▼
                    ┌─────────────┐
                    │   Nginx     │
                    │ Reverse     │
                    │ Proxy       │
                    └──────┬──────┘
                           │
                    Load Balancing
                           │
              ┌────────────┼────────────┐
              ▼            ▼            ▼
           Server 1     Server 2     Server 3
              │            │            │
              └────────────┼────────────┘
                           │
                           ▼
                         Cache
                           │
                           ▼
                       Database
```

---

# 2. Forward Proxy

## What is a Forward Proxy?

A forward proxy sits between the **client and the Internet**.

```text
Client
   │
   ▼
Forward Proxy
   │
   ▼
Internet
```

The client sends the request to the proxy.

The proxy then sends the request to the destination.

```text
Client
  │
  │ Request
  ▼
Proxy
  │
  │ Request
  ▼
Google / Website / API
```

The proxy represents the **client**.

---

# 3. Why Use a Forward Proxy?

Common reasons:

* Control Internet access
* Filter websites
* Monitor traffic
* Hide client IP from destinations
* Cache frequently requested content
* Control corporate network traffic

Example:

```text
Company Network
      │
      ▼
Forward Proxy
      │
      ├── Allow → github.com
      ├── Allow → google.com
      └── Block → example.com
```

---

# 4. Forward Proxy Example with Squid

A popular forward proxy is **Squid**.

Docker:

```bash
docker pull ubuntu/squid
```

Run:

```bash
docker run -d \
  --name squid \
  -p 3128:3128 \
  ubuntu/squid
```

Check:

```bash
docker ps
```

Check logs:

```bash
docker logs squid
```

The proxy normally listens on:

```text
3128
```

---

# 5. Test a Forward Proxy

Using curl:

```bash
curl -x http://localhost:3128 https://example.com
```

The:

```text
-x
```

means:

```text
Use proxy
```

Architecture:

```text
curl
 │
 │ :3128
 ▼
Squid
 │
 ▼
example.com
```

---

# 6. Reverse Proxy

A reverse proxy is different.

It sits in front of your **servers**.

```text
Client
   │
   ▼
Reverse Proxy
   │
   ▼
Backend Server
```

The reverse proxy represents the **server**.

Popular reverse proxies:

* Nginx
* Apache
* HAProxy
* Traefik
* Caddy

---

# 7. Why Use a Reverse Proxy?

A reverse proxy can provide:

* Routing
* SSL/TLS termination
* Load balancing
* Security
* Authentication
* Compression
* Caching
* Logging

Example:

```text
User
 │
 │ https://example.com
 ▼
Nginx
 │
 ├── /api → Backend
 │
 ├── /admin → Admin Server
 │
 └── / → Frontend
```

---

# 8. Nginx Reverse Proxy

Create:

```text
reverse-proxy/
├── docker-compose.yml
└── nginx.conf
```

`nginx.conf`:

```nginx
events {}

http {

    server {

        listen 80;

        location / {
            proxy_pass http://backend:3000;
        }
    }
}
```

Docker Compose:

```yaml
services:

  nginx:
    image: nginx:latest
    ports:
      - "8080:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - backend

  backend:
    image: node:22
    command: node -e "require('http').createServer((req,res)=>res.end('Hello from Backend')).listen(3000)"
```

Start:

```bash
docker compose up -d
```

Open:

```text
http://localhost:8080
```

Architecture:

```text
Browser
   │
   │ :8080
   ▼
Nginx
   │
   │ :3000
   ▼
Backend
```

---

# 9. Reverse Proxy with Multiple Services

You can route different paths:

```text
                Nginx
                  │
        ┌─────────┴─────────┐
        │                   │
        ▼                   ▼
    /api                 /admin
        │                   │
        ▼                   ▼
   Backend API         Admin Server
```

Example:

```nginx
location /api/ {
    proxy_pass http://backend:3000;
}

location /admin/ {
    proxy_pass http://admin:4000;
}
```

---

# 10. Load Balancer

A load balancer distributes traffic across multiple servers.

Without load balancing:

```text
Users
  │
  ▼
Server
```

If 10,000 users arrive:

```text
Users
  │
  ▼
One Server
  │
  X
Overloaded
```

With load balancing:

```text
                  Load Balancer
                       │
            ┌──────────┼──────────┐
            ▼          ▼          ▼
         Server 1   Server 2   Server 3
```

Traffic can be distributed:

```text
Request 1 → Server 1
Request 2 → Server 2
Request 3 → Server 3
Request 4 → Server 1
Request 5 → Server 2
```

---

# 11. Load Balancer with Nginx

Create:

```text
load-balancer/
├── docker-compose.yml
└── nginx.conf
```

`nginx.conf`:

```nginx
events {}

http {

    upstream backend_servers {

        server backend1:3000;
        server backend2:3000;
        server backend3:3000;
    }

    server {

        listen 80;

        location / {

            proxy_pass http://backend_servers;
        }
    }
}
```

Compose:

```yaml
services:

  nginx:
    image: nginx:latest
    ports:
      - "8080:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - backend1
      - backend2
      - backend3

  backend1:
    image: nginx:latest

  backend2:
    image: nginx:latest

  backend3:
    image: nginx:latest
```

Start:

```bash
docker compose up -d
```

Now:

```text
                  Nginx
               Load Balancer
                    │
        ┌───────────┼───────────┐
        ▼           ▼           ▼
    backend1    backend2    backend3
```

---

# 12. Load Balancing Algorithms

Common algorithms include:

## Round Robin

Requests are distributed sequentially:

```text
Request 1 → Server 1
Request 2 → Server 2
Request 3 → Server 3
Request 4 → Server 1
```

Nginx uses round-robin by default.

---

## Least Connections

Send traffic to the server with the fewest active connections.

```nginx
upstream backend_servers {

    least_conn;

    server backend1:3000;
    server backend2:3000;
    server backend3:3000;
}
```

---

## IP Hash

A client tends to be sent to the same server based on its IP.

```nginx
upstream backend_servers {

    ip_hash;

    server backend1:3000;
    server backend2:3000;
}
```

---

# 13. Firewall

A firewall controls network traffic.

Think:

```text
Internet
   │
   ▼
Firewall
   │
   ├── Allow
   ├── Allow
   ├── Block
   └── Block
```

Example rules:

```text
Port 22  → SSH       → Allow
Port 80  → HTTP      → Allow
Port 443 → HTTPS     → Allow
Port 3306 → MySQL    → Block
```

---

# 14. Linux Firewall with UFW

Ubuntu commonly uses UFW.

Check status:

```bash
sudo ufw status
```

Enable:

```bash
sudo ufw enable
```

Allow SSH:

```bash
sudo ufw allow 22
```

Allow HTTP:

```bash
sudo ufw allow 80
```

Allow HTTPS:

```bash
sudo ufw allow 443
```

Block a port:

```bash
sudo ufw deny 3306
```

Delete a rule:

```bash
sudo ufw delete allow 80
```

---

# 15. Important Firewall Rule

If you are connected to a remote Ubuntu server using SSH, be careful.

Before enabling UFW, allow SSH:

```bash
sudo ufw allow ssh
```

Then:

```bash
sudo ufw enable
```

Otherwise, you can accidentally block your own SSH connection.

---

# 16. Caching Server

A caching server stores frequently requested data.

Without cache:

```text
User
 │
 ▼
Server
 │
 ▼
Database
```

Every request may require expensive processing.

With cache:

```text
User
 │
 ▼
Cache
 │
 ├── Cache HIT → Return data
 │
 └── Cache MISS
          │
          ▼
        Server
          │
          ▼
       Database
```

---

# 17. Why Use Caching?

Caching can:

* Reduce server load
* Reduce database queries
* Improve response time
* Reduce bandwidth
* Improve scalability

Common caching technologies:

* Redis
* Memcached
* Varnish
* Nginx cache

---

# 18. Redis Cache with Docker

Pull Redis:

```bash
docker pull redis
```

Run:

```bash
docker run -d \
  --name redis \
  -p 6379:6379 \
  redis
```

Check:

```bash
docker ps
```

Connect:

```bash
docker exec -it redis redis-cli
```

Set a value:

```redis
SET username sokhin
```

Get it:

```redis
GET username
```

Result:

```text
"sokhin"
```

---

# 19. Cache Architecture

Typical backend architecture:

```text
                Backend API
                    │
                    ▼
                  Redis
                    │
             Cache HIT?
              /       \
            YES       NO
             │         │
             ▼         ▼
          Return    Database
                       │
                       ▼
                    Store in
                     Redis
```

Example:

```text
GET /users/123

        ↓

Check Redis

        ↓

Found?
  │
  ├── YES → Return cached user
  │
  └── NO
       ↓
   PostgreSQL
       ↓
   Save to Redis
       ↓
   Return user
```

---

# 20. Web Server

A web server receives HTTP requests and returns responses.

Common web servers:

* Nginx
* Apache
* Caddy

Example:

```text
Browser
   │
   │ HTTP
   ▼
Web Server
   │
   ▼
HTML / CSS / JS
```

---

# 21. Nginx Web Server

Run Nginx:

```bash
docker run -d \
  --name web \
  -p 8080:80 \
  nginx
```

Open:

```text
http://localhost:8080
```

You should see the Nginx welcome page.

---

# 22. Serve Your Own Website

Create:

```text
website/
└── index.html
```

Example `index.html`:

```html
<!DOCTYPE html>
<html>
<head>
    <title>My Website</title>
</head>

<body>
    <h1>Hello Docker!</h1>
</body>
</html>
```

Run:

```bash
docker run -d \
  --name web \
  -p 8080:80 \
  -v ./website:/usr/share/nginx/html:ro \
  nginx
```

Now Nginx serves your local website.

```text
Your Computer
│
├── website/
│   └── index.html
│
│        ↓ volume
│
└── Docker
     │
     ▼
   Nginx
     │
     ▼
   :80
```

---

# 23. Forward Proxy vs Reverse Proxy

This is extremely important.

## Forward Proxy

```text
CLIENT
  │
  ▼
FORWARD PROXY
  │
  ▼
INTERNET
```

The proxy represents the:

```text
CLIENT
```

Used for:

* Internet access control
* Filtering
* Client anonymity
* Corporate networks
* Outbound traffic control

---

## Reverse Proxy

```text
CLIENT
  │
  ▼
REVERSE PROXY
  │
  ▼
SERVER
```

The proxy represents the:

```text
SERVER
```

Used for:

* Routing
* Load balancing
* SSL termination
* Caching
* Security
* Hiding backend servers

---

# 24. Reverse Proxy vs Load Balancer

They are related but not exactly the same.

Reverse proxy:

```text
Client
  ↓
Nginx
  ↓
Backend
```

Load balancer:

```text
Client
  ↓
Load Balancer
  ↓
┌───────┬───────┬───────┐
Server1 Server2 Server3
```

A reverse proxy **can perform load balancing**.

Nginx can therefore act as:

```text
Reverse Proxy
      +
Load Balancer
      +
Web Server
      +
Cache
```

---

# 25. Full Docker Architecture

Now combine everything:

```text
                         INTERNET
                             │
                             ▼
                       ┌──────────┐
                       │ Firewall │
                       └────┬─────┘
                            │
                            ▼
                   ┌─────────────────┐
                   │ Nginx           │
                   │ Reverse Proxy   │
                   │ Load Balancer   │
                   └────────┬────────┘
                            │
                 ┌──────────┼──────────┐
                 ▼          ▼          ▼
              Backend 1  Backend 2  Backend 3
                 │          │          │
                 └──────────┼──────────┘
                            │
                            ▼
                         Redis
                         Cache
                            │
                            ▼
                       PostgreSQL
```

---

# 26. Real-World Request Flow

Suppose a user requests:

```text
https://api.example.com/users
```

The request might flow like this:

```text
User
 │
 ▼
Internet
 │
 ▼
Firewall
 │
 ▼
Nginx
 │
 │ Reverse Proxy
 ▼
Load Balancer
 │
 ├── Backend 1
 ├── Backend 2
 └── Backend 3
       │
       ▼
     Redis
       │
       ├── HIT → Return data
       │
       └── MISS
            │
            ▼
        PostgreSQL
```

---

# 27. Docker Compose Practice Project

Create:

```text
devops-infrastructure/
│
├── compose.yaml
│
├── nginx/
│   └── nginx.conf
│
└── website/
    └── index.html
```

Your goal:

```text
                    Browser
                       │
                       ▼
                    Nginx
                 Reverse Proxy
                       │
              ┌────────┴────────┐
              ▼                 ▼
          Backend 1         Backend 2
              │                 │
              └────────┬────────┘
                       ▼
                     Redis
```

Start:

```bash
docker compose up -d
```

Check:

```bash
docker compose ps
```

Check logs:

```bash
docker compose logs -f
```

Stop:

```bash
docker compose down
```

---

# 28. Commands to Practise

## Docker

```bash
docker ps
docker ps -a

docker images

docker pull nginx

docker run

docker stop

docker start

docker restart

docker rm

docker logs

docker exec

docker inspect
```

## Docker Compose

```bash
docker compose up
docker compose up -d

docker compose ps

docker compose logs
docker compose logs -f

docker compose restart

docker compose down
```

## Linux Networking

```bash
ip addr
ip route

ping google.com

curl https://example.com

ss -tuln
```

## Firewall

```bash
sudo ufw status

sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443

sudo ufw deny 3306
```

---

# 29. Learning Order

Don't try to master everything at once.

Follow this order:

```text
1. Web Server
       ↓
2. Reverse Proxy
       ↓
3. Load Balancer
       ↓
4. Firewall
       ↓
5. Caching
       ↓
6. Forward Proxy
       ↓
7. Combine Everything
```

Recommended practical progression:

```text
Nginx
  ↓
Nginx + Docker
  ↓
Nginx Reverse Proxy
  ↓
Nginx + 2 Backend Containers
  ↓
Load Balancing
  ↓
Redis
  ↓
Firewall / UFW
  ↓
Forward Proxy / Squid
  ↓
Complete Infrastructure
```

---

# 30. What You Should Be Able to Explain

After practising, you should be able to answer:

### Web Server

> What is a web server?

```text
A server that receives HTTP requests and serves web content.
```

### Forward Proxy

> Who does a forward proxy represent?

```text
The client.
```

### Reverse Proxy

> Who does a reverse proxy represent?

```text
The server.
```

### Load Balancer

> What does a load balancer do?

```text
Distributes traffic across multiple backend servers.
```

### Firewall

> What does a firewall do?

```text
Controls which network traffic is allowed or blocked.
```

### Cache

> Why use a cache?

```text
To store frequently accessed data so it can be returned faster
and reduce load on backend systems.
```

---

# 31. DevOps Mental Model

Remember this:

```text
             SECURITY
                │
             Firewall
                │
                ▼
             TRAFFIC
                │
                ▼
          Reverse Proxy
                │
                ▼
          Load Balancer
                │
       ┌────────┼────────┐
       ▼        ▼        ▼
    Backend  Backend  Backend
       │        │        │
       └────────┼────────┘
                ▼
              Cache
                │
                ▼
             Database
```

And separately:

```text
Client
  │
  ▼
Forward Proxy
  │
  ▼
Internet
```

The key idea is:

```text
Forward Proxy  → protects/controls CLIENT traffic

Reverse Proxy  → protects/controls SERVER traffic

Load Balancer  → distributes SERVER traffic

Firewall       → controls NETWORK traffic

Cache          → speeds up repeated DATA access

Web Server     → serves WEB CONTENT
```

Once you understand these six pieces, you're moving from **"I know Docker commands"** toward **"I understand how a real server infrastructure works."**
