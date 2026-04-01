unit uProFeatures;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uProFeatures;

implementation

procedure Register_uProFeatures;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  _styleEl := TJSHTMLElement(document.createElement('style'));
  _styleEl.textContent := '.pro-features { animation: fadeIn 0.5s ease-in; }   @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }    /* Transition Classes */   .fade-enter-active, .fade-leave-active { transition: opacity 0.5s, transform 0.5s; }   .fade-enter-from, .fade-leave-to { opacity: 0; transform: translateY(-10px); }   .fade-enter-to, .fade-leave-from { opacity: 1; transform: translateY(0); }';
  document.head.appendChild(_styleEl);
  comp := TJSObject.new;
  comp['template'] :=
    '  <div class="pro-features">' +
    '    <h2 class="section-title">🛡️ BlaiseVue 2.0 Pro: Novas Fronteiras</h2>' +
    '    ' +
    '    <!-- 1. Teste de Slots -->' +
    '    <card titulo="Demonstração de Slot">' +
    '      <template slot="header">Título Customizado via Slot 🎨</template>' +
    '      <p>Este texto está vindo <strong>DA PÁGINA PAI</strong> e sendo injetado dentro do componente Card!</p>' +
    '      <button class="btn-primary" @click="testarSlot">Clique para Ver o Log</button>' +
    '      <template slot="footer">Rodapé customizado via Slot 🔗</template>' +
    '    </card>' +
    '' +
    '    <!-- 2. Teste de Global Store -->' +
    '    <div class="section">' +
    '       <h3>🧠 Memória Central ($store)</h3>' +
    '       <p>Versão do App: <span class="badge badge-green">{{ $store.appVersion }}</span></p>' +
    '       <p>Usuário Logado: <strong>{{ $store.user }}</strong></p>' +
    '       <button class="btn-outline" @click="mudarVersao">Atualizar Versão Global</button>' +
    '    </div>' +
    '' +
    '    <!-- 3. Teste de Provide/Inject -->' +
    '    <div class="section">' +
    '       <h3>🔗 Elo Sagrado (Inject)</h3>' +
    '       <p>Dados injetados do App Root:</p>' +
    '       <ul>' +
    '          <li>Ambiente: <strong>{{ getAmbiente().status }}</strong></li>' +
    '          <li>ID Interno: <strong>{{ getAmbiente().id }}</strong></li>' +
    '       </ul>' +
    '    </div>' +
    '' +
    '    <!-- 4. Teste de Lifecycle Updated -->' +
    '    <div class="section">' +
    '       <h3>🔄 Batida do Motor (Updated)</h3>' +
    '       <p>Contador de Reatividade: <strong>{{ contador }}</strong></p>' +
    '       <button class="btn-primary" @click="incrementar">Pulsar Motor</button>' +
    '       <p><small>(Veja o log no console para o hook ''updated'')</small></p>' +
    '    </div>' +
    '' +
    '    <!-- 5. Teste de Transições -->' +
    '    <div class="section">' +
    '       <h3>✨ Magia Visual (Transitions)</h3>' +
    '       <button class="btn-outline" @click="toggleShow">Alternar Elemento</button>' +
    '       <transition name="fade">' +
    '          <div v-show="showElement" class="badge badge-orange" style="padding: 20px; display: block; margin-top: 10px;">' +
    '             Surpresa! Eu apareço com suavidade. 🎭' +
    '          </div>' +
    '       </transition>' +
    '    </div>' +
    '  </div>';

  comp['data'] := function(): TJSObject
  var d: TJSObject;
  begin
    d := TJSObject.new;
    d['contador'] := 0;
    d['showElement'] := true;
    Result := d;
  end;

  m := TJSObject.new;
  m['testarSlot'] := procedure(_this: TJSObject)

    begin
      asm console.log("[Slot Test] O pai está falando!"); end;
    end;
    
  m['mudarVersao'] := procedure(_this: TJSObject)

    begin
      TJSObject(_this['$store'])['appVersion'] := '2.1.0-ULTRA-PRO';
      TJSObject(_this['$store'])['user'] := 'Pascal King 👑';
    end;
    
  m['incrementar'] := procedure(_this: TJSObject)

    begin
      _this['contador'] := Integer(_this['contador']) + 1;
    end;
    
  m['toggleShow'] := procedure(_this: TJSObject)

    begin
      _this['showElement'] := not Boolean(_this['showElement']);
    end;

  comp['methods'] := m;

  comp['updated'] := procedure(_this: TJSObject)
    begin
      asm console.log("[Lifecycle] Componente UPDATED! Pulso detectado."); end;
    end;

    ;
  comp['inject'] := TJSArray.new;
  TJSArray(comp['inject']).push('getAmbiente');

  RegisterComponent('pro-features-page', comp);
end;

end.
