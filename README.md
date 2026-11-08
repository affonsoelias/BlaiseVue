<p align="center">
  <a href="https://github.com/affonsoelias/BlaiseVue">
    <img src="doc/brand/banner.png" alt="BlaiseVue: The Object Pascal Reactive Framework" width="100%">
  </a>
</p>

# 🛡️ BlaiseVue: The Universal Reactive Framework for Object Pascal

> **The Universal Reactive Framework for Object Pascal.**  
> Build modern Web (SPA/SSG), Native Mobile (Android/iOS), and Ultra-light Desktop apps from a single Pascal codebase.

<p align="center">
  <img src="doc/images/blaisevue-showcase.png" alt="BlaiseVue Multiplatform Showcase (Web, Desktop, Mobile)" width="100%">
</p>

**BlaiseVue** is a high-performance, enterprise-grade universal reactive framework for **Object Pascal**. It combines the type safety, architectural robustness, and raw compilation speed of Pascal with the elegance, ergonomics, and reactivity of **Vue.js**, enabling seamless multiplatform deployment across Web, Mobile, and Desktop from a single codebase.

---

## 💡 Why BlaiseVue?

The Pascal ecosystem (Delphi and Lazarus) powers **tens of billions of dollars** in enterprise software globally. It underpins critical banking infrastructure, industrial manufacturing ERPs, hospital automation systems, retail point-of-sale (POS) terminals, and mission-critical electronic invoicing across Brazil and worldwide.

For more than 15 years, these organizations have faced the exact same dramatic dilemma:

> *"We need to modernize our ERPs and enterprise systems for the Web, Cloud, and Mobile, but we cannot afford to throw away 20 years of battle-tested Pascal business logic, rewrite everything from scratch, and re-hire an entire team of React/TypeScript or Flutter engineers."*

**BlaiseVue was engineered specifically to solve this dilemma.**

It provides a modern, reactive component model (inspired by Vue.js) written **100% in Object Pascal**. You preserve your business logic, database datasets, and team expertise while compiling directly to ultra-fast, single-page web applications (SPA/SSG), native Android/iOS mobile apps via Capacitor, and lightweight desktop binaries.

If this dilemma sounds familiar to you, **then you should consider BlaiseVue.**

---

## 📦 Official Packages Ecosystem

BlaiseVue features a modular package architecture located in `/packages`:

| Package | Description | Key Components / Features |
| :--- | :--- | :--- |
| **`blaise-ui`** | Native Bootstrap-inspired component kit | `<bv-btn>`, `<bv-card>`, `<bv-modal>`, `<bv-datagrid>`, `<bv-toast>`, `<bv-navbar>`, `<bv-tabs>`, `<bv-input>` |
| **`blaise-themes`** | 9 Bootswatch themes + reactive theme management | Flatly, Darkly, Cosmo, Cyborg, Lux, Pulse, Solar, Vapor, Zephyr, `<bv-theme-toggle>`, `<bv-theme-select>`, `$theme` |
| **`blaise-icons`** | Bootstrap Icons library (fonts + CSS) | `<bv-icon name="heart-fill" size="24px" color="red">`, 2,000+ vector icons |
| **`blaise-charts`** | Reactive Chart.js data visualization suite | `<bv-chart>`, `<bv-bar-chart>`, `<bv-line-chart>`, `<bv-pie-chart>`, typed Pascal records (`TBVChartData`, `TBVChartOptions`, `TBVChartPalette`) |
| **`blaise-reports`** | Declarative PDF reports and printing engine | PDF report templates, multi-page data tables, headers/footers, print dialogs |
| **`blaise-studio`** | Developer cockpit & live WebSocket hub | Visual AST inspector, real-time WebSocket monitor, 1-click test/build runner, `TBVStudioClient` |
| **`blaise-ui-mobile`** | Mobile-first Ionic components & Pascal wrappers | `<bv-ion-app>`, `<bv-ion-toolbar>`, iOS/Android adaptive themes, `TIonicToast`, `TIonicAlert` |

---

---

## 📖 Roadmap & Technical Documentation

For the complete architectural evolution specifications, delivered enterprise pillars, and future roadmap milestones (v2.0 to v5.0), see:

- 🎓 **[Complete Course: Zero to Ninja (doc/Course/README.md)](doc/Course/README.md)**: 13 beginner-friendly practical modules with step-by-step guides, runnable `.bv` examples, and real-world analogies.
- 🗺️ **[Technical Roadmap (doc/Documentation/99-roadmap.md)](doc/Documentation/99-roadmap.md)**: Full architecture breakdown, testing matrices, and future horizons.
- 📚 **[Documentation Index (doc/Documentation/README.md)](doc/Documentation/README.md)**: 54 comprehensive technical manuals covering CLI, reactivity, components, mobile, desktop, ecosystem, and mORMot 2.
- 🏛️ **[Core Architecture & Internals (doc/Architecture/README.md)](doc/Architecture/README.md)**: Deep dive into the compiler pipeline, AST evaluation, and reactive proxy engine.

---

## 📂 Project Structure

