program libbootstrap_view_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, uBVNavbar, uBVNavItem, uBVContainer, uBVRow, uBVCol, uBVBreadcrumb, uBVBreadcrumbItem, uBVBtn, uBVCard, uBVProgress, uBVAlert, uBVBadge, uBVModal, uBVDrawer, uBVToast, uLibBootstrap;

var
  Wrapper: TWrapper;

begin
  Register_uBVNavbar;
  Register_uBVNavItem;
  Register_uBVContainer;
  Register_uBVRow;
  Register_uBVCol;
  Register_uBVBreadcrumb;
  Register_uBVBreadcrumbItem;
  Register_uBVBtn;
  Register_uBVCard;
  Register_uBVProgress;
  Register_uBVAlert;
  Register_uBVBadge;
  Register_uBVModal;
  Register_uBVDrawer;
  Register_uBVToast;
  Register_uLibBootstrap;

  Describe('View: LibBootstrap', procedure
    begin
       It('deve inicializar a view LibBootstrap com o kit oficial BlaiseUI', procedure
         begin
            Wrapper := Mount('lib-bootstrap-page');
            Expect(Wrapper.Element <> nil).ToBe(True);
            Expect(Wrapper.Find('.lib-bootstrap-page')).toBeDefined;
            Expect(Wrapper.Find('.bui-navbar')).toBeDefined;
            Expect(Wrapper.Find('.bui-breadcrumb')).toBeDefined;
         end);
    end);
end.
