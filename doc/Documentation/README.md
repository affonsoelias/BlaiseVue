# 🛡️ BlaiseVue 4.3 Documentation
**The Universal Reactive Framework for Object Pascal.**  
Build modern Web (SPA/SSG), Native Mobile (Android/iOS), Ultra-light Desktop, and High-Throughput Full-Stack microservices from a single Pascal codebase.

<p align="center">
  <img src="../images/blaisevue-showcase.png" alt="BlaiseVue Multiplatform Showcase (Web, Desktop, Mobile)" width="100%">
</p>

---

## 🌟 The BlaiseVue 4.3 Architecture

BlaiseVue delivers a complete, unified Object Pascal ecosystem for modern software engineering:

- 🛡️ **End-to-End Type-Safe Pascal RPC**: Shared service contracts (`ICustomerService`), automated client proxies (`bv mormot rpc`), dual HTTP/WebSocket transport, and compile-time API validation with Synopse mORMot 2.
- 📊 **LiveBindings & Reactive `TBVDataSet`**: In-memory cursor navigation (`First`, `Next`, `Prior`, `Last`), transactional buffering (`Append`, `Edit`, `Post`, `Delete`), two-way `b-field` directive, delta tracking (`FDelta`), and native `<bv-datagrid :dataset="myDS">` integration.
- 💎 **Idiomatic Zero-ASM Object Pascal DX**: Clean, modern Pascal view layer (`BVPascalDX.pas`) without inline `asm` blocks, featuring native dialogs, reactive form mutations, and typed API helpers.
- 📱 **Universal Hybrid Mobile (Capacitor & Android .apk)**: Scaffolding and compilation of native Android applications (`bv mobile build android`) paired with the `@blaise-ui-mobile` Ionic component kit.
- 🖥️ **Ultra-Lightweight Native Desktop (WebUI & Lazarus IDE)**: Standalone native desktop applications (<10 MB, 40 MB RAM) running identically across Windows, Linux, and macOS without Electron bloat.
- ⚡ **WebAssembly Acceleration Engine (`BVWasm` / `$wasm`)**: Near-native binary execution for compute-intensive routines in the browser.
- 🎨 **Master Component Catalog (53+ Widgets)**: Native suites for general UI (`@blaise-ui`), Bootswatch themes (`@blaise-themes`), 2,000+ vector icons (`@blaise-icons`), reactive Chart.js (`@blaise-charts`), and developer cockpit (`@blaise-studio`).
- 🚀 **Full-Stack mORMot 2 Micro-Containers**: Production Dockerfile multi-stage builds (`bv mormot docker`) generating sub-20 MB Alpine containers with <15ms startup time.

---

## 📚 Complete Documentation Index

### 🏁 1. Getting Started & Core Fundamentals
1. [01. Architecture and Mission](01-introduction.md) — The philosophy and vision behind BlaiseVue.
2. [02. Installation & SDK Setup](02-installation.md) — System requirements, FPC setup, and pre-bundled Pas2JS compiler.
3. [03. BlaiseCLI Technical Manual (bv.exe)](03-cli.md) — Complete command-line interface reference for scaffolding, building, and running apps.
4. [04. Single File Component (.bv) Format](04-bv-format.md) — Structure of `<template>`, `<script>`, and `<style>` sections in `.bv` files.
5. [05. The Reactive Engine & Proxies](05-reactivity.md) — Deep reactivity model, dependency tracking, effects, and proxies.
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

### 📦 4. Official Component Packages & UI Kits
24. [24. BlaiseUI (Official Component Kit)](24-blaise-ui.md) — Overview of the native 25+ widget kit (buttons, modals, cards, tabs, drawers).
28. [28. Themes & Bootswatch Integration ($theme)](28-themes.md) — 9 Bootswatch themes, dark mode toggle, and dynamic stylesheet switching.
29. [29. Blaise Icons & Bootstrap Icons (bv-icon)](29-icons.md) — 2,000+ vector icons with size and color customization.
38. [38. Mobile UI Kit (blaise-ui-mobile)](38-mobile-ionic.md) — Ionic Web Components with strongly typed Object Pascal controllers.
39. [39. Reactive Chart.js Suite (blaise-charts)](39-blaise-charts.md) — High-performance canvas charts (Bar, Line, Pie, Radar, Bubble) with typed datasets.
41. [41. Package Components Catalog & Manual](41-package-components-catalog.md) — Comprehensive reference manual covering props, events, slots, and copy-pasteable snippets for all 53+ components.

