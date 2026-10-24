program theme_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, BVReactivity, BVCompiler, BVTheme;

begin
  Describe('BlaiseVue 2.6 Integrated Theme Manager (Blaise-Themes)', procedure
    begin
       It('deve inicializar com o tema padrao flatly', procedure
         begin
            TBVTheme.Init('flatly');
            Expect(TBVTheme.GetTheme).ToBe('flatly');
            Expect(TBVTheme.IsDark).ToBe(False);
         end);

       It('deve alternar para tema escuro e atualizar isDark', procedure
         begin
            TBVTheme.SetTheme('darkly');
            Expect(TBVTheme.GetTheme).ToBe('darkly');
            Expect(TBVTheme.IsDark).ToBe(True);

            TBVTheme.SetTheme('cyborg');
            Expect(TBVTheme.GetTheme).ToBe('cyborg');
            Expect(TBVTheme.IsDark).ToBe(True);
         end);

       It('deve alternar para tema claro e atualizar isDark', procedure
         begin
            TBVTheme.SetTheme('cosmo');
            Expect(TBVTheme.GetTheme).ToBe('cosmo');
            Expect(TBVTheme.IsDark).ToBe(False);

            TBVTheme.SetTheme('lux');
            Expect(TBVTheme.GetTheme).ToBe('lux');
            Expect(TBVTheme.IsDark).ToBe(False);
         end);

       It('deve executar ToggleDarkLight corretamente', procedure
         begin
            TBVTheme.SetTheme('flatly');
            Expect(TBVTheme.IsDark).ToBe(False);

            TBVTheme.ToggleDarkLight;
            Expect(TBVTheme.GetTheme).ToBe('darkly');
            Expect(TBVTheme.IsDark).ToBe(True);

            TBVTheme.ToggleDarkLight;
            Expect(TBVTheme.GetTheme).ToBe('flatly');
            Expect(TBVTheme.IsDark).ToBe(False);
         end);

       It('deve atualizar o elemento link no DOM e atributo data-bs-theme', procedure
         var
           LinkHref: string;
           BsTheme: string;
         begin
            TBVTheme.SetTheme('solar');
            asm
              let l = document.getElementById('bv-theme');
              LinkHref = l ? l.getAttribute('href') : '';
              BsTheme = document.documentElement ? document.documentElement.getAttribute('data-bs-theme') : '';
            end;
            Expect(LinkHref).ToBe('lib/themes/solar.min.css');
            Expect(BsTheme).ToBe('dark');
         end);

       It('deve injetar $theme reativo no compilador de componentes', procedure
         var
           Container: TJSHTMLElement;
           Data: TBlaiseData;
           ResHtml: string;
         begin
            Container := TJSHTMLElement(document.createElement('div'));
            Container.innerHTML := '<span id="theme-display">{{ $theme.current }}</span>';

            Data := TBlaiseData.Create;
            Compile(Container, Data, nil);

            asm
              ResHtml = Container.innerHTML;
            end;

            Expect(ResHtml).ToContain('solar');
         end);
    end);
end.
