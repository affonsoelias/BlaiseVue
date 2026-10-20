# blaise-charts 📊

The official reactive data visualization suite for **BlaiseVue 4.0**, powered by **Chart.js** and strongly typed **Object Pascal** data structures.

---

## Features

- 🚀 **Hardware-Accelerated HTML5 Canvas**: Smooth 60 FPS transitions across Web, Mobile (Capacitor/Android), and Desktop (WebUI).
- 🧩 **Zero External Dependencies**: Bundled standalone `chart.min.js` ensures 100% offline rendering without CDN reliance.
- 🎯 **Strongly Typed Pascal Models**: Write robust Pascal logic using `TBVChartData`, `TBVChartDataset`, `TBVChartOptions`, and `TBVChartPalette`.
- 🔄 **Automatic Vue-Style Reactivity**: Watches bound Pascal state and triggers intelligent chart updates (`chart.update()`).
- 🌓 **Dynamic Theme Integration**: Synchronizes typography and grid contrast with dark/light themes (`packages/blaise-themes`).
- 🖱️ **Interactive Point Events**: Listen to `@chart-click` to drill down into dataset and index coordinates.

---

## Installation

Add to any BlaiseVue project via CLI:

```bash
bv lib install charts
# or:
bv lib install blaise-charts
```

---

## Quick Example (Pascal Component)

```pascal
unit DashboardView;

interface

uses
  BlaiseVue, BlaiseCharts;

type
  TDashboard = class(TBVComponent)
  private
    SalesData: TBVChartData;
    ChartOptions: TBVChartOptions;
  public
    procedure Created; override;
    procedure Randomize;
  end;

implementation

procedure TDashboard.Created;
begin
  // Strongly typed Pascal data definition
  SalesData := TBVChartData.Create;
  SalesData.Labels(['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun']);
  SalesData.AddDataset('Revenue 2026', [12000, 19000, 3000, 5000, 2000, 3000], '#3b82f6');

  // Strongly typed Pascal options
  ChartOptions := TBVChartOptions.Create;
  ChartOptions.Title('Monthly Revenue Performance')
              .Legend('top')
              .Responsive(True);
end;

procedure TDashboard.Randomize;
begin
  SalesData.Dataset(0).SetData([22000, 14000, 28000, 39000, 41000, 58000]);
end;

end.
```

In your Single File Component template:

```html
<template>
  <div class="dashboard">
    <bv-chart type="bar" :data="SalesData" :options="ChartOptions" height="360px" @chart-click="onPointClick"></bv-chart>
    <bv-btn variant="primary" @click="Randomize">Update Data</bv-btn>
  </div>
</template>
```

---

## Available Components

| Component | Description | Default Type |
|---|---|---|
| `<bv-chart>` | Universal dynamic chart component | Configurable via `:type` |
| `<bv-bar-chart>` / `<bv-bar>` | Bar & column series | `bar` |
| `<bv-line-chart>` / `<bv-line>` | Line, smooth spline & area charts | `line` |
| `<bv-pie-chart>` / `<bv-pie>` | Proportional pie chart | `pie` |
| `<bv-doughnut-chart>` / `<bv-doughnut>` | Ring / doughnut chart | `doughnut` |
| `<bv-radar-chart>` / `<bv-radar>` | Spider / radar assessment chart | `radar` |
| `<bv-polar-area-chart>` / `<bv-polar-area>` | Polar area radial chart | `polarArea` |
| `<bv-scatter-chart>` | Cartesian XY scatter plot | `scatter` |
| `<bv-bubble-chart>` | Multi-variable bubble chart | `bubble` |
