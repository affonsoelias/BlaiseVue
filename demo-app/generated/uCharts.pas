unit uCharts;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils, BVPascalDX, BlaiseCharts;

procedure Register_uCharts;

implementation

procedure Register_uCharts;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  _styleEl := TJSHTMLElement(document.createElement('style'));
  _styleEl.textContent := '.chart-dashboard {     padding: 24px;     background: #f8fafc;     min-height: 100vh;   }   .header-card {     background: #ffffff;     padding: 24px 28px;     border-radius: 14px;     box-shadow: 0 4px 12px rgba(0,0,0,0.04);     margin-bottom: 24px;     border: 1px solid #e2e8f0;   }   .universal-card {     background: #ffffff;     border: 1px solid #cbd5e1;     border-top: 4px solid #3b82f6;   }   .chart-grid {     display: grid;     grid-template-columns: repeat(auto-fit, minmax(460px, 1fr));     gap: 24px;   }   .chart-item {     background: #ffffff;     padding: 20px 24px;     border-radius: 14px;     box-shadow: 0 4px 12px rgba(0,0,0,0.04);     border: 1px solid #e2e8f0;     display: flex;     flex-direction: column;     align-items: center;   }   .chart-header-row {     display: flex;     justify-content: space-between;     align-items: center;     width: 100%;     margin-bottom: 16px;     padding-bottom: 12px;     border-bottom: 1px solid #f1f5f9;   }   .chart-item h3 {     margin: 0;     font-size: 1.05rem;     font-weight: 600;     color: #1e293b;   }   .badge-type {     font-size: 0.75rem;     padding: 4px 8px;     background: #f1f5f9;     color: #475569;     border-radius: 6px;     font-weight: 600;     text-transform: uppercase;   }   .btn-type-pill {     background: #ffffff;     border: 1px solid #cbd5e1;     color: #334155;     padding: 5px 10px;     border-radius: 6px;     font-size: 0.8rem;     font-weight: 500;     cursor: pointer;     transition: all 0.15s ease;   }   .btn-type-pill:hover {     background: #3b82f6;     color: #ffffff;     border-color: #3b82f6;   }';
  document.head.appendChild(_styleEl);
  comp := TJSObject.new;
  comp['template'] :=
    '  <div class="chart-dashboard">' +
    '    <div class="header-card">' +
    '      <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">' +
    '        <div style="text-align: left;">' +
    '          <h1 style="margin: 0; font-size: 1.8rem; font-weight: 700; color: #1e293b;">' +
    '            📊 BlaiseCharts 4.0 - Data Visualization Suite' +
    '          </h1>' +
    '          <p style="margin: 6px 0 0 0; color: #64748b; font-size: 0.95rem;">' +
    '            Suíte oficial e dedicada de gráficos reativos via HTML5 Canvas (Chart.js), com classes e registros fortemente tipados em Object Pascal (<strong>packages/blaise-charts</strong>).' +
    '          </p>' +
    '        </div>' +
    '        <div style="display: flex; gap: 10px; flex-wrap: wrap;">' +
    '          <bv-btn variant="primary" @click="randomizeData">🎲 Randomizar Dados</bv-btn>' +
    '          <bv-btn variant="secondary" @click="togglePalette">🎨 Alternar Paleta ({{ currentPalette }})</bv-btn>' +
    '          <bv-btn variant="dark" @click="toggleDarkMode">🌓 {{ isDarkMode ? ''Modo Claro'' : ''Modo Escuro'' }}</bv-btn>' +
    '        </div>' +
    '      </div>' +
    '' +
    '      <div b-if="clickedPointInfo" style="margin-top: 18px; padding: 10px 16px; background: #e0f2fe; border-left: 4px solid #0284c7; border-radius: 6px; font-size: 0.9rem; color: #0369a1; text-align: left;">' +
    '        <strong>🎯 Ponto Selecionado / Status:</strong> {{ clickedPointInfo }}' +
    '      </div>' +
    '    </div>' +
    '' +
    '    <!-- 1. DESTAQUE: Componente Universal <bv-chart> com Troca Dinâmica de Tipo -->' +
    '    <div class="chart-item universal-card" style="margin-bottom: 24px;">' +
    '      <div class="chart-header-row">' +
    '        <div>' +
    '          <h3>🌟 &lt;bv-chart&gt; - Componente Universal com Tipo Dinâmico</h3>' +
    '          <p style="margin: 4px 0 0 0; font-size: 0.85rem; color: #64748b;">' +
    '            Um único componente reativo capaz de renderizar qualquer gráfico dinamicamente via prop <code>:type="{{ universalType }}"</code>:' +
    '          </p>' +
    '        </div>' +
    '        <div style="display: flex; gap: 6px; flex-wrap: wrap;">' +
    '          <button class="btn-type-pill" @click="setUniversalType(''bar'')">📊 Barras</button>' +
    '          <button class="btn-type-pill" @click="setUniversalType(''line'')">📈 Linha</button>' +
    '          <button class="btn-type-pill" @click="setUniversalType(''pie'')">🍕 Pizza</button>' +
    '          <button class="btn-type-pill" @click="setUniversalType(''doughnut'')">🍩 Rosca</button>' +
    '          <button class="btn-type-pill" @click="setUniversalType(''radar'')">🕸️ Radar</button>' +
    '          <button class="btn-type-pill" @click="setUniversalType(''polarArea'')">❄️ Polar</button>' +
    '        </div>' +
    '      </div>' +
    '      <bv-chart :type="universalType" :data="barData" :options="chartOptions" height="340px" @chart-click="onPointClick"></bv-chart>' +
    '    </div>' +
    '' +
    '    <!-- 2. GRID: Componentes Especializados do BlaiseCharts -->' +
    '    <div class="chart-grid">' +
    '      <!-- 2.1 Barras (bv-bar-chart) -->' +
    '      <div class="chart-item">' +
    '        <div class="chart-header-row">' +
    '          <h3>📊 Vendas Trimestrais (&lt;bv-bar-chart&gt;)</h3>' +
    '          <span class="badge-type">Bar / Column</span>' +
    '        </div>' +
    '        <bv-bar-chart :data="barData" :options="chartOptions" height="300px" @chart-click="onPointClick"></bv-bar-chart>' +
    '      </div>' +
    '' +
    '      <!-- 2.2 Linhas & Tendências (bv-line-chart) -->' +
    '      <div class="chart-item">' +
    '        <div class="chart-header-row">' +
    '          <h3>📈 Usuários &amp; Conexões WS (&lt;bv-line-chart&gt;)</h3>' +
    '          <span class="badge-type">Spline Line</span>' +
    '        </div>' +
    '        <bv-line-chart :data="lineData" :options="chartOptions" height="300px" @chart-click="onPointClick"></bv-line-chart>' +
    '      </div>' +
    '' +
    '      <!-- 2.3 Pizza Proporcional (bv-pie-chart) -->' +
    '      <div class="chart-item">' +
    '        <div class="chart-header-row">' +
    '          <h3>🍕 Distribuição de Tráfego (&lt;bv-pie-chart&gt;)</h3>' +
    '          <span class="badge-type">Pie Chart</span>' +
    '        </div>' +
    '        <bv-pie-chart :data="pieData" :options="pieOptions" height="300px" @chart-click="onPointClick"></bv-pie-chart>' +
    '      </div>' +
    '' +
    '      <!-- 2.4 Rosca / Doughnut (bv-doughnut-chart) -->' +
    '      <div class="chart-item">' +
    '        <div class="chart-header-row">' +
    '          <h3>🍩 Plataformas Suportadas (&lt;bv-doughnut-chart&gt;)</h3>' +
    '          <span class="badge-type">Doughnut</span>' +
    '        </div>' +
    '        <bv-doughnut-chart :data="doughnutData" :options="pieOptions" height="300px" @chart-click="onPointClick"></bv-doughnut-chart>' +
    '      </div>' +
    '' +
    '      <!-- 2.5 Área Polar (bv-polar-area-chart) -->' +
    '      <div class="chart-item">' +
    '        <div class="chart-header-row">' +
    '          <h3>❄️ Distribuição de Recursos (&lt;bv-polar-area-chart&gt;)</h3>' +
    '          <span class="badge-type">Polar Area</span>' +
    '        </div>' +
    '        <bv-polar-area-chart :data="pieData" :options="pieOptions" height="300px" @chart-click="onPointClick"></bv-polar-area-chart>' +
    '      </div>' +
    '' +
    '      <!-- 2.6 Radar / Competências (bv-radar-chart) -->' +
    '      <div class="chart-item">' +
    '        <div class="chart-header-row">' +
    '          <h3>🕸️ Análise de Desempenho (&lt;bv-radar-chart&gt;)</h3>' +
    '          <span class="badge-type">Radar Matrix</span>' +
    '        </div>' +
    '        <bv-radar-chart :data="radarData" :options="chartOptions" height="300px" @chart-click="onPointClick"></bv-radar-chart>' +
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
    d['universalType'] := 'bar';
    d['clickedPointInfo'] := '';
    d['currentPalette'] := 'Emerald';
    d['isDarkMode'] := false;
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
      // 2. Bar Chart Data (Typed TBVChartData)
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
    end;
    
  m['setUniversalType'] := procedure(_this: TJSObject; newType: string)

    begin
      _this['universalType'] := newType;
      _this['clickedPointInfo'] := 'Tipo do <bv-chart> alterado para: ' + newType;
    end;
    
  m['toggleDarkMode'] := procedure(_this: TJSObject)

    var
      NewDark: Boolean;
    begin
      NewDark := not Boolean(_this['isDarkMode']);
      _this['isDarkMode'] := NewDark;
      UpdateChartDarkMode(_this['chartOptions'], NewDark);
      _this['chartOptions'] := ObjectAssign(NewObject, _this['chartOptions']);
      if NewDark then
        _this['clickedPointInfo'] := 'Modo escuro ativado para escalas dos gráficos!'
      else
        _this['clickedPointInfo'] := 'Modo claro ativado para escalas dos gráficos!';
    end;
    
  m['randomizeData'] := procedure(_this: TJSObject)

    var
      NewData: TJSArray;
      i, Val: Integer;
      Datasets: TJSArray;
      Ds0: TJSObject;
    begin
      NewData := TJSArray.new;
      for i := 0 to 5 do
      begin
        Val := 10000 + Random(35000);
        NewData.push(Val);
      end;
      if _this['barData'] <> nil then
      begin
        Datasets := TJSArray(TJSObject(_this['barData'])['datasets']);
        if (Datasets <> nil) and (Datasets.Length > 0) then
        begin
          Ds0 := TJSObject(Datasets[0]);
          Ds0['data'] := NewData;
          _this['barData'] := ObjectAssign(NewObject, _this['barData']);
        end;
      end;
      _this['clickedPointInfo'] := 'Dados randomizados com sucesso!';
    end;
    
  m['togglePalette'] := procedure(_this: TJSObject)

    var
      Pal: TJSArray;
      Cur: string;
      Datasets: TJSArray;
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
      if _this['pieData'] <> nil then
      begin
        Datasets := TJSArray(TJSObject(_this['pieData'])['datasets']);
        if (Datasets <> nil) and (Datasets.Length > 0) then
        begin
          TJSObject(Datasets[0])['backgroundColor'] := Pal;
          TJSObject(Datasets[0])['borderColor'] := Pal;
          _this['pieData'] := ObjectAssign(NewObject, _this['pieData']);
        end;
      end;
      if _this['doughnutData'] <> nil then
      begin
        Datasets := TJSArray(TJSObject(_this['doughnutData'])['datasets']);
        if (Datasets <> nil) and (Datasets.Length > 0) then
        begin
          TJSObject(Datasets[0])['backgroundColor'] := Pal;
          TJSObject(Datasets[0])['borderColor'] := Pal;
          _this['doughnutData'] := ObjectAssign(NewObject, _this['doughnutData']);
        end;
      end;
      _this['clickedPointInfo'] := 'Paleta alterada para ' + String(_this['currentPalette']) + '!';
    end;
    
  m['onPointClick'] := procedure(_this: TJSObject; ev: JSValue)

    var
      Lbl, Val, DsIdx: string;
    begin
      if Boolean(ev) and (GetFieldStr(ev, 'label') <> '') then
      begin
        Lbl := GetFieldStr(ev, 'label');
        Val := GetFieldStr(ev, 'value');
        DsIdx := IntToStr(GetFieldInt(ev, 'datasetIndex', 0) + 1);
        _this['clickedPointInfo'] := 'Categoria: "' + Lbl + '", Valor: ' + Val + ' (Série #' + DsIdx + ')';
      end;
    end;

  comp['methods'] := m;

  comp['created'] := procedure(_this: TJSObject)
    begin
      asm if (!_this) _this = this; end;

      CallMethod(_this, 'initCharts');
    end;

    ;
  RegisterComponent('charts-page', comp);
end;

end.
