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

> [!NOTE]
> ### 🚀 Project Status: Active Development & Upcoming Official v1.0.0 Release
>
> BlaiseVue is currently in active pre-release development. The platform is **fully functional, battle-tested, and ready for developers to clone, test, build prototypes, explore reactive Pascal, and evaluate full-stack architectures**.
>
> Current version tags or numbers appearing in the CLI and repository are **internal development milestones** used to track architectural iterations. An official, production-ready **v1.0.0 Release** is being finalized and will be officially launched very soon.
>
> We warmly invite developers and the Pascal community to clone the repository, build applications, share feedback, and join us in shaping the future of Object Pascal on the modern Web!

---

## 💡 Why BlaiseVue?

The Pascal ecosystem (Delphi and Lazarus) powers **tens of billions of dollars** in enterprise software globally. It underpins critical banking infrastructure, industrial manufacturing ERPs, hospital automation systems, retail point-of-sale (POS) terminals, and mission-critical electronic invoicing across Brazil and worldwide.

For more than 15 years, these organizations have faced the exact same dramatic dilemma:

> *"We need to modernize our ERPs and enterprise systems for the Web, Cloud, and Mobile, but we cannot afford to throw away 20 years of battle-tested Pascal business logic, rewrite everything from scratch, and re-hire an entire team of React/TypeScript or Flutter engineers."*

**BlaiseVue was engineered specifically to solve this dilemma.**

It provides a modern, reactive component model (inspired by Vue.js) written **100% in Object Pascal**. You preserve your business logic, database datasets, and team expertise while compiling directly to ultra-fast, single-page web applications (SPA/SSG), native Android/iOS mobile apps via Capacitor, and lightweight desktop binaries.

If this dilemma sounds familiar to you, **then you should consider BlaiseVue.**

---

## 🧩 Architectural Freedom: Frontend-Only or Full-Stack

BlaiseVue is decoupled by design, giving teams complete architectural freedom across isolated backend directories:

- **Frontend-Only Mode (Zero Backend)**: Build pure reactive Web SPAs, Jamstack sites, or native mobile apps that consume existing corporate REST / GraphQL APIs (Node.js, Go, Python, C#, Java, PHP, or Delphi). Remove any backend cleanly at any time (`bv mormot remove -y`, `bv zephyr remove -y`, or `bv horse remove -y`).
- **Default Enterprise Full-Stack: Synopse mORMot 2 (`server-mormot/`, Port `8090`)**: High-throughput (100k+ req/sec) native Pascal SOA backend with shared interface contracts (`common/contracts.pas`), zero serialization drift, and sub-millisecond response times *(legacy `server/` projects remain supported automatically)*.
- **Native Aether Full-Stack (Experimental): Zephyr (`server-zephyr/`, Port `8091`)**: Built-in Aether HTTP/1.1 + WebSocket server with integrated static SPA hosting, OWASP security headers, and zero-dependency C99/Pascal binaries (`bv zephyr init`, `bv zephyr run`, `bv zephyr deploy`).
- **Alternative Microframework: Horse (`server-horse/`, Port `9000`)**: Express.js-style lightweight REST microservices via the external **`blaise-horse`** ecosystem tool, completely isolated in `server-horse/` (`bv horse init`, `bv horse run`, `bv horse remove`).

---

## 🔷 Optional Aether Integration & Zephyr Backend (Experimental)

BlaiseVue works alongside the **[Aether](https://github.com/affonsoelias/aether)** language (`--aether`, `<script lang="aether">`, `.aeth` services in `src/services/`, and native `.test.aeth` unit tests) for building full-stack applications — while **the BlaiseVue framework itself (CLI, core reactive runtime, compiler, and official UI/data packages) remains 100% written in Free Pascal / Object Pascal**.

- **Completely Optional**: Using Aether is entirely optional. Standard Object Pascal remains the primary default experience (`bv create my-app`), and both languages interoperate seamlessly inside the same project (`bv create my-app --aether` or `bv g <c|v|s|t> <Name> --aether`).
- **Why Add Aether to BlaiseVue?**: Aether preserves Pascal's readable syntax and mental model while adding modern systems-level guarantees — compile-time ownership/borrow checking, design-by-contract (`require`/`ensure`), `[derive(JSON, Equals)]`, and direct compilation to C99, Object Pascal, and WebAssembly.
- **Why Build Zephyr exclusively in Aether?**: Writing the dedicated **Zephyr** backend (`vendor/zephyr`, scaffolded in `server-zephyr/`) in Aether gives the framework maximum architectural freedom and end-to-end control over its HTTP/1.1 + WebSocket + SPA serving stack (tight CLI integration, built-in static SPA + history fallback, OWASP security headers, and memory/contract safety without third-party C/C++ bindings).
- **mORMot 2 Remains First-Class**: Adopting Zephyr does **not** replace **Synopse mORMot 2**. `server-mormot/` continues as the battle-tested enterprise Object Pascal backend, and both `server-mormot/` and `server-zephyr/` can coexist cleanly in the same project.

> [!WARNING]
> **Active Testing Notice:** Both the **Aether language** and the **Zephyr native backend** are currently **experimental and under active testing**. Expect rapid iterations while core Object Pascal (`pas2js` + `mORMot 2`) remains the stable enterprise baseline.
>
> See the full technical guide in **[59. Aether Language Integration & Zephyr Backend](doc/Documentation/59-aether-integration-and-zephyr-backend.md)**.

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
- 📚 **[Documentation Index (doc/Documentation/README.md)](doc/Documentation/README.md)**: 59 comprehensive technical manuals covering CLI, reactivity, components, mobile, desktop, ecosystem, mORMot 2, and Aether/Zephyr.
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
│   ├── mormot2/               # High-throughput Synopse mORMot 2.4 framework
│   └── zephyr/                # Native Aether HTTP/1.1 + WebSocket server (experimental)
├── tests/                     # SDK-level framework test suites (bv test --sdk)
├── doc/                       # Architecture, manuals & educational courses
│   ├── Architecture/          # Core compiler pipeline, reactivity engine & internals
│   ├── Documentation/         # 59 comprehensive technical manuals + API Reference
│   ├── Course/                # 13-module practical course from beginner to ninja
│   └── brand/                 # Official vector logos, icons & banner assets
└── demo-app/                  # Enterprise showcase application (v4.4.0 Full-Stack)
    ├── src/                   # Reactive frontend SPA (views, components, services)
    ├── server-mormot/         # High-throughput native mORMot 2 backend server
    ├── mobile/                # Native Capacitor Android (APK/AAB) & iOS projects
    ├── desktop/               # Native WebUI desktop app with Lazarus project
    └── tests/                 # 3-tier application test suites (components, views, services)
```

---

## 🏁 Quick Start

### 📋 Prerequisites
- **Git (v2.30+)**: Required for cloning the framework, automatic selective updates (`bv self-update`), and channel management (`bv channel`).
- **Lazarus IDE (or Free Pascal Compiler 3.2+)**: Recommended IDE and compiler for building the native CLI (`bv` / `bv.exe`), desktop applications (`desktop/`), and mORMot 2 servers (`server-mormot/`).
- **Aether Compiler (`aetherc`, Optional & Recommended — Experimental)**: Optional compiler needed only if you create `--aether` apps, author `<script lang="aether">` / `.aeth` modules, run `.test.aeth` suites, or build the **Zephyr** backend (`bv zephyr`). Standard Object Pascal projects work without it.
- **Python (v3.8+ Recommended)**: Recommended for executing cross-platform lifecycle scripts (`status.py`, `install.py`, `update.py`, `remove.py`, `pack.py`) for the dynamic developer tooling ecosystem (`bv tool`) and custom user packages (`~/.blaisevue/tools/`).
- **Node.js (v18+ LTS) & npm**: Powers the development server with HMR (`bv dev`), automated testing (`bv test`), and mobile synchronization (`bv capacitor` / `bv mobile`).
- **Android Studio (Recommended for Mobile)**: Required for compiling native Android `.apk` / `.aab` packages (`bv capacitor build`), managing emulators, and running `bv capacitor open android`. Bundles the Android SDK, Platform-Tools (`adb`), and Java JDK.

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
Scaffold a complete, modern BlaiseVue project and enter its directory:
```bash
bv create my-app
# Or initialize directly with Aether frontend / a specific backend:
bv create my-app --aether
bv create my-app --backend=mormot
bv create my-app --backend=zephyr

cd my-app
```
`bv create` automatically scaffolds the reactive frontend, domain services (`src/services/`), Lazarus IDE project files (`.lpi`/`.lpr`), and clean 3-tier test suites (`tests/`). Add `--backend=mormot`, `--backend=zephyr`, or `--backend=<tool>` (or run `bv mormot init` / `bv zephyr init` later) to attach your preferred backend in its own isolated directory.

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
bv mormot init
bv mormot run

# Native Zephyr (Aether) backend server (Port 8091, experimental):
bv zephyr init
bv zephyr run

# Native Mobile on Android Emulator (Capacitor):
bv capacitor run android --emulator  # or: bv mobile run android --emulator

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
