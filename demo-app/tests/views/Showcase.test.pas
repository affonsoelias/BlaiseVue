program showcase_view_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, uBVIcon, uShowcase;

var
  Wrapper: TWrapper;

begin
  Register_uBVIcon;
  Register_uShowcase;

  Describe('View: Showcase', procedure
    begin
       It('deve inicializar a view de Showcase com a galeria de icones', procedure
         begin
            Wrapper := Mount('showcase-page');
            Expect(Wrapper.Element <> nil).ToBe(True);
            Expect(Wrapper.Find('.showcase-header h1').textContent).ToContain('Showcase');
            Expect(Wrapper.Find('.icon-grid')).toBeDefined;
         end);

       It('deve alternar o tema selecionado ao clicar no seletor de temas', procedure
         begin
            Wrapper := Mount('showcase-page');
            // Clica no botao Darkly
            TJSHTMLElement(Wrapper.Find('.theme-buttons button.btn-primary')).click;
            Expect(Wrapper.Find('.badge.bg-secondary').textContent).toBe('darkly');
         end);
    end);
end.
