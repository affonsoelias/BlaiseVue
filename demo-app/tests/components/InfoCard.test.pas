program infocard_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, uInfoCard;

var
  Wrapper: TWrapper;

begin
  Register_uInfoCard;

  Describe('Component: InfoCard', procedure
    begin
       It('deve montar o componente no DOM com titulo e texto padrao', procedure
         begin
            Wrapper := Mount('info-card');
            Expect(Wrapper.Element <> nil).ToBe(True);
            Expect(Wrapper.Find('.info-card')).toBeDefined;
            Expect(Wrapper.Find('.info-icon')).toBeDefined;
            Expect(Wrapper.Find('.info-icon').textContent).ToContain('i');
            Expect(Wrapper.Find('.info-body strong').textContent).ToContain('Informacao');
            Expect(Wrapper.Find('.info-body p').textContent).ToContain('reutilizavel');
         end);
    end);
end.
