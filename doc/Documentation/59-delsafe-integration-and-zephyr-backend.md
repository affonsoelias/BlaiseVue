# 59. DelSafe Language Integration & Zephyr Native Backend (`--delsafe`, `bv zephyr`)

BlaiseVue integrates **DelSafe (DelSafe)** cleanly into both the reactive frontend workflow and native full-stack backend development, while keeping **Object Pascal** and **DelSafe** 100% interoperable in the same project.

---

## 1. Scaffolding an DelSafe Full-Stack Frontend (`bv create --delsafe`)

Create a new project where all `.bv` components/views use `<script lang="delsafe">` alongside an DelSafe domain module and an Object Pascal formatter consumed together:

```bash
bv create my-app --delsafe
cd my-app
```

Generated structure (clean `src/services/` layout with no extra top-level `shared/` clutter):

```text
my-app/
├── src/
│   ├── app.bv                    # Root component with <script lang="delsafe"> + router
│   ├── views/
│   │   ├── Home.bv               # <script lang="delsafe" uses="pricing, uFormatters">
│   │   └── About.bv              # <script lang="delsafe">
│   └── services/
│       ├── pricing.dels          # Native DelSafe module (calculateTotal)
│       └── uFormatters.pas       # Pure Object Pascal unit (FormatCurrency)
└── tests/
    ├── services/
    │   ├── pricing.test.dels     # Native DelSafe unit test
    │   └── Formatters.test.pas   # Pascal + Vitest unit test
    └── views/
        ├── Home.test.pas         # Verifies $149.70 rendered via DelSafe + Pascal interop
        └── About.test.pas
```

In `Home.bv`, the template computes `computeTotal(unitPrice, qty)` via DelSafe (`pricing.dels`) and formats the result through Object Pascal (`uFormatters.FormatCurrency`):

```html
<template>
  <div class="home-delsafe">
    <h2>{{ headline() }}</h2>
    <p>DelSafe + Object Pascal interop in action:</p>
    <p class="price-total">{{ FormatCurrency(computeTotal(unitPrice, qty)) }}</p>
  </div>
</template>

<script lang="delsafe" uses="pricing, uFormatters">
  data:
    unitPrice: double = 49.90;
    qty: integer = 3;

  methods:
    function headline() return String is
    begin
      return "Welcome to BlaiseVue + DelSafe";
    end headline;

    function computeTotal(p: Float64; q: Int32) return Float64 is
    begin
      return pricing.calculateTotal(p, q);
    end computeTotal;
</script>
```

---

## 2. Writing `<script lang="delsafe">` Components & Services

When transpiling `.bv` files with `<script lang="delsafe">`:
- `bv transpile` / `bv build` compiles `.dels` modules first into `.blaisevue/generated/<module>.pas` + shared runtime `uDelSafeRuntime.pas`.
- Entries in `uses="..."` are resolved automatically:
  - Matching `.dels` modules generate DelSafe `import <module>;` clauses.
  - Matching `.pas` service units in `src/services/` get thin typed wrappers automatically so reactive templates can invoke Object Pascal functions directly alongside DelSafe methods.
- Scalar return types (`Float64`, `Int32`, `Bool`, `String`) in `methods:` are mapped to typed Pascal wrappers (`Double`, `Integer`, `Boolean`, `string`), allowing direct composition in template expressions.

---

## 3. DelSafe Module Search Paths (`src/services/` & JSON Config)

By default, BlaiseVue discovers `.dels` service modules in:
1. `src/services/` (default location for application `.dels` modules)
2. `shared/` (only if created manually by the developer)

You can also configure additional search directories in either `blaisevue.json`:

```json
{
  "paths": {
    "delsafe": ["src/domain", "packages/delsafe-math"]
  }
}
```

Or inside `package.json`:

```json
{
  "blaisevue": {
    "paths": {
      "delsafe": ["extra_dels"]
    }
  }
}
```

Both `bv transpile` / `bv build`, `bv test`, and `bv zephyr` forward `paths.delsafe` directories to `delsafec` via `-I`. The same `"paths"` block also accepts `"pascal": [...]` to inject extra `-Fu<dir>` Object Pascal unit paths into `bv build`, `bv build --release`, `bv dev`, `bv test`, and `uses="..."` wrappers (see [53. Compiler Search Paths & Legacy Migration](53-compiler-search-paths-and-legacy-migration.md)).

