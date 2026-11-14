<p align="center">
  <a href="../../README.md">
    <img src="../brand/banner.png" alt="BlaiseVue: The Object Pascal Reactive Framework" width="100%">
  </a>
</p>

# 🛡️ BlaiseVue 4.4 Documentation
**The Universal Reactive Framework for Object Pascal.**  
Build modern Web (SPA/SSG), Native Mobile (Android/iOS), Ultra-light Desktop, and High-Throughput Full-Stack microservices from a single Pascal codebase.

---

## 🌟 The BlaiseVue 4.4 Enterprise Universal Architecture

BlaiseVue 4.4 represents an enterprise generational milestone, delivering full-stack mORMot 2 integration, native mobile and desktop suites, interactive developer cockpit, zero-ASM pure Object Pascal DX, compile-time template verification, and offline-first dataset synchronization:

- **⚡ Compiler Template Type-Checking & Zero-`with()` Native Templates (v4.4)**: Recursive-descent AST evaluator (`bv.fastEval`) with LRU caching, strict CSP compliance, and compile-time AST verification with Levenshtein typo suggestions (`bv check`).
- **💾 Offline-First `TBVDataSet` & Delta Sync (v4.4)**: High-capacity IndexedDB persistence with transactional delta tracking (`FDelta`), server ID reconciliation, and automated reconnect triggers for mORMot 2 (`ApplyUpdates`).
- **🔗 Relational Master-Detail CRUD & Multi-Database ORM (v4.4)**: Automated relational model generation (`bv mormot crud`) with foreign keys, nested views, and pluggable database support (`--db sqlite|postgres|mysql|firebird` or `.env`).
- **🏎️ High-Performance Virtual Scrolling (v4.4)**: DOM virtualization engine (`<bv-virtual-scroll>`) rendering 100,000+ records at a constant 60 FPS in `<bv-data-grid>`.
- **📦 Standalone Library Scaffolding & Packaging (v4.4)**: Dedicated library generator (`bv create --lib`) with interactive license selection (MIT, Apache, LGPL), isolated HMR playground, autonomous test suite, and release packager (`bv lib pack`).
- **🛡️ Project Metadata, Licensing Suite & Clean Slate Reset (v4.4)**: Automated licensing (`bv license`), SemVer bumping (`bv meta bump`), Pascal unit sync (`src/uAppVersion.pas`), and clean slate project reset (`bv reset`) with double-layered safety guards.
- **🛡️ End-to-End Type-Safe Pascal RPC with mORMot 2 (v4.3)**: Shared service interfaces (`ICustomerService`), automated client proxy generation (`bv mormot rpc`), dual HTTP/WebSocket transport, JSON-RPC 2.0, and 100% compile-time API validation in pure Object Pascal.
- **📊 LiveBindings & Reactive `TBVDataSet` (v4.2)**: Delphi/Lazarus data-aware semantics in modern reactive Web applications. In-memory cursor navigation (`First`, `Next`, `Prior`, `Last`), transactional buffering (`Append`, `Edit`, `Post`, `Delete`), strongly typed fields (`AsString`, `AsInteger`, `AsFloat`, `AsBoolean`), and two-way `b-field` directive.
- **📱 Universal Hybrid Mobile Suite (Capacitor & `@blaise-ui-mobile`)**: 22+ adaptive Ionic components with Cupertino (iOS) and Material Design (Android) aesthetics, touch gestures, and safe-area notch handling.
- **🖥️ Ultra-Lightweight Native Desktop (`bv desktop`)**: Standalone native desktop applications (<10 MB, 40 MB RAM) running across Windows, Linux, and macOS without Electron overhead.
- **⚡ WebAssembly Acceleration Engine (`BVWasm` / `$wasm`)**: Near-native binary execution for compute-intensive routines in the browser.
- **🎨 Master Component Catalog (60+ Production Widgets)**: Official packages for UI (`@blaise-ui`), Bootswatch themes (`@blaise-themes`), 2,000+ vector icons (`@blaise-icons`), reactive Chart.js (`@blaise-charts`), and vector PDF/Excel reports (`@blaise-reports`).
- **🚀 Full-Stack mORMot 2 Micro-Containers**: Production Dockerfile multi-stage builds (`bv mormot docker`) generating sub-20 MB Alpine containers with <15ms startup time.

