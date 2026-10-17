# 24. BlaiseUI (Official Component Kit)

**BlaiseUI** is the official, unified, and native component library of BlaiseVue 2.0 / 3.0. Built 100% in Object Pascal and Single File Components (`.bv`), it unifies the visual design system, form controls, navigation primitives, overlays, and reactive charts into a single cohesive package with zero external CSS dependencies.

---

## 📦 Unified Architecture

BlaiseUI replaces legacy fragmented libraries (such as `bootstrap-bv` and `chart-bv`) with a **single package directory**:
- **Source Package**: [`packages/blaise-ui/`](file:///c:/Users/Pichau/Documents/BlaiseVue/packages/blaise-ui/)
- **Application Integration**: [`demo-app/lib/blaise-ui/`](file:///c:/Users/Pichau/Documents/BlaiseVue/demo-app/lib/blaise-ui/)

Through the automatic autoloading mechanism of BlaiseVue's `lib/` directory:
1. All components with the `bv-*` prefix are **registered globally** without requiring manual imports.
2. The [`blaise-ui.css`](file:///c:/Users/Pichau/Documents/BlaiseVue/packages/blaise-ui/blaise-ui.css) stylesheet is automatically injected into `<head>`.
3. The bundled [`chart.min.js`](file:///c:/Users/Pichau/Documents/BlaiseVue/packages/blaise-ui/chart.min.js) script is automatically injected before application bootstrap.

---

## 🎨 Design System & CSS Variables

BlaiseUI utilizes customizable CSS custom properties (`--bui-*`):

```css
:root {
  --bui-primary: #42b883;
  --bui-primary-hover: #33a06f;
  --bui-secondary: #64748b;
  --bui-success: #10b981;
  --bui-danger: #ef4444;
  --bui-warning: #f59e0b;
  --bui-info: #0ea5e9;
  --bui-bg: #ffffff;
  --bui-card-bg: #ffffff;
  --bui-border: #e2e8f0;
  --bui-text: #1e293b;
  --bui-text-muted: #64748b;
  --bui-radius: 6px;
}
```

---

## 🧩 Complete Component Catalog

### 0. Responsive Grid & Layout (Mobile & Desktop)
Engineered around an adaptive 12-column grid system supporting any display resolution:
- **`<bv-container>`**: Centered layout container with fixed responsive or fluid width (`fluid="true"`).
- **`<bv-row>`**: Flexbox grid row with column spacing configurable via `gutter` prop (`none`, `sm`, `md`, `lg`).
- **`<bv-col>`**: Adaptive column supporting Bootstrap breakpoint spans (`cols`, `sm`, `md`, `lg`, `xl`) and offsets (`offset`).
  ```html
  <bv-container fluid="true">
    <bv-row gutter="md">
      <!-- 12 columns on mobile, 4 columns from medium screens up -->
      <bv-col cols="12" md="4">
        <bv-card title="Sidebar / Summary">...</bv-card>
      </bv-col>
      <!-- 12 columns on mobile, 8 columns from medium screens up -->
      <bv-col cols="12" md="8">
        <bv-card title="Main Content">...</bv-card>
      </bv-col>
    </bv-row>
  </bv-container>
  ```

### 1. Actions & Core Structure
- **`<bv-btn>`**: Standardized button with styling variants (`primary`, `secondary`, `success`, `danger`, `outline`), sizes (`sm`, `md`, `lg`), and `disabled` state.
  ```html
  <bv-btn variant="primary" size="md" @click="saveRecord">Save Record</bv-btn>
  ```
- **`<bv-card>`**: Structured surface container with `header`, default (body), and `footer` slots.
  ```html
  <bv-card title="System Metrics">
    <p>Card Body Content</p>
    <template b-slot:footer>
      <bv-btn size="sm" variant="secondary">Refresh</bv-btn>
    </template>
  </bv-card>
  ```
- **`<bv-badge>`**: Colored status chips and pill markers.
  ```html
  <bv-badge variant="success" :pill="true">Active</bv-badge>
  ```

---

### 2. Feedback, Overlays & Notifications
- **`<bv-modal>`**: Interactive modal dialog rendered via `<teleport to="body">` with safe visibility control via `b-show="isVisible"`, preventing z-index issues, layout shifts, or accidental viewport blocking. Includes automatic child node teardown in the routing unmount lifecycle.
  ```html
  <bv-modal b-ref="myModal" title="Confirm Operation" okLabel="Confirm" cancelLabel="Cancel" @ok="onConfirm">
    <p>Are you sure you want to proceed?</p>
  </bv-modal>
  ```
- **`<bv-drawer>`**: Slide-out off-canvas drawer menu tailored for mobile and desktop secondary navigation.
  ```html
  <bv-drawer b-ref="myDrawer" title="Main Menu">
    <p>Slide-out navigation content.</p>
  </bv-drawer>
  ```
- **`<bv-toast>`**: Floating notification banner with timed auto-dismissal.
  ```html
  <bv-toast b-ref="myToast" title="Success" variant="success" :duration="3000">
    Record updated successfully!
  </bv-toast>
  ```
- **`<bv-alert>`**: Alert banner with status variants and `dismissible` support.
  ```html
  <bv-alert variant="warning" :dismissible="true">Please review your input.</bv-alert>
  ```
- **`<bv-progress>`**: Reactive progress bar with smooth CSS animation and percentage display.
  ```html
  <bv-progress :value="progressPercent" variant="success"></bv-progress>
  ```
- **`<bv-spinner>`**: Animated loading indicator with `small` option.
  ```html
  <bv-spinner variant="primary" :small="true"></bv-spinner>
  ```

---

### 3. Navigation & Collections
- **`<bv-bottom-nav>` & `<bv-bottom-nav-item>`**: Fixed bottom navigation bar for mobile devices with icons, labels, and active route detection.
  ```html
  <bv-bottom-nav>
    <bv-bottom-nav-item href="#/" icon="🏠" label="Home"></bv-bottom-nav-item>
    <bv-bottom-nav-item href="#/profile" icon="👤" label="Profile"></bv-bottom-nav-item>
  </bv-bottom-nav>
  ```
- **`<bv-navbar>` & `<bv-nav-item>`**: Top application header with branding and navigation links. Handles internal route transitions with `preventDefault` to keep URL hashes clean.
  ```html
  <bv-navbar brand="My Application">
    <bv-nav-item href="#/" active="true" label="Home"></bv-nav-item>
    <bv-nav-item href="#/reports" label="Reports"></bv-nav-item>
  </bv-navbar>
  ```
- **`<bv-breadcrumb>` & `<bv-breadcrumb-item>`**: Hierarchical breadcrumb navigation trails.
  ```html
  <bv-breadcrumb>
    <bv-breadcrumb-item href="#/">Home</bv-breadcrumb-item>
    <bv-breadcrumb-item active="true">Details</bv-breadcrumb-item>
  </bv-breadcrumb>
  ```
- **`<bv-tabs>` & `<bv-tab>`**: Tabbed interface with dynamic registration via provide/inject.
  ```html
  <bv-tabs @change="onTabChange">
    <bv-tab id="tab1" title="Overview" active="true">Tab 1 Content</bv-tab>
    <bv-tab id="tab2" title="Settings">Tab 2 Content</bv-tab>
  </bv-tabs>
  ```
- **`<bv-accordion>`**: Expandable accordion sections for collapsible content and FAQs.
  ```html
  <bv-accordion :items="faqItems" initialActiveId="q1"></bv-accordion>
  ```
- **`<bv-pagination>`**: Numbered pagination control with `input` and `change` events.
  ```html
  <bv-pagination :value="currentPage" :total="10" @input="changePage"></bv-pagination>
  ```
- **`<bv-list-group>` & `<bv-list-group-item>`**: Structured lists with badge and active state support.
  ```html
  <bv-list-group>
    <bv-list-group-item badge="3" badgeVariant="danger">Inbox</bv-list-group-item>
  </bv-list-group>
  ```
- **`<bv-icon>`**: Embedded vector SVG icon set (`check-circle`, `warning`, `gear-fill`, `heart-fill`, `weather`, `code-slash`, `cpu`).
  ```html
  <bv-icon name="check-circle" size="24" class="text-success" />
  ```

---

### 4. Form Controls
- **`<bv-input>`**: Reactive input field with `b-model`, label, and error feedback.
  ```html
  <bv-input label="Full Name" b-model="name" placeholder="Enter your name"></bv-input>
  ```
- **`<bv-form-select>`**: Select dropdown bound to dynamic options.
  ```html
  <bv-form-select label="Priority" b-model="priority" :options="priorityOptions"></bv-form-select>
  ```
- **`<bv-input-group>`**: Input field with prepend and append visual adornments.
  ```html
  <bv-input-group label="Price" prepend="$" append=".00" b-model="price"></bv-input-group>
  ```

---

### 5. Complex Data & Tables
- **`<bv-datagrid>`**: High-performance data table with search filtering, column sorting, pagination, and **Scoped Slots**.
  ```html
  <bv-datagrid :columns="columns" :items="users">
    <template b-slot:cell(status)="scope">
      <bv-badge :variant="scope.row.active ? 'success' : 'danger'">
        {{ scope.row.active ? 'Active' : 'Inactive' }}
      </bv-badge>
    </template>
  </bv-datagrid>
  ```

---

### 6. Reactive Charts (`Chart.js`)
BlaiseUI integrates reactive charting directly into the kit:
- **`<bv-chart>`**: Master chart component supporting `:type="bar|line|pie|doughnut|radar|polarArea"`, `:data`, and `:options`.
- **Specialized Direct Wrappers**:
  - `<bv-bar :data="data" :options="options"></bv-bar>`
  - `<bv-line :data="data" :options="options"></bv-line>`
  - `<bv-pie :data="data" :options="options"></bv-pie>`
  - `<bv-doughnut :data="data" :options="options"></bv-doughnut>`
  - `<bv-polar-area :data="data" :options="options"></bv-polar-area>`
  - `<bv-radar :data="data" :options="options"></bv-radar>`

```html
<template>
  <bv-bar :data="salesData" :options="chartOptions"></bv-bar>
</template>
```

---

## 🛡️ Advantages of Unified Architecture

| Before (Fragmented) | Now (Unified BlaiseUI) |
|---|---|
| Three separate folders (`bootstrap-bv`, `chart-bv`, `blaise-ui`) | **Single directory**: `lib/blaise-ui/` |
| Competing prefixes (`b-btn`, `bv-btn`, `c-line`) | **Standardized universal prefix**: `bv-*` |
| Heavy `bootstrap.css` bundle (~230KB) | **Lightweight customizable CSS** (`blaise-ui.css`) |
| Redundant components (`BModal` vs `BVModal`) | **Single definitive component with built-in Teleport** |
