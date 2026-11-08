# 🎛️ Module 25: Visual Development with Blaise Studio
**Supercharge your productivity with BlaiseVue Studio: visual AST inspection, WebSocket telemetry, and 1-click test runners.**

One of Delphi and Lazarus's most beloved traits has always been **RAD (Rapid Application Development)**: having visual clarity over components, event handlers, and data flows.

In modern web development, developers often lose that clarity—juggling dozen of files, guessing which components are currently mounted in the DOM, and debugging WebSocket traffic in obscure browser tabs.

BlaiseVue restores that RAD superpowers with **BlaiseVue Studio (`bv studio`)**: a visual developer cockpit and live telemetry hub designed specifically for Object Pascal web applications!

---

## 🏛️ 1. Studio Architecture & Live Telemetry Hub

```text
┌────────────────────────────────────────────────────────────────────────┐
│                   BlaiseVue Studio Cockpit UI                          │
│     Web Dashboard (http://localhost:9000) • Dark/Light Mode            │
│  [Overview] • [Component Tree] • [WS Monitor] • [Test Runner] • [Routes]│
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

Operating as a lightweight background service, Studio connects your source code, your running browser application, and your mORMot 2 server into a single visual dashboard.

---

## 🚀 2. Launching Blaise Studio (`bv studio`)

Inside any BlaiseVue project root, open your terminal and run:

```bash
bv studio
```

### Options:
- `--port <number>`: Specify custom port (default: `9000`).
- `--no-open`: Prevents automatic browser launch.

```bash
bv studio --port 9050 --no-open
```

Your browser automatically opens to **`http://localhost:9000`** with the Studio Dashboard active!

---

## 🌟 3. Core Cockpit Capabilities

### 1. Component Tree & AST Inspector
Inspect your application's Single File Component hierarchy in real time:
- View all mounted `.bv` components in a visual tree.
- Inspect reactive `data:`, `computed:`, and `props:` values currently held in memory.
- Highlight component boundaries directly in the active browser window!

### 2. Live WebSocket Monitor
Building real-time full-stack apps with mORMot 2? The WebSocket monitor displays a live stream of all network frames:
- Filter frames by topic (e.g. `customer_created`, `order_updated`).
- Inspect raw JSON payloads and execution timestamps.
- Simulate and inject inbound WebSocket events into your frontend to test edge cases!

### 3. Route Navigator & Guard Map
View an architectural diagram of all registered application routes:
- Check route paths, matching components, and parameters.
- Verify which routes are protected by authentication guards (`requiresAuth: true`, `roles: ['admin']`).

### 4. 1-Click Test & Build Runner
Run your automated test suite or trigger a production build directly from the Studio interface without opening a separate terminal:
- Click **Run All Tests** to trigger `bv test` and review green/red status bars with exact line numbers for any failing assertion.
- Click **Build Release** to execute `bv build --release` and inspect your final minified asset sizes and tree-shaking metrics.

---

## 💻 4. Client Telemetry Integration in Pascal

BlaiseVue components can communicate directly with Studio using the `TBVStudioClient` unit:

```pascal
uses BVStudioClient;

procedure TOrderView.ProcessHighValueTransaction(Amount: Double);
begin
  // Send custom telemetry event visible in Blaise Studio Dashboard
  StudioLog('Finance', 'Processing transaction of $' + FloatToStr(Amount));
  
  if Amount > 100000.00 then
    StudioWarn('Audit', 'Large transaction flag triggered for review!');
end;
```

---

## 🏋️ Practical Exercise

1. Open your terminal in your BlaiseVue project and run `bv studio`.
2. Observe the Studio banner in the terminal and open `http://localhost:9000`.
3. Switch Studio between Dark and Light mode using the cockpit header toggle.
4. Open the **Component Tree** tab and click through your application's mounted views.
5. Navigate to the **Tests** panel and click **Run Tests** to see live test suite execution inside the dashboard!

---

## 📖 Deeper Technical Reference

- **[BlaiseVue Studio Dashboard Manual](../Documentation/40-blaise-studio.md)**: Deep dive into the internal AST parser, WebSocket telemetry protocols, and headless CLI integrations.

---

[⬅️ Module 24: Enterprise Reporting with Blaise Reports](24-reports.md) | [🏠 Course Index](README.md) | [Module 26: Unit & E2E Testing Automation ➡️](26-testing.md)
