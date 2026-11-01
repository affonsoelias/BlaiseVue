# 🛡️ Technical Roadmap: BlaiseVue Platform (v2.0 – v5.0)

> **The Universal Reactive Framework for Object Pascal.**  
> Comprehensive architectural evolution, delivered enterprise pillars, and future milestones.

---

## 🧭 1. Executive Release Matrix

| Version | Status | Milestone / Focus | Major Deliverables |
| :--- | :---: | :--- | :--- |
| **v2.0 – v2.6** | ✅ Delivered | **Foundation & Reactivity** | `.bv` Single-File Components, Reactive Proxy, Router SPA (HTML5 History), Scoped Slots, HMR with state persistence. |
| **v3.0** | ✅ Delivered | **Framework Maturation** | Form engine (`b-validate`), FLIP `<transition-group>`, i18n (`$t`), `bv doc`, WebAssembly (`$wasm`), SSG pre-rendering, E2E test driver. |
| **v3.5** | ✅ Delivered | **Universal Multiplatform** | Desktop WebUI (Lazarus), Mobile Capacitor (Android APK), mORMot 2 backend foundation, VS Code official extension. |
| **v4.0** | ✅ Delivered | **Enterprise Cloud Ecosystem** | Full-Stack CRUD generator (`bv mormot crud`), JWT Auth (`$auth`), Swagger/OpenAPI 3.0, Docker micro-containers, `blaise-charts`, `blaise-studio`, Zero-ASM DX. |
| **v4.1** | ✅ Delivered | **Component Catalog & Documentation** | 52 technical manuals, full props/events/slots specification tables, zero-ASM application patterns. |
| **v4.2** | ✅ Delivered | **LiveBindings & Reactive `TBVDataSet`** | Delphi/Lazarus data-aware state machine, cursor navigation (`First`, `Next`), transactional buffering, `b-field` directive. |
| **v4.3** | ✅ Delivered | **Type-Safe Pascal RPC with mORMot 2** | JSON-RPC 2.0, dual HTTP/WebSocket transport, shared `ICustomerService` interfaces, compile-time API validation. |
| **v4.4** | ✅ Delivered | **Resilience, Packaging & Ecosystem** | AST Type-Checker (`bv check`), IndexedDB offline delta sync, Virtual Scroll, Relational CRUD, `bv create --lib`, `bv lib pack`, decentralized registries (`bv repo`, `bv lib`), `blaise-reports`, unified extensions (`bv extension`). |
| **v5.0** | 🚀 In Progress | **Cloud, PWA & Real-Time Era** | BlaiseX state machines (`TBVStore 2.0`), PWA Background Sync (`bv pwa`), Node-free dynamic SSR (<3ms), BlaiseStudio 2.0 visual modeler. |

---

## 🏛️ 2. Foundation Releases (v2.0 – v3.5) — [Delivered ✅]

### 📦 2.1 BlaiseVue 2.0 – 2.6: The Core Reactive Engine
- **Single-File Component Architecture (`.bv`)**: Triple block structure combining `<template>`, `<script>`, and `<style scoped>`, compiled into efficient JavaScript via Pas2JS.
- **Reactive Proxy & Dependency Tracking (`core/BVReactivity.pas`)**: Automatic dependency collection with fine-grained DOM patching ($O(1)$ updates) without full virtual DOM diffing overhead.
- **SPA Router & HTML5 History API (`core/BVRouting.pas`)**: Client-side routing with clean URLs, nested `<router-view>` hierarchies, dynamic route parameters (`:id`), and navigation guards (`beforeEach`, `afterEach`).
- **Scoped Slots & Directives**: Two-way data passing from child components back to parent templates (`#name="slotProps"`, `b-slot`, `slot-scope`).
- **Hot Module Replacement (HMR)**: Instant component recompilation and in-place DOM patching over WebSockets (`:8081`) while preserving active reactive state.

---

