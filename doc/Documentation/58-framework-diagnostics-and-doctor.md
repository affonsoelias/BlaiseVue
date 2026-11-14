# 🩺 58. Framework & Project Diagnostics (`bv doctor`)

The **BlaiseVue Doctor** (`bv doctor`) is the platform's automated diagnostics, environment validation, and project alignment engine. Inspired by the diagnostic reliability of tools like `flutter doctor` and `cargo verify-project`, `bv doctor` provides end-to-end visibility into host system tooling, compilers, runtimes, and active project dependencies.

Whether onboarding a new team member, verifying a Continuous Integration (CI) runner, or auditing a cloned repository with custom pinned SDK versions, `bv doctor` diagnoses potential bottlenecks and provides actionable one-line resolution commands.

---

## 🎯 Architecture & Dual Diagnostic Scope

`bv doctor` operates with an intelligent **dual-scope detection mechanism**:

```
                       ┌─────────────────────────┐
                       │      bv doctor          │
                       └────────────┬────────────┘
                                    │
               ┌────────────────────┴────────────────────┐
               ▼                                         ▼
   [System Environment Scope]                [Project Alignment Scope]
   • Git CLI                                 • .pas2js-version audit
   • Free Pascal (FPC)                       • server/mormot.path audit
   • InstantFPC Scripting                    • package.json & node_modules
   • Lazarus IDE                             • server-horse/ & blaise-horse
   • Python 3 Engine                         • Factory Fallback status
   • Node.js & npm (Vitest)                  • Actionable Dependency Notice
   • Docker Container CLI
   • Java JDK (17/21 LTS)
   • Android SDK, ADB & AVDs
   • Capacitor CLI / Runtime
```

1. **System Environment Scope (Global)**: When run from anywhere on the machine, `bv doctor` inspects your host operating system, searching system `PATH` and standard installation directories for compilers, SDKs, and developer tooling.
2. **Project Alignment Scope (Contextual)**: When executed inside any BlaiseVue project (or subfolder), `bv doctor` crawls upward to find the project root and cross-examines the project's dependency manifests against cached distributions in `~/.blaisevue/versions/`.

---

## 🔬 The 4 Diagnostic Layers

### [1] Core Framework Tooling
Validates the fundamental compilers and libraries required to build full-stack Pascal applications:

- **Git CLI**: Required for automated framework self-updates (`bv self-update`), branch switching (`bv channel`), and package repository sync (`bv repo sync`).
- **Free Pascal (FPC)**: Verifies the native Pascal compiler. Automatically resolves FPC from the system `PATH` or standard Lazarus IDE paths (`C:\lazarus\fpc\...` on Windows, `/usr/bin/fpc` on Linux/macOS).
- **InstantFPC**: Inspects whether the InstantFPC script engine is available. InstantFPC enables running developer tools written in pure Pascal as lightweight, standalone scripts.
- **Lazarus IDE**: Detects Lazarus IDE installation (`lazarus.exe` / `lazbuild`) for visual Desktop GUI design and F9 rapid prototyping.
- **Pas2JS (Bundled)**: Validates the presence and integrity of the factory-shipped Object Pascal-to-JavaScript transpiler in `vendor/pas2js/`.
- **Synopse mORMot 2 (Bundled)**: Confirms the presence of the immutable core backend framework in `vendor/mormot2/`.

### [2] Ecosystem & Testing Tools
Audits developer extension runtimes and test suites:

- **Python 3**: Verifies a modern Python 3 interpreter in `PATH`. Python powers the lifecycle automation hooks (`install.py`, `run.py`, `update.py`, `remove.py`) used by dynamic `bv tool` packages.
- **Node.js & npm**: Checks for Node.js and npm, which drive Vitest unit testing (`bv test`), component playgrounds (`bv doc`), and Vite-powered Hot Module Replacement (HMR).
- **Docker CLI**: Verifies Docker availability for generating and compiling ultra-lightweight (<20MB) Alpine Linux micro-containers (`bv mormot docker`).
- **Developer Tools**: Reports the total count of active developer extensions, differentiating between built-in tools and custom user tools in `~/.blaisevue/tools`.

