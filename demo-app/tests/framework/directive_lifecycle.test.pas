program directive_lifecycle_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, BVComponents, BVCompiler, BVReactivity;

var
  Wrapper: TWrapper;

procedure RegisterTemplate(const AName, ATemplate: string; AData: TJSObject);
var
  Comp: TJSObject;
begin
  Comp := TJSObject.new;
  Comp['template'] := ATemplate;
  Comp['data'] := function(): TJSObject
  var
    Key: string;
  begin
    Result := TJSObject.new;
    for Key in TJSObject.keys(AData) do
      Result[Key] := AData[Key];
  end;
  RegisterComponent(AName, Comp);
end;

function SelectValue: string;
begin
  Result := TJSHTMLSelectElement(Wrapper.Find('.sel')).value;
end;

function Exists(const ASelector: string): Boolean;
begin
  Result := Wrapper.Element.querySelector(ASelector) <> nil;
end;

procedure SetupComponents;
begin
  RegisterTemplate('test-select',
    '<div>' +
    '  <button class="open" @click="open = true">Open</button>' +
    '  <button class="swap" @click="rows = otherRows">Swap</button>' +
    '  <button class="set" @click="rate = ''13''">Set</button>' +
    '  <div v-if="open">' +
    '    <select class="sel" b-model="rate">' +
    '      <option value="0">0</option>' +
    '      <option b-for="v in rows" :value="v">{{ v }}</option>' +
    '    </select>' +
    '  </div>' +
    '</div>',
    new(['open', False, 'rate', '24', 'rows', TJSArray._of('13', '24'), 'otherRows', TJSArray._of('6', '13', '24')]));

  RegisterTemplate('test-closable',
    '<div class="closable"><button class="bye" @click="$emit(''close'')">Close</button><slot></slot></div>',
    TJSObject.new);

  RegisterTemplate('test-closed-parent',
    '<div>' +
    '  <button class="show" @click="open = true">Show</button>' +
    '  <test-closable v-if="open" @close="open = false"><span class="slotted">Hi</span></test-closable>' +
    '</div>',
    new(['open', False]));

  RegisterTemplate('test-open-parent',
    '<div>' +
    '  <button class="show" @click="open = true">Show</button>' +
    '  <test-closable v-if="open" @close="open = false"><span class="slotted">Hi</span></test-closable>' +
    '</div>',
    new(['open', True]));

  RegisterTemplate('test-stable-if',
    '<div>' +
    '  <button class="change" @click="lang = ''b''">Change</button>' +
    '  <div class="box" v-if="lang"><input class="field"></div>' +
    '</div>',
    new(['lang', 'a']));
end;

begin
  SetupComponents;

  Describe('Directive lifecycle', procedure
    begin
       It('should show the model value in a select created by v-if with b-for options', procedure
         begin
            Wrapper := Mount('test-select');
            Wrapper.Find('.open').click();
            Expect(SelectValue).ToBe('24');
         end);

       It('should keep the model value when the options of a select are rendered again', procedure
         begin
            Wrapper := Mount('test-select');
            Wrapper.Find('.open').click();
            Wrapper.Find('.swap').click();
            Expect(SelectValue).ToBe('24');
         end);

       It('should follow a later model change in a select', procedure
         begin
            Wrapper := Mount('test-select');
            Wrapper.Find('.open').click();
            Wrapper.Find('.set').click();
            Expect(SelectValue).ToBe('13');
         end);

       It('should close a component with v-if from its own event', procedure
         begin
            Wrapper := Mount('test-open-parent');
            Expect(Exists('.closable')).ToBe(True);
            Wrapper.Find('.bye').click();
            Expect(Exists('.closable')).ToBe(False);
         end);

       It('should open, close and open again a component with v-if, keeping its slot', procedure
         begin
            Wrapper := Mount('test-closed-parent');
            Expect(Exists('.closable')).ToBe(False);
            Wrapper.Find('.show').click();
            Expect(Exists('.slotted')).ToBe(True);
            Wrapper.Find('.bye').click();
            Expect(Exists('.closable')).ToBe(False);
            Wrapper.Find('.show').click();
            Expect(Exists('.slotted')).ToBe(True);
            Wrapper.Find('.bye').click();
            Expect(Exists('.closable')).ToBe(False);
         end);

       It('should keep the same element when a v-if value changes but stays true', procedure
         var
           Before, After: TJSElement;
         begin
            Wrapper := Mount('test-stable-if');
            Before := Wrapper.Find('.field');
            Wrapper.Find('.change').click();
            After := Wrapper.Find('.field');
            Expect(Before = After).ToBe(True);
         end);
    end);
end.
