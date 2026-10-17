# 36. Multiplatform Desktop & Lazarus IDE (bv desktop) - Phase 3

**Phase 3 of the BlaiseVue Universal Platform (v3.5)** introduces native multiplatform desktop application development using **Free Pascal**, **Lazarus IDE**, and the **WebUI** library (with transparent fallback to system browser app mode).

This architecture produces ultra-lightweight desktop binaries (**< 10 MB** on disk, **< 40 MB** RAM usage), eliminating the massive overhead of bundling Chromium/Electron and avoiding legacy GTK2 dependencies on Linux.

---

## 🖥️ Desktop Architecture Overview

```text
┌────────────────────────────────────────────────────────┐
│         BlaiseVue Single File Components (.bv)         │
│             Native hardware access via $desktop        │
└──────────────────────────┬─────────────────────────────┘
                           │ Transpilation (bv run build)
┌──────────────────────────▼─────────────────────────────┐
│                 Optimized Web Bundle                   │
│          dist/ (index.html, main.js, css/)             │
└──────────────────────────┬─────────────────────────────┘
                           │ Synchronization (bv desktop sync)
┌──────────────────────────▼─────────────────────────────┐
│          Lazarus / Free Pascal Project (desktop/)      │
│     <AppName>.lpi, <AppName>.lpr, uDesktopBridge.pas   │
└──────────────────────────┬─────────────────────────────┘
                           │ FPC / Lazarus Build (bv desktop build)
┌──────────────────────────▼─────────────────────────────┐
│          Native Executable Binary (< 10 MB)            │
│       desktop/bin/<AppName>.exe (Win/Linux/macOS)      │
│     (WebUI C Runtime or Browser App-Mode Fallback)     │
└────────────────────────────────────────────────────────┘
```

---

## 🛠️ CLI Commands (`bv desktop`)

```bash
# 1. Scaffolding complete desktop project (Lazarus .lpi, .lpr, bridges, assets, bin/, units/)
bv desktop init [AppName]

# 2. Synchronize production build (dist/) into desktop/assets/
bv desktop sync

# 3. DEBUG Build Mode (with active console window for diagnostics and logging):
bv desktop build               # Compiles for current host OS (e.g.: Windows -> desktop/bin/windows/)
bv desktop build windows       # Specifically targets Windows
bv desktop build linux         # Specifically targets Linux
bv desktop run                 # Launches host OS binary in debug mode

# 4. RELEASE Build Mode (for End Users - 100% GUI, NO console window):
bv desktop build --release             # Compiles for host OS in Release mode
bv desktop build windows --release     # Compiles for Windows in desktop/bin/windows/
bv desktop build linux --release       # Compiles for Linux in desktop/bin/linux/
bv desktop build macos --release       # Compiles for macOS in desktop/bin/macos/
bv desktop run windows --release       # Launches on Windows without a console window

# 5. Compile for ALL Platforms simultaneously:
bv desktop build all                   # Compiles Windows, Linux, and macOS (Debug)
bv desktop build all --release         # Compiles Windows, Linux, and macOS (Release)
```

### ⚙️ Build Modes & Platforms

| Platform / Mode | CLI Command | Lazarus IDE Mode | Window Behavior | Generated Binary |
|---|---|---|---|---|
| **Windows Debug** | `bv desktop run windows` | `Debug` | **GUI Window + Diagnostics Console** | `desktop/bin/windows/<App>.exe` |
| **Windows Release** | `bv desktop run windows --release` | `Release` | **GUI Window Only (No Console)** | `desktop/bin/windows/<App>.exe` |
| **Linux Debug** | `bv desktop build linux` | `Debug` | Native ELF Binary + Logging | `desktop/bin/linux/<App>` |
| **Linux Release** | `bv desktop build linux --release` | `Release` | Optimized Native ELF Binary | `desktop/bin/linux/<App>` |
| **macOS Release** | `bv desktop build macos --release` | `Release` | Mach-O Executable / App Bundle | `desktop/bin/macos/<App>` |
| **All Platforms** | `bv desktop build all --release` | - | Segregated Binaries for Win, Linux, Mac | `desktop/bin/<platform>/` |

