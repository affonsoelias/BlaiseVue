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

### 5. `bv mobile` (Fase 2: Plataforma Móvel Híbrida Android / iOS & Capacitor)
Gerencia o ciclo de desenvolvimento móvel com Capacitor em estrutura unificada na pasta `mobile/`:
- **`bv mobile init [name] [id]`**: Inicializa a estrutura móvel na pasta `mobile/` (`mobile/android/`, `mobile/ios/`, `mobile/bin/android/`, `mobile/bin/ios/`, `mobile/README.md`) e gera `capacitor.config.json`.
- **`bv mobile sync [android|ios|all]`**: Sincroniza os arquivos de build de `dist/` com a plataforma móvel desejada.
- **`bv mobile build [target] [--release]`**: Compila o pacote instalável nativo (`.apk` / `.aab` / `.ipa`).
  - Ex: `bv mobile build android` (Gera `mobile/bin/android/<App>-debug.apk` via Gradle `assembleDebug`)
  - Ex: `bv mobile build android --release` (Gera `mobile/bin/android/<App>-release.apk` otimizado via `assembleRelease`)
  - Ex: `bv mobile build ios` (Prepara e sincroniza o projeto nativo iOS)
  - Ex: `bv mobile build all --release` (Compila todas as plataformas móveis em modo release)
- **`bv mobile emulator <list|start [nome]|run [nome]>`**: Gerencia e executa emuladores Android (AVD) diretamente pelo terminal.
  - Ex: `bv mobile emulator list` (Lista os emuladores instalados no Android Studio)
  - Ex: `bv mobile emulator start` (Inicia o emulador em segundo plano)
- **`bv mobile run [target] [--emulator [nome]]`**: Instala e executa diretamente no aparelho ou emulador conectado via ADB (`adb install -r` + `am start`). Se a flag `--emulator` for fornecida, inicia o emulador automaticamente se estiver desligado.
- **`bv mobile open [target]`**: Abre o projeto na IDE nativa (`open android` para Android Studio, `open ios` para Xcode no macOS).

> [!NOTE]
> **O BlaiseVue NÃO requer o Flutter instalado.** O ambiente móvel utiliza apenas o Node.js/npm, o Android Studio (Android SDK, Build-Tools e Platform-Tools `adb`) e o Java JDK 17/21.

| Comando Móvel | Plataforma | Modo | Saída / Ação |
|---|---|---|---|
| `bv mobile build android` | Android | Debug | `mobile/bin/android/<App>-debug.apk` |
| `bv mobile build android --release` | Android | Release | `mobile/bin/android/<App>-release.apk` |
| `bv mobile emulator list` | Android | - | Lista os emuladores (AVDs) instalados |
| `bv mobile emulator start` | Android | - | Inicia o emulador em segundo plano |
| `bv mobile run android` | Android | Debug | Instala e abre no dispositivo USB conectado |
| `bv mobile run android --emulator` | Android | Debug | Inicia emulador, instala e abre o app |
| `bv mobile open android` | Android | - | Abre projeto no Android Studio |
| `bv mobile open ios` | iOS | - | Abre projeto no Xcode (macOS) |

### 6. `bv desktop` (Fase 3: Plataforma Desktop Multiplataforma WebUI & Lazarus IDE)
Gerencia o ciclo de desenvolvimento desktop nativo com Free Pascal e WebUI:
- **`bv desktop init [name]`**: Gera a estrutura de projeto Lazarus (`.lpi`, `.lpr`, `webui.pas`, `uDesktopBridge.pas`, `assets/`, `bin/`, `units/`, `README.md`) na pasta `desktop/`.
- **`bv desktop sync`**: Sincroniza o build de produção (`dist/`) com os assets da aplicação desktop (`desktop/assets/`).
- **`bv desktop build [target] [--release]`**: Compila o binário nativo para uma plataforma específica (`windows`, `linux`, `macos` ou `all`). Se o alvo não for informado, usa o SO atual.
  - Ex: `bv desktop build windows` (Modo Debug no Windows com console ativo)
  - Ex: `bv desktop build linux --release` (Modo Release para Linux em `desktop/bin/linux/`)
  - Ex: `bv desktop build all --release` (Compila todas as plataformas em modo Release)
- **`bv desktop run [target] [--release]`**: Sincroniza, compila e inicializa a aplicação desktop.
  - Ex: `bv desktop run windows` (Inicia no Windows com console de logs para depuração)
  - Ex: `bv desktop run windows --release` (Inicia sem janela de console para usuário final)

| Modo Desktop | Exemplo CLI | Modo Lazarus IDE | Comportamento da Janela | Diretório de Saída |
|---|---|---|---|---|
| **Debug (Windows)** | `bv desktop run windows` | `Debug` | Janela GUI + Console de Logs | `desktop/bin/windows/` |
| **Release (Windows)** | `bv desktop run windows --release` | `Release` | Janela GUI (Sem Console) | `desktop/bin/windows/` |
| **Debug (Linux)** | `bv desktop build linux` | `Debug` | Binário ELF nativo com logs | `desktop/bin/linux/` |
| **Release (Linux)** | `bv desktop build linux --release` | `Release` | Binário ELF otimizado | `desktop/bin/linux/` |
| **All Platforms** | `bv desktop build all --release` | - | Binários para Win, Linux e Mac | `desktop/bin/<plataforma>/` |

Consulte o capítulo detalhado em **[36. Multiplatform Desktop & Lazarus IDE](36-desktop-webui.md)**.

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
