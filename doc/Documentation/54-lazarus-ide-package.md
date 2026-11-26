# 54. Lazarus IDE Integration & Design-Time Package (`blaisevue_ide.lpk`)

BlaiseVue delivers official design-time integration for the **Lazarus IDE**, bringing first-class developer tooling, syntax highlighting, component wizards, and project inspector organization directly to the native Object Pascal IDE.

---

## 🎯 Key Capabilities & Objectives

1. **Multi-Syntax Highlighting (`TSynMultiSyn`)**:
   - Simultaneous syntax coloring in a single `.bv` editor window:
     - `<template>`: HTML5 tags, custom component tags (`<bv-*>`), and reactive directives (`b-model`, `@click`, `:prop`, `v-if`).
     - `<script>`: Official Object Pascal highlighting (`TSynPasSyn`) with vibrant colors and keyword recognition.
     - `<style>`: CSS highlighting (`TSynCssSyn`) with properties, dimensions, units, and scoped rules.
   - Clean visual design without high-contrast yellow marker backgrounds.
   - Full buffer and range isolation per editor tab, preventing cross-tab collisions.

2. **File Wizards (`File -> New...`)**:
   - Native **BlaiseVue** category registered in the Lazarus New Item dialog.
   - **BlaiseVue Component (.bv)**: Scaffolds a reactive Single File Component with typed props, reactive data, and scoped styles.
   - **BlaiseVue View (.bv)**: Scaffolds a full routed page view with standard layout.

3. **Integrated Tools Menu (`Tools -> BlaiseVue`)**:
   - **Format Active Component (`Ctrl+Shift+F`)**: Instantly formats the active `.bv` component with standardized 2-space indentation in HTML templates, 2/4/6 spaces in Pascal scripts, and 2/4 spaces in CSS, with full undo support (`Ctrl+Z`).
   - **BlaiseVue Autocomplete (`Ctrl+Space`)**: Contextual auto-completion popup for reactive directives (`b-model`, `b-for`, `b-if`, `@click`), BlaiseUI components (`<bv-btn>`, `<bv-card>`, `<bv-modal>`, etc.), and Pascal blocks (`props:`, `data:`, `methods:`, `computed:`, etc.).
   - **Verify Active Component (`bv check`)**: Parses the Abstract Syntax Tree (AST) of the open `.bv` component and displays validation errors directly in the Lazarus Messages window.
   - **List Search Paths (`bv path`)**: Displays compiler search paths (-Fu) and Pas2JS libraries configured in `app.cfg`.
   - **Run Test Suite (`bv test`)**: Triggers the test suite with results displayed directly inside the IDE.
   - **Synchronize Project (`bv lazarus init`)**: Synchronizes the Lazarus project tree (.lpi) with all project files.

4. **Project Generation & Full Architecture Sync (`bv lazarus init`)**:
   - Automatically generates a complete Lazarus Project (`.lpi` and `.lpr`) from any existing BlaiseVue project.
   - Comprehensive multi-tier indexer scanning `src/` (components and views), `tests/` (unit and integration suites), `server/` (mORMot 2 backend), `desktop/` (WebUI desktop wrapper), `generated/` (compiler intermediate units), and root configurations (`app.cfg`).
   - Automatically utilizes the native **Directory Hierarchy View** in the Project Inspector so all project directories appear organized in their respective tree folders.
   - Configures build macros so pressing **F9** executes `bv dev` and **Ctrl+F9** executes `bv build`.

---

## 📦 Package Architecture

The Lazarus package lives in [`packages/tools/blaise-lazarus/`](/BlaiseVue/packages/tools/blaise-lazarus/):

```text
packages/tools/blaise-lazarus/
├── blaisevue_ide.lpk           # Official Lazarus Package manifest
├── blaisevue_ide.pas           # Package unit root
├── README.md                   # Quick installation guide
└── src/
    ├── uBVSynMultiSyn.pas      # Tri-language highlighter (HTML + Pascal + CSS)
    ├── uBVFileDescriptor.pas   # File -> New... descriptors and category registration
    ├── uBVFormatter.pas        # 3-section code formatting engine (FormatBVContent)
    ├── uBVAutoComplete.pas     # TSynCompletion provider (Ctrl+Space autocomplete)
    ├── uBVToolsMenu.pas        # Tools -> BlaiseVue action handlers
    └── uBlaiseVueIDEReg.pas    # IDE registration and SourceEditorManager hooks
```

---

## 🚀 Installation in Lazarus IDE

### Step 1: Open the Package
1. Open **Lazarus IDE**.
2. In the main menu, go to **Package $\rightarrow$ Open Package File (.lpk)...**
3. Select `packages/tools/blaise-lazarus/blaisevue_ide.lpk`.

### Step 2: Install and Rebuild
1. In the Package Manager window, click **Compile** to verify.
2. Click **Use $\rightarrow$ Install**.
3. When prompted: *"Do you want to rebuild Lazarus now?"*, select **Yes**.
4. Lazarus will rebuild its executable with the package embedded and restart automatically.

---

## 💻 CLI Integration (`bv lazarus init`)

To open an existing BlaiseVue project inside Lazarus:

```bash
# In your project root directory (e.g. demo-app/)
bv lazarus init
```

This command:
1. Scans `src/` recursively for all `.bv` Single File Components and `.pas` units.
2. Generates `<project_name>.lpi` and `<project_name>.lpr`.
3. Sets up compile commands to run `bv build` and execution commands for `bv dev`.
4. Opens seamlessly in Lazarus with all files listed in the **Project Inspector** (Ctrl+Shift+F11).

---

## 🛡️ Compatibility

- **Lazarus**: 2.2, 3.0, 3.2, 4.0, 4.6+
- **Free Pascal (FPC)**: 3.2.2 or higher
- **Platforms**: Windows (x64/x86), Linux (x86_64, aarch64), macOS