```text
BlaiseVue/
├── bin/                       # BlaiseVue CLI compiler & development toolchain
│   ├── bv.pas & bv.exe        # Zero-dependency native CLI compiler & orchestrator
│   ├── dev-server.js          # Fast local development HTTP server with live HMR
│   ├── studio-server.js       # BlaiseVue Studio telemetry hub & API bridge
│   ├── studio/                # Embedded BlaiseVue Studio web cockpit UI
│   └── templates.res          # Embedded pre-compiled project & component templates
├── core/                      # Core runtime engine (Transpiled via Pas2JS)
│   ├── BlaiseVue.pas          # Core SPA instance orchestrator & hydration
│   ├── BVCompiler.pas         # Template engine, directives & AST parser
│   ├── BVReactivity.pas       # Reactive proxy & dependency tracking ($ref, $computed)
│   ├── BVRouting.pas          # SPA Router, navigation guards & HTML5 History API
│   ├── BVValidation.pas       # Reactive form validation engine (b-validate)
│   ├── BVI18n.pas             # Internationalization & localization engine ($t)
│   ├── BVTheme.pas            # Theme switcher & persistence engine ($theme)
│   ├── BVWasm.pas             # WebAssembly acceleration engine ($wasm)
│   ├── BVStore.pas            # BlaiseX 2.0 modular store (, )
│   ├── BVFSM.pas              # Deterministic Finite State Machines (TBVStateMachine)
│   ├── BVMiddleware.pas       # Action/mutation pipeline (Logger, AuthGuard, Telemetry)
│   ├── BVStoreHistory.pas     # Time-travel debugging, snapshots & DevTools bridge
│   ├── BVAuth.pas             # JWT authentication, session storage & route protection
│   ├── BVClient.pas           # Reactive REST ($api) & WebSocket ($ws) client helpers
│   ├── BVDataSet.pas          # LiveBindings, reactive TDataSet & offline delta sync
│   ├── BVRpc.pas              # Type-safe Pascal RPC client proxies for mORMot 2 SOA
│   ├── BVMobile.pas           # Capacitor mobile runtime bridge & device events
│   ├── BVDesktop.pas          # WebUI native desktop window & IPC bridge
│   ├── BVDevTools.pas         # Browser DevTools extension telemetry bridge
│   └── Blaise*.pas            # Official Pascal bindings (UI, Charts, Reports, Ionic)
├── templates/                 # Scaffolding templates for new projects
│   ├── fullstack-mormot/      # High-performance native mORMot 2 server template
│   ├── *.bv                   # Component, View and App template blueprints
│   └── *.pas                  # Domain services, test suites and config templates
├── packages/                  # Modular package ecosystem & developer tooling
│   ├── core/                  # Official core framework packages
│   │   ├── blaise-ui/         # 25+ native reactive UI components & styles
│   │   ├── blaise-themes/     # 9 Bootswatch themes & build-time pruning optimizer
│   │   ├── blaise-icons/      # Bootstrap Icons fonts & stylesheet bundle
│   │   ├── blaise-charts/     # Reactive Chart.js visualization & Pascal wrappers
│   │   ├── blaise-reports/    # Declarative PDF reports generation engine
│   │   ├── blaise-studio/     # Developer cockpit telemetry & AST inspector
│   │   └── blaise-ui-mobile/  # Mobile-first Ionic components & Pascal wrappers
│   └── tools/                 # Development extensions & IDE tooling
│       ├── blaise-devtools/   # Browser DevTools extension (Chrome, Firefox, Edge)
│       ├── blaise-vscode/     # Official VS Code extension (.vsix packaging & snippets)
│       └── blaise-lazarus/    # Official Lazarus IDE package (.lpk design-time integration)
├── vendor/                    # Pre-bundled compilers & native frameworks
│   ├── pas2js/                # Official multi-platform Pas2JS transpiler & RTL binaries
│   └── mormot2/               # High-throughput Synopse mORMot 2.4 framework
├── doc/                       # Architecture, manuals & educational courses
│   ├── Architecture/          # Core compiler pipeline, reactivity engine & internals
│   ├── Documentation/         # 54 comprehensive technical manuals + API Reference
│   ├── Course/                # 13-module practical course from beginner to ninja
│   └── brand/                 # Official vector logos, icons & banner assets
└── demo-app/                  # Enterprise showcase application (v4.4.0 Full-Stack)
    ├── src/                   # Reactive frontend SPA (views, components, services)
    ├── server/                # High-throughput native mORMot 2 backend server
    ├── mobile/                # Native Capacitor Android (APK/AAB) & iOS projects
    ├── desktop/               # Native WebUI desktop app with Lazarus project
    └── tests/                 # 4-tier automated test suites with Vitest
```

---

## 🏁 Quick Start