### [3] Mobile & Cross-Platform Tooling
Validates the complete Android native compilation stack:

- **Java Runtime (JDK)**: Inspects `JAVA_HOME` and system Java. BlaiseVue enforces **Java 17 or 21 LTS** compatibility, warning developers if incompatible versions (Java 8, 11, or 22+) are active, which cause modern Android Gradle 8.x builds to fail.
- **Android SDK**: Automatically detects the Android SDK in `ANDROID_HOME`, `ANDROID_SDK_ROOT`, or standard paths (`%LOCALAPPDATA%\Android\Sdk` on Windows, `~/Android/Sdk` on Linux/macOS).
- **Android Debug Bridge (ADB)**: Confirms ADB availability for direct USB device deployment (`bv capacitor run android`).
- **Android Emulator & AVDs**: Queries emulator status and enumerates all configured Android Virtual Devices (AVDs).
- **Capacitor CLI & Runtime**: Detects whether Capacitor is installed globally or locally, identifying modern v8 LTS installations versus legacy v7 or v6 versions.

### [4] Active Project Alignment (Contextual Audit)
When run inside an active project, `bv doctor` performs a deep dependency reconciliation:

```
[4] Active Project Alignment (demo-app):
  [v] Pas2JS Compiler:      v3.2.0 (using factory baseline at vendor/pas2js)
  [v] mORMot 2 Framework:   bundled (using factory baseline at vendor/mormot2)
  [v] Capacitor Mobile:     v8.5.3 (installed in node_modules, ready)
```

- **Pas2JS Compiler**: Inspects `.pas2js-version`. If a pinned version (e.g., `3.4.0`) is configured:
  - If installed in `~/.blaisevue/versions/pas2js/3.4.0`: Marked `[v]`.
  - If missing locally: Marked `[!]`, activates the safe factory fallback (`vendor/pas2js`), and suggests `bv pas2js upgrade --version=<v>`.
- **mORMot 2 Framework**: If `server/` exists, inspects `server/mormot.path` or `.mormot-version`:
  - If set to `bundled` or default: Verified against `vendor/mormot2`.
  - If set to a specific tag (e.g., `2.4-stable`): Checks `~/.blaisevue/versions/mormot/`. If missing, safely engages the factory baseline.
- **Capacitor Mobile**: If `mobile/` or `capacitor.config.json` is present:
  - Verifies that `@capacitor/core` declared in `package.json` is physically installed in `node_modules/@capacitor/core`.
  - If absent, alerts the developer to run `npm install`.
- **Alternative Backend (Horse)**: If `server-horse/` exists:
  - Checks if the official `blaise-horse` developer tool is installed. If absent, prompts `bv tool install blaise-horse`.

---

## 🛡️ Factory Protection & Safe Fallbacks

A central tenet of the BlaiseVue architecture is **Zero Build Breakage**.

When a developer clones an existing BlaiseVue repository on a new machine that does not yet possess the project's pinned compiler or backend versions:

```
                       ┌─────────────────────────────────────┐
                       │ Project Pins: Pas2JS 3.4.0          │
                       │               mORMot 2.4-stable     │
                       └──────────────────┬──────────────────┘
                                          │
                                   Does cache exist?
                                          │
                        ┌─────────────────┴─────────────────┐
                       YES                                  NO
                        │                                   │
              ┌─────────┴─────────┐               ┌─────────┴─────────┐
              │ Run Pinned User   │               │ Engage Protected  │
              │ Cache Version     │               │ Factory Baselines │
              │ (~/.blaisevue/)   │               │ (vendor/pas2js)   │
              └───────────────────┘               │ (vendor/mormot2)  │
                                                  └─────────┬─────────┘
                                                            │
                                                  ┌─────────┴─────────┐
                                                  │ Log Notice in     │
                                                  │ bv doctor         │
                                                  └───────────────────┘
```

