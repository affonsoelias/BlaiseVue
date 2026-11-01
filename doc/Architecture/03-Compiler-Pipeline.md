# 🏗️ The Compiler Pipeline
**From .bv Single File Components to Browser Execution.**

The BlaiseVue Compiler is the bridge between the high-level SFC format and the low-level JavaScript execution. It follows a strictly structured translation path.

---

## 1. Phase 1: Separation (SFC Stripping)
- **Tool**: `bin/bv.pas`
- **Logic**: The CLI reads the source file and looks for `<template>`, `<script>`, and `<style>` tags. 
- It extracts each section into a specialized memory buffer (TStringList).

## 2. Phase 2: Structural Generation (Pascal Object)
The compiler then generates an **Object Pascal Unit** in the `generated/` folder.
1. **The Template**: Converted into a massive string inside the `GetTemplate` function.
2. **The Script**: The logic inside `<script>` is wrapped into a new class inheriting from `TBVComponent`.
3. **The Bindings**: The compiler analyzes expressions in `data:`, `methods:`, and `computed:` to ensure they are compatible with the JS Proxy.

## 3. Phase 3: Pas2JS Compilation
Once the `.pas` units are generated, the CLI invokes the **Pas2JS** compiler.
- It transforms the Pascal code into highly optimized JavaScript.
- It links all global units like `BVReactivity` and `BVStore`.

## 4. Phase 4: Final Asset Bundling
The CLI then:
- Minifies or versions the JS file (Cache Busting).
- Copies any CSS from the `<style>` tag into `dist/css/`.
- Injects the script tags into the final `index.html`.

---

## 🚀 How to Contribute to the Compiler
If you want to add new directives (like `v-on-hover` or `b-mask`), you need to modify:
1. `bin/bv.pas`: Add the directive to the parsing logic if it requires special Pascal code generation.
2. `core/BVDirectives.pas`: Implement the DOM binding logic for the new directive.

---
🛡️ **Next Lesson:** The Contribution Guide: Coding standards and Testing.
