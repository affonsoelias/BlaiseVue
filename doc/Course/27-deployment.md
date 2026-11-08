# 🐳 Module 27: Micro-Containers, CI/CD & Deployment
**Deploy sub-20MB production micro-containers with multi-stage Docker builds and automated CI/CD.**

In modern cloud environments (Kubernetes, AWS ECS, Google Cloud Run, DigitalOcean), container image size and startup latency directly dictate your cloud hosting bills and auto-scaling responsiveness.

Traditional web applications built with Node.js, Python, or Ruby produce bloated Docker images ranging from **800 MB to 1.5 GB**, requiring dozens of seconds to spin up.

Because BlaiseVue compiles to static web assets and native Object Pascal machine code via Free Pascal and mORMot 2, your entire production stack can be packaged into an ultra-lean **micro-container under 20 MB** with **sub-second boot times**!

---

## 🛠️ 1. Scaffolding Containers with `bv mormot docker`

To generate production-hardened container infrastructure, run:

```bash
bv mormot docker

# Alias:
bv mormot container
```

This generates three production-ready files:
1. `Dockerfile`: High-performance, multi-stage build configuration.
2. `docker-compose.yml`: Local and staging orchestration with port mapping and healthcheck integration.
3. `.dockerignore`: Lean build rules filtering out local build artifacts, `.git`, and development logs.

If Docker is running on your machine, you can scaffold and build the container in a single step:

```bash
bv mormot docker --build
```

---

## 🏗️ 2. Anatomy of the Multi-Stage `Dockerfile`

The generated `Dockerfile` employs modern multi-stage compilation to keep the final image completely free of compilers and development tools:

```dockerfile
# ======================================================================
# STAGE 1: Compile Native mORMot 2 Backend (Free Pascal)
# ======================================================================
FROM debian:bookworm-slim AS backend-builder
RUN apt-get update && apt-get install -y fpc binutils && rm -rf /var/lib/apt/lists/*
WORKDIR /build
COPY server/ ./server/
COPY vendor/ ./vendor/
RUN cd server && fpc -O3 -Xs -XX -vewnhi server.lpr -o../bin/server

# ======================================================================
# STAGE 2: Compile Frontend SPA Web Assets
# ======================================================================
FROM node:20-alpine AS frontend-builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build -- --release

# ======================================================================
# STAGE 3: Ultra-Lean Production Runtime (Alpine Linux)
# ======================================================================
FROM alpine:3.20 AS runtime
RUN apk add --no-cache ca-certificates gcompat curl

# Create non-root system user for security
RUN addgroup -g 1001 -S blaise && adduser -u 1001 -S blaise -G blaise
WORKDIR /app

# Copy compiled native server binary and frontend web assets
COPY --from=backend-builder --chown=blaise:blaise /build/bin/server ./server
COPY --from=frontend-builder --chown=blaise:blaise /app/dist ./dist

# Native Healthcheck hitting the mORMot 2 status endpoint
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD curl -f http://localhost:8090/api/status || exit 1

USER blaise
EXPOSE 8090
ENTRYPOINT ["./server"]
```

### 🏆 The Result:
- **Total Image Size**: **~ 18 MB** (over 98% smaller than typical web containers!).
- **Cold Boot Time**: **~ 15 milliseconds**.
- **Memory Consumption**: Under **12 MB of RAM** under normal load!

---

## 🚢 3. Running with Docker Compose

To start and verify your containerized application:

```bash
# Start container in detached background mode
docker compose up -d

# Check running status and healthcheck
docker compose ps

# View live server logs
docker compose logs -f

# Stop and remove containers
docker compose down
```

Open `http://localhost:8090` in your browser. The native mORMot 2 server inside the Alpine container serves your reactive SPA and dispatches API requests!

---

## 🔄 4. Automated CI/CD with GitHub Actions

Here is a ready-to-use GitHub Actions workflow (`.github/workflows/deploy.yml`) to automatically test, build, and publish your container on every push to `main`:

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main ]

jobs:
  test-and-build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 20

      - name: Install Dependencies & Run Tests
        run: |
          npm ci
          npx bv test
          npx bv test e2e

      - name: Build Docker Micro-Container
        run: |
          docker build -t my-blaisevue-app:latest .

      - name: Verify Container Image Size
        run: |
          docker images my-blaisevue-app:latest
```

---

## 🏋️ Practical Exercise

1. Inside your project, run `bv mormot docker` to scaffold the containerization suite.
2. Inspect the generated `Dockerfile` and `docker-compose.yml`.
3. If Docker Desktop is installed, run `docker compose up -d --build`.
4. Run `docker compose ps` to verify that the healthcheck reports `(healthy)`.
5. Visit `http://localhost:8090/api/status` to confirm the server response from within the container!

---

## 📖 Deeper Technical Reference

- **[Cloud-Native Micro-Containers in mORMot 2](../Documentation/37-mormot2-backend.md#cloud-native-micro-containers-bv-mormot-docker)**: Detailed guide on Alpine compatibility layers (`gcompat`), non-root container security, volume persistence for databases, and Kubernetes pod specs.

---

[⬅️ Module 26: Unit & E2E Testing Automation](26-testing.md) | [🏠 Course Index](README.md) | [Module 28: Capstone Enterprise Challenge ➡️](28-capstone.md)
