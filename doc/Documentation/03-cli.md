# 🛡️ BlaiseCLI Technical Manual (bv.exe)

The `bv.exe` is the native command-line orchestrator of BlaiseVue, responsible for transpiling SFC components, managing libraries, running tests, scaffolding projects, and serving development builds with Hot Module Replacement (HMR).

---

## 🏗️ Development and Serving Commands

### 1. `bv dev` / `bv serve` (Development Server with Instant HMR)
Launches the integrated development server with live Hot Module Replacement:
- **`bv dev`**: Modern standard command to boot the dev server with HMR.
- **`bv serve`**: Legacy alias fully supported for backward compatibility.
- **HTTP Server**: Serves your application bundle locally at `http://localhost:8080`.
- **WebSocket Server**: Active at `ws://localhost:8081` to stream instant component updates.
- **File Watcher**: Monitors `src/` and `lib/` directories. On file save, re-transpiles only the affected `.bv` file and sends an in-place patch to the browser without reloading the page or losing state.

### 2. `bv run dev` (Express Development Build)
Executes a full development build with cache busting:
- **Cache Busting (`v=123...`)**: Injects timestamps into script and link tags in `index.html` to prevent stale browser caches.
- **Diagnostic DevTools**: Injects diagnostic symbols and runtime hooks for browser extensions.
- **Verbose Console Output**: Generates human-readable debug logs.

### 3. `bv run build` (Optimized Production)
Generates the production-ready distribution in `dist/`:
- **Purge Artifacts**: Removes development scaffolding, debug symbols, and experimental units.
- **Tree-Shaking & Minification**: Links only the required runtime units from Pas2JS RTL.
- **Static Assets**: Bundles and hashes scripts for long-term caching.

---

## 🏛️ Native Resource Scaffolding (`templates.res`)

The BlaiseVue CLI's internal architecture is designed to eliminate hardcoded template strings:

1. **Templates Directory**: All initial project files reside in [`bin/templates/`](file:///c:/Users/Pichau/Documents/BlaiseVue/bin/templates/):
   - `index.html` — Base HTML entry point.
   - `app.bv` — Root component layout.
   - `Home.bv` & `Counter.bv` — Starter page and component.
   - `app.cfg` — Preconfigured Pas2JS transpiler configuration.
   - `bootstrap.css` — Base styles.
2. **Resource Embedding (`{$R templates.res}`)**:
   - Templates are compiled into a binary resource file (`templates.res`) via `windres` / FPC.
   - Embedded directly into the `bv.exe` executable at compile-time.
3. **Standalone Binary & 4-Tier Scaffolding**:
   - Running `bv create <ProjectName>` extracts the templates cleanly using `TResourceStream` and scaffolds the complete enterprise directory tree.
   - Automatically establishes the **4-Tier Testing Architecture** (`tests/components/`, `tests/views/`, `tests/unit/`, `tests/framework/`), initial domain services in `src/services/`, and sets up `vitest.config.js` with deep recursive glob discovery.

---

## 🏗️ Scaffolding Generators for Components, Views, and Tests (`bv new`)

BlaiseVue features intelligent code generators that accelerate development and automatically create corresponding test suites:

### 1. Create Component: `bv new component <Name> [--no-test]`
Creates the visual Single File Component (`.bv`) and its companion test file:
```bash
bv new component ProductCard
# Shorthand:
bv new c ProductCard
```
- Creates: `src/components/ProductCard.bv`
- Automatically generates: `tests/components/ProductCard.test.pas`
- Pass `--no-test` (or `-nt`) to create only the `.bv` component.

### 2. Create View / Page: `bv new view <Name> [--no-test]`
Creates an application page view and its mount verification test:
```bash
bv new view OrderHistory
# Shorthand:
bv new v OrderHistory
```
- Creates: `src/views/OrderHistory.bv`
- Automatically generates: `tests/views/OrderHistory.test.pas`
- Supports `--no-test` to skip test generation.

### 3. Create Service Unit: `bv new service <Name> [--no-test]`
Creates a pure Pascal business service unit and its corresponding domain unit test:
```bash
bv new service PaymentProcessor
# Shorthand:
bv new s PaymentProcessor
# Generator alias:
bv g s PaymentProcessor
```
- Creates: `src/services/uPaymentProcessor.pas` (Pure Pascal domain logic)
- Automatically generates: `tests/unit/PaymentProcessor.test.pas` (Pre-configured unit test with `BVTestUtils`)
- Pass `--no-test` (or `-nt`) to create only the service unit without a test file.

### 4. Create Dedicated Test File (Smart Hierarchy Resolution): `bv new test <Name>`
Creates test suites on demand with automatic directory resolution:
```bash
bv new test SimpleBadge
# Shorthand:
bv new t SimpleBadge
```
- **If `SimpleBadge.bv` is a component:** created in `tests/components/SimpleBadge.test.pas` mounting `'simple-badge'`.
- **If it is a view:** created in `tests/views/SimpleBadge.test.pas` mounting `'simple-badge-page'`.
- **If it is a service in `src/services/`:** created in `tests/unit/SimpleBadge.test.pas` importing `uSimpleBadge`.
- **If given a relative path:** `bv new t services/CalculoFrete` -> created in `tests/services/CalculoFrete.test.pas`.
- **Otherwise:** created in `tests/unit/SimpleBadge.test.pas` for pure Object Pascal business logic.

### 5. List Elements: `bv list <c|v|s|t|lib>`
Lists registered files across the project:
- `bv list c`: Lists components in `src/components/`.
- `bv list v`: Lists views in `src/views/`.
- `bv list s`: Lists pure Pascal service units in `src/services/`.
- `bv list t`: Lists all test suites recursively across the 4 tiers of `tests/`.
- `bv list lib`: Lists installed libraries in `lib/`.

### 6. Remove Elements: `bv remove <component|view|service|test> <Name>`
Safely purges the source file, generated Pascal units in `generated/`, and associated test files across subfolders:
```bash
bv remove component ProductCard     # or: bv remove c ProductCard
bv remove view OrderHistory         # or: bv remove v OrderHistory
bv remove service PaymentProcessor  # or: bv remove s PaymentProcessor
bv remove test SimpleBadge          # or: bv remove t SimpleBadge
```

---

## 🧪 Automated Test Runner (`bv test`)

The `bv test` command compiles and executes all unit and integration tests across the 4-tier hierarchy:
```bash
bv test
```
1. **Pre-flight Cleaning:** Automatically cleans stale artifacts in `generated/tests/` to prevent orphan test execution.
2. **Recursive Discovery:** Finds all `*.test.pas` files across `tests/components/`, `tests/views/`, `tests/unit/`, and `tests/framework/`.
3. **Component Transpilation:** Transpiles all `.bv` Single File Components into `generated/`.
4. **Folder-Preserving Compilation:** Compiles each Pascal test program to JavaScript using Pas2JS, maintaining relative folder structure (e.g. `generated/tests/views/Home.test.js`).
5. **Vitest Execution:** Runs the test suites via **Vitest** on Node.js / JSDOM with 100% test compatibility and terminal reporting.

For continuous test-driven development:
```bash
bv test --watch
```

---

## 📦 Standalone Library Scaffolding & Release Packager

BlaiseVue enables creating, testing, and distributing modular component libraries:

### 1. Scaffold Dedicated Library: `bv create <name> --lib [--license <type>]`
Creates an isolated library repository with component templates, standalone CSS, autonomous test suite, and interactive development sandbox:
```bash
bv create my-ui-kit --lib
```
- Prompts for license selection interactively: **MIT**, **Apache-2.0**, **LGPL-3.0**, **Commercial**, or **None**.
- In CI pipelines, specify `--license <type>` non-interactively (e.g. `bv create my-ui-kit --lib --license mit`).
- Scaffolds `src/`, `styles/`, `demo/`, `tests/`, `package.json`, `LICENSE`, and `README.md`.

### 2. Assemble Release Artifact: `bv lib pack [dir] [--skip-tests]`
Prepares a production release package in `dist/<name>-<version>.zip` with SHA-256 verification:
```bash
bv lib pack
# Alias:
bv lib dist
```
- **Pre-flight Tests**: Runs `bv test` before packaging to guarantee zero regressions (bypass with `--skip-tests`).
- **Production Filtering**: Packages only `src/`, `styles/`, `package.json`, `README.md`, `LICENSE`, and `setup.pas`.
- **Integrity Hash**: Computes SHA-256 checksum and writes `dist/<name>-<version>.zip.sha256`.

---

## 📦 Library & Package Management (`/lib`)

BlaiseVue includes an integrated package manager and library system:
- **Official Package Aliases (`bv lib install <name>`)**:
  - `bv lib install themes`: Installs the 9 official Bootswatch themes and theme switcher components into `lib/themes/`.
  - `bv lib install icons`: Installs the Bootstrap Icons suite (styles + woff2 fonts) into `lib/icons/`.
  - `bv lib install ui`: Installs the official BlaiseUI component suite into `lib/blaise-ui/`.
  - `bv lib install <url>`: Downloads, extracts, and configures third-party libraries from any `.zip` URL.
- **Theme Switcher CLI (`bv theme`)**:
  - `bv theme list`: Lists all installed Bootswatch themes in `lib/themes/`.
  - `bv theme use <name>`: Updates the active project stylesheet link in `public/index.html` (e.g. `bv theme use darkly`).
- **Auto-Autoload**: Any `.bv` files within `lib/` (or subdirectories) are automatically registered as global components.
- **Auto-Asset Injection**: Non-theme `.css` and `.js` files found in `lib/` are automatically injected into `dist/index.html`.
- **Interactive Library Setup (`bv s <name>`)**: Triggers an interactive installation and configuration menu for modular libraries following the **[setup.pas standard](18-external-libraries.md)**.

---

## ⚡ Next-Gen Enterprise & Universal Platform (Phases 1-4) Commands

### 1. `bv doc [--serve]` (Interactive Documentation & Component Playground)
Parses the AST of all `.bv` components across the project, extracting props, slots, events, and Pascal docstrings, and generates an interactive component documentation website at `dist/docs/index.html`. Optionally boots a dedicated HTTP documentation server with `--serve`.

### 2. `bv wasm <info|benchmark>` (WebAssembly Acceleration)
Manages WebAssembly modules in the project and executes performance benchmarks comparing Pascal compiled directly to JavaScript versus Pascal executing natively inside WebAssembly (Wasm).

### 3. `bv run ssg` (Static Site Generation & Pre-rendering)
Pre-renders all registered application routes into static, SEO-friendly HTML files with zero-flicker reactive client-side hydration.

### 4. `bv vsix` / `bv extension [install|package]` (VS Code Official Extension)
Packages the official BlaiseVue extension into a standalone `.vsix` bundle for Visual Studio Code and VSCodium, featuring triple syntax highlighting, intelligent auto-completion, and an extensive snippet library. The `bv extension install` command installs the extension directly into the local editor.

### 5. `bv mobile` (Hybrid Mobile Platform Android / iOS & Capacitor)
Manages the complete mobile development lifecycle using Capacitor within a unified `mobile/` architecture:
- **`bv mobile init [name] [id]`**: Scaffolds the mobile directory structure inside `mobile/` (`mobile/android/`, `mobile/ios/`, `mobile/bin/android/`, `mobile/bin/ios/`, `mobile/README.md`) and configures `capacitor.config.json`.
- **`bv mobile sync [android|ios|all]`**: Synchronizes the production build (`dist/`) with the selected native mobile platforms.
- **`bv mobile build [target] [--release]`**: Compiles ready-to-install native packages (`.apk` / `.aab` / `.ipa`).
  - E.g.: `bv mobile build android` (Generates `mobile/bin/android/<App>-debug.apk` via Gradle `assembleDebug`)
  - E.g.: `bv mobile build android --release` (Generates `mobile/bin/android/<App>-release.apk` optimized with R8/ProGuard)
  - E.g.: `bv mobile build ios` (Prepares and synchronizes native Xcode project)
  - E.g.: `bv mobile build all --release` (Compiles all mobile target platforms in release mode)
- **`bv mobile emulator <list|start [name]|run [name]>`**: Manages and launches Android Virtual Devices (AVD) directly from the command line.
  - E.g.: `bv mobile emulator list` (Lists all installed AVDs from Android Studio)
  - E.g.: `bv mobile emulator start` (Starts the emulator process in the background)
- **`bv mobile run [target] [--emulator [name]]`**: Installs and launches the application directly on a connected device or emulator via ADB (`adb install -r` + `am start`). If `--emulator` is provided, automatically boots the emulator if it is offline.
- **`bv mobile open [target]`**: Opens the native IDE (`open android` for Android Studio, `open ios` for Xcode on macOS).

> [!NOTE]
> **BlaiseVue does NOT require Flutter.** The mobile toolchain only requires Node.js/npm, Android Studio (Android SDK, Build-Tools, and Platform-Tools `adb`), and Java JDK 17/21.

| Mobile Command | Platform | Build Mode | Output / Action |
|---|---|---|---|
| `bv mobile build android` | Android | Debug | `mobile/bin/android/<App>-debug.apk` |
| `bv mobile build android --release` | Android | Release | `mobile/bin/android/<App>-release.apk` |
| `bv mobile emulator list` | Android | - | Lists installed AVD emulators |
| `bv mobile emulator start` | Android | - | Boots emulator in background |
| `bv mobile run android` | Android | Debug | Installs & launches on USB-connected device |
| `bv mobile run android --emulator` | Android | Debug | Boots emulator, installs APK, and launches app |
| `bv mobile open android` | Android | - | Opens project in Android Studio |
| `bv mobile open ios` | iOS | - | Opens project in Xcode (macOS) |

### 6. `bv desktop` (Multiplatform Desktop WebUI & Lazarus IDE)
Manages the native desktop development lifecycle with Free Pascal and WebUI:
- **`bv desktop init [name]`**: Scaffolds the Lazarus project structure (`.lpi`, `.lpr`, `webui.pas`, `uDesktopBridge.pas`, `assets/`, `bin/`, `units/`, `README.md`) inside `desktop/`.
- **`bv desktop sync`**: Synchronizes the production web build (`dist/`) into desktop application assets (`desktop/assets/`).
- **`bv desktop build [target] [--release]`**: Compiles native binaries for a specific platform (`windows`, `linux`, `macos`, or `all`). Defaults to the host OS if not specified.
  - E.g.: `bv desktop build windows` (Debug mode on Windows with active logging console)
  - E.g.: `bv desktop build linux --release` (Release mode for Linux in `desktop/bin/linux/`)
  - E.g.: `bv desktop build all --release` (Cross-compiles for all platforms in Release mode)
- **`bv desktop run [target] [--release]`**: Synchronizes assets, compiles, and launches the native desktop application.
  - E.g.: `bv desktop run windows` (Launches on Windows with console window for live diagnostics)
  - E.g.: `bv desktop run windows --release` (Launches in pure GUI mode without console window for end users)

| Desktop Target / Mode | CLI Command | Lazarus IDE Mode | Window Behavior | Output Directory |
|---|---|---|---|---|
| **Debug (Windows)** | `bv desktop run windows` | `Debug` | GUI Window + Diagnostics Console | `desktop/bin/windows/` |
| **Release (Windows)** | `bv desktop run windows --release` | `Release` | GUI Window Only (No Console) | `desktop/bin/windows/` |
| **Debug (Linux)** | `bv desktop build linux` | `Debug` | Native ELF Binary with Logs | `desktop/bin/linux/` |
| **Release (Linux)** | `bv desktop build linux --release` | `Release` | Optimized Native ELF Binary | `desktop/bin/linux/` |
| **All Platforms** | `bv desktop build all --release` | - | Segregated Binaries for Win, Linux, Mac | `desktop/bin/<platform>/` |

See detailed documentation in **[36. Multiplatform Desktop & Lazarus IDE](36-desktop-webui.md)**.

### 7. `bv mormot` (Full-Stack Pascal with Synopse mORMot 2)
Manages high-throughput native Pascal backend microservices and zero-configuration production deployment:
- **`bv create <name> --mormot`**: Scaffolds a full-stack project with both reactive frontend and native mORMot 2 backend.
- **`bv mormot init`**: Scaffolds the Lazarus project structure (`.lpi`, `.lpr`, `ServerApp.pas`, `ServerModels.pas`) inside `server/`.
- **`bv mormot build [--release]`**: Compiles the native backend executable with Free Pascal.
  - E.g.: `bv mormot build` (Debug mode with diagnostic symbols)
  - E.g.: `bv mormot build --release` (Maximum optimization `-O3`, stripped symbols, ~1.6 MB)
- **`bv mormot run [--port <port>]`**: Launches the native mORMot 2 server (defaults to port 8090) with static SPA hosting and REST API.
- **`bv mormot status [--port <port>]`**: Queries the running server health endpoint (`/api/status`).
- **`bv mormot deploy [--zip] [--port <port>]`**: Packages the complete standalone production bundle:
  - Compiles frontend in production mode (`bv run build`).
  - Compiles backend in release mode (`bv mormot build --release`).
  - Assembles `deploy/` with `server.exe`, `dist/`, `start.bat`, `start.sh`, and `README.txt`.
  - Optionally compresses everything into `deploy.zip` when `--zip` is passed.
  - **Zero Server Prerequisites**: No Node.js, npm, Free Pascal, or Lazarus required on the target server!

| mORMot Command | Subcommand / Flag | Action / Output |
|---|---|---|
| `bv mormot init` | - | Scaffolds native backend in `server/` |
| `bv mormot build` | - | Compiles Debug server (`server/bin/server.exe`) |
| `bv mormot build` | `--release` | Compiles optimized Release server |
| `bv mormot run` | `[--port <p>]` | Starts server on port (default: 8090) |
| `bv mormot status` | `[--port <p>]` | Queries `/api/status` health check |
| `bv mormot deploy` | `[--port <p>]` | Creates standalone `deploy/` folder |
| `bv mormot deploy` | `--zip` | Creates standalone `deploy.zip` archive |

See detailed documentation in **[37. Full-Stack Pascal with mORMot 2](37-mormot2-backend.md)**.

---

## 🧹 Maintenance Commands

### `bv clean`
Performs a complete purge of the build workspace:
1. Purges the `generated/` directory.
2. Purges compiled scripts in `dist/js/` and styles in `dist/css/`.
3. Resets `dist/index.html` back to the template state.

---

## ⚡ CLI Performance Benchmark

Written 100% in **Native Object Pascal (FreePascal)**, the `bv.exe` CLI transpiles and orchestrates SFC components up to **50x faster** than Node.js-based alternatives, delivering instant feedback on enterprise codebases. 🛡️✨🏆
