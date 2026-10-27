# 2. Installation & Environment Setup

BlaiseVue is engineered to be as frictionless as possible. The core transpiler (`pas2js`) and full-stack backend libraries (`mORMot 2`) come **pre-bundled** inside the SDK, meaning you only need a minimal set of standard developer tools to get started.

---

## 📋 Prerequisites

Before installing BlaiseVue, ensure the following core tools are installed on your machine:

1. **Git CLI (v2.30+)** *(Required)*:
   - Mandatory for cloning the repository, downloading selective delta updates from GitHub via `bv self-update`, and managing framework branches (`main` vs `develop`) via `bv channel`.
   - Download: [https://git-scm.com](https://git-scm.com) (ensure `git` is added to your system `PATH`).

2. **Lazarus IDE / Free Pascal Compiler (FPC 3.2.2+)** *(Required for backend & CLI compilation)*:
   - The primary compiler and IDE for Object Pascal development.
   - Required to compile native mORMot 2 backend servers (`server/`), desktop applications (`desktop/`), and the BlaiseVue CLI (`bv` / `bv.exe`).
   - Download: [https://www.lazarus-ide.org](https://www.lazarus-ide.org) or [https://www.freepascal.org](https://www.freepascal.org).

3. **Node.js (v18+ LTS) & npm** *(Required for Dev Server & Tests)*:
   - Powers the development server with live Hot Module Replacement (HMR) on port `8080` & WebSocket `8081` (`bv serve` / `bv dev`).
   - Serves local production previews (`bv run preview`) and interactive component documentation (`bv doc --serve`).
   - Runs the automated test suite (`bv test` via Vitest).
   - Manages mobile dependencies and synchronization (`bv mobile init`, `bv mobile sync`).
   - Download: [https://nodejs.org](https://nodejs.org) (LTS version recommended; must be on your system `PATH`).

4. **Android Studio** *(Recommended for Mobile App Development)*:
   - Required for building native Android packages (`.apk` / `.aab`), configuring Android emulators (AVD), and running `bv mobile open android`.
   - Bundles the Android SDK, Build-Tools, Platform-Tools (`adb`), and Java JDK.
   - Download: [https://developer.android.com/studio](https://developer.android.com/studio).

5. **Docker CLI** *(Optional for Micro-Containers)*:
   - Used for scaffolding and building lightweight sub-20MB Alpine Linux production micro-containers (`bv mormot docker`).
   - Download: [https://www.docker.com](https://www.docker.com).

> [!NOTE]
> **Pas2JS & mORMot 2 are pre-bundled!**  
> You do **not** need to install `pas2js` or `mORMot 2` separately. Official multi-platform binaries for Windows, Linux, and macOS are already included in `vendor/pas2js/`, and the Synopse mORMot 2 framework is pre-configured in `vendor/mormot2/`.

---

## 🚀 Step 1: Clone the Repository

Clone the BlaiseVue SDK using Git. Choose the channel that best suits your workflow:

### Option A: Official Stable Release Channel (`main`)
Recommended for end users and production application development:
```bash
git clone https://github.com/affonsoelias/BlaiseVue.git
cd BlaiseVue
```

### Option B: Bleeding-Edge Development Channel (`develop`)
Recommended for framework contributors and developers who want the latest cutting-edge features:
```bash
git clone -b develop https://github.com/affonsoelias/BlaiseVue.git
cd BlaiseVue
```

---

## 🛠️ Step 2: Add the BlaiseVue CLI to System PATH

Pre-compiled CLI binaries are already provided in `bin/` (`bv.exe` for Windows, `bv` for Linux/macOS). Add the `bin/` directory to your system `PATH` so you can execute `bv` from any directory:

### Windows (PowerShell - Run as Administrator)
```powershell
$sdkBin = "C:\path\to\BlaiseVue\bin"
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$sdkBin*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$sdkBin", "User")
    Write-Host "BlaiseVue added to User PATH successfully!"
}
```

### Linux & macOS (Bash / Zsh)
Add the `bin/` folder to your shell configuration file (`~/.zshrc` for Zsh users such as Manjaro/macOS, or `~/.bashrc` for Bash users):
```bash
export PATH="$HOME/path/to/BlaiseVue/bin:$PATH"
```
Ensure both the `bv` CLI and the bundled `pas2js` transpiler binaries have executable permissions (`+x`):
```bash
chmod +x "$HOME/path/to/BlaiseVue/bin/bv"
chmod +x "$HOME/path/to/BlaiseVue/vendor/pas2js/"pas2js-*/bin/{pas2js,compileserver,makestub,webidl2pas} 2>/dev/null || true
```
*(Without executable permissions on `vendor/pas2js/.../bin/pas2js`, compilation fails with `EOSError: Failed to execute ".../bin/pas2js", error code: 127`.)*

Then reload your active shell configuration:
```bash
# If your terminal runs Zsh (default on Manjaro & macOS — check with `echo $SHELL`):
source ~/.zshrc

# If your terminal runs Bash:
source ~/.bashrc
```
> [!TIP]
> **Zsh vs. Bash:** Only `source` the configuration file matching your current terminal shell. Running `source ~/.bashrc` inside a **Zsh** terminal will trigger syntax warnings (`bad option: -P` or `command not found: shopt`) because `.bashrc` uses Bash-specific builtins.

---

## 🩺 Step 3: Run Environment Diagnostics (`bv doctor`)

Restart your terminal and run the environment diagnostic tool:

```bash
bv doctor
```

`bv doctor` automatically inspects your environment and verifies all core framework dependencies:
* **Git CLI**: Verifies installation in PATH and reports the active channel.
* **Free Pascal (FPC) & Lazarus IDE**: Detects FPC in PATH or bundled inside standard Lazarus installations (`C:\lazarus\fpc\...` on Windows, `/usr/bin/fpc` on Linux/macOS).
* **Pas2JS (Bundled)**: Confirms the presence and integrity of the built-in transpiler in `vendor/pas2js/`.
* **Synopse mORMot 2 (Bundled)**: Verifies the full-stack Pascal framework in `vendor/mormot2/`.
* **Node.js & npm**: Checks runtime versions for Vitest and HMR dev server.
* **Docker CLI**: Checks optional micro-container tooling.

**Expected healthy output:**
```text
======================================================================
  BlaiseVue Doctor - Environment Diagnostics
======================================================================
  Operating System:     Windows (x86_64)
  SDK Directory:        C:\Users\Pichau\Documents\BlaiseVue
  Git Channel:          main (Commit: a1b2c3d)
  Remote Origin:        https://github.com/affonsoelias/BlaiseVue.git

[1] Core Framework Tooling:
  [v] Git CLI:              git version 2.50.1 detected in PATH
  [v] Free Pascal (FPC):    v3.2.2 (system PATH)
  [v] Lazarus IDE:          Detected (Full F9 and Desktop app support)
  [v] Pas2JS (Bundled):     v3.2.0 verified at vendor\pas2js\...
  [v] Synopse mORMot 2:     Verified at vendor\mormot2

[2] Ecosystem & Testing Tools:
  [v] Node.js & npm:        Node v24.12.0 and npm v11.11.0 detected in PATH
  [!] Docker CLI:           Not detected (Optional: production micro-containers)

======================================================================
  [v] Diagnostics complete: Your environment is 100% healthy and ready!
======================================================================
```

---

## 🔄 Step 4: Keeping BlaiseVue Updated (`bv self-update`)

Never manually re-download ZIP files or re-clone the repository to get bug fixes or new features. BlaiseVue includes a built-in Git auto-updater:

### 1. Check for remote updates (without downloading):
```bash
bv self-update --check
```

### 2. Download and apply updates:
```bash
bv self-update
```
The updater automatically:
* Performs a `git fetch` and downloads only the delta of modified files (a few KBs).
* Protects uncommitted local changes, halting safely if your workspace is dirty.
* Automatically recompiles the `bv` binary if `bin/bv.pas` was updated.

### 3. Switch between Channels:
```bash
# Switch to bleeding-edge development channel:
bv channel use develop

# Switch back to stable release channel:
bv channel use main
```

---

## ⚡ Step 5: Test the Demo Application

Launch the enterprise showcase application included with the framework:

```bash
cd demo-app
bv dev   # or bv serve
```
Open **[http://localhost:8080](http://localhost:8080)** in your browser to experience instant Hot Module Replacement (HMR), reactive forms, and full-stack mORMot 2 integration!

---

## 🔧 Recompiling the CLI from Source (Optional)

If you modify `bin/bv.pas` directly or want to recompile the CLI manually:

```bash
cd bin
fpc -MObjFPC -Sh bv.pas
```
On Linux and macOS, ensure executable permissions:
```bash
chmod +x bv
```
