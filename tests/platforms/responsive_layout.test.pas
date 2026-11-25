program responsive_layout_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, BVComponents, uBVContainer, uBVRow, uBVCol, uBVDrawer, uBVBottomNav, uBVBottomNavItem;

var
  Wrapper: TWrapper;
  ContProps, RowProps, ColProps, DrawerProps, NavItemProps: TJSObject;

begin
  Register_uBVContainer;
  Register_uBVRow;
  Register_uBVCol;
  Register_uBVDrawer;
  Register_uBVBottomNav;
  Register_uBVBottomNavItem;

  Describe('BlaiseUI Responsive Layout System', procedure
    begin
       It('deve renderizar bv-container com classe padrao bui-container', procedure
         begin
            Wrapper := Mount('bv-container');
            Expect(Wrapper.Find('div')).toBeDefined;
            Expect(Wrapper.Find('div').className).ToContain('bui-container');
         end);

       It('deve renderizar bv-container fluido com bui-container-fluid', procedure
         begin
            ContProps := TJSObject.new;
            ContProps['fluid'] := true;
            Wrapper := Mount('bv-container', ContProps);
            Expect(Wrapper.Find('div').className).ToContain('bui-container-fluid');
         end);

       It('deve renderizar bv-row com classes de grid e gutter', procedure
         begin
            RowProps := TJSObject.new;
            RowProps['gutter'] := 'lg';
            RowProps['align'] := 'center';
            RowProps['justify'] := 'between';
            Wrapper := Mount('bv-row', RowProps);
            Expect(Wrapper.Find('div')).toBeDefined;
            Expect(Wrapper.Find('div').className).ToContain('bui-row');
            Expect(Wrapper.Find('div').className).ToContain('bui-gutter-lg');
            Expect(Wrapper.Find('div').className).ToContain('bui-align-center');
            Expect(Wrapper.Find('div').className).ToContain('bui-justify-between');
         end);

       It('deve renderizar bv-col com classes responsivas mobile-first e breakpoints', procedure
         begin
            ColProps := TJSObject.new;
            ColProps['cols'] := '12';
            ColProps['md'] := '6';
            ColProps['lg'] := '4';
            Wrapper := Mount('bv-col', ColProps);
            Expect(Wrapper.Find('div')).toBeDefined;
            Expect(Wrapper.Find('div').className).ToContain('bui-col-12');
            Expect(Wrapper.Find('div').className).ToContain('bui-col-md-6');
            Expect(Wrapper.Find('div').className).ToContain('bui-col-lg-4');
         end);

       It('deve instanciar bv-drawer com classes de posicionamento e estrutura', procedure
         begin
            DrawerProps := TJSObject.new;
            DrawerProps['title'] := 'Painel Lateral';
            DrawerProps['position'] := 'left';
            DrawerProps['show'] := true;
            Wrapper := Mount('bv-drawer', DrawerProps);
            Expect(Wrapper.Find('.bui-drawer')).toBeDefined;
            Expect(Wrapper.Find('.bui-drawer').className).ToContain('bui-drawer-left');
            Expect(Wrapper.Find('.bui-drawer-title').textContent).ToContain('Painel Lateral');
            Expect(Wrapper.Find('.bui-drawer-backdrop')).toBeDefined;
         end);

       It('deve renderizar bv-bottom-nav e bv-bottom-nav-item', procedure
         begin
            Wrapper := Mount('bv-bottom-nav');
            Expect(Wrapper.Find('nav')).toBeDefined;
            Expect(Wrapper.Find('nav').className).ToContain('bui-bottom-nav');

            NavItemProps := TJSObject.new;
            NavItemProps['label'] := 'Home';
            NavItemProps['icon'] := '🏠';
            NavItemProps['active'] := true;
            Wrapper := Mount('bv-bottom-nav-item', NavItemProps);
            Expect(Wrapper.Find('a')).toBeDefined;
            Expect(Wrapper.Find('a').className).ToContain('bui-bottom-nav-item');
            Expect(Wrapper.Find('a').className).ToContain('active');
            Expect(Wrapper.Find('.bui-bottom-nav-label').textContent).ToContain('Home');
            Expect(Wrapper.Find('.bui-bottom-nav-icon').textContent).ToContain('🏠');
         end);
    end);
end.
