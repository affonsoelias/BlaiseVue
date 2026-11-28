# Zephyr Backend Roadmap (`v0.1.0` -> `v1.0.0`)

> **Simple & Expressive like Horse. Enterprise-Complete & Fast like mORMot 2.**  
> Written natively in **DelSafe** with zero-GC safety, compile-time ownership/contracts, and dual native compilation to **GCC C99** and **Free Pascal**.

---

## Vision & Design Principles

Zephyr exists to bridge two worlds in the Pascal & DelSafe ecosystem:

1. **Horse-Style Ergonomics (Zero Boilerplate):**
   - Start an API in ~5 lines (`NewServer(8091)`, `srv.Get("/users/:id", ...)`, `srv.Use(...)`, `srv.Group("/api/v1", ...)`).
   - Clean `Request`/`Response` builders, middleware pipelines, and instant `bv zephyr init` / `bv zephyr run` developer workflow.
2. **mORMot 2 Enterprise Power (Batteries Included):**
   - Native ORM, Multi-Database drivers, Interface-based SOA/RPC, bidirectional WebSocket callbacks, RBAC + JWT + modern cryptography, high-speed rotating/compressed logging, in-memory & distributed caching, DDD/CQRS/Unit-of-Work, background jobs, server-side PDF/reporting, and clustering.
3. **DelSafe-Native Safety & Dual Backend:**
   - Memory safety via static ownership (`take`, `borrow`, `mut borrow`), design-by-contract (`require`/`ensure`), metaprogramming (`[derive(JSON, ORM, Equals)]`), and native binaries compiled via both **C99 (`-O3 -flto`)** and **Free Pascal**.

```delsafe
// Target developer experience: Horse simplicity + mORMot power
srv := NewServer(8091);
srv.Use(Logger(), Compression(), Cors());
srv.AutoRest(Order);                  // 1-line ORM CRUD + pagination + OpenAPI
srv.AddService(IOrderService);        // Shared Pascal/DelSafe SOA contract
srv.ListenAndServe();
```

---

## Capability Parity Matrix (Horse + mORMot 2 -> Zephyr)

| Enterprise Pillar | Inspiration | Current (`v0.1.0`) | Target Milestone |
| :--- | :--- | :--- | :--- |
| Declarative Routing & JSON Helpers | Horse | `AddGet/Post/Put/Delete/Patch`, `OkJson` | `v0.1.0` -> `v0.2.0` (`:params`, `Group`, `Use`) |
| Middleware Pipeline & Uploads | Horse | Global CORS, OWASP, `RateLimiter` | `v0.2.0` (`Next()`, Gzip, ETag, `multipart`, `Range`) |
| High-Concurrency Engine, TLS & HTTP/2 | mORMot 2 | Single-accept HTTP/1.1 + WS | `v0.3.0` (`epoll`/`kqueue`/`IOCP`, pool, TLS, HTTP/2, SSE) |
| ORM, Query Builder & Multi-DB | mORMot 2 | Direct JSON structs (`[derive(JSON)]`) | `v0.4.0` (`[derive(ORM)]`, SQLite/PG/MySQL/FB/MSSQL) |
| Auto-REST CRUD & Migrations | mORMot 2 | Manual handlers | `v0.4.0` (`AutoRest`, `bv zephyr migrate`) |
| Interface SOA / RPC & WS Callbacks | mORMot 2 | Raw WS echo handlers | `v0.5.0` (Shared contracts, JSON/Binary RPC, OpenAPI 3.1) |
| Authentication, RBAC & Modern Crypto | mORMot 2 | `auth_token` field + IP/token rate limit | `v0.6.0` (JWT/OAuth2/OIDC, RBAC, Argon2id, AES-GCM, Ed25519) |
| Caching, Event Bus, Jobs, DDD & PDF | mORMot 2 | Stateless handlers | `v0.7.0` (LRU/Redis, queues, Cron, CQRS, Mustache/PDF) |
| High-Speed Logger & Observability | mORMot 2 (`TSynLog`) | Console status output | `v0.8.0` (Rotating/compressed logs, Prometheus, OTel, benchmarks) |
| Clustering & Production Packaging | mORMot 2 | Local binary via `bv zephyr deploy` hook | `v0.9.0` (Service discovery, proxy, systemd/WinSvc/Docker) |

---

## Milestones

