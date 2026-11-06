# 🛡️ BlaiseCLI Technical Manual (bv.exe)

The `bv.exe` is the native command-line orchestrator of BlaiseVue, responsible for transpiling SFC components, managing libraries, running tests, scaffolding projects, and serving development builds with Hot Module Replacement (HMR).

---

### 🏷️ Version Inspection (`bv --version` / `bv -v`)

Outputs the dynamic framework version derived from the Single Source of Truth (`package.json`):

```bash
bv --version
# Output: BlaiseVue CLI v4.4.0 (Universal Pascal Full-Stack Platform)

bv -v
```

---

## 🏗️ Development and Build Commands

### 1. `bv dev` (Development Build & Server with Instant HMR)
Compiles Single File Components (`.bv`) in development mode and boots the integrated development server with live Hot Module Replacement:
- **Build & Serve**: Compiles all reactive templates (`BVDevTools` active) and launches the HMR development server on `http://localhost:8080`.
- **WebSocket Server**: Active at `ws://localhost:8081` to stream instant component updates.
- **File Watcher**: Monitors `src/` and `lib/` directories. On file save, re-transpiles only the affected `.bv` file and updates the browser in real time.
- **Cache Busting (`v=123...`)**: Injects timestamps into script and link tags in `index.html` to prevent stale browser caches.

### 2. `bv build` (Development / Lazarus Compilation)
Compiles Single File Components (`.bv`) in development/debug mode without launching the HTTP server:
- Ideal for Lazarus IDE (`Ctrl+F9`), watchers, linters, and CI verification.
- Injects diagnostic `BVDevTools` symbols and generates `dist/js/main.js`.

### 3. `bv build --release` (Optimized Production Build)
Generates the production-ready distribution in `dist/` (`-dPRODUCTION`):
- **Purge Artifacts**: Removes development scaffolding, `BVDevTools`, and debug hooks.
- **Tree-Shaking & Optimization**: Links only the required runtime units from Pas2JS RTL.
- **Static Assets & Hashing**: Bundles and hashes scripts (`main.<hash>.js`) for long-term caching.

### 4. `bv preview` (Production Preview Server)
Starts a local static HTTP server on `http://localhost:5000` to inspect the production build in `dist/`.

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
   - Automatically establishes the **4-Tier Testing Architecture** (`tests/components/`, `tests/views/`, `tests/services/`, `tests/framework/`), initial domain services in `src/services/`, and sets up `vitest.config.js` with deep recursive glob discovery.

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
- Automatically generates: `tests/services/PaymentProcessor.test.pas` (Pre-configured unit test with `BVTestUtils`)
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
- **If it is a service in `src/services/`:** created in `tests/services/SimpleBadge.test.pas` importing `uSimpleBadge`.
- **Otherwise:** created in `tests/services/SimpleBadge.test.pas` for pure Object Pascal business logic.

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

### 7. Rename Elements: `bv rename <component|view|service|project> <OldName> [NewName]`
Intelligently refactors components, views, services, or the entire project, updating source files, internal Pascal declarations, unit names, test suites, router configurations, and global registry entries:

```bash
# Rename a pure Pascal service and its unit tests:
bv rename service ShippingCalculator LogisticsEngine
# Shorthand:
bv rename s ShippingCalculator LogisticsEngine

# Rename a component and update HTML tag across tests:
bv rename component ProductCard ItemCard
# Shorthand:
bv rename c ProductCard ItemCard

# Rename a view and update app.bv router definition:
bv rename view OrderHistory MyOrders
# Shorthand:
bv rename v OrderHistory MyOrders

# Rename the entire project across package.json, src/app.bv, uAppVersion.pas, index.html, and registry:
bv rename project my-new-erp
# Shorthand:
bv rename p my-new-erp
```
* **Services**: Renames `src/services/u<Old>.pas` to `src/services/u<New>.pas`, updates `unit u<New>;`, refactors `T<New> = class`, method signatures, and updates `tests/services/<New>.test.pas`.
* **Components**: Renames `src/components/<Old>.bv` to `src/components/<New>.bv`, updates associated test and tags (`<old-card>` -> `<new-card>`).
* **Views**: Renames `src/views/<Old>.bv` to `src/views/<New>.bv`, updates associated test and automatically updates route tags in `src/app.bv`.
* **Projects**: Updates `package.json`, `src/uAppVersion.pas`, `src/app.bv` (`appTitle`), `public/index.html` (`<title>`), and the global project registry.

