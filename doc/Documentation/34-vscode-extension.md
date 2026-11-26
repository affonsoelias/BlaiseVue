# 34. VS Code Extension & Professional DX (.vsix)

BlaiseVue delivers a first-class Developer Experience (DX) for modern Object Pascal full-stack development. The official extension for Visual Studio Code and Chromium-based editors (e.g. VSCodium) turns Single File Component (`.bv`) authoring into a seamless, productive workflow featuring intelligent auto-completion, visual syntax highlighting, and productive snippets.

---

## 🎯 Key Capabilities & Objectives

1. **Native `.bv` File Format Recognition**:
   - Triple hybrid syntax highlighting in a single document: HTML elements in `<template>`, modern Object Pascal in `<script>`, and CSS rules in `<style>`.
2. **Intelligent Directive Auto-Completion**:
   - Contextual completion when typing BlaiseVue directives: `b-model`, `b-for`, `b-if`, `b-show`, `b-validate`, `@click`, `:class`, `:style`, etc.
3. **Integrated BlaiseUI Component Catalog**:
   - Auto-suggestions for all official components (`<bv-btn>`, `<bv-card>`, `<bv-container>`, `<bv-row>`, `<bv-col>`, `<bv-modal>`, `<bv-drawer>`, `<bv-bottom-nav>`, `<bv-icon>`, etc.) with built-in documentation for *props* and *slots*.
4. **Productive Snippet Library**:
   - Instant scaffolding for components, views, validated forms, modal dialogs, and responsive grids.
5. **Autonomous CLI Packaging**:
   - Standalone `.vsix` packaging without requiring heavy Node.js dependencies or external marketplace accounts.

---

## 📦 Complete Installation & Activation Guide (Step-by-Step)

The official BlaiseVue extension is compatible with **Visual Studio Code**, **Google Antigravity IDE**, **Cursor**, and other editors based on VS Code / VSCodium.

---

### Method 1: Automatic Installation via BlaiseVue CLI (Recommended)

The fastest and recommended way to install or update the extension across all your compatible IDEs:

```bash
# Installs official extension for VS Code / Antigravity IDE / Cursor:
bv tool install blaise-vscode

# (short alias also supported: bv tool install vscode)
```

**What this command does behind the scenes:**
1. Locates the extension package in `packages/tools/blaise-vscode/` and its `tool.json` manifest.
2. Executes the cross-platform installation script (`install.py`, or `install.pas` via InstantFPC) with the Python environment detected by the CLI (`bv doctor`).
3. Automatically detects active extension directories in your user profile (`~/.vscode/extensions`, `~/.antigravity-ide/extensions`, `~/.antigravity/extensions`).
4. Performs a clean deployment of syntax grammars, auto-completion schemas, component catalogs, and the formatting provider.

> [!IMPORTANT]
> **Mandatory Activation Step**: After running the installation, you **MUST reload the IDE window** so that the editor loads the new version of the extension:
> 1. Press **`Ctrl + Shift + P`** (or `Cmd + Shift + P` on macOS) to open the Command Palette.
> 2. Type and select: **`Developer: Reload Window`**.
> 3. *Alternative*: You can also simply close and reopen VS Code / Antigravity IDE.

---

### Method 2: Manual Installation via IDE Graphical Interface (Install from VSIX...)

If you prefer to install directly through the VS Code or Antigravity IDE user interface without opening a terminal:

1. Open the **Extensions** side panel by pressing **`Ctrl + Shift + X`** (or clicking the extensions block icon on the left activity bar).
2. Click the three-dots menu (**`...`**) located in the top-right corner of the Extensions panel (*Views and More Actions*).
3. Select **"Install from VSIX..."**.
4. In the file picker that opens, navigate to the project root and select the compiled package:
   ```text
   packages/tools/blaise-vscode/blaisevue-vscode-1.0.0.vsix
   ```
5. Click **Install**. A success notification will appear in the bottom-right corner confirming the installation (*Completed installing BlaiseVue extension*).
6. Press **`Ctrl + Shift + P`** $\rightarrow$ **`Developer: Reload Window`** to activate.

---

### Method 3: Installation via Terminal with the `code` CLI

If you have the `code` (or `cursor`) command-line utility configured in your system `PATH`:

```bash
# For Visual Studio Code:
code --install-extension packages/tools/blaise-vscode/blaisevue-vscode-1.0.0.vsix

# For Cursor:
cursor --install-extension packages/tools/blaise-vscode/blaisevue-vscode-1.0.0.vsix
```

After terminal installation completes, reload the IDE window (**`Ctrl + Shift + P`** $\rightarrow$ **`Developer: Reload Window`**).

---

### Method 4: Automated PowerShell Script (Windows)

On Windows, you can also execute the official PowerShell installer:

