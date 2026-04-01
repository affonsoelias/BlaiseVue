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
    end);
end.