---

## 🧪 Automated Test Runner (`bv test`)

The `bv test` command compiles and executes all unit and integration tests across the 4-tier hierarchy:
```bash
bv test
```
1. **Pre-flight Cleaning:** Automatically cleans stale artifacts in `generated/tests/` to prevent orphan test execution.
2. **Recursive Discovery:** Finds all `*.test.pas` files across `tests/components/`, `tests/views/`, `tests/services/`, and `tests/framework/`.
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

## 📦 Package Management, Ecosystem & Registries

BlaiseVue features a modern, multi-tier package manager designed for zero-conflict SDK updates, SemVer version pinning, global offline caching, and decentralized repositories.

### 1. Package Repositories (`bv repo`)
Manages upstream catalog sources and multi-package ecosystem repositories configured in `~/.blaisevue/repos.json`:

```bash
# List all registered repositories (* denotes default active catalog):
bv repo list

# Register an external community or private repository:
bv repo add community https://github.com/my-org/my-blaise-packages

# Set default primary repository for package resolution:
bv repo default community

# Remove a registered repository:
bv repo remove community

# Synchronize and cache ecosystem catalog metadata locally:
bv repo sync

# Search packages across all registered repositories:
bv repo search chart
```

### 2. Package Installation & Resolution (`bv lib install`)
Installs packages using a 4-tier resolution strategy:
1. **Local Project (`/lib/<pkg>`)**: Reuses project-installed libraries if the requested version matches.
2. **User Global Cache (`~/.blaisevue/packages/<pkg>`)**: Instant offline installation in milliseconds when cached.
3. **Core Framework (`packages/core/<pkg>`)**: Shielded built-in libraries (`blaise-ui`, `blaise-themes`, `blaise-icons`, `blaise-charts`, `blaise-reports`, `blaise-studio`).
4. **Remote Ecosystem (GitHub Releases)**: Automatically downloads versioned `.zip` release assets, updates global cache, and installs into the project.

```bash
# Install latest version of an ecosystem package into project /lib:
bv lib install test

# Install a specific pinned version:
bv lib install test@1.0.0

# Install from a specific repository (<repo>:<package>[@version]):
bv lib install official:test@1.1.0
bv lib install myrepo:my-widget

# Install directly into user global cache (~/.blaisevue/packages/):
bv lib install test --global # (or alias: -g)

# Install official core packages (supports short aliases, full names, or @blaise-* namespaces):
bv lib install themes    # (or: blaise-themes, @blaise-themes) -> lib/themes/
bv lib install ui        # (or: blaise-ui, @blaise-ui)         -> lib/blaise-ui/
bv lib install icons     # (or: blaise-icons, @blaise-icons)   -> lib/icons/
bv lib install charts    # (or: blaise-charts, @blaise-charts) -> lib/blaise-charts/
bv lib install reports   # (or: blaise-reports, @blaise-reports) -> lib/blaise-reports/
bv lib install mobile    # (or: blaise-ui-mobile, @blaise-ui-mobile) -> lib/blaise-ui-mobile/
bv lib install studio    # (or: blaise-studio, @blaise-studio) -> lib/blaise-studio/

# Install from arbitrary URL or local .zip archive:
bv lib install https://example.com/vendor-package.zip
```

### 3. Inspection & Updates (`bv lib outdated` & `bv lib update`)
Inspects SemVer discrepancies and upgrades packages seamlessly:

```bash
# Inspect outdated packages comparing local versions against remote ecosystem:
bv lib outdated

# Inspect user global cache for outdated packages:
bv lib outdated --global

# Upgrade all installed packages to latest versions:
bv lib update

# Upgrade a specific package:
bv lib update test
```

### 4. Removal & Listing (`bv lib remove` & `bv lib list`)
```bash
# List installed libraries in current project /lib:
bv lib list

# List packages in user global cache:
bv lib list --global

# Safely remove a package from project /lib (runs setup.pas cleanup if present):
bv lib remove test

# Remove a package from user global cache:
bv lib remove test --global
```

