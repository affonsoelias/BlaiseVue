# 28. Themes & Bootswatch Integration (`blaise-themes`)

BlaiseVue includes the official **`blaise-themes`** package, providing full support for Bootswatch themes, reactive runtime theme switching, dark/light mode toggling, and automatic persistent storage.

---

## 1. Overview & Architecture

Themes in BlaiseVue are built on top of standard Bootstrap 5 stylesheets from Bootswatch. Because `blaise-ui` components use standard Bootstrap classes (`btn`, `card`, `alert`, `navbar`, etc.), any Bootswatch theme immediately transforms the visual appearance of all components with zero code changes.

```
┌────────────────────────────────────────┐
│               App DOM                  │
│  <link id="bv-theme" href="flatly">   │
└──────────────────┬─────────────────────┘
                   │ Controlled dynamically
┌──────────────────▼─────────────────────┐
│          core/BVTheme.pas              │
│  $theme.current  /  $theme.isDark      │
│  $theme.setTheme() / $theme.toggle()   │
│  localStorage('bv_theme')              │
└────────────────────────────────────────┘
```

---

## 2. Installing Themes via CLI

To install the official themes suite into your BlaiseVue project, run:

```bash
bv lib install themes
```

This command installs 9 popular Bootswatch themes into your project's `lib/themes/` directory:

| Theme | Type | Style Profile |
|---|---|---|
| **flatly** | Light | Flat, modern, clean (default) |
| **cosmo** | Light | Minimalist, metropolitan |
| **lux** | Light | Classy, luxury typography |
| **zephyr** | Light | Soft, breezy, rounded |
| **darkly** | Dark | Elegant dark mode |
| **cyborg** | Dark | Jet black, high-contrast cyber theme |
| **solar** | Dark | Calmer dark tones inspired by Solarized |
| **vapor** | Neon | Synthwave / cyberpunk retro colors |
| **pulse** | Vibrant | Purple-accented, lively |

---

## 3. Switching Themes via CLI (`bv theme`)

You can inspect and set the default initial theme directly from your terminal:

```bash
# List all installed themes in your project
bv theme list

# Switch the default theme in public/index.html
bv theme use darkly
bv theme use flatly
```

The CLI automatically detects your `index.html` and creates or updates `<link id="bv-theme" rel="stylesheet" href="lib/themes/<name>.min.css">`.

---

## 4. Runtime Reactive Theme Switching (`$theme`)

Every BlaiseVue component template and script has direct access to the reactive `$theme` singleton.

### 4.1. Template API
```html
<template>
  <div class="d-flex align-items-center gap-2">
    <!-- Toggle Button -->
    <button class="btn btn-sm btn-outline-secondary" @click="$theme.toggle()">
      <span v-if="$theme.isDark">☀️ Claro</span>
      <span v-if="!$theme.isDark">🌙 Escuro</span>
    </button>

    <!-- Dropdown Selector -->
    <select class="form-select form-select-sm" :value="$theme.current" @change="changeTheme($event)">
      <option value="flatly">Flatly (Claro)</option>
      <option value="darkly">Darkly (Escuro)</option>
      <option value="lux">Lux (Claro)</option>
      <option value="cyborg">Cyborg (Escuro)</option>
      <option value="solar">Solar (Escuro)</option>
      <option value="vapor">Vapor (Neon)</option>
      <option value="pulse">Pulse (Roxo)</option>
    </select>
  </div>
</template>
```

### 4.2. Pascal Script API
```pascal
unit uMyView;

interface
uses JS, Web, BVTheme;

methods:
  procedure changeTheme(e: JSValue);
  var
    sel: string;
  begin
    sel := string(TJSObject(TJSObject(e)['target'])['value']);
    TBVTheme.SetTheme(sel);
  end;

  procedure toggleDark;
  begin
    TBVTheme.ToggleDarkLight;
  end;
```

---

## 5. Ready-to-Use UI Components

When `blaise-themes` is installed, two ready-to-use components are included in `lib/themes/`:

1. **`<BVThemeSelect />`**: A styled dropdown component with all installed themes.
2. **`<BVThemeToggle />`**: A single button that toggles between light and dark modes with sun/moon icons.

---

## 6. LocalStorage Persistence & Dark Mode Detection

When `$theme.setTheme(name)` is called:
1. It updates `<link id="bv-theme">` in the DOM.
2. It sets `data-bs-theme="dark"` or `data-bs-theme="light"` on `document.documentElement`.
3. It sets classes `.theme-dark` and `.theme-light` on `<html>`.
4. It saves the preference to `localStorage.getItem('bv_theme')`.
5. Upon page reload, the user's preferred theme is restored automatically before rendering.

---

## 7. Automatic Harmonization with BlaiseUI

All official **BlaiseUI** components (`<bv-btn>`, `<bv-card>`, `<bv-modal>`, `<bv-navbar>`, etc.) are engineered to respect the active theme palette and contrast dynamically:

1. **Bootstrap 5 Semantic Variables**: Button colors, card backgrounds, borders, and typography inherit directly from the selected Bootswatch theme.
2. **Immediate Adaptation Without Reload**: Calling `$theme.setTheme('darkly')` or `$theme.toggle()` adapts component styling across the application in real time without unmounting reactive components.
3. **Native Mobile Support**: In the hybrid Android/iOS application, theme changes instantly apply to the top app bar, off-canvas navigation drawer, and mobile bottom navigation `<bv-bottom-nav>`.

