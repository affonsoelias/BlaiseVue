# 59. Aether Language Integration & Zephyr Native Backend (`--aether`, `bv zephyr`)

BlaiseVue integrates **AetherLang (Aether)** cleanly into both the reactive frontend workflow and native full-stack backend development, while keeping **Object Pascal** and **Aether** 100% interoperable in the same project.

---

## 1. Scaffolding an Aether Full-Stack Frontend (`bv create --aether`)

Create a new project where all `.bv` components/views use `<script lang="aether">` alongside an Aether domain module and an Object Pascal formatter consumed together:

```bash
bv create my-app --aether
cd my-app
```

Generated structure (clean `src/services/` layout with no extra top-level `shared/` clutter):

```text
my-app/
├── src/
│   ├── app.bv                    # Root component with <script lang="aether"> + router
│   ├── views/
│   │   ├── Home.bv               # <script lang="aether" uses="pricing, uFormatters">
│   │   └── About.bv              # <script lang="aether">
│   └── services/
│       ├── pricing.aeth          # Native Aether module (calculateTotal)
│       └── uFormatters.pas       # Pure Object Pascal unit (FormatCurrency)
└── tests/
    ├── services/
    │   ├── pricing.test.aeth     # Native Aether unit test
    │   └── Formatters.test.pas   # Pascal + Vitest unit test
    └── views/
        ├── Home.test.pas         # Verifies $149.70 rendered via Aether + Pascal interop
        └── About.test.pas
```

In `Home.bv`, the template computes `computeTotal(unitPrice, qty)` via Aether (`pricing.aeth`) and formats the result through Object Pascal (`uFormatters.FormatCurrency`):

```html
<template>
  <div class="home-aether">
    <h2>{{ headline() }}</h2>
    <p>Aether + Object Pascal interop in action:</p>
    <p class="price-total">{{ FormatCurrency(computeTotal(unitPrice, qty)) }}</p>
  </div>
</template>

<script lang="aether" uses="pricing, uFormatters">
  data:
    unitPrice: double = 49.90;
    qty: integer = 3;

  methods:
    function headline() return String is
    begin
      return "Welcome to BlaiseVue + Aether";
    end headline;

    function computeTotal(p: Float64; q: Int32) return Float64 is
    begin
      return pricing.calculateTotal(p, q);
    end computeTotal;
</script>
```

---

## 2. Writing `<script lang="aether">` Components & Services

When transpiling `.bv` files with `<script lang="aether">`:
- `bv transpile` / `bv build` compiles `.aeth` modules first into `.blaisevue/generated/<module>.pas` + shared runtime `uAetherRuntime.pas`.
- Entries in `uses="..."` are resolved automatically:
  - Matching `.aeth` modules generate Aether `import <module>;` clauses.
  - Matching `.pas` service units in `src/services/` get thin typed wrappers automatically so reactive templates can invoke Object Pascal functions directly alongside Aether methods.
- Scalar return types (`Float64`, `Int32`, `Bool`, `String`) in `methods:` are mapped to typed Pascal wrappers (`Double`, `Integer`, `Boolean`, `string`), allowing direct composition in template expressions.

---

## 3. Aether Module Search Paths (`src/services/` & JSON Config)

By default, BlaiseVue discovers `.aeth` service modules in:
1. `src/services/` (default location for application `.aeth` modules)
2. `shared/` (only if created manually by the developer)

You can also configure additional search directories in either `blaisevue.json`:

```json
{
  "paths": {
    "aether": ["src/domain", "packages/aether-math"]
  }
}
```

Or inside `package.json`:

```json
{
  "blaisevue": {
    "paths": {
      "aether": ["extra_aeth"]
    }
  }
}
```

Both `bv transpile` / `bv build`, `bv test`, and `bv zephyr` forward `paths.aether` directories to `aetherc` via `-I`. The same `"paths"` block also accepts `"pascal": [...]` to inject extra `-Fu<dir>` Object Pascal unit paths into `bv build`, `bv build --release`, `bv dev`, `bv test`, and `uses="..."` wrappers (see [53. Compiler Search Paths & Legacy Migration](53-compiler-search-paths-and-legacy-migration.md)).

