# 📋 BlaiseVue Versioning & Release Model

BlaiseVue adopts standard **Semantic Versioning 2.0.0 (SemVer)** combined with **GitHub Releases prebuilt binaries** built from the single **`main`** branch across **`stable`** and **`nightly`** channels.

---

## 🏺 The Version Format

All releases follow the standard semantic format:

$$\text{MAJOR} \,.\, \text{MINOR} \,.\, \text{PATCH} \quad (\text{e.g., } \mathbf{0.1.0} \text{ pre-release} \rightarrow \mathbf{1.0.0} \text{ stable})$$

```
     1   .   0   .   0
     ▲       ▲       ▲
     │       │       └── PATCH: Non-breaking bugfixes, security & optimizations
     │       └────────── MINOR: Backward-compatible new features & capabilities
     └────────────────── MAJOR: Architectural leaps & major platform milestones
```

> [!NOTE]
> **First Official Pre-Release (`v0.1.0`):** BlaiseVue is in the public **`v0.1.x`** pre-release series and will **continue in `v0.1.x`** throughout upcoming roadmap phases without a scheduled `v1.0.0` date yet. End-users install prebuilt binaries via `install.ps1` / `install.sh` and update directly from GitHub Releases using `bv self-update` (zero Git or Free Pascal compiler required for core CLI/SPA builds).

### 1. 🏛️ Major Version (Eras & Architectural Leaps)
Incremented when fundamental architectural evolutions occur or when breaking API changes are introduced across the framework runtime, compiler pipeline, or core interfaces (`0.x` represents public pre-release development prior to `1.0.0`).

### 2. ✨ Minor Version (New Features & Capabilities)
Incremented when new backward-compatible features, directives, components, CLI commands, or platform capabilities are introduced:

- During the **`0.1.x`** pre-release series, minor and patch iterations deliver new subsystems and refinements as the platform matures.
- Starting at **`1.0.0`**, **Minor** increments (`1.1.0`, `1.2.0`, ...) deliver backward-compatible feature additions without breaking public APIs.

### 3. 🛠️ Patch / Revision
Incremented for bugfixes, security patches, compiler edge-case resolutions, and documentation updates.
- Example: `1.0.0` $\rightarrow$ `1.0.1` (Strictly bugfixes, fully backward-compatible).

---

## 🌿 Single-Branch Release Workflow & Channels (`main`)

Following the DelSafe release architecture, BlaiseVue develops on a single **`main`** trunk and distributes ready-to-use platform archives via GitHub Releases:

```
[feat/*]  ───────●──────────┐
                            ▼
[main]    ───●───────●──────●──────────●─────► GitHub Actions Matrix Builds
                            🏷️ v0.1.0          (Windows, Linux, macOS + SHA-256)
                                │
                                ├──► Channel "stable"  (SemVer tags v*.*.*)
                                └──► Channel "nightly" (Rolling main builds)
```

| Channel | CLI Aliases | GitHub Source | Purpose |
|---|---|---|---|
| **`stable`** *(default)* | `stable`, `main` | Tagged GitHub Releases (`v0.1.0`, `v*.*.*`) | Recommended release channel for applications and production workflows. |
| **`nightly`** | `nightly`, `develop`, `dev` | Rolling `nightly` pre-release from `main` | Weekly scheduled and manual pre-release builds from the latest `main` trunk. |

### 📦 What Each Platform Archive Includes
- **Included in the release archive:** native `bv` CLI executable, `core/`, `packages/core/`, `templates/`, `vendor/zephyr/`, `package.json`, and **the matching platform's `vendor/pas2js/` compiler** — ready for `bv create`, `bv dev`, and `bv build` out of the box.
- **Fetched on demand:** `vendor/mormot2/` (`bv mormot upgrade` / `bv mormot run`) and `demo-app/` (`bv create --demo`, cached in `~/.blaisevue/cache/demo-app/`).
- **Cryptographic Verification & Atomic Rollback:** Every archive ships with `<archive>.sha256` and `SHA256SUMS.txt`. `bv self-update` verifies SHA-256 checksums, backs up `bin/bv` (`.bak`) and runtime folders (`.bv_upgrade_backup/`), and supports instant revert via `bv rollback`.

