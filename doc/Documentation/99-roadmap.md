# 🛡️ Technical Roadmap: BlaiseVue Platform (v0.1.x Pre-Release Track)

> **The Universal Reactive Framework for Object Pascal.**  
> Comprehensive architectural evolution, delivered baseline pillars (`v0.1.0`), and ongoing pre-release milestones (`v0.1.x`).

> [!NOTE]
> **Ongoing `v0.1.x` Pre-Release Track:** BlaiseVue will remain in the **`v0.1.x`** public pre-release series throughout all currently planned phases (including Cloud/PWA/SSR, Distributed Micro-Frontends, and Serverless Edge / BlaiseEdge) and will **continue evolving in `v0.1.x`** even after those phases are completed. There is currently **no scheduled release date or forecast for `v1.0.0`**.

---

## 🧭 1. Executive Release Matrix

| Version | Status | Milestone / Focus | Major Deliverables |
| :--- | :---: | :--- | :--- |
| **`v0.1.0`** | ✅ Delivered | **Universal Full-Stack Baseline** | `.bv` Single-File Components, Reactivity Proxy, SPA Router, Scoped Slots, HMR, Validation (`b-validate`), FLIP `<transition-group>`, i18n (`$t`), `bv doc`, `$wasm`, SSG, E2E, Desktop (WebUI/Lazarus), Mobile (Capacitor), mORMot 2 SOA/RPC/Relational CRUD, Zero-`with()` AST Checker (`bv check`), Offline `TBVDataSet` + IndexedDB Delta Sync, Virtual Scroll, BlaiseX (`TBVStore 2.0` + FSM + Middleware + Time-Travel), Vue 3-Style Fragments, Official Packages (`blaise-ui`, `blaise-reports`, etc.), Decentralized Ecosystem (`bv repo`, `bv lib`, `bv tool`), Multi-Version `bv framework` (local FPC build), `bv doctor`, and DelSafe/Zephyr *(experimental)*. |
| **`v0.1.x` (Phase A)** | 🚀 Next | **Cloud, PWA & Real-Time Era** | Full PWA Engine & Background Sync (`bv pwa`), Node-Free Dynamic SSR (mORMot 2 SSR `<3ms`), BlaiseVue Studio 2.0 (Visual Cockpit & DB Modeler). |
| **`v0.1.x` (Phase B)** | 🗺️ Planned | **Distributed Enterprise Era** | Micro-Frontends & Dynamic Module Federation (`RegisterRemoteModule`, `bv create --mf-host` / `--mf-remote`, federated BlaiseX slices). |
| **`v0.1.x` (Phase C)** | 🗺️ Planned | **Serverless Edge Era (BlaiseEdge)** | Native `wasm32-wasi` compilation, `bv edge <init|build|deploy>`, `<0.2ms` cold start, sub-2MB microservices for Cloudflare Workers & Fastly. |
| **`v0.1.x+`** | 🔄 Ongoing | **Continued Pre-Release Evolution** | Further stabilization, performance tuning, community feedback, and ecosystem expansion after Phase C — **continuing in `v0.1.x`**. |
| **`v1.0.0`** | ⏳ TBD | **Future Official GA (No Forecast)** | Long-term API freeze, cross-platform certification, and standard SemVer 2.0.0 stability guarantees — **no release date scheduled yet**. |

---

## 🏛️ 2. Delivered Baseline (`v0.1.0`) — [Delivered ✅]

