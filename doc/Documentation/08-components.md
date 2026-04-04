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
