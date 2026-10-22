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

## 📦 Extension CLI Commands

The native `bv` CLI manages extension packaging and installation:

```bash
# Packages the official extension into a distributable .vsix bundle
bv vsix

# Or via the extension subcommand:
bv extension package

# Installs the extension directly into local VS Code
bv extension install
```

This command generates `blaisevue-language-tools-1.0.0.vsix` ready for team distribution or manual installation (`code --install-extension blaisevue-language-tools-1.0.0.vsix`).

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

### 4. Productivity Snippets

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

The extension lives in [`vscode-extension/`](file:///c:/Users/Pichau/Documents/BlaiseVue/vscode-extension/):

```text
vscode-extension/
├── package.json               # Extension manifest, activation events, and commands
├── language-configuration.json # Tag auto-closing rules and comment syntax
├── syntaxes/
│   └── blaisevue.tmLanguage.json # Hybrid TextMate grammar (HTML + Pascal + CSS)
├── snippets/
│   └── blaisevue.json        # Collection of .bv productivity snippets
└── README.md                  # Developer guide
```

Editing BlaiseVue applications in VS Code provides an ergonomic and professional developer experience comparable to mainstream web frameworks. 🛡️✨
