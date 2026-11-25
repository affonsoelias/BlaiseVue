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
│   ├── layouts/           # Master Layouts & App Shells (.bv) [Recommended Pattern]
│   │   ├── AppLayout.bv   # Sidebar + Navbar shell with <slot />
│   │   └── AuthLayout.bv  # Centered card shell for login/register
│   ├── views/             # Full route pages (.bv, mapped to -page tags)
│   │   ├── Home.bv
│   │   └── About.bv
│   └── services/          # Business logic & formatters (.pas and/or .aeth)
│       ├── pricing.aeth   # Optional Aether modules (with --aether)
│       └── uFormatters.pas
│
├── lib/                   # Component Libraries & Add-ons
│   └── blaise-ui/         # Official BlaiseUI component kit & CSS
│
├── tests/                 # 3-Tier Application Unit & Integration Tests (.test.pas & .test.aeth)
│   ├── components/        # Component tests (props, slots, DOM, $emit)
│   │   └── ProductCard.test.pas
│   ├── views/             # Page tests (lifecycle, validation, user flows)
│   │   ├── Home.test.pas
│   │   └── DatasetView.test.pas
│   ├── services/          # Domain service tests (.test.pas and .test.aeth)
│   │   ├── pricing.test.aeth
│   │   └── Formatters.test.pas
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
- **`layouts/`** *(Optional, Highly Recommended)*: Master page shells and layout templates (e.g. `AppLayout.bv`, `AuthLayout.bv`). Eliminates code duplication by encapsulating navigation bars, sidebars, headers, and footers in components using standard `<slot></slot>`.
- **`views/`**: Top-level page views connected to the router. Each view generates an internal `<view-name-page>` tag.
- **`services/`**: Object Pascal units (`u*.pas`) and optional Aether modules (`*.aeth`) containing calculation engines, validators, domain models, formatters, and mORMot 2 client proxies. Configured out-of-the-box in `app.cfg` via `-Fusrc/services` and resolved automatically for Aether imports.

---

### Backend Architecture: Isolated & Modular (`server-mormot/`, `server-zephyr/`, `server-horse/`, or Frontend-Only)

BlaiseVue gives every backend framework its own dedicated directory so you can switch or combine backends cleanly without file collisions:

1. **Frontend-Only Mode (Static SPA / Jamstack)**:
   - If you only want the reactive frontend, you do not need any backend directory.
   - Your compiled frontend (`dist/`) can be hosted on any static provider (Netlify, Vercel, S3, Nginx, Apache, Cloudflare Pages).
   - In-app communication uses the built-in `$api` (REST) and `$ws` (WebSocket) clients to consume any existing API.
   - Cleanly purge an existing backend when needed: `bv mormot remove -y`, `bv zephyr remove -y`, or `bv horse remove -y`.

2. **Enterprise Pascal Full-Stack: Synopse mORMot 2 (`server-mormot/`, Port `8090`)**:
   - The enterprise-grade Pascal backend for high throughput, WebSockets, and end-to-end type-safe Pascal RPC contracts (legacy `server/` projects remain supported automatically).
   - Initialized via `bv mormot init` (or `bv create <app> --backend=mormot`), built with `bv mormot build`, and launched via `bv mormot run`.

3. **Native Aether Full-Stack: Zephyr (`server-zephyr/`, Port `8091`)**:
   - BlaiseVue's built-in Aether HTTP/1.1 + WebSocket backend (`vendor/zephyr`), keeping its models and entry point self-contained inside `server-zephyr/` and serving `../dist` automatically.
   - Initialized via `bv zephyr init` (or `bv create <app> --backend=zephyr`), run with `bv zephyr run`, packaged with `bv zephyr deploy [--zip]`, and removed cleanly with `bv zephyr remove -y`.

4. **Alternative Microframework: Horse (`server-horse/`, Port `9000`)**:
   - Lightweight REST microframework via the external `blaise-horse` tool (`bv tool install blaise-horse`).
   - Lives in `server-horse/` and can be initialized directly during project creation with `bv create <app> --backend=horse` or afterwards with `bv horse init`.

---

### `tests/` — 3-Tier Application Testing Architecture

The BlaiseVue CLI (`bv create`) scaffolds a clean 3-tier application test hierarchy in every new project (without framework SDK clutter):

1. **`tests/components/`**:
   - Automatically populated by `bv g c <Name>`.
   - Tests visual rendering, default and custom props, slots, and `$emit` event triggers using `BVTestUtils.Mount`.
2. **`tests/views/`**:
   - Automatically populated by `bv g v <Name>`.
   - Tests entire pages, user interaction flows, modal toggles, and form submissions.
3. **`tests/services/`**:
   - Automatically populated by `bv g s <Name>` (or `--aether` for `.test.aeth`) and `bv g t <Name>` for pure business logic and services.
   - Tests Object Pascal services (`*.test.pas`) via Vitest and Aether modules (`*.test.aeth`) natively via `aetherc`.
4. **`tests/setup.js`**:
   - JSDOM polyfills, window mockups, and testing environment initialization for Vitest.

*(Framework-level SDK suites reside at the BlaiseVue SDK root `tests/` directory and run via `bv test --sdk`.)*

---

### `lib/` — Component Libraries & Packages

Houses local and installed packages (such as `blaise-themes`, `blaise-icons`, or `blaise-ui`). Any `.bv` files placed here are auto-discovered by the transpiler, and accompanying CSS/assets are bundled into the project.

---

### `generated/` — Transpiled Pascal & Test Artifacts

**Never edit files in this folder manually.** They are rebuilt automatically during `bv run dev`, `bv run build`, or `bv test`.
- All `.bv` files are converted into standard Object Pascal units (`u<Name>.pas`).
- During `bv test`, Pascal test suites are compiled into `generated/tests/` preserving subfolder organization (`components/`, `views/`, `services/`, `framework/`).

---

### `dist/` — Production Distribution

Optimized output ready for web servers, Docker containers, or Electron/WebUI desktop bundling. Built using `bv run build`.

---

## Essential CLI Workflow

```bash
# 1. Create a new project (scaffolds 4-tier tests & services natively)
bv create my-app
cd my-app

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
