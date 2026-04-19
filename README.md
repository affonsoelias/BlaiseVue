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

## 🌟 Version 1.0 PRO: Officially Released!

We are proud to announce the official launch of **BlaiseVue 1.0 PRO**. This version establishes a stable, production-ready foundation for professional Pascal-based web development, featuring complete routing, reactivity, and a fully documented core.

---

## 🗺️ Roadmap to BlaiseVue 2.0

While v1.0 is stable, our vision for the future is even more ambitious. The following features are planned for the next major evolution of the framework:

1.  **⚡ HMR (Hot Module Replacement)**: Selective component injection without page reloads or state loss.
2.  **🛣️ History Mode & Nested Routes**: Support for HTML5 clean URLs and sub-layouts (`children` routes).
3.  **🧩 Scoped Slots**: Dynamic data passing from children back to parent templates for advanced UI logic.
4.  **🚀 Teleport & Suspense**: Rendering modals outside the app root and standardizing async loading states.
5.  **🏗️ Static Template Booting**: Compiler-level optimizations to ignore non-reactive DOM nodes.
6.  **📦 Code Splitting**: Automatic lazy loading of routes to minimize initial bundle size.
7.  **🕵️ DevTools Browser Extension**: A dedicated Chrome/Edge extension for real-time component and state inspection.
8.  **🛡️ BlaiseUI Library**: An official ecosystem of pre-styled, high-performance UI components.
9.  **🏗️ Native Resource Scaffolding**: Move hardcoded templates to `.res` files for a cleaner CLI source code.

> [!TIP]
> **Detailed Engineering Plan**: For a deep dive into the technical architecture of these features, check out our [Technical Roadmap v2.0](doc/Documentation/99-roadmap-v2.md).

---

## 🛠️ Project Structure

- **`/bin`**: The BlaiseVue CLI (`bv.pas`). The brain of the project.
- **`/core`**: Framework internals (Reactivity, Compiler, Directives, Store).
- **`/doc`**:
  - `Documentation/`: Comprehensive technical manuals (20+ chapters).
  - `Course/`: Step-by-step guides, including an **Internals & Architecture** course for contributors.
- **`/demo-app`**: A full showcase application featuring all core features and UI libraries.

---

## 🏁 Quick Start

### 1. Compile the BlaiseVue CLI
Ensure you have **FPC (Free Pascal Compiler)** installed.
```bash
cd bin
fpc bv.pas
# Move bv or bv.exe to root
```

### 2. Set Up Pas2JS (Multi-platform)
Download the [Pas2JS 3.2.0](https://getpas2js.freepascal.org) archive for your OS (Windows, Linux, or macOS). Extract it into a `pas2js/` folder at the project root following this naming convention:
- `/pas2js/pas2js-win64-x86_64-3.2.0/`
- `/pas2js/pas2js-linux-x86_64-3.2.0/`
- `/pas2js/pas2js-darwin-x86_64-3.2.0/`

**The CLI now automatically detects your OS and uses the correct path!** 🛡️✨🚀

---

## 🏗️ Project Structure

If you want to contribute to the core or understand how the reactivity engine works, check out our **Architecture Course** at:
`doc/Course/Architecture-and-Internals/`

---

## ⚖️ Licensing

BlaiseVue is open-source and follows the **Lazarus / Free Pascal** licensing model:
- **The BlaiseCLI tool (`bin/`):** Licensed under the **GNU GPL v2**.
- **The BlaiseVue Core (`core/`):** Licensed under the **Modified GNU LGPL v2.1** with a **Static Linking Exception**.

This allows you to create **commercial and proprietary applications** without having to open-source your own code, while maintaining the open-source nature of the framework itself. See the [LICENSE](LICENSE) file for more details.

---

 🛡️ **"BlaiseVue: Bringing Pascal to the modern Web, and the Web to Pascal."** ✨🏆🚀
