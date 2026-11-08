# ⚡ Module 15: Full-Stack mORMot 2 Setup & Architecture
**Unlock the power of 100% Pascal across the entire stack: from reactive web components to native microservices.**

Historically, web development forced Pascal programmers into an uncomfortable compromise: write your desktop backend in Delphi or Free Pascal, but then switch to JavaScript, Python, or Go to build your web APIs and backend services.

**BlaiseVue changes everything.** By combining BlaiseVue (reactive frontend transpiled to JavaScript via `pas2js`) with **Synopse mORMot 2** (the fastest native Object Pascal server engine in the world), you can now build **100% Full-Stack Object Pascal applications**!

---

## 🏛️ 1. Full-Stack Pascal Architecture Overview

```text
┌────────────────────────────────────────────────────────┐
│         BlaiseVue Reactive Frontend (.bv / SPA)        │
│    Built-in $api (REST Client) & $ws (WebSocket Client)│
└──────────────────────────┬─────────────────────────────┘
                           │ HTTP REST (JSON) & WebSocket Frames
                           │ (ws://localhost:8090/blaise-ws)
┌──────────────────────────▼─────────────────────────────┐
│          Synopse mORMot 2 Native Backend Server        │
│         (server/server.lpr, server/ServerApp.pas)      │
├────────────────────────────────────────────────────────┤
│  [+] Asynchronous Non-blocking HTTP Server Engine      │
│  [+] Real-time WebSocket Protocol (TWebSocketServer)   │
│  [+] Built-in CORS Handler for Web Dev                 │
│  [+] Static SPA Host (dist/) with History Fallback     │
│  [+] Shared Records / DTOs (ServerModels.pas)          │
└────────────────────────────────────────────────────────┘
```

### Why mORMot 2 for the Backend?
- **Blazing Performance**: Native compiled x86_64 or ARM64 binary. Capable of handling over 50,000 requests per second with sub-millisecond response times.
- **Zero Runtime Dependencies**: The compiled server executable requires **no Node.js, no Python runtime, no JVM, and no external web servers** (like Nginx or Apache) to run!
- **Unified Language**: Share your records, schemas, calculation algorithms, and business logic between frontend and backend.

---

## 🛠️ 2. Initializing the Backend with `bv mormot init`

Inside any existing BlaiseVue project, initializing a production-ready mORMot 2 backend takes a single command:

```bash
# 1. Initialize default backend with embedded SQLite3
bv mormot init

# 2. Or initialize with an enterprise SQL engine:
bv mormot init --db postgres    # PostgreSQL
bv mormot init --db mysql       # MySQL / MariaDB
bv mormot init --db firebird    # Firebird SQL
```

### 📂 What Gets Created in `server/`:

```text
my-project/
├── server/
│   ├── server.lpi           # Lazarus IDE project file
│   ├── server.lpr           # Console entry point & CLI startup parser
│   ├── ServerApp.pas        # HTTP router, WebSockets & static SPA server
│   ├── ServerModels.pas     # Shared Pascal records & JSON DTOs
│   ├── DatabaseConfig.pas   # Pluggable SQL database connection layer
│   └── README.md            # Backend developer guide
├── src/                     # BlaiseVue reactive frontend components
├── dist/                    # Compiled SPA web assets
└── app.cfg                  # BlaiseVue project config
```

> [!NOTE]
> **Zero External Downloads**: The complete **mORMot 2** framework is pre-bundled with BlaiseVue inside the embedded `vendor/mormot2/` folder. You do not need to hunt for external Git submodules or install third-party packages to get started.

---

## 🏃 3. Running and Building the Native Server

The BlaiseVue CLI provides high-level commands to manage the server lifecycle:

### Starting the Server in Development:
```bash
# Launch server on default port 8090 (Debug mode)
bv mormot run

# Launch on a custom port
bv mormot run --port 8080

# Clean-start: automatically terminates any lingering server instances
bv mormot run --fresh
```

When you run `bv mormot run`, the CLI compiles `server/server.lpr` with Free Pascal and prints the startup banner:

```text
============================================================
       BlaiseVue + Synopse mORMot 2 Native Server v5.0
============================================================
[*] HTTP Service Listening:  http://localhost:8090
[*] REST API Endpoint:       http://localhost:8090/api/
[*] WebSocket Endpoint:      ws://localhost:8090/blaise-ws
[*] Static SPA Root:         ./dist
============================================================
```

### Checking Status and Terminating:
```bash
# Query health and uptime (/api/status)
bv mormot status

# Gracefully terminate the running server process
bv mormot kill
```

---

## 🚀 4. Compiling for Production & Standalone Deployment

When you're ready to ship to a production server, run:

```bash
# Builds optimized frontend (dist/) and optimized native backend binary
bv mormot build --release

# Or generate a complete standalone deployment package:
bv mormot deploy --zip
```

### The Standalone `deploy/` Folder:
The `deploy/` folder contains:
1. `server.exe` (or `server` on Linux) — Compiled with `-O3 -Xs` (under 2 MB, fully stripped).
2. `dist/` — Your minified frontend SPA.
3. `start.bat` / `start.sh` — 1-click startup scripts.

To deploy, simply copy the `deploy/` directory to any Windows or Linux server and execute `server`! The server will host the REST APIs and serve the frontend web application automatically with zero configuration.

---

## 💻 5. Developing with Lazarus IDE

Prefer working in a graphical IDE? The generated `server/server.lpi` is fully compatible with **Lazarus**:

1. Open **Lazarus IDE**.
2. Go to **Project ➔ Open Project...** and select `server/server.lpi`.
3. In `server/ServerApp.pas`, you can set breakpoints, inspect HTTP request objects (`TTestContext`), step through business logic, and test WebSocket broadcasts.
4. Press **F9** to compile and run natively with Lazarus's visual debugger!

---

## 🏋️ Practical Exercise

1. Open your terminal in a BlaiseVue project and run `bv mormot init`.
2. Inspect `server/ServerModels.pas` and observe how Pascal records are defined with JSON attribute tags.
3. Start the server using `bv mormot run`.
4. In another terminal window or browser, visit `http://localhost:8090/api/status` to inspect the JSON health response.
5. Stop the server using `bv mormot kill`.

---

## 📖 Deeper Technical Reference

- **[Full-Stack Pascal with mORMot 2 Manual](../Documentation/37-mormot2-backend.md)**: Complete guide covering high-concurrency threading, WebSockets, static file caching, and deployment scripts.
- **[Relational Master-Detail CRUD & Database Config](../Documentation/46-relational-master-detail-crud.md)**: Pluggable drivers for PostgreSQL, MySQL, Firebird, and SQLite3.

---

[⬅️ Module 14: Enterprise Data Architecture & TDataSet](14-dataset.md) | [🏠 Course Index](README.md) | [Module 16: Scaffolding Enterprise CRUD & Reactive DataGrid ➡️](16-mormot-crud.md)
