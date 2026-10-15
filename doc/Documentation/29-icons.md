# 29. Blaise Icons & Bootstrap Icons (`blaise-icons`)

BlaiseVue 2.6 introduces the **`blaise-icons`** package, providing access to over 1,800+ vector icons powered by Bootstrap Icons, with zero external CDN dependency and complete backwards compatibility with the `<bv-icon>` component.

---

## 1. Overview & Architecture

The icon system combines two distinct advantages:

1. **Embedded SVGs for core icons**: Zero HTTP requests, instant rendering, perfectly crisp at any resolution.
2. **Webfont suite for 1,800+ Bootstrap icons**: Complete icon palette with search, alerts, media controls, symbols, and arrows.

```html
<!-- Built-in vector SVG: renders directly into the DOM -->
<bv-icon name="check-circle" size="20" color="#28a745"></bv-icon>

<!-- Full Bootstrap Icon suite: renders as <i class="bi bi-star-fill"> -->
<bv-icon name="star-fill" size="24" color="#ffc107"></bv-icon>
<bv-icon name="shield-check" size="22" color="#0d6efd"></bv-icon>
```

---

## 2. Installing Icons via CLI

To install the official icon suite into your BlaiseVue project, run:

```bash
bv lib install icons
```

This installs:
- `lib/icons/bootstrap-icons.min.css`
- `lib/icons/fonts/bootstrap-icons.woff2`
- `lib/icons/fonts/bootstrap-icons.woff`

---

## 3. Registering the Stylesheet in `index.html`

In `public/index.html`:

```html
<link rel="stylesheet" href="lib/icons/bootstrap-icons.min.css">
```

---

## 4. Component Usage (`<bv-icon>`)

### 4.1. Supported Props

| Prop | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | `'check-circle'` | Icon name (e.g. `'star-fill'`, `'gear'`, `'heart'`, `'search'`) |
| `size` | `string` | `'16'` | Pixel size (width/height or font-size) |
| `color` | `string` | `''` | CSS color (hex, rgb, or color name) |

### 4.2. Example Template

```html
<template>
  <div class="card p-3">
    <div class="d-flex align-items-center gap-3">
      <bv-icon name="star-fill" size="28" color="#ffc107"></bv-icon>
      <div>
        <h5 class="m-0">Favorite Project</h5>
        <small class="text-muted">Updated today</small>
      </div>
      <button class="btn btn-sm btn-outline-danger ms-auto">
        <bv-icon name="trash" size="16"></bv-icon> Delete
      </button>
    </div>
  </div>
</template>
```

---

## 5. Built-in Standalone SVG Icons

The following icons are also compiled as standalone SVGs inside `<bv-icon>`:
- `check-circle`
- `warning`
- `gear-fill`
- `heart-fill`
- `weather`
- `code-slash`
- `cpu`
- `bootstrap-fill`

For all other names (e.g. `sun-fill`, `moon-fill`, `folder`, `bell`, `lightning-charge-fill`), `<bv-icon>` automatically renders the corresponding Bootstrap icon class (`bi bi-<name>`).
