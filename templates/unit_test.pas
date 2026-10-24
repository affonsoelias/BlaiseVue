program {{TEST_NAME}}_test;

{$mode objfpc}

uses JS, Web, BVTestUtils;

var
  Wrapper: TWrapper;

begin
  Describe('Unit: {{TEST_NAME}}', procedure
    begin
       It('deve executar o teste com sucesso', procedure
         begin
            Expect(True).ToBe(True);
         end);
    end);
end.