### 📦 2.1 Core Reactive Engine, SFC & Developer Foundations
- **Single-File Component Architecture (`.bv`)**: Triple block structure combining `<template>`, `<script>`, and `<style scoped>`, compiled into efficient JavaScript via Pas2JS.
- **Reactive Proxy & Dependency Tracking (`core/BVReactivity.pas`)**: Automatic dependency collection with fine-grained DOM patching ($O(1)$ updates) without full virtual DOM diffing overhead.
- **SPA Router & HTML5 History API (`core/BVRouting.pas`)**: Client-side routing with clean URLs, nested `<router-view>` hierarchies, dynamic route parameters (`:id`), and navigation guards (`beforeEach`, `afterEach`).
- **Scoped Slots & Directives**: Two-way data passing from child components back to parent templates (`#name="slotProps"`, `b-slot`, `slot-scope`).
- **Hot Module Replacement (HMR)**: Instant component recompilation and in-place DOM patching over WebSockets (`:8081`) while preserving active reactive state.
- **Declarative Form Validation Engine (`b-validate`)**: Client-side validation rules (`required`, `email`, `min:N`, `max:N`, `numeric`, `pattern`), reactive error tracking (`$errors`), touch states (`$v`), and programmatic validation (`$validate()`).
- **FLIP List Transitions (`<transition-group>`)**: High-performance collection animations powered by the First-Last-Invert-Play (FLIP) algorithm, custom wrapper tags (`tag="ul"`), and smooth reordering via `.bv-move`.
- **Integrated Internationalization (`Blaise-i18n`)**: Embedded multi-locale translation engine with `$t(key, params)`, reactive locale switching (`$setLocale(code)`), and fallback resolution.
- **Automatic Documentation Generator (`bv doc`)**: Zero-configuration interactive catalog generator analyzing component AST, props, slots, and events, served directly via `bv doc --serve`.
- **WebAssembly Acceleration Engine (`BVWasm` / `$wasm`)**: Near-native binary execution in the browser via `$wasm.call('math', 'fib', 15)` and automated benchmarks (`bv wasm benchmark`).
- **Static Site Generation (`bv ssg`)**: Pre-renders routing trees into static HTML for instant First Contentful Paint (`<50ms`) and complete search engine indexing (SEO).
- **Headless E2E Test Driver (`bv test e2e`)**: Validates user journeys across routing, forms, theme switches, and hydration.

---

### 🌐 2.2 Universal Multiplatform & Full-Stack Backends
- **Desktop Multiplatform (WebUI + Lazarus IDE)**: Scaffolds ultra-light desktop applications wrapping the reactive frontend within native Lazarus binaries via WebUI (`bv desktop init`, `bv desktop build`, `bv desktop run`).
- **Hybrid Mobile Runtime (Capacitor & Android APK)**: Mobile project scaffolding (`bv mobile init` / `bv capacitor init`), live assets synchronization (`bv capacitor sync`), self-healing Gradle support, and native Android APK/AAB compilation (`bv capacitor build`).
- **Full-Stack Pascal with mORMot 2 (`server-mormot/`, Port `8090`)**:
  - **Full-Stack CRUD & ORM Generator (`bv mormot crud <Model>`)**: Scaffolds ORM models, REST API endpoints, and reactive `<bv-datagrid>` interfaces.
  - **Enterprise Authentication & Route Guards (`$auth`)**: Native JWT authentication with role-based access control (RBAC) and declarative navigation guards (`meta: (requiresAuth: true)`).
  - **Auto-Generated Swagger & OpenAPI 3.0 (`/api/docs`)**: Interactive API explorer dynamically generated from mORMot 2 interfaces.
  - **Cloud-Native Micro-Containers (`bv mormot docker`)**: Zero-dependency Alpine Linux containerization producing sub-20MB images and `docker-compose.yml` configurations.
  - **End-to-End Type-Safe Pascal RPC (`bv mormot rpc`)**: Unified SOA service interfaces (`src/services/ICustomerService.pas`) compiled into type-safe client proxies with HTTP/WebSocket transport and compile-time signature checking.
- **Optional DelSafe Integration & Zephyr Native Backend (`--delsafe`, `bv zephyr`) *(Experimental)***:
  - Interoperable `<script lang="delsafe" uses="...">` SFCs, `.dels` domain modules, and native `.test.dels` suites integrated into `bv test`.
  - Isolated **Zephyr** HTTP/1.1 + WebSocket + static SPA server (`server-zephyr/`, port `8091`) compiled natively via `delsafec`.
- **Official Component & UI Packages (`packages/core/`)**:
  - 60+ production widgets across `blaise-ui`, `blaise-themes`, `blaise-icons`, `blaise-charts`, `blaise-reports`, `blaise-studio`, and `blaise-ui-mobile`.
  - **Zero-ASM Pure Object Pascal DX (`BVPascalDX.pas`)**: 100% pure Pascal application layer (`ShowToast`, `Confirm`, `ApiFetch`, `ApiSave`, `ApiDelete`).
- **LiveBindings & Reactive `TBVDataSet` (`core/BVDataSet.pas`)**:
  - Delphi/Lazarus data-aware state machine (`dsInactive`, `dsBrowse`, `dsEdit`, `dsInsert`), bidirectional cursor navigation (`First`, `Prior`, `Next`, `Last`), transactional CRUD buffering (`Append`, `Edit`, `Post`, `Cancel`), typed field accessors, `b-field` directive, and in-memory filtering/sorting.

