# 🛡️ BlaiseVue: The Universal Reactive Framework for Object Pascal

> **The Universal Reactive Framework for Object Pascal.**  
> Build modern Web (SPA/SSG), Native Mobile (Android/iOS), and Ultra-light Desktop apps from a single Pascal codebase.

<p align="center">
  <img src="doc/images/blaisevue-showcase.png" alt="BlaiseVue Multiplatform Showcase (Web, Desktop, Mobile)" width="100%">
</p>

**BlaiseVue** is a high-performance, enterprise-grade universal reactive framework for **Object Pascal**. It combines the type safety, architectural robustness, and raw compilation speed of Pascal with the elegance, ergonomics, and reactivity of **Vue.js**, enabling seamless multiplatform deployment across Web, Mobile, and Desktop from a single codebase.

---

## 🌟 Version 3.0: The Enterprise Next-Gen Release

BlaiseVue 3.0 represents a generational milestone, delivering native WebAssembly acceleration, zero-configuration interactive documentation, and static site pre-rendering with zero-flicker hydration:

- **⚡ WebAssembly Acceleration Engine (`BVWasm` / `$wasm`)**: Execute compute-intensive algorithms in the browser with near-native binary speed (2x to 10x faster than pure JavaScript) via `$wasm.call('math', 'fib', 15)` and automated benchmarks (`bv wasm benchmark`).
- **📚 Automatic Documentation Generator & Playground (`bv doc`)**: Zero-configuration Storybook/VuePress-like interactive catalog generator analyzing component AST, props, slots, and events, served directly via `bv doc --serve`.
- **🚀 SSG & Static Pre-rendering (`bv run ssg`)**: Pre-renders routing trees into static HTML for instant First Contentful Paint (<50ms) and complete search engine indexing (SEO).
- **🌊 Zero-Flicker Reactive Hydration**: Seamlessly adopts pre-rendered SSG DOM markup without clearing `#app`, attaching event listeners and reactive proxies with zero layout shifts.
- **🧪 Headless End-to-End Test Suite (`bv test e2e`)**: Validates complete user journeys across routing, forms, theme switches, and hydration (130 automated tests passing across 12 test suites).
- **📋 Reactive Form Validation Engine (`b-validate`)**: Declarative client-side validation rules (`required`, `email`, `min:N`, `max:N`, `numeric`, `pattern`), reactive error tracking (`$errors`), touch states (`$v`), and programmatic validation (`$validate()`).
- **🎬 FLIP List Transitions (`<transition-group>`)**: High-performance collection animations powered by the First-Last-Invert-Play (FLIP) algorithm, custom wrapper tags (`tag="ul"`), and smooth reordering via `.bv-move`.
- **🌐 Native Internationalization (`Blaise-i18n`)**: Embedded multi-locale translation engine with `$t(key, params)`, reactive locale switching (`$setLocale(code)`), and fallback resolution.
- **🎨 Official Themes Package (`packages/blaise-themes`)**: 9 integrated Bootswatch themes (`flatly`, `darkly`, `cosmo`, `cyborg`, `lux`, `pulse`, `solar`, `vapor`, `zephyr`), dynamic stylesheet swapping, dark mode toggle (`data-bs-theme`), and ready-to-use `<bv-theme-toggle>` and `<bv-theme-select>` components.
- **🔤 Official Icons Package (`packages/blaise-icons`)**: Full integration with 2,000+ Bootstrap Icons via `<bv-icon name="..." size="..." color="...">` with zero runtime bloat.
- **⚡ Hot Module Replacement (HMR)**: Instant component recompilation and in-place DOM patching via WebSockets (`:8081`) while preserving active reactive state (`this['State']`).
- **🛣️ Advanced SPA Routing**: Clean URLs via **HTML5 History API**, recursive **Nested Routes** with `<router-view>`, dynamic route parameters (`:id`), and **Navigation Guards** (`beforeEach`, `beforeEnter`, `afterEach`).
- **🧩 Scoped Slots & Templates**: Seamless two-way data passing from child components back to parent templates (`#name="slotProps"`, `b-slot`, `slot-scope`).
- **🚀 Teleport & Suspense**: Mount elements into remote DOM targets (`<teleport to="body">`) and orchestrate asynchronous dependencies (`<suspense>`).
- **🏎️ Static Hoisting & Compiler Pruning**: Compiler-level static analysis tags invariant nodes (`bvStatic = true`), bypassing diff comparisons for $O(1)$ reconciliation.
- **📱 Hybrid Mobile Platform (Capacitor & Android .apk)**: Native mobile runtime targeting Android and iOS with native APK generation via `bv mobile build`.
- **📐 Responsive Grid System (`<bv-container>`, `<bv-row>`, `<bv-col>`)**: Fluid 12-column grid layout with Bootstrap-compatible breakpoints (`cols`, `sm`, `md`, `lg`, `xl`) and gutter controls.
- **🧭 Mobile Bottom Navigation & Drawer**: Bottom-pinned mobile navigation (`<bv-bottom-nav>`, `<bv-bottom-nav-item>`) and off-canvas drawer (`<bv-drawer>`).
- **🛠️ VS Code Official Extension (`.vsix`)**: Triple syntax highlighting for `.bv`, directive autocompletion, BlaiseUI IntelliSense, and snippets (`bv vsix`, `bv extension install`).
- **📦 BlaiseUI Official Component Kit**: Over 25 production-ready UI widgets (`bv-btn`, `bv-card`, `bv-input`, `bv-modal`, `bv-datagrid`, `bv-chart`, `bv-toast`, `bv-accordion`, `bv-container`, `bv-row`, `bv-col`, `bv-drawer`, `bv-bottom-nav`) styled with clean modern CSS.

