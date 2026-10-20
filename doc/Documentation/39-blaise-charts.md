# 39. Reactive Chart.js Suite (`blaise-charts` & `BlaiseCharts`)

**Phase 6 of the BlaiseVue 4.0 Cloud & Mobile Ecosystem** introduces the official data visualization and analytics library: **`blaise-charts`** (`packages/blaise-charts`).

Blaise Charts bridges the industry-standard **Chart.js** engine with strongly typed **Object Pascal** classes and records, delivering reactive, hardware-accelerated 60 FPS HTML5 `<canvas>` rendering across Web, Desktop (WebUI), and Mobile (Capacitor/Android) with zero CDN dependency.

---

## 📊 Architecture & Hardware Acceleration

```text
┌─────────────────────────────────────────────────────────────────┐
│              BlaiseVue Single File Component (.bv)               │
│  <bv-chart>, <bv-bar-chart>, <bv-line-chart>, <bv-pie-chart>    │
└────────────────────────────────┬────────────────────────────────┘
                                 │ Reactive Binding (:data, :options)
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│             Strongly Typed Pascal Layer (BlaiseCharts)           │
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

### Key Highlights:
1. **100% Offline & Self-Contained**: Includes offline-bundled `chart.min.js` and responsive styles. Operates in airplane mode, local desktop apps, and intranet servers without CDN latency.
2. **Strongly Typed Object Pascal**: No manual JavaScript objects or untyped dictionaries needed. Build datasets and configure scales, tooltips, and legends using type-safe Pascal records and fluent builder classes.
3. **Smooth Reactivity**: Whenever Pascal arrays or values change, the chart updates smoothly using Chart.js animation easing without flickering or rebuilding DOM nodes.
4. **Theme & Dark Mode Aware**: Seamlessly adjusts gridlines, text labels, borders, and legends when switching between Light and Dark themes.

---

## 📦 Package Installation (`bv lib install charts`)

To install the charting package into any BlaiseVue project:

```bash
bv lib install charts
# or:
bv lib install blaise-charts
```

This installs `lib/blaise-charts/` containing:
- `chart.min.js`: Production Chart.js runtime.
- `blaise-charts.css`: Canvas wrapper, aspect ratio utilities, and skeleton loaders.
- `BlaiseCharts.pas`: Strongly typed Pascal data models and helpers.
- Component suite: `<bv-chart>`, `<bv-bar-chart>`, `<bv-line-chart>`, `<bv-pie-chart>`, `<bv-doughnut-chart>`, `<bv-radar-chart>`, `<bv-polar-area-chart>`, `<bv-scatter-chart>`, `<bv-bubble-chart>`.

---

## 🧩 Chart Components Reference

| Component Tag | Chart Type | Props & Events |
|---|---|---|
| `<bv-chart>` | Universal Chart | `type`: `'bar'\|'line'\|'pie'\|'doughnut'\|'radar'\|'polarArea'\|'scatter'\|'bubble'`<br>`:data`: `TBVChartData` or Object<br>`:options`: `TBVChartOptions` or Object<br>`height`: string / number<br>`width`: string / number<br>`title`: optional header card<br>`description`: optional subtitle<br>`@chart-click`: emits `(event, activeElements)` |
| `<bv-bar-chart>` | Bar / Column Chart | Same props as `<bv-chart>`. Pre-configured `type="bar"`. |
| `<bv-line-chart>` | Line / Area Chart | Same props as `<bv-chart>`. Pre-configured `type="line"`. |
| `<bv-pie-chart>` | Pie Chart | Same props as `<bv-chart>`. Pre-configured `type="pie"`. |
| `<bv-doughnut-chart>` | Doughnut / Ring Chart | Same props as `<bv-chart>`. Pre-configured `type="doughnut"`. |
| `<bv-radar-chart>` | Radar / Spider Chart | Same props as `<bv-chart>`. Pre-configured `type="radar"`. |
| `<bv-polar-area-chart>` | Polar Area Chart | Same props as `<bv-chart>`. Pre-configured `type="polarArea"`. |
| `<bv-scatter-chart>` | XY Scatter Plot | Same props as `<bv-chart>`. Pre-configured `type="scatter"`. |
| `<bv-bubble-chart>` | Bubble Chart (X, Y, R) | Same props as `<bv-chart>`. Pre-configured `type="bubble"`. |

---

## ⚡ Strongly Typed Pascal API (`BlaiseCharts.pas`)

Import `BlaiseCharts` in your Pascal unit or `.bv` component `<script uses="BlaiseCharts">`:

### 1. `TBVChartDataset` (Series Configuration)

Represents an individual data series with custom styling and behavior:

```pascal
var
  Series: TBVChartDataset;
