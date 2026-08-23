# Docker Beginner Guide

Docker is a platform used to **build, package, run, and deploy applications inside containers**.

Instead of installing an application's dependencies directly on your server, Docker packages the application and its dependencies into a **container**.

---

# 1. What Is Docker?

Imagine you have a Node.js application.

Without Docker:

```text
Server
├── Node.js
├── npm
├── Application
├── Dependencies
├── Configuration
└── Environment setup
```

Another developer may have a different environment:

```text
Developer Computer
├── Different Node.js version
├── Different npm version
├── Different OS
└── Different dependencies
```

This can cause:

```text
"It works on my machine!"
```

Docker helps solve this problem.

With Docker:

```text
Docker Container
├── Application
├── Dependencies
├── Runtime
└── Configuration
```

The same container can run on:

```text
Developer PC
      ↓
Test Server
      ↓
Production Server
      ↓
Cloud Server
```

---

# 2. Container vs Virtual Machine

A virtual machine usually looks like:

```text
Physical Server
│
├── Host OS
│
├── VM 1
│   ├── Guest OS
│   └── Application
│
├── VM 2
│   ├── Guest OS
│   └── Application
```

Docker containers:

```text
Physical Server
│
├── Host OS
│
├── Docker
│
├── Container 1
│   └── Application
│
├── Container 2
│   └── Application
│
└── Container 3
    └── Application
```

Containers are generally lighter and faster to start because they share the host's kernel.

---

# 3. Important Docker Concepts

You should understand these terms:

| Concept        | Meaning                              |
| -------------- | ------------------------------------ |
| Docker Engine  | Runs Docker containers               |
| Image          | Template used to create containers   |
| Container      | Running instance of an image         |
| Dockerfile     | Instructions for building an image   |
| Docker Hub     | Public registry for Docker images    |
| Registry       | Storage for Docker images            |
| Volume         | Persistent container data            |
| Network        | Allows containers to communicate     |
| Docker Compose | Defines and runs multiple containers |

The basic relationship is:

```text
Dockerfile
    ↓
Docker Image
    ↓
Docker Container
```

---

# 4. Check Docker Installation

Check Docker version:

```bash
docker --version
```

Example:

```text
Docker version 28.x.x
```

More detailed information:

```bash
docker info
```

Check Docker installation:

```bash
docker run hello-world
```

If everything works, Docker will download the `hello-world` image and run a container.

---

# 5. Docker Images

An image is a **template** for creating containers.

List local images:

```bash
docker images
```

Modern equivalent:

```bash
docker image ls
```

Example:

```text
REPOSITORY    TAG       IMAGE ID       CREATED       SIZE
nginx         latest    abc123         2 days ago    188MB
ubuntu        latest    def456         5 days ago    78MB
```

---

# 6. Download an Image

Use:

```bash
docker pull nginx
```

This downloads the Nginx image.

You can specify a version:

```bash
docker pull nginx:latest
```

Or:

```bash
docker pull nginx:1.27
```

General format:

```bash
docker pull IMAGE:TAG
```

---

# 7. Run a Container

Run Nginx:

```bash
docker run nginx
```

Docker will:

```text
Find image
   ↓
Download image if necessary
   ↓
Create container
   ↓
Start container
```

---

# 8. Run in Background

Normally:

```bash
docker run nginx
```

runs in the foreground.

Use `-d` for detached mode:

```bash
docker run -d nginx
```

Example output:

```text
a8f3c1...
```

That value is the container ID.

---

# 9. Give a Container a Name

Instead of using a random name:

```bash
docker run -d --name my-nginx nginx
```

Now the container is called:

```text
my-nginx
```

---

# 10. List Containers

Show running containers:

```bash
docker ps
```

Show all containers:

```bash
docker ps -a
```

Modern syntax:

```bash
docker container ls
```

All containers:

```bash
docker container ls -a
```

---

# 11. Stop a Container

Stop:

```bash
docker stop my-nginx
```

Or using the container ID:

```bash
docker stop CONTAINER_ID
```

---

# 12. Start a Stopped Container

```bash
docker start my-nginx
```

---

# 13. Restart a Container

```bash
docker restart my-nginx
```

---

