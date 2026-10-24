# 48 - External Library Scaffolding & Release Packager

BlaiseVue provides a first-class ecosystem for creating, testing, packaging, and distributing reusable Single File Component (SFC) libraries and Object Pascal packages.

Developers can scaffold standalone library repositories with interactive licensing, test components autonomously with `bv test`, and assemble cryptographically verified distribution bundles using `bv lib pack`.

---

## 🛠️ Scaffolding a Component Library (`bv create --lib`)

To scaffold a dedicated library project, run:

```bash
bv create <library-name> --lib
```

### Interactive License Selector

During scaffolding, the CLI prompts the developer to select an appropriate license:

```text
Select license for library "my-ui-kit":
  1) MIT (Permissive, recommended for open-source community packages)
  2) Apache 2.0 (Permissive with patent grant protection)
  3) GNU LGPL v3 (Traditional Pascal library copyleft standard)
  4) Commercial / Proprietary (All rights reserved)
  5) None
Enter choice [1-5] (default 1):
```

### Non-Interactive / CI Usage (`--license`)

For automated pipelines or headless environments, specify the license directly via `--license`:

```bash
# Permissive MIT
bv create my-ui-kit --lib --license mit

# Apache 2.0 with patent protection
bv create enterprise-grid --lib --license apache

# LGPL v3 copyleft standard
bv create pascal-charts --lib --license lgpl

# Commercial proprietary license
bv create pro-widgets --lib --license commercial
```

---

## 📂 Standard Library Architecture

When scaffolded, the library features an isolated, modular architecture:

```text
my-ui-kit/
├── demo/                   # Interactive component playground
│   ├── app.bv             # Playground root component
│   └── index.html         # Local development preview
├── dist/                  # Packaged distribution bundles (.zip)
├── src/                   # Reusable library source code
│   ├── MyUiKit.bv         # Single File Component (<template>, <script>, <style>)
│   └── MyUiKit.pas        # Companion Object Pascal unit & configuration
├── styles/                # Standalone CSS stylesheets
│   └── my-ui-kit.css      # Component style definitions
├── tests/                 # Autonomous unit & component test suite
│   └── my-ui-kit.test.pas # Vitest-compatible automated tests
├── LICENSE                # Complete license text based on chosen license
├── package.json           # Machine-readable package metadata
└── README.md              # Documentation with installation & API guides
```

### `package.json` Specification

The generated `package.json` adheres to standard package specifications:

```json
{
  "name": "my-ui-kit",
  "version": "1.0.0",
  "description": "BlaiseVue component library: my-ui-kit",
  "main": "src/MyUiKit.bv",
  "style": "styles/my-ui-kit.css",
  "license": "MIT",
  "blaisevue": {
    "type": "library"
  },
  "scripts": {
    "dev": "bv run dev",
    "test": "bv test",
    "pack": "bv lib pack"
  }
}
```

---

## 🧪 Local Development & Autonomous Testing

Inside the library folder, you can run the interactive development playground and test suite without any external tools:

```bash
# Launch interactive playground with live HMR
bv run dev

# Execute autonomous unit tests
bv test
```

---

## 📦 Automated Release Packager (`bv lib pack` / `bv lib dist`)

To prepare a production release for the community or internal enterprise registries, run:

```bash
bv lib pack
```

*(Note: `bv lib dist` is an identical alias).*

### Packaging Workflow

1. **Pre-flight Automated Testing**:
   Automatically runs `bv test` before packaging. If any test fails, packaging is aborted immediately to prevent distributing defective software.
   *(Pass `--skip-tests` or `-s` to bypass verification if needed).*

2. **Clean Production Filtering**:
   Packages only essential distributable files:
   - `package.json`
   - `README.md`
   - `LICENSE`
   - `setup.pas` (if present)
   - `src/` (all `.bv` and `.pas` files)
   - `styles/` (all `.css` files)

   **Excluded automatically**: internal `demo/`, `tests/`, `.git/`, `dist/`, `node_modules/`, and Free Pascal compiler caches (`.o`, `.ppu`, `.tmp`).

3. **Cryptographic SHA-256 Verification**:
   Computes the SHA-256 hash using the native pure-Pascal RFC 6234 cryptographic engine and writes a standard checksum file (`dist/<name>-<version>.zip.sha256`).

### Packager Output Example

```text
=== [Pre-flight] Running Automated Tests for my-ui-kit ===
[+] Pre-flight tests passed successfully!

Assembling release artifact: my-ui-kit-1.0.0.zip ...

============================================================
  📦 BlaiseVue Library Packager
============================================================
  Package:     my-ui-kit @ v1.0.0
  Archive:     dist/my-ui-kit-1.0.0.zip
  Size:        3.51 KB
  SHA-256:     28688ccd19a444f8b066fd09f19de17da07d043565eee4c1b4a14af6900f9939
  Checksum:    dist/my-ui-kit-1.0.0.zip.sha256
============================================================
🎉 Package successfully assembled and verified!

Installation commands for consumers:
  bv lib install https://github.com/<org>/my-ui-kit/releases/download/v1.0.0/my-ui-kit-1.0.0.zip
  bv lib install ./dist/my-ui-kit-1.0.0.zip
```

---

## 📥 Consumer Installation (`bv lib install`)

Any consumer project can install and register your package with a single command:

### Remote GitHub / HTTP Release

```bash
bv lib install https://github.com/company/my-ui-kit/releases/latest/download/my-ui-kit-1.0.0.zip
```

### Local / Offline File System Archive

For air-gapped environments or private local monorepos:

```bash
bv lib install ./path/to/my-ui-kit-1.0.0.zip
```

The CLI automatically unpacks the library into the consumer project's `/lib/my-ui-kit` folder, runs any optional `setup.pas` configuration scripts, and makes all components instantly available throughout the application.

---

## 🧪 Automated Packager Test Coverage

Automated tests validating library scaffolding, metadata integrity, file filtering, and checksum formatting are located in `demo-app/tests/framework/lib_packager.test.pas`:

```bash
bv test
```