---

### 🚀 2.3 Enterprise Resilience, Packaging & Tooling

#### ⚡ Compiler Template Type-Checking & Zero-`with()` Native Templates (`bv check`)
- **Zero-`with()` Native Expression Evaluator (`core/BVCompiler.pas`)**: Recursive-descent token parser and AST evaluator (`bv.fastEval`) replacing legacy dynamic `Function('with(data)...')`.
- **Microsecond LRU Cache (`bv.evalCache`)**: Caches parsed expression trees for 3x–5x faster reactive DOM updates.
- **Strict CSP Compliance**: 100% compliant with strict Content Security Policies without requiring `unsafe-eval`.
- **Compile-Time Template AST Verifier (`bv check [file]`)**: Audits template bindings against declared symbols (`data:`, `props:`, `computed:`, `methods:`) with automated Levenshtein typo suggestions (e.g. `cuont` $\rightarrow$ *"Did you mean 'count'?"*).

#### 💾 Offline-First `TBVDataSet` & Automated Delta Sync (`ApplyUpdates`)
- **IndexedDB Structured Storage (`TBVIndexedDBAdapter`)**: High-capacity client-side persistence with automatic fallback to `localStorage`.
- **Transactional Delta Tracking (`FDelta`)**: Captures detailed mutation logs (`deltaId`, `action`, `tableName`, `record`, `oldRecord`, `timestamp`).
- **Authoritative Server ID Remapping (`ReconcileDelta`)**: Seamlessly reconciles temporary negative client IDs (`-1`) with authoritative backend IDs generated by mORMot 2.
- **Configurable Conflict Policies**: `crServerWins` (default), `crClientWins`, or procedural `OnConflict` events.

#### 🔗 Multi-Database ORM & Relational Master-Detail CRUD (`bv mormot crud`)
- **Relational Code Generation**: Automated scaffolding for parent-child relationships (e.g. `Order` $\rightarrow$ `OrderItems`) with foreign key constraints.
- **Pluggable Database Engines**: One-command support for SQLite, PostgreSQL, MySQL, and Firebird via `--db <engine>` or `.env` configuration.
- **Synchronized Reactive Selection**: Selecting a master record automatically filters and binds child tables.

#### 🏎️ Enterprise UI Performance: Virtual Scrolling (`<bv-virtual-scroll>`)
- **High-Density DOM Virtualization**: DOM recycling engine rendering 50,000 to 100,000+ records at a constant 60 FPS in `<bv-data-grid>`.
- **Minimal DOM Footprint**: Only visible rows plus customizable buffer are rendered, eliminating layout thrashing and browser memory leaks.

#### 📦 External Library Scaffolding & Packaging (`bv create --lib` & `bv lib pack`)
- **Dedicated Library Scaffolding (`bv create <name> --lib`)**: Scaffolds standalone library packages with interactive license selection (MIT, Apache 2.0, LGPL v3, Commercial), isolated development sandbox (`demo/`), and test suite.
- **Automated Production Packager (`bv lib pack`)**: Runs pre-flight verification tests (`bv test`), strips build artifacts, and produces signed release bundles in `dist/<name>-<version>.zip` with SHA-256 checksums.

#### 🎮 Interactive Cockpit, Multi-Version SDK & Diagnostics (`bv enter`, `bv framework`, `bv doctor`)
- **Project Cockpit Shell (`bv enter`, `bv use <name>`, `bv project`)**: Colored project prompt (`[bv: <project>] >`), `[TAB]` autocompletion, cross-session registry, and smart refactoring CLI (`bv rename`).
- **Local-Compile Multi-Version Framework (`bv framework`)**: Lean sparse checkouts in `~/.blaisevue/versions/blaisevue/<ver>/` compiled locally via FPC with transparent auto-delegation (`.blaisevue-version`), `BV_HOST_SDK` vendor sharing, and safe fallback to `bv channel` (`main`/`develop`).
- **Cross-Module SDK & Diagnostics (`bv versions`, `bv doctor`)**: Unified management and diagnostics for BlaiseVue, Pas2JS, mORMot 2, Capacitor, DelSafe, and external tools.

