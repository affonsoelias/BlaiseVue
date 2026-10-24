program mobileview_view_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, uBVIonApp, uBVIonHeader, uBVIonToolbar, uBVIonTitle, uBVIonBadge, uBVIonContent, uBVIonCard, uBVIonButton, uBVIonList, uBVIonItem, uBVIonTabs, uBVIonTabBar, uBVIonTabButton, uMobileView;

var
  Wrapper: TWrapper;

begin
  Register_uBVIonApp;
  Register_uBVIonHeader;
  Register_uBVIonToolbar;
  Register_uBVIonTitle;
  Register_uBVIonBadge;
  Register_uBVIonContent;
  Register_uBVIonCard;
  Register_uBVIonButton;
  Register_uBVIonList;
  Register_uBVIonItem;
  Register_uBVIonTabs;
  Register_uBVIonTabBar;
  Register_uBVIonTabButton;
  Register_uMobileView;

  Describe('View: MobileView', procedure
    begin
       It('deve inicializar a view Mobile com ecossistema universal Ionic', procedure
         begin
            Wrapper := Mount('mobile-view-page');
            Expect(Wrapper.Element <> nil).ToBe(True);
            Expect(Wrapper.Find('.mobile-view-container')).toBeDefined;
         end);
    end);
end.
