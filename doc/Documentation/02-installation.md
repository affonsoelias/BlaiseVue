# 2. Installation

## Prerequisites

1. **FPC** (3.2.2+): Free Pascal Compiler
   - Required to compile the native BlaiseVue CLI (`bv` / `bv.exe`) and desktop applications.
   - Usually installed along with Lazarus IDE or standalone from: https://www.freepascal.org

2. **pas2js** (3.2.0+): Pascal → JavaScript Transpiler
   - Transpiles your Object Pascal Single File Components into optimized JavaScript.
   - Download: https://wiki.freepascal.org/pas2js or https://getpas2js.freepascal.org

3. **Node.js** (v18+ LTS) & **npm**:
   - Powers the development server with Hot Module Replacement (HMR) on port `8080` & WebSocket `8081` (`bv serve`).
   - Serves local production previews and interactive documentation (`bv run preview`, `bv doc --serve`).
   - Manages mobile scaffolding and synchronization via Capacitor (`bv mobile init`, `bv mobile sync`).
   - Executes unit and end-to-end test suites (`bv test`, `bv test e2e` via Vitest).
   - Packages the official VS Code extension (`bv vsix` via `@vscode/vsce`).
   - Download: https://nodejs.org (LTS version recommended). Must be accessible in your system PATH.

## 🛠️ Step 1: Building the BlaiseVue CLI

The BlaiseVue CLI is written in pure Object Pascal. You must compile it once to generate the `bv` (or `bv.exe`) executable.

1. Open your terminal in the `bin/` directory.
2. Run the Free Pascal Compiler:
   ```bash
   fpc bv.pas
   ```
3. Move the generated `bv` (Windows: `bv.exe`) to your project root or add the `bin/` folder to your System PATH.

---

## ⚙️ Step 2: Setting up Pas2JS (Multi-platform)

BlaiseVue bundles the `pas2js` transpiler inside `vendor/pas2js/` to convert your Pascal code to optimized JavaScript. To support multiple operating systems, the framework organizes binaries under `vendor/pas2js/` (with fallback to `pas2js/` in the root).

### 📥 Download (Optional if not bundled)
Visit [getpas2js.freepascal.org](https://getpas2js.freepascal.org) and download the latest **3.2.0** version for your system:
- **Windows**: `pas2js-win64-x86_64-3.2.0.zip`
- **Linux**: `pas2js-linux-x86_64-3.2.0.tar.gz`
- **macOS**: `pas2js-darwin-x86_64-3.2.0.zip`

### 📂 Directory Structure
The vendor directory structure is organized as follows:

```text
/BlaiseVue
├── bin/          <-- CLI source & executable
├── core/         <-- Framework core
├── vendor/       <-- Embedded third-party engines
│   ├── pas2js/   <-- Multi-platform pas2js binaries & RTL
│   │   ├── pas2js-win64-x86_64-3.2.0/
│   │   ├── pas2js-linux-x86_64-3.2.0/
│   │   └── pas2js-darwin-x86_64-3.2.0/
│   └── mormot2/  <-- Synopse mORMot 2.4 framework
├── bv.exe        <-- Compiled CLI
└── README.md
```

The CLI will automatically detect your OS and use the corresponding folder inside `vendor/pas2js/`.

## Installing BlaiseVue

### 1. SDK Structure

```
BlaiseVue/
├── bin/
│   └── bv.exe       # Framework CLI
├── core/            # Pascal runtime modules
│   ├── BlaiseVue.pas
│   ├── BVCompiler.pas
│   ├── BVComponents.pas
│   ├── BVData.pas
│   ├── BVDirectives.pas
│   ├── BVReactivity.pas
│   └── BVRouting.pas
└── rtl.js           # pas2js JavaScript runtime
```

### 2. Add to PATH

Add the BlaiseVue `bin/` folder to the system PATH:

**Windows (PowerShell as admin):**
```powershell
$path = [Environment]::GetEnvironmentVariable("Path", "User")
$newPath = "$path;C:\path\to\BlaiseVue\bin"
[Environment]::SetEnvironmentVariable("Path", $newPath, "User")
```

### 3. Verify

Restart the terminal and run:
```bash
bv
```

Expected output:
```
BlaiseVue CLI v1.0
==================

Usage:
  bv create <name>       Creates a new project
  bv clean               Cleans generated files (generated/ and dist/)
  bv run dev             DEBUG build with timestamp (SFC -> Pas -> JS)
  bv run build           PRODUCTION build with hashes (SFC -> Pas -> JS)
  bv serve               Starts development server (server logs)
  ...
```

## Recompiling the CLI (optional)

If you modify `bv.pas`, recompile it with FPC:

```bash
fpc -o"bin/bv.exe" bin/bv.pas
```