### 🚀 2.2 BlaiseVue 3.0: Core Feature Maturation
- **Declarative Form Validation Engine (`b-validate`)**: Declarative client-side validation rules (`required`, `email`, `min:N`, `max:N`, `numeric`, `pattern`), reactive error tracking (`$errors`), touch states (`$v`), and programmatic validation (`$validate()`).
- **FLIP List Transitions (`<transition-group>`)**: High-performance collection animations powered by the First-Last-Invert-Play (FLIP) algorithm, custom wrapper tags (`tag="ul"`), and smooth reordering via `.bv-move`.
- **Integrated Internationalization (`Blaise-i18n`)**: Embedded multi-locale translation engine with `$t(key, params)`, reactive locale switching (`$setLocale(code)`), and fallback resolution.
- **Automatic Documentation Generator (`bv doc`)**: Zero-configuration interactive catalog generator analyzing component AST, props, slots, and events, served directly via `bv doc --serve`.
- **WebAssembly Acceleration Engine (`BVWasm` / `$wasm`)**: Near-native binary execution in the browser via `$wasm.call('math', 'fib', 15)` and automated benchmarks (`bv wasm benchmark`).
- **Static Site Generation (`bv run ssg`)**: Pre-renders routing trees into static HTML for instant First Contentful Paint (<50ms) and complete search engine indexing (SEO).
- **Headless E2E Test Driver (`bv test e2e`)**: Validates user journeys across routing, forms, theme switches, and hydration.

---

### 🌐 2.3 BlaiseVue 3.5: The Universal Multiplatform
- **Desktop Multiplatform (WebUI + Lazarus IDE)**: Scaffolds ultra-light desktop applications wrapping the reactive frontend within native Lazarus binaries via WebUI (`bv desktop init`, `bv desktop build`, `bv desktop run`).
- **Hybrid Mobile Runtime (Capacitor & Android APK)**: Seamless mobile project scaffolding (`bv mobile init`), live assets synchronization (`bv mobile sync`), and native Android APK compilation via Gradle (`bv mobile build`).
- **Full-Stack Pascal with mORMot 2 (Initial Backend Foundation)**: Native HTTP server scaffolding in `server/`, compiling to standalone sub-15MB binaries with zero runtime dependencies.
- **Official VS Code Extension (`.vsix`)**: Syntax highlighting for `.bv` files, directive autocompletion, Pascal script IntelliSense, and embedded snippet libraries.

---

## 🛡️ 3. Current Enterprise Era: BlaiseVue 4.0 – 4.4 — [Delivered ✅]

### ⚡ 3.1 BlaiseVue 4.0: Enterprise Cloud & Full-Stack Ecosystem
- **Full-Stack CRUD & ORM Generator (`bv mormot crud <Model>`)**: Automatically scaffolds ORM models in `server/src/models/`, REST API endpoints, and reactive `<bv-datagrid>` interfaces in the frontend.
- **Enterprise Authentication & Route Guards (`$auth`)**: Native JWT authentication with role-based access control (RBAC), automatic token injection, secure storage, and declarative navigation guards (`meta: (requiresAuth: true)`).
- **Auto-Generated Swagger & OpenAPI 3.0 (`/api/docs`)**: Interactive API explorer dynamically generated from mORMot 2 interfaces with live *Try it out* execution.
- **Cloud-Native Micro-Containers (`bv mormot docker`)**: Zero-dependency Alpine Linux containerization producing sub-20MB images and complete `docker-compose.yml` configurations.
- **Mobile-First Ionic Suite (`packages/core/blaise-ui-mobile`)**: Ionic UI components with adaptive iOS/Android styling and Pascal controller bridges (`IonicToast`, `IonicAlert`, `IonicConfirm`).
- **Data Visualization Suite (`packages/core/blaise-charts`)**: Reactive Chart.js wrapper with strongly typed Pascal records (`TBVChartData`, `TBVChartOptions`, `TBVChartPalette`).
- **Developer Cockpit (`packages/core/blaise-studio`)**: Live WebSocket monitoring, AST inspection, and one-click build triggers.
- **Zero-ASM Pure Object Pascal DX (`BVPascalDX.pas`)**: 100% pure Pascal application layer eliminating inline `asm ... end;` blocks for all common operations (`ShowToast`, `Confirm`, `ApiFetch`, `ApiSave`, `ApiDelete`).

---

### 📚 3.2 BlaiseVue 4.1: Component Catalog & Comprehensive Documentation
- **Exhaustive Component Catalog**: Complete documentation of 53+ production components across `@blaise-ui`, `@blaise-charts`, `@blaise-ui-mobile`, and `@blaise-themes`.
- **Standardized Documentation Specification**: Every component features:
  - Detailed overview and business use cases.
  - Strongly typed Props specification tables.
  - Events specification tables with parameter signatures.
  - Default and named Slots tables.
  - Full copy-pasteable pure Pascal code snippets (`<template>`, `<script>`, `<style>`).