---

## 4. DelSafe Generators (`--delsafe`) & Native `.test.dels` Runner

Pass `--delsafe` (or `-a`) to standard CLI generators:

```bash
bv g s Billing --delsafe         # Creates src/services/Billing.dels + tests/services/Billing.test.dels
bv g c MetricCard --delsafe      # Creates src/components/MetricCard.bv (<script lang="delsafe">) + test
bv g v Reports --delsafe         # Creates src/views/Reports.bv (<script lang="delsafe">) + test
bv g t QuickCheck --delsafe      # Creates tests/services/QuickCheck.test.dels
```

`bv g t <Name>` also performs Smart Detection for existing `src/services/<Name>.dels` modules even without `--delsafe`.

### Executing `bv test` with DelSafe Tests
`bv test [filter] [--no-cache|--fresh]` executes both pipelines automatically:
- `tests/**/*.test.pas` → compiled with `pas2js` and executed with Vitest + JSDOM.
- `tests/**/*.test.dels` → compiled with `delsafec --target=c` (cached incrementally in `generated/tests/.cache/`) and executed natively with dependency hash tracking across all DelSafe search paths.

---

## 5. Native High-Performance Zephyr Backend (`bv zephyr`)

**Zephyr** (`vendor/zephyr`) is BlaiseVue's native HTTP/1.1 + WebSocket server written in DelSafe. It lives in its own isolated **`server-zephyr/`** directory and defaults to port **`8091`**, allowing it to coexist side by side with `server-mormot/` (`8090`) and `server-horse/` (`9000`).

### Initialize Together with `bv create` or Independently
```bash
# Scaffold frontend + Zephyr backend in one step:
bv create my-app --backend=zephyr

# Or add Zephyr to an existing project:
bv zephyr init
```

Generated layout inside `server-zephyr/`:

```text
server-zephyr/
├── delsafe.json            # Zephyr build config (vendor/zephyr/src + local dir)
├── .env                   # PORT=8091
├── models.dels            # Domain records with [derive(JSON, Equals)] & contracts
├── zephyr_server.dels     # HTTP/WS router, dist/ SPA serving & startup banner
└── bin/
    └── zephyr_server.exe  # Native compiled binary
```

### Static SPA Hosting & SPA-Compatible OWASP Security Headers
- When `zephyr_server` starts, it automatically locates `dist/` (`--dist <dir>`, `./dist`, `../dist`, or `../../dist`), serves static assets with MIME detection (`.html`, `.js`, `.css`, `.json`, `.svg`, `.wasm`, images), and falls back to `index.html` for client-side SPA routes (while skipping `/api` and `/api/`).
- Security headers in `vendor/zephyr/src/zephyr_security.dels` include an SPA-compatible `Content-Security-Policy` allowing `script-src 'self' 'unsafe-inline' 'unsafe-eval' 'wasm-unsafe-eval'`, `style-src 'self' 'unsafe-inline'`, `connect-src 'self' ws: wss:`, and `frame-ancestors 'none'`.
- Launching `bv zephyr run` auto-builds `dist/` first if `dist/index.html` is missing and prints a clickable startup summary (`http://localhost:8091/`, `/api/health`, `/api/items`, `ws://localhost:8091/ws`).

### Zephyr CLI Reference

| Command | Flags / Options | Action / Output |
|---|---|---|
| `bv zephyr init` | - | Scaffolds isolated backend in `server-zephyr/` (port `8091`) |
| `bv zephyr build` | `[--target=c\|pascal] [--release\|--debug]` | Compiles `server-zephyr/bin/zephyr_server[.exe]` |
| `bv zephyr run` | `[--port <p>] [--target=c\|pascal]` | Auto-builds `dist/` if needed, compiles & launches server |
| `bv zephyr deploy` | `[--zip] [--port <p>] [--out <dir>]` | Builds `dist/` + release binary into `deploy/server-zephyr/` |
| `bv zephyr status` | - | Displays SDK, `delsafec`, binary, and port status |
| `bv zephyr remove` | `[-y\|--yes]` | Safely removes `server-zephyr/`, `bin/server-zephyr/`, and `deploy/server-zephyr/` |
