# 🎨 Module 23: Blaise UI Design System & Themes
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
- 30+ responsive Pascal Single File Components (`<bv-btn>`, `<bv-card>`, `<bv-modal>`, `<bv-switch>`, `<bv-slider>`, `<bv-dropdown>`, `<bv-skeleton>`, `<bv-datagrid>`, etc.).
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

## 🧩 4. The Official BlaiseUI Component Kit (30+ Widgets)

The `@blaise-ui` package replaces third-party CSS dependencies with clean, native `.bv` components. Every component automatically responds to the active Bootswatch theme:

### 1. Actions, Overlays & Menus
- **Buttons (`<bv-btn>`)**: Variants (`primary`, `success`, `danger`, `outline`), sizes (`sm`, `md`, `lg`), disabled state.
- **Dropdown Menus (`<bv-dropdown>` & `<bv-dropdown-item>`)**: Contextual dropdown menus with split-button support, drop directions (`down`, `up`, `start`, `end`), and dividers.
- **Modals (`<bv-modal>`)**: Teleported dialogs (`<teleport to="body">`) with backdrop dismiss and action buttons.

### 2. Modern Form Controls
- **Toggle Switches (`<bv-switch>`)**: Bootstrap 5 switches with color accents (`primary`, `success`, `danger`) and two-way `b-model`.
- **Checkboxes & Radios (`<bv-checkbox>` & `<bv-radio>`)**: Native accessible selection controls with inline layout options.
- **Range Sliders (`<bv-slider>`)**: Granular sliders with live numeric value badge counters.
- **Inputs & Selects (`<bv-input>` & `<bv-form-select>`)**: Labelled form controls with feedback and two-way binding.

### 3. Placeholders & Loading States
- **Animated Skeletons (`<bv-skeleton>`)**: Reduces perceived wait times with animated wave or glow placeholders (`type="text" | "rect" | "circle" | "card"`).
- **Spinners & Progress (`<bv-spinner>` & `<bv-progress>`)**: Standard circular loaders and dynamic percentage progress bars.

### 4. Enterprise Tables & Layout
- **Responsive 12-Column Grid (`<bv-container>`, `<bv-row>`, `<bv-col>`)**: Flexible layouts adapting from mobile screens to 4K monitors.
- **High-Performance DataGrid (`<bv-datagrid>`)**: Enterprise tables with column sorting, keyword search, pagination, and scoped slot cell formatting.

---

## ⚡ 5. Reactive Runtime Theme Switching (`$theme`)

In your Pascal components, you can switch themes on the fly or toggle between light and dark modes without reloading the page:

```html
<template>
  <bv-container fluid="true">
    
    <!-- Top Theme & Action Toolbar -->
    <bv-card>
      <div class="toolbar-content">
        <div>
          <h3>Theme Showcase</h3>
          <span>Active: <strong>{{ $theme.current }}</strong> ({{ $theme.isDark ? 'Dark Mode' : 'Light Mode' }})</span>
        </div>

        <div class="toolbar-actions">
          <!-- Toggle Light/Dark with bv-switch -->
          <bv-switch 
            label="Dark Mode" 
            :checked="$theme.isDark" 
            color="success" 
            @change="handleThemeToggle">
          </bv-switch>

          <!-- Theme Dropdown Picker -->
          <bv-dropdown :text="'Theme: ' + $theme.current" variant="primary">
            <bv-dropdown-item @click="setTheme('flatly')">Flatly (Light)</bv-dropdown-item>
            <bv-dropdown-item @click="setTheme('cosmo')">Cosmo (Light)</bv-dropdown-item>
            <bv-dropdown-item @click="setTheme('lux')">Lux (Luxury)</bv-dropdown-item>
            <bv-dropdown-item divider="true"></bv-dropdown-item>
            <bv-dropdown-item @click="setTheme('darkly')">Darkly (Dark)</bv-dropdown-item>
            <bv-dropdown-item @click="setTheme('cyborg')">Cyborg (Jet Black)</bv-dropdown-item>
            <bv-dropdown-item @click="setTheme('vapor')">Vapor (Synthwave)</bv-dropdown-item>
          </bv-dropdown>
        </div>
      </div>
    </bv-card>

    <!-- Dashboard Content with New Form Controls -->
    <bv-row gutter="md">
      
      <!-- Left Column: Controls & Configuration -->
      <bv-col cols="12" md="6">
        <bv-card title="System Preferences">
          <bv-slider 
            label="Notification Volume" 
            :min="0" 
            :max="100" 
            :step="5" 
            :showValue="true" 
            b-model="volumeLevel">
          </bv-slider>

          <bv-switch 
            label="Automatic Cloud Backup" 
            b-model="cloudBackup" 
            color="primary">
          </bv-switch>

          <div class="radio-group">
            <label class="form-label">Backup Frequency:</label>
            <bv-radio name="freq" label="Hourly" value="hourly" b-model="frequency" :inline="true"></bv-radio>
            <bv-radio name="freq" label="Daily" value="daily" b-model="frequency" :inline="true"></bv-radio>
            <bv-radio name="freq" label="Weekly" value="weekly" b-model="frequency" :inline="true"></bv-radio>
          </div>
        </bv-card>
      </bv-col>

      <!-- Right Column: Data Loading with Skeleton Placeholders -->
      <bv-col cols="12" md="6">
        <bv-card title="Live Telemetry">
          <!-- When loading, show modern pulsating skeletons -->
          <div b-if="isLoading">
            <bv-skeleton type="text" animation="wave" :count="2"></bv-skeleton>
            <bv-skeleton type="rect" height="80px" animation="glow"></bv-skeleton>
          </div>

          <!-- When loaded, show real data -->
          <div b-if="!isLoading">
            <bv-alert variant="success">All background workers operational.</bv-alert>
            <p>Active cluster nodes: <strong>8</strong> | CPU Load: <strong>14%</strong></p>
          </div>

          <template b-slot:footer>
            <bv-btn size="sm" variant="secondary" @click="simulateReload">Reload Data</bv-btn>
          </template>
        </bv-card>
      </bv-col>

    </bv-row>

  </bv-container>
</template>

<script>
data:
  volumeLevel: 65;
  cloudBackup: true;
  frequency: 'daily';
  isLoading: false;

methods:
  procedure handleThemeToggle(isChecked: boolean);
  begin
    $theme.toggle();
  end;

  procedure setTheme(newTheme: string);
  begin
    $theme.setTheme(newTheme);
  end;

  procedure simulateReload;
  begin
    this['isLoading'] := true;
    asm
      setTimeout(() => {
        this.isLoading = false;
      }, 1500);
    end;
  end;
</script>

<style>
.toolbar-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 12px;
}
.toolbar-actions {
  display: flex;
  align-items: center;
  gap: 16px;
}
.radio-group {
  margin-top: 12px;
}
</style>
```

When `$theme.setTheme('darkly')` is called:
- The `<link id="bv-theme">` tag dynamically points to the new CSS file.
- The user's preference is saved to `localStorage('bv_theme')` so it persists across sessions!
- All BlaiseUI widgets automatically adapt their text contrast, background surfaces, borders, and buttons.

---

## 🌲 6. Production Build Tree-Shaking

When deploying to production, bundling all 25+ Bootswatch themes would unnecessarily inflate your bundle size.

With `bv theme add`, specify only the themes your application actually uses:
```bash
bv theme add darkly
bv theme add flatly
```

When you execute `bv build --release`, BlaiseVue's build pipeline performs **Tree-Shaking**: it excludes all unreferenced themes from `dist/`, keeping your production footprint tiny!

---

## 🏋️ Practical Exercise

1. Install themes using `bv lib install themes` and UI with `bv lib install ui`.
2. Inspect `package.json` to verify the theme settings.
3. In your dashboard, add a `<bv-switch>` that toggles between `flatly` and `darkly`.
4. Add a `<bv-slider>` controlling an interactive value, and verify that the numeric badge updates smoothly.
5. Add a `<bv-skeleton>` container that pulses while your dataset is loading.
6. Refresh the browser and verify that your selected theme preference was automatically restored from `localStorage`.

---

## 📖 Deeper Technical Reference

- **[Themes & Bootswatch Integration Manual](../Documentation/28-themes.md)**: Build-time tree-shaking algorithms, CSS custom property variables, and custom theme creation.
- **[BlaiseUI Component Suite Manual](../Documentation/24-blaise-ui.md)**: Full API documentation for all 30+ components.
- **[Package Components Catalog](../Documentation/41-package-components-catalog.md)**: Detailed technical specifications, props, events, and slots.

---

[⬅️ Module 22: Native Lightweight Desktop Applications](22-desktop-webui.md) | [🏠 Course Index](README.md) | [Module 24: Data Visualization with Blaise Charts ➡️](24-charts.md)
