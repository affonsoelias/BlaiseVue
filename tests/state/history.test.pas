program history_test;

{$mode objfpc}

uses JS, Web, SysUtils, BVStore, BVStoreHistory, BVTestUtils;

var
  CounterSlice, CanvasSlice: TBVStoreSlice;
  CounterState, CanvasState: TJSObject;
  ExportedLog: string;
  ImportSuccess: Boolean;

begin
  Describe('BVStoreHistory - Time-Travel & State Snapshots (BlaiseX Pillar 1 Step 4)', procedure
    begin
      It('deve registrar snapshot inicial @@INIT e gerenciar CanUndo / CanRedo', procedure
        begin
          CounterState := TJSObject.new;
          CounterState['count'] := 0;
          CounterSlice := DefineStore('counter_hist', CounterState);

          Expect(CounterSlice.History.Count).ToBe(1);
          Expect(CounterSlice.CanUndo).ToBe(False);
          Expect(CounterSlice.CanRedo).ToBe(False);
        end);

      It('deve registrar snapshots a cada mutacao permitindo operacoes de Undo e Redo', procedure
        begin
          CounterState := TJSObject.new;
          CounterState['count'] := 0;
          CounterSlice := DefineStore('counter_undo', CounterState);

          CounterSlice.Mutation('inc', procedure(AState, APayload: JSValue)
            begin
              TJSObject(AState)['count'] := Integer(TJSObject(AState)['count']) + 1;
            end);

          CounterSlice.Commit('inc'); // count = 1
          CounterSlice.Commit('inc'); // count = 2
          CounterSlice.Commit('inc'); // count = 3

          Expect(Integer(TJSObject(CounterSlice.State)['count'])).ToBe(3);
          Expect(CounterSlice.History.Count).ToBe(4); // @@INIT + 3 mutacoes
          Expect(CounterSlice.CanUndo).ToBe(True);
          Expect(CounterSlice.CanRedo).ToBe(False);

          // 1º Undo -> volta para count = 2
          Expect(CounterSlice.Undo).ToBe(True);
          Expect(Integer(TJSObject(CounterSlice.State)['count'])).ToBe(2);
          Expect(CounterSlice.CanRedo).ToBe(True);

          // 2º Undo -> volta para count = 1
          Expect(CounterSlice.Undo).ToBe(True);
          Expect(Integer(TJSObject(CounterSlice.State)['count'])).ToBe(1);

          // 3º Undo -> volta para count = 0 (@@INIT)
          Expect(CounterSlice.Undo).ToBe(True);
          Expect(Integer(TJSObject(CounterSlice.State)['count'])).ToBe(0);
          Expect(CounterSlice.CanUndo).ToBe(False);

          // 1º Redo -> avanca para count = 1
          Expect(CounterSlice.Redo).ToBe(True);
          Expect(Integer(TJSObject(CounterSlice.State)['count'])).ToBe(1);

          // 2º Redo -> avanca para count = 2
          Expect(CounterSlice.Redo).ToBe(True);
          Expect(Integer(TJSObject(CounterSlice.State)['count'])).ToBe(2);
        end);

      It('deve podar historico futuro ao comitar nova mutacao apos Undo (Branching Timeline)', procedure
        begin
          CounterState := TJSObject.new;
          CounterState['count'] := 0;
          CounterSlice := DefineStore('counter_branch', CounterState);

          CounterSlice.Mutation('inc', procedure(AState, APayload: JSValue)
            begin
              TJSObject(AState)['count'] := Integer(TJSObject(AState)['count']) + 1;
            end);

          CounterSlice.Mutation('setVal', procedure(AState, APayload: JSValue)
            begin
              TJSObject(AState)['count'] := Integer(APayload);
            end);

          CounterSlice.Commit('inc'); // 1
          CounterSlice.Commit('inc'); // 2
          CounterSlice.Commit('inc'); // 3

          // Volta 2 passos (para count = 1)
          CounterSlice.Undo; // 2
          CounterSlice.Undo; // 1
          Expect(Integer(TJSObject(CounterSlice.State)['count'])).ToBe(1);
          Expect(CounterSlice.CanRedo).ToBe(True);

          // Comita novo valor no passado -> cria nova linha do tempo
          CounterSlice.Commit('setVal', 100);

          Expect(Integer(TJSObject(CounterSlice.State)['count'])).ToBe(100);
          // O Redo anterior nao deve mais existir
          Expect(CounterSlice.CanRedo).ToBe(False);
        end);

      It('deve permitir salto temporal direto para qualquer snapshot via TimeTravel', procedure
        begin
          CanvasState := TJSObject.new;
          CanvasState['tool'] := 'pen';
          CanvasSlice := DefineStore('canvas_tt', CanvasState);

          CanvasSlice.Mutation('selectTool', procedure(AState, APayload: JSValue)
            begin
              TJSObject(AState)['tool'] := string(APayload);
            end);

          CanvasSlice.Commit('selectTool', 'brush');  // Index 1
          CanvasSlice.Commit('selectTool', 'eraser'); // Index 2
          CanvasSlice.Commit('selectTool', 'bucket'); // Index 3

          Expect(string(TJSObject(CanvasSlice.State)['tool'])).ToBe('bucket');

          // Salta direto para o primeiro snapshot inicial (Index 0: 'pen')
          Expect(CanvasSlice.TimeTravel(0)).ToBe(True);
          Expect(string(TJSObject(CanvasSlice.State)['tool'])).ToBe('pen');

          // Salta direto para o Index 2 ('eraser')
          Expect(CanvasSlice.TimeTravel(2)).ToBe(True);
          Expect(string(TJSObject(CanvasSlice.State)['tool'])).ToBe('eraser');
        end);

      It('deve respeitar capacidade maxima de snapshots descartando os mais antigos', procedure
        var
          SmallSlice: TBVStoreSlice;
          SmallState: TJSObject;
          i: Integer;
        begin
          SmallState := TJSObject.new;
          SmallState['step'] := 0;
          SmallSlice := DefineStore('small_hist', SmallState);

          SmallSlice.EnableHistory(3); // Capacidade de apenas 3 snapshots

          SmallSlice.Mutation('step', procedure(AState, APayload: JSValue)
            begin
              TJSObject(AState)['step'] := Integer(TJSObject(AState)['step']) + 1;
            end);

          for i := 1 to 6 do
            SmallSlice.Commit('step');

          // O total de snapshots nao pode ultrapassar o limite configurado
          Expect(SmallSlice.History.Count <= 3).ToBe(True);
          Expect(Integer(TJSObject(SmallSlice.State)['step'])).ToBe(6);
        end);

      It('deve exportar e importar historico completo em formato JSON', procedure
        var
          ExportSlice, ImportSlice: TBVStoreSlice;
          ExpState, ImpState: TJSObject;
        begin
          ExpState := TJSObject.new;
          ExpState['title'] := 'v1';
          ExportSlice := DefineStore('exp_slice', ExpState);

          ExportSlice.Mutation('setTitle', procedure(AState, APayload: JSValue)
            begin
              TJSObject(AState)['title'] := string(APayload);
            end);

          ExportSlice.Commit('setTitle', 'v2');
          ExportSlice.Commit('setTitle', 'v3');

          ExportedLog := ExportSlice.History.ExportJSON;
          Expect(ExportedLog <> '').ToBe(True);

          // Importa o log em outro slice
          ImpState := TJSObject.new;
          ImpState['title'] := 'v0';
          ImportSlice := DefineStore('imp_slice', ImpState);

          ImportSuccess := ImportSlice.History.ImportJSON(ExportedLog);
          Expect(ImportSuccess).ToBe(True);
          Expect(ImportSlice.History.Count).ToBe(3);
          Expect(string(TJSObject(ImportSlice.State)['title'])).ToBe('v3');

          // Replay de Undo no slice importado
          ImportSlice.Undo;
          Expect(string(TJSObject(ImportSlice.State)['title'])).ToBe('v2');
        end);

      It('deve expor bridge no window.__BLAISEX_DEVTOOLS__ para painel de ferramentas', procedure
        var
          DevToolsObj: TJSObject;
          HasDevTools: Boolean;
        begin
          HasDevTools := False;
          asm
            if (typeof window !== 'undefined' && window.__BLAISEX_DEVTOOLS__) {
              HasDevTools = typeof window.__BLAISEX_DEVTOOLS__.undo === 'function' &&
                            typeof window.__BLAISEX_DEVTOOLS__.redo === 'function' &&
                            typeof window.__BLAISEX_DEVTOOLS__.timeTravel === 'function';
            }
          end;
          Expect(HasDevTools).ToBe(True);
        end);

    end);
end.
