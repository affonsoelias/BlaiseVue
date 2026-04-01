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
  _styleEl.textContent := '.chart-dashboard {     padding: 20px;     background: #f8f9fa;     min-height: 100vh;   }   .header-card {     background: white;     padding: 30px;     border-radius: 12px;     box-shadow: 0 4px 6px rgba(0,0,0,0.05);     margin-bottom: 30px;     text-align: center;   }   .chart-grid {     display: grid;     grid-template-columns: repeat(auto-fit, minmax(450px, 1fr));     gap: 20px;   }   .chart-item {     background: white;     padding: 20px;     border-radius: 12px;     box-shadow: 0 2px 8px rgba(0,0,0,0.05);     display: flex;     flex-direction: column;     align-items: center;   }   .chart-item h3 {     margin-bottom: 20px;     color: #333;     width: 100%;     border-bottom: 1px solid #eee;     padding-bottom: 10px;   }   .btn-primary {     margin-top: 15px;     background: #007bff;     color: white;     border: none;     padding: 8px 16px;     border-radius: 6px;     cursor: pointer;   }';
  document.head.appendChild(_styleEl);
  comp := TJSObject.new;
  comp['template'] :=
    '  <div class="chart-dashboard">' +
    '    <div class="header-card">' +
    '      <h1>Dashboard de Gráficos (Chart.js)</h1>' +
    '      <p>Todos os componentes abaixo são wrappers BlaiseVue para a biblioteca Chart.js.</p>' +
    '    </div>' +
    '' +
    '    <div class="chart-grid">' +
    '      <!-- 1. Barras -->' +
    '      <div class="chart-item">' +
    '        <h3>Gráfico de Barras</h3>' +
    '        <c-bar :data="barData" :options="chartOptions"></c-bar>' +
    '        <button class="btn-primary" @click="randomizeData">Randomizar Dados</button>' +
    '      </div>' +
    '' +
    '      <!-- 2. Linhas -->' +
    '      <div class="chart-item">' +
    '        <h3>Gráfico de Linha</h3>' +
    '        <c-line :data="lineData" :options="chartOptions"></c-line>' +
    '      </div>' +
    '' +
    '      <!-- 3. Pizza -->' +
    '      <div class="chart-item">' +
    '        <h3>Gráfico de Pizza</h3>' +
    '        <c-pie :data="pieData" :options="pieOptions"></c-pie>' +
    '      </div>' +
    '' +
    '      <!-- 4. Rosca -->' +
    '      <div class="chart-item">' +
    '        <h3>Gráfico de Rosca (Doughnut)</h3>' +
    '        <c-doughnut :data="pieData" :options="pieOptions"></c-doughnut>' +
    '      </div>' +
    '' +
    '      <!-- 5. Área Polar -->' +
    '      <div class="chart-item">' +
    '        <h3>Área Polar</h3>' +
    '        <c-polar-area :data="pieData" :options="pieOptions"></c-polar-area>' +
    '      </div>' +
    '' +
    '      <!-- 6. Radar -->' +
    '      <div class="chart-item">' +
    '        <h3>Gráfico Radar</h3>' +
    '        <c-radar :data="radarData" :options="chartOptions"></c-radar>' +
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
       // Opções Globais
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
         // Dados de Exemplo
         this.barData = {
           labels: ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun'],
           datasets: [{
             label: 'Vendas 2025',
             data: [12, 19, 3, 5, 2, 3],
             backgroundColor: 'rgba(54, 162, 235, 0.5)',
             borderColor: 'rgb(54, 162, 235)',
             borderWidth: 1
           }]
         };
         this.lineData = {
           labels: ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun'],
           datasets: [{
             label: 'Usuários Ativos',
             data: [65, 59, 80, 81, 56, 55],
             fill: true,
             borderColor: 'rgb(75, 192, 192)',
             tension: 0.1
           }]
         };
         this.pieData = {
           labels: ['Red', 'Blue', 'Yellow'],
           datasets: [{
             data: [300, 50, 100],
             backgroundColor: ['rgb(255, 99, 132)', 'rgb(54, 162, 235)', 'rgb(255, 205, 86)']
           }]
         };
         this.radarData = {
           labels: ['Eating', 'Drinking', 'Sleeping', 'Designing', 'Coding', 'Cycling', 'Running'],
           datasets: [{
             label: 'Dev A',
             data: [65, 59, 90, 81, 56, 55, 40],
             fill: true,
             backgroundColor: 'rgba(255, 99, 132, 0.2)',
             borderColor: 'rgb(255, 99, 132)'
           }]
         };
       end;
    end;
    
  m['randomizeData'] := procedure(_this: TJSObject)

    var
      newData: JSValue;
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
