program hoisting_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, BVComponents, BVCompiler, BVReactivity;

var
  Wrapper: TWrapper;
  StaticComp: TJSObject;
  StaticNode, DynamicNode: TJSHTMLElement;

function CheckIsStatic(Node: JSValue): Boolean;
begin
  asm
    Result = window.__BV_CORE__.isStatic(Node);
  end;
end;

function GetNodeProp(Node: JSValue; const PropName: string): JSValue;
begin
  asm
    Result = (Node && typeof Node === 'object') ? Node[PropName] : undefined;
  end;
end;

procedure SetupHoistingComponent;
begin
  StaticComp := TJSObject.new;
  StaticComp['template'] :=
    '<div class="hoist-root">' +
    '  <div class="pure-static-box">' +
    '    <h4>Titulo Estático Hoisted</h4>' +
    '    <p>Este paragrafo nunca muda.</p>' +
    '  </div>' +
    '  <div class="dynamic-box">' +
    '    <span class="dyn-val">{{ count }}</span>' +
    '  </div>' +
    '</div>';
  StaticComp['data'] := function(): TJSObject
  var d: TJSObject;
  begin
    d := TJSObject.new;
    d['count'] := 100;
    Result := d;
  end;
  RegisterComponent('test-hoisting', StaticComp);
end;

begin
  SetupHoistingComponent;

  Describe('BlaiseVue 2.0 Static Hoisting & Compiler Pruning', procedure
    begin
       It('deve identificar subarvores puramente estaticas como estaticas', procedure
         begin
            StaticNode := TJSHTMLElement(document.createElement('div'));
            StaticNode.innerHTML := '<h3>Fixed Title</h3><p>Static Description</p>';
            Expect(CheckIsStatic(StaticNode)).ToBe(True);
         end);

       It('deve identificar elementos com interpolacao ou diretivas como dinamicos', procedure
         begin
            DynamicNode := TJSHTMLElement(document.createElement('div'));
            DynamicNode.innerHTML := '<span>{{ dynamicCount }}</span>';
            Expect(CheckIsStatic(DynamicNode)).ToBe(False);
         end);

       It('deve marcar o nó estático no DOM com bvStatic = true apos compilacao', procedure
         begin
            Wrapper := Mount('test-hoisting');
            StaticNode := Wrapper.Find('.pure-static-box');
            Expect(StaticNode).ToBeDefined;
            Expect(GetNodeProp(StaticNode, 'bvStatic')).ToBe(True);
         end);

       It('nao deve marcar o nó dinamico com bvStatic', procedure
         begin
            Wrapper := Mount('test-hoisting');
            DynamicNode := Wrapper.Find('.dynamic-box');
            Expect(DynamicNode).ToBeDefined;
            Expect(GetNodeProp(DynamicNode, 'bvStatic')).ToBeUndefined;
         end);
    end);
end.
