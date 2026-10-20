# 40. BlaiseVue Studio Dashboard (`bv studio` & `BlaiseStudio`)

**Phase 7 of the BlaiseVue 4.0 Cloud & Mobile Ecosystem** introduces **BlaiseVue Studio** (`bv studio`) — an ultra-modern, visual developer cockpit and live telemetry hub for the BlaiseVue platform.

Operating at `http://localhost:9000`, BlaiseVue Studio provides visual component AST inspection, real-time WebSocket traffic monitoring, one-click execution of tests and builds, and live telemetry integration with Object Pascal applications.

---

## 🎨 Architecture & Live Hub Overview

```text
┌────────────────────────────────────────────────────────────────────────┐
│                   BlaiseVue Studio Cockpit UI                          │
│     Web Dashboard (http://localhost:9000) • Dark/Light Mode            │
│  [Overview] • [Component Tree] • [WS Monitor] • [Vitest] • [Routes]    │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ HTTP REST + WebSocket (/ws)
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│              Studio Hub & Dev Server (studio-server.js)                │
│    Project Scanner  •  AST Parser  •  HMR Watcher  •  CLI Bridge       │
└──────────────┬────────────────────┬────────────────────┬───────────────┘
               │                    │                    │
               ▼                    ▼                    ▼
     [ Frontend Client ]    [ mORMot 2 Backend ]   [ CLI Runner ]
       TBVStudioClient         WebSocket Stream       bv run build
       window.$studio           REST Endpoints         bv test
```

---

## 🚀 Launching BlaiseVue Studio (`bv studio`)

Start Studio from any BlaiseVue project root:

```bash
bv studio
```

Options:
- `--port <number>`: Specify custom port (default: `9000`).
- `--no-open`: Prevents automatic browser launch.

Example:
```bash
bv studio --port 9050 --no-open
```

Output:
```text
=== BlaiseVue Studio 4.0 Developer Cockpit ===
  Dashboard: http://localhost:9000
  WebSocket: ws://localhost:9000/ws

======================================================
 🛡️  BlaiseVue Studio 4.0 - Developer Cockpit Active
======================================================
  Studio Dashboard: http://localhost:9000
  Live WebSocket:   ws://localhost:9000/ws
  Project Directory: C:\Users\Pichau\Documents\BlaiseVue
======================================================
```

---

## 🌟 Visual Studio Features

### 1. 📊 Cockpit / Project Overview
- **Real-Time Project Stats**: Total `.bv` components analyzed, active SPA routes, lines of Pascal code compiled, and backend mORMot 2 health status.
- **Fast Action Buttons**:
  - `🔨 Executar Build de Desenvolvimento` (`bv run dev`).
  - `🧪 Rodar Suíte Vitest` (`bv test`).
  - `📱 Sincronizar Capacitor Android` (`bv mobile sync`).
  - `🖥️ Sincronizar Desktop WebUI` (`bv desktop sync`).
  - `📦 Scaffolding CRUD mORMot 2` (`bv mormot crud`).

---

### 2. 🌳 Component Tree & AST Inspector
- **Searchable Component Directory**: Lists every `.bv` file found in `src/components`, `src/views`, `lib/`, and `packages/`.
- **Deep AST Property Inspection**:
  - Declared props with types and default values.
  - Active custom events emitted (`$emit`).
  - Slot names and scoped slot parameters.
  - Pascal unit dependencies imported via `<script uses="...">`.
- **Integrated Source Viewer**: Displays complete `.bv` template and Pascal script code with line numbers and syntax highlighting.

---

### 3. ⚡ Real-Time WebSocket Monitor
- **Bidirectional Packet Capture**:
  - `⬇ IN`: Incoming server push frames and mORMot 2 notifications.
  - `⬆ OUT`: Outgoing client queries and RPC dispatches.
  - `⚡ EVENT`: DevTools and HMR component mount/unmount triggers.
- **Interactive JSON Tree**: Expand and search JSON payloads without external proxies.
- **Mock Message Generator**: Send test packets to connected clients directly from the Studio interface to verify reactive handlers.

---

### 4. 🧪 Vitest & Terminal Runner
- **Live Test Dashboard**: Tracks pass/fail counts, total test files, and execution durations.
- **Live Terminal Window**: Displays ANSI-colored output from `bv run dev` and `bv test` in real-time.

---

### 5. 🌐 Routes & REST API Explorer
- **SPA Frontend Routes**: Displays all registered client-side routes, path parameters, component mappings, and JWT authentication requirements.
- **mORMot 2 REST Endpoints**: Lists active backend microservice routes (`GET`, `POST`, `PUT`, `DELETE`), target records, and role requirements.

---

## ⚡ Client Pascal Telemetry API (`BlaiseStudio.pas`)

Frontend applications can connect directly to BlaiseVue Studio for debugging and telemetry:

```pascal
uses
  BlaiseStudio;

// 1. Send diagnostic logs to Studio console
TBVStudioClient.SendLog('info', 'Customer checkout initiated', CheckoutData);

// 2. Broadcast custom telemetry events
TBVStudioClient.SendEvent('user:action', ActionPayload);

// 3. Inspect component reactive state in Studio tree
TBVStudioClient.InspectState('OrderGrid', this['Orders']);

// 4. Trace WebSocket network frames
TBVStudioClient.TrackWebSocketFrame('OUT', 'orders:subscribe', SubPayload);
```

---

## 🧪 Automated Testing & Vitest Suite

BlaiseVue Studio is covered by unit tests in `demo-app/tests/studio.test.pas`:
- Bridge initialization (`window.$studio`).
- Dynamic WebSocket URL configuration.
- Telemetry, logging, and WebSocket frame dispatchers.
- DevTools hook integration and event forwarding.
- Endpoint and schema validation.

Run tests:
```bash
bv test
```

Result:
```text
✓ tests/studio.test.pas (6 tests passed)
✓ Test Files  22 passed (22)
✓ Tests       326 passed (326)
```
