# 56. Multi-Version SDK & Compiler Management (`bv versions`, `bv framework`, `bv pas2js`)

BlaiseVue (`v0.1.0`+) incorporates a native, cross-module **Multi-Version SDK & Compiler Management** architecture — covering **BlaiseVue itself** (`bv framework`), **Pas2JS**, **Synopse mORMot 2**, **Capacitor**, and **Horse**.

Similar to modern version managers in other ecosystems (such as `nvm` for Node, `rustup` for Rust, or `pyenv` for Python), BlaiseVue provides complete freedom to discover, download, isolate, switch, and prune multiple runtime and compiler versions per project, without breaking system stability.

---

## 🏛️ Architecture & Core Principles

```text
┌────────────────────────────────────────────────────────────────────────┐
│                      Active Project (.pas2js-version)                  │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ Resolution
         ┌──────────────────────────┴──────────────────────────┐
         ▼                                                     ▼
┌─────────────────────────────────┐   ┌──────────────────────────────────┐
│   Factory Protected Baselines   │   │     User Cached Distributions    │
│            vendor/              │   │      ~/.blaisevue/versions/      │
│  - vendor/pas2js/ (Immutable)   │   │  - pas2js/3.4.0 (GitLab main)    │
│  - vendor/mormot2/ (Immutable)  │   │  - pas2js/3.0.1 (Legacy)         │
│  (Always available offline)     │   │  - mormot/2.4-stable             │
└─────────────────────────────────┘   └──────────────────────────────────┘
```

### 1. Zero-Risk Factory Baseline Protection (`vendor/`)
BlaiseVue comes bundled with verified, stable baseline distributions of core tools in `vendor/` (such as `vendor/pas2js` and `vendor/mormot2`). 
- **Factory baselines are strictly protected**: neither `bv versions clean` nor any `remove-version` command can delete them.
- If a developer experiments with a beta compiler or third-party release and encounters an issue, running `bv <module> use bundled` instantly restores the project to the immutable baseline.

### 2. User Distribution Isolation (`~/.blaisevue/versions/`)
All dynamically downloaded versions are isolated inside the user's home directory:
- `~/.blaisevue/versions/blaisevue/<version>/` (lean sparse checkout compiled locally via FPC)
- `~/.blaisevue/versions/pas2js/<version>/`
- `~/.blaisevue/versions/mormot/<version>/`
- `~/.blaisevue/versions/capacitor/<version>/`
- `~/.blaisevue/versions/horse/<version>/` (when the `blaise-horse` tool is installed)

This guarantees that upgrading or switching versions never modifies the Git working copy or active global channel.

### 3. Project Pinning via Dotfiles (`.blaisevue-version`, `.pas2js-version`, `.mormot-version`)
Each project can declare its own pinned versions by placing simple single-line dotfiles in its root:
- `.blaisevue-version` $\rightarrow$ Pins the BlaiseVue framework CLI, SFC compiler, core runtime, and packages (e.g. `0.1.0`), or omit/`channel` to track `bv channel`.
- `.pas2js-version` $\rightarrow$ Specifies the active Pas2JS compiler (e.g. `3.4.0` or `bundled`).
- `.mormot-version` $\rightarrow$ Specifies the active mORMot 2 core.
- `.horse-version` $\rightarrow$ Specifies the active Horse framework version.

When committed to version control, these dotfiles ensure **100% reproducible builds across team members and CI/CD pipelines**.

---

## 🌐 Centralized Global Dashboard (`bv versions` / `bv sdk`)

To inspect all dependencies, baseline versions, and cached user distributions across all modules in one view, run:

```bash
bv versions
# or alias
bv sdk
```

### Example Terminal Output:

```text
=============================================================================
  BlaiseVue SDK & Multi-Version Global Dashboard
=============================================================================
  Active Project Dependencies:
    * Capacitor: 8.6.2 (@capacitor/core)
    * mORMot 2:  bundled (vendor/mormot2)
    * Pas2JS:    bundled (vendor/pas2js)
    * Horse:     (not initialized)

  Factory Protected Baselines:
    [x] vendor/mormot2  Synopse mORMot 2 Core (Immutable Baseline)
    [x] vendor/pas2js   Free Pascal Pas2JS Compiler (Immutable Baseline)

  Cached User SDK Distributions (~/.blaisevue/versions/):
    [pas2js]    3.4.0          (38.2 MB) -> C:\Users\User\.blaisevue\versions\pas2js\3.4.0
    [pas2js]    3.0.1          (32.1 MB) -> C:\Users\User\.blaisevue\versions\pas2js\3.0.1
    [mormot]    2.4-stable     (18.5 MB) -> C:\Users\User\.blaisevue\versions\mormot\2.4-stable

  Total Disk Usage: 88.8 MB
=============================================================================
  To switch version:   bv <capacitor|mormot|pas2js> use <version>
  To download version: bv <capacitor|mormot|pas2js> upgrade
  To clean versions:   bv versions clean (or bv versions remove)
=============================================================================
```

> [!NOTE]
> External co-official ecosystem tools (such as `blaise-horse`) are dynamically detected. If `blaise-horse` is installed in `~/.blaisevue/tools` or `server-horse/` exists in your project, Horse dependencies and cached versions appear automatically in the dashboard!

---

## 🧹 Interactive Disk Cleanup Wizard (`bv versions clean`)

Compilers and SDK distributions consume disk space over time. BlaiseVue provides an interactive, safe cleanup wizard:

```bash
bv versions clean
# or aliases
bv versions remove
bv versions prune
```

### Wizard Workflow:

```text
=============================================================================
  BlaiseVue SDK Multi-Version Storage Cleanup
=============================================================================
  Select cached version to remove:
    [1] [pas2js] 3.4.0 (38.2 MB)
    [2] [pas2js] 3.0.1 (32.1 MB)
    [3] [mormot] 2.4-stable (18.5 MB)
    [A] Purge ALL cached user SDK versions (88.8 MB)
    [C] Cancel
=============================================================================
Select option [1-3, A, C]: 1

Are you sure you want to permanently delete pas2js version '3.4.0'? (y/N): y
[SUCCESS] Removed C:\Users\User\.blaisevue\versions\pas2js\3.4.0 (Reclaimed 38.2 MB).
```

- **Protected Baselines**: Factory baselines in `vendor/` are never listed for deletion.
- **Active Project Safety**: If the active project is currently bound to the version being deleted, BlaiseVue warns the user and automatically falls back to `bundled`.

---

## 🚀 BlaiseVue Framework Multi-Version Manager (`bv framework`)

Similar to `fvm` for Flutter or `rustup` toolchains, **`bv framework`** lets different projects on the same machine target different versions of **BlaiseVue itself** without changing your global `bv channel` (`main`/`develop`):

1. **Lean Sparse Checkout + Local FPC Compilation (Zero Pre-Built Binaries Required)**:
   - `bv framework upgrade` queries GitHub tags via `git ls-remote --tags --refs` and performs a lean sparse checkout (`bin/`, `core/`, `packages/core/`, `templates/`, `vendor/zephyr/`), skipping heavy `vendor/pas2js`, `vendor/mormot2`, `demo-app/`, and `doc/` (~5–15 MB per cached version).
   - It then compiles `bin/bv.pas` locally into `~/.blaisevue/versions/blaisevue/<ver>/bin/bv[.exe]` using Free Pascal in a staging directory before promotion.
2. **Transparent Auto-Delegation (`BV_DELEGATED_VERSION` + `BV_HOST_SDK`)**:
   - When `.blaisevue-version` exists in a project, running `bv dev`, `bv build`, `bv test`, `bv check`, etc., automatically delegates to the pinned version's CLI, SFC transpiler, `core/`, and `packages/core/`.
   - The host passes `BV_HOST_SDK` so the cached version reuses `vendor/pas2js` and `vendor/mormot2` from your main SDK (unless overridden by `.pas2js-version` or `.mormot-version`).
   - If the pinned version is missing locally, BlaiseVue prints an actionable warning and safely falls back to your active global channel.