- **Enterprise Theme Manager & Build-Time Optimizer (`bv theme`)**:
  - `bv theme [list]`: Displays active project themes configured in `package.json`, the current default theme, and all catalog themes provided by `@blaise-themes`.
  - `bv theme add <name>`: Registers a theme into the `"themes"` array in `package.json`. When building (`bv build`), only configured themes are bundled, reducing CSS payload by ~90% (from ~2.0 MB down to ~220 KB per theme).
  - `bv theme remove <name>`: Removes a theme from the `"themes"` whitelist in `package.json`.
  - `bv theme use <name>`: Sets the default active theme in `package.json` (`"theme": "<name>"`) and synchronizes `<link id="bv-theme" rel="stylesheet" href="lib/themes/<name>.min.css">` in `public/index.html`.
  - `bv theme reset`: Resets theme filtering in `package.json` to compatibility mode, causing `bv build` to bundle all available themes.
  - *Safety Guard*: Requires `@blaise-themes` (installed via `bv lib install @blaise-themes`). If missing, provides immediate installation guidance.
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

### 4. `bv extension <list|install|remove|pack> [target]` (Development Tools & Extensions)
Manages built-in framework developer tooling (`packages/tools/`) and user-level custom extensions (`~/.blaisevue/tools/`):
- `bv extension list`: Inspects available extensions (`blaise-vscode`, `blaise-lazarus`, `blaise-devtools`, and custom tools) and their installation status and versions.
- `bv extension install <target>`: Installs a specific target extension:
  - `bv extension install blaise-vscode` (alias: `vscode`): Deploys the official VS Code / Antigravity IDE / Cursor extension (`~/.vscode/extensions/`, `~/.antigravity/extensions/`). After running this command, reload the window via `Ctrl + Shift + P` $\rightarrow$ `Developer: Reload Window` (or restart the IDE). Alternatively, install the pre-packaged `.vsix` manually through the Extensions UI (*Install from VSIX...*) or via terminal (`code --install-extension packages/tools/blaise-vscode/blaisevue-vscode-4.4.0.vsix`).
  - `bv extension install blaise-lazarus` (alias: `lazarus`): Compiles and validates the official Lazarus IDE package (`blaisevue_ide.lpk`) using `lazbuild`.
  - `bv extension install blaise-devtools` (alias: `devtools`): Displays step-by-step instructions for loading the DevTools panel in Mozilla Firefox (`about:debugging`) and Google Chrome (`chrome://extensions`).
  - `bv extension install <tool>`: Executes the custom installer from `~/.blaisevue/tools/<name>/install.ps1` (or `install.sh`).
- `bv extension remove <target>`: Uninstalls a specific extension (e.g. `bv extension remove blaise-vscode` or `bv extension remove <tool>`).
- `bv extension pack [target]`: Compiles and packages the extension into an installable standalone `.vsix` bundle using `@vscode/vsce`.

### 5. `bv mobile` (Hybrid Mobile Platform Android / iOS & Capacitor)
Manages the complete mobile development lifecycle using Capacitor within a unified `mobile/` architecture:
- **`bv mobile init [name] [id]`**: Scaffolds the mobile directory structure inside `mobile/` (`mobile/android/`, `mobile/ios/`, `mobile/bin/android/`, `mobile/bin/ios/`, `mobile/README.md`) and configures `capacitor.config.json`.
- **`bv mobile sync [android|ios|all]`**: Synchronizes the production build (`dist/`) with the selected native mobile platforms.
- **`bv mobile remove [-y]`**: Safely removes the `mobile/` directory, `capacitor.config.json`, and mobile binaries.
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
- **`bv desktop remove [-y]`**: Safely removes the `desktop/` directory and desktop binaries.
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
- **`bv mormot init`**: Scaffolds the Lazarus project structure (`.lpi`, `.lpr`, `ServerApp.pas`, `ServerModels.pas`) inside `server/`.
- **`bv mormot build [--release]`**: Compiles the native backend executable with Free Pascal.
  - E.g.: `bv mormot build` (Debug mode with diagnostic symbols)
  - E.g.: `bv mormot build --release` (Maximum optimization `-O3`, stripped symbols, ~1.6 MB)
