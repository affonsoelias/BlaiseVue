program loginview_view_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, uLoginView;

var
  Wrapper: TWrapper;

begin
  Register_uLoginView;

  Describe('View: LoginView', procedure
    begin
       It('deve inicializar a view e renderizar o formulario de login', procedure
         begin
            Wrapper := Mount('login-view-page');
            Expect(Wrapper.Element <> nil).ToBe(True);
            Expect(Wrapper.Find('.login-title').textContent).ToContain('Autentica');
            Expect(Wrapper.Find('input[type="email"]')).toBeDefined;
            Expect(Wrapper.Find('input[type="password"]')).toBeDefined;
         end);

       It('deve exibir mensagem de erro ao submeter com campos vazios', procedure
         begin
            Wrapper := Mount('login-view-page');
            TJSHTMLElement(Wrapper.Find('.login-form button.btn-block')).click;
            Expect(Wrapper.Find('.auth-error-banner')).toBeDefined;
            Expect(Wrapper.Find('.auth-error-banner').textContent).ToContain('informe o e-mail');
         end);

       It('deve preencher credenciais ao clicar no acesso rapido de admin', procedure
         begin
            Wrapper := Mount('login-view-page');
            TJSHTMLElement(Wrapper.Find('.demo-admin')).click;
            Expect(TJSHTMLInputElement(Wrapper.Find('input[type="email"]')).value).toBe('admin@blaisevue.dev');
            Expect(TJSHTMLInputElement(Wrapper.Find('input[type="password"]')).value).toBe('admin123');
         end);
    end);
end.
