# Squid Forward Proxy Lab

A simple professional Docker-based lab for learning how a
Squid forward proxy works.

## Architecture

```text
Client / curl
     |
     | HTTP Proxy :3128
     v
+-------------------+
| Squid Forward     |
| Proxy             |
| :3128             |
+---------+---------+
          |
          | HTTP / HTTPS
          v
       Internet