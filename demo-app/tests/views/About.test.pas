program about_view_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, uAbout;

var
  Wrapper: TWrapper;

begin
  Register_uAbout;

  Describe('View: About', procedure
    begin
       It('deve inicializar a pagina About com arsenal tecnologico visivel', procedure
         begin
            Wrapper := Mount('about-page');
            Expect(Wrapper.Element <> nil).ToBe(True);
            Expect(Wrapper.Find('.section-title').textContent).ToContain('About BlaiseVue');
            Expect(Wrapper.Find('.resource-grid')).toBeDefined;
         end);

       It('deve alternar a exibicao do laboratorio ao clicar no botao', procedure
         begin
            Wrapper := Mount('about-page');
            // Inicialmente o lab nao esta no DOM
            Expect(Wrapper.Find('.lab-container') = nil).ToBe(True);
            // Clica em abrir laboratorio
            TJSHTMLElement(Wrapper.Find('.action-bar button.btn-primary')).click;
            Expect(Wrapper.Find('.lab-container')).toBeDefined;
         end);
    end);
end.
