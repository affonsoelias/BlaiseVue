# 📚 Automatic Documentation Generator & Playground (`bv doc`)

BlaiseVue includes an integrated, zero-configuration component catalog and interactive documentation generator powered by the CLI command `bv doc`.

---

## 🌟 Overview

Similar to tools like *Storybook* or *VuePress*, `bv doc` analyzes your project's components (`src/components/`, `src/views/`, and `lib/`) using an Object Pascal AST parser. It automatically extracts:
- Component names and kebab-case tags (`<bv-button>`, `<user-card>`).
- Docstring descriptions and inline comments.
- Declared properties (Props) with names, types, and default values.
- Emitted events (`$emit`).
- Declared named and default slots.
- Component templates and code preview snippets.

---

## 🛠️ Usage

### Generate Static Documentation Site
Run the following command from your project root:
```bash
bv doc
```

The CLI will scan all `.bv` Single File Components and generate a self-contained, responsive SPA in `dist/docs/index.html`:
```text
=== BlaiseVue Documentation & Component Playground Generator ===
  Found 44 .bv component(s). Parsing AST metadata...
  [SUCCESS] Documentation generated at dist/docs/index.html (44 components analyzed)
```

### Preview Documentation with Live Server
To immediately spin up a local preview server on port `8085`:
```bash
bv doc --serve
```

---

## 🎨 Interactive Features in the Generated Catalog

1. **Live Search & Filter**: Real-time filtering by component name or HTML tag.
2. **Interactive Props Table**: Displays property name, Pascal type, and default values.
3. **Template Previewer**: Syntax-highlighted template view.
4. **Theme Switcher**: Instant Dark Mode and Light Mode toggle to test component appearances.
5. **Zero Dependencies**: Generated catalog is self-contained with zero runtime dependencies.
