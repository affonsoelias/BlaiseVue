# 8. Components

Components are reusable interface blocks with isolated state. In BlaiseVue, all components are automatically **globally registered**.

## Creating a Component

### Via CLI
```bash
bv new c MyComponent
```
Creates `src/components/MyComponent.bv`.

### Manually
Just create a `.bv` file in `src/components/`. The compiler will detect it and make it available throughout the project.

```html
<!-- src/components/Counter.bv -->
<template>
  <div class="counter">
    <span>{{ value }}</span>
    <button @click="plus">+</button>
    <button @click="minus">-</button>
  </div>
</template>

<script>
  data:
    value: integer = 0;

  methods:
    procedure plus;
    begin
      this['value'] := Integer(this['value']) + 1;
    end;

    procedure minus;
    begin
      this['value'] := Integer(this['value']) - 1;
    end;
</script>
```

## Using a Component

Use the corresponding HTML tag inside any template:

```html
<template>
  <div>
    <h1>My Page</h1>
    <counter></counter>
    <counter></counter>
  </div>
</template>
```

Each `<counter>` has its **own state**. Clicking the "+" on one does not affect the others.

## Automatic Global Registration

Unlike other frameworks where you need to `import` and register (`components: { ... }`), in BlaiseVue every file inside `src/components/` or `src/views/` is globally registered by the CLI at build time.

This means a component can use another without any extra declaration.

## Sub-components (Nesting)

You can use components inside other components to create complex interfaces:

```html
<!-- src/components/NavBar.bv -->
<template>
  <nav>
    <logo-icon></logo-icon> <!-- Sub-component -->
    <div class="links">
      <a href="#/">Home</a>
    </div>
  </nav>
</template>
```

## Naming Convention

| File | HTML Tag |
|---------|----------|
| `Counter.bv` | `<counter>` |
| `InfoCard.bv` | `<info-card>` |
| `NavBar.bv` | `<nav-bar>` |
| `FormHeader.bv` | `<form-header>` |

The conversion is **PascalCase → kebab-case**.

## Isolated State

Each component instance has its own data. This happens because `data:` generates a **function** that returns a new object for each call in the Pascal runtime:

```pascal
// Automatically generated:
comp['data'] := function(): TJSObject
var d: TJSObject;
begin
  d := TJSObject.new;
  d['value'] := 0;      
  Result := d;
end;
```

---

## Multi-Root Components (Vue 3-Style Fragments)

In BlaiseVue, component templates **do not require a single wrapper `<div>`**. You can declare multiple sibling root elements directly inside `<template>`, just like in Vue 3:

```html
<!-- src/components/PageShell.bv -->
<template>
  <header class="app-header">{{ title }}</header>
  <main class="app-content">
    <slot></slot>
  </main>
  <footer class="app-footer">© BlaiseVue</footer>
</template>
```

### How Fragments Work in the DOM
- **Single-Root Fast Path**: If a component has only one root element, BlaiseVue replaces the custom tag directly with that element (`replaceChild`) with zero extra overhead.
- **Multi-Root Comment Anchors**: If a component has multiple root elements, BlaiseVue uses the native HTML5 `<template>` parser and mounts the sibling nodes bounded by lightweight comment anchors:
  ```html
  <!-- [bv-fragment: page-shell] -->
  <header class="app-header">Dashboard</header>
  <main class="app-content">...</main>
  <footer class="app-footer">© BlaiseVue</footer>
  <!-- [/bv-fragment] -->
  ```
- **Native Table & List Elements (`<tr>`, `<td>`, `<li>`)**: Because templates are parsed via native HTML5 `<template>` (`DocumentFragment`), components can return bare `<td>` cells or `<tr>` rows inside `<table>` / `<tbody>` without the browser stripping tags or breaking CSS Grid / Flexbox layouts:
  ```html
  <!-- src/components/UserCells.bv -->
  <template>
    <td class="cell-name">{{ name }}</td>
    <td class="cell-role">{{ role }}</td>
  </template>
  ```

### Attribute Fallthrough & `$attrs`

When a parent passes HTML attributes (`class`, `style`, `id`, `data-*`, `aria-*`) or native event listeners (`@click`) to a component:

1. **Automatic Fallthrough (Default)**:
   Without any extra configuration, non-prop attributes in `$attrs` automatically fall through onto the **first visible element** of the component (merging `class` and `style` with the element's existing classes and styles):
   ```html
   <page-shell class="theme-dark" id="main-shell" data-testid="shell"></page-shell>
   <!-- Applied automatically to <header class="app-header theme-dark" id="main-shell" data-testid="shell"> -->
   ```

2. **Explicit Target via `b-bind="$attrs"` (or `v-bind="$attrs"`)**:
   If you want fallthrough attributes applied to a specific sibling or inner element instead of the first root element, add `b-bind="$attrs"` to the desired target element:
   ```html
   <template>
     <header class="app-header">{{ title }}</header>
     <main class="app-content" b-bind="$attrs">
       <slot></slot>
     </main>
     <footer class="app-footer">© BlaiseVue</footer>
   </template>
   ```
   When `b-bind="$attrs"` is present in the template, BlaiseVue disables automatic fallthrough on the first root element and applies `$attrs` exclusively to the marked element(s).
