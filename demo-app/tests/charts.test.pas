program charts_test;

{$mode objfpc}

uses
  JS, Web, SysUtils,
  BVTestUtils, BVComponents, BVReactivity, BVCompiler, BlaiseCharts, BlaiseVue,
  uBVChart, uBVBarChart, uBVLineChart, uBVPieChart, uBVDoughnutChart, uBVRadarChart, uBVPolarAreaChart;

var
  Wrapper: TWrapper;
  ChartProps: TJSObject;

begin
  // Register chart components
  Register_uBVChart;
  Register_uBVBarChart;
  Register_uBVLineChart;
  Register_uBVPieChart;
  Register_uBVDoughnutChart;
  Register_uBVRadarChart;
  Register_uBVPolarAreaChart;

  Describe('BlaiseVue 4.0 Reactive Charting Suite (BlaiseCharts)', procedure
    begin
      // 1. TBVChartDataset
      It('should create and configure typed TBVChartDataset series', procedure
        var
          Ds: TBVChartDataset;
          JSObj: TJSObject;
        begin
          Ds := TBVChartDataset.Create('Sales 2026');
          Ds.SetData([10.5, 20.0, 35.2])
            .BackgroundColor('#10b981')
            .BorderColor('#059669')
            .BorderWidth(2)
            .Fill(True)
            .Tension(0.4);

          JSObj := Ds.ToJS;
          Expect(JSObj['label']).ToBe('Sales 2026');
          Expect(TJSArray(JSObj['data']).length).ToBe(3);
          Expect(JSObj['backgroundColor']).ToBe('#10b981');
          Expect(JSObj['borderColor']).ToBe('#059669');
          Expect(JSObj['borderWidth']).ToBe(2);
          Expect(JSObj['fill']).ToBe(True);
        end);

      // 2. TBVChartData
      It('should manage labels and multiple datasets in TBVChartData', procedure
        var
          Data: TBVChartData;
          JSObj: TJSObject;
        begin
          Data := TBVChartData.Create;
          Data.Labels(['Jan', 'Feb', 'Mar', 'Apr'])
              .AddDataset('Product A', [100, 150, 200, 250], '#3b82f6')
              .BorderWidth(2);
          
          Data.AddDataset('Product B', [80, 120, 190, 220], '#10b981');

          Expect(Data.DatasetCount).ToBe(2);
          JSObj := Data.ToJS;
          Expect(TJSArray(JSObj['labels']).length).ToBe(4);
          Expect(TJSArray(JSObj['datasets']).length).ToBe(2);
          Expect(Data.Dataset(0).GetLabel).ToBe('Product A');
          Expect(Data.Dataset(1).GetLabel).ToBe('Product B');

          // Multi-color dataset
          Data.AddMultiColorDataset('Status', [40, 30, 20, 10], ['#ef4444', '#f59e0b', '#10b981', '#3b82f6']);
          Expect(Data.DatasetCount).ToBe(3);
        end);

      // 3. TBVChartOptions
      It('should configure responsive options, titles, legends and scales', procedure
        var
          Opts: TBVChartOptions;
          JSObj, Plugins, Scales: TJSObject;
        begin
          Opts := TBVChartOptions.Create;
          Opts.Responsive(True)
              .MaintainAspectRatio(False)
              .Title('Quarterly Financials', 18)
              .Legend('bottom', True)
              .Tooltip(True)
              .Scales(True, True, True);

          JSObj := Opts.ToJS;
          Expect(JSObj['responsive']).ToBe(True);
          Expect(JSObj['maintainAspectRatio']).ToBe(False);

          Plugins := TJSObject(JSObj['plugins']);
          Expect(Plugins).toBeDefined;
          Expect(TJSObject(Plugins['title'])['text']).ToBe('Quarterly Financials');
          Expect(TJSObject(Plugins['legend'])['position']).ToBe('bottom');

          Scales := TJSObject(JSObj['scales']);
          Expect(Scales).toBeDefined;
          Expect(TJSObject(TJSObject(Scales['y'])['ticks'])['beginAtZero']).ToBe(True);
        end);

      // 4. TBVChartOptions DarkMode
      It('should adapt colors dynamically for dark mode', procedure
        var
          Opts: TBVChartOptions;
          JSObj, Plugins, LegLabels: TJSObject;
        begin
          Opts := TBVChartOptions.Create;
          Opts.Title('System Monitor').Legend('top');
          Opts.DarkMode(True);

          JSObj := Opts.ToJS;
          Plugins := TJSObject(JSObj['plugins']);
          LegLabels := TJSObject(TJSObject(Plugins['legend'])['labels']);
          Expect(LegLabels['color']).ToBe('#e5e7eb');

          Opts.DarkMode(False);
          LegLabels := TJSObject(TJSObject(Plugins['legend'])['labels']);
          Expect(LegLabels['color']).ToBe('#4b5563');
        end);

      // 5. TBVChartPalette
      It('should generate hex-to-rgba and curated modern color palettes', procedure
        var
          Rgba: string;
          Pal: TJSArray;
        begin
          Rgba := TBVChartPalette.HexToRgba('#3b82f6', 0.5);
          Expect(Rgba).ToContain('rgba(59, 130, 246, 0.5)');

          Pal := TBVChartPalette.Emerald(6, 0.8);
          Expect(Pal.length).ToBe(6);

          Pal := TBVChartPalette.Sunset(6, 1.0);
          Expect(Pal.length).ToBe(6);

          Pal := TBVChartPalette.Cyberpunk(6, 0.9);
          Expect(Pal.length).ToBe(6);
        end);

      // 6. TBVChartBuilder
      It('should build complete chart configurations using fluent builder', procedure
        var
          Builder: TBVChartBuilder;
          DataObj, OptsObj: TJSObject;
        begin
          Builder := TBVChartBuilder.New(CHART_BAR)
            .WithLabels(['2023', '2024', '2025', '2026'])
            .AddDataset('Net Income', [120000, 150000, 180000, 240000], '#3b82f6')
            .WithTitle('Corporate Net Growth')
            .WithLegend('top')
            .Responsive(True);

          DataObj := Builder.BuildData;
          OptsObj := Builder.BuildOptions;

          Expect(Builder.ChartType).ToBe('bar');
          Expect(TJSArray(DataObj['labels']).length).ToBe(4);
          Expect(TJSArray(DataObj['datasets']).length).ToBe(1);
          Expect(TJSObject(TJSObject(OptsObj['plugins'])['title'])['text']).ToBe('Corporate Net Growth');

          Builder.Free;
        end);

      // 7. Component Mounting: bv-chart
      It('should mount reactive bv-chart component with canvas', procedure
        var
          Data: TBVChartData;
          Opts: TBVChartOptions;
        begin
          Data := TBVChartData.Create;
          Data.Labels(['A', 'B', 'C']).AddDataset('Sample', [10, 20, 30], '#3b82f6');
          Opts := TBVChartOptions.Create;

          ChartProps := TJSObject.new;
          ChartProps['type'] := 'bar';
          ChartProps['data'] := Data.ToJS;
          ChartProps['options'] := Opts.ToJS;
          ChartProps['width'] := '100%';
          ChartProps['height'] := '300px';

          Wrapper := Mount('bv-chart', ChartProps);
          Expect(Wrapper.Find('.bui-chart-wrapper')).toBeDefined;
          Expect(Wrapper.Find('canvas')).toBeDefined;
        end);

      // 8. Component Mounting: bv-bar-chart
      It('should mount dedicated bv-bar-chart convenience wrapper', procedure
        var
          Data: TBVChartData;
        begin
          Data := TBVChartData.Create;
          Data.Labels(['Mon', 'Tue', 'Wed']).AddDataset('Steps', [5000, 8000, 12000], '#10b981');

          ChartProps := TJSObject.new;
          ChartProps['data'] := Data.ToJS;
          ChartProps['height'] := '320px';

          Wrapper := Mount('bv-bar-chart', ChartProps);
          Expect(Wrapper.Find('.bui-chart-wrapper')).toBeDefined;
          Expect(Wrapper.Find('canvas')).toBeDefined;
        end);

      // 9. Component Mounting: bv-line-chart
      It('should mount dedicated bv-line-chart convenience wrapper', procedure
        var
          Data: TBVChartData;
        begin
          Data := TBVChartData.Create;
          Data.Labels(['1h', '2h', '3h']).AddDataset('Temp', [21.5, 22.0, 20.8], '#f59e0b');

          ChartProps := TJSObject.new;
          ChartProps['data'] := Data.ToJS;
          ChartProps['height'] := '320px';

          Wrapper := Mount('bv-line-chart', ChartProps);
          Expect(Wrapper.Find('.bui-chart-wrapper')).toBeDefined;
          Expect(Wrapper.Find('canvas')).toBeDefined;
        end);
    end);
end.