#### 🛡️ Project Metadata, Licensing Suite & Clean Slate Reset (`bv license`, `bv meta`, `bv reset`)
- **Automated Licensing Management (`bv license [list|show|set]`)**: Full support for MIT, Apache, LGPL, GPL, BSD, and Commercial licenses with dynamic header injection.
- **SemVer Synchronization (`bv meta [show|get|set|bump|sync]`)**: Synchronizes `package.json` SemVer across the monorepo and Pascal `uAppVersion.pas` units.
- **Protected Clean Slate Reset (`bv reset [--bare] [--force]`)**: Resets projects to baseline while preventing accidental wipe of `demo-app/`.

#### 🌐 Decentralized Package Ecosystem & Registry Architecture (`bv repo`, `bv lib`)
- **Multi-Registry Catalog Manager (`bv repo`)**: Add, remove, synchronize, and search decentralized package catalogs (`official`, `company-internal`, etc.).
- **Disambiguation Syntax (`<repo>:<package>[@version]`)**: Deterministic package resolution (e.g. `bv lib install official:test@1.1.0` or `bv lib install acme:my-pkg`).
- **Core Reserved Names Protection**: Strictly blocks external packages from claiming core names (`ui`, `themes`, `icons`, `charts`, `reports`, `studio`, `mobile`, `core`, `sdk`, `tools`) or the official `blaise-` prefix.

#### 📊 Enterprise Reporting & Unified Developer Tools (`blaise-reports`, `bv tool`)
- **Declarative Report Builder (`TBVReport`)**: Fluent reporting engine binding directly to `TBVDataSet` with Vector PDF (`ExportPDF`), Excel (`ExportExcel`), CSV (`ExportCSV`), and print rules.
- **Centralized Developer Tooling (`bv tool`)**: Pluggable tooling ecosystem (`list`, `search`, `info`, `install`, `update`, `outdated`, `remove`, `pack`, `init`), IDE integrations (`blaise-vscode`, `blaise-lazarus`, `blaise-devtools`), and isolated user tools in `~/.blaisevue/tools/`.

---

### 🗄️ 2.4 BlaiseX — Advanced Global State & Finite State Machines (`TBVStore 2.0`) [✅ COMPLETE]
**Goal**: Evolved `$store` (`core/BVStore.pas`) into an enterprise-grade state management system inspired by Pinia, Redux Toolkit, and XState, written in 100% pure Object Pascal.

- **Status**: **Fully implemented, tested, and documented (Chapters 15 & 55)**.
- **Architectural Scope & Delivered Features**:
  1. **Deterministic Finite State Machines (`core/BVFSM.pas`)**:
     - Declarative states, initial state definition, and allowed transitions preventing illegal state jumps.
     - Guard expressions (`TBVFSMGuardFunc`), lifecycle hooks (`OnEnter`, `OnExit`, `TBVFSMActionProc`), event auditing history, and reactive mounting (`AttachMachine`).
  2. **Modular Store Slices & BlaiseX Core (`core/BVStore.pas`)**:
     - Domain slices via `DefineStore('sliceName', InitialState)`, atomic `Mutation`, async `Action`, cached `Getter`, `Patch`, `Reset`, and full `$store.state` compatibility.
  3. **Enterprise Middleware & Interceptor Pipeline (`core/BVMiddleware.pas`)**:
     - `TBVLoggerMiddleware`, `TBVAuthGuardMiddleware`, `TBVTelemetryMiddleware`, and anonymous `Slice.Use(BeforeProc, AfterProc)`.
  4. **Time-Travel Debugging & State Snapshots (`core/BVStoreHistory.pas`)**:
     - Bounded snapshot ring buffer with `Undo`, `Redo`, `TimeTravel(index)`, `ExportJSON`, `ImportJSON`, and `window.__BLAISEX_DEVTOOLS__`.
  5. **Component (`.bv`), AST Compiler, Pascal DX & CLI Scaffolding**:
     - `bv g store <Name>`, `bv g fsm <Name>`, `bv list store|fsm`, `bv remove store|fsm`, Zero-ASM helpers in `core/BVPascalDX.pas`, and Chapter 55 documentation.

---

### 🧩 2.5 Vue 3-Style Component Fragments (Multi-Root Templates & Attribute Fallthrough) [✅ COMPLETE]
**Goal**: Eliminate the single-root wrapper `<div>` requirement in `.bv` component templates, implementing native Vue 3-style Fragments with comment anchor node boundaries and friendly automatic attribute fallthrough.

