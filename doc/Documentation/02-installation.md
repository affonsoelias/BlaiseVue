# 2. Installation

## Prerequisites

1. **pas2js** (3.2.0+): Pascal → JavaScript Transpiler
   - Download: https://wiki.freepascal.org/pas2js
   - Must be in the system PATH

2. **FPC** (3.2.2+): Free Pascal Compiler (to compile the CLI)
   - Usually installed along with Lazarus

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
