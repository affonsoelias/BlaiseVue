# 📖 BlaiseVue: API Technical Reference (v2.0)

This document is the official technical reference for all directives, components, events, hooks, compiler attributes, and global objects supported by the BlaiseVue 2.0 runtime engine.

---

## 🛡️ Structural Directives & Built-in Tags

| Directive / Tag | Description | Example |
|---|---|---|
| `b-if` | Conditional rendering (DOM creation / complete removal). | `<div b-if="show">...</div>` |
| `b-show` | Visibility toggling via inline CSS (`display: none`). | `<div b-show="visible">...</div>` |
| `b-for` | Reactive array iteration over `TJSArray` or collections. | `<li b-for="item in list">...</li>` |
| `b-model` | Two-way reactive data synchronization for form elements and custom components. | `<input b-model="name">` |
| `b-ref` | Registers an element reference into the component's `$refs` dictionary. | `<canvas b-ref="chart"></canvas>` |
| `b-slot` / `#` | Directs content into named slots or receives scoped slot parameters. | `<template #header="scope">...</template>` |
| `<teleport to="...">` | Teleports child DOM elements to an external selector outside the parent container. | `<teleport to="body">...</teleport>` |
| `<suspense>` | Coordinates asynchronous component loading with `#default` and `#fallback` slots. | `<suspense>...</suspense>` |
| `:attr` / `v-bind` | Dynamically synchronizes HTML attributes with Pascal expressions. | `<div :class="{ active: isActive }"></div>` |

---

## 🧩 Advanced Slot Syntax

| Slot Directive | Scope | Example |
|---|---|---|
| `<slot name="...">` | Child Slot Declaration | `<slot name="header"></slot>` |
| `<slot :item="...">` | Child Scoped Slot Binding | `<slot name="row" :item="user" :index="idx"></slot>` |
| `b-slot:name="scope"` | Parent Scoped Slot Receiver | `<template b-slot:row="scope">{{ scope.item.name }}</template>` |
| `#name="scope"` | Modern Shorthand Receiver | `<template #row="scope">{{ scope.item.name }}</template>` |
| `slot-scope="scope"` | Legacy Shorthand Receiver | `<template slot="row" slot-scope="scope">...</template>` |

---

## ⚡ Events, Directives & Modifiers

Events can be declared using `@`, `v-on:`, or `b-on:`. Handlers can be Pascal procedure identifiers, function calls with parameters (including `$event`), or inline expressions / statements.

| Event Directive | Modifiers | Description | Example |
|---|:---:|---|---|
| `@click` / `v-on:click` | `.stop`, `.prevent` | Triggered on mouse click with optional propagation stopping. | `<button @click.stop="doAction">` |
| `@input` / `v-on:input` | - | Continuous text or value update event. | `<input @input="onInput">` |
| `@change` / `v-on:change` | - | Form control value change confirmed. | `<select @change="onChange">` |
| `@submit` / `v-on:submit` | `.prevent` | Form submission event (can prevent default page reload). | `<form @submit.prevent="onSave">` |
| `@custom` / `v-on:custom` | `.stop`, `.prevent` | Custom component events triggered via child `$emit('custom', payload)`. | `<modal @ok="onConfirm">` |
| Inline Mutation | - | Directly mutate reactive properties inside template expressions. | `<button @click="count = (count + 1) % 100">` |

---

## 🛣️ SPA Router API (`$router`)

Configured in `app.bv` under the `router:` block and accessible via `this['$router']` in Pascal or `$router` in templates.

### Configuration Properties
- **`mode`**: `'history'` (HTML5 History API) or `'hash'` (default hash-based navigation).
- **`routes`**: Dictionary or array mapping paths to component tags, functions, or route records.
- **`children`**: Nested sub-routes rendered in inner `<router-view>` containers.
- **`beforeEach(to, from)`**: Global navigation guard executed prior to route transition.
- **`beforeEnter(to, from)`**: Route-specific navigation guard.
- **`afterEach(to, from)`**: Global hook executed after navigation completion.

### Runtime Navigation Methods
- **`$router.push(path)`**: Pushes a new URL into the browser history.
- **`$router.replace(path)`**: Replaces the active history entry.
- **`$router.back()`**: Navigates to the previous history entry.
- **`$router.currentRoute`**: Returns the active route object (`{ path, params, query }`).

---

## 🧬 Injected Global Objects

Available directly in template expressions (`{{ $obj }}`) or via `this['$obj']` in Pascal methods:

| Object | Type | Description |
|---|---|---|
| `$store` | `TBVStore` | The singleton application store for global reactive state. |
| `$router` | `TBVRouter` | The SPA router instance for programmatic navigation and route metadata. |
| `$refs` | `TJSObject` | Map of DOM elements or child component reactive instances registered with `b-ref`. |
| `$emit` | `procedure` | Dispatches custom events up to the parent component. |

---

## 🧠 Lifecycle Hooks

| Hook | Invocation Moment | Typical Usage |
|---|---|---|
| **`created`** | Reactive state initialized; DOM does not yet exist. | Initializing non-DOM data, subscribing to services. |
| **`mounted`** | Component DOM is mounted into the document. | Accessing `$refs`, initializing charts, external DOM widgets. |
| **`updated`** | Called immediately after any state change re-renders the DOM. | DOM measurements, synchronizing third-party libraries. |
| **`unmounted`** | Component removed from the DOM tree. | Clearing timers, removing global event listeners, cleanup. |

---

## 🏎️ Compiler Optimizations & HMR Runtime

| API / Marker | Layer | Description |
|---|---|---|
| `bv.isStatic = true` | Compiler Pass | Flags immutable template subtrees to skip reconciliation. |
| `bvStatic = true` | Virtual DOM Node | Node marker bypassing the reactive patch algorithm ($O(1)$ diff). |
| `bv.initHMR()` | Runtime Bridge | Connects browser client to WebSocket HMR server on port 8081. |
| `bv.patchComponent(name, newDef)` | Runtime Bridge | In-place component updater preserving `this['State']`. |
| `window.__BLAISE_DEVTOOLS_HOOK__` | DevTools Bridge | Global inspection hook for Chrome/Edge DevTools extension. |

---

🛡️ **"BlaiseVue: Stability, Typing, and Reactivity."** ✨🏆