```bash
# 1. Inspect active channel and cached BlaiseVue versions:
bv framework versions

# 2. Discover GitHub tags and compile a version locally into cache:
bv framework upgrade
bv framework upgrade --version=0.1.0

# 3. Pin the current project to v0.1.0 (.blaisevue-version):
bv framework use 0.1.0

# 4. Unpin and follow your global channel (main/develop) again:
bv framework use channel

# 5. Remove a cached version:
bv framework remove-version 0.1.0 -y
```

> **Note (`bv channel` vs. `bv framework use channel`):** `bv channel use <main|develop>` switches your **global** SDK installation branch, whereas `bv framework use channel` configures the **current project** to track whichever global channel is active.

---

## ⚡ Pas2JS Compiler Multi-Version Manager (`bv pas2js`)

BlaiseVue compiles Single-File Components (`.bv`) into JavaScript using the official **Pas2JS** compiler. The `bv pas2js` command (alias: `bv compiler`) manages the full compiler lifecycle:

### 1. Inspect Compilers (`bv pas2js versions`)
Lists all installed compiler distributions:
```bash
bv pas2js versions
```

**Output:**
```text
  Active Compiler:
    * pas2js: C:\Users\User\Documents\BlaiseVue\vendor\pas2js\bin\pas2js.exe (bundled)
    * Version: 3.2.0 [2026/02/20] for x86_64

  Factory Protected Baseline:
    [x] vendor/pas2js (3.2.0)

  Cached User Compilers (~/.blaisevue/versions/pas2js/):
    [1] 3.4.0 (GitLab main) (38.2 MB)
    [2] 3.0.1 (Legacy)      (32.1 MB)
```

### 2. Discover & Download Compilers (`bv pas2js upgrade`)
Queries the official Free Pascal GitLab repository (`gitlab.com/freepascal.org/fpc/pas2js.git`) in real-time to fetch all available release tags:

```bash
bv pas2js upgrade
```

**Interactive Menu:**
```text
=============================================================================
  Pas2JS Compiler Upgrade & Version Manager
=============================================================================
  Select target Pas2JS compiler distribution to install:
    [1] 3.2.0 (Official Stable Release)
    [2] 3.4.0 (Development / GitLab main)
    [3] 3.0.1 (Legacy Release)
    [4] Custom version tag or repository
=============================================================================
Select option [1-4] or [C]ancel:
```

- Selecting an option clones or fetches the distribution directly from GitLab into `~/.blaisevue/versions/pas2js/<ver>/` and verifies the compiler executable and RTL units.

### 3. Switch Compiler (`bv pas2js use <version>`)
Switches the active compiler for the current project:

```bash
# Switch to user-installed development version:
bv pas2js use 3.4.0

# Switch back to immutable factory baseline:
bv pas2js use bundled
```

This writes `.pas2js-version` in the project root. When you run `bv dev` or `bv build`, BlaiseVue detects `.pas2js-version` and invokes the specified compiler binary and system RTL units.

### 4. Remove Compiler (`bv pas2js remove-version`)
Safely deletes a cached compiler from user storage:

```bash
# Interactive selection:
bv pas2js remove-version

# Direct removal:
bv pas2js remove-version 3.0.1 -y
```

---

## 🐘 Backend Multi-Version Manager (`bv mormot`)

Synopse mORMot 2 powers BlaiseVue's enterprise SOA backend. The same multi-version semantics apply:

```bash
# 1. List installed mORMot 2 versions:
bv mormot versions

# 2. Dynamically discover and download release tags from GitHub:
bv mormot upgrade

# 3. Pin project to a specific mORMot version:
bv mormot use 2.4-stable

# 4. Remove cached version:
bv mormot remove-version 2.3-stable -y
```

---

## 📱 Mobile Runtime Manager (`bv capacitor`)

For hybrid mobile applications, Capacitor runtime versions are managed via:

```bash
# 1. List installed and active Capacitor runtime versions:
bv capacitor versions

# 2. Query npm for latest release and run native Gradle migration:
bv capacitor upgrade

# 3. Interactively remove a cached Capacitor version:
bv capacitor remove-version
```

---

## 🩺 Project-Aware Diagnostics (`bv doctor`)

When collaborating across different machines or onboarding a new developer, a cloned project might declare pinned SDK versions (via `.pas2js-version`, `server/mormot.path`, or `package.json`) that are not yet downloaded in the local user cache (`~/.blaisevue/versions/`).

Running `bv doctor` inside a project root automatically cross-examines the project's dependency manifest against local disk installations:

```
[4] Active Project Alignment (my-app):
  [!] Pas2JS Compiler:      v3.4.0 requested in .pas2js-version, but NOT installed!
      -> Active fallback:   v3.2.0 (factory baseline at vendor/pas2js)
      -> Run to install:    bv pas2js upgrade --version=3.4.0
  [v] mORMot 2 Framework:   bundled (using factory baseline at vendor/mormot2)
  [v] Capacitor Mobile:     v8.5.3 (installed in node_modules, ready)

----------------------------------------------------------------------
  [!] Project Dependency Notice:
      The project specifies SDK/tool versions not cached on this machine.
      Safe factory fallback baselines are currently active to prevent build breakage.
      To align your environment with exact project pinned versions:
        * Pas2JS compiler v3.4.0 is missing -> Run: bv pas2js upgrade --version=3.4.0
----------------------------------------------------------------------
```

### Self-Healing & Factory Fallback Guarantees:
- **Builds Never Break**: If a requested SDK version is absent, BlaiseVue seamlessly engages the factory protected baseline (`vendor/pas2js` or `vendor/mormot2`), keeping compilation operational.
- **Clear Actionable Path**: `bv doctor` lists the exact one-liner commands needed to satisfy the project's pinned requirements without guesswork.
- **Outside Project Isolation**: When executed outside a project, `bv doctor` informs the developer that project alignment audits will activate as soon as it is run within any BlaiseVue project directory.

---

## 📋 Command Summary Table

| Command | Subcommand | Purpose |
|---|---|---|
| `bv versions` | - | Consolidated dashboard of all dependencies, baselines, and disk sizes |
| `bv versions` | `clean` | Interactive multi-module disk cleanup wizard |
| `bv framework` | `versions` | Lists active project pin, global channel, and cached BlaiseVue versions |
| `bv framework` | `upgrade` | Queries GitHub tags, sparsely clones sources, and compiles CLI locally via FPC |
| `bv framework` | `use <v\|channel>` | Pins BlaiseVue version (`.blaisevue-version`) or tracks active global channel |
| `bv framework` | `remove-version [v]` | Deletes a cached BlaiseVue version from user storage |
| `bv pas2js` | `versions` | Lists active compiler, factory baseline, and user-installed compilers |
| `bv pas2js` | `upgrade` | Dynamically queries GitLab and downloads a Pas2JS compiler distribution |
| `bv pas2js` | `use <v\|bundled>` | Switches active compiler for current project (`.pas2js-version`) |
| `bv pas2js` | `remove-version [v]` | Deletes a cached compiler distribution from user storage |
| `bv mormot` | `versions` | Lists active, bundled, and cached mORMot 2 versions |
| `bv mormot` | `upgrade` | Dynamically queries GitHub and downloads a mORMot 2 distribution |
| `bv mormot` | `use <v\|bundled>` | Switches active mORMot version for current project (`.mormot-version`) |
| `bv mormot` | `remove-version [v]` | Deletes a cached mORMot distribution from user storage |
| `bv capacitor` | `versions` | Displays active project and cached Capacitor runtime versions |
| `bv capacitor` | `upgrade` | Queries npm and upgrades Capacitor packages with Gradle self-healing |
| `bv capacitor` | `remove-version [v]` | Interactively deletes a cached Capacitor version |
