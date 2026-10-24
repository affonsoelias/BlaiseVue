program home_view_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, uCard, uInfoCard, uBVThemeToggle, uBVThemeSelect, uBVIcon, uHome;

var
  Wrapper: TWrapper;

begin
  Register_uCard;
  Register_uInfoCard;
  Register_uBVThemeToggle;
  Register_uBVThemeSelect;
  Register_uBVIcon;
  Register_uHome;

  Describe('View: Home', procedure
    begin
       It('deve inicializar a view Home com todos os componentes registrados', procedure
         begin
            Wrapper := Mount('home-page');
            Expect(Wrapper.Element <> nil).ToBe(True);
            Expect(Wrapper.Find('h2').textContent).ToContain('Home: Control Panel');
            Expect(Wrapper.Find('.alert-box')).toBeDefined;
         end);

       It('deve alternar a visibilidade da caixa de alerta ao clicar no botao', procedure
         begin
            Wrapper := Mount('home-page');
            // Inicialmente isVisible = true
            Expect(Wrapper.Find('.alert-box').style.getPropertyValue('display')).NotToContain('none');
            // Clica em Toggle Visibility (primeiro botao do painel)
            TJSHTMLElement(Wrapper.Find('button')).click;
            // Agora deve disparar a saida
            Expect(Wrapper.Find('.alert-box').className).ToContain('fade-leave-active');
         end);
    end);
end.
