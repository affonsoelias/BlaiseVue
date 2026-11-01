# 🎨 BlaiseVue Studio (`blaise-studio`)

**Pillar 7 of the BlaiseVue 4.0 Cloud & Mobile Ecosystem** introduces **BlaiseVue Studio** — a developer cockpit and real-time analytics hub.

## 🚀 Quick Start

Launch Studio directly via the CLI in any BlaiseVue project:
```bash
bv studio
```
Or specify a custom port:
```bash
bv studio --port 9000
```

Studio automatically serves the developer dashboard on `http://localhost:9000` and launches your default browser.

## 🌟 Key Features
- **Live Component Tree & AST Inspector**: Interactive searchable view of all `.bv` components, props, data, slots, events, and syntax-highlighted source code.
- **Real-Time WebSocket Monitor**: Live traffic analyzer for client-server messages, HMR, and mORMot 2 events with formatted JSON inspection.
- **One-Click Actions**: Run Vitest unit tests, build production packages, sync mobile/desktop assets, or verify mORMot 2 backend health with a single click.
- **Client Pascal Telemetry (`BlaiseStudio.pas`)**: Track custom component state, log messages, and WebSocket frames directly from Pascal.
