program teleport_suspense_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, BVComponents, BVCompiler, BVReactivity;

var
  Wrapper: TWrapper;
  TeleportComp: TJSObject;
  SuspenseComp: TJSObject;
  El: TJSHTMLElement;

procedure SetupTestComponents;
begin
  // Teleport component
  TeleportComp := TJSObject.new;
  TeleportComp['template'] :=
    '<div class="component-root">' +
    '  <teleport to="body">' +
    '    <div class="teleported-modal">Teleported to Body Content</div>' +
    '  </teleport>' +
    '</div>';
  TeleportComp['data'] := function(): TJSObject
  begin
    Result := TJSObject.new;
  end;
  RegisterComponent('test-teleport', TeleportComp);

  // Suspense component with fallback slot
  SuspenseComp := TJSObject.new;
  SuspenseComp['template'] :=
    '<div class="suspense-root">' +
    '  <suspense>' +
    '    <div class="async-data">Resolved Content</div>' +
    '    <template #fallback>' +
    '      <div class="async-fallback">Loading async resource...</div>' +
    '    </template>' +
    '  </suspense>' +
    '</div>';
  SuspenseComp['data'] := function(): TJSObject
  begin
    Result := TJSObject.new;
  end;
  RegisterComponent('test-suspense', SuspenseComp);
end;

begin
  SetupTestComponents;

  Describe('BlaiseVue 2.0 Teleport & Suspense', procedure
    begin
       It('deve teleportar o conteudo diretamente para document.body', procedure
         begin
            Wrapper := Mount('test-teleport');
            El := TJSHTMLElement(document.body.querySelector('.teleported-modal'));
            Expect(El).ToBeDefined;
            Expect(El.textContent).ToContain('Teleported to Body Content');
         end);

       It('deve renderizar conteudo de componente suspense', procedure
         begin
            Wrapper := Mount('test-suspense');
            Expect(Wrapper.Find('.async-data')).ToBeDefined;
            Expect(Wrapper.Find('.async-data').textContent).ToContain('Resolved Content');
         end);
    end);
end.