---

## 📚 Complete Documentation Index

> 💡 **New to Pascal or Web Development?** Check out our practical step-by-step **[Complete Course: From Zero to Ninja](../Course/README.md)** (13 beginner-friendly modules with runnable code, analogies, and exercises).


### 🏁 1. Getting Started & Core Fundamentals
1. [01. Architecture and Mission](01-introduction.md) — The philosophy and vision behind BlaiseVue.
2. [02. Installation & SDK Setup](02-installation.md) — System requirements, FPC setup, and pre-bundled Pas2JS compiler.
3. [03. BlaiseCLI Technical Manual (bv.exe)](03-cli.md) — Complete command-line interface reference for scaffolding, building, and running apps.
4. [04. Single File Component (.bv) Format](04-bv-format.md) — Structure of `<template>`, `<script>`, and `<style>` sections in `.bv` files.
5. [05. Reactivity Engine & State Management](05-reactivity.md) — Practical guide to state mutation, reactive arrays, computed caching, and dependency tracking proxies.
6. [06. Data Binding & Directives](06-data-binding.md) — Two-way binding (`b-model`), conditionals (`v-if`), loops (`b-for`), and expressions.
7. [07. Methods & Event Handling](07-methods-events.md) — Declarative event listeners (`@click`, `@input`), modifiers, and Pascal methods.
8. [08. Component Basics & SFC](08-components.md) — Creating, declaring, and composing reusable reactive components.
10. [10. Standard Project Structure](10-project-structure.md) — Organization of files across `src/`, `lib/`, `generated/`, and `dist/`.

### 🧭 2. Routing, Navigation & Global State
9. [09. Advanced SPA Router](09-router.md) — HTML5 History API, nested routes with `<router-view>`, dynamic parameters, and guards.
11. [11. Props, Refs, and Custom Events ($emit)](11-props-refs-emit.md) — Parent-child communication, template refs (`$refs`), and custom event dispatching.
13. [13. Advanced Slots & Scoped Slots](13-advanced-slots.md) — Content distribution, named slots, and scoped data passing.
15. [15. Global State Management ($store)](15-global-store.md) — Centralized reactive store pattern across pages and components.
16. [16. Dependency Injection (Provide / Inject)](16-provide-inject.md) — Cross-hierarchy state sharing without prop-drilling.
17. [17. Component Lifecycle Hooks](17-lifecycle-pro.md) — `created`, `mounted`, `updated`, and `unmounted` hooks.

### 📋 3. Forms, Validation & Reactive DataSets
25. [25. Form Validation Engine (b-validate)](25-form-validation.md) — Typed rules, reactive error banners, dirty state tracking, and programmatic `$validate()`.
26. [26. List Transitions (<transition-group>)](26-transition-group.md) — Smooth FLIP animations for entering, leaving, and reordering list items.
27. [27. Integrated Internationalization (Blaise-i18n)](27-i18n.md) — Multi-locale dictionaries, token interpolation, and runtime `$setLocale`.
42. [42. LiveBindings & Reactive TBVDataSet](42-livebindings-dataset.md) — Delphi/Lazarus-style in-memory dataset, cursor navigation, CRUD buffers, delta tracking, and `<bv-datagrid :dataset="...">`.
47. [47. Enterprise UI Performance: Virtual Scrolling](47-virtual-scrolling.md) — DOM node virtualization and recycling engine for 50,000+ records at constant 60 FPS with `<bv-virtual-scroll>` and `<bv-data-grid>`.

