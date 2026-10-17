# 🛡️ BlaiseCLI Technical Manual (bv.exe)

The `bv.exe` is the native command-line orchestrator of BlaiseVue, responsible for transpiling SFC components, managing libraries, running tests, scaffolding projects, and serving development builds with Hot Module Replacement (HMR).

---

## 🏗️ Development and Serving Commands

### 1. `bv serve` (Development Server with Instant HMR)
Launches the integrated development server with live Hot Module Replacement:
- **HTTP Server**: Serves your application bundle locally at `http://localhost:8080`.
- **WebSocket Server**: Active at `ws://localhost:8081` to stream instant component updates.
- **File Watcher**: Monitors `src/` and `lib/` directories. On file save, re-transpiles only the affected `.bv` file and sends an in-place patch to the browser without reloading the page or losing state.

### 2. `bv run dev` (Express Development Build)
Executes a full development build with cache busting:
- **Cache Busting (`v=123...`)**: Injects timestamps into script and link tags in `index.html` to prevent stale browser caches.
- **Diagnostic DevTools**: Injects diagnostic symbols and runtime hooks for browser extensions.
- **Verbose Console Output**: Generates human-readable debug logs.

### 3. `bv run build` (Optimized Production)
Generates the production-ready distribution in `dist/`:
- **Purge Artifacts**: Removes development scaffolding, debug symbols, and experimental units.
- **Tree-Shaking & Minification**: Links only the required runtime units from Pas2JS RTL.
- **Static Assets**: Bundles and hashes scripts for long-term caching.

---

## 🏛️ Native Resource Scaffolding (`templates.res`)

In BlaiseVue 2.0, the CLI's internal architecture was completely refactored to eliminate hardcoded template strings from the Pascal source code:

1. **Templates Directory**: All initial project files reside in [`bin/templates/`](file:///c:/Users/Pichau/Documents/BlaiseVue/bin/templates/):
   - `index.html` — Base HTML entry point.
   - `app.bv` — Root component layout.
   - `Home.bv` & `Counter.bv` — Starter page and component.
   - `app.cfg` — Preconfigured Pas2JS transpiler configuration.
   - `bootstrap.css` — Base styles.
2. **Resource Embedding (`{$R templates.res}`)**:
   - Templates are compiled into a binary resource file (`templates.res`) via `windres` / FPC.
   - Embedded directly into the `bv.exe` executable at compile-time.
3. **Standalone Binary**:
   - Running `bv create <ProjectName>` extracts the templates cleanly using `TResourceStream`.
   - The compiled `bv.exe` requires zero external template files to generate new projects.

---

## 🧪 Unit Testing Arsenal (`bv test`)

BlaiseVue integrates automated testing using Pascal test specifications compiled to JavaScript and executed with **Vitest**:

### `bv test`
Transpiles all components, builds the test units in `tests/`, and executes the full suite in headless Node.js via Vitest.

### `bv new t <Name>`
Instantly scaffolds a new unit test file.
```bash
bv new t UserProfile
```
Generates `tests/UserProfile.test.pas` pre-filled with the `Describe`, `It`, and `Expect` assertions template.

### `bv list t`
Lists all unit test suites currently registered in the `tests/` folder.

### `bv remove t <Name>`
Safely removes a test file and any corresponding compiled artifacts.

---

## 📦 Library & Package Management (`/lib`)

BlaiseVue includes an integrated package manager and library system:
- **Official Package Aliases (`bv lib install <name>`)**:
  - `bv lib install themes`: Installs the 9 official Bootswatch themes and theme switcher components into `lib/themes/`.
  - `bv lib install icons`: Installs the Bootstrap Icons suite (styles + woff2 fonts) into `lib/icons/`.
  - `bv lib install ui`: Installs the official BlaiseUI component suite into `lib/blaise-ui/`.
  - `bv lib install <url>`: Downloads, extracts, and configures third-party libraries from any `.zip` URL.
- **Theme Switcher CLI (`bv theme`)**:
  - `bv theme list`: Lists all installed Bootswatch themes in `lib/themes/`.
  - `bv theme use <name>`: Updates the active project stylesheet link in `public/index.html` (e.g. `bv theme use darkly`).
- **Auto-Autoload**: Any `.bv` files within `lib/` (or subdirectories) are automatically registered as global components.
- **Auto-Asset Injection**: Non-theme `.css` and `.js` files found in `lib/` are automatically injected into `dist/index.html`.
- **Interactive Library Setup (`bv s <name>`)**: Triggers an interactive installation and configuration menu for modular libraries following the **[setup.pas standard](18-external-libraries.md)**.

---

## ⚡ Next-Gen Enterprise & Phase 1 / Phase 2 Commands

### 1. `bv doc [--serve]` (Documentador Interativo & Playground)
Analisa a AST de todos os componentes `.bv` do projeto, extraindo props, slots, eventos e comentários, e gera uma documentação interativa em `dist/docs/index.html`. Opcionalmente sobe um servidor HTTP dedicado com `--serve`.

### 2. `bv wasm <info|benchmark>` (Aceleração WebAssembly)
Gerencia os módulos WebAssembly do projeto e executa testes comparativos de desempenho entre Pascal compilado para JS versus Pascal executado em Wasm.

### 3. `bv run ssg` (Static Site Generation & Pré-renderização)
Pré-renderiza todas as rotas registradas da aplicação em arquivos HTML estáticos com suporte a hidratação reativa de zero flicker.

### 4. `bv vsix` / `bv extension [install|package]` (Fase 1: Extensão VS Code)
Empacota a extensão oficial do BlaiseVue em arquivo `.vsix` independente para o VS Code com destaque de sintaxe triplo, autocompletar inteligente e biblioteca de snippets. O comando `bv extension install` instala a extensão diretamente no editor local.

### 5. `bv mobile` (Fase 2: Plataforma Móvel Híbrida Android / iOS)
Gerencia o ciclo de desenvolvimento móvel com Capacitor:
- **`bv mobile init [name] [id]`**: Inicializa o suporte a Capacitor e gera a estrutura do projeto Android.
- **`bv mobile sync`**: Sincroniza os arquivos de build de `dist/` com a pasta de assets nativos do Android.
- **`bv mobile open`**: Abre o projeto móvel no Android Studio.
- **`bv mobile build`**: Compila o pacote nativo APK utilizando o Gradle Wrapper (`assembleDebug`).

### 6. `bv desktop` (Fase 3: Plataforma Desktop Multiplataforma WebUI & Lazarus IDE)
Gerencia o ciclo de desenvolvimento desktop nativo com Free Pascal e WebUI:
- **`bv desktop init [name]`**: Gera a estrutura de projeto Lazarus (`.lpi`, `.lpr`, `webui.pas`, `uDesktopBridge.pas`, `assets/`, `README.md`) na pasta `desktop/`.
- **`bv desktop sync`**: Sincroniza o build de produção (`dist/`) com os assets da aplicação desktop (`desktop/assets/`).
- **`bv desktop build`**: Compila o binário nativo executável (`desktop/bin/<AppName>.exe`) utilizando o compilador Free Pascal (`fpc`).
- **`bv desktop run`**: Sincroniza, compila e inicializa a aplicação desktop nativa (com suporte ao runtime WebUI ou fallback para o modo janela de aplicativo do Edge/Chrome).

---

## 🧹 Maintenance Commands

### `bv clean`
Performs a complete purge of the build workspace:
1. Purges the `generated/` directory.
2. Purges compiled scripts in `dist/js/` and styles in `dist/css/`.
3. Resets `dist/index.html` back to the template state.

---

## ⚡ CLI Performance Benchmark

Written 100% in **Native Object Pascal (FreePascal)**, the `bv.exe` CLI transpiles and orchestrates SFC components up to **50x faster** than Node.js-based alternatives, delivering instant feedback on enterprise codebases. 🛡️✨🏆
