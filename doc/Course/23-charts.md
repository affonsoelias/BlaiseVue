# 📊 Module 23: Data Visualization with Blaise Charts
**Create hardware-accelerated, 60 FPS interactive charts and graphs using strongly-typed Object Pascal.**

Modern executive dashboards, ERPs, and monitoring tools require clear, interactive visual analytics. Rendering complex datasets into responsive charts should not require writing thousands of lines of raw JavaScript canvas calls.

BlaiseVue delivers **`@blaise-charts`**—an official data visualization suite that bridges the industry-standard **Chart.js** engine with strongly-typed **Object Pascal** classes and records.

---

## 🏛️ 1. Architecture & Hardware Acceleration

```text
┌─────────────────────────────────────────────────────────────────┐
│              BlaiseVue Single File Component (.bv)               │
│  <bv-chart>, <bv-bar-chart>, <bv-line-chart>, <bv-pie-chart>    │
└────────────────────────────────┬────────────────────────────────┘
                                 │ Reactive Binding (:data, :options)
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│             Strongly-Typed Pascal Layer (BlaiseCharts)          │
│   TBVChartData  •  TBVChartOptions  •  TBVChartPalette          │
│   TBVChartDataset  •  TBVChartBuilder (Fluent API)              │
└────────────────────────────────┬────────────────────────────────┘
                                 │ Deep Watcher + chart.update()
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                Chart.js Core Engine (chart.min.js)              │
│       HTML5 Canvas 2D Context • 60 FPS Smooth Animations        │
└─────────────────────────────────────────────────────────────────┘
```

### Highlights:
- **100% Offline & Self-Contained**: Comes pre-bundled with `chart.min.js`. Zero external CDN calls; functions reliably in airplane mode, intranet servers, and desktop apps.
- **No Manual JavaScript Objects**: Configure charts using type-safe Pascal records and fluent builder methods.
- **Smooth Reactivity**: Whenever Pascal arrays or dataset records update, the chart animates smoothly to new values without flickering.
- **Theme Aware**: Gridlines, fonts, and borders automatically adapt when switching between Light (`flatly`) and Dark (`darkly`) themes!

---

## 📦 2. Installing Blaise Charts

Install the charting suite into your project via the CLI:

```bash
bv lib install charts

# Aliases:
bv lib install blaise-charts
bv lib install @blaise-charts
```

This installs `lib/blaise-charts/` containing:
- `chart.min.js`: Production Chart.js runtime.
- `blaise-charts.css`: Canvas wrapper and responsive aspect ratio styles.
- `BlaiseCharts.pas`: Strongly-typed Pascal classes.
- Ready-to-use chart components.

---

## 🧩 3. Available Chart Components

| Component Tag | Chart Type | Best Used For |
|---|---|---|
| `<bv-bar-chart>` | Bar / Column | Comparing sales, quantities, or categories across periods |
| `<bv-line-chart>` | Line / Area | Visualizing trends over time (revenue, temperature, memory) |
| `<bv-pie-chart>` | Pie | Showing percentage distributions of a whole |
| `<bv-doughnut-chart>` | Doughnut | Distribution percentages with room for a center metric |
| `<bv-radar-chart>` | Radar | Comparing multivariate performance metrics across teams |
| `<bv-polar-area-chart>` | Polar Area | Cyclical or directional magnitude comparisons |

---

## 💻 4. Building an Interactive Analytics Dashboard

Here is a complete `.bv` view that defines and dynamically updates charts in Object Pascal:

```html
<template>
  <div class="analytics-dashboard">
    <header class="dashboard-header">
      <h2>📈 Real-Time Sales & Revenue Analytics</h2>
      <button @click="simulateNewSales" class="btn-refresh">🎲 Simulate Sales Surge</button>
    </header>

    <div class="charts-grid">
      <!-- 1. Bar Chart: Monthly Revenue -->
      <div class="chart-card">
        <h3>Monthly Revenue ($)</h3>
        <bv-bar-chart 
          :labels="months" 
          :datasets="revenueDatasets" 
          :options="chartOptions">
        </bv-bar-chart>
      </div>

      <!-- 2. Doughnut Chart: Market Share by Category -->
      <div class="chart-card">
        <h3>Product Category Breakdown</h3>
        <bv-doughnut-chart 
          :labels="categories" 
          :datasets="categoryDatasets">
        </bv-doughnut-chart>
      </div>
    </div>
  </div>
</template>

<script>
uses SysUtils, JS;

data:
  months: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
  categories: ['Software', 'Hardware', 'Cloud Subscriptions', 'Consulting'];
  
  revenueDatasets: [
    (
      label: 'Revenue 2026',
      data: [12500, 19200, 15400, 22100, 28900, 31400],
      backgroundColor: '#3b82f6'
    )
  ];

  categoryDatasets: [
    (
      data: [45, 25, 20, 10],
      backgroundColor: ['#3b82f6', '#10b981', '#f59e0b', '#8b5cf6']
    )
  ];

  chartOptions: (
    responsive: true,
    maintainAspectRatio: true,
    animation: (duration: 800)
  );

methods:
  procedure simulateNewSales;
  var
    i: Integer;
    arr: TJSArray;
  begin
    arr := TJSArray(TJSObject(revenueDatasets[0])['data']);
    for i := 0 to arr.length - 1 do
    begin
      // Add a random increment to simulate real-time live metrics
      arr[i] := Integer(arr[i]) + Random(5000) - 2000;
    end;
    // The chart detects the change and animates smoothly!
  end;
</script>

<style>
.analytics-dashboard { padding: 20px; font-family: sans-serif; }
.dashboard-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}
.btn-refresh {
  padding: 8px 16px;
  border-radius: 6px;
  background: #2563eb;
  color: #fff;
  border: none;
  cursor: pointer;
  font-weight: bold;
}
.charts-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(420px, 1fr));
  gap: 25px;
}
.chart-card {
  background: #ffffff;
  padding: 20px;
  border-radius: 12px;
  box-shadow: 0 4px 16px rgba(0,0,0,0.06);
}
.chart-card h3 { margin-top: 0; margin-bottom: 15px; font-size: 16px; color: #475569; }
</style>
```

---

## 🔗 5. Binding Charts to `TBVDataSet`

You can seamlessly bridge `TBVDataSet` records with Blaise Charts:

```pascal
procedure TAnalyticsView.UpdateChartFromDataSet(ds: TBVDataSet);
var
  Labels: TJSArray;
  Values: TJSArray;
begin
  Labels := TJSArray.new;
  Values := TJSArray.new;

  ds.First;
  while not ds.Eof do
  begin
    Labels.push(ds.FieldByName('productName').AsString);
    Values.push(ds.FieldByName('totalSold').AsInteger);
    ds.Next;
  end;

  this.chartLabels := Labels;
  TJSObject(this.chartDatasets[0])['data'] := Values;
end;
```

---

## 🏋️ Practical Exercise

1. Install the charting library in your project: `bv lib install charts`.
2. Create a new view file `src/views/AnalyticsView.bv`.
3. Add a `<bv-line-chart>` representing weekly website visitors.
4. Add two buttons: `"Weekly View"` and `"Monthly View"`.
5. When clicked, toggle the dataset between weekly data points (7 values) and monthly data points (30 values).
6. Observe how Chart.js animates the line curve transitions smoothly!

---

## 📖 Deeper Technical Reference

- **[Reactive Chart.js Suite Manual](../Documentation/39-blaise-charts.md)**: Full API for `TBVChartBuilder`, custom plugins, tooltips, click events, and multi-axis scales.
- **[Package Components Catalog](../Documentation/41-package-components-catalog.md#part-ii-blaisecharts-suite-packagesblaise-charts)**: Property definitions and custom callback hooks.

---

[⬅️ Module 22: Blaise UI Design System & Themes](22-themes.md) | [🏠 Course Index](README.md) | [Module 24: Enterprise Reporting with Blaise Reports ➡️](24-reports.md)