### 📦 4. Official Component Packages & UI Kits
24. [24. BlaiseUI (Official Component Kit)](24-blaise-ui.md) — Overview of the native 25+ widget kit (buttons, modals, cards, tabs, drawers).
28. [28. Themes & Bootswatch Integration ($theme)](28-themes.md) — 9 Bootswatch themes, dark mode toggle, and dynamic stylesheet switching.
29. [29. Blaise Icons & Bootstrap Icons (bv-icon)](29-icons.md) — 2,000+ vector icons with size and color customization.
38. [38. Mobile UI Kit (blaise-ui-mobile)](38-mobile-ionic.md) — Ionic Web Components with strongly typed Object Pascal controllers.
39. [39. Reactive Chart.js Suite (blaise-charts)](39-blaise-charts.md) — High-performance canvas charts (Bar, Line, Pie, Radar, Bubble) with typed datasets.
41. [41. Package Components Catalog & Manual](41-package-components-catalog.md) — Comprehensive reference manual covering props, events, slots, and copy-pasteable snippets for all 53+ components.
48. [48. External Library Scaffolding & Release Packager](48-library-distribution-packager.md) — Scaffolding dedicated standalone component libraries with interactive licensing (`bv create --lib`) and automated release distribution (`bv lib pack`) with SHA-256 integrity verification.
49. [49. Project Metadata, Licensing Suite & Clean Slate Reset](49-project-metadata-licensing-reset.md) — Automated license generation (`bv license`), SemVer & metadata sync (`bv meta`), synchronized Pascal unit (`src/uAppVersion.pas`), and clean slate reset (`bv reset`) with framework safety guards.
50. [50. Package Ecosystem & Registries](50-package-ecosystem-and-registries.md) — Multi-tier package manager architecture, registry sources (`bv repo`), 4-layer resolution (`lib/`, global cache, core, remote), SemVer versioning (`@version`), updates (`bv lib outdated` / `bv lib update`), and community ecosystem distribution.
51. [51. BlaiseReports: Native Vector PDF, Excel & Print Engine](51-blaise-reports.md) — Declarative enterprise reporting and multi-format document export engine in pure Object Pascal with `TBVReport` and print optimization.
52. [52. Global Mixins and Global Plugins in BlaiseVue](52-mixins-and-plugins.md) — Extending framework functionality, global option injection, and cross-cutting plugin architecture.

### ⚙️ 5. Full-Stack mORMot 2 & Cloud Architecture
37. [37. Full-Stack Pascal with mORMot 2](37-mormot2-backend.md) — High-throughput REST API, ORM, WebSockets, JWT authentication, and Docker micro-containers.
43. [43. End-to-End Type-Safe Pascal RPC with mORMot 2](43-typesafe-rpc-mormot.md) — Shared Pascal service contracts, automated proxy scaffolding (`bv mormot rpc`), and compile-time API validation.
46. [46. Multi-Database ORM & Relational Master-Detail CRUD](46-relational-master-detail-crud.md) — Pluggable database engines (SQLite, Postgres, MySQL, Firebird), foreign key mapping, and parent-child dual-grid CRUD scaffolding (`bv mormot crud`).

### 📱 6. Universal Multiplatform (Mobile & Desktop)
35. [35. Hybrid Mobile Platform & Capacitor (bv mobile)](35-mobile-capacitor.md) — Native Android APK builds, emulator management, and responsive 12-column mobile layout.
36. [36. Multiplatform Desktop & Lazarus IDE (bv desktop)](36-desktop-webui.md) — Ultra-lightweight native desktop apps (<10 MB) via WebUI with dual Debug and Release GUI modes.

