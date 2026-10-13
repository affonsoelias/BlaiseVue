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
            Expect(Wrapper.Text).ToContain('Contador');
            Expect(Wrapper.Find('.counter-value').textContent).ToBe('0');
         end);
         
       It('deve incrementar o valor ao clicar no botao', procedure
         begin
            Wrapper := Mount('counter');
            // Clica no botao de incrementar (+) que e o segundo botao
            Wrapper.Find('.counter-controls button:last-child').click();
            Expect(Wrapper.Find('.counter-value').textContent).ToBe('1');
         end);
    end);
end.