- **`bv mormot run [--release] [--port <port>]`**: Launches the native mORMot 2 server (defaults to port 8090, or reads `PORT` from `.env`) with static SPA hosting and REST API. Features **Intelligent Port Fallback**: if port 8090 is in use or locked by a Windows socket, it automatically detects it and binds to the next available port (e.g. 8091).
  - Pass `--release` to automatically compile the frontend in production mode (`bv build --release`) and start the native server in optimized release mode (`-O3 -Xs`).
- **`bv mormot kill` (or `bv mormot stop`)**: Forcibly terminates any running background `server.exe` instances and releases locked ports.
- **`bv mormot status [--port <port>]`**: Queries the running server health endpoint (`/api/status`). Fast 2-second timeout prevents terminal hangs.
- **`bv mormot deploy [--zip] [--port <port>]`**: Packages the complete standalone production bundle:
  - Compiles frontend in production mode (`bv build --release`).
  - Compiles backend in release mode (`bv mormot build --release`).
  - Assembles `deploy/` with `server.exe`, `dist/`, `start.bat`, `start.sh`, and `README.txt`.
  - Optionally compresses everything into `deploy.zip` when `--zip` is passed.
  - **Zero Server Prerequisites**: No Node.js, npm, Free Pascal, or Lazarus required on the target server!

| mORMot Command | Subcommand / Flag | Action / Output |
|---|---|---|
| `bv mormot init` | - | Scaffolds native backend in `server/` |
| `bv mormot build` | - | Compiles Debug server (`server/bin/server.exe`) |
| `bv mormot build` | `--release` | Compiles optimized Release server |
| `bv mormot run` | `[--release] [--port <p>]` | Starts server (debug or release) with automatic port conflict fallback |
| `bv mormot kill` | - | Forcefully terminates running `server.exe` instances |
| `bv mormot status` | `[--port <p>]` | Queries `/api/status` health check (with 2s timeout) |
| `bv mormot deploy` | `[--port <p>]` | Creates standalone `deploy/` folder |
| `bv mormot deploy` | `--zip` | Creates standalone `deploy.zip` archive |

See detailed documentation in **[37. Full-Stack Pascal with mORMot 2](37-mormot2-backend.md)**.

### 8. `bv path` (Compiler Search Paths & Legacy Migration)
Manages Pas2JS compiler search paths (`-Fu`) in `app.cfg`, linking official built-in Pas2JS packages and mapping legacy Lazarus/Delphi codebases:
- **`bv path [list]`**: Displays all active search paths grouped by category (Core Framework, Official Pas2JS Packages, and Custom/Legacy Search Paths).
- **`bv path add <dir | pas2js:<package>>`**: Appends a new search path (`-Fu`) to `app.cfg` with automatic path normalization and duplicate prevention.
  - E.g.: `bv path add pas2js:chartjs` (Links official Chart.js bindings)
  - E.g.: `bv path add ../legacy/business_logic` (Imports legacy Lazarus/Delphi units)
- **`bv path remove <target>`**: Safely removes a search path from `app.cfg`.
- **`bv path available`**: Discovers and catalogs all 30+ pre-bundled Pas2JS packages (`vendor/pas2js/.../packages`) with real-time `[active]` status markers.

| Path Command | Arguments | Action / Output |
|---|---|---|
| `bv path` | `[list]` | Lists active compiler search paths in `app.cfg` |
| `bv path add` | `<dir | pas2js:p>` | Appends `-Fu<path>` with duplicate check & relative paths |
| `bv path remove` | `<target>` | Deletes matching search path from `app.cfg` |
| `bv path available`| - | Catalogs 30+ official Pas2JS packages with `[active]` tags |

See detailed documentation in **[53. Compiler Search Paths & Legacy Pascal Migration (bv path)](53-compiler-search-paths-and-legacy-migration.md)**.

---

## 🚀 Interactive Cockpit & Project Registry (`bv enter`, `bv use`, `bv project`)

BlaiseVue provides an interactive cockpit environment and global project registry for fast, error-free multi-project development without risk of modifying or deleting files in the wrong directory.

### 1. Enter Project Cockpit: `bv enter`
Opens the interactive cockpit shell locked to the current directory.
> [!IMPORTANT]
> **Safety Rule**: `bv enter` only executes if you are already inside a valid BlaiseVue project (`app.cfg`, `package.json`, `src/`). It refuses to run in arbitrary or non-project directories.

