unit uCharts;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils, BlaiseCharts;

procedure Register_uCharts;

implementation

procedure Register_uCharts;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  _styleEl := TJSHTMLElement(document.createElement('style'));
  _styleEl.textContent := '.chart-dashboard {     padding: 24px;     background: #f8fafc;     min-height: 100vh;   }   .header-card {     background: #ffffff;     padding: 24px 28px;     border-radius: 14px;     box-shadow: 0 4px 12px rgba(0,0,0,0.04);     margin-bottom: 24px;     border: 1px solid #e2e8f0;   }   .section-container {     margin-bottom: 28px;   }   .package-section-header {     display: flex;     justify-content: space-between;     align-items: center;     padding: 16px 20px;     border-radius: 12px;     margin-bottom: 18px;     border: 1px solid transparent;   }   .ui-header {     background: linear-gradient(135deg, #f0fdf4 0%, #ecfdf5 100%);     border-color: #bbf7d0;   }   .charts-header {     background: linear-gradient(135deg, #eff6ff 0%, #e0e7ff 100%);     border-color: #bfdbfe;   }   .badge-pkg {     font-size: 0.78rem;     font-weight: 700;     padding: 6px 12px;     border-radius: 20px;     text-transform: uppercase;     letter-spacing: 0.04em;   }   .badge-pkg-ui {     background: #10b981;     color: white;   }   .badge-pkg-charts {     background: #3b82f6;     color: white;   }   .chart-grid {     display: grid;     grid-template-columns: repeat(auto-fit, minmax(460px, 1fr));     gap: 24px;   }   .chart-item {     background: #ffffff;     padding: 20px 24px;     border-radius: 14px;     box-shadow: 0 4px 12px rgba(0,0,0,0.04);     border: 1px solid #e2e8f0;     display: flex;     flex-direction: column;     align-items: center;   }   .chart-header-row {     display: flex;     justify-content: space-between;     align-items: center;     width: 100%;     margin-bottom: 16px;     padding-bottom: 12px;     border-bottom: 1px solid #f1f5f9;   }   .chart-item h3 {     margin: 0;     font-size: 1.05rem;     font-weight: 600;     color: #1e293b;   }   .badge-type {     font-size: 0.75rem;     padding: 4px 8px;     background: #f1f5f9;     color: #475569;     border-radius: 6px;     font-weight: 600;     text-transform: uppercase;   }   .btn-type-pill {     background: #ffffff;     border: 1px solid #cbd5e1;     color: #334155;     padding: 5px 10px;     border-radius: 6px;     font-size: 0.8rem;     font-weight: 500;     cursor: pointer;     transition: all 0.15s ease;   }   .btn-type-pill:hover {     background: #3b82f6;     color: #ffffff;     border-color: #3b82f6;   }';
  document.head.appendChild(_styleEl);
  comp := TJSObject.new;
  comp['template'] :=
    '  <div class="chart-dashboard">' +
    '    <div class="header-card">' +
    '      <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">' +
    '        <div style="text-align: left;">' +
    '          <h1 style="margin: 0; font-size: 1.8rem; font-weight: 700; color: #1e293b;">' +
    '            📊 Data Visualization Suite: BlaiseCharts & BlaiseUI' +
    '          </h1>' +
    '          <p style="margin: 6px 0 0 0; color: #64748b; font-size: 0.95rem;">' +
    '            Demonstração dos componentes de gráficos do ecossistema BlaiseVue: a suíte fortemente tipada (<strong>blaise-charts</strong>) e o componente genérico base (<strong>blaise-ui</strong>).' +
    '          </p>' +
    '        </div>' +
    '        <div style="display: flex; gap: 10px; flex-wrap: wrap;">' +
    '          <bv-btn variant="primary" @click="randomizeData">🎲 Randomizar Dados</bv-btn>' +
    '          <bv-btn variant="secondary" @click="togglePalette">🎨 Alternar Paleta ({{ currentPalette }})</bv-btn>' +
    '        </div>' +
    '      </div>' +
    '' +
    '      <!-- Seletor de visualização (Filtro de Abas) -->' +
    '      <div style="display: flex; gap: 8px; margin-top: 20px; border-top: 1px solid #f1f5f9; padding-top: 16px; flex-wrap: wrap; align-items: center;">' +
    '        <span style="font-size: 0.85rem; font-weight: 600; color: #64748b; margin-right: 6px;">Visualizar Pacotes:</span>' +
    '        <bv-btn variant="primary" @click="showAll">🌟 Ver Todos</bv-btn>' +
    '        <bv-btn variant="success" @click="showChartsOnly">📊 BlaiseCharts 4.0 (Tipado)</bv-btn>' +
    '        <bv-btn variant="info" @click="showUIOnly">📦 BlaiseUI (&lt;bv-chart&gt; Genérico)</bv-btn>' +
    '      </div>' +
    '' +
    '      <div b-if="clickedPointInfo" style="margin-top: 18px; padding: 10px 16px; background: #e0f2fe; border-left: 4px solid #0284c7; border-radius: 6px; font-size: 0.9rem; color: #0369a1; text-align: left;">' +
    '        <strong>🎯 Status / Seleção:</strong> {{ clickedPointInfo }}' +
    '      </div>' +
    '    </div>' +
    '' +
    '    <!-- SEÇÃO 1: BLAISE-UI CHARTS (Componente Universal & Atalhos Legados) -->' +
    '    <div b-if="showBlaiseUI" class="section-container">' +
    '      <div class="package-section-header ui-header">' +
    '        <div style="text-align: left;">' +
    '          <h2 style="margin: 0; font-size: 1.35rem; color: #0f172a; display: flex; align-items: center; gap: 8px;">' +
    '            📦 Pacote: <code>blaise-ui</code> (&lt;bv-chart&gt; Universal)' +
    '          </h2>' +
    '          <p style="margin: 4px 0 0 0; color: #64748b; font-size: 0.88rem;">' +
    '            O componente universal <code>&lt;bv-chart&gt;</code> do BlaiseUI renderiza qualquer tipo de gráfico de forma dinâmica via prop <code>:type</code>.' +
    '          </p>' +
    '        </div>' +
    '        <span class="badge-pkg badge-pkg-ui">Core UI Package</span>' +
    '      </div>' +
    '' +
    '      <div class="chart-grid">' +
    '        <!-- 1.1 bv-chart Dinâmico -->' +
    '        <div class="chart-item" style="grid-column: 1 / -1;">' +
    '          <div class="chart-header-row">' +
    '            <div>' +
    '              <h3>🎨 &lt;bv-chart&gt; Universal com Tipo Dinâmico em Execução</h3>' +
    '              <p style="margin: 3px 0 0 0; font-size: 0.82rem; color: #64748b;">' +
    '                Alterne o tipo do gráfico em tempo real através da prop <code>:type="{{ legacyType }}"</code>:' +
    '              </p>' +
    '            </div>' +
    '            <div style="display: flex; gap: 6px; flex-wrap: wrap;">' +
    '              <button class="btn-type-pill" @click="setLegacyType(''bar'')">📊 Barras</button>' +
    '              <button class="btn-type-pill" @click="setLegacyType(''line'')">📈 Linha</button>' +
    '              <button class="btn-type-pill" @click="setLegacyType(''pie'')">🍕 Pizza</button>' +
    '              <button class="btn-type-pill" @click="setLegacyType(''doughnut'')">🍩 Rosca</button>' +
    '              <button class="btn-type-pill" @click="setLegacyType(''radar'')">🕸️ Radar</button>' +
    '              <button class="btn-type-pill" @click="setLegacyType(''polarArea'')">❄️ Polar</button>' +
    '            </div>' +
    '          </div>' +
    '          <bv-chart :type="legacyType" :data="legacyData" :options="chartOptions" height="340px"></bv-chart>' +
    '        </div>' +
    '' +
    '        <!-- 1.2 bv-bar do blaise-ui -->' +
    '        <div class="chart-item">' +
    '          <div class="chart-header-row">' +
    '            <h3>📊 &lt;bv-bar&gt; (Atalho BlaiseUI)</h3>' +
    '            <span class="badge-type">Bar Wrapper</span>' +
    '          </div>' +
    '          <bv-bar :data="legacyData" :options="chartOptions" height="280px"></bv-bar>' +
    '        </div>' +
    '' +
    '        <!-- 1.3 bv-line do blaise-ui -->' +
    '        <div class="chart-item">' +
    '          <div class="chart-header-row">' +
    '            <h3>📈 &lt;bv-line&gt; (Atalho BlaiseUI)</h3>' +
    '            <span class="badge-type">Line Wrapper</span>' +
    '          </div>' +
    '          <bv-line :data="legacyLineData" :options="chartOptions" height="280px"></bv-line>' +
    '        </div>' +
    '      </div>' +
    '    </div>' +
    '' +
    '    <!-- SEÇÃO 2: BLAISE-CHARTS 4.0 (Suíte Especializada & Tipada em Pascal) -->' +
    '    <div b-if="showBlaiseCharts" class="section-container" style="margin-top: 32px;">' +
    '      <div class="package-section-header charts-header">' +
    '        <div style="text-align: left;">' +
    '          <h2 style="margin: 0; font-size: 1.35rem; color: #0f172a; display: flex; align-items: center; gap: 8px;">' +
    '            📊 Pacote: <code>blaise-charts</code> (Suíte Especializada & Pascal Tipado)' +
    '          </h2>' +
    '          <p style="margin: 4px 0 0 0; color: #64748b; font-size: 0.88rem;">' +
    '            Componentes especializados com suporte direto a classes Pascal <code>TBVChartData</code>, <code>TBVChartOptions</code> e paletas <code>TBVChartPalette</code>.' +
    '          </p>' +
    '        </div>' +
    '        <span class="badge-pkg badge-pkg-charts">Dedicated Charts Suite</span>' +
    '      </div>' +
    '' +
    '      <div class="chart-grid">' +
    '        <!-- 2.1 Barras Tipadas (bv-bar-chart) -->' +
    '        <div class="chart-item">' +
    '          <div class="chart-header-row">' +
    '            <h3>📊 Vendas Trimestrais (&lt;bv-bar-chart&gt;)</h3>' +
    '            <span class="badge-type">Bar / Column</span>' +
    '          </div>' +
    '          <bv-bar-chart :data="barData" :options="chartOptions" height="300px" @chart-click="onPointClick"></bv-bar-chart>' +
    '        </div>' +
    '' +
    '        <!-- 2.2 Linhas & Tendências (bv-line-chart) -->' +
    '        <div class="chart-item">' +
    '          <div class="chart-header-row">' +
    '            <h3>📈 Usuários &amp; Conexões WS (&lt;bv-line-chart&gt;)</h3>' +
    '            <span class="badge-type">Spline Line</span>' +
    '          </div>' +
    '          <bv-line-chart :data="lineData" :options="chartOptions" height="300px" @chart-click="onPointClick"></bv-line-chart>' +
    '        </div>' +
    '' +
    '        <!-- 2.3 Pizza Proporcional (bv-pie-chart) -->' +
    '        <div class="chart-item">' +
    '          <div class="chart-header-row">' +
    '            <h3>🍕 Distribuição de Tráfego (&lt;bv-pie-chart&gt;)</h3>' +
    '            <span class="badge-type">Pie Chart</span>' +
    '          </div>' +
    '          <bv-pie-chart :data="pieData" :options="pieOptions" height="300px" @chart-click="onPointClick"></bv-pie-chart>' +
    '        </div>' +
    '' +
    '        <!-- 2.4 Rosca / Doughnut (bv-doughnut-chart) -->' +
    '        <div class="chart-item">' +
    '          <div class="chart-header-row">' +
    '            <h3>🍩 Plataformas Suportadas (&lt;bv-doughnut-chart&gt;)</h3>' +
    '            <span class="badge-type">Doughnut</span>' +
    '          </div>' +
    '          <bv-doughnut-chart :data="doughnutData" :options="pieOptions" height="300px" @chart-click="onPointClick"></bv-doughnut-chart>' +
    '        </div>' +
    '' +
    '        <!-- 2.5 Área Polar (bv-polar-area-chart) -->' +
    '        <div class="chart-item">' +
    '          <div class="chart-header-row">' +
    '            <h3>❄️ Distribuição de Recursos (&lt;bv-polar-area-chart&gt;)</h3>' +
    '            <span class="badge-type">Polar Area</span>' +
    '          </div>' +
    '          <bv-polar-area-chart :data="pieData" :options="pieOptions" height="300px" @chart-click="onPointClick"></bv-polar-area-chart>' +
    '        </div>' +
    '' +
    '        <!-- 2.6 Radar / Competências (bv-radar-chart) -->' +
    '        <div class="chart-item">' +
    '          <div class="chart-header-row">' +
    '            <h3>🕸️ Análise de Desempenho (&lt;bv-radar-chart&gt;)</h3>' +
    '            <span class="badge-type">Radar Matrix</span>' +
    '          </div>' +
    '          <bv-radar-chart :data="radarData" :options="chartOptions" height="300px" @chart-click="onPointClick"></bv-radar-chart>' +
    '        </div>' +
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
    d['doughnutData'] := null;
    d['radarData'] := null;
    d['legacyData'] := null;
    d['legacyLineData'] := null;
    d['legacyType'] := 'bar';
    d['clickedPointInfo'] := '';
    d['currentPalette'] := 'Emerald';
    d['showBlaiseCharts'] := true;
    d['showBlaiseUI'] := true;
    Result := d;
  end;


  m := TJSObject.new;
  m['initCharts'] := procedure(_this: TJSObject)

    var
      BarModel, LineModel, PieModel, DoughnutModel, RadarModel: TBVChartData;
      OptsModel, PieOptsModel: TBVChartOptions;
    begin
      // 1. Chart Options
      OptsModel := TBVChartOptions.Create;
      OptsModel.Responsive(True)
               .MaintainAspectRatio(False)
               .Legend('top')
               .Tooltip(True)
               .Scales(True, True, True);
      _this['chartOptions'] := OptsModel.ToJS;
      PieOptsModel := TBVChartOptions.Create;
      PieOptsModel.Responsive(True)
                  .MaintainAspectRatio(False)
                  .Legend('bottom');
      _this['pieOptions'] := PieOptsModel.ToJS;
      // 2. Bar Chart Data (Typed TBVChartData from BlaiseCharts)
      BarModel := TBVChartData.Create;
      BarModel.Labels(['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun']);
      BarModel.AddDataset('Vendas 2026', [14500, 21800, 18900, 27400, 31200, 42000], 'rgba(16, 185, 129, 0.6)', '#10b981');
      BarModel.AddDataset('Metas 2026',  [12000, 18000, 20000, 25000, 30000, 38000], 'rgba(59, 130, 246, 0.5)', '#3b82f6');
      _this['barData'] := BarModel.ToJS;
      // 3. Line Chart Data (Typed TBVChartData)
      LineModel := TBVChartData.Create;
      LineModel.Labels(['00:00', '04:00', '08:00', '12:00', '16:00', '20:00']);
      LineModel.AddDataset('Conexões WebSocket', [320, 180, 840, 1920, 2450, 1880], 'rgba(99, 102, 241, 0.2)', '#6366f1')
               .Fill(True)
               .Tension(0.35)
               .PointRadius(5);
      _this['lineData'] := LineModel.ToJS;
      // 4. Pie Chart Data (Typed Multi-Color)
      PieModel := TBVChartData.Create;
      PieModel.Labels(['Web (SPA)', 'Desktop (WebUI)', 'Mobile (Capacitor)', 'Backend REST']);
      PieModel.AddMultiColorDataset('Requisições', [45, 25, 20, 10], ['#3b82f6', '#10b981', '#f59e0b', '#8b5cf6']);
      _this['pieData'] := PieModel.ToJS;
      // 5. Doughnut Chart Data
      DoughnutModel := TBVChartData.Create;
      DoughnutModel.Labels(['Windows x64', 'Linux ARM/x64', 'Android', 'macOS']);
      DoughnutModel.AddMultiColorDataset('Instalações', [52, 28, 14, 6], ['#06b6d4', '#10b981', '#ec4899', '#f59e0b']);
      _this['doughnutData'] := DoughnutModel.ToJS;
      // 6. Radar Chart Data
      RadarModel := TBVChartData.Create;
      RadarModel.Labels(['Velocidade', 'Tipagem Pascal', 'Reatividade', 'Memória Baixa', 'Full-Stack', 'Multiplataforma']);
      RadarModel.AddDataset('BlaiseVue 4.0', [98, 100, 95, 92, 97, 96], 'rgba(16, 185, 129, 0.3)', '#10b981')
                .Fill(True);
      _this['radarData'] := RadarModel.ToJS;
      // 7. BlaiseUI Legacy/Generic Chart Data (Direct JS Objects)
      asm
        this.legacyData = {
          labels: ['Frontend', 'Backend mORMot', 'Database SQLite', 'Mobile Capacitor', 'WebUI Desktop'],
          datasets: [{
            label: 'Taxa de Entrega (BlaiseUI <bv-chart>)',
            data: [95, 98, 92, 88, 94],
            backgroundColor: [
              'rgba(59, 130, 246, 0.7)',
              'rgba(16, 185, 129, 0.7)',
              'rgba(245, 158, 11, 0.7)',
              'rgba(236, 72, 153, 0.7)',
              'rgba(139, 92, 246, 0.7)'
            ],
            borderColor: ['#3b82f6', '#10b981', '#f59e0b', '#ec4899', '#8b5cf6'],
            borderWidth: 2
          }]
        };
        this.legacyLineData = {
          labels: ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'],
          datasets: [{
            label: 'Throughput do Servidor (req/s)',
            data: [4200, 6800, 5900, 8400, 9200, 11500, 8900],
            fill: true,
            backgroundColor: 'rgba(14, 165, 233, 0.25)',
            borderColor: '#0ea5e9',
            tension: 0.35,
            borderWidth: 3
          }]
        };
      end;
    end;
    
  m['showAll'] := procedure(_this: TJSObject)

    begin
      _this['showBlaiseCharts'] := True;
      _this['showBlaiseUI'] := True;
      _this['clickedPointInfo'] := 'Exibindo todos os componentes (BlaiseCharts + BlaiseUI).';
    end;
    
  m['showChartsOnly'] := procedure(_this: TJSObject)

    begin
      _this['showBlaiseCharts'] := True;
      _this['showBlaiseUI'] := False;
      _this['clickedPointInfo'] := 'Filtrando apenas a suíte oficial blaise-charts.';
    end;
    
  m['showUIOnly'] := procedure(_this: TJSObject)

    begin
      _this['showBlaiseCharts'] := False;
      _this['showBlaiseUI'] := True;
      _this['clickedPointInfo'] := 'Filtrando apenas o componente <bv-chart> do blaise-ui.';
    end;
    
  m['setLegacyType'] := procedure(_this: TJSObject; newType: string)

    begin
      _this['legacyType'] := newType;
      _this['clickedPointInfo'] := 'Tipo do <bv-chart> alterado dinamicamente para: ' + newType;
    end;
    
  m['randomizeData'] := procedure(_this: TJSObject)

    var
      NewData: TJSArray;
      i, Val: Integer;
    begin
      NewData := TJSArray.new;
      for i := 0 to 5 do
      begin
        Val := 10000 + Random(35000);
        NewData.push(Val);
      end;
      asm
        if (this.barData && this.barData.datasets && this.barData.datasets[0]) {
          this.barData.datasets[0].data = NewData;
          this.barData = Object.assign({}, this.barData);
        }
        if (this.legacyData && this.legacyData.datasets && this.legacyData.datasets[0]) {
          const lData = [50 + Math.floor(Math.random() * 50), 50 + Math.floor(Math.random() * 50), 50 + Math.floor(Math.random() * 50), 50 + Math.floor(Math.random() * 50), 50 + Math.floor(Math.random() * 50)];
          this.legacyData.datasets[0].data = lData;
          this.legacyData = Object.assign({}, this.legacyData);
        }
      end;
      _this['clickedPointInfo'] := 'Dados randomizados com sucesso!';
    end;
    
  m['togglePalette'] := procedure(_this: TJSObject)

    var
      Pal: TJSArray;
      Cur: string;
    begin
      Cur := String(_this['currentPalette']);
      if Cur = 'Emerald' then
      begin
        _this['currentPalette'] := 'Sunset';
        Pal := TBVChartPalette.Sunset(4, 0.7);
      end
      else if Cur = 'Sunset' then
      begin
        _this['currentPalette'] := 'Cyberpunk';
        Pal := TBVChartPalette.Cyberpunk(4, 0.7);
      end
      else if Cur = 'Cyberpunk' then
      begin
        _this['currentPalette'] := 'Neon';
        Pal := TBVChartPalette.Neon(4, 0.7);
      end
      else
      begin
        _this['currentPalette'] := 'Emerald';
        Pal := TBVChartPalette.Emerald(4, 0.7);
      end;
      asm
        if (this.pieData && this.pieData.datasets && this.pieData.datasets[0]) {
          this.pieData.datasets[0].backgroundColor = Pal;
          this.pieData.datasets[0].borderColor = Pal;
          this.pieData = Object.assign({}, this.pieData);
        }
        if (this.doughnutData && this.doughnutData.datasets && this.doughnutData.datasets[0]) {
          this.doughnutData.datasets[0].backgroundColor = Pal;
          this.doughnutData.datasets[0].borderColor = Pal;
          this.doughnutData = Object.assign({}, this.doughnutData);
        }
      end;
      _this['clickedPointInfo'] := 'Paleta alterada para ' + String(_this['currentPalette']) + '!';
    end;
    
  m['onPointClick'] := procedure(_this: TJSObject; ev: JSValue)

    begin
      asm
        if (ev && ev.label !== undefined) {
          this.clickedPointInfo = 'Categoria: "' + ev.label + '", Valor: ' + ev.value + ' (Série #' + (ev.datasetIndex + 1) + ')';
        }
      end;
    end;

  comp['methods'] := m;

  comp['created'] := procedure(_this: TJSObject)
    begin
      asm this.initCharts(); end;
    end;

    ;
  RegisterComponent('charts-page', comp);
end;

end.
