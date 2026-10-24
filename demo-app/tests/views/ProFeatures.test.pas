program profeatures_view_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, uCard, uProFeatures;

var
  Wrapper: TWrapper;

begin
  Register_uCard;
  Register_uProFeatures;

  Describe('View: ProFeatures', procedure
    begin
       It('deve inicializar a view ProFeatures e renderizar secoes avancadas', procedure
         begin
            Wrapper := Mount('pro-features-page');
            Expect(Wrapper.Element <> nil).ToBe(True);
            Expect(Wrapper.Find('.pro-features')).toBeDefined;
            Expect(Wrapper.Find('.wasm-card')).toBeDefined;
         end);

       It('deve alternar a visibilidade do elemento na secao de transicoes', procedure
         begin
            Wrapper := Mount('pro-features-page');
            // Clica em alternar elemento (5th div)
            TJSHTMLElement(Wrapper.Find('.section:nth-of-type(5) button')).click;
            Expect(Wrapper.Find('.badge-orange').className).ToContain('fade-leave-active');
         end);
    end);
end.
