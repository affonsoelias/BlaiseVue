program charts_view_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, uBVBtn, uBVChart, uBVBarChart, uBVLineChart, uBVPieChart, uBVDoughnutChart, uBVPolarAreaChart, uBVRadarChart, uCharts;

var
  Wrapper: TWrapper;

begin
  Register_uBVBtn;
  Register_uBVChart;
  Register_uBVBarChart;
  Register_uBVLineChart;
  Register_uBVPieChart;
  Register_uBVDoughnutChart;
  Register_uBVPolarAreaChart;
  Register_uBVRadarChart;
  Register_uCharts;

  Describe('View: Charts', procedure
    begin
       It('deve inicializar a view de Graficos e renderizar dashboard completo', procedure
         begin
            Wrapper := Mount('charts-page');
            Expect(Wrapper.Element <> nil).ToBe(True);
            Expect(Wrapper.Find('.chart-dashboard')).toBeDefined;
            Expect(Wrapper.Find('.universal-card')).toBeDefined;
            Expect(Wrapper.Find('.chart-grid')).toBeDefined;
         end);
    end);
end.