### 🛠️ 7. Tooling, Optimization & Developer Experience
12. [12. Debugging & Error Handling](12-debugging.md) — Source maps, runtime error boundaries, and console inspection.
14. [14. CSS Transitions & Animations](14-css-transitions.md) — Declarative `<transition>` wrapper with enter/leave classes.
18. [18. External Libraries & Setup Scripts (/lib)](18-external-libraries.md) — Installing and managing community packages via `bv lib`.
19. [19. Automated Unit & Integration Testing (4-Tier Architecture)](19-unit-testing.md) — Writing and executing automated tests in Pascal across 4 tiers (components, views, unit services, framework) with JSDOM and Vitest.
20. [20. Consolidating Extra Libraries](20-extra-libraries.md) — Architecture for package imports and stylesheet bundling.
21. [21. Teleport & Suspense](21-teleport-suspense.md) — DOM target relocation and asynchronous loading wrappers.
22. [22. Static Hoisting & Compiler Optimization](22-static-hoisting.md) — Compile-time static analysis and diff pruning for peak rendering performance.
23. [23. Hot Module Replacement (HMR) & DevTools](23-hmr-devtools.md) — Instant live reloading preserving component state, and browser DevTools extension.
30. [30. WebAssembly Acceleration Engine (BVWasm)](30-wasm-acceleration.md) — Hybrid Pascal/Wasm execution pipeline with automated benchmarking.
31. [31. Automatic Documentation Generator & Playground (bv doc)](31-doc-generator.md) — Interactive AST-based component catalog and Storybook-like explorer.
32. [32. SSG & Static Pre-rendering with Reactive Hydration](32-ssg-and-hydration.md) — Instant First Contentful Paint and SEO pre-rendering.
33. [33. Headless End-to-End Test Suite (bv test e2e)](33-e2e-testing.md) — Automated browser-based end-to-end integration tests.
34. [34. VS Code Extension & Professional DX (.vsix)](34-vscode-extension.md) — Official IDE extension with syntax highlighting, IntelliSense, and snippets.
40. [40. BlaiseVue Studio Dashboard (bv studio)](40-blaise-studio.md) — Web-based developer cockpit for real-time WebSocket monitoring and workflows.
44. [44. Native Fast Templates & Compiler AST Verifier](44-native-templates-ast-checker.md) — Zero-with template evaluation, 100% CSP compliance, and compile-time AST typo checking.
53. [53. Compiler Search Paths & Legacy Pascal Migration (bv path)](53-compiler-search-paths-and-legacy-migration.md) — Linking official Pas2JS built-in packages (chartjs, fcl-base, jspdf) and importing legacy Lazarus/Delphi business logic without rewriting.
54. [54. Lazarus IDE Integration & Design-Time Package (blaisevue_ide.lpk)](54-lazarus-ide-package.md) — Official Lazarus design-time package with tri-syntax highlighting (`.bv`), File -> New wizards, Tools menu, and `bv lazarus init`.

### 📖 8. Technical References & Roadmaps
- [API Technical Reference](api-reference.md) — Complete technical specification of global helpers, classes, and directives.
- [Technical Roadmap (v2.0 - v4.4)](99-roadmap.md) — Detailed milestone history and upcoming feature specifications.

---

## 🛠️ CLI Quick Reference (`bv.exe`)

The BlaiseVue CLI is a single, zero-dependency native executable compiled with Free Pascal.