### `v0.1.0` — Native Foundation (Delivered)
- HTTP/1.1 Keep-Alive foundation and zero-dependency HTTP parser/serializer (`src/zephyr_http.dels`).
- Declarative route table (`AddGet`, `AddPost`, `AddPut`, `AddDelete`, `AddPatch`, `AddWs`) and static SPA hosting with MIME type detection (`src/zephyr.dels`).
- Pure DelSafe RFC 6455 WebSocket implementation with RFC 3174 SHA-1 and RFC 4648 Base64 (`src/zephyr_ws.dels`).
- Security baseline: IP & token `RateLimiter`, path traversal guard, CORS, and OWASP security headers (`src/zephyr_security.dels`).
- Native `[derive(JSON, Equals)]` payload serialization and `contract require/ensure` validation (`examples/zephyr_demo.dels`).
- Dual-backend test suite (`tests/zephyr_test.dels` via `delsafec test --target=all`) and BlaiseVue CLI integration (`bv zephyr init/build/run/status`).

### `v0.2.0` — Horse-Style DX, Dynamic Routing & Middleware Pipeline
- Radix-tree / segmented router supporting path parameters (`/users/:id`), optional segments, and catch-all wildcards (`/files/*filepath`).
- Route groups (`srv.Group("/api/v1")`) with scoped prefixing and middleware inheritance.
- Composable middleware pipeline (`srv.Use(mw)` + `Next(req)`):
  - Built-in middlewares: Request Logger, Panic/Exception Recovery, Response Compression (`gzip`/`deflate`), `ETag`/`304 Not Modified`, Request ID, and Body Limit.
- Ergonomic Request/Response helpers: typed query/path/header extractors, cookies (`GetCookie`/`SetCookie`), `Redirect`, `Download`, `StreamFile`, HTTP `Range` requests (partial content), and `multipart/form-data` streaming uploads.
- Content negotiation (`Accept` JSON/HTML/text) and zero-boilerplate Horse-style fluent aliases (`srv.Get(...)`, `res.Status(201).Json(...)`).

### `v0.3.0` — Multi-Threaded Concurrency, Async I/O, TLS & HTTP/2
- True multi-connection Keep-Alive worker loop backed by DelSafe OS threads (`std/sync`, `Channel<T>`).
- Non-blocking I/O multiplexing (`IOCP` on Windows, `epoll` on Linux, `kqueue` on macOS) with configurable worker pool sizing.
- Graceful shutdown (`SIGINT`/`SIGTERM` draining in-flight requests cleanly).
- Native TLS 1.2 / 1.3 (`https://` and `wss://`) + ALPN negotiation and HTTP/2 multiplexing.
- Server-Sent Events (`SSE`) streaming helper (`res.Sse(...)`).
- Full WebSocket protocol upgrade: binary frames (`0x2`), fragmented frames, automatic Ping/Pong heartbeats, pub/sub rooms, and broadcast helpers.

### `v0.4.0` — Native ORM, Multi-Database & Auto-REST *(mORMot ORM Pillar)*
- Compile-time ORM metaprogramming (`[derive(ORM, JSON)]`) with strong Pascal/DelSafe record mapping, table/column attributes, indexes, optimistic concurrency versioning, soft deletes (`deleted_at`), and automatic audit timestamps (`created_at`/`updated_at`).
- Native connection pools and parameterized prepared statements (SQL-injection proof) across:
  - **SQLite3** (embedded default), **PostgreSQL**, **MySQL / MariaDB**, **Firebird**, and **MSSQL / ODBC**.
- Fluent type-safe Query Builder (`Where`, `OrderBy`, `Limit/Offset`, `Join`, `Select`, aggregations) + relationship loaders (`1:1`, `1:N`, `N:N` eager/lazy loading).
- Transactions (`Begin/Commit/Rollback`) with nested savepoint support and high-speed bulk/batch inserts/updates.
- Schema diffing & CLI migrations (`bv zephyr migrate create|up|status`).
- 1-line mORMot-style Auto-REST resource exposure (`srv.AutoRest<T>("/api/products")`) with automatic filtering, sorting, pagination, field selection, and OpenAPI schema metadata.

