# 20. Extra-Official Libraries

BlaiseVue includes two major "extra-official" libraries in the `demo-app` that serve as a foundation for building professional UIs and data visualizations. These libraries are portable and can be added to any project by copying their folders into your `/lib` directory.

---

## 🎨 bootstrap-bv (UI Toolkit)

The `bootstrap-bv` library provides a collection of Pascal-wrapped Bootstrap 5 components. It automatically injects `bootstrap.css` into your project without extra configuration.

### 🚀 Common Components:

| Component | Usage | Description |
|-----------|-------|-------------|
| `<b-btn>` | `<b-btn variant="primary" @click="doIt">Click</b-btn>` | Standardized button with variants. |
| `<b-alert>` | `<b-alert v-if="show" variant="danger">Error!</b-alert>` | Reactive alert messages. |
| `<b-modal>` | `<b-modal v-model="visible" title="Title">Content</b-modal>` | Overlay modal controlled by a boolean. |
| `<b-card>` | `<b-card title="My Card">...</b-card>` | Content container with header/body/footer. |
| `<b-icon>` | `<b-icon icon="home"></b-icon>` | Integrated Bootstrap Icons. |
| `<b-tabs>` | `<b-tabs><b-tab title="One">...</b-tab></b-tabs>` | Tabbed navigation system. |

### 🛠️ Example: Creating a Modal
```html
<template>
  <div>
    <b-btn @click="openModal">Open Modal 🛡️</b-btn>
    
    <b-modal v-model="showModal" title="Security Alert">
      <p>Permission granted via Pascal Logic!</p>
      <template b-slot:footer>
         <b-btn variant="secondary" @click="closeModal">Dismiss</b-btn>
      </template>
    </b-modal>
  </div>
</template>

<script>
  data:
    showModal: boolean = false;

  methods:
    procedure openModal; begin showModal := true; end;
    procedure closeModal; begin showModal := false; end;
</script>
```

---

## 📊 chart-bv (Data Visualization)

The `chart-bv` library is a powerful wrapper for **Chart.js**. It allows you to create reactive charts using Pascal data structures.

### 📈 Available Chart Types:
- **`CLine`**: Line Charts.
- **`CBar`**: Bar Charts.
- **`CPie` / `CDoughnut`**: Circular Charts.
- **`CRadar`**: Radar Charts.
- **`CPolarArea`**: Polar Area Charts.

### 🛠️ Example: A Reactive Bar Chart
To use a chart, pass the `data` and `options` props (usually `TJSValue` or `TJSObject` in Pascal):

```html
<template>
  <div style="height: 300px;">
    <c-bar :data="chartData" :options="chartOptions"></c-bar>
    <b-btn @click="updateData">Randomize Data ⚡</b-btn>
  </div>
</template>

<script>
  data:
    chartData: JSValue = null;
    chartOptions: JSValue = null;

  created:
    begin
      chartData := TJSObject.new;
      TJSObject(chartData)['labels'] := TJSArray.new('Jan', 'Feb', 'Mar');
      // Initialize with more complex JSValue structures...
    end;
    
  methods:
    procedure updateData;
    begin
       // Logic to modify chartData and see the chart animate!
    end;
</script>
```

> [!TIP]
> **Automatic Injection:** The `chart-bv` library automatically injects `chart.min.js` into your production bundle's `<head>`, so you don't need to import external CDN scripts manually.

---

## 📥 How to Install
These libraries are currently located in the `demo-app/lib/` folder. To use them in a new project:
1. Create a `lib/` directory in your project root.
2. Copy the `bootstrap-bv` or `chart-bv` folders into that directory.
3. The BlaiseCLI will automatically detect them on the next `bv run dev`. 🛡️✨🚀
