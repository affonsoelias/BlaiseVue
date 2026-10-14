# 🛡️ BlaiseVue: The Modern Pascal SPA Framework

**BlaiseVue** is a high-performance, enterprise-grade Single Page Application (SPA) framework for **Object Pascal**. It combines the type safety, architectural robustness, and raw compilation speed of Pascal with the elegance, ergonomics, and reactivity of **Vue.js**.

---

## 🌟 Version 2.0: The Enterprise Release

BlaiseVue 2.0 represents a monumental leap forward, establishing a complete enterprise frontend ecosystem:

- **⚡ Hot Module Replacement (HMR)**: Instant component recompilation and in-place DOM patching via WebSockets (`:8081`) while preserving active reactive state (`this['State']`).
- **🛣️ Advanced SPA Routing**: Clean URLs via **HTML5 History API**, recursive **Nested Routes** with `<router-view>`, dynamic code-splitting (`import()`), and **Navigation Guards** (`beforeEach`, `beforeEnter`, `afterEach`).
- **🧩 Scoped Slots**: Seamless two-way data passing from child components back to parent templates (`#name="slotProps"`, `b-slot`, `slot-scope`).
- **🚀 Teleport & Suspense**: Mount elements into remote DOM targets (`<teleport to="body">`) and orchestrate asynchronous loading dependencies (`<suspense>`).
- **🏎️ Static Hoisting & Compiler Pruning**: Compiler-level static analysis tags invariant nodes (`bvStatic = true`), bypassing diff comparisons for $O(1)$ reconciliation.
- **🕵️ Browser DevTools Extension**: Dedicated Manifest V3 extension for Chrome/Edge with Component Tree inspection, real-time reactive state editing, and timeline logging.
- **🎨 BlaiseUI Official Component Kit**: Production-ready, native UI widgets (`bv-btn`, `bv-card`, `bv-input`, `bv-modal`, `bv-toast`, `bv-datagrid`) with pure modern CSS variables.
- **🏗️ Native Resource Scaffolding**: CLI templates embedded at compile-time via `{$R templates.res}`, providing a portable, zero-dependency executable (`bv.exe`).
- **🧪 Automated Unit Testing (Vitest)**: TDD engine in Pascal with headless JSDOM verification via `bv test`.

---

## 🔮 The Next Frontier: Roadmap to BlaiseVue 2.5 & 3.0

Our architectural vision continues to expand. The next cycle focuses on enterprise tooling, form engineering, and high-performance computing:

1. **📋 Typed Form Engine (`b-validate`)**: Declarative validations with reactive `$errors` tracking.
2. **🎬 List Transitions (`<transition-group>`)**: Smooth collection animations powered by the FLIP algorithm.
3. **🌐 Native i18n (Blaise-i18n)**: Multi-locale support with `$t()` and dynamic language switching.
4. **📚 Automatic Documentation (`bv doc`)**: Component catalog and interactive playground generator.
5. **⚡ WebAssembly Acceleration**: Direct FPC Wasm compilation for compute-intensive routines.
6. **🚀 SSG & Static Pre-rendering**: Static HTML pre-rendering with client hydration for instant FCP and SEO.

> [!TIP]
> **Detailed Engineering Plan**: For a deep dive into the technical architecture of upcoming features, check out our [Technical Roadmap (v2.5 & v3.0)](doc/Documentation/99-roadmap-v3.md).

---

## 🛠️ CLI Quick Reference (`bv.exe`)

```bash
# Start development server with instant HMR and WebSocket
bv serve

# Run express development build with cache busting
bv run dev

# Run automated unit test suite with Vitest
bv test

# Scaffold a new unit test in tests/
bv new t MyComponent

# Build optimized production bundle
bv run build

# Clean build artifacts (dist/ and generated/)
bv clean
```

---

## 📂 Project Structure

- **`/bin`**: The BlaiseVue CLI (`bv.pas`). The native compiler and orchestrator.
- **`/core`**: Framework runtime internals (Reactivity Proxy, Compiler, Directives, Store, Router).
- **`/packages/blaise-ui`**: Official native component library and stylesheets.
- **`/devtools`**: Manifest V3 browser extension for Chrome and Edge.
- **`/doc`**:
  - `Documentation/`: Comprehensive technical manuals (24 chapters + API Reference).
  - `Course/`: Step-by-step guides, including an **Internals & Architecture** course for contributors.
- **`/demo-app`**: Showcase application featuring all 2.0 features, router views, and UI kits.

---

## 🏁 Quick Start

### 1. Compile the BlaiseVue CLI
Ensure you have **FPC (Free Pascal Compiler 3.2+)** installed:
```bash
cd bin
fpc bv.pas
# Move bv or bv.exe to root or add bin/ to your PATH
```

### 2. Set Up Pas2JS (Multi-platform)
Download the [Pas2JS 3.2.0](https://getpas2js.freepascal.org) archive for your OS (Windows, Linux, or macOS). Extract it into a `pas2js/` folder at the project root following this naming convention:
- `/pas2js/pas2js-win64-x86_64-3.2.0/`
- `/pas2js/pas2js-linux-x86_64-3.2.0/`
- `/pas2js/pas2js-darwin-x86_64-3.2.0/`

The CLI automatically detects your OS and uses the correct binary path!

### 3. Launch the Demo App
```bash
cd demo-app
..\bin\bv serve
# Open http://localhost:8080 in your browser
```

---

## ⚖️ Licensing

BlaiseVue is open-source and follows the **Lazarus / Free Pascal** licensing model:
- **The BlaiseCLI tool (`bin/`):** Licensed under the **GNU GPL v2**.
- **The BlaiseVue Core (`core/`):** Licensed under the **Modified GNU LGPL v2.1** with a **Static Linking Exception**.

This allows you to create **commercial and proprietary applications** without having to open-source your own code, while maintaining the open-source nature of the framework itself. See the [LICENSE](LICENSE) file for more details.

---

🛡️ **"BlaiseVue: Bringing Pascal to the modern Web, and the Web to Pascal."** ✨🏆🚀
