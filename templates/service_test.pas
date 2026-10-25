program {{TEST_NAME}}_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, u{{SERVICE_NAME}};

var
  Service: T{{SERVICE_NAME}};

begin
  Describe('Unit: {{SERVICE_NAME}} (Domain Service)', procedure
    begin
       It('deve instanciar o servico e executar com sucesso', procedure
         begin
            Service := T{{SERVICE_NAME}}.Create;
            try
              Expect(Service.Execute('teste')).ToBe('Processed: teste');
            finally
              Service.Free;
            end;
         end);

       It('deve executar a funcao helper com sucesso', procedure
         begin
            Expect({{SERVICE_NAME}}Helper(10)).ToBe(20);
         end);
    end);
end.
