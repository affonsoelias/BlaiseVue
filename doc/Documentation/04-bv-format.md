# 4. .bv Format (Single File Component)

The `.bv` file is the SFC format for BlaiseVue, inspired by Vue.js's `.vue` files. It combines template, logic, and style in a single file.

## Structure

```html
<template>
  <!-- Component HTML -->
</template>

<script uses="MyCustomUnit, MyHelpers">
  <!-- Pascal Logic -->
</script>

<style>
  /* Component CSS */
</style>
```

## `<template>` Section

Contains the component's HTML. It supports:

- **Interpolation:** `{{ variable }}`
- **Two-way binding:** `<input b-model="field">`
- **Events:** `<button @click="method">`
- **Attr binding:** `<div :class="className">`
- **Components:** `<my-component></my-component>`
- **Router view:** `<router-view></router-view>`

```html
<template>
  <div>
    <h1>{{ title }}</h1>
    <input type="text" b-model="name">
    <p>Hello, {{ name }}!</p>
    <button @click="greet">Click</button>
    <my-component></my-component>
  </div>
</template>
```

## `<script>` Section

Contains the component's logic in a declarative format.

### `uses` Attribute (Optional)

Imports additional **Custom Pascal Units** that are not part of the core framework.
```html
<script uses="MyBusinessLogic, DataModels">
```

> [!NOTE]
> **Automatic Units**: BlaiseVue automatically includes core units like `JS`, `Web`, `BVComponents`, `BVReactivity`, `BVStore`, `SysUtils`, and `BVRouting` (when local routes are detected). You only need the `uses` attribute for your own external `.pas` files.

### `<script lang="aether">` (Optional Aether Mode)

BlaiseVue SFCs also support writing component methods and computed helpers in **Aether** (`<script lang="aether">` or `<script lang="aether" uses="pricing, uFormatters">`):

```html
<script lang="aether" uses="pricing, uFormatters">
  data:
    unitPrice: double = 49.90;
    qty: integer = 3;

  methods:
    function computeTotal(p: Float64; q: Int32) return Float64 is
    begin
      return pricing.calculateTotal(p, q);
    end computeTotal;
</script>
```

- References in `uses="..."` automatically import `.aeth` modules from `src/services/` (or configured `paths.aether`) and generate typed wrappers for Object Pascal `.pas` services.
- See **[59. Aether Language Integration & Zephyr Native Backend](59-aether-integration-and-zephyr-backend.md)** for complete details.

### `data:` Sub-section

Defines reactive data. Format: `name: type = defaultValue;`

```
data:
  name: string = 'World';
  counter: integer = 0;
  active: boolean = True;
```

**Supported types:** `string`, `integer`, `boolean`

### `methods:` Sub-section

Defines methods in pure Pascal. Each method is a `procedure`. You can access reactive data using the `this` (or `State`) variable:

```
methods:
  procedure greet;
  begin
    window.alert('Hello!'); 
  end;

  procedure increment;
  begin
    this['counter'] := Integer(this['counter']) + 1;
  end;
```

> **Note:** BlaiseVue exposes global objects like `window`, `document`, and `console` via the `Web` unit, allowing native use without `asm`.

### `router:` Sub-section

Defines SPA routes (only in `app.bv`):

```
router:
  routes:
    '/': 'home-page';
    '/about': 'about-page';
    '/user/:id': 'user-profile-page';
```

## `<style>` Section

CSS that will be automatically injected into the page's `<head>`:

```html
<style>
  h1 { color: #42b883; }
  .container { max-width: 800px; margin: 0 auto; }
</style>
```

## Full Example

```html
<template>
  <div class="card">
    <h2>{{ title }}</h2>
    <input type="text" b-model="message">
    <p>You typed: {{ message }}</p>
    <button @click="clear">Clear</button>
  </div>
</template>

<script>
  data:
    title: string = 'My Component';
    message: string = '';

  methods:
    procedure clear;
    begin
      this['message'] := '';
    end;
</script>

<style>
  .card { border: 1px solid #ddd; padding: 20px; border-radius: 8px; }
</style>
```
