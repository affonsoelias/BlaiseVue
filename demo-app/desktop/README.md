# BlaiseVue Desktop (BlaiseVue 3.5 Desktop)

Native desktop application powered by **Free Pascal**, **Lazarus IDE**, and **WebUI**.

## Structure
- `BlaiseVue_Desktop.lpi`: Lazarus Project File (open in Lazarus IDE and press F9).
- `BlaiseVue_Desktop.lpr`: Main Free Pascal program entry point.
- `webui.pas`: WebUI C dynamic library loader.
- `uDesktopBridge.pas`: Native Pascal RPC bridge handlers for `$desktop`.
- `assets/`: Synchronized frontend build (`dist/`).
- `bin/`: Platform-segregated native executables:
  - `bin/windows/`: Windows executable (`.exe`) and `webui-2.dll`.
  - `bin/linux/`: Linux native ELF executable and `libwebui-2.so`.
  - `bin/macos/`: macOS executable / application bundle and `libwebui-2.dylib`.
- `units/`: Free Pascal compiled unit caches (`.ppu`, `.o`) separated by target OS:
  - `units/windows/`, `units/linux/`, `units/macos/`.

## Quick Commands
```bash
# 1. Sync frontend to desktop assets
bv desktop sync

# 2. Build in Debug mode (default: host OS, with console for logs & diagnostics)
bv desktop build
bv desktop build windows
bv desktop build linux
bv desktop run

# 3. Build in Release mode (pure GUI for end users - NO console window)
bv desktop build --release
bv desktop build windows --release
bv desktop build linux --release
bv desktop build macos --release
bv desktop run windows --release

# 4. Build for all platforms at once
bv desktop build all
bv desktop build all --release
```

## Lazarus IDE (F9)
Open `BlaiseVue_Desktop.lpi` in Lazarus IDE and switch between **Debug** and **Release** build modes in the top toolbar.
