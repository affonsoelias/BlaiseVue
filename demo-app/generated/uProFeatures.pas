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
  _styleEl.textContent := '.pro-features { animation: fadeIn 0.5s ease-in; }   @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }    /* Transition Classes */   .fade-enter-active, .fade-leave-active { transition: opacity 0.5s, transform 0.5s; }   .fade-enter-from, .fade-leave-to { opacity: 0; transform: translateY(-10px); }   .fade-enter-to, .fade-leave-from { opacity: 1; transform: translateY(0); }    /* FLIP List Grid */   .flip-grid {     display: flex;     flex-wrap: wrap;     gap: 10px;     margin-top: 15px;     min-height: 50px;   }   .flip-card {     background: #ffffff;     border: 2px solid #42b883;     border-radius: 8px;     padding: 10px 16px;     font-weight: 600;     color: #2c3e50;     box-shadow: 0 2px 4px rgba(0,0,0,0.05);     display: inline-block;   }';
  document.head.appendChild(_styleEl);
  comp := TJSObject.new;
  comp['template'] :=
    '  <div class="pro-features">' +
    '    <h2 class="section-title">{{ $t(''pro.title'') }}</h2>' +
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
    '' +
    '    <!-- 6. Teste de Transições de Lista (Transition-Group FLIP) -->' +
    '    <div class="section">' +
    '       <h3>{{ $t(''pro.transitionTitle'') }}</h3>' +
    '       <p style="color: #64748b; margin-bottom: 12px;">' +
    '         O algoritmo <strong>FLIP</strong> (<em>First, Last, Invert, Play</em>) calcula a diferença de coordenadas geométricas antes e depois de mutações de lista e anima suavemente via CSS Transforms.' +
    '       </p>' +
    '       <div style="margin-bottom: 14px;">' +
    '         <button class="btn-primary" @click="embaralhar">{{ $t(''pro.shuffle'') }}</button>' +
    '         <button class="btn-outline" @click="adicionarItem">{{ $t(''pro.add'') }}</button>' +
    '         <button class="btn-danger" @click="removerItem">{{ $t(''pro.remove'') }}</button>' +
    '         <button class="btn-outline" @click="resetarLista">{{ $t(''pro.resetList'') }}</button>' +
    '       </div>' +
    '' +
    '       <transition-group tag="div" name="list" class="flip-grid">' +
    '          <div b-for="item in itens" class="flip-card">' +
    '             {{ item }}' +
    '          </div>' +
    '       </transition-group>' +
    '    </div>' +
    '  </div>';

  comp['data'] := function(): TJSObject
  var d: TJSObject;
  begin
    d := TJSObject.new;
    d['contador'] := 0;
    d['showElement'] := true;
    d['itens'] := '';
    Result := d;
  end;


  m := TJSObject.new;
  m['testarSlot'] := procedure(_this: TJSObject)

    begin
      asm console.log("[Slot Test] O pai está falando!"); end;
    end;
    
  m['mudarVersao'] := procedure(_this: TJSObject)

    var
      currentVer: string;
      newVer, newUser: string;
    begin
      currentVer := string(TJSObject(_this['$store'])['appVersion']);
      if currentVer = '2.1.0-ULTRA-PRO' then
      begin
        newVer := '3.0.0-TURBO-HYPER';
        newUser := 'Blaise Visionary 🚀';
      end
      else if currentVer = '3.0.0-TURBO-HYPER' then
      begin
        newVer := '1.0.0-PRO';
        newUser := 'DevMaster 🏆';
      end
      else
      begin
        newVer := '2.1.0-ULTRA-PRO';
        newUser := 'Pascal King 👑';
      end;
      TJSObject(_this['$store'])['appVersion'] := newVer;
      TJSObject(_this['$store'])['user'] := newUser;
      asm
        console.log("%c[Store] Memória Central Atualizada! Versão: " + newVer + " | Usuário: " + newUser, "color: #10b981; font-weight: bold; font-size: 13px;");
      end;
    end;
    
  m['incrementar'] := procedure(_this: TJSObject)

    begin
      _this['contador'] := Integer(_this['contador']) + 1;
    end;
    
  m['toggleShow'] := procedure(_this: TJSObject)

    begin
      _this['showElement'] := not Boolean(_this['showElement']);
    end;
    
  m['embaralhar'] := procedure(_this: TJSObject)

    begin
      asm
        if (Array.isArray(this.itens)) {
          this.itens = this.itens.slice().sort(() => Math.random() - 0.5);
        }
      end;
    end;
    
  m['adicionarItem'] := procedure(_this: TJSObject)

    begin
      asm
        if (Array.isArray(this.itens)) {
          const emojis = ['⚡ Lightning', '🔥 Fire', '🚀 Rocket', '💎 Diamond', '🔮 Crystal', '🌟 Star', '🛡️ Shield', '🎯 Target'];
          const rand = emojis[Math.floor(Math.random() * emojis.length)];
          this.itens.push(rand + ' #' + (this.itens.length + 1));
        }
      end;
    end;
    
  m['removerItem'] := procedure(_this: TJSObject)

    begin
      asm
        if (Array.isArray(this.itens) && this.itens.length > 0) {
          this.itens.shift();
        }
      end;
    end;
    
  m['resetarLista'] := procedure(_this: TJSObject)

    begin
      asm
        this.itens = ['⚡ Pascal', '🔥 BlaiseVue', '🚀 WebAssembly', '💎 HighPerf'];
      end;
    end;

  comp['methods'] := m;

  comp['created'] := procedure(_this: TJSObject)
    begin
      asm
        this.itens = ['⚡ Pascal', '🔥 BlaiseVue', '🚀 WebAssembly', '💎 HighPerf'];
      end;
    end;

    ;
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
