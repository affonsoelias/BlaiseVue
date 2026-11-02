<p align="center">
  <img src="icon.png" alt="BlaiseVue Extension Icon" width="100" height="100">
</p>

# 🛡️ BlaiseVue Official VS Code Extension

The official **BlaiseVue Developer Experience (DX)** extension for Visual Studio Code and Cursor.

Provides first-class tooling, syntax highlighting, IntelliSense, rich snippets, and CLI integration for Single File Components (`.bv`) combining HTML templates, Object Pascal logic, and CSS styling.

---

## ✨ Features

- **🎨 Multi-Language Syntax Highlighting**:
  - Highlights `<template>` with full HTML5 and BlaiseVue directives (`b-model`, `b-validate`, `b-for`, `b-if`, `b-else`, `b-show`).
  - Highlights shorthand bindings (`:prop`, `@event`) and interpolation (`{{ ... }}`).
  - Highlights `<script>` with native Object Pascal grammar, including custom section keywords (`props:`, `data:`, `methods:`, `computed:`, `watch:`, `validations:`, `created:`, `mounted:`).
  - Highlights embedded `asm ... end` blocks as JavaScript.
  - Highlights `<style>` with CSS3 grammar.
- **💡 HTML Custom Data & IntelliSense**:
  - Autocomplete for all **BlaiseUI components** (`<bv-btn>`, `<bv-card>`, `<bv-modal>`, `<bv-input>`, `<bv-icon>`, `<bv-badge>`, `<bv-alert>`, `<bv-toast>`, `<bv-spinner>`, `<bv-progress>`, `<bv-chart>`, `<bv-data-grid>`, `<bv-tabs>`, `<bv-tab>`).
  - Autocomplete for **BlaiseThemes** controls (`<bv-theme-select>`, `<bv-theme-toggle>`).
  - Autocomplete and hover documentation for all `b-*` directives and attributes.
- **🔍 Contextual Hover Documentation**:
  - Hover over `b-validate`, `$v`, `$errors`, `$store`, `$router`, `$i18n`, `$t`, `$theme`, or `$wasm` to view detailed documentation and Pascal usage examples.
- **⚡ Production Snippets Suite**:
  - `bv-comp`: Scaffold a basic `.bv` component.
  - `bv-comp-full`: Scaffold a full component with props, data, computed, watch, and lifecycle.
  - `bv-form`: Scaffold a reactive form with `b-validate` and error messages.
  - `bv-modal`, `bv-card`, `bv-btn`, `bv-input`, `bv-icon`, `bv-toast`, `bv-chart`, `bv-data-grid`, etc.
  - `bv-wasm`: WebAssembly execution template with fallback.
- **🛠️ Integrated Commands**:
  - `BlaiseVue: Start Dev Server (HMR)` (`bv run dev`)
  - `BlaiseVue: Build Production Bundle` (`bv build`)
  - `BlaiseVue: Run Unit Tests` (`bv test`)
  - `BlaiseVue: Generate Documentation Catalog` (`bv doc`)
  - `BlaiseVue: Create New Component (.bv)`

---

## 🚀 Installation & Activation Guide

The BlaiseVue extension is compatible with **Visual Studio Code**, **Google Antigravity IDE**, **Cursor**, and other Chromium/VS Code-based editors.

### Option 1: Automatic via BlaiseVue CLI (Recommended)
From anywhere in your BlaiseVue project, run:
```bash
bv extension install blaise-vscode
```
*(Or use the short alias: `bv extension install vscode`)*

### Option 2: Manual Installation via Editor UI (Install from VSIX...)
1. Open the Extensions sidebar (**`Ctrl + Shift + X`**).
2. Click the three dots menu (**`...`**) in the top-right corner of the Extensions panel (*Views and More Actions*).
3. Select **"Install from VSIX..."** (*Instalar a partir do VSIX...*).
4. Select the packaged extension:
   ```text
   packages/tools/blaise-vscode/blaisevue-vscode-4.4.0.vsix
   ```
5. Wait for the confirmation prompt.

### Option 3: Command Line via `code` CLI
```bash
code --install-extension packages/tools/blaise-vscode/blaisevue-vscode-4.4.0.vsix
```

### Option 4: Direct PowerShell Script (Windows)
Run from the `packages/tools/blaise-vscode` directory:
```powershell
.\install_extension.ps1
```

---

### ⚠️ Important: Activating the Extension (Reload Window)
After installing through any of the options above, **reload the IDE window** to activate the extension:
1. Press **`Ctrl + Shift + P`** (or `Cmd + Shift + P` on macOS) to open the Command Palette.
2. Select **`Developer: Reload Window`**.
3. *Alternative*: Simply close and restart VS Code / Antigravity IDE.

---

🛡️ **BlaiseVue — Modern Reactive Frontend in Object Pascal.**
