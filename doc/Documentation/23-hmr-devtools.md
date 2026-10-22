# 23. Hot Module Replacement (HMR) & DevTools

BlaiseVue provides an enterprise-grade developer experience with **Hot Module Replacement (HMR)** and an official **Browser DevTools Extension (Manifest V3)**.

---

## ⚡ Part 1: Hot Module Replacement (HMR)

### The Developer Experience Challenge
In traditional web development, editing a component forces a full browser reload. This destroys user input in forms, collapses open modals, and resets application state back to the initial screen.

BlaiseVue solves this with **Instant HMR**:
- Modifying a `.bv` file re-transpiles only that specific component.
- The browser updates the DOM, styles, and methods **in-place** without reloading the page.
- The component's active reactive state (`this['State']`) is **fully preserved**.

---

### Architecture & Data Flow

```
[ Developer edits .bv file ]
           │
           ▼
[ Dev Server File Watcher ] ── (re-transpiles single .bv) ──► [ JS Patch Module ]
           │
           ▼
[ WebSocket Server :8081 ] ── (broadcasts update event) ──► [ Browser Client ]
                                                                  │
                                                                  ▼
                                                      [ bv.patchComponent(...) ]
                                                                  │
                                                      ├── Update Template DOM
                                                      ├── Update Stylesheet
                                                      ├── Update Methods
                                                      └── PRESERVE this['State']
```

---

### Running the Dev Server with HMR

Start the development server from your application directory:

```bash
bv serve
```

This launches:
- **HTTP Server**: `http://localhost:8080` (serves the SPA bundle).
- **WebSocket Server**: `ws://localhost:8081` (transmits HMR patches).
- **File Watcher**: Monitors `src/` and `lib/` for changes.

When you save any `.bv` file:
```text
[HMR] Detected change in src/components/Counter.bv
[HMR] Transpiled uCounter.js in 18ms
[HMR] Broadcasted patch to connected clients
[Browser] [HMR] Component "u-counter" successfully patched in-place (State preserved).
```

---

### In-Place State Preservation: `bv.patchComponent`

The runtime bridge in [`core/BVCompiler.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/core/BVCompiler.pas) implements `bv.patchComponent(name, newDef)`:

1. **Locates Existing Instances**: Finds all mounted DOM nodes of the component.
2. **Backs up State**: Extracts the active `this['State']` proxy dictionary.
3. **Swaps Definition**: Updates methods, computed getters, and the template render tree.
4. **Restores State**: Re-attaches the existing `this['State']` to the updated instance.
5. **Re-renders**: Triggers a fast reactivity cycle with the new template without losing form values or counters.

---

## 🕵️ Part 2: Official Browser DevTools Extension

BlaiseVue includes a dedicated DevTools browser extension located in the [`devtools/`](file:///c:/Users/Pichau/Documents/BlaiseVue/devtools/) directory.

```
devtools/
├── manifest.json       # Manifest V3 configuration
├── background.js       # Service worker background bridge
├── devtools.html       # Entry point for Chrome DevTools
├── devtools.js         # Panel registration script
├── panel.html          # DevTools UI layout
└── panel.js            # Reactive Tree, State Inspector & Timeline logic
```

---

### Key DevTools Features

1. **🌳 Component Tree Inspector**:
   - Visualizes the complete hierarchical tree of mounted components (`<app>`, `<router-view>`, child components).
   - Clicking a component highlights its physical boundaries on the live webpage.

2. **🔍 Live State Inspector & Editor**:
   - Inspect all fields declared in `data:`, `props:`, and `computed:`.
   - Edit values directly in the DevTools panel to test reactive behavior in real time.

3. **🧠 Global Store ($store) Inspector**:
   - Displays all state variables stored in `TBVStore`.
   - Tracks real-time mutations triggered by actions across components.

4. **⏱️ Event & Router Timeline**:
   - Logs user interactions (`@click`, `@input`), custom `$emit` events, and router navigation hooks (`beforeEach`, route transitions).

---

### Installing the DevTools Extension (Developer Mode)

To install the extension in **Google Chrome**, **Microsoft Edge**, or **Brave**:

1. Open your browser and navigate to:
   - Chrome: `chrome://extensions/`
   - Edge: `edge://extensions/`
2. Enable **Developer mode** (toggle switch in the top-right corner).
3. Click the **Load unpacked** button.
4. Browse to and select the `devtools/` folder in your BlaiseVue directory:
   ```text
   C:\Users\Pichau\Documents\BlaiseVue\devtools\
   ```
5. Open your BlaiseVue application (`http://localhost:8080`), press `F12` to open DevTools, and click on the **🛡️ BlaiseVue** tab!

---

## 🛠️ DevTools Hook API

The framework exposes a global hook on `window.__BLAISE_DEVTOOLS_HOOK__`. This allows automated test suites or custom diagnostic scripts to communicate with the application:

```javascript
// Example: Inspecting mounted components programmatically
if (window.__BLAISE_DEVTOOLS_HOOK__) {
  console.log("Mounted Components:", window.__BLAISE_DEVTOOLS_HOOK__.getComponentTree());
  console.log("Global Store:", window.__BLAISE_DEVTOOLS_HOOK__.getStoreState());
}
```
