# 21. Teleport & Suspense

BlaiseVue 2.0 introduces **Teleport** and **Suspense**, two powerful directives designed for advanced DOM management and asynchronous component orchestration.

---

## 🚀 1. Teleport (`<teleport to="...">`)

### What is Teleport?
In modern Single Page Applications, certain UI elements like **Modals**, **Dialogs**, **Tooltips**, and **Toasts** logically belong to a specific component, but physically must be rendered outside of the component's DOM container (often directly under `document.body` or a dedicated `#overlay` div) to avoid CSS `z-index`, `overflow: hidden`, or `transform` clipping issues.

The `<teleport>` component allows you to specify a target CSS selector where the rendered DOM tree should be teleported, while preserving the reactive state, event listeners, and Pascal lifecycles within the original component hierarchy.

### Syntax and Target Selector
```html
<teleport to="targetSelector">
  <!-- Content to be rendered inside targetSelector -->
</teleport>
```
The `to` attribute accepts any valid CSS selector, such as:
- `to="body"` — Appends the content to `document.body`.
- `to="#modal-root"` — Appends to an element with `id="modal-root"`.
- `to=".floating-layer"` — Appends to the first element matching the class.

### Complete Example: Reactive Modal with Teleport
```html
<!-- src/components/ConfirmModal.bv -->
<template>
  <div>
    <button @click="openModal">Open Dialog</button>

    <teleport to="body">
      <div b-if="isOpen" class="modal-backdrop">
        <div class="modal-dialog">
          <h3>{{ title }}</h3>
          <p>{{ message }}</p>
          <div class="modal-actions">
            <button @click="confirm">Confirm</button>
            <button @click="closeModal">Cancel</button>
          </div>
        </div>
      </div>
    </teleport>
  </div>
</template>

<script>
  data:
    isOpen: boolean = false;
    title: string = 'Security Confirmation';
    message: string = 'Are you sure you want to proceed?';

  methods:
    procedure openModal;
    begin
      isOpen := true;
    end;

    procedure closeModal;
    begin
      isOpen := false;
    end;

    procedure confirm;
    begin
      console.log('Action confirmed!');
      closeModal;
    end;
</script>

<style>
  .modal-backdrop {
    position: fixed;
    top: 0;
    left: 0;
    width: 100vw;
    height: 100vh;
    background: rgba(0, 0, 0, 0.5);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 9999;
  }
  .modal-dialog {
    background: #ffffff;
    padding: 24px;
    border-radius: 8px;
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.2);
  }
</style>
```

### Key Teleport Behaviors
1. **State Preservation**: Any mutation to `isOpen`, `title`, or `message` reacts immediately inside the teleported DOM element.
2. **Event Bubbling**: Events triggered inside the teleported elements execute Pascal methods on the component that declared them.
3. **Automatic Cleanup**: When the host component is unmounted from the application, the teleported nodes in `document.body` are cleanly removed.

---

## ⏳ 2. Suspense (`<suspense>`)

### What is Suspense?
When building data-driven applications or using **Dynamic Code-Splitting** (lazy-loading components), components often require asynchronous operations (fetching network data, loading remote JavaScript bundles) before they can be rendered.

Without Suspense, every component must manage its own `isLoading` flags, skeleton loaders, and error boundaries manually.

`<suspense>` coordinates asynchronous dependencies in the component tree. It exposes two slots:
- **`#default`**: Rendered once all asynchronous operations (Promises) have resolved.
- **`#fallback`**: Rendered automatically while pending/loading.

### Syntax
```html
<suspense>
  <template #default>
    <!-- Asynchronous component or dynamic content -->
  </template>
  <template #fallback>
    <!-- Fallback UI shown while resolving (spinner, skeleton) -->
  </template>
</suspense>
```

### Complete Example: Lazy Component Loading with Suspense
```html
<!-- src/views/Dashboard.bv -->
<template>
  <div class="dashboard-page">
    <h2>Analytics Dashboard</h2>

    <suspense>
      <template #default>
        <async-user-stats></async-user-stats>
      </template>

      <template #fallback>
        <div class="loading-skeleton">
          <div class="spinner"></div>
          <p>Loading analytics and data from server...</p>
        </div>
      </template>
    </suspense>
  </div>
</template>

<script>
  data:
    pageLoaded: boolean = true;
</script>

<style>
  .loading-skeleton {
    padding: 32px;
    text-align: center;
    background: #f8fafc;
    border-radius: 8px;
  }
  .spinner {
    width: 32px;
    height: 32px;
    border: 3px solid #cbd5e1;
    border-top-color: #3b82f6;
    border-radius: 50%;
    animation: spin 1s linear infinite;
    margin: 0 auto 12px;
  }
  @keyframes spin {
    to { transform: rotate(360deg); }
  }
</style>
```

### How BlaiseVue Suspense Resolves Under the Hood
1. When `<suspense>` mounts, it checks child nodes for pending Promises (e.g. from dynamic `import()` or async initialization hooks).
2. If any Promise is pending, it displays the `#fallback` slot.
3. Upon Promise fulfillment (`Promise.all` resolution), it gracefully mounts the `#default` slot into the DOM and cleans up the fallback.

---

## 🛡️ Summary

| Directive | Purpose | Primary Use Cases |
|---|---|---|
| `<teleport to="...">` | Move DOM elements to an external selector outside the parent layout | Modals, Tooltips, Toasts, Dropdown menus |
| `<suspense>` | Handle asynchronous component dependencies with loading fallbacks | Lazy-loaded routes, async data widgets, skeletons |