```bash
cd C:\Projects\my-erp
bv enter
```
**Output:**
```text
========================================================================
  [BlaiseVue Interactive Cockpit]
  Active Project: my-erp (C:\Projects\my-erp)
  Commands: new, remove, list, test, dev, build, project add, exit
========================================================================

[bv: my-erp] >
```

### 2. Register Current Project: `project add`
Inside the cockpit (or via `bv project add`), register the current project into the global registry (`~/.blaisevue/projects.json`):
```text
[bv: my-erp] > project add

  [SUCCESS] Project "my-erp" successfully registered in BlaiseVue registry!
  Path:    C:\Projects\my-erp
  Version: v1.0.0

  You can now enter this project from anywhere using:
    bv use my-erp
```

### 3. Jump to Registered Project from Anywhere: `bv use <project-name>`
From any terminal directory on the machine, jump directly into a registered project:
```bash
C:\Users\Developer> bv use my-erp
```
The CLI validates the project's existence on disk, switches directory, and opens the cockpit locked to `my-erp`:
```text
[bv: my-erp] > 
```

### 4. Project Registry Management (`bv project` / `project`)
Commands available both from the terminal and inside the interactive cockpit:
* **`project list` (or `bv project list`)**: Lists all registered projects with an active marker `(*)`:
  ```text
  Registered BlaiseVue Projects:
  ----------------------------------------------------------------------------
  * my-erp            v1.0.0    C:\Projects\my-erp
    customer-portal   v4.4.0    D:\Work\customer-portal
  ----------------------------------------------------------------------------
  Total: 2 project(s) registered (* active)
  ```
* **`project current` (or `bv project current`)**: Displays active project name, version, path, and disk health status.
* **`project remove <name>` (or `bv project remove <name>`)**: Unregisters a project from the registry (keeps project files completely intact).
* **`use <other-name>`**: Inside the cockpit, switch to another registered project on the fly without exiting the shell!

### 5. Running Commands Inside the Cockpit
Within the interactive cockpit (`[bv: <project>] > `), run commands directly without repeating `bv`:
* `new s <Name> [--no-test]` — Scaffolds pure Pascal domain service and unit test.
* `new c <Name> [--no-test]` — Scaffolds `.bv` component and test.
* `new v <Name> [--no-test]` — Scaffolds `.bv` view and test.
* `remove <c|v|s|t> <Name>` — Safely deletes element and associated tests.
* `rename <c|v|s|p> <Old> [New]` — Intelligently refactors components, views, services, or project.
* `list <c|v|s|t|lib>` — Lists components, views, services, or tests.
* `test` — Runs full test suite (Pas2JS + Vitest).
* `dev` — Builds in debug mode & starts dev server with instant HMR.
* `build [--release]` — Compiles frontend distribution (debug or `--release` with hashes).
* `preview` — Starts local HTTP preview server for `dist/`.
* `check [file]` — Validates SFC templates with AST type-checker.
* `clean` — Purges `generated/` and `dist/`.
* `update` / `upgrade` — Surgically syncs project infrastructure and Lazarus IDE files (`.lpi` / `.lpr`) with latest framework features.
* `doctor` — Diagnoses development environment (Git, Lazarus, FPC, Pas2JS, Node.js).
* `self-update` — Synchronizes and recompiles BlaiseVue engine directly from GitHub.
* `channel [use <name>]` — Inspects or switches framework branches (main / develop).
* `path [list|add|remove|available]` — Manages compiler search paths (-Fu) and official Pas2JS packages.
* `exit` / `quit` — Exits the cockpit and returns to regular shell.

> [!TIP]
> **Resilient Cockpit Shell (`Ctrl+C` Handling)**:  
> Inside the interactive cockpit (`[bv: my-app] >`), pressing `Ctrl + C` halts the currently running server or command (such as `dev` or `mormot run`) and immediately returns control to the `[bv: my-app] >` prompt without terminating your cockpit session. To quit the cockpit shell, use `exit` or `quit`.

---

## 🧹 Maintenance & Upgrades

### `bv clean`
Performs a complete purge of the build workspace:
1. Purges the `generated/` directory.
2. Purges compiled scripts in `dist/js/` and styles in `dist/css/`.
3. Resets `dist/index.html` back to the template state.