# 14. Remove a Container

First stop it:

```bash
docker stop my-nginx
```

Then remove it:

```bash
docker rm my-nginx
```

Force remove:

```bash
docker rm -f my-nginx
```

---

# 15. Port Mapping

This is one of the most important Docker concepts.

Suppose Nginx inside the container listens on:

```text
Port 80
```

You can expose it to your computer:

```bash
docker run -d --name my-nginx -p 8080:80 nginx
```

The format is:

```text
-p HOST_PORT:CONTAINER_PORT
```

So:

```text
Computer
   │
   │ localhost:8080
   ↓
Docker
   │
   │ container port 80
   ↓
Nginx
```

Open:

```text
http://localhost:8080
```

---

# 16. Environment Variables

Containers can receive environment variables using `-e`.

Example:

```bash
docker run -e APP_ENV=production nginx
```

Multiple variables:

```bash
docker run \
  -e APP_ENV=production \
  -e API_URL=https://api.example.com \
  nginx
```

Check environment variables:

```bash
docker inspect my-nginx
```

---

# 17. Execute Commands Inside a Container

Run a shell inside a running container:

```bash
docker exec -it my-nginx bash
```

If Bash isn't available:

```bash
docker exec -it my-nginx sh
```

Now you are inside the container:

```text
root@container:/#
```

Try:

```bash
ls
```

Then:

```bash
exit
```

---

# 18. View Container Logs

```bash
docker logs my-nginx
```

Follow logs:

```bash
docker logs -f my-nginx
```

This is extremely useful when debugging applications.

---

# 19. Inspect a Container

```bash
docker inspect my-nginx
```

This provides detailed information such as:

```text
Container ID
Image
Network
IP Address
Ports
Environment Variables
Volumes
Configuration
```

---

# 20. Dockerfile

A `Dockerfile` contains instructions for building an image.

Example:

```dockerfile
FROM nginx:latest

COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80
```

Project:

```text
my-project/
├── Dockerfile
└── index.html
```

---

# 21. Build an Image

Inside the project directory:

```bash
docker build -t my-nginx .
```

Explanation:

```text
docker build
    ↓
Build an image

-t my-nginx
    ↓
Give image a name

.
    ↓
Use current directory as build context
```

Check the image:

```bash
docker images
```

---

# 22. Run Your Own Image

```bash
docker run -d --name my-web -p 8080:80 my-nginx
```

Now:

```text
Browser
   ↓
localhost:8080
   ↓
Docker Container
   ↓
Nginx :80
   ↓
index.html
```

---

# 23. Dockerfile Instructions

Common Dockerfile instructions:

| Instruction  | Purpose                                          |
| ------------ | ------------------------------------------------ |
| `FROM`       | Select base image                                |
| `WORKDIR`    | Set working directory                            |
| `COPY`       | Copy files into image                            |
| `ADD`        | Copy files, with additional archive/URL behavior |
| `RUN`        | Execute command during image build               |
| `CMD`        | Default command when container starts            |
| `ENTRYPOINT` | Configure the main executable                    |
| `EXPOSE`     | Document intended container port                 |
| `ENV`        | Set environment variable                         |
| `ARG`        | Define build-time variable                       |
| `USER`       | Set user                                         |
| `VOLUME`     | Declare mount point                              |

---

# 24. Example Node.js Dockerfile

Suppose you have:

```text
node-app/
├── package.json
├── package-lock.json
└── server.js
```

Dockerfile:

```dockerfile
FROM node:22

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3000

CMD ["node", "server.js"]
```

Build:

```bash
docker build -t node-app .
```

Run:

```bash
docker run -d --name node-app -p 3000:3000 node-app
```

Open:

```text
http://localhost:3000
```

---

# 25. Volumes

Containers are usually considered disposable.

If you delete a container, data stored only inside that container can disappear.

Volumes provide persistent storage.

Create a volume:

```bash
docker volume create my-data
```

List volumes:

```bash
docker volume ls
```

Run a container with a volume:

```bash
docker run -d \
  --name mysql \
  -v mysql-data:/var/lib/mysql \
  mysql
```

The structure is:

```text
Docker Volume
     │
     ↓
Container
     │
     ↓
Application Data
```

