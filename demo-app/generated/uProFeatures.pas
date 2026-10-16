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
  _styleEl.textContent := '.pro-features { animation: fadeIn 0.5s ease-in; }   @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }    /* Transition Classes */   .fade-enter-active, .fade-leave-active { transition: opacity 0.5s, transform 0.5s; }   .fade-enter-from, .fade-leave-to { opacity: 0; transform: translateY(-10px); }   .fade-enter-to, .fade-leave-from { opacity: 1; transform: translateY(0); }    /* FLIP List Grid */   .flip-grid {     display: flex;     flex-wrap: wrap;     gap: 10px;     margin-top: 15px;     min-height: 50px;   }   .flip-card {     background: #ffffff;     border: 2px solid #42b883;     border-radius: 8px;     padding: 10px 16px;     font-weight: 600;     color: #2c3e50;     box-shadow: 0 2px 4px rgba(0,0,0,0.05);     display: inline-block;   }    /* WebAssembly Section Styles */   .wasm-card { border-left: 4px solid #6366f1; }   .wasm-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 16px; margin-top: 12px; }   .wasm-box { background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 14px; }   .wasm-result { margin-top: 10px; font-size: 13px; padding: 8px 10px; background: #fff; border-radius: 6px; border: 1px solid #e2e8f0; }   .stat-badge { flex: 1; min-width: 140px; background: #fff; border: 1px solid #e2e8f0; border-radius: 6px; padding: 10px 14px; }   .stat-label { font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 600; }   .stat-val { font-size: 20px; font-weight: bold; margin-top: 4px; }    /* Dark mode adjustments */   html[data-bs-theme="dark"] .wasm-box, body.theme-dark .wasm-box,   html[data-bs-theme="dark"] .wasm-bench-container, body.theme-dark .wasm-bench-container {     background: #1e2227;     border-color: #333842;   }   html[data-bs-theme="dark"] .wasm-result, body.theme-dark .wasm-result,   html[data-bs-theme="dark"] .stat-badge, body.theme-dark .stat-badge {     background: #282c34;     border-color: #3e4451;     color: #e0e0e0;   }   html[data-bs-theme="dark"] .wasm-bench-title, body.theme-dark .wasm-bench-title {     color: #abb2bf;   }';
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
    '' +
    '    <!-- 7. Aceleração WebAssembly & Benchmarking (BlaiseVue 3.0 Engine) -->' +
    '    <div class="section wasm-card">' +
    '       <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; flex-wrap: wrap; gap: 8px;">' +
    '         <h3 style="color: #6366f1; margin: 0;">⚡ Aceleração WebAssembly ($wasm) - BlaiseVue 3.0</h3>' +
    '         <span class="badge" style="background: #6366f1;">Wasm Active 🚀</span>' +
    '       </div>' +
    '       <p style="color: #64748b; margin-bottom: 16px;">' +
    '         O BlaiseVue 3.0 integra computação de alto desempenho via <strong>WebAssembly nativo</strong> diretamente do Pascal no navegador através do objeto injetado <code>$wasm</code>, executando com velocidade quase-nativa em relação ao JavaScript tradicional.' +
    '       </p>' +
    '' +
    '       <div class="wasm-grid">' +
    '         <!-- Teste 1: Fibonacci Wasm -->' +
    '         <div class="wasm-box">' +
    '           <h4 style="color: #2c3e50; margin-bottom: 8px;">🔢 Cálculo Fibonacci Acelerado</h4>' +
    '           <p style="font-size: 13px; color: #64748b;">Calcule o N-ésimo número de Fibonacci via Wasm:</p>' +
    '           <div style="display: flex; gap: 8px; margin: 10px 0; align-items: center;">' +
    '             <input type="number" b-model="fibInput" style="width: 80px; padding: 6px; border: 1px solid #ccc; border-radius: 4px;" min="1" max="45" />' +
    '             <button class="btn-primary" @click="calcularWasmFib">Calcular Wasm ⚡</button>' +
    '           </div>' +
    '           <div class="wasm-result">' +
    '             Resultado: <strong>{{ wasmFibResult }}</strong>' +
    '             <br />' +
    '             <small>Tempo de execução: <strong>{{ wasmFibTime }} ms</strong></small>' +
    '           </div>' +
    '         </div>' +
    '' +
    '         <!-- Teste 2: Teste de Primalidade Wasm -->' +
    '         <div class="wasm-box">' +
    '           <h4 style="color: #2c3e50; margin-bottom: 8px;">🛡️ Teste de Primalidade Wasm</h4>' +
    '           <p style="font-size: 13px; color: #64748b;">Valide se um número grande é primo usando algoritmo compilado:</p>' +
    '           <div style="display: flex; gap: 8px; margin: 10px 0; align-items: center;">' +
    '             <input type="number" b-model="primeInput" style="width: 120px; padding: 6px; border: 1px solid #ccc; border-radius: 4px;" />' +
    '             <button class="btn-primary" style="background: #8e44ad;" @click="testarPrimoWasm">Verificar Primo 🔍</button>' +
    '           </div>' +
    '           <div class="wasm-result">' +
    '             Status: <strong>{{ primeResult }}</strong>' +
    '           </div>' +
    '         </div>' +
    '       </div>' +
    '' +
    '       <!-- Teste 3: Benchmark em Tempo Real -->' +
    '       <div style="margin-top: 20px; padding: 16px; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px;" class="wasm-bench-container">' +
    '         <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">' +
    '           <div>' +
    '             <h4 style="margin: 0; color: #1e293b;" class="wasm-bench-title">📊 Benchmark em Tempo Real: WebAssembly vs JavaScript</h4>' +
    '             <p style="font-size: 13px; color: #64748b; margin-top: 4px;">Executa 1.000 iterações em paralelo comparando Wasm com JS Vanilla.</p>' +
    '           </div>' +
    '           <button class="btn-primary" style="background: #6366f1;" @click="rodarBenchmark">Executar Benchmark 🚀</button>' +
    '         </div>' +
    '' +
    '         <div style="display: flex; gap: 16px; margin-top: 14px; flex-wrap: wrap;">' +
    '           <div class="stat-badge">' +
    '             <div class="stat-label">JavaScript Puro</div>' +
    '             <div class="stat-val" style="color: #e67e22;">{{ benchJsTime }} ms</div>' +
    '           </div>' +
    '           <div class="stat-badge">' +
    '             <div class="stat-label">WebAssembly Nativo</div>' +
    '             <div class="stat-val" style="color: #10b981;">{{ benchWasmTime }} ms</div>' +
    '           </div>' +
    '           <div class="stat-badge">' +
    '             <div class="stat-label">Aceleração Relativa</div>' +
    '             <div class="stat-val" style="color: #6366f1;">{{ benchSpeedup }}</div>' +
    '           </div>' +
    '         </div>' +
    '         <p style="font-size: 12px; color: #64748b; margin-top: 10px;">' +
    '           Status do Benchmark: <em>{{ benchSummary }}</em>' +
    '         </p>' +
    '       </div>' +
    '' +
    '       <!-- Teste 4: SSG / Hydration Engine Demo -->' +
    '       <div style="margin-top: 20px; padding: 14px; background: #ecfdf5; border: 1px solid #a7f3d0; border-radius: 8px;">' +
    '         <h4 style="margin: 0 0 6px 0; color: #065f46;">🚀 Motor SSG & Hidratação Reativa (BlaiseVue 3.0)</h4>' +
    '         <p style="font-size: 13px; color: #047857; margin: 0;">' +
    '           O BlaiseVue 3.0 detecta nós pré-renderizados estaticamente via <code>bv run ssg</code> e executa <strong>Rehydration</strong> reativa no cliente preservando a hierarquia DOM existente sem recriar os elementos do zero.' +
    '         </p>' +
    '       </div>' +
    '    </div>' +
    '  </div>';

  comp['data'] := function(): TJSObject
  var d: TJSObject;
  begin
    d := TJSObject.new;
    d['contador'] := 0;
    d['showElement'] := true;
    d['itens'] := '';
    d['fibInput'] := 20;
    d['wasmFibResult'] := 6765;
    d['wasmFibTime'] := '0.04';
    d['primeInput'] := 999983;
    d['primeResult'] := '999983 é primo! 💎';
    d['benchIters'] := 1000;
    d['benchJsTime'] := '0.00';
    d['benchWasmTime'] := '0.00';
    d['benchSpeedup'] := 'Calculando...';
    d['benchSummary'] := 'Pronto para execução';
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
    
  m['calcularWasmFib'] := procedure(_this: TJSObject)

    begin
      asm
        const n = parseInt(this.fibInput, 10) || 1;
        const t0 = performance.now();
        const res = this.$wasm.call('math', 'fib', n);
        const t1 = performance.now();
        this.wasmFibResult = res;
        this.wasmFibTime = (t1 - t0).toFixed(3);
      end;
    end;
    
  m['testarPrimoWasm'] := procedure(_this: TJSObject)

    begin
      asm
        const n = parseInt(this.primeInput, 10) || 2;
        const isP = this.$wasm.call('math', 'isPrime', n);
        if (isP === 1) {
          this.primeResult = n + ' é um NÚMERO PRIMO! 💎';
        } else {
          this.primeResult = n + ' NÃO é primo ❌';
        }
      end;
    end;
    
  m['rodarBenchmark'] := procedure(_this: TJSObject)

    begin
      asm
        const n = parseInt(this.fibInput, 10) || 20;
        const rep = this.$wasm.benchmark('math', 'fib', n, 1000);
        this.benchJsTime = rep.jsDurationMs;
        this.benchWasmTime = rep.wasmDurationMs;
        this.benchSpeedup = rep.speedup + ' Mais Rápido! 🚀';
        this.benchSummary = 'Executadas 1.000 iterações com sucesso no módulo math.';
      end;
    end;

  comp['methods'] := m;

  comp['created'] := procedure(_this: TJSObject)
    begin
      asm
        this.itens = ['⚡ Pascal', '🔥 BlaiseVue', '🚀 WebAssembly', '💎 HighPerf'];
        if (this.$wasm) {
          const rep = this.$wasm.benchmark('math', 'fib', 20, 1000);
          this.benchJsTime = rep.jsDurationMs;
          this.benchWasmTime = rep.wasmDurationMs;
          this.benchSpeedup = rep.speedup + ' Mais Rápido! 🚀';
          this.benchSummary = 'Módulo WebAssembly math ativo e operacional.';
        }
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
