unit uProFeatures;

{$mode objfpc}
{$modeswitch externalclass}
{$COPERATORS ON}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, BVFSM, SysUtils, BVPascalDX, BVDataSet;

procedure Register_uProFeatures;

implementation

type
  TComponentThis = class external name 'Object' (TJSObject)
    contador: Integer;
    showElement: Boolean;
    fibInput: Integer;
    wasmFibResult: Integer;
    wasmFibTime: string;
    primeInput: Integer;
    primeResult: string;
    benchIters: Integer;
    benchJsTime: string;
    benchWasmTime: string;
    benchSpeedup: string;
    benchSummary: string;
  end;

procedure Register_uProFeatures;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  _styleEl := TJSHTMLElement(document.createElement('style'));
  _styleEl.textContent := '.pro-features { animation: fadeIn 0.5s ease-in; }   @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }    /* Transition Classes */   .fade-enter-active, .fade-leave-active { transition: opacity 0.5s, transform 0.5s; }   .fade-enter-from, .fade-leave-to { opacity: 0; transform: translateY(-10px); }   .fade-enter-to, .fade-leave-from { opacity: 1; transform: translateY(0); }    /* FLIP List Grid */   .flip-grid {     display: flex;     flex-wrap: wrap;     gap: 10px;     margin-top: 15px;     min-height: 50px;   }   .flip-card {     background: var(--bv-surface);     border: 2px solid #42b883;     border-radius: 8px;     padding: 10px 16px;     font-weight: 600;     color: var(--bv-text);     box-shadow: var(--bv-shadow);     display: inline-block;   }    /* WebAssembly Section Styles */   .wasm-card { border-left: 4px solid #6366f1; }   .wasm-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 16px; margin-top: 12px; }   .wasm-box { background: var(--bv-surface-subtle); border: 1px solid var(--bv-border); border-radius: 8px; padding: 14px; }   .wasm-bench-container { margin-top: 20px; padding: 16px; background: var(--bv-surface-subtle); border: 1px solid var(--bv-border); border-radius: 8px; }   .wasm-result { margin-top: 10px; font-size: 13px; padding: 8px 10px; background: var(--bv-surface); border-radius: 6px; border: 1px solid var(--bv-border); color: var(--bv-text); }   .stat-badge { flex: 1; min-width: 140px; background: var(--bv-surface); border: 1px solid var(--bv-border); border-radius: 6px; padding: 10px 14px; }   .stat-label { font-size: 11px; text-transform: uppercase; color: var(--bv-text-muted); font-weight: 600; }   .stat-val { font-size: 20px; font-weight: bold; margin-top: 4px; }   .ssg-info-box { margin-top: 20px; padding: 14px; background: rgba(16, 185, 129, 0.12); border: 1px solid rgba(16, 185, 129, 0.35); border-radius: 8px; }   .ssg-info-box h4, .ssg-info-box p { color: #10b981; }';
  document.head.appendChild(_styleEl);
  comp := TJSObject.new;
  comp['template'] :=
    '  <div class="pro-features">' +
    '    <h2 class="section-title">{{ $t(''pro.title'') }}</h2>' +
    '' +
    '    <!-- 1. Slot Demonstration -->' +
    '    <card titulo="Slot Demonstration">' +
    '<template slot="header">Custom Title via Slot 🎨</template>' +
    '  <p>This markup is transmitted <strong>FROM THE PARENT VIEW</strong> and injected inside the Card component slot.</p>' +
    '  <button class="btn-primary" @click="testarSlot">Click to Inspect Console Log</button>' +
    '<template slot="footer">Custom Footer via Slot 🔗</template>' +
    '  </card>' +
    '' +
    '  <!-- 2. Global Store ($store) -->' +
    '  <div class="section">' +
    '    <h3>🧠 Central Reactive Memory ($store)</h3>' +
    '    <p>Active User: <strong>{{ $store.user }}</strong></p>' +
    '    <button class="btn-outline" @click="atualizarEstadoGlobal">Update Global State</button>' +
    '  </div>' +
    '' +
    '  <!-- 3. Provide/Inject -->' +
    '  <div class="section">' +
    '    <h3>🔗 Hierarchical Context (Inject)</h3>' +
    '    <p>Injected context from Application Root:</p>' +
    '    <ul>' +
    '      <li>Environment: <strong>{{ getAmbiente().status }}</strong></li>' +
    '      <li>Internal Instance ID: <strong>{{ getAmbiente().id }}</strong></li>' +
    '    </ul>' +
    '  </div>' +
    '' +
    '  <!-- 4. Lifecycle Hook (Updated) -->' +
    '  <div class="section">' +
    '    <h3>🔄 Engine Pulse (Updated Lifecycle)</h3>' +
    '    <p>Reactivity Counter: <strong>{{ contador }}</strong></p>' +
    '    <button class="btn-primary" @click="incrementar">Pulse Engine</button>' +
    '    <p><small>(Inspect console log to view ''updated'' hook telemetry)</small></p>' +
    '  </div>' +
    '' +
    '  <!-- 5. Transitions -->' +
    '  <div class="section">' +
    '    <h3>✨ Visual Polish (Transitions)</h3>' +
    '    <button class="btn-outline" @click="toggleShow">Toggle Animated Element</button>' +
    '    <transition name="fade">' +
    '      <div v-show="showElement" class="badge badge-orange" style="padding: 20px; display: block; margin-top: 10px;">' +
    '        Smoothly Animated Reactive Node 🎭' +
    '      </div>' +
    '    </transition>' +
    '  </div>' +
    '' +
    '  <!-- 6. List Transitions (Transition-Group FLIP) -->' +
    '  <div class="section">' +
    '    <h3>{{ $t(''pro.transitionTitle'') }}</h3>' +
    '    <p style="color: #64748b; margin-bottom: 12px;">' +
    '      The <strong>FLIP</strong> algorithm (<em>First, Last, Invert, Play</em>) computes coordinate diffs before and after list mutations and applies fluid hardware-accelerated CSS transforms.' +
    '    </p>' +
    '    <div style="margin-bottom: 14px;">' +
    '      <button class="btn-primary" @click="embaralhar">{{ $t(''pro.shuffle'') }}</button>' +
    '      <button class="btn-outline" @click="adicionarItem">{{ $t(''pro.add'') }}</button>' +
    '      <button class="btn-danger" @click="removerItem">{{ $t(''pro.remove'') }}</button>' +
    '      <button class="btn-outline" @click="resetarLista">{{ $t(''pro.resetList'') }}</button>' +
    '    </div>' +
    '' +
    '    <transition-group tag="div" name="list" class="flip-grid">' +
    '      <div b-for="item in itens" class="flip-card">' +
    '        {{ item }}' +
    '      </div>' +
    '    </transition-group>' +
    '  </div>' +
    '' +
    '  <!-- 7. WebAssembly Acceleration & Benchmarking -->' +
    '  <div class="section wasm-card">' +
    '    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; flex-wrap: wrap; gap: 8px;">' +
    '      <h3 style="color: #6366f1; margin: 0;">⚡ WebAssembly Acceleration ($wasm)</h3>' +
    '      <span class="badge" style="background: #6366f1;">Wasm Active 🚀</span>' +
    '    </div>' +
    '    <p style="color: #64748b; margin-bottom: 16px;">' +
    '      BlaiseVue integrates high-performance computing via <strong>native WebAssembly</strong> directly from Object Pascal through the injected <code>$wasm</code> bridge, achieving near-native execution speed.' +
    '    </p>' +
    '' +
    '    <div class="wasm-grid">' +
    '      <!-- Test 1: Fibonacci Wasm -->' +
    '      <div class="wasm-box">' +
    '        <h4 style="margin-bottom: 8px;">🔢 Accelerated Fibonacci Computation</h4>' +
    '        <p style="font-size: 13px;">Compute the N-th Fibonacci term via Wasm:</p>' +
    '        <div style="display: flex; gap: 8px; margin: 10px 0; align-items: center;">' +
    '          <input type="number" b-model="fibInput" style="width: 80px;" min="1" max="45" />' +
    '          <button class="btn-primary" @click="calcularWasmFib">Compute Wasm ⚡</button>' +
    '        </div>' +
    '        <div class="wasm-result">' +
    '          Result: <strong>{{ wasmFibResult }}</strong>' +
    '          <br />' +
    '          <small>Execution Time: <strong>{{ wasmFibTime }} ms</strong></small>' +
    '        </div>' +
    '      </div>' +
    '' +
    '      <!-- Test 2: Primality Test Wasm -->' +
    '      <div class="wasm-box">' +
    '        <h4 style="margin-bottom: 8px;">🛡️ Wasm Primality Benchmark</h4>' +
    '        <p style="font-size: 13px;">Verify large integer primality using compiled bytecode:</p>' +
    '        <div style="display: flex; gap: 8px; margin: 10px 0; align-items: center;">' +
    '          <input type="number" b-model="primeInput" style="width: 120px;" />' +
    '          <button class="btn-primary" style="background: #8e44ad; border-color: #8e44ad;" @click="testarPrimoWasm">Verify Prime 🔍</button>' +
    '        </div>' +
    '        <div class="wasm-result">' +
    '          Status: <strong>{{ primeResult }}</strong>' +
    '        </div>' +
    '      </div>' +
    '    </div>' +
    '' +
    '    <!-- Test 3: Real-Time Benchmark -->' +
    '    <div class="wasm-bench-container">' +
    '      <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">' +
    '        <div>' +
    '          <h4 style="margin: 0;" class="wasm-bench-title">📊 Real-Time Benchmark: WebAssembly vs JavaScript</h4>' +
    '          <p style="font-size: 13px; margin-top: 4px;">Executes 1,000 parallel iterations comparing Wasm bytecode to vanilla JavaScript.</p>' +
    '        </div>' +
    '        <button class="btn-primary" style="background: #6366f1; border-color: #6366f1;" @click="rodarBenchmark">Run Benchmark 🚀</button>' +
    '      </div>' +
    '' +
    '      <div style="display: flex; gap: 16px; margin-top: 14px; flex-wrap: wrap;">' +
    '        <div class="stat-badge">' +
    '          <div class="stat-label">Vanilla JavaScript</div>' +
    '          <div class="stat-val" style="color: #e67e22;">{{ benchJsTime }} ms</div>' +
    '        </div>' +
    '        <div class="stat-badge">' +
    '          <div class="stat-label">Native WebAssembly</div>' +
    '          <div class="stat-val" style="color: #10b981;">{{ benchWasmTime }} ms</div>' +
    '        </div>' +
    '        <div class="stat-badge">' +
    '          <div class="stat-label">Speedup Factor</div>' +
    '          <div class="stat-val" style="color: #6366f1;">{{ benchSpeedup }}</div>' +
    '        </div>' +
    '      </div>' +
    '      <p style="font-size: 12px; margin-top: 10px;">' +
    '        Benchmark Telemetry: <em>{{ benchSummary }}</em>' +
    '      </p>' +
    '    </div>' +
    '' +
    '    <!-- Test 4: SSG / Hydration Engine Demo -->' +
    '    <div class="ssg-info-box">' +
    '      <h4 style="margin: 0 0 6px 0;">🚀 SSG &amp; Client Rehydration Engine</h4>' +
    '      <p style="font-size: 13px; margin: 0;">' +
    '        Pre-rendered static HTML via <code>bv run ssg</code> is seamlessly rehydrated on the client preserving existing DOM hierarchy without re-rendering nodes from scratch.' +
    '      </p>' +
    '    </div>' +
    '  </div>' +
    '  </div>';

  comp['data'] := function(): TJSObject
  var d: TJSObject;
  begin
    d := TJSObject.new;
    d['contador'] := 0;
    d['showElement'] := True;
    d['itens'] := '';
    d['fibInput'] := 20;
    d['wasmFibResult'] := 6765;
    d['wasmFibTime'] := '0.04';
    d['primeInput'] := 999983;
    d['primeResult'] := '999983 is a PRIME NUMBER! 💎';
    d['benchIters'] := 1000;
    d['benchJsTime'] := '0.00';
    d['benchWasmTime'] := '0.00';
    d['benchSpeedup'] := 'Calculating...';
    d['benchSummary'] := 'Ready for execution';
    Result := d;
  end;


  m := TJSObject.new;
  m['testarSlot'] := procedure(_this: TJSObject)

    begin
      WriteLn('[Slot Test] Parent view slot active!');
    end;
    
  m['atualizarEstadoGlobal'] := procedure(_this: TJSObject)

    var
    currentUser, newUser: string;
    begin
      currentUser := string(TJSObject(_this['$store'])['user']);
      if currentUser = 'Pascal King 👑' then
      newUser := 'Blaise Visionary 🚀'
      else if currentUser = 'Blaise Visionary 🚀' then
      newUser := 'DevMaster 🏆'
      else
      newUser := 'Pascal King 👑';
      TJSObject(_this['$store'])['user'] := newUser;
      WriteLn('[Store] Central Store Updated! User: ' + newUser);
    end;
    
  m['incrementar'] := procedure(_this: TJSObject)

    begin
      TComponentThis(_this).contador += 1;
    end;
    
  m['toggleShow'] := procedure(_this: TJSObject)

    begin
      TComponentThis(_this).showElement := not TComponentThis(_this).showElement;
    end;
    
  m['embaralhar'] := procedure(_this: TJSObject)

    var
    Arr: TJSArray;
    i, j: Integer;
    Tmp: JSValue;
    begin
      Arr := TJSArray(_this['itens']);
      if Arr <> nil then
    begin
      for i := Arr.Length - 1 downto 1 do
    begin
      j := Random(i + 1);
      Tmp := Arr[i];
      Arr[i] := Arr[j];
      Arr[j] := Tmp;
    end;
    _this['itens'] := ObjectAssign(NewArray, Arr);
    end;
    end;
    
  m['adicionarItem'] := procedure(_this: TJSObject)

    var
    Emojis: array[0..7] of string = ('⚡ Lightning', '🔥 Fire', '🚀 Rocket', '💎 Diamond', '🔮 Crystal', '🌟 Star', '🛡️ Shield', '🎯 Target');
    Arr: TJSArray;
    begin
      Arr := TJSArray(_this['itens']);
      if Arr <> nil then
      Arr.push(Emojis[Random(8)] + ' #' + IntToStr(Arr.Length + 1));
    end;
    
  m['removerItem'] := procedure(_this: TJSObject)

    var
    Arr: TJSArray;
    begin
      Arr := TJSArray(_this['itens']);
      if (Arr <> nil) and (Arr.Length > 0) then
      Arr.shift;
    end;
    
  m['resetarLista'] := procedure(_this: TJSObject)

    begin
      _this['itens'] := NewArray;
      TJSArray(_this['itens']).push('⚡ Pascal');
      TJSArray(_this['itens']).push('🔥 BlaiseVue');
      TJSArray(_this['itens']).push('🚀 WebAssembly');
      TJSArray(_this['itens']).push('💎 HighPerf');
    end;
    
  m['calcularWasmFib'] := procedure(_this: TJSObject)

    var
    n, res: Integer;
    t0, t1: Double;
    begin
      n := StrToIntDef(String(_this['fibInput']), 1);
      t0 := NowTimestampMs;
      res := Integer(WasmCall(_this, 'math', 'fib', n));
      t1 := NowTimestampMs;
      TComponentThis(_this).wasmFibResult := res;
      TComponentThis(_this).wasmFibTime := FormatFloat('0.000', t1 - t0);
    end;
    
  m['testarPrimoWasm'] := procedure(_this: TJSObject)

    var
    n: Integer;
    isP: Integer;
    begin
      n := StrToIntDef(String(_this['primeInput']), 2);
      isP := Integer(WasmCall(_this, 'math', 'isPrime', n));
      if isP = 1 then
      TComponentThis(_this).primeResult := IntToStr(n) + ' is a PRIME NUMBER! 💎'
      else
      TComponentThis(_this).primeResult := IntToStr(n) + ' is NOT prime ❌';
    end;
    
  m['rodarBenchmark'] := procedure(_this: TJSObject)

    var
    n: Integer;
    rep: JSValue;
    begin
      n := StrToIntDef(String(_this['fibInput']), 20);
      rep := WasmBenchmark(_this, 'math', 'fib', n, 1000);
      if rep <> nil then
    begin
      TComponentThis(_this).benchJsTime := GetFieldStr(rep, 'jsDurationMs');
      TComponentThis(_this).benchWasmTime := GetFieldStr(rep, 'wasmDurationMs');
      TComponentThis(_this).benchSpeedup := GetFieldStr(rep, 'speedup') + ' Faster! 🚀';
      TComponentThis(_this).benchSummary := '1,000 iterations completed successfully in math module.';
    end;
    end;

  comp['methods'] := m;

  comp['created'] := procedure(_this: TJSObject)
    var
    rep: JSValue;
    begin
      asm if (!_this) _this = this; end;

      _this['itens'] := NewArray;
      TJSArray(_this['itens']).push('⚡ Pascal');
      TJSArray(_this['itens']).push('🔥 BlaiseVue');
      TJSArray(_this['itens']).push('🚀 WebAssembly');
      TJSArray(_this['itens']).push('💎 HighPerf');
      rep := WasmBenchmark(_this, 'math', 'fib', 20, 1000);
      if rep <> nil then
    begin
      TComponentThis(_this).benchJsTime := GetFieldStr(rep, 'jsDurationMs');
      TComponentThis(_this).benchWasmTime := GetFieldStr(rep, 'wasmDurationMs');
      TComponentThis(_this).benchSpeedup := GetFieldStr(rep, 'speedup') + ' Faster! 🚀';
      TComponentThis(_this).benchSummary := 'WebAssembly math module operational.';
    end;
    end;

    ;
  comp['updated'] := procedure(_this: TJSObject)
    begin
      asm if (!_this) _this = this; end;

      WriteLn('[Lifecycle] Component UPDATED! Pulse detected.');
    end;

    ;
  comp['inject'] := TJSArray.new;
  TJSArray(comp['inject']).push('getAmbiente');
  RegisterComponent('pro-features-page', comp);
end;

end.