- **Status**: **Fully implemented and verified in `tests/core/fragments.test.pas`**.
- **Architectural Scope**:
  1. **Comment Anchor Boundaries (`<!-- [bv-fragment: <tag>] -->` ... `<!-- [/bv-fragment] -->`)**: Direct replacement for single-root components and tracked `DocumentFragment` (`__bv_fragment_nodes__`) for multi-root templates.
  2. **Option A (Automatic & Friendly) Attribute Fallthrough**: Root attributes (`class`, `style`, `id`) and events (`@click`, `@input`) fall through automatically onto the first visible element node, or explicitly to `b-bind="$attrs"`.
  3. **Reactive Directives, Teardown & HMR**: Seamless `b-if`, `b-for`, `unmounted`, and in-place HMR range replacement in `core/BVCompiler.pas`.

---

## 🔮 3. Cloud, PWA & Real-Time Era (`v0.1.x` — Phase A) — [Next 🚀]

```text
                                BLAISEVUE v0.1.x (PHASE A)
                                           │
               ┌───────────────────────────┼───────────────────────────┐
               ▼                           ▼                           ▼
          [Pillar 1]                  [Pillar 2]                  [Pillar 3]
         Full PWA &                 Node-Free SSR               Visual Studio
        Offline Sync                 (mORMot SSR)                Cockpit & DB
        (PWA Engine)                (SSR Evolution)            (Studio 2.0)
```

| Phase A Strategic Pillar | Target Track | Focus Subsystem | Primary Architecture |
|---|:---:|---|---|
| **Pillar 1: Full PWA Engine & Background Sync (`bv pwa`)** | `v0.1.x` | `bin/bv.pas`, `core/BVDataSet.pas` | Service Worker caching, background sync with `ApplyUpdates` |
| **Pillar 2: Node-Free Dynamic Server-Side Rendering (mORMot 2 SSR)** | `v0.1.x` | `server-mormot/`, `core/BVCompiler.pas` | Native Pascal SSR executed in `<3ms` without Node.js |
| **Pillar 3: BlaiseVue Studio 2.0 (Visual Modeler & Cockpit)** | `v0.1.x` | `packages/core/blaise-studio/` | Drag-and-drop DB modeler, visual AST editor, live telemetry |

---

### 📱 Pillar 1: Full PWA Engine & Service Worker Background Sync (`bv pwa`)
**Goal**: Expand the offline capabilities of `TBVDataSet` and the mobile runtime by introducing an automated Progressive Web App engine with declarative Service Worker caching and background synchronization.

- **Architectural Scope**:
  1. **Single-Command PWA Generation (`bv pwa init`)**:
     - Automatically generates `manifest.json`, cross-platform app icons (192px, 512px, maskable), theme colors, and an optimized `sw.js` (Service Worker).
     - Provides instant installability across Desktop (Windows, macOS, Linux) and Mobile (Android, iOS) directly from any modern browser.
  2. **Tiered Caching Strategies**:
     - *Cache-First (Stale-While-Revalidate)*: Static assets (`main.js`, CSS, fonts) load in under 20ms from Cache Storage.
     - *Network-First with Fallback*: API and RPC endpoints fall back gracefully to cached responses when offline.
  3. **Background Sync Integration with `TBVDataSet.ApplyUpdates`**:
     - Mutations committed offline into `TBVDataSet` are persisted in IndexedDB.
     - When connectivity is restored, the browser's native **Service Worker `sync` event wakes up in the background**, submits pending deltas via `POST /api/dataset/apply` to the mORMot 2 backend, reconciles primary keys, and broadcasts confirmations even if the tab was closed.
  4. **Native Web Push Bridge**:
     - System-level push notifications dispatched directly from mORMot 2 servers to client devices.

---

### ⚡ Pillar 2: Node-Free Dynamic Server-Side Rendering (mORMot 2 SSR)
**Goal**: Evolve the static build-time pre-rendering engine (`bv ssg`) into a real-time, on-demand dynamic Server-Side Rendering (SSR) pipeline executed directly inside the native Synopse mORMot 2 backend in under 3 milliseconds.

