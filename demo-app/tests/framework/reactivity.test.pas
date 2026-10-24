program reactivity_test;

{$mode objfpc}

uses JS, Web, BVReactivity, BVTestUtils;

var
  Data, Proxy: TJSObject;
  Counter: Integer;

begin
  Describe('BVReactivity', procedure
    begin
       It('deve tornar um objeto reativo', procedure
         begin
            Data := TJSObject.new;
            Data['count'] := 0;
            Proxy := TJSObject(DefineReactive(Data));
            
            Expect(Proxy['count']).ToBe(0);
         end);
         
       It('deve disparar efeitos quando o dado muda', procedure
         begin
            Data := TJSObject.new;
            Data['count'] := 0;
            Proxy := TJSObject(DefineReactive(Data));
            Counter := 0;
            
            Effect(procedure
              begin
                 Counter := Integer(Proxy['count']);
              end);
            
            Proxy['count'] := 10;
            Expect(Counter).ToBe(10);
         end);

       It('deve suportar padrao watcher reagindo a mutacoes subsequentes', procedure
         var
           WatchCallCount: Integer;
           WatchedVal: JSValue;
           FirstRun: Boolean;
         begin
            Data := TJSObject.new;
            Data['searchTerm'] := 'delphi';
            Proxy := TJSObject(DefineReactive(Data));
            WatchCallCount := 0;
            FirstRun := True;
            WatchedVal := '';
            
            Effect(procedure
              var
                Val: JSValue;
              begin
                 Val := Proxy['searchTerm'];
                 if FirstRun then
                 begin
                   FirstRun := False;
                   Exit;
                 end;
                 Inc(WatchCallCount);
                 WatchedVal := Val;
              end);
            
            // Montagem inicial nao dispara efeito colateral do watcher
            Expect(WatchCallCount).ToBe(0);
            
            // Primeira mutacao dispara o watcher
            Proxy['searchTerm'] := 'blaisevue';
            Expect(WatchCallCount).ToBe(1);
            Expect(WatchedVal).ToBe('blaisevue');
            
            // Segunda mutacao dispara novamente
            Proxy['searchTerm'] := 'pascal';
            Expect(WatchCallCount).ToBe(2);
            Expect(WatchedVal).ToBe('pascal');
         end);
    end);
end.
