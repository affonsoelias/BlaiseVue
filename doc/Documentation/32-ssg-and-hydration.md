# 🚀 SSG & Static Pre-rendering with Reactive Hydration

BlaiseVue delivers **Static Site Generation (SSG)** and **Zero-Flicker Reactive Hydration**, achieving ultra-fast First Contentful Paint times (<50ms) and complete SEO crawlability.

---

## 🌟 The Challenge of Traditional SPAs

In standard Client-Side Single Page Applications (SPAs):
1. The browser requests `index.html`, which contains an empty `<div id="app"></div>`.
2. The user sees a blank screen until the JavaScript bundle (`main.js` and `rtl.js`) finishes downloading, parsing, and executing.
3. Search engines and web crawlers may fail to index dynamic content.

---

## ⚡ The BlaiseVue SSG Solution

With `bv run ssg`, BlaiseVue statically evaluates your routing tree (`src/app.bv`) at build time:
- Each route is pre-rendered into its own static HTML file (`dist/index.html`, `dist/about.html`, `dist/form.html`, etc.).
- The pre-rendered markup is injected directly into `<div id="app" data-bv-ssg="true">...</div>`.
- When the visitor opens the page, the browser paints the complete layout **instantly (FCP < 50ms)**.

---

## 🌊 Reactive Hydration Engine

When the BlaiseVue runtime boots in the browser:
1. `TBlaiseVue.Create` inspects the root element `#app`.
2. If `data-bv-ssg="true"` is detected:
   ```text
   [Hydration] SSG pre-rendered content detected on #app. Engaging Reactive Hydration...
   ```
3. Instead of wiping `innerHTML = ''` and re-creating DOM elements from scratch (which causes visual layout shift and flickering), the **Hydration Engine** adopts the existing DOM nodes:
   - Event listeners (`@click`, `@input`) are attached directly to existing buttons and inputs.
   - Reactive data proxies and expressions are wired up seamlessly.
   - The user experiences an instantaneous, fully interactive application with **zero screen flicker**.

---

## 🛠️ Usage

To build your application with SSG pre-rendering:
```bash
bv run ssg
```

Console Output:
```text
=== BlaiseVue Static Site Generator (SSG & Pre-rendering) ===
  Parsed app routes: 8 route(s) registered.
  [1/2] Running production compilation...
  [2/2] Pre-rendering route views into static HTML...
    - Pre-rendered route: / -> dist/index.html
    - Pre-rendered route: /about -> dist/about.html
    - Pre-rendered route: /form -> dist/form.html
    - Pre-rendered route: /pro -> dist/pro.html
    - Pre-rendered route: /bootstrap -> dist/bootstrap.html
    - Pre-rendered route: /charts -> dist/charts.html
    - Pre-rendered route: /showcase -> dist/showcase.html

=== SSG Pre-rendering completed successfully! ===
All routes are pre-rendered for instant First Contentful Paint (<50ms).
```