- **Architectural Scope**:
  1. **On-Demand Dynamic Route Rendering**:
     - Dynamic routes (e.g. `/products/:id`, `/orders/:id`, `/blog/:slug`) are rendered on-demand when requested by search engine bots (Googlebot, Bing) or social share crawlers (WhatsApp, Twitter/X, LinkedIn).
     - The mORMot 2 Pascal backend queries the database and renders the complete initial HTML markup in memory.
  2. **Ultra-Low Latency & Sub-25MB Footprint**:
     - Standard JavaScript SSR frameworks (Next.js, Nuxt) require external Node.js runtimes consuming 500 MB–1.5 GB of RAM with 40–120ms response times.
     - BlaiseVue SSR runs directly inside the **compiled native Pascal binary**, executing in **less than 3 milliseconds** and consuming **under 25 MB RAM**.
  3. **Zero-Flicker Hydration Handshake**:
     - Client browsers receive fully rendered HTML with OpenGraph meta tags, titles, and layout immediately.
     - Client-side Pas2JS engine engages reactive hydration, attaching event listeners and reactive bindings without repainting the DOM.

---

### 🛠️ Pillar 3: BlaiseVue Studio 2.0 (Visual Cockpit & Database Modeler)
**Goal**: Expand the existing developer dashboard (`packages/core/blaise-studio` / `bv studio`) into a full visual cockpit featuring an interactive database schema designer, visual workflow builder, and real-time network telemetry.

- **Architectural Scope**:
  1. **Visual Relational Database Schema Modeler**:
     - Drag-and-drop web-based visual entity-relationship designer allowing developers to model tables, fields, types, and foreign key relations.
     - One-click code generation automatically producing:
       - 1) The mORMot 2 ORM records in `ServerModels.pas`.
       - 2) The relational service implementation (`Crud<Entity>.pas`).
       - 3) The frontend `.bv` view with `<bv-data-grid>`, search filters, and editing dialogs.
  2. **Reactive Time-Travel State Inspector**:
     - Visual timeline capturing every reactive proxy mutation, computed property evaluation, and `TBVDataSet` cursor navigation step with step-by-step replay.
  3. **Live Network & RPC Latency Telemetry**:
     - Real-time dashboard tracking JSON-RPC 2.0 throughput, WebSocket frame roundtrips, and database query execution times.

---

## 🌐 4. Distributed Enterprise Era (`v0.1.x` — Phase B) — [Planned 🗺️]

### 🧩 Micro-Frontends & Dynamic Module Federation
**Goal**: Enable large enterprise teams (banking, telecom, global ERPs) to build, deploy, and scale independent frontend applications that compose seamlessly into a unified BlaiseVue shell at runtime without requiring full-application recompilation.

- **Motivation**:
  1. **Autonomous Team Velocity**: Domain teams (e.g., Billing, Inventory, Authentication) ship features and deploy bugfixes to independent endpoints independently.
  2. **Zero-Downtime Hot Upgrades**: Remote modules update dynamically on remote CDN endpoints; client shells fetch the latest manifest upon route transition without user downtime.
  3. **Shared Reactive Kernel**: All federated micro-frontends share the single global Pascal runtime instance (`rtl.js`, `BVReactivity`, and `BVStore`), eliminating duplicate bundle downloads.

- **Architectural Scope**:
  1. **Dynamic Module Registry (`RegisterRemoteModule`)**:
     - Remote entry points expose a standardized manifest:
       ```pascal
       RegisterRemoteModule('billing', 'https://billing.company.com/remoteEntry.js');
       ```
     - Remote components load lazily on route activation:
       ```pascal
       Router.AddRoute('/billing', RemoteComponent('billing', 'BillingDashboard'));
       ```
  2. **Federated BlaiseX Store Slices**:
     - Remote micro-frontends dynamically register domain store slices and FSMs directly into the host shell's active store:
       ```pascal
       // Inside remote billing module:
       DefineStore('billing', InitialBillingState)
         .AttachMachine('invoiceFlow', CreateInvoiceMachine);
       ```
     - Shell templates and child micro-frontends interact reactively via `$store.billing` with full time-travel debugging and telemetry support.
  3. **Style & Asset Isolation**:
     - Enforced `<style scoped>` encapsulation prevents CSS leakage between federated micro-apps and the host shell.
  4. **CLI Module Federation Scaffolding**:
     - `bv create <app> --mf-remote`: Scaffolds a standalone federated micro-frontend with export manifest.
     - `bv create <app> --mf-host`: Scaffolds a federated shell container.