---

## 4. Aether Generators (`--aether`) & Native `.test.aeth` Runner

Pass `--aether` (or `-a`) to standard CLI generators:

```bash
bv g s Billing --aether         # Creates src/services/Billing.aeth + tests/services/Billing.test.aeth
bv g c MetricCard --aether      # Creates src/components/MetricCard.bv (<script lang="aether">) + test
bv g v Reports --aether         # Creates src/views/Reports.bv (<script lang="aether">) + test
bv g t QuickCheck --aether      # Creates tests/services/QuickCheck.test.aeth
```

`bv g t <Name>` also performs Smart Detection for existing `src/services/<Name>.aeth` modules even without `--aether`.

### Executing `bv test` with Aether Tests
`bv test [filter] [--no-cache|--fresh]` executes both pipelines automatically:
- `tests/**/*.test.pas` → compiled with `pas2js` and executed with Vitest + JSDOM.
- `tests/**/*.test.aeth` → compiled with `aetherc --target=c` (cached incrementally in `generated/tests/.cache/`) and executed natively with dependency hash tracking across all Aether search paths.

---

## 5. Native High-Performance Zephyr Backend (`bv zephyr`)

**Zephyr** (`vendor/zephyr`) is BlaiseVue's native HTTP/1.1 + WebSocket server written in Aether. It lives in its own isolated **`server-zephyr/`** directory and defaults to port **`8091`**, allowing it to coexist side by side with `server-mormot/` (`8090`) and `server-horse/` (`9000`).

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
├── aether.json            # Zephyr build config (vendor/zephyr/src + local dir)
├── .env                   # PORT=8091
├── models.aeth            # Domain records with [derive(JSON, Equals)] & contracts
├── zephyr_server.aeth     # HTTP/WS router, dist/ SPA serving & startup banner
└── bin/
    └── zephyr_server.exe  # Native compiled binary
```

### Static SPA Hosting & SPA-Compatible OWASP Security Headers
- When `zephyr_server` starts, it automatically locates `dist/` (`--dist <dir>`, `./dist`, `../dist`, or `../../dist`), serves static assets with MIME detection (`.html`, `.js`, `.css`, `.json`, `.svg`, `.wasm`, images), and falls back to `index.html` for client-side SPA routes (while skipping `/api` and `/api/`).
- Security headers in `vendor/zephyr/src/zephyr_security.aeth` include an SPA-compatible `Content-Security-Policy` allowing `script-src 'self' 'unsafe-inline' 'unsafe-eval' 'wasm-unsafe-eval'`, `style-src 'self' 'unsafe-inline'`, `connect-src 'self' ws: wss:`, and `frame-ancestors 'none'`.
- Launching `bv zephyr run` auto-builds `dist/` first if `dist/index.html` is missing and prints a clickable startup summary (`http://localhost:8091/`, `/api/health`, `/api/items`, `ws://localhost:8091/ws`).

### Zephyr CLI Reference

| Command | Flags / Options | Action / Output |
|---|---|---|
| `bv zephyr init` | - | Scaffolds isolated backend in `server-zephyr/` (port `8091`) |
| `bv zephyr build` | `[--target=c\|pascal] [--release\|--debug]` | Compiles `server-zephyr/bin/zephyr_server[.exe]` |
| `bv zephyr run` | `[--port <p>] [--target=c\|pascal]` | Auto-builds `dist/` if needed, compiles & launches server |
| `bv zephyr deploy` | `[--zip] [--port <p>] [--out <dir>]` | Builds `dist/` + release binary into `deploy/server-zephyr/` |
| `bv zephyr status` | - | Displays SDK, `aetherc`, binary, and port status |
| `bv zephyr remove` | `[-y\|--yes]` | Safely removes `server-zephyr/`, `bin/server-zephyr/`, and `deploy/server-zephyr/` |
