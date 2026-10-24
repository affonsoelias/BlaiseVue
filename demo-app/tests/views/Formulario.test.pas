program formulario_view_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, uFormHeader, uFormulario;

var
  Wrapper: TWrapper;

begin
  Register_uFormHeader;
  Register_uFormulario;

  Describe('View: Formulario', procedure
    begin
       It('deve inicializar a view de formulario com o form-header integrado', procedure
         begin
            Wrapper := Mount('formulario-page');
            Expect(Wrapper.Element <> nil).ToBe(True);
            Expect(Wrapper.Find('.form-header')).toBeDefined;
            Expect(Wrapper.Find('input[placeholder*="nome"]')).toBeDefined;
         end);

       It('deve preencher e limpar dados atraves dos botoes de acao', procedure
         begin
            Wrapper := Mount('formulario-page');
            // Clica no botao Preencher (segundo botao da barra)
            TJSHTMLElement(Wrapper.Find('.section:nth-of-type(2) button.btn-outline')).click;
            Expect(TJSHTMLInputElement(Wrapper.Find('input[placeholder*="nome"]')).value).toBe('Blaise Pascal');
            Expect(TJSHTMLInputElement(Wrapper.Find('input[placeholder*="usuario@dominio.com"]')).value).toBe('blaise@pascal.dev');

            // Clica no botao Limpar
            TJSHTMLElement(Wrapper.Find('.section:nth-of-type(2) button.btn-danger')).click;
            Expect(TJSHTMLInputElement(Wrapper.Find('input[placeholder*="nome"]')).value).toBe('');
         end);
    end);
end.
