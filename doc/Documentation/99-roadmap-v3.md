# 🛡️ Technical Roadmap: BlaiseVue 2.5 & 3.0 (The Next Frontier)

This document defines the technical strategy, architectural goals, and specifications for the next major evolution of the framework: **BlaiseVue 2.5 and 3.0**.

> [!NOTE]
> **Current Status**: 🚀 **BlaiseVue 3.0 Delivered (✅ Completed)**. All architectural goals for Version 3.0 (`bv doc` generator, WebAssembly acceleration via `BVWasm`, SSG pre-rendering, Reactive Hydration, and Headless E2E testing) are fully implemented and verified with 130 unit tests across 12 test suites.

---

## 🏆 Delivery Record: BlaiseVue 2.0, 2.5, 2.6 & 3.0 (✅ 100% Completed)

BlaiseVue has reached enterprise maturity with all goals for versions 2.0, 2.5, 2.6, and 3.0 fully implemented and covered by 130 automated unit tests across 12 test suites:

### BlaiseVue 3.0 Enterprise Next (✅ Completed)
| 3.0 Goal | Status | Implementation Files |
|---|:---:|---|
| **1. Automatic Documentation Generator (`bv doc`)** | ✅ Completed | [`bin/bv.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/bin/bv.pas) (`CmdDoc`), `dist/docs/index.html` |
| **2. WebAssembly Acceleration (`BVWasm`)** | ✅ Completed | [`core/BVWasm.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/core/BVWasm.pas), `$wasm` helper, `bv wasm info/benchmark` |
| **3. SSG & Static Pre-rendering (`bv run ssg`)** | ✅ Completed | [`bin/bv.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/bin/bv.pas) (`CmdSSG`), route pre-rendering |
| **4. Zero-Flicker Reactive Hydration** | ✅ Completed | [`core/BlaiseVue.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/core/BlaiseVue.pas), [`core/BVCompiler.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/core/BVCompiler.pas) |
| **5. Headless E2E Testing (`bv test e2e`)** | ✅ Completed | [`bin/bv.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/bin/bv.pas) (`CmdTestE2E`), [`demo-app/tests/wasm_ssg.test.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/demo-app/tests/wasm_ssg.test.pas) |
| **6. Automated Test Suite (130/130 Passing)** | ✅ Completed | 130 tests passing across 12 test suites |

### BlaiseVue 2.0 Enterprise Release
| 2.0 Goal | Status | Implementation Files |
|---|:---:|---|
| **1. Hot Module Replacement (HMR)** | ✅ Completed | [`bin/dev-server.js`](file:///c:/Users/Pichau/Documents/BlaiseVue/bin/dev-server.js), [`core/BVCompiler.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/core/BVCompiler.pas) |
| **2. Advanced Routing (History & Nested)** | ✅ Completed | [`core/BVRouting.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/core/BVRouting.pas) |
| **3. Scoped Slots** | ✅ Completed | [`core/BVCompiler.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/core/BVCompiler.pas) |
| **4. Teleport & Suspense** | ✅ Completed | [`core/BVCompiler.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/core/BVCompiler.pas) |
| **5. Static Hoisting & Compiler Pruning** | ✅ Completed | [`core/BVCompiler.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/core/BVCompiler.pas) |
| **6. Browser DevTools Extension (Manifest V3)** | ✅ Completed | [`devtools/`](file:///c:/Users/Pichau/Documents/BlaiseVue/devtools/), [`core/BVCompiler.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/core/BVCompiler.pas) |
| **7. BlaiseUI Component Kit** | ✅ Completed | [`packages/blaise-ui/`](file:///c:/Users/Pichau/Documents/BlaiseVue/packages/blaise-ui/), [`demo-app/lib/blaise-ui/`](file:///c:/Users/Pichau/Documents/BlaiseVue/demo-app/lib/blaise-ui/) |
| **8. CLI Native Resource Scaffolding** | ✅ Completed | [`bin/templates/`](file:///c:/Users/Pichau/Documents/BlaiseVue/bin/templates/), `{$R templates.res}` in [`bin/bv.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/bin/bv.pas) |
| **9. Automated Test Suite** | ✅ Completed | `demo-app/tests/`, Vitest runner (73/73 tests passing across 10 suites) |

### BlaiseVue 2.5 Release (✅ Completed)
| 2.5 Goal | Status | Implementation Files |
|---|:---:|---|
| **1. Form Validation Engine (`b-validate`)** | ✅ Completed | [`core/BVValidation.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/core/BVValidation.pas), [`core/BVCompiler.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/core/BVCompiler.pas), [`demo-app/tests/validation.test.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/demo-app/tests/validation.test.pas) |
| **2. List Transitions (`<transition-group>`)** | ✅ Completed | [`core/BVCompiler.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/core/BVCompiler.pas), [`core/BlaiseVue.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/core/BlaiseVue.pas), [`demo-app/tests/transition_group.test.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/demo-app/tests/transition_group.test.pas) |
| **3. Integrated Internationalization (`Blaise-i18n`)** | ✅ Completed | [`core/BVI18n.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/core/BVI18n.pas), [`core/BVReactivity.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/core/BVReactivity.pas), [`core/BVCompiler.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/core/BVCompiler.pas), [`demo-app/tests/i18n.test.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/demo-app/tests/i18n.test.pas) |

### BlaiseVue 2.6 Release (✅ Completed)
| 2.6 Goal | Status | Implementation Files |
|---|:---:|---|
| **1. Bootswatch Themes Integration (`blaise-themes`)** | ✅ Completed | [`packages/blaise-themes/`](file:///c:/Users/Pichau/Documents/BlaiseVue/packages/blaise-themes/), [`core/BVTheme.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/core/BVTheme.pas), `$theme.setTheme`, `$theme.toggle`, `localStorage` persistence |
| **2. Bootstrap Icons Suite (`blaise-icons`)** | ✅ Completed | [`packages/blaise-icons/`](file:///c:/Users/Pichau/Documents/BlaiseVue/packages/blaise-icons/), 1800+ icons, updated [`BVIcon.bv`](file:///c:/Users/Pichau/Documents/BlaiseVue/packages/blaise-ui/BVIcon.bv) |
| **3. Package Registry & Theme CLI** | ✅ Completed | [`bin/bv.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/bin/bv.pas), `bv lib install themes`, `bv lib install icons`, `bv theme list`, `bv theme use <name>` |
| **4. Automated Test Suite (99/99 Passing)** | ✅ Completed | [`demo-app/tests/theme.test.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/demo-app/tests/theme.test.pas), 99/99 tests passing across 11 suites |

---

## 🔮 The Next Horizon: Architectural Goals (v3.0)

Below are the new strategic pillars designed to consolidate BlaiseVue as the most robust and performant frontend ecosystem in Object Pascal:

```
                                  BLAISEVUE 3.0
                                        │
        ┌───────────────┬───────────────┼───────────────┬───────────────┐
        ▼               ▼               ▼               ▼               ▼
   [b-validate]    [transition-    [Blaise-i18n]    [bv doc]        [WebAssembly]
  (Form Engine)      group]        (Multilingual) (Docs/Storybook)   (FPC Wasm)
```

---

### 📋 1. Native Form Validation Engine (`b-validate` / Typed Form Engine)
**Goal**: Reactive form validation without manual boilerplate and with Pascal's type safety.
- **Declarative Syntax**: `b-validate` directive or `validations:` block in `.bv` components:
  ```html
  <bv-input
    b-model="email"
    b-validate="required|email"
    label="E-mail"
    :error="$errors.email"
  ></bv-input>
  ```
- **Typed Rules in Pascal**: Creation of custom validators in Object Pascal:
  ```pascal
  function ValidateTaxId(Value: string): boolean;
  ```
- **State Management**: Automatic injection of the `$v` or `$errors` object containing `$dirty`, `$invalid`, `$touch()`, and localized error messages.

---

### 🎬 2. Reactive List Transitions (`<transition-group>`)
**Goal**: Smooth animations for entry, removal, and reordering of elements in collections.
- **FLIP Algorithm (*First, Last, Invert, Play*)**: The compiler computes the initial and final position of each DOM node upon mutation via `b-for`, generating smooth CSS transitions without heavy layout recalculations.
- **Automatic Classes**: Injection of CSS classes `-move`, `-enter-active`, and `-leave-to` supporting `transform: translate(...)` coordinates.

---

### 🌐 3. Integrated Internationalization (Blaise-i18n)
**Goal**: First-class support for multilingual applications.
- **Global Helper `$t()`**: Immediate access in the template (`{{ $t('common.save') }}`) and in Pascal methods (`this['$t']('common.save')`).
- **Reactive Dictionaries**: Message files in `.json` or Pascal units (`uLocalePT.pas`, `uLocaleEN.pas`).
- **Dynamic Locale Switching**: Instant runtime language switching without reloading the page, updating all on-screen strings.

---

### 📚 4. Automatic Documentation Generator (`bv doc`)
**Goal**: Facilitate the creation of enterprise Design Systems and component libraries.
- **CLI Command**: `bv doc` analyzes the `src/components/` and `lib/` folders.
- **AST Parser in Pascal**: Automatically extracts:
  - Declared props (name, type, default value).
  - Emitted events (`$emit`).
  - Available slots (named and scoped).
  - Documentation docstrings written inside `.bv` files.
- **Interactive Catalog**: Generates a modern static site (similar to *Storybook* or *VuePress*) featuring a component previewer and interactive playground.

---

### ⚡ 5. WebAssembly Acceleration (FPC Wasm Target)
**Goal**: Near-native performance for computationally intensive tasks.
- **Hybrid Pipeline**: Enable image processing routines, cryptography, mathematical computations, or compression to be compiled directly to WebAssembly (`.wasm`) using the FreePascal Compiler's Wasm backend.
- **Interoperability**: Seamlessly call Wasm functions directly from `.bv` component methods without the complexity of manual JavaScript wrappers.

---

### 🚀 6. SSG & Static Pre-rendering (Static Site Generation)
**Goal**: Instant first-load time (FCP < 100ms) and perfect search engine indexing (SEO).
- **Command `bv run ssg`**: Pre-renders router routes into static HTML files with initial data injected.
- **Reactive Hydration**: Upon loading in the browser, the BlaiseVue client attaches the reactive tree to pre-existing HTML without repainting the screen (zero flickering).

---

### 🧪 7. Headless End-to-End Test Driver (E2E Testing)
**Goal**: Test complete user workflows in real browsers.
- **CLI Integration**: `bv test e2e` command.
- **Critical Flow Validation**: Automated tests covering authentication, HTML5 History navigation, form submissions, modal dialog openings via `<teleport>`, and asynchronous resolution of `<suspense>`.

---

## 🔮 The Next Frontier: BlaiseVue 3.5 — The Universal Pascal Platform

With the core web, reactive, and WebAssembly engines completed in **v3.0**, **BlaiseVue 3.5** expands the framework to a **universal multiplatform platform** (Web + Desktop + Mobile + Full-Stack Pascal), unifying frontend, mobile packaging, and backend microservices under the Object Pascal umbrella.

```
                                  BLAISEVUE 3.5
                                        │
        ┌───────────────┬───────────────┼───────────────┐
        ▼               ▼               ▼               ▼
    [Desktop]       [Mobile]       [mORMot 2]      [VS Code DX]
 (WebUI4Delphi)   (Capacitor)     (Full-Stack)     (LSP & VSIX)
```

---

### 🖥️ Pillar 1: Real Multiplatform Desktop (WebUI4Delphi + Lazarus IDE)
**Goal**: Build ultra-lightweight, native desktop applications (<10 MB, 40 MB RAM) running identically on **Windows, Linux, and macOS** without Electron bloat and without legacy GTK2 dependencies.
- **Why WebUI4Delphi over WebView2/GTK2**:
  - WebUI4Delphi utilizes modern installed browsers (Chrome, Edge, Firefox, Brave) in clean native app mode (`--app`).
  - Completely eliminates GTK2 dependency on modern Linux distributions (Ubuntu 22.04/24.04, Debian 12, Fedora).
  - True cross-platform: Windows (Win32), Linux (X11/Wayland), macOS (Cocoa).
- **Lazarus IDE Integration**: Official template `.lpi`/`.lpr` ready for development and native debugging (`F9`).
- **Single-Binary Packaging (`.res`)**: Automatic packaging of `dist/` into Windows/Linux resources for a zero-dependency standalone `.exe`.
- **CLI Commands**:
  - `bv desktop init --webui`: Scaffolds the Lazarus + WebUI4Delphi desktop bridge.
  - `bv desktop run`: Compiles the frontend and launches the native desktop window.

---

### 📱 Pillar 2: Straightforward Mobile Hybrid (Capacitor Integration) — ✅ Completed
**Goal**: Package BlaiseVue applications as native **Android (.apk / .aab)** and iOS apps without the Rust/NDK toolchain complexity of Tauri or the obsolescence of Cordova.
- **Why Capacitor over Cordova and Tauri Mobile**:
  - Cordova is legacy with abandoned plugins.
  - Tauri Mobile requires complex Rust, Android NDK, and cross-compilation toolchains on Windows.
  - Capacitor uses standard Android Studio / Xcode, wrapping `dist/` inside a modern native WebView with zero Rust setup.
- **Responsive Layout & Mobile UX**:
  - Responsive Grid System (`bv-container`, `bv-row`, `bv-col`) with fluid gutters and 12-column adaptive layout.
  - Mobile bottom navigation (`bv-bottom-nav`, `bv-bottom-nav-item`) with active route tracking.
  - Responsive Off-canvas Drawer (`bv-drawer`) for secondary navigation.
  - Adaptive dialog modals (`bv-modal`) with clean unmount and teleport management.
- **CLI Commands**:
  - `bv mobile init [name] [id]`: Configures Capacitor and scaffolds the native Android project.
  - `bv mobile sync`: Syncs `dist/` assets directly into `android/app/src/main/assets/public/`.
  - `bv mobile open`: Syncs and opens the project in Android Studio.
  - `bv mobile build`: Compiles the native Debug APK via Gradle (`android/app/build/outputs/apk/debug/app-debug.apk`).

---

### ⚙️ Pillar 3: Full-Stack Pascal with mORMot 2 (Ultra-High-Performance Backend)
**Goal**: Combine the fastest frontend Pascal framework (BlaiseVue) with the fastest backend Pascal engine in existence (Synopse mORMot 2 by Arnaud Bouchez).
- **Official Template `fullstack-mormot`**:
  - Pre-configured backend server in Free Pascal / Delphi with SQLite/PostgreSQL ORM, JWT authentication, and high-throughput REST endpoints.
  - Native real-time WebSockets for bidirectional communication (push notifications, live dashboard metrics).
- **Reactive Client Service (`$api` & `$ws`)**:
  - Injected `$api` and `$ws` helpers in BlaiseVue component scopes with automatic header injection, bearer token handling, and reactive data synchronization.
- **Shared Pascal Contracts**: Share data structures and record definitions directly between the backend and frontend.

---

### 🛠️ Pillar 4: Professional Developer Experience (VS Code Extension VSIX) — ✅ Completed
**Goal**: Provide a frictionless developer experience comparable to Vue Volar / React JSX.
- **Intelligent Directive & Component Autocomplete**:
  - Typing `b-` suggests directives (`b-model`, `b-for`, `b-if`, `b-validate`).
  - Typing `<bv-` suggests all 25+ BlaiseUI components (`<bv-modal>`, `<bv-btn>`, `<bv-card>`, `<bv-icon>`, `<bv-theme-toggle>`) with documented attributes and slots.
- **Comprehensive Snippet Suite**:
  - `bv-comp` (SFC scaffolding), `bv-form` (validated form), `bv-wasm` (Wasm benchmark call), `bv-modal`, `bv-chart`.
- **Packaged `.vsix` & Direct CLI Tooling**:
  - `bv vsix` / `bv extension package`: Generates standalone 1-click installable `.vsix` package for VS Code and Cursor.
  - `bv extension install`: Installs the extension into the local VS Code editor.

---

## 📅 Schedule & Implementation Roadmap

```
[ v2.0 - Completed ✅ ] ──► SPA Router, Scoped Slots, DevTools, Vitest
       │
       ▼
[ v2.5 - Completed ✅ ] ──► Form Validation Engine (b-validate)
                        ──► List Transitions (<transition-group>)
                        ──► Internationalization (Blaise-i18n)
       │
       ▼
[ v2.6 - Completed ✅ ] ──► Themes (blaise-themes) & Icons (blaise-icons)
       │
       ▼
[ v3.0 - Completed ✅ ] ──► Documentation Generator (bv doc)
                        ──► WebAssembly Acceleration (BVWasm / $wasm)
                        ──► SSG & Static Pre-rendering (bv run ssg)
                        ──► Zero-Flicker Reactive Hydration
                        ──► Automated E2E Suite (bv test e2e)
       │
       ▼
[ v3.5 - The Universal Pascal Platform 🚀 ]
  ├── Phase 1: Tooling & DX ──► VS Code Extension (.vsix) + Snippets + BlaiseUI Autocomplete (✅ Completed)
  ├── Phase 2: Mobile ────────► Capacitor Integration (bv mobile init/run) (✅ Completed)
  ├── Phase 3: Desktop ───────► WebUI4Delphi + Lazarus IDE Scaffolding (bv desktop)
  └── Phase 4: Full-Stack ────► mORMot 2 Backend Template (fullstack-mormot)
```

---

🛡️ **"Architecture is the art of making the impossible inevitable."** ✨🏆🚀

