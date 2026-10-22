# 20. Extra-Official Libraries & BlaiseUI Evolution

In early versions of BlaiseVue, two auxiliary libraries were developed in the `lib/` directory to showcase external component integration: `bootstrap-bv` (Bootstrap 5 wrapper) and `chart-bv` (Chart.js wrapper).

BlaiseVue consolidates UI widgets into the official, native **[BlaiseUI](24-blaise-ui.md)** package, eliminating prefix ambiguity and external heavyweight CSS dependencies.

---

## 🏛️ Evolution to Unified BlaiseUI

| Legacy Library | Unified Architecture | Motivation for Migration |
|---|---|---|
| `bootstrap-bv/` | **`packages/blaise-ui/`** | Removal of `bootstrap.css` (~230KB) in favor of lightweight native CSS variables (`blaise-ui.css`). |
| `chart-bv/` | **`packages/blaise-ui/`** | Integrated `<bv-chart>` and specialized chart wrappers directly into the official component kit. |
| Mixed `b-*` and `c-*` Prefixes | **Standardized `bv-*` Prefix** | Resolved naming collisions between components (`BBtn` vs `BVBtn`, `BToast` vs `BVToast`). |

---

## 📦 Creating Custom Libraries in `/lib`

The BlaiseVue ecosystem provides full native support for modular third-party libraries and local packages placed in the `lib/` directory.

Any folder inside `lib/` benefits from automatic CLI (`bv.exe`) integration:
1. **Auto Component Registration**: Any `.bv` file inside `lib/<your-lib>/` is automatically transpiled and registered globally across the application.
2. **Auto CSS Injection**: `.css` files located in `lib/<your-lib>/` are copied to `dist/css/lib/` and injected via `<link>` into `index.html`.
3. **Auto JS Script Injection**: `.js` files located in `lib/<your-lib>/` (such as chart engines or utility drivers) are copied to `dist/js/lib/` and injected via `<script>` before application initialization.
4. **Lifecycle Setup (`setup.pas`)**: Libraries can provide an interactive `setup.pas` configuration script executed via `bv s <lib-name>`.

---

## 📊 Reactive Charts in Unified BlaiseUI

To use reactive data visualizations in any BlaiseVue project, use the unified BlaiseUI chart components:

```html
<template>
  <div style="height: 350px;">
    <!-- Master chart component or direct shortcut -->
    <bv-bar :data="chartData" :options="chartOptions"></bv-bar>
    <bv-btn variant="primary" @click="updateData">Randomize Data ⚡</bv-btn>
  </div>
</template>

<script>
  data:
    chartData: JSValue = null;
    chartOptions: JSValue = null;

  created:
    begin
       asm
         this.chartOptions = { responsive: true, maintainAspectRatio: false };
         this.chartData = {
           labels: ['Jan', 'Feb', 'Mar'],
           datasets: [{ label: 'Sales', data: [10, 25, 42], backgroundColor: '#42b883' }]
         };
       end;
    end;

  methods:
    procedure updateData;
    begin
       asm
         this.chartData = {
           ...this.chartData,
           datasets: [{ ...this.chartData.datasets[0], data: [35, 12, 58] }]
         };
       end;
    end;
</script>
```

---

🛡️ For the full catalog of components, consult the official guide: **[24. BlaiseUI (Official Component Kit)](24-blaise-ui.md)**.
