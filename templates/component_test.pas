program {{TEST_NAME}}_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, u{{COMP_NAME}};

var
  Wrapper: TWrapper;

begin
  Register_u{{COMP_NAME}};

  Describe('Component: {{COMP_NAME}}', procedure
    begin
       It('deve montar o componente no DOM sem erros', procedure
         begin
            Wrapper := Mount('{{COMP_TAG}}');
            Expect(Wrapper.Element <> nil).ToBe(True);
         end);
    end);
end.
