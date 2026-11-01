# 🧭 53. Compiler Search Paths & Legacy Pascal Migration (`bv path`)

The `bv path` suite empowers BlaiseVue developers to inspect, link, and manage compiler unit search paths (`-Fu`) directly inside the project's [`app.cfg`](file:///c:/Users/Pichau/Documents/BlaiseVue/demo-app/app.cfg) configuration file.

This unlocks two transformative capabilities:
1. **Instant Access to Pas2JS Official Libraries**: Link any of the 30+ official packages bundled with the Pas2JS compiler distribution (`fcl-base`, `fcl-db`, `chartjs`, `jspdf`, `fpcunit`, etc.) using friendly `pas2js:<package>` shortcuts.
2. **Seamless Legacy Code Reuse & Migration**: Import existing Object Pascal business logic, data models, domain services, and algorithms from legacy **Lazarus (FPC)** or **Delphi** desktop codebases without rewriting them from scratch.

---

## 🏛️ Architecture & How It Works

During compilation (`bv run dev` or `bv build`), the Pas2JS compiler reads `@app.cfg` located in the root of your project. Each line starting with `-Fu` instructs the compiler where to look when resolving `uses` clauses:

```
┌────────────────────────────────────────────────────────┐
│                   Component (.bv)                      │
│   <script uses="uRegraTributaria, chartjs, jspdf">     │
└───────────────────────────┬────────────────────────────┘
                            │ (Compiler Unit Resolution)
                            ▼
┌────────────────────────────────────────────────────────┐
│               app.cfg Search Path Table                │
│   -Fugenerated                                         │
│   -Fusrc/services                                      │
│   -Fu../vendor/.../packages/chartjs/src                │
│   -Fu../legacy-erp/shared/domain/models                │
└────────────────────────────────────────────────────────┘
```

The `bv path` command automates all interactions with `app.cfg`, ensuring that paths are normalized, portable, relative across platforms, and strictly validated.

---

## 📋 Command Reference

### 1. `bv path [list]` (Inspect Active Search Paths)
Displays all configured search paths in `app.cfg`, neatly categorizing them:

```bash
bv path
# or
bv path list
```

**Example Output:**
```text
  BlaiseVue Compiler Search Paths (app.cfg)
  =========================================

  [Framework & Core Paths]
    - generated
    - common
    - src/services

  [Pas2JS Built-in Packages]
    - pas2js:chartjs          -> ../vendor/pas2js/.../packages/chartjs/src
    - pas2js:fcl-base         -> ../vendor/pas2js/.../packages/fcl-base/src

  [Custom & Legacy Unit Paths]
    - ../legacy-erp/models
    - src/shared/calculators
```

---

### 2. `bv path add <target>` (Link Packages & Folders)

#### A. Linking Official Pas2JS Packages (`pas2js:<name>`)
Links official built-in Pas2JS packages using portable relative search paths:

```bash
# Link Chart.js official canvas bindings:
bv path add pas2js:chartjs

# Link Base Free Component Library (Contnrs, IniFiles, CustApp):
bv path add pas2js:fcl-base

# Link Client-Side PDF Generation:
bv path add pas2js:jspdf

# Link xUnit Unit Testing Framework:
bv path add pas2js:fpcunit
```

**Output:**
```text
  [+] Search path added to app.cfg:
      -Fu../vendor/pas2js/pas2js-win64-x86_64-3.2.0/packages/chartjs/src
      Package:     pas2js:chartjs
      Description: Official Pas2JS Chart.js HTML5 canvas visualizer bindings
  Units located in this path are now accessible in uses clauses.
```

#### B. Linking Local & Legacy Lazarus / Delphi Folders
To reuse existing Pascal units from an on-disk folder:

```bash
# Relative paths:
bv path add ../meu-sistema-legado/models
bv path add ./legacy/regras-de-negocio

# Absolute paths:
bv path add C:\ProjetosLazarus\SharedUnits
```

> [!NOTE]
> The CLI physically verifies that the target directory exists on disk before modifying `app.cfg`. If the directory is invalid or missing, it safely rejects the operation with an error.

---

### 3. `bv path remove <target>` (Unlink Search Paths)
Removes a search path or Pas2JS package from `app.cfg`:

```bash
# Remove by package alias:
bv path remove pas2js:chartjs

# Remove by directory path:
bv path remove ../meu-sistema-legado/models
```

**Output:**
```text
  [-] Removed from app.cfg: -Fu../vendor/pas2js/pas2js-win64-x86_64-3.2.0/packages/chartjs/src

  [SUCCESS] Successfully removed 1 search path(s) from app.cfg.
```

---

### 4. `bv path available` (Discover Built-in Packages)
Lists all 30+ official packages bundled within your active Pas2JS installation, displaying descriptions and active indicators (`[active]`):

