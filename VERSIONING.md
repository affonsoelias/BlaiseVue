# 📋 BlaiseVue Versioning & Release Model

BlaiseVue adopts standard **Semantic Versioning 2.0.0 (SemVer)** combined with automated Git channel workflows (`main` / `develop`).

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
> **Current Public Pre-Release (`v0.1.x`):** BlaiseVue is in the public **`v0.1.x`** pre-release series and will **continue in `v0.1.x`** throughout all upcoming roadmap phases (including Serverless Edge / BlaiseEdge) and beyond. There is currently **no scheduled release date for `v1.0.0`**. BlaiseVue follows standard Semantic Versioning 2.0.0 (`MAJOR.MINOR.PATCH`) with `main`/`develop` Git channels.

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

## 🌿 Git Branching & Release Workflow

BlaiseVue enforces a clean separation of concerns between production stability and active development:

```
[develop]  ───●──────●───────●──────●──── (Active Integration: v0.1.x-dev)
               \                   /
                └─── [feat/...] ──┘
                                   \ (Merge / Tag)
[main]     ─────────────────────────●──── (Release Channel: v0.1.0 / v0.1.x)
                                    🏷️ v0.1.0
```

| Branch | Stability | Target Version | Purpose |
|---|---|---|---|
| **`main`** | 🟢 Release | Tagged Releases (`v0.1.0`, `v0.1.x`, ...) | Release-ready code, official releases, and release tags. |
| **`develop`** | 🟡 Active | Active Development | Integration branch for new features, community PRs, and bleeding-edge changes. |
| **`feat/*`** | 🧪 Experimental | — | Isolated feature development branched from `develop`. |
| **`fix/*`** | 🩹 Hotfix | Patch bump | Critical bugfixes targeted at `develop` (and cherry-picked to `main` if urgent). |

---

## ⚙️ Automated Versioning via BlaiseVue CLI

The BlaiseVue CLI (`bv`) features an automated SemVer and metadata synchronization suite for both the framework and user applications.

### 📦 Bumping Project Versions

You can increment project versions directly from the command line:

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

This guarantees that compile-time constants in Pascal always reflect the exact version stored in repository metadata without manual editing.

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
| **v0.1.0** | **Public Pre-Release Baseline** | Universal Pascal SPA/SSG, mORMot 2, Capacitor Mobile, Desktop WebUI, BlaiseX + Fragments, Multi-Version `bv framework`, CLI tooling, DelSafe/Zephyr *(experimental)* | 🟢 **Current Baseline** |
| **v0.1.x** | **Ongoing Pre-Release Track** | Phase A (PWA, mORMot SSR, Studio 2.0), Phase B (Micro-Frontends & Module Federation), Phase C (BlaiseEdge / `wasm32-wasi` Serverless) — **continues in `0.1.x` even after Phase C** | 🚀 **Active Roadmap (`0.1.x`)** |
| **v1.0.0** | **Future Official GA** | Long-term API freeze, full cross-platform certification, and standard SemVer 2.0.0 long-term stability guarantees | ⏳ **TBD (No Forecast Yet)** |

---

**BlaiseVue: Stability, Predictability, and Pascal Craftsmanship.** 🛡️⚡🚀
