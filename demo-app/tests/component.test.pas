program component_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, uCounter;

var
  Wrapper: TWrapper;

begin
  Register_uCounter;

  Describe('Counter Component', procedure
    begin
       It('deve renderizar o valor inicial', procedure
         begin
            Wrapper := Mount('counter');
            Expect(Wrapper.Text).ToContain('Count: 0');
         end);
         
       It('deve incrementar o valor ao clicar no botao', procedure
         begin
            Wrapper := Mount('counter');
            Wrapper.Find('button').click();
            Expect(Wrapper.Text).ToContain('Count: 1');
         end);
    end);
end.
