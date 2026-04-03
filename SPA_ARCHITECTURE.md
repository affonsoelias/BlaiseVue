# BlaiseVue SPA Architecture Guide 🛡️📖

This document explains the technical implementation of the BlaiseVue framework, focusing on the stabilization techniques used for local assets, reactivity, and component context.

## 1. Project Philosophy
BlaiseVue is a Pascal-powered SPA (Single Page Application) framework that translates Pascal code into optimized JavaScript (via `pas2js`). 

### Core Stability Rules:
*   **Zero Dependencies**: All assets (Bootstrap Icons, Bootswatch Themes, Google Fonts) are hosted locally.
*   **Canonical Scrip Tags**: Components must follow the `data:` and `methods:` script blocks for stable Proxy registration.
*   **Direct State Modification**: When using `$refs` to communicate with child components, we prioritize direct property modification on the Proxy to avoid context failures.

## 2. Key Components Breakdown

### 2.1 BIcon.bv (Local SVG Rendering)
The `b-icon` component handles iconography without external sprites or fonts. It uses **Explicit Template Rendering** via `v-if` to choose the correct SVG paths.
*   **Why?** In local `file://` environments, external SVG imports are often blocked by CORS. Hardcoded SVGs ensures 100% reliability.

### 2.2 FormHeader.bv (Proxy Context)
The `form-header` demonstrates standard Pascal methods. 
*   **Concept**: Every property in the `data:` block is automatically wrapped in a JavaScript Proxy. Changing `this['title']` triggers an immediate UI update.

### 2.3 Showcase.bv (Dynamic Themes)
The Theme Selector uses an `asm` (inline assembly) block to manipulate the DOM's `<link>` tag for CSS.
*   **Technique**: It dynamically switches the `href` attribute to point to local `.min.css` files in `assets/themes/`.

## 3. Communication Patterns

| Method | Best Practice | Rationale |
| :--- | :--- | :--- |
| **Props** | `:title="var"` | Standard one-way data flow. |
| **Events** | `$emit('event')` | Decoupled child-to-parent communication. |
| **Refs** | `header['prop'] := val` | Fast and direct state mutation for stable child updates. |

## 4. Local Environment Success
By using `v=TIMESTAMP` in the `index.html` and ensuring all paths are relative, this architectural approach guarantees that the project runs perfectly from a local folder without requiring a permanent web server.

---
*Created for study purposes - BlaiseVue v1.3.0-dev*
