# 📋 BlaiseVue Versioning & Release Model

BlaiseVue adopts a hybrid versioning model that unites the rock-solid stability traditions of the **Lazarus IDE and Free Pascal** with modern **Semantic Versioning 2.0.0 (SemVer)** and automated Git workflows.

---

## 🏺 The Version Format

All releases follow the standard semantic format:

$$\text{MAJOR} \,.\, \text{MINOR} \,.\, \text{PATCH} \quad (\text{e.g., } \mathbf{4.4.0})$$

```
     4   .   4   .   0
     ▲       ▲       ▲
     │       │       └── PATCH: Non-breaking bugfixes, security & optimizations
     │       └────────── MINOR: Even (Stable Release) / Odd (Active Development)
     └────────────────── MAJOR: Architectural leaps & major platform milestones
```

### 1. 🏛️ Major Version (Eras & Architectural Leaps)
Incremented when fundamental architectural evolutions occur or when breaking API changes are introduced across the framework runtime, compiler pipeline, or core interfaces.

### 2. ⚖️ The Even/Odd Rule (Minor Version Parity)
Inherited from the Lazarus/FPC and Linux kernel heritage, the **Minor** version number strictly signals stability guarantees:

- **🟢 EVEN Minor Numbers (Stable Production Releases)**:
  - Examples: `1.0.x`, `2.0.x`, `3.0.x`, `4.0.x`, `4.2.x`, `4.4.x`.
  - Production-ready, thoroughly validated branches.
  - **Zero breaking changes**: only bugfixes, performance enhancements, and non-disruptive patches are backported.
  
- **🔴 ODD Minor Numbers (Active Development & Staging)**:
  - Examples: `1.1.x`, `3.1.x`, `4.1.x`, `4.3.x`, `4.5.x`.
  - Development branches on `develop`.
  - Incubate new directives, compiler features, and experimental capabilities on the road to the next stable release.

### 3. 🛠️ Patch / Revision
Incremented for bugfixes, security patches, compiler edge-case resolutions, and documentation updates.
- Example: `4.4.0` $\rightarrow$ `4.4.1` (Strictly bugfixes, fully backward-compatible).

---

## 🌿 Git Branching & Release Workflow

BlaiseVue enforces a clean separation of concerns between production stability and active development:

```
[develop]  ───●──────●───────●──────●──── (Odd Minors: v4.5.0-dev)
               \                   /
                └─── [feat/...] ──┘
                                   \ (Merge / Tag)
[main]     ─────────────────────────●──── (Even Minors: v4.4.0 / v4.4.1)
                                    🏷️ v4.4.0
```

| Branch | Stability | Target Version | Purpose |
|---|---|---|---|
| **`main`** | 🟢 Stable | Even Minors (`v4.4.x`) | Production-ready code, official releases, and signed release tags. |
| **`develop`** | 🟡 Active | Odd Minors (`v4.5.x-dev`) | Integration branch for new features, community PRs, and bleeding-edge changes. |
| **`feat/*`** | 🧪 Experimental | — | Isolated feature development branched from `develop`. |
| **`fix/*`** | 🩹 Hotfix | Patch bump | Critical bugfixes targeted at `develop` (and cherry-picked to `main` if urgent). |

---

## ⚙️ Automated Versioning via BlaiseVue CLI

Starting with **v4.4**, the BlaiseVue CLI (`bv`) features an automated SemVer and metadata synchronization suite for both the framework and user applications.

### 📦 Bumping Project Versions

You can increment project versions directly from the command line:

```bash
# Increment patch: 4.4.0 -> 4.4.1 (Bugfix)
bv meta bump patch

# Increment minor: 4.4.1 -> 4.5.0 (New feature / dev cycle)
bv meta bump minor

# Increment major: 4.5.0 -> 5.0.0 (Next architectural era)
bv meta bump major
```

### 🔄 Automatic Pascal Unit Synchronization (`uAppVersion.pas`)

Whenever `bv meta bump` or `bv meta set` is executed, the CLI automatically keeps `package.json` and the Pascal source unit [`src/uAppVersion.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/core/uAppVersion.pas) in exact lockstep:

```pascal
unit uAppVersion;

{$mode objfpc}{$H+}

interface

const
  APP_NAME    = 'MyProject';
  APP_VERSION = '4.4.0';
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
| **v1.0 - v1.2** | Genesis Era | Virtual DOM, `@click`, `b-model`, basic CLI | 📜 Legacy |
| **v2.0 - v3.5** | Foundation & Reactivity | Surgical DOM patching, mORMot 2 SSR, WebAssembly acceleration | 📜 Shipped |
| **v4.0 - v4.4** | **Enterprise Universal** | Monorepo architecture, `bv extension`, ecosystem packages, metadata suite | 🟢 **Current Stable** |
| **v5.0** | **Cloud Era** | High-density WebSockets, micro-frontends, multi-registry mesh | 🚀 Upcoming (Q3 2027) |

---

**BlaiseVue: Stability, Predictability, and Pascal Craftsmanship.** 🛡️⚡🚀