Even if the container is removed, the volume can remain.

---

# 26. Bind Mounts

A bind mount connects a directory on your computer to a directory inside the container.

Example:

```bash
docker run -d \
  -v $(pwd):/app \
  node-app
```

Meaning:

```text
Current computer directory
        │
        ↓
      /app
   Container
```

This is very useful during development.

---

# 27. Docker Networks

Containers can communicate through Docker networks.

List networks:

```bash
docker network ls
```

Create a network:

```bash
docker network create my-network
```

Run containers on the network:

```bash
docker run -d \
  --name backend \
  --network my-network \
  node-app
```

Another container:

```bash
docker run -d \
  --name database \
  --network my-network \
  postgres
```

The containers can communicate using their container names.

For example:

```text
backend → database
```

The backend can connect to:

```text
database:5432
```

instead of using an IP address.

---

# 28. Docker Compose

When your application needs multiple services, Docker Compose becomes very useful.

Example application:

```text
Application
│
├── Frontend
├── Backend
└── PostgreSQL
```

Instead of running three commands manually, define everything in:

```text
compose.yaml
```

Example:

```yaml
services:

  backend:
    build: .
    ports:
      - "3000:3000"
    depends_on:
      - database

  database:
    image: postgres:17
    environment:
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: password
      POSTGRES_DB: app
```

Start:

```bash
docker compose up
```

Run in background:

```bash
docker compose up -d
```

Stop:

```bash
docker compose down
```

View services:

```bash
docker compose ps
```

View logs:

```bash
docker compose logs
```

Follow logs:

```bash
docker compose logs -f
```

---

# 29. Docker Image Lifecycle

The typical Docker workflow is:

```text
Dockerfile
    ↓
docker build
    ↓
Docker Image
    ↓
docker run
    ↓
Docker Container
    ↓
docker logs / exec / inspect
    ↓
docker stop
    ↓
docker rm
```

---

# 30. Docker Registry

A registry stores Docker images.

A common public registry is Docker Hub.

Typical workflow:

```text
Developer
    ↓
docker build
    ↓
Docker Image
    ↓
docker push
    ↓
Docker Registry
    ↓
Production Server
    ↓
docker pull
    ↓
docker run
```

Login:

```bash
docker login
```

Tag an image:

```bash
docker tag my-app username/my-app:1.0
```

Push:

```bash
docker push username/my-app:1.0
```

Pull:

```bash
docker pull username/my-app:1.0
```

---

# 31. Useful Docker Commands

| Command               | Purpose                           |
| --------------------- | --------------------------------- |
| `docker --version`    | Show Docker version               |
| `docker info`         | Show Docker system information    |
| `docker images`       | List images                       |
| `docker pull`         | Download image                    |
| `docker build`        | Build image                       |
| `docker run`          | Create and start container        |
| `docker ps`           | List running containers           |
| `docker ps -a`        | List all containers               |
| `docker start`        | Start container                   |
| `docker stop`         | Stop container                    |
| `docker restart`      | Restart container                 |
| `docker rm`           | Remove container                  |
| `docker rmi`          | Remove image                      |
| `docker logs`         | View container logs               |
| `docker exec`         | Execute command in container      |
| `docker inspect`      | Inspect container/image           |
| `docker cp`           | Copy files between host/container |
| `docker stats`        | Show container resource usage     |
| `docker system df`    | Show Docker disk usage            |
| `docker volume ls`    | List volumes                      |
| `docker network ls`   | List networks                     |
| `docker compose up`   | Start Compose application         |
| `docker compose down` | Stop Compose application          |

---

# 32. Docker Cleanup

Remove stopped containers:

```bash
docker container prune
```

Remove unused images:

```bash
docker image prune
```

Remove unused volumes:

```bash
docker volume prune
```

Remove unused Docker resources:

```bash
docker system prune
```

Be careful with cleanup commands because they can delete resources you still need.

---

# 33. Important Docker Command Patterns

### Run a container

```bash
docker run IMAGE
```

### Run in background

```bash
docker run -d IMAGE
```

### Give it a name

```bash
docker run -d --name NAME IMAGE
```

### Map a port

```bash
docker run -d -p HOST_PORT:CONTAINER_PORT IMAGE
```

