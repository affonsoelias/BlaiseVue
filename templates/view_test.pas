program {{TEST_NAME}}_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, u{{VIEW_NAME}};

var
  Wrapper: TWrapper;

begin
  Register_u{{VIEW_NAME}};

  Describe('View: {{VIEW_NAME}}', procedure
    begin
       It('deve inicializar a view e renderizar sem erros', procedure
         begin
            Wrapper := Mount('{{VIEW_TAG}}');
            Expect(Wrapper.Element <> nil).ToBe(True);
         end);
    end);
end.