1. **Fallback Baselines Engage Immediately**: Compilation does not fail. BlaiseVue automatically redirects compilation to the immutable factory baselines in `vendor/pas2js` and `vendor/mormot2`.
2. **Clear Diagnostics**: `bv doctor` marks the item with `[!]` and informs the developer that the project is running on fallback mode.
3. **Automated Remediation**: The exact one-liner commands to achieve full parity are printed in the summary.

---

## 📋 The Project Dependency Notice Banner

If `bv doctor` identifies missing pinned versions or uninstalled packages in an active project, it displays a high-visibility summary banner at the bottom of the diagnostic report:

```
----------------------------------------------------------------------
  [!] Project Dependency Notice:
      The project specifies SDK/tool versions not cached on this machine.
      Safe factory fallback baselines are currently active to prevent build breakage.
      To align your environment with exact project pinned versions:
        * Pas2JS compiler v3.4.0 is missing -> Run: bv pas2js upgrade --version=3.4.0
        * Capacitor packages missing in node_modules -> Run: npm install
----------------------------------------------------------------------

======================================================================
  [!] Diagnostics complete: Environment is healthy, but project has missing pinned versions.
      Safe factory fallback baselines are currently active.
======================================================================
```

Developers can copy and paste the suggested commands directly into their terminal to download the missing versions.

---

## 🚀 CI/CD Pipelines & Automation

`bv doctor` is optimized for automated integration environments such as **GitHub Actions**, **GitLab CI**, and **Docker build stages**.

### Example: GitHub Actions Workflow Verification

```yaml
name: BlaiseVue CI Verification

on: [push, pull_request]

jobs:
  diagnose-and-test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Setup Free Pascal Compiler
        uses: gcarreno/setup-fpc@v1
        with:
          fpc-version: '3.2.2'

      - name: Setup Node.js & npm
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Run BlaiseVue Doctor
        run: |
          ./bin/bv doctor

      - name: Compile and Test
        run: |
          ./bin/bv build --release
          npm test
```

---

## 🔧 Troubleshooting & Common Diagnostic Flags

| Flag / Symbol | Meaning | Action Recommended |
|---|---|---|
| `[v]` | **Healthy / Verified** | Component or SDK is present, validated, and ready for use. |
| `[!]` | **Warning / Fallback Active** | Optional tool missing, non-LTS Java version detected, or project pinned version absent (running on safe factory fallback). |
| `[-]` | **Neutral / Inactive** | Module not initialized in project (e.g., project does not have `mobile/` or `server/`). |
| `[X]` | **Critical Error** | Mandatory core component missing (e.g., FPC not found). Prevents native compilation. |

### Common Diagnostic Solutions:

#### 1. Free Pascal (FPC) Not Detected (`[X]`)
- **Cause**: FPC is not added to system `PATH` and Lazarus is not in standard paths.
- **Solution (Windows)**: Install Lazarus IDE to `C:\lazarus`, or add `C:\lazarus\fpc\<version>\bin\x86_64-win64` to your user `PATH`.
- **Solution (Linux/macOS)**: Run `sudo apt-get install fpc fpc-source lazarus` or `brew install fpc`.

#### 2. Java Runtime Version Incompatibility (`[!]`)
- **Cause**: Android Gradle 8.x requires Java 17 or 21 LTS. Older versions (Java 8/11) or bleeding-edge versions (Java 22+) trigger compilation failures in Gradle.
- **Solution**: Install Eclipse Temurin 17 or 21 LTS (`winget install EclipseAdoptium.Temurin.17.JDK` on Windows, or `sudo apt install openjdk-17-jdk` on Linux).

#### 3. Capacitor Packages Missing in `node_modules` (`[!]`)
- **Cause**: Project was newly cloned, but `npm install` has not yet been executed.
- **Solution**: Run `npm install` in the project root.

#### 4. Missing Pinned Pas2JS Compiler (`[!]`)
- **Cause**: Project contains `.pas2js-version` with a version not cached in `~/.blaisevue/versions/pas2js/`.
- **Solution**: Run `bv pas2js upgrade --version=<version>`.
