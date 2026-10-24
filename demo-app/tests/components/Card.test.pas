program card_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, uCard;

var
  Wrapper: TWrapper;

begin
  Register_uCard;

  Describe('Component: Card', procedure
    begin
       It('deve montar o componente no DOM e renderizar estrutura padrao', procedure
         begin
            Wrapper := Mount('card');
            Expect(Wrapper.Element <> nil).ToBe(True);
            Expect(Wrapper.Find('.bv-card')).toBeDefined;
            Expect(Wrapper.Find('.bv-card-header')).toBeDefined;
            Expect(Wrapper.Find('.bv-card-body')).toBeDefined;
            Expect(Wrapper.Find('.bv-card-footer')).toBeDefined;
            Expect(Wrapper.Find('.bv-card-header').textContent).ToContain('Card');
         end);
    end);
end.
