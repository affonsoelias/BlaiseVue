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

## 📦 Installation

### Option 1: Automatic Script (PowerShell)
Run from the `vscode-extension` directory:
```powershell
.\install_extension.ps1
```

### Option 2: Install via .VSIX
Package and install the standalone `.vsix` file:
```bash
code --install-extension blaisevue-vscode-3.5.0.vsix
```

---

🛡️ **BlaiseVue — Modern Reactive Frontend in Object Pascal.**