---

## 📦 Official Packages Ecosystem

BlaiseVue features a modular package architecture located in `/packages`:

| Package | Description | Key Components / Features |
| :--- | :--- | :--- |
| **`blaise-ui`** | Native Bootstrap-inspired component kit | `<bv-btn>`, `<bv-card>`, `<bv-modal>`, `<bv-datagrid>`, `<bv-chart>`, `<bv-toast>`, `<bv-navbar>`, `<bv-tabs>` |
| **`blaise-themes`** | 9 Bootswatch themes + reactive theme management | Flatly, Darkly, Cosmo, Cyborg, Lux, Pulse, Solar, Vapor, Zephyr, `<bv-theme-toggle>`, `<bv-theme-select>`, `$theme` |
| **`blaise-icons`** | Bootstrap Icons library (fonts + CSS) | `<bv-icon name="heart-fill" size="24px" color="red">`, 2,000+ vector icons |
| **`blaise-charts`** *(Planned v4.0)* | Reactive Chart.js data visualization suite | `<bv-chart>`, 8 chart types (bar, line, pie, radar, etc.), strongly typed Pascal datasets & auto-updating canvas |
| **`blaise-ui-mobile`** *(Planned v4.0)* | Mobile-first Ionic components & Pascal wrappers | `<ion-app>`, `<ion-toolbar>`, iOS/Android adaptive themes, `TIonicToast`, `TIonicAlert` |

Install packages directly into your project via the CLI:
```bash
bv lib install themes   # Installs Bootswatch themes and switcher components
bv lib install icons    # Installs Bootstrap Icons fonts and stylesheets
bv lib install ui       # Installs the complete BlaiseUI component suite
bv lib install charts   # (Planned v4.0) Installs Chart.js data visualization suite
```

---

## 🛠️ CLI Quick Reference (`bv.exe`)

The BlaiseVue CLI is a single, zero-dependency native executable compiled with Free Pascal.