- **52 Technical Manuals**: Comprehensive guides located in `doc/Documentation/` spanning all framework subsystems.

---

### 📊 3.3 BlaiseVue 4.2: LiveBindings & Reactive `TBVDataSet`
- **Delphi/Lazarus Data-Aware State Machine**: Full implementation of dataset lifecycle (`dsInactive`, `dsBrowse`, `dsEdit`, `dsInsert`) in pure Object Pascal (`core/BVDataSet.pas`).
- **In-Memory Cursor Navigation**: Bidirectional record pointer manipulation (`First`, `Prior`, `Next`, `Last`, `RecNo`, `RecordCount`).
- **Transactional CRUD Buffering**: `Append`, `Edit`, `Post`, and `Cancel` with automatic rollback support.
- **Strongly Typed Field Access**: Direct accessors (`FieldByName('salary').AsFloat`, `AsString`, `AsInteger`, `AsBoolean`).
- **Declarative LiveBindings Directive (`b-field` / `v-field`)**: Two-way data binding connecting UI inputs directly to dataset fields with automatic dirty tracking.
- **Multi-Field Sorting & In-Memory Filtering**: High-speed filtering (`SetFilter`) and multi-column sorting without server roundtrips.

---

### 🔗 3.4 BlaiseVue 4.3: End-to-End Type-Safe Pascal RPC with mORMot 2
- **Unified SOA Service Interfaces**: Shared Pascal interface units (e.g. `src/services/ICustomerService.pas`) shared between backend server and frontend client.
- **Automated Client Proxy Scaffolding (`bv mormot rpc`)**: Compiles service contracts into type-safe client proxies:
  ```pascal
  CustomerService.GetCustomers(Page, Limit,
    procedure(const Items: TCustomerArray)
    begin
      this.customers := Items;
    end);
  ```
- **Dual HTTP & WebSocket Transport**: Automatic protocol negotiation supporting high-throughput binary serialization and JSON-RPC 2.0.
- **100% Compile-Time API Validation**: Parameter type mismatches, renamed methods, or altered signatures fail at compile time during `bv run dev`.

---

### 🚀 3.5 BlaiseVue 4.4: Enterprise Resilience, Native Templates & Decentralized Ecosystem

#### ⚡ Pillar 1: Compiler Template Type-Checking & Zero-`with()` Native Templates (`bv check`)
- **Zero-`with()` Native Expression Evaluator (`core/BVCompiler.pas`)**: Replaced deprecated `new Function('with(data)...')` with a pure recursive-descent token parser and AST evaluator (`bv.fastEval`).
- **Microsecond LRU Cache (`bv.evalCache`)**: Caches parsed expression trees for 3x–5x faster reactive DOM updates.
- **Strict CSP Compliance**: 100% compliant with strict Content Security Policies without requiring `unsafe-eval`.
- **Compile-Time Template AST Verifier (`bv check [file]`)**: Audits template bindings against declared symbols (`data:`, `props:`, `computed:`, `methods:`) with automated Levenshtein typo suggestions (e.g. `cuont` $
ightarrow$ *"Did you mean 'count'?"*).

#### 💾 Pillar 2: Offline-First `TBVDataSet` & Automated Delta Sync (`ApplyUpdates`)
- **IndexedDB Structured Storage (`TBVIndexedDBAdapter`)**: High-capacity client-side persistence with automatic fallback to `localStorage`.
- **Transactional Delta Tracking (`FDelta`)**: Captures detailed mutation logs (`deltaId`, `action`, `tableName`, `record`, `oldRecord`, `timestamp`).
- **Authoritative Server ID Remapping (`ReconcileDelta`)**: Seamlessly reconciles temporary negative client IDs (`-1`) with authoritative backend IDs generated by mORMot 2.
- **Configurable Conflict Policies**: `crServerWins` (default), `crClientWins`, or procedural `OnConflict` events.

#### 🔗 Pillar 3: Multi-Database ORM & Relational Master-Detail CRUD (`bv mormot crud`)
- **Relational Code Generation**: Automated scaffolding for parent-child relationships (e.g. `Order` $
ightarrow$ `OrderItems`) with foreign key constraints.
- **Pluggable Database Engines**: One-command support for SQLite, PostgreSQL, MySQL, and Firebird via `--db <engine>` or `.env` configuration.
- **Synchronized Reactive Selection**: Selecting a master record automatically filters and binds child tables.

