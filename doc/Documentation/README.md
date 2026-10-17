# 🛡️ BlaiseVue Framework v3.5
**The Universal Pascal Platform: Web, Mobile, Desktop, and Full-Stack.**

BlaiseVue is an enterprise-grade, reactive framework that combines the strong typing and architectural robustness of **Object Pascal** with the simplicity, ergonomics, and reactivity of **Vue.js**.

---

## ⚔️ What's New in Version 3.5 (The Universal Release)

BlaiseVue 3.5 expands the platform across multiple form factors:

- 📱 **Hybrid Mobile Platform (Capacitor & Android .apk)**: Full native Android/iOS compilation via `bv mobile [init|sync|open|build]` with APK generation.
- 🛠️ **Professional DX & VS Code Extension (`.vsix`)**: Triple syntax highlighting for `.bv`, directive IntelliSense, BlaiseUI autocomplete, and snippets (`bv vsix`, `bv extension install`).
- 🎨 **Responsive Grid System (`<bv-container>`, `<bv-row>`, `<bv-col>`)**: Fluid 12-column grid layout fully adaptable from mobile phones to 4K displays.
- 🧭 **Mobile Bottom Navigation & Drawer**: Native mobile UX with `<bv-bottom-nav>`, `<bv-bottom-nav-item>`, and responsive off-canvas `<bv-drawer>`.
- ⚡ **WebAssembly Acceleration Engine (`BVWasm` / `$wasm`)**: Run compute-intensive Pascal routines at native binary speed.
- 📚 **Automatic Component Documentation & Playground (`bv doc`)**: Zero-configuration catalog analyzing component AST, props, and events.
- 🚀 **SSG & Static Pre-rendering (`bv run ssg`)**: Instant First Contentful Paint with Zero-Flicker Reactive Hydration.
- 🎨 **Bootswatch Themes & Theme Engine (`$theme`)**: 9 integrated themes with runtime switching and dark mode toggle.
- 🧪 **Vitest Pascal Test Suite (100% Pass Rate)**: Automated TDD with JSDOM runner via `bv test`.

---

## 📚 Complete Documentation Index

### 🏁 Getting Started & Core Fundamentals
1. [01. Architecture and Mission](01-introduction.md)
2. [02. Installation & SDK Setup](02-installation.md)
3. [03. BlaiseCLI Technical Manual (bv.exe)](03-cli.md)
4. [04. Single File Component (.bv) Format](04-bv-format.md)
5. [05. The Reactive Engine & Proxies](05-reactivity.md)
6. [06. Data Binding & Interpolation](06-data-binding.md)
7. [07. Methods & Event Handling](07-methods-events.md)
8. [08. Component Basics & SFC](08-components.md)

### 🧭 Navigation & Project Organization
9. [09. Advanced SPA Router (History & Nested)](09-router.md)
10. [10. Standard Project Structure](10-project-structure.md)
11. [11. Props, Refs, and Custom Events ($emit)](11-props-refs-emit.md)
12. [12. Debugging & Error Handling](12-debugging.md)

### 💎 Advanced Composition & Enterprise Architecture
13. [13. Advanced Slots & Scoped Slots](13-advanced-slots.md)
14. [14. CSS Transitions & Animations](14-css-transitions.md)
15. [15. Global State Management ($store)](15-global-store.md)
16. [16. Dependency Injection (Provide / Inject)](16-provide-inject.md)
17. [17. Advanced Component Lifecycle Hooks](17-lifecycle-pro.md)
18. [18. External Libraries & Setup Scripts (/lib)](18-external-libraries.md)

### 🚀 BlaiseVue 2.0 & 2.5 Features & Tooling
19. [19. Unit Testing with Vitest](19-unit-testing.md)
20. [20. Extra-Official Libraries (Bootstrap & Charts)](20-extra-libraries.md)
21. [21. Teleport & Suspense](21-teleport-suspense.md)
22. [22. Static Hoisting & Compiler Optimization](22-static-hoisting.md)
23. [23. Hot Module Replacement (HMR) & DevTools](23-hmr-devtools.md)
24. [24. BlaiseUI (Official Component Kit)](24-blaise-ui.md)
25. [25. Form Validation Engine (b-validate)](25-form-validation.md)
26. [26. List Transitions (<transition-group>)](26-transition-group.md)
27. [27. Integrated Internationalization (Blaise-i18n)](27-i18n.md)
28. [28. Themes & Bootswatch Integration ($theme)](28-themes.md)
29. [29. Blaise Icons & Bootstrap Icons (bv-icon)](29-icons.md)

### ⚡ BlaiseVue 3.0 Next-Gen Features
30. [30. WebAssembly Acceleration Engine (BVWasm)](30-wasm-acceleration.md)
31. [31. Automatic Documentation Generator & Playground (bv doc)](31-doc-generator.md)
32. [32. SSG & Static Pre-rendering with Reactive Hydration](32-ssg-and-hydration.md)
33. [33. Headless End-to-End Test Suite (bv test e2e)](33-e2e-testing.md)

### 🚀 BlaiseVue 3.5 Universal Platform (Phase 1 & Phase 2)
34. [34. VS Code Extension & Professional DX (.vsix) - Phase 1](34-vscode-extension.md)
35. [35. Hybrid Mobile Platform & Capacitor (bv mobile) - Phase 2](35-mobile-capacitor.md)

### 📖 References & Roadmaps
- [API Technical Reference](api-reference.md)
- [Technical Roadmap (v3.0 & v3.5)](99-roadmap-v3.md)

---

## 🛠️ CLI Quick Reference

```bash
# Start development server with instant HMR and WebSocket
bv serve

# Run express development build with cache busting
bv run dev

# Run automated unit test suite with Vitest
bv test

# Scaffold a new unit test in tests/
bv new t MyComponent

# Build optimized production bundle
bv run build

# Clean build artifacts (dist/ and generated/)
bv clean
```

---

## 🚀 Quick Start Example

```html
<!-- src/views/Home.bv -->
<template>
  <div class="welcome-box">
    <h1>{{ greeting }}</h1>
    <bv-btn variant="primary" @click="incrementCount">
      Clicked {{ counter }} times
    </bv-btn>
  </div>
</template>

<script>
  data:
    greeting: string = 'Welcome to BlaiseVue 2.0!';
    counter: integer = 0;

  methods:
    procedure incrementCount;
    begin
      Inc(counter);
    end;
</script>

<style>
  .welcome-box {
    padding: 32px;
    text-align: center;
  }
</style>
```

---

🛡️ **"BlaiseVue: Stability, Typing, and Reactivity."**  
_In Pascal we trust._ 🛡️✨🏆
