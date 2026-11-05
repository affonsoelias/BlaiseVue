program directive_lifecycle_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, BVComponents, BVCompiler, BVReactivity;

var
  Wrapper: TWrapper;
  CreatedCount: Integer;

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
var
  Comp: TJSObject;
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

  Comp := TJSObject.new;
  Comp['template'] :=
    '<div class="counter"><span class="count">{{ count }}</span>' +
    '<button class="inc" @click="count = count + 1">+</button></div>';
  Comp['data'] := function(): TJSObject
  begin
    Result := new(['count', 0]);
  end;
  Comp['created'] := procedure
  begin
    Inc(CreatedCount);
  end;
  RegisterComponent('test-counter', Comp);

  RegisterTemplate('test-wrapped-child',
    '<div>' +
    '  <button class="toggle" @click="open = !open">Toggle</button>' +
    '  <div class="holder" v-if="open"><test-counter></test-counter></div>' +
    '</div>',
    new(['open', True]));

  RegisterTemplate('test-else-child',
    '<div>' +
    '  <button class="toggle" @click="open = !open">Toggle</button>' +
    '  <span class="closed" v-if="!open">Closed</span>' +
    '  <div class="holder" v-else><test-counter></test-counter></div>' +
    '</div>',
    new(['open', True]));

  RegisterTemplate('test-model-if',
    '<div>' +
    '  <button class="toggle" @click="open = !open">Toggle</button>' +
    '  <input class="field" v-if="open" b-model="name">' +
    '</div>',
    new(['open', True, 'name', 'first']));
end;

procedure ToggleTwice;
begin
  Wrapper.Find('.toggle').click();
  Wrapper.Find('.toggle').click();
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

       It('should create a new component instance when its v-if parent opens again', procedure
         var
           Before: TJSElement;
         begin
            CreatedCount := 0;
            Wrapper := Mount('test-wrapped-child');
            Expect(CreatedCount).ToBe(1);
            Wrapper.Find('.inc').click();
            Expect(Wrapper.Find('.count').textContent).ToBe('1');
            Before := Wrapper.Find('.holder');
            ToggleTwice;
            Expect(CreatedCount).ToBe(2);
            Expect(Wrapper.Find('.count').textContent).ToBe('0');
            Expect(Wrapper.Find('.holder') = Before).ToBe(False);
         end);

       It('should create a new component instance in a v-else branch shown again', procedure
         begin
            CreatedCount := 0;
            Wrapper := Mount('test-else-child');
            Expect(CreatedCount).ToBe(1);
            Wrapper.Find('.inc').click();
            ToggleTwice;
            Expect(CreatedCount).ToBe(2);
            Expect(Wrapper.Find('.count').textContent).ToBe('0');
            ToggleTwice;
            Expect(CreatedCount).ToBe(3);
         end);

       It('should keep b-model working on an element with v-if shown again', procedure
         begin
            Wrapper := Mount('test-model-if');
            ToggleTwice;
            Expect(TJSHTMLInputElement(Wrapper.Find('.field')).value).ToBe('first');
            TJSHTMLInputElement(Wrapper.Find('.field')).value := 'second';
            Wrapper.Find('.field').dispatchEvent(TJSEvent.new('input'));
            ToggleTwice;
            Expect(TJSHTMLInputElement(Wrapper.Find('.field')).value).ToBe('second');
         end);
    end);
end.