---

## 📦 Directory Structure (`desktop/`)

When executing `bv desktop init [AppName]`, the following multiplatform structure is automatically created:

```text
my-project/
├── desktop/
│   ├── assets/                 # Synchronized frontend (dist/ shared across all OS targets)
│   ├── bin/                    # Platform-segregated native executable binaries
│   │   ├── windows/            # Windows executable (MyApp.exe and webui-2.dll)
│   │   ├── linux/              # Native Linux ELF executable (MyApp and libwebui-2.so)
│   │   └── macos/              # macOS executable / App Bundle (MyApp and libwebui-2.dylib)
│   ├── units/                  # FPC compilation unit caches (.ppu, .o) isolated by target OS
│   │   ├── windows/            # Prevents checksum collisions when compiling on Windows
│   │   ├── linux/              # Prevents checksum collisions when compiling on Linux
│   │   └── macos/              # Prevents checksum collisions when compiling on macOS
│   ├── MyApp.lpi               # Lazarus project file (open in IDE and press F9)
│   ├── MyApp.lpr               # Main Free Pascal program entry point
│   ├── webui.pas               # WebUI C dynamic library loader
│   ├── uDesktopBridge.pas      # Native Pascal RPC bridge for $desktop
│   └── README.md               # Development and build instructions
```

---

## 🔌 Window & Hardware API (`$desktop`)

Within any BlaiseVue component (`.bv`), the global helper `$desktop` is injected directly into the reactive scope (`this.$desktop`):

### 1. Environment Detection
```pascal
// Check if running inside a native desktop environment
if this.$desktop.isDesktop() then
  console.log('Native Desktop Environment Detected!');

// Returns 'windows', 'linux', 'macos', or 'browser'
var plat := this.$desktop.getPlatform();
```

### 2. Native Window Control
```pascal
// Minimize native window
this.$desktop.window.minimize();

// Maximize or restore native window
this.$desktop.window.maximize();

// Update window title bar
this.$desktop.window.setTitle('New Application Title');

// Toggle kiosk fullscreen mode
this.$desktop.window.setFullScreen(true);

// Close application
this.$desktop.window.close();
```

### 3. System Notifications & External URLs
```pascal
// Native desktop notification
this.$desktop.notification.show('Download Finished', 'File saved successfully!');

// Open URL in system default browser (outside the application window)
this.$desktop.shell.openURL('https://blaisevue.dev');
```

### 4. Native File Dialogs
```pascal
// Native Open File dialog
this.$desktop.dialog.openFile(procedure(fileInfo: JSValue)
begin
  console.log('Selected file:', fileInfo);
end);

// Native Save File dialog
this.$desktop.dialog.saveFile('report.pdf', procedure(savedFile: JSValue)
begin
  console.log('File saved successfully:', savedFile);
end);
```

### 5. System Information & Native Pascal RPC
```pascal
// Fetch system information (OS, CPU, Compiler)
this.$desktop.system.getInfo(procedure(sysInfo: JSValue)
begin
  console.log('System info:', sysInfo);
end);

// Execute custom Pascal function on native backend
this.$desktop.rpc.call('my_pascal_function', payload, procedure(res: JSValue)
begin
  console.log('Response from Free Pascal:', res);
end);
```

---

## 🎯 Lazarus IDE Integration (F9 Ready)

The `.lpi` file generated by `bv desktop init` is 100% compatible with the official **Lazarus IDE**:

1. Launch Lazarus IDE.
2. Select **Project > Open Project...** and choose `desktop/<AppName>.lpi`.
3. Press **F9** (or click the green *Run* button).
4. Lazarus compiles the Object Pascal code with native optimizations and opens the desktop window instantly!

---

## 🛡️ Automatic Fallback & Zero Dependencies

If the WebUI dynamic library (`webui-2.dll` on Windows or `libwebui-2.so` on Linux) is not present in the binary directory, the native executable automatically detects modern browsers installed on the host (**Microsoft Edge**, **Google Chrome**, **Brave**, or **Chromium**) and launches the application in **app-window mode** (`--app`), guaranteeing the app opens smoothly without requiring any installation steps from the user.
