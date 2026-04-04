# 📖 BlaiseVue: API Technical Reference (v1.0.0 PRO)

This document is the official source for directives, events, hooks, and global objects supported by the BlaiseVue reactivity engine.

---

## 🛡️ Structural and Flow Directives

| Directive | Description | Example |
|----------|-----------|---------|
| `b-if` | Conditional rendering (Full removal from the DOM). | `<div b-if="show">...</div>` |
| `b-show` | Visibility toggling (via CSS `display:none`). | `<div b-show="visible">...</div>` |
| `b-for` | Reactive list iteration (TJSArray). | `<li b-for="item in list">...</li>` |
| `b-model` | Two-way binding for inputs (and custom components). | `<input b-model="name">` |
| `b-ref` | Registers a reference in the component's `$refs` object. | `<canvas b-ref="chart"></canvas>` |
| `b-slot` | Defines the target for content injected by the parent. | `<slot name="header"></slot>` |
| `:attr` / `v-bind` | Synchronizes HTML attributes with Pascal expressions. | `<div :class="{active: isActive}"></div>` |

---

## ⚡ Events and Modifiers

Events are prefixed with `@` and can call Pascal procedures directly or execute inline expressions.

| Event | Modifiers | Description |
|--------|---------------|-----------|
| `@click` | `.stop`, `.prevent` | Triggered on click (supports propagation). |
| `@input` | - | Continuous update of text fields. |
| `@change` | - | Confirmed value change (focus lost). |
| `@custom` | - | Events triggered via `$emit(name, value)`. |

---

## 🧬 Injected Global Objects

Accessible via `{{ double-mustache }}` in the template or `this['$obj']` in Pascal.

- **`$store`**: Access to the global **B-Store** (Shared state).
- **`$router`**: Access to the SPA router (Navigation, Params).
- **`$refs`**: Dictionary of elements marked with `b-ref`.
- **`$emit`**: Procedure to trigger events to the parent component.

---

## 🧠 Lifecycle (Hooks)

| Hook | Execution Moment |
|------|---------|
| **`created`** | Data and reactivity initialized. DOM does not yet exist. |
| **`mounted`** | Component inserted into the document. Safe to use `$refs`. |
| **`updated`** | Called after any data change updates the DOM. |
| **`unmounted`** | Component removed from the tree. Cleanup of timers and listeners. |

---

## 🔗 Inter-Component Communication

- **`props`**: Data passed from Parent to Child (Downward flow).
- **`provide`**: Data made available by an ancestor to all its descendants.
- **`inject`**: Receives data provided by a distant ancestor (Resolves "prop drilling").

---
🛡️ **"BlaiseVue: Stability, Typing, and Reactivity."** ✨🏆