```bash
  BlaiseVue CLI v4.4.0 (Universal Pascal Full-Stack Platform)
  ============================================================
  Usage: bv <command> [options]

  # === Scaffolding & Generators ===
  bv create <name>           Scaffolds a new project with 4-tier testing hierarchy & domain services
  bv g c <Name>              Scaffolds a component (.bv) & test in tests/components/ (alias: bv new c)
  bv g v <Name>              Scaffolds a route view (.bv) & test in tests/views/ (alias: bv new v)
  bv g s <Name>              Scaffolds a pure Pascal domain service in src/services/ (alias: bv new s)
  bv g t <Name>              Scaffolds a Pascal test file (.test.pas) (alias: bv new t)
  bv remove <c|v|s|t> <Name> Safely deletes a component, view, service, or test
  bv list <c|v|s|t|lib>      Lists project components, views, services, tests, or installed libs
  bv rename <c|v|s|p>        Smart rename for services, components, views, or project name

  # === Workspace & Project Cockpit ===
  bv files [path] [--all]    Displays structured project files tree with architecture roles
  bv clear                   Clears terminal screen & refreshes header
  bv enter                   Enters interactive project Cockpit shell with [TAB] autocomplete & history
  bv use <project-name>      Jumps into registered project Cockpit shell from anywhere
  bv project add             Registers current project into global registry
  bv project list            Lists registered projects (* active)
  bv project current         Shows active project details
  bv project remove <name>   Unregisters a project from global registry

  # === Development & Frontend Build ===
  bv dev                     Builds project in dev mode & starts dev server with HMR on http://localhost:8080
  bv build                   Compiles frontend in development/debug mode (Lazarus & watchers)
  bv build --release         Builds optimized production bundle with hashes in dist/
  bv preview                 Local HTTP preview of production build (port 5000)
  bv ssg                     Pre-renders all routes into static HTML (SSG)
  bv wasm <info|benchmark>   WebAssembly acceleration and performance benchmarks
  bv check [file]            Validates component templates against script declarations (AST Type-Checker)
  bv clean                   Cleans generated build files (generated/ and dist/)

  # === Backend & Full-Stack (Synopse mORMot 2) ===
  bv mormot init             Scaffolds mORMot 2 backend server in server/
  bv mormot run [--release] [--fresh] [--port <p>] Starts native backend server (--fresh kills lingering instances)
  bv mormot build [--release] Compiles native server binary with Free Pascal (-O2 debug / -O3 release)
  bv mormot kill [--port <p>] Terminates lingering server.exe instances & verifies port release
  bv mormot status           Queries running mORMot 2 health endpoint (/api/status)
  bv mormot deploy [--zip]   Assembles standalone production bundle in deploy/
  bv mormot crud <Model>     Scaffolds full-stack ORM model, REST API & reactive DataGrid
  bv mormot auth             Scaffolds JWT authentication, AuthService, LoginView & route guards
  bv mormot docs | swagger   Generates interactive OpenAPI 3.0 & Swagger UI explorer (/api/docs)
  bv mormot docker [--build] Scaffolds sub-20MB Alpine micro-container & docker-compose.yml
  bv mormot rpc              Scaffolds type-safe Pascal RPC client proxies from SOA interfaces

  # === Mobile (Android & iOS via Capacitor) ===
  bv mobile init [name] [id] [--version=<v>] Scaffolds Capacitor & mobile/ native project
  bv mobile upgrade [--check] Migrates Capacitor dependencies & updates Gradle
  bv mobile sync             Syncs dist/ with native mobile assets
  bv mobile remove [-y]      Safely deletes mobile/ and capacitor.config.json
  bv mobile build android    Builds native Android Debug APK in mobile/bin/android/
  bv mobile build android --release Builds optimized Release APK (R8/ProGuard)
  bv mobile build android --bundle Builds Google Play Android App Bundle (.aab)
  bv mobile emulator list    Lists installed Android Virtual Devices (AVD)
  bv mobile emulator start   Boots Android emulator in background
  bv mobile emulator kill    Terminates lingering emulator & QEMU processes (alias: bv mobile kill)
  bv mobile run android      Installs and launches APK on connected USB device
  bv mobile run android --emulator [--release] [--fresh] Boots emulator, compiles & launches app (flags can be combined)
  bv mobile open android     Opens project in Android Studio

  # === Desktop (Free Pascal, Lazarus IDE & WebUI) ===
  bv lazarus init            Scaffolds & syncs root Lazarus project (.lpi, .lpr) for IDE development
  bv lazarus sync            Synchronizes all .bv components and Pascal units in Lazarus project tree
  bv desktop init [name]     Scaffolds Lazarus (.lpi, .lpr) & WebUI project
  bv desktop sync            Syncs dist/ with desktop/assets/
  bv desktop remove [-y]     Safely deletes desktop/ native project
  bv desktop build [target]  Compiles Debug native binary (live console logging)
  bv desktop build [target] --release Compiles Release native binary (pure GUI - NO console)
  bv desktop run [target]    Launches desktop app in Debug mode (with console)
  bv desktop run [target] --release Launches desktop app in Release mode (clean GUI)

  # === Testing & Docs ===
  bv test                    Compiles and runs all unit tests (.test.pas) with Vitest
  bv test e2e                Runs headless browser End-to-End integration test suite
  bv doc [--serve]           Generates interactive component documentation & playground
  bv studio                  Launches BlaiseVue Studio developer dashboard (port 9000)

  # === Package & Theme Management ===
  bv repo <list|add|remove|default|sync|search> Manages package repositories & ecosystem sources
  bv lib install [<repo>:]<pkg[@ver]|url> [--global|-g] Installs package in project /lib or user cache
  bv lib remove <name> [--global|-g] Removes package from lib/ or global cache
  bv lib update [[<repo>:]name] [--global|-g] Updates package(s) to latest version
  bv lib outdated [--global|-g] Checks for available updates in installed packages
  bv lib list [--global|-g]  Lists installed libraries
  bv lib search [[<repo>:]term] Searches packages in registered repositories
  bv lib pack [dir]          Assembles & verifies release artifact (.zip with SHA-256)
  bv theme [list]            Displays active and available themes in @blaise-themes
  bv theme add <name>        Adds a theme to package.json for optimized bundling
  bv theme remove <name>     Removes a theme from package.json
  bv theme use <name>        Sets active default theme in package.json & index.html
  bv theme reset             Resets theme filters (bundles all themes in compatibility mode)
  bv tool list               Lists all installed tools (built-in, co-official & user third-party)
  bv tool search [term]      Searches tools in registered ecosystem repositories
  bv tool info <name>        Displays detailed information, versions and scripts of a tool
  bv tool install [<repo>:]<name[@ver]> Installs tool from ecosystem into user tools (~/.blaisevue/tools)
  bv tool install <url|zip>  Installs tool from local archive or download URL
  bv tool outdated           Checks for available updates across all installed tools
  bv tool run <name> [args]  Runs an installed developer tool CLI or script
  bv tool update [<name>]    Updates user tools to latest versions found in ecosystem
  bv tool remove <name>      Removes a tool from user tools directory (~/.blaisevue/tools)
  bv tool pack [dir]         Packages a tool into a distributable archive (.zip with SHA-256)
  bv tool init <name>        Creates a new tool project scaffold with tool.json and lifecycle scripts

  # === Project Configuration & Search Paths ===
  bv license [list|show|set] Manages project license (MIT, Apache, LGPL, GPL, BSD, etc.)
  bv meta [show|get|set|bump|sync] Manages project metadata and syncs SemVer across monorepo
  bv path [list]             Lists all active unit search paths (-Fu) in app.cfg
  bv path add <dir|pas2js:p> Adds a folder or official Pas2JS package to app.cfg
  bv path remove <target>    Removes a search path or Pas2JS package from app.cfg
  bv path available          Lists all built-in Pas2JS packages available to link
  bv reset [--bare] [--force] Resets project to a clean slate (protected against demo-app)

  # === Framework Diagnostics & Maintenance ===
  bv doctor                  Diagnoses environment tools (Git, Lazarus, FPC, Pas2JS, Node)
  bv self-update [--check] [--force] Syncs & recompiles BlaiseVue directly from GitHub via Git
  bv channel [use <name>]    Inspects or switches framework branch (main/develop)
  bv rollback                Restores previous CLI binary from backup (bv.bak)
  bv update [--dry-run]      Surgically syncs project infrastructure with latest framework features
```