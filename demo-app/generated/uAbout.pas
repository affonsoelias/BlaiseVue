unit uAbout;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uAbout;

implementation

procedure Register_uAbout;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  _styleEl := TJSHTMLElement(document.createElement('style'));
  _styleEl.textContent := '.main-intro { text-align: center; background: #f8fafc; border-bottom: 2px solid #e2e8f0; }   .action-bar { margin-top: 20px; display: flex; gap: 10px; justify-content: center; }      .resource-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 15px; margin-top: 15px; }   .resource-item { padding: 15px; background: white; border: 1px solid #e2e8f0; border-radius: 8px; text-align: center; }   .resource-item p { font-size: 12px; margin-top: 8px; color: #64748b; }    .tech-card-pair { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }   .tech-card { padding: 20px; border-radius: 12px; color: white; display: flex; flex-direction: column; align-items: center; }   .fpc { background: linear-gradient(135deg, #1e293b 0%, #334155 100%); }   .pas2js { background: linear-gradient(135deg, #42b883 0%, #35495e 100%); }   .card-icon { font-size: 40px; margin-bottom: 10px; }    .lab-container { margin-top: 30px; border-top: 4px dashed #cbd5e1; padding-top: 20px; }   .lab-section { background: white; border-radius: 15px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); margin-bottom: 20px; }    .resource-list { list-style: none; padding: 0; margin-top: 15px; }   .resource-li { padding: 12px; border-bottom: 1px solid #f1f5f9; display: flex; align-items: center; gap: 10px; }   .li-tag { font-size: 11px; padding: 2px 8px; background: #f1f5f9; border-radius: 10px; color: #64748b; margin-left: auto; }    .form-horizontal { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 20px; }   .form-control { width: 100%; padding: 10px; border: 1px solid #cbd5e1; border-radius: 6px; }   .result-box { padding: 15px; background: #f0fdf4; border-left: 4px solid #42b883; border-radius: 4px; }   .res-text { color: #166534; font-weight: bold; margin-left: 10px; }    .alert { padding: 15px; border-radius: 8px; margin-top: 15px; font-weight: 500; }   .alert-success { background: #dcfce7; color: #166534; border: 1px solid #bbf7d0; }   .alert-warning { background: #fef9c3; color: #854d0e; border: 1px solid #fef08a; }    .btn-sm { padding: 6px 12px; font-size: 12px; }    @media (max-width: 600px) {     .tech-card-pair, .form-horizontal { grid-template-columns: 1fr; }   }';
  document.head.appendChild(_styleEl);
  comp := TJSObject.new;
  comp['template'] :=
    '  <div>' +
    '    <div class="section main-intro">' +
    '      <h1 class="section-title">Sobre o BlaiseVue Professional</h1>' +
    '      <p><strong>Status do Sistema:</strong> <span class="badge badge-green">Rodando via Pascal Power ⚔️</span></p>' +
    '      <p>Abaixo você encontra o laboratório analítico de todos os recursos implementados no framework.</p>' +
    '      ' +
    '      <div class="action-bar">' +
    '        <button class="btn-primary" @click="toggleDemos">' +
    '          {{ showDemos ? ''🔐 Fechar Laboratório'' : ''🔓 Abrir Laboratório de Recursos'' }}' +
    '        </button>' +
    '        <button class="btn-outline" @click="alertaTecnologia">Versão: {{ versao }}</button>' +
    '      </div>' +
    '    </div>' +
    '' +
    '    <!-- Tabela de Recursos (Sempre Visível) -->' +
    '    <div class="section">' +
    '      <h2 class="section-title">🛡️ Arsenal Technológico</h2>' +
    '      <div class="resource-grid">' +
    '        <div class="resource-item">' +
    '          <span class="badge badge-blue">Reatividade</span>' +
    '          <p>Dependency Tracking via Proxy JS</p>' +
    '        </div>' +
    '        <div class="resource-item">' +
    '          <span class="badge badge-green">Compilação</span>' +
    '          <p>AOT Pascal para JS Otimizado</p>' +
    '        </div>' +
    '        <div class="resource-item">' +
    '          <span class="badge badge-orange">Routing</span>' +
    '          <p>SPA Router com History/Hash</p>' +
    '        </div>' +
    '        <div class="resource-item">' +
    '          <span class="badge badge-gray">Store</span>' +
    '          <p>Global State Management (TBVStore)</p>' +
    '        </div>' +
    '      </div>' +
    '    </div>' +
    '' +
    '    <!-- Tecnologia VIP Cards -->' +
    '    <div class="section engine-section">' +
    '       <h2 class="section-title">⚙️ Motor de Alta Performance</h2>' +
    '       <div class="tech-card-pair">' +
    '          <div class="tech-card fpc">' +
    '             <div class="card-icon">🏰</div>' +
    '             <h3>Free Pascal</h3>' +
    '             <p>A segurança da tipagem forte.</p>' +
    '          </div>' +
    '          <div class="tech-card pas2js">' +
    '             <div class="card-icon">⚡</div>' +
    '             <h3>Pas2JS</h3>' +
    '             <p>A agilidade do ecossistema Web.</p>' +
    '          </div>' +
    '       </div>' +
    '    </div>' +
    '' +
    '    <!-- O LABORATÓRIO (Onde a mágica acontece) -->' +
    '    <transition name="fade">' +
    '      <div v-if="showDemos" class="lab-container">' +
    '          <!-- 1. Iteração Reativa (b-for) -->' +
    '          <div class="section lab-section">' +
    '            <h2 class="section-title">🔬 Laboratório 01: Iteração Dinâmica (b-for)</h2>' +
    '            <p>Os itens abaixo são injetados diretamente do Pascal em uma <code>TJSArray</code> reativa.</p>' +
    '            <ul class="resource-list">' +
    '              <li v-for="item in tecnologias" class="resource-li">' +
    '                <span class="li-icon">🔹</span>' +
    '                <strong>{{ item.nome }}</strong> ' +
    '                <span class="li-tag">{{ item.tipo }}</span>' +
    '              </li>' +
    '            </ul>' +
    '            <div style="margin-top: 15px;">' +
    '              <button class="btn-primary btn-sm" @click="addTec">➕ Injetar Nova Tecnologia</button>' +
    '              <button class="btn-danger btn-sm" @click="limparTecs">🗑️ Limpar Tudo</button>' +
    '            </div>' +
    '          </div>' +
    '' +
    '          <!-- 2. Two-Way e Computed -->' +
    '          <div class="section lab-section">' +
    '            <h2 class="section-title">📊 Laboratório 02: Computed & Two-Way</h2>' +
    '            <div class="form-horizontal">' +
    '              <div class="form-group">' +
    '                <label>Primeiro Nome:</label>' +
    '                <input type="text" b-model="firstName" class="form-control">' +
    '              </div>' +
    '              <div class="form-group">' +
    '                <label>Último Nome:</label>' +
    '                <input type="text" b-model="lastName" class="form-control">' +
    '              </div>' +
    '            </div>' +
    '            <div class="result-box">' +
    '              <strong>Resultado Computado:</strong> ' +
    '              <span class="res-text">{{ perfilInfo }}</span>' +
    '            </div>' +
    '          </div>' +
    '' +
    '          <!-- 3. Condicional e Estado -->' +
    '          <div class="section lab-section">' +
    '            <h2 class="section-title">🎭 Laboratório 03: Estado Condicional (b-if)</h2>' +
    '            <div class="toggle-control">' +
    '              <button class="btn-outline" @click="toggleLogin">' +
    '                {{ logado ? ''🔓 Deslogar'' : ''🔐 Simular Login'' }}' +
    '              </button>' +
    '            </div>' +
    '            <div v-if="logado" class="alert alert-success">' +
    '               ✅ Usuário autenticado via Pascal State!' +
    '            </div>' +
    '            <div v-if="!logado" class="alert alert-warning">' +
    '               ⚠️ Aguardando autenticação...' +
    '            </div>' +
    '          </div>' +
    '      </div>' +
    '    </transition>' +
    '  </div>';

  comp['data'] := function(): TJSObject
  var d: TJSObject;
  begin
    d := TJSObject.new;
    d['versao'] := '2.1.0-PRO';
    d['showDemos'] := false;
    d['logado'] := false;
    d['tecnologias'] := TJSArray.new;
    d['firstName'] := 'Blaise';
    d['lastName'] := 'Pascal';
    Result := d;
  end;

  m := TJSObject.new;
  m['toggleDemos'] := procedure(_this: TJSObject)

    var
      o1, o2: TJSObject;
    begin
      _this['showDemos'] := not Boolean(_this['showDemos']);
      // Popular inicial se estiver vazio
      if TJSArray(_this['tecnologias']).length = 0 then
      begin
        o1 := TJSObject.new;
        o1['nome'] := 'Object Pascal';
        o1['tipo'] := 'Linguagem';
        TJSArray(_this['tecnologias']).push(o1);
        o2 := TJSObject.new;
        o2['nome'] := 'Reatividade Proxy';
        o2['tipo'] := 'Core Engine';
        TJSArray(_this['tecnologias']).push(o2);
      end;
    end;
    
  m['toggleLogin'] := procedure(_this: TJSObject)

    begin
       asm 
         this.logado = !this.logado; 
         console.log("[Method] logado toggle: ", this.logado);
       end;
    end;
    
  m['addTec'] := procedure(_this: TJSObject)

    var
      o: TJSObject;
    begin
       o := TJSObject.new;
       o['nome'] := 'Recurso ' + IntToStr(TJSArray(_this['tecnologias']).length + 1);
       o['tipo'] := 'Gerado Dinamicamente';
       TJSArray(_this['tecnologias']).push(o);
    end;
    
  m['limparTecs'] := procedure(_this: TJSObject)

    begin
       TJSArray(_this['tecnologias']).length := 0;
    end;
    
  m['alertaTecnologia'] := procedure(_this: TJSObject)

    begin
      window.alert('BlaiseVue v2.1.0 \nOtimizado para alto desempenho!');
    end;

  comp['methods'] := m;

  comp['computed'] := TJSObject.new;
  TJSObject(comp['computed'])['perfilInfo'] := function(_this: TJSObject): JSValue

    begin
      Result := 'Mestre ' + string(_this['firstName']) + ' ' + string(_this['lastName']);
    end;

;

  RegisterComponent('about-page', comp);
end;

end.