```powershell
cd packages/tools/blaise-vscode
.\install_extension.ps1
```

The script automatically packages the latest `.vsix` bundle, removes stale versions, distributes files to VS Code and Antigravity IDE, and displays the completion status.

---

### 🛠️ Additional `bv tool` CLI Commands

```bash
# List installation status of developer tools (VS Code, DevTools, Lazarus, etc.)
bv tool list

# Package a new standalone .vsix release
bv tool pack blaise-vscode

# Uninstall the extension from the local environment
bv tool remove blaise-vscode
```

---

## 🧩 Feature Details

### 1. Hybrid Syntax Highlighting (`.bv`)

Single File Components blend three languages in one document. The extension provides specialized TextMate grammars:
- `<template>` block: Advanced HTML5 with Vue/BlaiseVue template syntax (`{{ }}`, `@`, `:`, `b-`).
- `<script>` block: Full Object Pascal (Free Pascal / Delphi syntax), highlighting keywords (`interface`, `implementation`, `var`, `procedure`, `function`, `asm`, `end`), types, and reactive identifiers.
- `<style>` block: Standard CSS3 with scoped styles and CSS variables (`--bui-*`).

### 2. BlaiseVue Directive Auto-Completion

When typing inside template elements, IntelliSense suggests framework directives with inline contextual documentation:

| Directive | Description |
| :--- | :--- |
| `b-model="field"` | Reactive two-way data binding for inputs and custom components |
| `b-validate="rules"` | Reactive validation rules (`required`, `email`, `min:N`, `max:N`, etc.) |
| `b-if="cond"` | Conditional DOM rendering with mounting, unmounting, and lifecycle cleanup |
| `b-show="cond"` | Visual visibility toggle via `display: none` without unmounting from DOM |
| `b-for="item in list"` | Collection rendering with reactive iteration and `$index` support |
| `b-ref="name"` | Component reference registered onto `$refs` for imperative method calls |
| `@click="method"` | Declarative event binding with modifiers (`.stop`, `.prevent`) |
| `:prop="expr"` | Reactive property binding to Pascal component state |

### 3. BlaiseUI Component Suggestions

Typing `<bv-` triggers a complete list of official components with typed property hints:

```html
<!-- Example auto-completion when typing <bv-r... -->
<bv-row gutter="md">
  <bv-col cols="12" md="6">
    <bv-card title="Dashboard">
      ...
    </bv-card>
  </bv-col>
</bv-row>
```

### 4. Code Formatting (`Format Document` & Format on Save)

The extension registers a native formatting provider for `.bv` files:
- **Default VS Code Shortcut**: `Shift + Alt + F` (or `Cmd + Shift + I` on macOS).
- **Format on Save**: Supports automatic formatting on save (`"editor.formatOnSave": true`).
- **Command Palette**: `Ctrl + Shift + P` $\rightarrow$ `BlaiseVue: Format Component (.bv)`.
- **Indentation Rules**:
  - `<template>` block: 2-space indentation with automatic calculation of open/closed HTML tag balance.
  - `<script>` block: Pascal indentation (2 spaces for `props:`, `data:`, `methods:` sections; 4 spaces for `procedure`, `begin`, `end;`; 6 spaces for statements inside method bodies).
  - `<style>` block: CSS indentation (2 spaces for selectors, 4 spaces for properties).

### 5. Productivity Snippets

The extension includes code snippets to speed up development:

- **`bv-comp`**: Basic SFC component template (`<template>`, `<script>`, `<style>`).
- **`bv-page`**: Complete routed view page with breadcrumbs, navbar, and container.
- **`bv-form`**: Form layout with fields validated via `b-validate` and submit button.
- **`bv-grid`**: Responsive layout scaffold with `bv-container`, `bv-row`, and adaptive columns.
- **`bv-modal`**: Interactive modal dialog with body and footer slots.
- **`bv-drawer`**: Slide-out off-canvas navigation drawer with reactive control.
- **`bv-bottom-nav`**: Mobile-optimized bottom navigation bar.

---

## 🛠️ Extension Source Layout

The extension lives in [`packages/tools/blaise-vscode/`](/BlaiseVue/packages/tools/blaise-vscode/):

```text
packages/tools/blaise-vscode/
├── package.json               # Extension manifest, activation events, and commands
├── language-configuration.json # Tag auto-closing rules and comment syntax
├── syntaxes/
│   └── blaisevue.tmLanguage.json # Hybrid TextMate grammar (HTML + Pascal + CSS)
├── snippets/
│   └── blaisevue.json        # Collection of .bv productivity snippets
└── README.md                  # Developer guide
```

Editing BlaiseVue applications in VS Code provides an ergonomic and professional developer experience comparable to mainstream web frameworks. 🛡️✨