```bash
# === Development & Server ===
bv dev                     # Starts development server with HMR on http://localhost:8080 (alias: bv serve)
bv serve                   # Starts development server with HMR
bv run dev                 # Builds project in development mode with cache-busting
bv run build               # Builds optimized production bundle in dist/
bv run preview             # Local HTTP preview of production build (port 5000)
bv clean                   # Cleans generated files (generated/ and dist/)

# === Scaffolding & Generators ===
bv create <app-name>       # Scaffolds a complete new BlaiseVue project
bv new c <Name>            # Scaffolds a new component (.bv) in src/components/
bv new v <Name>            # Scaffolds a new route view (.bv) in src/views/
bv new t <Name>            # Scaffolds a new Pascal test file (.test.pas) in tests/
bv remove <c|v|t> <Name>   # Safely deletes a component, view, or test
bv list <c|v|t|lib>        # Lists project components, views, tests, or installed libs

# === Package & Theme Management ===
bv lib install <pkg|url>   # Installs official package (themes, icons, ui) or from URL
bv lib remove <name>       # Removes an installed component or package from lib/
bv theme list              # Lists all available installed themes
bv theme use <name>        # Sets default project theme in index.html (e.g. darkly, lux)

# === Mobile (Android & iOS via Capacitor) ===
bv mobile init [name] [id] # Scaffolds Capacitor & mobile/ native project
bv mobile sync             # Syncs dist/ with native mobile assets
bv mobile build android    # Builds native Android Debug APK in mobile/bin/android/
bv mobile build android --release # Builds optimized Release APK (R8/ProGuard)
bv mobile emulator list    # Lists installed Android Virtual Devices (AVD)
bv mobile emulator start   # Boots Android emulator in background
bv mobile run android      # Installs and launches APK on connected USB device
bv mobile run android --emulator # Boots emulator, installs APK, and runs app
bv mobile open android     # Opens project in Android Studio

# === Desktop (Free Pascal, Lazarus IDE & WebUI) ===
bv desktop init [name]     # Scaffolds Lazarus (.lpi, .lpr) & WebUI project
bv desktop sync            # Syncs dist/ to desktop/assets/
bv desktop build [target]  # Compiles Debug native binary (live console logging)
bv desktop build [target] --release # Compiles Release native binary (pure GUI - NO console)
bv desktop run [target]    # Launches desktop app in Debug mode (with console)
bv desktop run [target] --release # Launches desktop app in Release mode (clean GUI)

# === Backend & Full-Stack (Synopse mORMot 2) ===
bv create <name> --mormot  # Scaffolds full-stack app with mORMot 2 native backend (--fullstack / -m)
bv mormot init             # Scaffolds mORMot 2 backend server in server/
bv mormot build            # Compiles Debug native server with Free Pascal
bv mormot build --release  # Compiles optimized Release native server (-O3, stripped)
bv mormot run              # Starts native backend server on port 8090
bv mormot status           # Queries /api/status health endpoint
bv mormot deploy           # Packages standalone production bundle in deploy/
bv mormot deploy --zip     # Packages standalone bundle into deploy.zip
                           # (Note: bv server commands preserved as aliases)

# === Testing ===
bv test                    # Compiles .test.pas files and runs Vitest suite
```

---

## 🔮 Architectural Milestones & Roadmap

Our architectural evolution roadmap:

- [x] **v2.0**: SPA Router, History API, Scoped Slots, DevTools, Static Hoisting, Vitest.
- [x] **v2.5**: Form Validation (`b-validate`), List Transitions (`<transition-group>`), Native i18n (`$t`).
- [x] **v2.6**: Bootswatch Themes (`blaise-themes`), Bootstrap Icons (`blaise-icons`), `$theme` engine.
- [x] **v3.0 Enterprise**: Automatic Documentation Generator (`bv doc`), WebAssembly Acceleration (`$wasm`), SSG (`bv run ssg`), Zero-Flicker Hydration, Headless E2E Test Suite (`bv test e2e`).
- [x] **v3.5 Universal Pascal Platform (100% Complete - Phases 1, 2, 3 & 4 Delivered)**:
  - [x] 🛠️ **Phase 1: Professional DX**: VS Code Extension (`.vsix`) with directive autocomplete, BlaiseUI Kit suggestions, and snippets (`bv vsix`, `bv extension install`).
  - [x] 📱 **Phase 2: Hybrid Mobile**: Native Android (`.apk`) & iOS integration via Capacitor (`bv mobile init|sync|open|build`), responsive 12-column grid (`<bv-container>`, `<bv-row>`, `<bv-col>`), mobile bottom navigation (`<bv-bottom-nav>`), and off-canvas drawer (`<bv-drawer>`).
  - [x] 🖥️ **Phase 3: Real Cross-Platform Desktop**: Ultra-lightweight native desktop app via WebUI & Lazarus IDE (`bv desktop init|sync|build|run`) with dual Debug (console logs) and Release (pure GUI without console) modes.
  - [x] ⚙️ **Phase 4: Full-Stack Pascal**: High-throughput backend integration with Synopse mORMot 2 (`bv mormot init|build|run|status`, `--mormot`, `$api`, `$ws`).
- [ ] **v4.0 Enterprise Ecosystem & Developer Superpowers (Planned 📋)**:
  - [ ] ⚡ **Phase 1: Full-Stack CRUD & ORM Generator**: Rapid entity scaffolding (`bv mormot crud <Model> <fields...>`) generating Pascal records, mORMot 2 ORM endpoints, and reactive frontend `<bv-data-grid>` views.
  - [ ] 🔐 **Phase 2: Enterprise Authentication & Route Guards (`$auth`)**: Native JWT middleware, Argon2 password hashing, and reactive `this.$auth` with role-based routing guards.
  - [ ] 📜 **Phase 3: Live Swagger / OpenAPI 3.0**: Auto-generated interactive API documentation and testing portal at `/api/docs`.
  - [ ] 🐳 **Phase 4: Cloud-Native Micro-Containers**: Production Dockerfile multi-stage builds (`bv mormot docker`) producing ultra-lean (< 20 MB) Alpine/Scratch containers.
  - [ ] 📱 **Phase 5: Mobile-First Ecosystem (`blaise-ui-mobile`)**: Standalone Ionic Web Components package with Pascal controller wrappers (`BlaiseIonic.pas`), providing native iOS/Android look & feel for both mobile apps and web/PWA.
  - [ ] 📊 **Phase 6: Data Visualization & Analytics (`blaise-charts`)**: Dedicated Chart.js package with strongly typed Pascal dataset configuration (`BlaiseCharts.pas`), reactive `<bv-chart>` component, and hardware-accelerated 60 FPS canvas rendering.
  - [ ] 🎨 **Phase 7: BlaiseVue Studio**: Visual developer dashboard (`bv studio`) for real-time WebSocket debugging, component tree visualization, and 1-click workflows.

> [!TIP]
> **Detailed Engineering Plan**: Read the complete specification in the [Technical Roadmap](doc/Documentation/99-roadmap.md), [Desktop Documentation](doc/Documentation/36-desktop-webui.md), and [Full-Stack mORMot 2 Documentation](doc/Documentation/37-mormot2-backend.md).

---

## 📂 Project Structure

