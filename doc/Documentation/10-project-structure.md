# 10. Project Structure

## Overview

```text
my-app/
├── app.cfg                # pas2js config (-Fusrc/services, -Fugenerated)
│
├── public/                # Static assets and index.html
│   └── index.html         # Base HTML with <div id="app">
│
├── src/                   # SOURCE CODE (application logic)
│   ├── app.bv             # Root component + SPA router configuration
│   ├── components/        # Reusable visual components (.bv)
│   │   ├── Counter.bv
│   │   └── InfoCard.bv
│   ├── views/             # Full route pages (.bv, mapped to -page tags)
│   │   ├── Home.bv
│   │   └── About.bv
│   └── services/          # Pure Pascal business logic, rules & models (.pas)
│       ├── uCalculadoraFrete.pas
│       └── uFormatters.pas
│
├── lib/                   # Component Libraries & Add-ons
│   └── blaise-ui/         # Official BlaiseUI component kit & CSS
│
├── tests/                 # 4-Tier Automated Unit & Integration Tests (Pascal + Vitest)
│   ├── components/        # Component tests (props, slots, DOM, $emit)
│   │   └── ProductCard.test.pas
│   ├── views/             # Page tests (lifecycle, validation, user flows)
│   │   ├── Home.test.pas
│   │   └── DatasetView.test.pas
│   ├── unit/              # Pure Pascal unit tests (business logic, calculations)
│   │   ├── CalculadoraFrete.test.pas
│   │   └── Formatters.test.pas
│   ├── framework/         # Internal framework verification tests
│   │   ├── reactivity.test.pas
│   │   └── dataset_offline.test.pas
│   └── setup.js           # Vitest and JSDOM global environment setup
│
├── generated/             # Generated Pascal code (DO NOT EDIT!)
│   ├── main.pas           # Application bootstrap
│   ├── uApp.pas           # app.bv → Pascal
│   ├── uHome.pas          # Home.bv → Pascal
│   └── tests/             # Compiled test bundles (*.test.js)
│
└── dist/                  # Final production bundle
    ├── index.html         # Output HTML with cache-busting hashes
    └── js/
        ├── rtl.js         # pas2js runtime
        └── main.[hash].js # Production bundle
```

---

## Folder Details

### `src/` — Application Source Code

**The heart of your project.**

- **`app.bv`**: Root component. Declares global layouts, navigation bars, application state, and SPA route definitions.
- **`components/`**: Modular, reusable UI components (e.g., buttons, cards, modals, headers). Automatically given natural kebab-case HTML tags (e.g., `<product-card>`).
- **`views/`**: Top-level page views connected to the router. Each view generates an internal `<view-name-page>` tag.
- **`services/`**: Pure Object Pascal units (`.pas`) containing calculation engines, validators, domain models, formatters, and mORMot 2 client proxies. Configured out-of-the-box in `app.cfg` via `-Fusrc/services`.

---

### `tests/` — 4-Tier Automated Testing Architecture

The BlaiseVue CLI (`bv create`) scaffolds an enterprise-ready 4-tier testing hierarchy in every new project:

1. **`tests/components/`**:
   - Automatically populated by `bv new component <Name>`.
   - Tests visual rendering, default and custom props, slots, and `$emit` event triggers using `BVTestUtils.Mount`.
2. **`tests/views/`**:
   - Automatically populated by `bv new view <Name>`.
   - Tests entire pages, user interaction flows, modal toggles, and form submissions.
3. **`tests/unit/`**:
   - Created with `bv new test <Name>` for pure business logic.
   - Tests classes, calculation engines, and service units without requiring DOM rendering.
4. **`tests/framework/`**:
   - BlaiseVue core subsystem verification (Reactivity, Routing, DataSet, RPC, Transitions).
5. **`tests/setup.js`**:
   - JSDOM polyfills, window mockups, and testing environment initialization for Vitest.

---

### `lib/` — Component Libraries & Packages

Houses local and installed packages (such as `blaise-themes`, `blaise-icons`, or `blaise-ui`). Any `.bv` files placed here are auto-discovered by the transpiler, and accompanying CSS/assets are bundled into the project.

---

### `generated/` — Transpiled Pascal & Test Artifacts

**Never edit files in this folder manually.** They are rebuilt automatically during `bv run dev`, `bv run build`, or `bv test`.
- All `.bv` files are converted into standard Object Pascal units (`u<Name>.pas`).
- During `bv test`, Pascal test suites are compiled into `generated/tests/` preserving subfolder organization (`components/`, `views/`, `unit/`, `framework/`).

---

### `dist/` — Production Distribution

Optimized output ready for web servers, Docker containers, or Electron/WebUI desktop bundling. Built using `bv run build`.

---

## Essential CLI Workflow

```bash
# 1. Create a new project (scaffolds 4-tier tests & services natively)
bv create MeuProjeto
cd MeuProjeto

# 2. Run automated test suite
bv test

# 3. Create a component with automatic test file
bv new c UserBadge

# 4. Create a route view with automatic test file
bv new v OrdersReport

# 5. Create a pure business rule unit test
bv new t TaxCalculator

# 6. Start the reactive development server with HMR
bv dev
```
