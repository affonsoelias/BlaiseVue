# BlaiseVue Desktop (BlaiseVue 3.5 Desktop)

Native desktop application powered by **Free Pascal**, **Lazarus IDE**, and **WebUI**.

## Structure
- `BlaiseVue_Desktop.lpi`: Lazarus Project File (open in Lazarus IDE and press F9).
- `BlaiseVue_Desktop.lpr`: Main Free Pascal program entry point.
- `webui.pas`: WebUI C dynamic library loader.
- `uDesktopBridge.pas`: Native Pascal RPC bridge handlers for `$desktop`.
- `assets/`: Synchronized frontend build (`dist/`).
- `bin/`: Compiled native executable.
- `units/`: Free Pascal compiled unit cache (`.ppu`, `.o`).

## Quick Commands
```bash
# 1. Sync frontend to desktop assets
bv desktop sync

# 2. Build native binary with Free Pascal
bv desktop build

# 3. Launch desktop app
bv desktop run
```
