# 🛡️ BlaiseCLI Technical Manual (bv.exe)

The `bv.exe` is the native orchestrator of BlaiseVue, responsible for transpiling SFC components, managing libraries, and orchestrating the build cycle.

---

## 🏗️ Development and Build Commands

### `bv run dev` (Express Development)
Executes a full build and activates real-time debugging features.
- **Cache Busting (v=123...)**: Rewrites all script and style links in `index.html` by injecting a timestamp-based version parameter to bypass browser caching.
- **Unit DevTools**: Automatically injects and activates the diagnostic sidebar (`BVDevTools`).
- **Debugging Flags**: Compiles Pascal with debug symbols and verbose output in the browser console.

### `bv run build` (Optimized Production)
Generates the final bundle for deployment.
- **Purge Artifacts**: Cleans up debug files and experimental units.
- **Optimized RTL**: Links only the necessary units.

---

## 🧪 Unit Testing Arsenal

The `bv test` command centralizes the execution of automated unit tests supported by the `BVTestUtils.pas` unit.

### `bv test`
Transpiles all components, compiles the `.pas` test units in `tests/` to JS, and executes the suite via **Vitest**.

### `bv new t <Name>`
Instant scaffolding for unit test files.
- **Example**: `bv new t User` creates the `tests/User.test.pas` file with the correct template.

### `bv list t`
Lists all unit tests currently registered in the `tests/` folder.

### `bv remove t <Name>`
Safely removes a test file and its transpiled artifacts.

---

## 📦 /lib Folder Management

BlaiseVue PRO 1.0 introduces intelligent management of external libraries:
- **Auto-Autoload**: Any `.bv` files within the `lib/` folder (or subdirectories) are registered as global components in the project.
- **Asset Injection**: `.css` and `.js` files detected in the `lib/` folder are automatically injected into the `<head>` of the generated `index.html` in `dist/`.
- **Interactive Setup (`bv s <name>`)**: Triggers an interactive installation/cleanup menu for libraries that follow the **[setup.pas standard](18-external-libraries.md)**.

---

---

## 🛠️ Maintenance Commands

### `bv clean`
Complete cleanup of the build environment:
1. Purges the `generated/` folder.
2. Purges the `dist/js/` and `dist/css/` folders.
3. Resets the `index.html` in `dist/` to the original state in `public/`.

---

## ⚡ CLI Performance
The CLI compiler is written entirely in **Native Pascal**, ensuring an SFC component processing speed up to **50x faster** than competing tools based on Node.js or traditional bundlers. 🛡️✨🏆
