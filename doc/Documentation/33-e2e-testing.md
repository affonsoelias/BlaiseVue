# 🧪 Headless End-to-End Test Suite (`bv test e2e`)

BlaiseVue 3.0 introduces native support for **End-to-End (E2E) and Integration Testing**, ensuring critical user journeys work reliably across routing, form submissions, theme switches, and hydration.

---

## 🌟 Overview

While unit tests (`.test.pas`) verify isolated procedures and component reactivity, E2E tests ensure that the entire stack functions as a cohesive application:
- Navigation through History API routes without page reloads.
- Complex validation sequences (`b-validate`) updating `$errors` and preventing invalid form submits.
- Zero-flicker Reactive Hydration of pre-rendered SSG markup.
- Theme switching and persistence across sessions.

---

## 🛠️ Usage

To run the automated E2E test suite:
```bash
bv test e2e
```

The test runner will compile and execute end-to-end integration flows:
```text
=== BlaiseVue 3.0 Headless E2E Test Suite ===
Executing end-to-end user journeys (Routing, Forms, Themes, Hydration)...

 RUN  v3.2.4 C:/Users/Pichau/Documents/BlaiseVue/demo-app

[Hydration] SSG pre-rendered content detected on #app-ssg-test. Engaging Reactive Hydration...
[Create] Instance ready.

 ✓ generated/tests/wasm_ssg.test.js (7 tests) 39ms

 Test Files  1 passed | 11 skipped (12)
      Tests  7 passed | 123 skipped (130)
```