#### 🏎️ Pillar 4: Enterprise UI Performance: Virtual Scrolling (`<bv-virtual-scroll>`)
- **High-Density DOM Virtualization**: DOM recycling engine rendering 50,000 to 100,000+ records at a constant 60 FPS in `<bv-data-grid>`.
- **Minimal DOM Footprint**: Only visible rows plus customizable buffer are rendered, eliminating layout thrashing and browser memory leaks.

#### 📦 Pillar 5: External Library Scaffolding & Packaging (`bv create --lib` & `bv lib pack`)
- **Dedicated Library Scaffolding (`bv create <name> --lib`)**: Scaffolds standalone library packages with interactive license selection (MIT, Apache 2.0, LGPL v3, Commercial), isolated development sandbox (`demo/`), and test suite.
- **Automated Production Packager (`bv lib pack`)**: Runs pre-flight verification tests (`bv test`), strips build artifacts, and produces signed release bundles in `dist/<name>-<version>.zip` with SHA-256 checksums.

#### 🎮 Pillar 6: Interactive Cockpit & Project Registry (`bv enter`, `bv use`)
- **Project Cockpit Shell (`bv enter`)**: Dedicated developer console with colored project prompt (`[bv: <project>] >`) and Windows interrupt traps (`Ctrl + C` halts tasks without killing shell).
- **Cross-Session Registry (`bv project` & `bv use <name>`)**: Instantly jump between registered projects from anywhere in the filesystem.
- **Smart Refactoring CLI (`bv rename <s|c|v|p> <NewName>`)**: Renames services, components, route views, and project identifiers consistently.

#### 🛡️ Pillar 7: Project Metadata, Licensing Suite & Clean Slate Reset (`bv license`, `bv meta`, `bv reset`)
- **Automated Licensing Management (`bv license [list|show|set]`)**: Full support for MIT, Apache, LGPL, GPL, BSD, and Commercial licenses with dynamic header injection.
- **SemVer Synchronization (`bv meta [show|get|set|bump]`)**: Synchronizes `package.json` SemVer with native Pascal unit `src/uAppVersion.pas`.
- **Protected Clean Slate Reset (`bv reset [--bare] [--force]`)**: Resets projects to baseline while preventing accidental wipe of `demo-app/`.

#### 🌐 Pillar 8: Decentralized Package Ecosystem & Registry Architecture (`bv repo`, `bv lib`)
- **Multi-Registry Catalog Manager (`bv repo`)**: Add, remove, synchronize, and search decentralized package catalogs (`official`, `company-internal`, etc.).
- **Disambiguation Syntax (`<repo>:<package>[@version]`)**: Deterministic package resolution (e.g. `bv lib install official:test@1.1.0` or `bv lib install acme:my-pkg`).
- **Default Registry Priority & Duplicate Notices**: Prioritizes default catalog while notifying developers if identical package names exist across repositories.
- **Core Reserved Names Protection**: Strictly blocks external packages from claiming core names (`ui`, `themes`, `icons`, `charts`, `reports`, `studio`, `mobile`, `core`, `sdk`, `tools`) or the official `blaise-` prefix.

#### 📊 Pillar 9: Enterprise Reporting & Multi-Format Document Export (`packages/core/blaise-reports`)
- **Declarative Report Builder (`TBVReport`)**: Fluent reporting engine binding directly to `TBVDataSet` with automatic aggregation (`aggSum`, `aggAverage`, `aggCount`).
- **Multi-Format Export Targets**: Client and server-side Vector PDF (`ExportPDF`), native Excel spreadsheets (`ExportExcel`), and clean CSV streaming (`ExportCSV`).
- **Print Optimization**: Tailored CSS `@media print` rules for A4, Letter, and thermal POS receipt printers (80mm/58mm).

#### 🛠️ Pillar 10: Unified Development Extensions & Tools Architecture (`packages/tools/`, `bv extension`)
- **Centralized Extension Tooling (`bv extension`)**: Unified management (`list`, `install`, `remove`, `pack`) for IDE and browser extensions.
- **VS Code Extension Packaging (`bv extension pack vscode`)**: Directly invokes `@vscode/vsce` to package production `.vsix` bundles from `packages/tools/vscode-extension/`.
- **Browser DevTools Deployment (`bv extension install devtools`)**: Automated deployment guides and installation bridges for Chrome, Edge, and Firefox DevTools extensions from `packages/tools/devtools-extension/`.
- **User Global Tools (`~/.blaisevue/tools/`)**: Isolated user directory protecting custom community tools from framework `bv self-update` operations.

