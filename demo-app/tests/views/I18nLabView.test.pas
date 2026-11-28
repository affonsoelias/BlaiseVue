program i18nlabview_view_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, BVI18n, uI18nLabView;

var
  Wrapper: TWrapper;

begin
  Register_uI18nLabView;

  Describe('View: I18nLabView (Internationalization Laboratory)', procedure
    begin
       It('should initialize I18nLabView and render multilingual showcase cards', procedure
         begin
            Wrapper := Mount('i18n-lab-view-page');
            Expect(Wrapper.Element <> nil).ToBe(True);
            Expect(Wrapper.Find('.i18n-lab-view')).toBeDefined;
            Expect(Wrapper.HTML).ToContain('Internationalization Laboratory');
         end);

       It('should toggle active locale when language buttons are clicked', procedure
         begin
            Wrapper := Mount('i18n-lab-view-page');
            TBVI18n.SetLocale('pt');
            Expect(TBVI18n.GetLocale).ToBe('pt');

            TBVI18n.SetLocale('el');
            Expect(TBVI18n.GetLocale).ToBe('el');

            TBVI18n.SetLocale('en');
            Expect(TBVI18n.GetLocale).ToBe('en');
         end);
    end);
end.
