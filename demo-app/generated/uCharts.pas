unit uCharts;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uCharts;

implementation

procedure Register_uCharts;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  _styleEl := TJSHTMLElement(document.createElement('style'));
  _styleEl.textContent := '.chart-dashboard {     padding: 20px;     background: #f8fafc;     min-height: 100vh;   }   .header-card {     background: white;     padding: 30px;     border-radius: 12px;     box-shadow: 0 4px 6px rgba(0,0,0,0.05);     margin-bottom: 30px;     text-align: center;   }   .chart-grid {     display: grid;     grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));     gap: 20px;   }   .chart-item {     background: white;     padding: 20px;     border-radius: 12px;     box-shadow: 0 2px 8px rgba(0,0,0,0.05);     display: flex;     flex-direction: column;     align-items: center;   }   .chart-item h3 {     margin-bottom: 20px;     color: #1e293b;     width: 100%;     border-bottom: 1px solid #e2e8f0;     padding-bottom: 10px;   }';
  document.head.appendChild(_styleEl);
  comp := TJSObject.new;
  comp['template'] :=
    '  <div class="chart-dashboard">' +
    '    <div class="header-card">' +
    '      <h1>Dashboard de Gráficos (BlaiseUI Chart)</h1>' +
    '      <p>Todos os componentes abaixo são componentes reativos nativos do BlaiseUI alimentados por Chart.js.</p>' +
    '    </div>' +
    '' +
    '    <div class="chart-grid">' +
    '      <!-- 1. Barras -->' +
    '      <div class="chart-item">' +
    '        <h3>Gráfico de Barras</h3>' +
    '        <bv-bar :data="barData" :options="chartOptions"></bv-bar>' +
    '        <bv-btn variant="primary" @click="randomizeData">Randomizar Dados</bv-btn>' +
    '      </div>' +
    '' +
    '      <!-- 2. Linhas -->' +
    '      <div class="chart-item">' +
    '        <h3>Gráfico de Linha</h3>' +
    '        <bv-line :data="lineData" :options="chartOptions"></bv-line>' +
    '      </div>' +
    '' +
    '      <!-- 3. Pizza -->' +
    '      <div class="chart-item">' +
    '        <h3>Gráfico de Pizza</h3>' +
    '        <bv-pie :data="pieData" :options="pieOptions"></bv-pie>' +
    '      </div>' +
    '' +
    '      <!-- 4. Rosca -->' +
    '      <div class="chart-item">' +
    '        <h3>Gráfico de Rosca (Doughnut)</h3>' +
    '        <bv-doughnut :data="pieData" :options="pieOptions"></bv-doughnut>' +
    '      </div>' +
    '' +
    '      <!-- 5. Área Polar -->' +
    '      <div class="chart-item">' +
    '        <h3>Área Polar</h3>' +
    '        <bv-polar-area :data="pieData" :options="pieOptions"></bv-polar-area>' +
    '      </div>' +
    '' +
    '      <!-- 6. Radar -->' +
    '      <div class="chart-item">' +
    '        <h3>Gráfico Radar</h3>' +
    '        <bv-radar :data="radarData" :options="chartOptions"></bv-radar>' +
    '      </div>' +
    '    </div>' +
    '  </div>';

  comp['data'] := function(): TJSObject
  var d: TJSObject;
  begin
    d := TJSObject.new;
    d['chartOptions'] := null;
    d['pieOptions'] := null;
    d['barData'] := null;
    d['lineData'] := null;
    d['pieData'] := null;
    d['radarData'] := null;
    Result := d;
  end;


  m := TJSObject.new;
  m['initData'] := procedure(_this: TJSObject)

    begin
       asm
         this.chartOptions = {
           responsive: true,
           maintainAspectRatio: false,
           plugins: {
             legend: { position: 'top' },
             tooltip: { enabled: true }
           }
         };
         this.pieOptions = {
           responsive: true,
           maintainAspectRatio: false
         };
         this.barData = {
           labels: ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun'],
           datasets: [{
             label: 'Vendas 2026',
             data: [12, 19, 3, 5, 2, 3],
             backgroundColor: 'rgba(66, 184, 131, 0.5)',
             borderColor: '#42b883',
             borderWidth: 1
           }]
         };
         this.lineData = {
           labels: ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun'],
           datasets: [{
             label: 'Usuários Ativos',
             data: [65, 59, 80, 81, 56, 55],
             fill: true,
             borderColor: '#3b82f6',
             backgroundColor: 'rgba(59, 130, 246, 0.1)',
             tension: 0.1
           }]
         };
         this.pieData = {
           labels: ['Red', 'Blue', 'Green'],
           datasets: [{
             data: [300, 50, 100],
             backgroundColor: ['#ef4444', '#3b82f6', '#10b981']
           }]
         };
         this.radarData = {
           labels: ['Eating', 'Drinking', 'Sleeping', 'Designing', 'Coding', 'Cycling', 'Running'],
           datasets: [{
             label: 'Dev A',
             data: [65, 59, 90, 81, 56, 55, 40],
             fill: true,
             backgroundColor: 'rgba(66, 184, 131, 0.2)',
             borderColor: '#42b883'
           }]
         };
       end;
    end;
    
  m['randomizeData'] := procedure(_this: TJSObject)

    begin
       asm
         const newValues = Array.from({length: 6}, () => Math.floor(Math.random() * 20));
         this.barData = {
           ...this.barData,
           datasets: [{ ...this.barData.datasets[0], data: newValues }]
         };
       end;
    end;

  comp['methods'] := m;

  comp['created'] := procedure(_this: TJSObject)
    begin
       asm this.initData(); end;
    end;

    ;
  RegisterComponent('charts-page', comp);
end;

end.