### 🔄 Channel & Update Commands
```bash
# Inspect or switch release channel (persisted in ~/.blaisevue/config.json)
bv channel
bv channel use stable          # or alias: main
bv channel use nightly         # or alias: develop

# Check or apply updates (binary releases by default; --from-source inside Git clones)
bv self-update --check
bv self-update
bv rollback                    # Restore previous binary & runtime directories
```

---

## ⚙️ Automated Versioning via BlaiseVue CLI

The BlaiseVue CLI (`bv`) features an automated SemVer and metadata synchronization suite for both the framework and user applications.

### 📦 Bumping Project Versions

```bash
# Increment patch: 0.1.0 -> 0.1.1 (Bugfix)
bv meta bump patch

# Increment minor: 0.1.1 -> 0.2.0 (New feature / dev cycle)
bv meta bump minor

# Increment major: 0.2.0 -> 1.0.0 (Official 1.0.0 milestone)
bv meta bump major
```

### 🔄 Automatic Pascal Unit Synchronization (`uAppVersion.pas`)

Whenever `bv meta bump` or `bv meta set` is executed, the CLI automatically keeps `package.json` and the Pascal source unit [`core/uAppVersion.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/core/uAppVersion.pas) in exact lockstep:

```pascal
unit uAppVersion;

{$mode objfpc}{$H+}

interface

const
  APP_NAME    = 'MyProject';
  APP_VERSION = '0.1.0';
  APP_AUTHOR  = 'Elias Affonso';
  APP_LICENSE = 'MIT';

implementation

end.
```

---

## 📦 Package Ecosystem Versioning (`bv lib`)

Third-party and official ecosystem packages (`blaise-ui`, `blaise-charts`, etc.) also adhere strictly to SemVer:

- **Distribution Archives**: Packaged with explicit SemVer suffixes: `<package>-<version>.zip` (e.g., `blaise-ui-1.2.0.zip`).
- **Version Pinning**: Users can install specific versions via the `@version` syntax:
  ```bash
  bv lib install blaise-ui@1.2.0
  bv lib install custom-repo:data-grid@2.0.1 --global
  ```
- **Auditing & Upgrades**:
  ```bash
  bv lib outdated          # Inspect installed packages against remote registries
  bv lib update blaise-ui  # Upgrade to the latest compatible release
  ```

---

## 🗺️ Framework Milestone Timeline

| Version Range | Era Name | Release Focus | Status |
|---|---|---|---|
| **v0.1.0** | **First Official Pre-Release** | Prebuilt cross-platform CLI & SDK releases (`stable`/`nightly`), Universal Pascal SPA/SSG, on-demand mORMot 2 & `demo-app`, Capacitor Mobile, Desktop WebUI, BlaiseX + Fragments, Multi-Version `bv framework`, DelSafe/Zephyr *(experimental)* | 🟢 **Current Baseline** |
| **v0.1.x** | **Ongoing Pre-Release Track** | Phase A (PWA, mORMot SSR, Studio 2.0), Phase B (Micro-Frontends & Module Federation), Phase C (BlaiseEdge / `wasm32-wasi` Serverless) — **continues in `0.1.x` even after Phase C** | 🚀 **Active Roadmap (`0.1.x`)** |
| **v1.0.0** | **Future Official GA** | Long-term API freeze, full cross-platform certification, and standard SemVer 2.0.0 long-term stability guarantees | ⏳ **TBD (No Forecast Yet)** |

---

**BlaiseVue: Stability, Predictability, and Pascal Craftsmanship.** 🛡️⚡🚀
