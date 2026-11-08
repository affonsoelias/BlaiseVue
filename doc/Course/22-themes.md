# 🎨 Module 22: Blaise UI Design System & Themes
**Build beautiful, responsive user interfaces with the official BlaiseUI component suite and Bootswatch themes.**

A great enterprise application needs more than raw business logic: it needs polished visual presentation, coherent brand styling, responsive mobile-to-desktop layouts, and seamless Dark/Light mode switching.

Rather than writing hundreds of lines of custom CSS, BlaiseVue provides **`@blaise-ui`** and **`@blaise-themes`**—official design system packages integrated with Bootswatch and Bootstrap 5 standards.

---

## 📦 1. Installing UI & Themes via the CLI

Install the official design packages into your project using the package manager:

```bash
# Install the official themes suite
bv lib install themes
# (Aliases: bv lib install blaise-themes | bv lib install @blaise-themes)

# Install the official UI component suite
bv lib install ui
# (Aliases: bv lib install blaise-ui | bv lib install @blaise-ui)
```

This installs:
- 9 curated Bootswatch themes in `lib/themes/` (Light, Dark, and Cyber styles).
- Pre-built responsive Pascal Single File Components (`<bv-button>`, `<bv-card>`, `<bv-modal>`, `<bv-alert>`, `<bv-badge>`, etc.).
- Reactive theme switcher engine `core/BVTheme.pas`.

---

## 🎭 2. The Theme Catalog

The `@blaise-themes` package includes both light and dark design profiles:

| Theme | Profile | Visual Style |
|---|---|---|
| **flatly** | Light *(Default)* | Clean, modern, flat enterprise styling |
| **cosmo** | Light | Metropolitan, crisp typography |
| **lux** | Light | High-end luxury typography with serif accents |
| **zephyr** | Light | Soft, rounded cards with gentle pastel borders |
| **darkly** | Dark | Elegant, low-contrast dark mode |
| **cyborg** | Dark | High-contrast jet black with neon blue accents |
| **solar** | Dark | Soothing dark palette inspired by Solarized Dark |
| **vapor** | Retro / Neon | Synthwave / 80s cyberpunk gradient aesthetics |
| **pulse** | Vibrant | Lively purple accents, ideal for creative apps |

---

## 🛠️ 3. Managing Themes from the Terminal (`bv theme`)

The BlaiseVue CLI allows you to inspect, activate, and optimize themes directly from your terminal:

```bash
# 1. List active configuration and available themes
bv theme list

# 2. Switch the active default theme
bv theme use darkly

# 3. Whitelist themes for production build-time tree-shaking
bv theme add darkly
bv theme add flatly
```

When you run `bv theme use darkly`:
1. `package.json` updates its default `"theme": "darkly"` setting.
2. `public/index.html` updates the active stylesheet link:  
   `<link id="bv-theme" rel="stylesheet" href="lib/themes/darkly.min.css">`.

---

## ⚡ 4. Reactive Runtime Theme Switching (`$theme`)

In your Pascal components, you can switch themes on the fly or toggle between light and dark modes without reloading the page:

```html
<template>
  <div class="theme-showcase">
    <!-- Theme Switcher Toolbar -->
    <div class="toolbar">
      <span>Current Theme: <strong>{{ $theme.current }}</strong></span>

      <button @click="$theme.toggle()" class="btn-toggle">
        {{ $theme.isDark ? '☀️ Switch to Light' : '🌙 Switch to Dark' }}
      </button>

      <select @change="changeTheme($event.target.value)" :value="$theme.current">
        <option value="flatly">Flatly (Light)</option>
        <option value="darkly">Darkly (Dark)</option>
        <option value="cosmo">Cosmo (Light)</option>
        <option value="cyborg">Cyborg (Dark)</option>
        <option value="vapor">Vapor (Synthwave)</option>
      </select>
    </div>

    <!-- BlaiseUI Component Cards -->
    <div class="cards-grid">
      <div class="card">
        <div class="card-header">System Metrics</div>
        <div class="card-body">
          <h5 class="card-title">Server Uptime</h5>
          <p class="card-text">All microservices operational with 99.98% uptime.</p>
          <span class="badge bg-success">Operational</span>
        </div>
      </div>

      <div class="card">
        <div class="card-header">Audit Logs</div>
        <div class="card-body">
          <h5 class="card-title">Security Status</h5>
          <p class="card-text">Zero penetration warnings detected in the last 24h.</p>
          <span class="badge bg-primary">Secure</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
methods:
  procedure changeTheme(const NewTheme: string);
  begin
    $theme.setTheme(NewTheme);
  end;
</script>

<style>
.theme-showcase { padding: 20px; font-family: sans-serif; }
.toolbar {
  display: flex;
  align-items: center;
  gap: 15px;
  margin-bottom: 25px;
  padding: 12px 18px;
  background: rgba(125, 125, 125, 0.1);
  border-radius: 8px;
}
.btn-toggle {
  padding: 6px 12px;
  border-radius: 6px;
  border: 1px solid #ccc;
  cursor: pointer;
}
.cards-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 20px;
}
</style>
```

When `$theme.setTheme('darkly')` is called:
- The `<link id="bv-theme">` tag dynamically points to the new CSS file.
- The user's preference is saved to `localStorage('bv_theme')` so it persists across sessions!

---

## 🌲 5. Production Build Tree-Shaking

When deploying to production, bundling all 25+ Bootswatch themes would unnecessarily inflate your bundle size.

With `bv theme add`, specify only the themes your application actually uses:
```bash
bv theme add darkly
bv theme add flatly
```

When you execute `bv build --release`, BlaiseVue's build pipeline performs **Tree-Shaking**: it excludes all unreferenced themes from `dist/`, keeping your production footprint tiny!

---

## 🏋️ Practical Exercise

1. Install themes using `bv lib install themes`.
2. Inspect `package.json` to see how the theme settings are registered.
3. In your application header, implement a Dark Mode toggle button that switches between `flatly` and `darkly` using `$theme.toggle()`.
4. Refresh the browser and verify that your selected theme preference was automatically restored from `localStorage`.
5. Run `bv theme list` in your terminal to view the active theme configuration.

---

## 📖 Deeper Technical Reference

- **[Themes & Bootswatch Integration Manual](../Documentation/28-themes.md)**: Build-time tree-shaking algorithms, CSS custom property variables, and custom theme creation.
- **[BlaiseUI Component Suite Manual](../Documentation/24-blaise-ui.md)**: Full API documentation for `<bv-button>`, `<bv-modal>`, `<bv-alert>`, and grid layouts.

---

[⬅️ Module 21: Emulation, Live Debugging & Device Build](21-mobile-build.md) | [🏠 Course Index](README.md) | [Module 23: Data Visualization with Blaise Charts ➡️](23-charts.md)
