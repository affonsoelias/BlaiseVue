# 🛡️ Technical Roadmap: BlaiseVue 2.5 & 3.0 (The Next Frontier)

This document defines the technical strategy, architectural goals, and specifications for the next major evolution of the framework: **BlaiseVue 2.5 and 3.0**.

> [!NOTE]
> **Current Status**: 📋 **Planned / Under Architectural Specification**. No implementation of the 2.5/3.0 cycle has been started.

---

## 🏆 Delivery Record: BlaiseVue 2.0 (✅ 100% Completed)

BlaiseVue version 2.0 has reached enterprise maturity with all 9 original goals fully implemented and covered by automated unit tests:

| 2.0 Goal | Status | Implementation Files |
|---|:---:|---|
| **1. Hot Module Replacement (HMR)** | ✅ Completed | [`bin/dev-server.js`](file:///c:/Users/Pichau/Documents/BlaiseVue/bin/dev-server.js), [`core/BVCompiler.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/core/BVCompiler.pas) |
| **2. Advanced Routing (History & Nested)** | ✅ Completed | [`core/BVRouting.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/core/BVRouting.pas) |
| **3. Scoped Slots** | ✅ Completed | [`core/BVCompiler.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/core/BVCompiler.pas) |
| **4. Teleport & Suspense** | ✅ Completed | [`core/BVCompiler.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/core/BVCompiler.pas) |
| **5. Static Hoisting & Compiler Pruning** | ✅ Completed | [`core/BVCompiler.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/core/BVCompiler.pas) |
| **6. Browser DevTools Extension (Manifest V3)** | ✅ Completed | [`devtools/`](file:///c:/Users/Pichau/Documents/BlaiseVue/devtools/), [`core/BVCompiler.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/core/BVCompiler.pas) |
| **7. BlaiseUI Component Kit** | ✅ Completed | [`packages/blaise-ui/`](file:///c:/Users/Pichau/Documents/BlaiseVue/packages/blaise-ui/), [`demo-app/lib/blaise-ui/`](file:///c:/Users/Pichau/Documents/BlaiseVue/demo-app/lib/blaise-ui/) |
| **8. CLI Native Resource Scaffolding** | ✅ Completed | [`bin/templates/`](file:///c:/Users/Pichau/Documents/BlaiseVue/bin/templates/), `{$R templates.res}` in [`bin/bv.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/bin/bv.pas) |
| **9. Automated Test Suite** | ✅ Completed | `demo-app/tests/`, Vitest runner |

---

## 🔮 The Next Horizon: Architectural Goals (v2.5 & v3.0)

Below are the new strategic pillars designed to consolidate BlaiseVue as the most robust and performant frontend ecosystem in Object Pascal:

```
                                  BLAISEVUE 3.0
                                        │
        ┌───────────────┬───────────────┼───────────────┬───────────────┐
        ▼               ▼               ▼               ▼               ▼
   [b-validate]    [transition-    [Blaise-i18n]    [bv doc]        [WebAssembly]
  (Form Engine)      group]        (Multilingual) (Docs/Storybook)   (FPC Wasm)
```

---

### 📋 1. Native Form Validation Engine (`b-validate` / Typed Form Engine)
**Goal**: Reactive form validation without manual boilerplate and with Pascal's type safety.
- **Declarative Syntax**: `b-validate` directive or `validations:` block in `.bv` components:
  ```html
  <bv-input
    b-model="email"
    b-validate="required|email"
    label="E-mail"
    :error="$errors.email"
  ></bv-input>
  ```
- **Typed Rules in Pascal**: Creation of custom validators in Object Pascal:
  ```pascal
  function ValidateTaxId(Value: string): boolean;
  ```
- **State Management**: Automatic injection of the `$v` or `$errors` object containing `$dirty`, `$invalid`, `$touch()`, and localized error messages.

---

### 🎬 2. Reactive List Transitions (`<transition-group>`)
**Goal**: Smooth animations for entry, removal, and reordering of elements in collections.
- **FLIP Algorithm (*First, Last, Invert, Play*)**: The compiler computes the initial and final position of each DOM node upon mutation via `b-for`, generating smooth CSS transitions without heavy layout recalculations.
- **Automatic Classes**: Injection of CSS classes `-move`, `-enter-active`, and `-leave-to` supporting `transform: translate(...)` coordinates.

---

### 🌐 3. Integrated Internationalization (Blaise-i18n)
**Goal**: First-class support for multilingual applications.
- **Global Helper `$t()`**: Immediate access in the template (`{{ $t('common.save') }}`) and in Pascal methods (`this['$t']('common.save')`).
- **Reactive Dictionaries**: Message files in `.json` or Pascal units (`uLocalePT.pas`, `uLocaleEN.pas`).
- **Dynamic Locale Switching**: Instant runtime language switching without reloading the page, updating all on-screen strings.

---

### 📚 4. Automatic Documentation Generator (`bv doc`)
**Goal**: Facilitate the creation of enterprise Design Systems and component libraries.
- **CLI Command**: `bv doc` analyzes the `src/components/` and `lib/` folders.
- **AST Parser in Pascal**: Automatically extracts:
  - Declared props (name, type, default value).
  - Emitted events (`$emit`).
  - Available slots (named and scoped).
  - Documentation docstrings written inside `.bv` files.
- **Interactive Catalog**: Generates a modern static site (similar to *Storybook* or *VuePress*) featuring a component previewer and interactive playground.

---

### ⚡ 5. WebAssembly Acceleration (FPC Wasm Target)
**Goal**: Near-native performance for computationally intensive tasks.
- **Hybrid Pipeline**: Enable image processing routines, cryptography, mathematical computations, or compression to be compiled directly to WebAssembly (`.wasm`) using the FreePascal Compiler's Wasm backend.
- **Interoperability**: Seamlessly call Wasm functions directly from `.bv` component methods without the complexity of manual JavaScript wrappers.

---

### 🚀 6. SSG & Static Pre-rendering (Static Site Generation)
**Goal**: Instant first-load time (FCP < 100ms) and perfect search engine indexing (SEO).
- **Command `bv run ssg`**: Pre-renders router routes into static HTML files with initial data injected.
- **Reactive Hydration**: Upon loading in the browser, the BlaiseVue client attaches the reactive tree to pre-existing HTML without repainting the screen (zero flickering).

---

### 🧪 7. Headless End-to-End Test Driver (E2E Testing)
**Goal**: Test complete user workflows in real browsers.
- **CLI Integration**: `bv test e2e` command.
- **Critical Flow Validation**: Automated tests covering authentication, HTML5 History navigation, form submissions, modal dialog openings via `<teleport>`, and asynchronous resolution of `<suspense>`.

---

## 📅 Schedule Overview

```
[ v2.0 - Completed ✅ ]
       │
       ▼
[ v2.5 - Q1/Q2 ] ──► Form Validation Engine (b-validate)
                 ──► List Transitions (<transition-group>)
                 ──► Internationalization (Blaise-i18n)
       │
       ▼
[ v3.0 - Q3/Q4 ] ──► Documentation Generator (bv doc)
                 ──► WebAssembly Acceleration (FPC Wasm)
                 ──► SSG & Static Pre-rendering
                 ──► Automated E2E Suite
```

---

🛡️ **"Architecture is the art of making the impossible inevitable."** ✨🏆🚀