### 📋 Prerequisites
- **Git (v2.30+)**: Required for cloning the framework, automatic selective updates (`bv self-update`), and channel management (`bv channel`).
- **Lazarus IDE (or Free Pascal Compiler 3.2+)**: Recommended IDE and compiler for building the native CLI (`bv` / `bv.exe`), desktop applications (`desktop/`), and mORMot 2 servers (`server/`).
- **Python (v3.8+ Recommended)**: Recommended for executing cross-platform lifecycle scripts (`status.py`, `install.py`, `remove.py`, `pack.py`) for the dynamic developer tooling ecosystem (`bv extension`) and custom user packages (`~/.blaisevue/tools/`).
- **Node.js (v18+ LTS) & npm**: Powers the development server with HMR (`bv dev`), automated testing (`bv test`), and mobile synchronization (`bv mobile`).
- **Android Studio (Recommended for Mobile)**: Required for compiling native Android `.apk` / `.aab` packages (`bv mobile build`), managing emulators, and running `bv mobile open android`. Bundles the Android SDK, Platform-Tools (`adb`), and Java JDK.

> [!NOTE]
> **Pas2JS is pre-bundled**: You do **not** need to install `pas2js`. Official multi-platform binaries for Windows, Linux, and macOS are already included in `vendor/pas2js/`.

### 1. Clone the Repository & Configure PATH
Clone the BlaiseVue SDK and configure the native CLI in your system `PATH`:
```bash
# Clone official stable release channel (main):
git clone https://github.com/affonsoelias/BlaiseVue.git
cd BlaiseVue

# Or clone the active development channel (develop):
git clone -b develop https://github.com/affonsoelias/BlaiseVue.git
cd BlaiseVue
```

#### Set Executable Permissions & PATH (Linux / macOS):
```bash
chmod +x bin/bv vendor/pas2js/pas2js-*/bin/{pas2js,compileserver,makestub,webidl2pas} 2>/dev/null || true

# Add to ~/.zshrc (if using Zsh, e.g. Manjaro/macOS) or ~/.bashrc (if using Bash):
export PATH="$HOME/BlaiseVue/bin:$PATH"

# Reload your active shell:
source ~/.zshrc   # or: source ~/.bashrc
```

On Windows, add the full path to `BlaiseVue\bin` to your System or User Environment `Path` (or invoke directly via `.\bin\bv.exe`).

### 2. Create Your First Project
Scaffold a complete, modern BlaiseVue full-stack project and enter its directory:
```bash
bv create my-app
cd my-app
```
`bv create` automatically scaffolds the reactive frontend, domain services, native mORMot 2 backend, mobile Capacitor runtime, Lazarus IDE project files (`.lpi`/`.lpr`), and 4-tier Vitest test suites with zero manual boilerplate.

### 3. Verify Environment Health
Run the built-in diagnostic doctor **inside** your newly created project directory:
```bash
bv doctor
```
Running `bv doctor` inside your project verifies all system compilers (Git, FPC, Lazarus, Pas2JS, Node) along with your project's local dependencies and mobile configuration with zero false positives.

### 4. Interactive Cockpit Shell (Optional)
BlaiseVue provides an interactive command shell with real-time `[TAB]` autocompletion, session history (`↑`/`↓`), and intelligent subcommand guidance:
```bash
bv enter
# Opens the interactive Cockpit: [bv: my-app] >
```
*(You can exit the shell anytime by typing `exit` or continue executing commands directly via `bv <command>`)*.

### 5. Launch the Development Server
Start the local development server with instant Hot Module Replacement (HMR):
```bash
bv dev
# Open http://localhost:8080 in your browser
```
Any modifications saved in `src/` or `app.bv` are recompiled and hot-swapped in the browser in milliseconds!

### 6. Explore Full-Stack, Mobile & Desktop
Your new project is multi-platform by design:
```bash
# Native mORMot 2 backend server (Port 8090):
bv mormot run

# Native Mobile on Android Emulator (Capacitor):
bv mobile run android --emulator

# Native Desktop Application (WebUI):
bv desktop run
```

> [!TIP]
> **Manual CLI Compilation (Optional)**: Pre-compiled binaries are provided in `bin/`. To rebuild manually with **Free Pascal Compiler 3.2+**, run `fpc -O2 bin/bv.pas -FEbin`. Pas2JS is pre-bundled in `vendor/pas2js/` with zero manual configuration required!

---

## ⚖️ Licensing

BlaiseVue is open-source and follows the standard **Lazarus / Free Pascal** licensing model:
- **The BlaiseCLI tool (`bin/`):** Licensed under the **GNU GPL v2**.
- **The BlaiseVue Core (`core/`):** Licensed under the **Modified GNU LGPL v2.1** with a **Static Linking Exception**.

This allows developers to build **commercial and proprietary applications** without having to open-source their proprietary code, while ensuring the framework runtime remains open and accessible to all. See the [LICENSE](LICENSE) file for details.

### 🖋️ Brand Identity & Trademarks
The BlaiseVue name, architecture, and the official **Shadow Hand & White Quill** logo are authored by **Elias Affonso**. For official brand assets, guidelines, and vector files, visit the [Brand Assets Directory](doc/brand/README.md).

---

🛡️ **"BlaiseVue: The Universal Reactive Framework for Object Pascal."** ✨🏆🚀