begin
  Series := TBVChartDataset.Create;
  Series.SetLabel('Monthly Revenue');
  Series.SetData([12000, 19000, 24000, 31000, 42000]);
  Series.SetBackgroundColor('#3B82F6');
  Series.SetBorderColor('#1D4ED8');
  Series.SetBorderWidth(2);
  Series.SetTension(0.35); // Smooth cubic curves for line charts
  Series.SetFill(True);     // Fill area under line
end;
```

### 2. `TBVChartData` (Labels and Datasets Container)

Manages chart category labels and one or multiple datasets:

```pascal
var
  Data: TBVChartData;
begin
  Data := TBVChartData.Create;
  Data.SetLabels(['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun']);
  
  // Single color dataset (e.g. line or single-series bar)
  Data.AddDataset('Q1 Revenue', [10500, 18200, 23400, 29000, 35000, 42000], '#10B981');
  
  // Multi-color dataset (e.g. pie / doughnut slices)
  Data.AddMultiColorDataset('Traffic Share', 
    [45, 25, 20, 10], 
    TBVChartPalette.Neon
  );
end;
```

### 3. `TBVChartOptions` (Responsive Layout & Scales)

Configures titles, tooltips, responsive aspect ratios, and grid axes:

```pascal
var
  Opts: TBVChartOptions;
begin
  Opts := TBVChartOptions.Create;
  Opts.SetResponsive(True);
  Opts.SetMaintainAspectRatio(False);
  Opts.SetTitle('Q2 Performance Overview', True);
  Opts.SetSubtitle('Aggregated across all regional nodes', True);
  Opts.SetLegend(True, 'top');
  Opts.SetScales(True, True); // Enable X and Y gridlines
  Opts.SetDarkMode(True);     // Automatically style axes and text for dark themes
end;
```

### 4. `TBVChartPalette` (Curated Color Schemes)

Blaise Charts includes six built-in professional palettes:

```pascal
TBVChartPalette.Default;   // Vibrant Modern Blue, Purple, Amber, Green
TBVChartPalette.Emerald;   // Professional Teal, Mint, Emerald & Forest hues
TBVChartPalette.Sunset;    // Warm Tangerine, Rose, Coral, Violet
TBVChartPalette.Neon;      // High-contrast Cyberpunk / Dark UI palette
TBVChartPalette.Pastel;    // Soft elegant tones for analytics dashboards
TBVChartPalette.Cyberpunk; // Ultra-futuristic Neon Violet, Gold, Cyan

// Generate RGBA translucent fills with alpha channel:
ColorWithAlpha := TBVChartPalette.HexToRgba('#3B82F6', 0.25);
```

### 5. `TBVChartBuilder` (Fluent Factory)

Create and populate charts in a single chained expression:

```pascal
var
  ChartData: TBVChartData;
begin
  ChartData := TBVChartBuilder.NewBar
    .Labels(['Node 1', 'Node 2', 'Node 3', 'Node 4'])
    .Series('Throughput (req/s)', [1420, 2180, 1890, 3100], '#8B5CF6')
    .Build;