### `v0.5.0` — Interface-Based SOA, RPC & Shared Contracts *(mORMot SOA Pillar)*
- Declare backend service interfaces in shared DelSafe/Object Pascal contracts compiled once for both server (`vendor/zephyr`) and BlaiseVue frontend (`common/contracts`).
- Automatic JSON-RPC / REST dispatcher exposing typed service methods over HTTP with automatic parameter/return JSON marshaling (`[derive(JSON)]`) and `contract require/ensure` validation -> HTTP `400`/`422`.
- Optional compact binary framing protocol for ultra-low-latency internal service-to-service RPC.
- Bidirectional real-time WebSocket interface callbacks (server pushes typed events directly to subscribed BlaiseVue clients, mirroring mORMot WebSocket SOA).
- Automatic client proxy codegen for BlaiseVue (`BVRpc`/`BVClient`), DelSafe, Delphi, and Free Pascal.
- Auto-generated OpenAPI 3.1 JSON spec (`/openapi.json`) and built-in Swagger UI (`/docs`).

### `v0.6.0` — Enterprise Authentication, RBAC & Cryptography *(mORMot Auth Pillar)*
- Pluggable authentication middleware & session manager:
  - **JWT** (`HS256`, `RS256`, `EdDSA`) with short-lived access tokens and refresh-token rotation/revocation.
  - **OAuth2 / OpenID Connect (OIDC)** social & corporate SSO integration.
  - Scoped **API Keys** and session cookies (`HttpOnly`, `SameSite`, `Secure`).
- mORMot-style **Granular RBAC** (`AuthUser`, `AuthGroup`, role/permission guards) assignable per route, Auto-REST entity, SOA service interface, or field projection.
- Built-in modern cryptography module (`ZephyrCrypto`): password hashing (`Argon2id` / `PBKDF2`), authenticated encryption (`AES-256-GCM` / `ChaCha20-Poly1305`), `HMAC-SHA256/512`, `Ed25519` signatures, and constant-time CSPRNG tokens.
- Anti-CSRF protection, account lockout policies, and tamper-evident security audit log events.

### `v0.7.0` — Caching, Messaging, Background Jobs, DDD & Reporting *(mORMot Enterprise Pillar)*
- **High-Speed Cache (`ZephyrCache`):** lock-striped / thread-safe in-memory LRU + TTL cache with tag invalidation and pluggable Redis / Valkey adapter.
- **Event Bus & Messaging:** in-process typed Pub/Sub (`EventBus`) + Redis Streams / RabbitMQ bridge for decoupled microservices.
- **Background Jobs & Scheduler:** persistent async job queues with retries, exponential backoff, Dead-Letter Queues (DLQ), and declarative Cron jobs.
- **DDD / CQRS Primitives:** Aggregate Root helpers, Domain Events, Repository & Unit-of-Work abstractions, and Command/Query bus.
- **Templating & Server-Side Reporting:** Mustache/HTML template engine for server-rendered views/emails + native PDF/report generator compatible with BlaiseVue reporting workflows.

### `v0.8.0` — High-Speed Logging, Observability & Benchmarks *(mORMot Ops Pillar)*
- **High-Throughput Structured Logger (`ZephyrLog`, inspired by `TSynLog`):** non-blocking ring-buffered JSON/text logging, size/date rotation, `.gz`/`.zst` archival compression, and automatic request correlation IDs.
- **Metrics & Health Probes:** Prometheus `/metrics` endpoint (latency histograms, throughput, pool utilization, active WS connections), `/health/live`, and `/health/ready`.
- **Distributed Tracing:** W3C `traceparent` propagation + OpenTelemetry OTLP exporter.
- **Official Benchmark Suite:** reproducible `wrk`/`bombardier` benchmarks comparing Zephyr (C99 & FPC), mORMot 2, and Horse across plaintext, JSON, ORM Postgres/SQLite queries, and WebSocket fan-out.

### `v0.9.0` — Clustering, Microservices & Production Deployment
- Built-in lightweight service discovery, health-checked reverse proxy, and HTTP load balancer helpers.
- Distributed cache invalidation and WebSocket pub/sub synchronization across cluster nodes.
- Database read/write splitting (primary/replica routing) and connection circuit breakers.
- Seamless `bv zephyr deploy` targets: single static stripped binary (`C99 -O3 -flto` / FPC), Linux `systemd` service unit, Windows Service wrapper, and minimal distroless Docker/OCI images.

### `v1.0.0` — Production LTS & Ecosystem Stability
- Public API freeze under Semantic Versioning (`1.x` compatibility guarantee).
- Full cross-platform CI E2E test matrix (Windows, Linux, macOS; both C99 and Free Pascal backends) + HTTP/WebSocket protocol fuzzing and security audit.
- Dedicated migration & quickstart guides: **"Zephyr for Horse Developers"** and **"Zephyr for mORMot 2 Developers"**.
