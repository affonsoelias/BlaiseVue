# 🛡️ BlaiseVue Framework v1.0.0 PRO
**The Power of Pascal, the Soul of Vue.**

BlaiseVue is a modern, reactive SPA (Single Page Application) framework that brings the power of strong typing from **Object Pascal** to the Web ecosystem, inspired by the simplicity and elegance of Vue.js.

---

## ⚔️ The B Standard (v1.0 PRO)
In this Pro version, BlaiseVue reaches maturity with enterprise-level architecture features and advanced productivity tools.

### 🔥 New in Version 1.0:
- **Testing Arsenal (`bv test`)**: Native suite for TDD (Test Driven Development) in Pascal.
- **Intelligent Cache Busting**: The development build automatically injects timestamps (`v=123...`) to avoid browser cache issues.
- **Advanced Dynamic Routing**: Full support for URL parameters (`:id`) and integrated Query Strings in `data:`.
- **Global Store ($store)**: Shared state management via `TBVStore` (Singleton).
- **Named Slots & Transitions**: Flexible composition and native CSS enter/exit animations.
- **Provide/Inject**: Communication between distant components without "prop drilling".
- **External Libraries (/lib)**: Autoloading of assets (CSS/JS) and external `.bv` components.

---

## 📦 External Libraries (/lib)
BlaiseVue PRO allows you to easily integrate third-party components and CSS:
- **Auto-Link**: `.css` files in the `lib/` folder are automatically injected into `index.html` during build.
- **Auto-Registration**: Any `.bv` within `lib/` (or subfolders) is globally registered.
- **External JS**: `.js` files in `lib/` are included as scripts in the header.

---

## 🧠 Global State ($store)
Centralize your data with **B-Store**, accessible in any component via `$store` in the template or `this['$store']` in Pascal.

```html
<template>
  <div>App Version: {{ $store.appVersion }}</div>
</template>
```

---

## 🧪19. [Unit Testing (Vitest)](19-unit-testing.md)
20. [Extra-Official Libraries (Bootstrap & Charts)](20-extra-libraries.md)
s for your components and business logic directly in Pascal:

```pascal
begin
  Describe('My Component', procedure
    begin
       It('should validate the initial state', procedure
         begin
            Expect(myVar).ToEqual(True);
         end);
    end);
end.
```

---

## 🛠️ CLI Tools (bv.exe)
- **`bv run dev`**: Fast build with active debugging and timestamp injection.
- **`bv test`**: Runs the test suite with **Vitest** integration.
- **`bv new t <Name>`**: Creates a new unit test file template.
- **`bv clean`**: Purges the `dist/` and `generated/` folders for a clean build.

---

## 🚀 How to Start

1.  Clone the repository.
2.  Navigate to the `demo-app` folder.
3.  Run `..\bin\bv.exe run dev`.
4.  Open `dist/index.html` in your browser.

---

**BlaiseVue: Stability, Typing, and Reactivity.**  
Developed by you and stabilized by AI. _"In Pascal we trust."_ 🛡️✨
