program scoped_slots_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, BVComponents, BVCompiler, BVReactivity;

var
  Wrapper: TWrapper;
  ChildComp: TJSObject;
  ParentComp: TJSObject;

procedure SetupScopedComponents;
begin
  // Componente filho que expoe scoped slot
  ChildComp := TJSObject.new;
  ChildComp['template'] :=
    '<div class="child-box">' +
    '  <slot name="item" :val="currentVal" :msg="greeting">Default Slot Content</slot>' +
    '</div>';
  ChildComp['data'] := function(): TJSObject
  var d: TJSObject;
  begin
    d := TJSObject.new;
    d['currentVal'] := 42;
    d['greeting'] := 'Hello from child';
    Result := d;
  end;
  RegisterComponent('slot-child', ChildComp);

  // Componente pai que consome o scoped slot via #item="slotProps"
  ParentComp := TJSObject.new;
  ParentComp['template'] :=
    '<div class="parent-box">' +
    '  <slot-child>' +
    '    <template #item="slotProps">' +
    '      <span class="custom-render">{{ slotProps.msg }} - Val: {{ slotProps.val }}</span>' +
    '    </template>' +
    '  </slot-child>' +
    '</div>';
  ParentComp['data'] := function(): TJSObject
  var d: TJSObject;
  begin
    d := TJSObject.new;
    Result := d;
  end;
  RegisterComponent('slot-parent', ParentComp);

  // Componentes para testar aninhamento em slots
  ChildComp := TJSObject.new;
  ChildComp['template'] := '<div class="nested-card-body"><slot></slot></div>';
  ChildComp['data'] := function(): TJSObject begin Result := TJSObject.new; end;
  RegisterComponent('nested-card', ChildComp);

  ChildComp := TJSObject.new;
  ChildComp['template'] := '<div class="inner-badge">Badge: {{ label }}</div>';
  ChildComp['data'] := function(): TJSObject 
  var d: TJSObject;
  begin 
    d := TJSObject.new;
    d['label'] := '';
    Result := d; 
  end;
  RegisterComponent('inner-badge', ChildComp);

  ParentComp := TJSObject.new;
  ParentComp['template'] := '<div class="test-wrapper"><nested-card><inner-badge label="Active"></inner-badge></nested-card></div>';
  ParentComp['data'] := function(): TJSObject begin Result := TJSObject.new; end;
  RegisterComponent('nested-test', ParentComp);
end;

begin
  SetupScopedComponents;

  Describe('BlaiseVue 2.0 Scoped Slots', procedure
    begin
       It('deve renderizar dados passados do componente filho para o template do pai', procedure
         begin
            Wrapper := Mount('slot-parent');
            Expect(Wrapper.Find('.custom-render')).ToBeDefined;
            Expect(Wrapper.Find('.custom-render').textContent).ToContain('Hello from child - Val: 42');
         end);

       It('deve suportar componentes aninhados dentro de slots padrao sem erro de parentNode', procedure
         begin
            Wrapper := Mount('nested-test');
            Expect(Wrapper.Find('.nested-card-body')).ToBeDefined;
            Expect(Wrapper.Find('.inner-badge')).ToBeDefined;
            Expect(Wrapper.Find('.inner-badge').textContent).ToContain('Badge: Active');
         end);
    end);
end.