### Set environment variable

```bash
docker run -d -e KEY=VALUE IMAGE
```

### Mount a volume

```bash
docker run -d -v VOLUME:/PATH IMAGE
```

### Run with multiple options

```bash
docker run -d \
  --name my-app \
  -p 8080:3000 \
  -e NODE_ENV=production \
  my-app
```

---

# 34. Docker vs Docker Compose

Use Docker directly when you have a simple application:

```text
One application
      ↓
One container
      ↓
docker run
```

Use Docker Compose when you have multiple services:

```text
        Compose
           │
    ┌──────┼──────┐
    ↓      ↓      ↓
Frontend Backend Database
```

For example:

```text
Flutter/Web App
      ↓
Backend API
      ↓
PostgreSQL
      ↓
Redis
```

Docker Compose can manage all of these together.

---

# 35. Docker in DevOps

Docker is important because it fits naturally into CI/CD.

A typical DevOps pipeline:

```text
Developer
    ↓
Git Push
    ↓
GitHub / GitLab
    ↓
CI/CD Pipeline
    ↓
Run Tests
    ↓
docker build
    ↓
Docker Image
    ↓
docker push
    ↓
Container Registry
    ↓
Production Server
    ↓
docker pull
    ↓
docker run
```

Later, Kubernetes can manage many Docker-compatible containers across multiple servers.

---

# 36. Docker Learning Roadmap

Learn Docker in this order:

```text
1. What is Docker?
       ↓
2. Images
       ↓
3. Containers
       ↓
4. docker run
       ↓
5. Ports
       ↓
6. Environment Variables
       ↓
7. Dockerfile
       ↓
8. docker build
       ↓
9. Volumes
       ↓
10. Networks
       ↓
11. Docker Compose
       ↓
12. Docker Registry
       ↓
13. Docker + CI/CD
       ↓
14. Docker + Cloud
       ↓
15. Kubernetes
```

---

# 37. Beginner Practice

## Practice 1 — Run Nginx

```bash
docker run -d --name nginx-test -p 8080:80 nginx
```

Check:

```bash
docker ps
```

Open:

```text
http://localhost:8080
```

Then stop:

```bash
docker stop nginx-test
```

Remove:

```bash
docker rm nginx-test
```

---

## Practice 2 — Run Ubuntu

```bash
docker run -it ubuntu bash
```

Inside the container:

```bash
ls
pwd
cat /etc/os-release
```

Exit:

```bash
exit
```

---

## Practice 3 — Build Your First Image

Create:

```text
docker-practice/
├── Dockerfile
└── index.html
```

Dockerfile:

```dockerfile
FROM nginx:latest

COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80
```

Build:

```bash
docker build -t my-first-image .
```

Run:

```bash
docker run -d \
  --name my-first-container \
  -p 8080:80 \
  my-first-image
```

Then open:

```text
http://localhost:8080
```

---

# 38. The Most Important Things to Remember

```text
Dockerfile
    ↓
Build
    ↓
Image
    ↓
Run
    ↓
Container
```

Remember:

```text
IMAGE      = Template
CONTAINER  = Running instance
VOLUME     = Persistent data
NETWORK     = Container communication
REGISTRY    = Image storage
COMPOSE     = Multiple containers
```

And the most important commands to memorize first:

```bash
docker pull
docker images
docker build
docker run
docker ps
docker stop
docker start
docker rm
docker logs
docker exec
docker inspect
docker volume
docker network
docker compose
```

---

# 39. DevOps Mental Model

As a DevOps learner, think about Docker like this:

```text
                    DOCKER

              ┌───────────────┐
              │   Dockerfile  │
              └───────┬───────┘
                      │
                   BUILD
                      ↓
              ┌───────────────┐
              │     IMAGE     │
              └───────┬───────┘
                      │
                    RUN
                      ↓
              ┌───────────────┐
              │   CONTAINER   │
              └───────┬───────┘
                      │
             ┌────────┼────────┐
             ↓        ↓        ↓
          Network   Volume    Port
             │        │        │
             └────────┼────────┘
                      ↓
                 Application
```

Once you understand this model, Docker becomes much easier to learn.
