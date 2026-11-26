# 🛡️ BlaiseVue: Architecture and Mission (Technical Reference)

BlaiseVue is an **SPA (Single Page Application)** framework built in **Object Pascal** and transpiled to JavaScript via **pas2js**. It was designed to bring Pascal's type robustness to the modern frontend ecosystem.

---

## 🏗️ Technology Stack
- **Language**: Object Pascal (FreePascal 3.2+)
- **Transpiler**: [pas2js 3.2.0](https://wiki.freepascal.org/pas2js)
- **Runtime**: Proxy-based DOM manipulation (identical to Vue.js 3 internals).
- **Tooling**: `bv.exe` (Native CLI compiled in FPC).

---

## 🧬 Engineering Principles

### 1. Proxy System
BlaiseVue maps the Pascal state (`FData`) to a Proxy object in JavaScript. This allows for granular change detection without the need for a heavy Virtual DOM, enabling surgical updates to the real DOM.

### 2. SFC (Single File Components)
BlaiseVue components (`.bv`) are triple-structured files (template, script, style) processed by the CLI. The CLI extracts the HTML template, translates the Pascal code to Pas2JS, and injects the CSS into the application header dynamically.

### 3. Hash-Based Routing
The ecosystem uses a Hash-based router to ensure compatibility with static servers, managing the lifecycle of components as the URL changes on the client.

---

## ⚡ Initial Performance
The initialization time of the BlaiseVue reactive engine is less than **10ms**, thanks to the absence of virtual rendering overhead during the first mount. 🛡️✨🏆

---

## 🔌 Backend Freedom & Decoupling

BlaiseVue is an independent, client-first reactive framework. While it provides first-class integrations with native Pascal servers, **it is completely decoupled from any specific backend**:

1. **Frontend-Only Mode (Zero Pascal Backend)**:
   - Build pure reactive Web SPAs, Jamstack sites, or native mobile apps in Object Pascal.
   - Host `dist/` on any static provider (Netlify, Vercel, AWS S3, Cloudflare Pages, Nginx).
   - In-app HTTP communication uses the built-in `$api` (REST) and `$ws` (WebSocket) clients to consume any existing API written in **Node.js, Go, Python, C# (.NET), Java, PHP, or Delphi**.

2. **Enterprise Full-Stack (Synopse mORMot 2)**:
   - The default high-throughput Pascal SOA backend (`server/`) with shared type-safe interface contracts (`common/contracts.pas`), zero serialization drift, and microsecond latency.

3. **Alternative Microframeworks (Horse)**:
   - For lightweight, Express.js-style REST microservices, developers can use the co-official tool **`blaise-horse`** in an isolated `server-horse/` directory.

4. **Architectural Symmetry & Removal**:
   - Backend architectures can be safely added or removed at any time (`bv mormot init` / `bv mormot remove -y` or `bv horse init` / `bv horse remove -y`) without affecting the frontend.