end;
```

---

## 💡 Real-World Component Example (`ChartsView.bv`)

```html
<template>
  <div class="charts-container p-4">
    <div class="row g-4">
      <!-- Universal Reactive Bar Chart -->
      <div class="col-12 col-lg-6">
        <bv-bar-chart 
          title="Server Request Throughput"
          description="Real-time requests handled per second"
          :data="ServerMetrics"
          :options="MetricsOptions"
          height="320"
          @chart-click="OnMetricClick"
        />
      </div>

      <!-- Donut Allocation Chart -->
      <div class="col-12 col-lg-6">
        <bv-doughnut-chart
          title="Memory Distribution"
          description="RAM allocation across worker pools"
          :data="MemoryMetrics"
          :options="DoughnutOptions"
          height="320"
        />
      </div>
    </div>

    <!-- Live Action Buttons -->
    <div class="mt-4 d-flex gap-2">
      <button class="btn btn-primary" @click="RandomizeData">
        ⚡ Randomize Metrics
      </button>
      <button class="btn btn-secondary" @click="ToggleTheme">
        🌓 Toggle Dark/Light Mode
      </button>
    </div>
  </div>
</template>

<script uses="BlaiseCharts">
type
  TChartsView = class(TBVComponent)
  private
    IsDark: Boolean;
  public
    ServerMetrics: TBVChartData;
    MemoryMetrics: TBVChartData;
    MetricsOptions: TBVChartOptions;
    DoughnutOptions: TBVChartOptions;
    
    procedure Setup; override;
    procedure RandomizeData;
    procedure ToggleTheme;
    procedure OnMetricClick(Sender: TObject; Payload: JSValue);
  end;

procedure TChartsView.Setup;
begin
  IsDark := False;

  // 1. Configure Bar Chart Data
  ServerMetrics := TBVChartData.Create;
  ServerMetrics.SetLabels(['00:00', '04:00', '08:00', '12:00', '16:00', '20:00']);
  ServerMetrics.AddDataset('API Gateway', [120, 180, 490, 920, 850, 610], '#3B82F6');
  ServerMetrics.AddDataset('Worker Pool', [45, 90, 280, 510, 480, 310], '#10B981');

  MetricsOptions := TBVChartOptions.Create;
  MetricsOptions.SetResponsive(True);
  MetricsOptions.SetMaintainAspectRatio(False);
  MetricsOptions.SetLegend(True, 'top');
  MetricsOptions.SetScales(True, True);

  // 2. Configure Doughnut Chart Data
  MemoryMetrics := TBVChartData.Create;
  MemoryMetrics.SetLabels(['mORMot 2 Core', 'V8 Runtime', 'Buffers', 'Free RAM']);
  MemoryMetrics.AddMultiColorDataset('Allocated MB', 
    [512, 340, 180, 968], 
    TBVChartPalette.Neon
  );

  DoughnutOptions := TBVChartOptions.Create;
  DoughnutOptions.SetResponsive(True);
  DoughnutOptions.SetMaintainAspectRatio(False);
  DoughnutOptions.SetLegend(True, 'right');

  // Register state in component
  this['ServerMetrics'] := ServerMetrics;
  this['MemoryMetrics'] := MemoryMetrics;
  this['MetricsOptions'] := MetricsOptions;
  this['DoughnutOptions'] := DoughnutOptions;
end;

procedure TChartsView.RandomizeData;
var
  NewData: array of Integer;
  i: Integer;
begin
  SetLength(NewData, 6);
  for i := 0 to 5 do
    NewData[i] := 100 + Random(900);

  // Updating the Pascal data immediately triggers smooth chart re-render
  ServerMetrics.Datasets[0].SetData(NewData);
end;

procedure TChartsView.ToggleTheme;
begin
  IsDark := not IsDark;
  MetricsOptions.SetDarkMode(IsDark);
  DoughnutOptions.SetDarkMode(IsDark);
end;

procedure TChartsView.OnMetricClick(Sender: TObject; Payload: JSValue);
begin
  WriteLn('Chart segment clicked! Element: ', Payload);
end;
</script>
```

---

## 🧪 Automated Testing & Vitest Suite

Blaise Charts is rigorously tested with automated unit tests (`tests/charts.test.pas`):
- Dataset property setters and array mutation.
- Multi-color palette assignment and RGBA conversions.
- Chart options serialization, dark mode transitions, and scale configuration.
- Fluent builder compilation.
- Canvas element mounting and lifecycle destruction.

Run all tests via CLI:
```bash
bv test
```

Result:
```text
✓ tests/charts.test.pas (9 tests passed)
✓ Test Files  21 passed (21)
✓ Tests       304 passed (304)
```
