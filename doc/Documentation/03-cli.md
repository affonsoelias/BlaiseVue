# 🛡️ BlaiseCLI Technical Manual (bv.exe)

The `bv.exe` is the native command-line orchestrator of BlaiseVue, responsible for transpiling SFC components, managing libraries, running tests, scaffolding projects, and serving development builds with Hot Module Replacement (HMR).

---

## 🏗️ Development and Serving Commands

### 1. `bv serve` (Development Server with Instant HMR)
Launches the integrated development server with live Hot Module Replacement:
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

In BlaiseVue 2.0, the CLI's internal architecture was completely refactored to eliminate hardcoded template strings from the Pascal source code:

1. **Templates Directory**: All initial project files reside in [`bin/templates/`](file:///c:/Users/Pichau/Documents/BlaiseVue/bin/templates/):
   - `index.html` — Base HTML entry point.
   - `app.bv` — Root component layout.
   - `Home.bv` & `Counter.bv` — Starter page and component.
   - `app.cfg` — Preconfigured Pas2JS transpiler configuration.
   - `bootstrap.css` — Base styles.
2. **Resource Embedding (`{$R templates.res}`)**:
   - Templates are compiled into a binary resource file (`templates.res`) via `windres` / FPC.
   - Embedded directly into the `bv.exe` executable at compile-time.
3. **Standalone Binary**:
   - Running `bv create <ProjectName>` extracts the templates cleanly using `TResourceStream`.
   - The compiled `bv.exe` requires zero external template files to generate new projects.

---

## 🧪 Unit Testing Arsenal (`bv test`)

BlaiseVue integrates automated testing using Pascal test specifications compiled to JavaScript and executed with **Vitest**:

### `bv test`
Transpiles all components, builds the test units in `tests/`, and executes the full suite in headless Node.js via Vitest.

### `bv new t <Name>`
Instantly scaffolds a new unit test file.
```bash
bv new t UserProfile
```
Generates `tests/UserProfile.test.pas` pre-filled with the `Describe`, `It`, and `Expect` assertions template.

### `bv list t`
Lists all unit test suites currently registered in the `tests/` folder.

### `bv remove t <Name>`
Safely removes a test file and any corresponding compiled artifacts.

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

## ⚡ Next-Gen Enterprise & Phase 1 / Phase 2 / Phase 3 Commands

### 1. `bv doc [--serve]` (Interactive Documentation & Component Playground)
Parses the AST of all `.bv` components across the project, extracting props, slots, events, and Pascal docstrings, and generates an interactive component documentation website at `dist/docs/index.html`. Optionally boots a dedicated HTTP documentation server with `--serve`.

### 2. `bv wasm <info|benchmark>` (WebAssembly Acceleration)
Manages WebAssembly modules in the project and executes performance benchmarks comparing Pascal compiled directly to JavaScript versus Pascal executing natively inside WebAssembly (Wasm).

### 3. `bv run ssg` (Static Site Generation & Pre-rendering)
Pre-renders all registered application routes into static, SEO-friendly HTML files with zero-flicker reactive client-side hydration.

### 4. `bv vsix` / `bv extension [install|package]` (Phase 1: VS Code Official Extension)
Packages the official BlaiseVue extension into a standalone `.vsix` bundle for Visual Studio Code and VSCodium, featuring triple syntax highlighting, intelligent auto-completion, and an extensive snippet library. The `bv extension install` command installs the extension directly into the local editor.

### 5. `bv mobile` (Phase 2: Hybrid Mobile Platform Android / iOS & Capacitor)
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

### 6. `bv desktop` (Phase 3: Multiplatform Desktop WebUI & Lazarus IDE)
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