---

## ☁️ 5. Serverless Edge Era (`v0.1.x` — Phase C) — [Planned 🗺️]

### 🚀 BlaiseEdge & WASI Serverless Computing
**Goal**: Compile Pascal business logic, mORMot 2 services, and backend endpoints into native WebAssembly System Interface (`wasm32-wasi`) binaries, delivering sub-millisecond cold starts and sub-2MB memory footprints for global edge cloud platforms within the ongoing `v0.1.x` track.

- **Motivation**:
  1. **The Serverless Cold-Start Dilemma**: Traditional JavaScript, Python, and Java serverless functions incur 200ms–2000ms cold starts and require heavy 150MB–500MB runtime VMs.
  2. **Deterministic Pascal Performance**: Free Pascal's direct compilation to WASI produces lean, deterministic binaries that execute instantly without garbage collection stalls or VM warmup.
  3. **Global Edge Proximity**: Deploying Pascal endpoints to global edge networks (Cloudflare Workers, Fastly Compute@Edge, AWS Lambda Wasm, Wasmer) ensures `<5ms` API roundtrips globally.

- **Architectural Scope**:
  1. **Dedicated CLI Command Architecture (`bv edge <init|build|deploy>`)**:
     - Following BlaiseVue's clean target conventions (`bv mobile` / `bv capacitor` for Android/iOS, `bv desktop` for Lazarus/WebUI, `bv mormot` and `bv zephyr` for native servers), all serverless edge capabilities are unified under `bv edge`:
       - `bv edge init`: Scaffolds a standalone edge microservice in `server-edge/` with routing, handlers, and configuration.
       - `bv edge build`: Cross-compiles the Pascal source directly to `dist/edge/server.wasm` via FPC (`wasm32-wasi`).
       - `bv edge deploy`: Deploys the standalone Wasm bundle directly to Cloudflare Workers or Fastly Compute.
     - **Zero Redundancy Guarantee**: Keeps `bv wasm <info|benchmark>` strictly dedicated to client-side in-browser numeric/cryptographic acceleration (`core/BVWasm.pas`), avoiding developer confusion.
  2. **`wasm32-wasi` Compilation Pipeline**:
     - Free Pascal (FPC) cross-compilation pipeline targeting standard WASI (`bv edge build`), producing a sub-2MB standalone binary (`dist/edge/server.wasm`) with zero OS dependencies and zero container overhead.
  3. **Microsecond Cold-Start & Micro-Memory Footprint**:
     - Cold start boot time: **`<0.2` milliseconds**.
     - Runtime memory consumption: **`<5` MB RAM**.
  4. **Native Edge Transport Adapters**:
     - Streaming HTTP and WebSocket request/response adapters bridging mORMot 2 SOA interfaces directly with WASI stdio and socket streams.
  5. **Cloudflare & Fastly Deployment Templates**:
     - Automated scaffolding of `wrangler.toml` (Cloudflare Workers) and `fastly.toml` (Fastly Compute) for instant one-command deployment (`bv edge deploy`).

---

## 🎯 6. Beyond Phase C: Continued `v0.1.x` Evolution & Future `v1.0.0` (No Scheduled Date) — [Ongoing 🔄]

Even after Phases A, B, and C (including **Serverless Edge / BlaiseEdge**) are completed, **BlaiseVue will remain on the `v0.1.x` series** while undergoing continued refinement, real-world validation, and ecosystem growth:

1. **Continued `v0.1.x` Iterations**: Completing BlaiseEdge (`wasm32-wasi`) does **not** automatically trigger `v1.0.0`; subsequent `v0.1.x` releases will continue hardening APIs, tooling, and multiplatform stability.
2. **Future `v1.0.0` GA (No Forecast Yet)**: There is currently **no scheduled date or timeline for `v1.0.0`**. It will only be cut when long-term API stability and cross-platform certification are formally declared.
3. **Standard SemVer 2.0.0 & Git Channels**: Both pre-release (`v0.1.x`) and future post-`1.0.0` releases follow standard Semantic Versioning 2.0.0 (`MAJOR.MINOR.PATCH`) as defined in [`VERSIONING.md`](../../VERSIONING.md), with `main` as the release channel and `develop` as the active integration branch.

---

🛡️ **BlaiseVue: Stability, Predictability, and Universal Object Pascal Craftsmanship.** 🚀