---

## 🔮 4. The Next Horizon: BlaiseVue 5.0 — The Cloud, PWA & Real-Time Era (🚀 In Progress)

```
                                  BLAISEVUE 5.0
                                        │
        ┌───────────────┬───────────────┴───────────────┬───────────────┐
        ▼               ▼                               ▼               ▼
   [Pillar 1]      [Pillar 2]                      [Pillar 3]      [Pillar 4]
    BlaiseX /       Full PWA &                    Node-Free SSR    Visual Studio
   TBVStore 2.0    Offline Sync                   (mORMot SSR)    Cockpit & DB
 (Store Evolution) (PWA Engine)                  (SSR Evolution) (Studio Evolution)
```

| 5.0 Strategic Pillar | Target Milestone | Focus Subsystem | Primary Architecture |
|---|:---:|---|---|
| **Pillar 1: BlaiseX (`TBVStore 2.0` & State Machines)** | v5.0-alpha | `core/BVStore.pas` | Finite State Machines, time-travel history, action middleware |
| **Pillar 2: Full PWA Engine & Background Sync (`bv pwa`)** | v5.0-beta | `bin/bv.pas`, `core/BVDataSet.pas` | Service Worker caching, background sync with `ApplyUpdates` |
| **Pillar 3: Node-Free Dynamic Server-Side Rendering (mORMot 2 SSR)** | v5.0-rc | `server/`, `core/BVCompiler.pas` | Native Pascal SSR executed in <3ms without Node.js |
| **Pillar 4: BlaiseVue Studio 2.0 (Visual Modeler & Cockpit)** | v5.0-GA | `packages/core/blaise-studio/` | Drag-and-drop DB modeler, visual AST editor, live telemetry |

---

### 🗄️ Pillar 1: BlaiseX — Advanced Global State & Finite State Machines (`TBVStore 2.0`)
**Goal**: Evolve the existing `$store` (`core/BVStore.pas`) into an enterprise state management system inspired by Pinia, Redux Toolkit, and XState, written in 100% pure Object Pascal.

- **Motivation**: Large-scale financial, medical, and industrial systems require formal state machines (e.g. checkout workflows, claim approvals, multi-step wizards) with strict state transition guarantees and complete audit trails.
- **Architectural Scope**:
  1. **Finite State Machines (FSM)**:
     - Declarative states (`idle`, `loading`, `success`, `error`) and allowed transitions preventing invalid state jumps:
       ```pascal
       Machine := TBVStateMachine.Create('Payment')
         .Initial('idle')
         .State('idle', ['SUBMIT' -> 'processing'])
         .State('processing', ['RESOLVE' -> 'completed', 'REJECT' -> 'failed'])
         .State('completed', [])
         .State('failed', ['RETRY' -> 'processing']);
       ```
  2. **Action Middleware & Pipeline**:
     - Pre/post action interceptors allowing centralized logging, performance metrics, and authorization validation before executing mutations.
  3. **Time-Travel Debugging & State Snapshots**:
     - Integrated state history buffer enabling *Undo*, *Redo*, and real-time state replay directly within BlaiseVue DevTools.

---

### 📱 Pillar 2: Full PWA Engine & Service Worker Background Sync (`bv pwa`)
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
     - When connectivity is restored, the browser's native **Service Worker `sync` event wakes up in the background**, submits pending deltas via `POST /api/dataset/apply` to the mORMot 2 backend, reconciles primary keys, and broadcasts confirmations even if the tab was closed!
  4. **Native Web Push Bridge**:
     - System-level push notifications dispatched directly from mORMot 2 servers to client devices.

---

### ⚡ Pillar 3: Node-Free Dynamic Server-Side Rendering (mORMot 2 SSR)
**Goal**: Evolve the static build-time pre-rendering engine (`bv run ssg`) into a real-time, on-demand dynamic Server-Side Rendering (SSR) pipeline executed directly inside the native Synopse mORMot 2 backend in under 3 milliseconds.

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

### 🛠️ Pillar 4: BlaiseVue Studio 2.0 (Visual Cockpit & Database Modeler)
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

🛡️ **"Architecture is the art of making the impossible inevitable."** ✨🏆🚀