```text
BlaiseVue/
├── bin/                       # BlaiseVue CLI compiler & dev server (bv.pas, bv.exe)
├── core/                      # Core runtime engine
│   ├── BlaiseVue.pas          # Core SPA instance orchestrator & Hydration
│   ├── BVCompiler.pas         # Template engine, directives, AST parser
│   ├── BVReactivity.pas       # Reactive proxy & dependency tracking
│   ├── BVRouting.pas          # SPA Router & HTML5 History API
│   ├── BVValidation.pas       # Reactive form validation engine (b-validate)
│   ├── BVI18n.pas             # Internationalization engine ($t)
│   ├── BVTheme.pas            # Theme switcher & persistence engine ($theme)
│   ├── BVWasm.pas             # WebAssembly acceleration engine ($wasm)
│   ├── BVStore.pas            # Centralized state management ($store)
│   ├── BVClient.pas           # REST ($api) & WebSocket ($ws) client helpers
├── templates/                 # Scaffolding templates
│   ├── fullstack-mormot/      # High-performance mORMot 2 server template
│   └── BVDevTools.pas         # Bridge to browser DevTools extension (v3.0)
├── packages/                  # Official ecosystem packages
│   ├── blaise-ui/             # 20+ native UI components & styles
│   ├── blaise-themes/         # 9 Bootswatch themes & theme switchers
│   ├── blaise-icons/          # Bootstrap Icons fonts & stylesheet
│   ├── blaise-charts/         # (Planned) Reactive Chart.js visualization & Pascal wrappers
│   └── blaise-ui-mobile/      # (Planned) Mobile-first Ionic components & Pascal wrappers
├── vendor/                    # Embedded compiler & backend engines
│   ├── pas2js/                # Multi-platform pas2js transpiler & RTL
│   └── mormot2/               # High-throughput Synopse mORMot 2.4 framework
├── devtools/                  # Manifest V3 Chrome/Edge DevTools extension
├── doc/
│   ├── Documentation/         # 33 comprehensive technical manuals + API Reference
│   └── Course/                # 10-lesson practical course and architecture deep-dive
└── demo-app/                  # Enterprise showcase application (v3.0)
```

---

## 🏁 Quick Start

### 📋 Prerequisites
- **Lazarus IDE (or Free Pascal Compiler 3.2+)**: Recommended IDE and compiler for building the native CLI (`bv` / `bv.exe`), desktop applications (`desktop/`), and mORMot 2 servers (`server/`).
- **Node.js (v18+ LTS) & npm**: Powers the development server with HMR (`bv serve` / `bv dev`), automated testing (`bv test`), and mobile synchronization (`bv mobile`).
- **Android Studio (Recommended for Mobile)**: Required for compiling native Android `.apk` / `.aab` packages (`bv mobile build`), managing emulators, and running `bv mobile open android`. Bundles the Android SDK, Platform-Tools (`adb`), and Java JDK.

> [!NOTE]
> **Pas2JS is pre-bundled**: You do **not** need to install `pas2js`. Official multi-platform binaries for Windows, Linux, and macOS are already included in `vendor/pas2js/`.

### 1. Compile the BlaiseVue CLI
Ensure you have **FPC (Free Pascal Compiler 3.2+)** installed (included with Lazarus):
```bash
cd bin
fpc -O2 bv.pas
# Move bv or bv.exe to your PATH or use directly from bin/
```

### 2. Pre-bundled Pas2JS Compiler
BlaiseVue comes with the `pas2js` transpiler already included under `vendor/pas2js/`. The CLI automatically detects your platform (Windows, Linux, macOS) with zero manual configuration required!

### 3. Launch the Demo App
```bash
cd demo-app
..\bin\bv.exe serve
# Open http://localhost:8080 in your browser
```

---

## ⚖️ Licensing

BlaiseVue is open-source and follows the standard **Lazarus / Free Pascal** licensing model:
- **The BlaiseCLI tool (`bin/`):** Licensed under the **GNU GPL v2**.
- **The BlaiseVue Core (`core/`):** Licensed under the **Modified GNU LGPL v2.1** with a **Static Linking Exception**.

This allows developers to build **commercial and proprietary applications** without having to open-source their proprietary code, while ensuring the framework runtime remains open and accessible to all. See the [LICENSE](LICENSE) file for details.

---

🛡️ **"BlaiseVue: The Universal Reactive Framework for Object Pascal."** ✨🏆🚀
