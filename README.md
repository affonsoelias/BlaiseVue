# 🛡️ BlaiseVue: The Modern Pascal SPA Framework

**BlaiseVue** is a high-performance, enterprise-grade Single Page Application (SPA) framework for **Object Pascal**. It combines the type safety, architectural robustness, and raw compilation speed of Pascal with the elegance, ergonomics, and reactivity of **Vue.js**.

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
- **🕵️ Browser DevTools Extension**: Dedicated Manifest V3 extension for Chrome/Edge with Component Tree inspection, real-time reactive state editing, and timeline logging.
- **📦 BlaiseUI Official Component Kit**: Over 20 production-ready UI widgets (`bv-btn`, `bv-card`, `bv-input`, `bv-modal`, `bv-datagrid`, `bv-chart`, `bv-toast`, `bv-accordion`, etc.) styled with clean modern CSS.

---

## 📦 Official Packages Ecosystem

BlaiseVue features a modular package architecture located in `/packages`:

| Package | Description | Key Components / Features |
| :--- | :--- | :--- |
| **`blaise-ui`** | Native Bootstrap-inspired component kit | `<bv-btn>`, `<bv-card>`, `<bv-modal>`, `<bv-datagrid>`, `<bv-chart>`, `<bv-toast>`, `<bv-navbar>`, `<bv-tabs>` |
| **`blaise-themes`** | 9 Bootswatch themes + reactive theme management | Flatly, Darkly, Cosmo, Cyborg, Lux, Pulse, Solar, Vapor, Zephyr, `<bv-theme-toggle>`, `<bv-theme-select>`, `$theme` |
| **`blaise-icons`** | Bootstrap Icons library (fonts + CSS) | `<bv-icon name="heart-fill" size="24px" color="red">`, 2,000+ vector icons |

Install packages directly into your project via the CLI:
```bash
bv lib install themes   # Installs Bootswatch themes and switcher components
bv lib install icons    # Installs Bootstrap Icons fonts and stylesheets
bv lib install ui       # Installs the complete BlaiseUI component suite
```

---

## 🛠️ CLI Quick Reference (`bv.exe`)

The BlaiseVue CLI is a single, zero-dependency native executable compiled with Free Pascal.

```bash
# === Development & Server ===
bv serve                   # Starts development server with HMR on http://localhost:8080
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
- [ ] **v3.5 Universal Pascal Platform (In Progress)**:
  - 🛠️ **Phase 1: Professional DX**: VS Code Extension (`.vsix`) with directive autocomplete, BlaiseUI Kit suggestions, and snippets.
  - 📱 **Phase 2: Hybrid Mobile**: Native Android (`.apk`) & iOS integration via Capacitor (`bv mobile init/run`).
  - 🖥️ **Phase 3: Real Cross-Platform Desktop**: Ultra-lightweight native desktop app via WebUI4Delphi & Lazarus IDE (`bv desktop`).
  - ⚙️ **Phase 4: Full-Stack Pascal**: High-throughput backend integration with Synopse mORMot 2 (`--template fullstack-mormot`).

> [!TIP]
> **Detailed Engineering Plan**: Read the complete specification in the [Technical Roadmap (v3.0 & v3.5)](doc/Documentation/99-roadmap-v3.md).

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
│   └── BVDevTools.pas         # Bridge to browser DevTools extension (v3.0)
├── packages/                  # Official ecosystem packages
│   ├── blaise-ui/             # 20+ native UI components & styles
│   ├── blaise-themes/         # 9 Bootswatch themes & theme switchers
│   └── blaise-icons/          # Bootstrap Icons fonts & stylesheet
├── devtools/                  # Manifest V3 Chrome/Edge DevTools extension
├── doc/
│   ├── Documentation/         # 33 comprehensive technical manuals + API Reference
│   └── Course/                # 10-lesson practical course and architecture deep-dive
└── demo-app/                  # Enterprise showcase application (v3.0)
```

---

## 🏁 Quick Start

### 1. Compile the BlaiseVue CLI
Ensure you have **FPC (Free Pascal Compiler 3.2+)** installed:
```bash
cd bin
fpc -O2 bv.pas
# Move bv or bv.exe to your PATH or use directly from bin/
```

### 2. Set Up Pas2JS (Multi-platform)
Download the [Pas2JS 3.2.0](https://getpas2js.freepascal.org) archive for your OS (Windows, Linux, or macOS) and extract it into a `pas2js/` folder at the repository root:
- `/pas2js/pas2js-win64-x86_64-3.2.0/`
- `/pas2js/pas2js-linux-x86_64-3.2.0/`
- `/pas2js/pas2js-darwin-x86_64-3.2.0/`

The CLI automatically detects your platform and invokes the matching compiler!

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

🛡️ **"BlaiseVue: Bringing Pascal to the modern Web, and the Web to Pascal."** ✨🏆🚀