### ⚙️ 5. Full-Stack mORMot 2 & Cloud Architecture
37. [37. Full-Stack Pascal with mORMot 2](37-mormot2-backend.md) — High-throughput REST API, ORM, WebSockets, JWT authentication, and Docker micro-containers.
43. [43. End-to-End Type-Safe Pascal RPC with mORMot 2](43-typesafe-rpc-mormot.md) — Shared Pascal service contracts, automated proxy scaffolding (`bv mormot rpc`), and compile-time API validation.

### 📱 6. Universal Multiplatform (Mobile & Desktop)
35. [35. Hybrid Mobile Platform & Capacitor (bv mobile)](35-mobile-capacitor.md) — Native Android APK builds, emulator management, and responsive 12-column mobile layout.
36. [36. Multiplatform Desktop & Lazarus IDE (bv desktop)](36-desktop-webui.md) — Ultra-lightweight native desktop apps (<10 MB) via WebUI with dual Debug and Release GUI modes.

### 🛠️ 7. Tooling, Optimization & Developer Experience
12. [12. Debugging & Error Handling](12-debugging.md) — Source maps, runtime error boundaries, and console inspection.
14. [14. CSS Transitions & Animations](14-css-transitions.md) — Declarative `<transition>` wrapper with enter/leave classes.
18. [18. External Libraries & Setup Scripts (/lib)](18-external-libraries.md) — Installing and managing community packages via `bv lib`.
19. [19. Unit Testing with Vitest](19-unit-testing.md) — Writing and executing automated tests in Pascal with JSDOM and Vitest.
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

### 📖 8. Technical References & Roadmaps
- [API Technical Reference](api-reference.md) — Complete technical specification of global helpers, classes, and directives.
- [Technical Roadmap (v2.0 - v4.4)](99-roadmap.md) — Detailed milestone history and upcoming feature specifications.

---

## 🛠️ CLI Quick Reference

```bash
# === Development & Build ===
bv dev                     # Starts dev server with instant HMR on http://localhost:8080 (alias: bv serve)
bv run dev                 # Builds project in development mode with cache-busting
bv run build               # Builds optimized production bundle in dist/
bv run ssg                 # Pre-renders static HTML for all routes (SSG)
bv run preview             # Local HTTP preview of production build (port 5000)

# === Scaffolding ===
bv create <app-name>       # Scaffolds a new BlaiseVue application
bv create <name> --lib     # Scaffolds a standalone library package with license and playground
bv new c <Name>            # Scaffolds a new component (.bv)
bv new v <Name>            # Scaffolds a new route view (.bv)
bv new t <Name>            # Scaffolds a new Pascal test file (.test.pas)

# === Full-Stack mORMot 2 ===
bv mormot init [--db <eng>] # Scaffolds backend (sqlite, postgres, mysql, firebird)
bv mormot crud <Model> [f:t...] # Scaffolds ORM model, REST endpoints, and DataGrid view
bv mormot rpc              # Scaffolds type-safe Pascal RPC client proxies from server interfaces
bv mormot run              # Starts native mORMot 2 server on port 8090
bv mormot docker           # Builds production multi-stage micro-container (<20 MB)

# === Mobile & Desktop ===
bv mobile init [name] [id] # Scaffolds Capacitor mobile project
bv mobile build android    # Compiles native Android Debug APK
bv desktop init [name]     # Scaffolds WebUI & Lazarus desktop project
bv desktop run             # Compiles and launches native desktop app

# === Testing & Docs ===
bv test                    # Compiles and runs all unit tests (.test.pas) with Vitest
bv test e2e                # Runs headless browser End-to-End integration test suite
bv doc [--serve]           # Generates interactive component documentation & playground
bv studio                  # Launches BlaiseVue Studio developer dashboard (port 9000)
```
