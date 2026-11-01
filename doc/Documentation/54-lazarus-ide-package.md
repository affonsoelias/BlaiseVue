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
   - **Formatar Componente Ativo (`Ctrl+Shift+F`)**: Formata instantaneamente o componente `.bv` ativo com indentação padronizada de 2 espaços no template HTML, 2/4/6 espaços no script Pascal e 2/4 espaços no CSS, com suporte total a desfazer (`Ctrl+Z`).
   - **Autocomplete BlaiseVue (`Ctrl+Espaço`)**: Popup de autocompletar contextual para diretivas reativas (`b-model`, `b-for`, `b-if`, `@click`), componentes BlaiseUI (`<bv-btn>`, `<bv-card>`, `<bv-modal>`, etc.) e blocos Pascal (`props:`, `data:`, `methods:`, `computed:`, etc.).
   - **Verificar Componente Ativo (`bv check`)**: Analisa a árvore sintática (AST) do componente `.bv` aberto e exibe erros de validação na janela de Mensagens do Lazarus.
   - **Listar Search Paths (`bv path`)**: Exibe as unidades de busca do compilador e bibliotecas Pas2JS mapeadas no `app.cfg`.
   - **Executar Suíte de Testes (`bv test`)**: Dispara a suíte de testes com resultados exibidos diretamente na IDE.
   - **Sincronizar Projeto (`bv lazarus init`)**: Sincroniza a árvore do Projeto (.lpi) com todos os arquivos do projeto.

4. **Project Generation & Full Architecture Sync (`bv lazarus init`)**:
   - Automatically generates a complete Lazarus Project (`.lpi` and `.lpr`) from any existing BlaiseVue project.
   - Comprehensive multi-tier indexer scanning `src/` (components and views), `tests/` (unit and integration suites), `server/` (mORMot 2 backend), `desktop/` (WebUI desktop wrapper), `generated/` (compiler intermediate units), and root configurations (`app.cfg`).
   - Automatically utilizes the native **Directory Hierarchy View** in the Project Inspector so all project directories appear organized in their respective tree folders.
   - Configures build macros so pressing **F9** executes `bv dev` and **Ctrl+F9** executes `bv build`.

---

## 📦 Package Architecture

The Lazarus package lives in [`packages/tools/lazarus/`](/BlaiseVue/packages/tools/lazarus/):

```text
packages/tools/lazarus/
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
3. Select `packages/tools/lazarus/blaisevue_ide.lpk`.

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
