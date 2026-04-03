# 🛡️ BlaiseVue: The Modern Pascal SPA Framework

**BlaiseVue** is a professional-grade Single Page Application (SPA) framework for **Object Pascal**, designed to bring the power of modern reactivity, routing, and state management to the web using Pascal's type safety and performance.

---

## 🚀 Key Features

- **⚡ Reactive Proxy Core**: Automatic dependency tracking and batch updates, similar to Vue.js 3.
- **📦 SFC (Single File Components)**: Unified `.bv` files separating `Template`, `Script`, and `Style`.
- **🛤️ SPA Routing**: Built-in hash-based router with hooks, dynamic parameters, and guards.
- **🧠 B-Store**: Global state management with a Proxy-based singleton pattern.
- **🔗 DI Engine**: Support for `Provide/Inject` to handle deep component communication.
- **🧪 Unit Testing**: Native Vitest integration for Pascal-based testing.
- **📦 Lib Manager**: Zero-config autoloading for external CSS, JS, and UI Kits.

---

## 🛠️ Project Structure

- **`/bin`**: The BlaiseVue CLI (`bv.pas`). The brain of the project.
- **`/core`**: Framework internals (Reactivity, Compiler, Directives, Store).
- **`/doc`**:
  - `Documentation/`: Comprehensive technical manuals.
  - `Course/`: Step-by-step guides, including an **Internals & Architecture** course for contributors.
- **`/demo-app`**: A full showcase application featuring all core features.

---

## 🏁 Quick Start

### 1. Compile the CLI
Ensure you have **FPC (Free Pascal Compiler)** installed.
```bash
cd bin
fpc bv.pas
```

### 2. Scaffold a Project
```bash
./bv create my-app
cd my-app
```

### 3. Run Development Server
```bash
./bv run dev
./bv serve
```

---

## 🧪 Architecture & Contributions

If you want to contribute to the core or understand how the reactivity engine works, check out our **Architecture Course** at:
`doc/Course/Architecture-and-Internals/`

---
🛡️ **"BlaiseVue: Bringing Pascal to the modern Web, and the Web to Pascal."** ✨🏆🚀