---

### `bv update` (alias: `bv upgrade`)
Surgically and non-destructively updates an existing BlaiseVue project with the latest framework runtime improvements, signal handlers, port conflict mitigation, `.env` support, runtime scripts, RTL assets, and **Lazarus IDE project files (`.lpi` / `.lpr` and `server/server.lpi`)**.

```bash
# Preview what would be updated without touching any files
bv update --dry-run

# Run the live update
bv update

# Available options
bv update --server     # Update only backend infrastructure (server.lpr, server.lpi, binary)
bv update --frontend   # Update only frontend & Lazarus IDE infrastructure (package.json, rtl.js, .lpi/.lpr)
bv update --force      # Force rebuild and re-patching even if up to date
bv update --no-backup  # Skip creating automatic backup snapshot
```

> [!IMPORTANT]
> **Zero-Risk Non-Destructive Guarantee**:  
> `bv update` **NEVER** deletes, overwrites, or modifies custom user directories or files (such as `server/kernel/`, `server/packages/`, `server/models/`, `server/controllers/`, `src/`, etc.). It only updates framework glue files (`server/server.lpr`, `server/server.lpi`, `<project>.lpi`, `<project>.lpr`, `package.json` scripts, `dist/js/rtl.js`).  
> Furthermore, an automatic snapshot is preserved in `.bv_backup/update_<timestamp>/` prior to modifying any file.

---

### `bv doctor`
Diagnoses your system environment, verifying that essential tools and bundled assets are correctly configured and accessible.

```bash
bv doctor
```

**What it verifies:**
1. **Git CLI**: Required for framework updates and channel switching.
2. **Free Pascal (FPC) & Lazarus IDE**: Automatically detects FPC either in the system PATH or bundled within standard Lazarus paths (`C:\lazarus\fpc\...` on Windows, `/usr/bin/fpc` on Linux/macOS).
3. **InstantFPC**: Automatically detects InstantFPC in system PATH or inside the Lazarus FPC directory (`instantfpc.exe`), enabling direct Pascal script execution for developer tools.
4. **Python 3**: Verifies Python in PATH, recommended for dynamic extension lifecycle scripts (`install.py`, `remove.py`, `status.py`, `pack.py`).
5. **Pas2JS (Bundled)**: Verifies the built-in Object Pascal to JavaScript transpiler in `vendor/pas2js/`.
6. **Synopse mORMot 2 (Bundled)**: Confirms presence of the embedded mORMot 2 full-stack framework in `vendor/mormot2/`.
7. **Node.js & npm**: Checks for Vitest testing suite and live development HMR support.
8. **Docker & Optional Tools**: Checks micro-container tools and Android SDK for cross-platform workflows.

---

### `bv self-update` (alias: `bv upgrade-cli`)
Updates the BlaiseVue framework engine itself directly from GitHub using Git.

```bash
# Synchronize and update framework on current branch:
bv self-update

# Check for remote updates without downloading:
bv self-update --check

# Switch to development channel:
bv self-update --channel=develop

# Switch to official stable release channel:
bv self-update --channel=main
```

**How it works under the hood:**
* Executes `git fetch origin`.
* Compares and lists modified files on GitHub with `git diff --name-only`.
* Performs `git pull`, transferring only the delta of changed files (a few KBs).
* If CLI source code (`bin/bv.pas`) was updated or branch was switched, automatically recompiles the binary:
  * **On Windows**: Recompiles `bin/bv.exe` (safely replacing the running binary).
  * **On Linux / macOS**: Recompiles `bin/bv` and applies executable permissions `chmod +x bin/bv`.

---

### `bv channel` (Git Channel Manager)
Inspects active framework branch and quickly switches between stable release channel (`main`) and development channel (`develop`).

```bash
# Display active channel, current commit, and repository status:
bv channel

# Switch to development channel:
bv channel use develop

# Switch to official stable release channel:
bv channel use main
```

---

## ⚡ CLI Performance Benchmark

Written 100% in **Native Object Pascal (FreePascal)**, the `bv.exe` CLI transpiles and orchestrates SFC components up to **50x faster** than Node.js-based alternatives, delivering instant feedback on enterprise codebases. 🛡️✨🏆