```bash
bv path available
# or
bv path pas2js
```

---

## 📦 Built-in Pas2JS Packages Catalog

| Package Identifier | Key Units | Description / Capabilities |
|---|---|---|
| `pas2js:chartjs` | `chartjs` | Complete HTML5 Canvas Chart.js visualization bindings |
| `pas2js:fcl-base` | `custapp`, `fpexprpars`, `browserapp` | Core FCL application and expression parsing primitives |
| `pas2js:fcl-db` | `db`, `jsondataset`, `memdataset` | Legacy TDataSet and relational field structures |
| `pas2js:fcl-json` | `fpjson`, `jsonparser` | Classical FPC JSON document parsing and serialization |
| `pas2js:fcl-rpc` | `jsonrpc`, `fclrpc` | Low-level JSON-RPC client and service wrappers |
| `pas2js:jspdf` | `jspdf` | Dynamic client-side vector PDF document creation |
| `pas2js:pdfjs` | `pdfjs` | Mozilla PDF.js canvas viewer and rasterizer |
| `pas2js:fpcunit` | `fpcunit`, `testregistry` | Standard Pascal xUnit test runner and assertions |
| `pas2js:datatables` | `datatables` | jQuery DataTables grid and pagination wrappers |
| `pas2js:flatpickr` | `flatpickr` | Lightweight modern calendar and time picker bindings |
| `pas2js:fullcalendar` | `fullcalendar` | Enterprise event calendar and timeline visualization |
| `pas2js:tinyeditor` | `tinyeditor` | Browser-based WYSIWYG rich text editor |
| `pas2js:xterm` | `xterm` | Hardware-accelerated terminal emulator for web apps |
| `pas2js:wasi` | `wasi` | WebAssembly System Interface (WASI) standard runtime |
| `pas2js:wasm-utils` | `wasmutils` | Low-level WebAssembly memory buffer & module loaders |
| `pas2js:zenfs` | `zenfs` | Cross-browser in-memory and indexedDB virtual filesystem |

---

## 🚀 Practical Guide: Migrating Legacy Lazarus/Delphi Code

Migrating legacy desktop code to BlaiseVue does **not** require rewriting business logic from scratch. Follow this 4-step modernization strategy:

### Step 1: Identify Portable Units
- ✅ **100% Portable (Zero changes required)**:
  - Mathematical calculations, financial formulas, tax algorithms.
  - String manipulation, formatters, and regular expressions.
  - Document validators (CPF/CNPJ, IBAN, email, checksums).
  - Domain entity records, typed lists, and state machines.
- ❌ **Non-Portable (Requires UI separation)**:
  - VCL/LCL visual controls (`TForm`, `TButton`, `TEdit`, `TStringGrid` from `Forms`, `Controls`, `StdCtrls`). Replace these visual controls with declarative BlaiseVue components (`.bv`).
  - Direct Win32 OS calls (`Windows.pas`, `Registry`).

### Step 2: Link the Legacy Folder
From your BlaiseVue project root:

```bash
bv path add ../legacy-erp/src/domain/calculators
```

Verify that `bv path list` shows the new path under `[Custom & Legacy Unit Paths]`.

### Step 3: Consume Legacy Units in BlaiseVue SFCs
In any component or view:

```html
<template>
  <div class="calculator-card">
    <h3>Tax Simulator (Legacy Engine)</h3>
    <bv-input v-model="subtotal" label="Subtotal ($)" type="number" />
    <bv-btn @click="calcularImposto">Calculate Tax</bv-btn>
    <p v-if="resultado > 0">Calculated Tax: <strong>${{ resultado }}</strong></p>
  </div>
</template>

<!-- Inject the legacy unit into the SFC uses clause -->
<script uses="uTaxEngine">
  data:
    subtotal: real = 1000.0;
    resultado: real = 0.0;

  methods:
    procedure calcularImposto;
    begin
      // Directly call the legacy Pascal function:
      this['resultado'] := CalculateCorporateTax(Real(this['subtotal']));
    end;
</script>
```

### Step 4: Compile & Test
Run your development server:
```bash
bv run dev
```

Pas2JS transpiles the legacy unit alongside your reactive components with zero overhead.

---

## ⚡ Cheat Sheet

```bash
# View active search paths
bv path

# Discover available Pas2JS packages
bv path available

# Link an official Pas2JS library
bv path add pas2js:chartjs
bv path add pas2js:jspdf

# Link an existing Lazarus/FPC directory
bv path add ../legacy/business-rules
bv path add C:\SharedPascal\models

# Unlink a package or folder
bv path remove pas2js:chartjs
bv path remove ../legacy/business-rules
```
