program focused_model_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, BVComponents, BVCompiler, BVReactivity;

var
  Wrapper: TWrapper;

procedure RegisterField;
var
  Comp: TJSObject;
begin
  Comp := TJSObject.new;
  Comp['template'] :=
    '<div>' +
    '  <input class="field" b-model="name">' +
    '  <input class="amount" b-model="amount">' +
    '  <button class="load" @click="name = ''loaded''">Load</button>' +
    '  <button class="clear" @click="name = ''''">Clear</button>' +
    '  <button class="number" @click="amount = 12">Number</button>' +
    '  <span class="shown">{{ name }}</span>' +
    '</div>';
  Comp['data'] := function(): TJSObject
  begin
    Result := new(['name', '', 'amount', 0]);
  end;
  RegisterComponent('test-focused-field', Comp);
end;

function Field(const ASelector: string): TJSHTMLInputElement;
begin
  Result := TJSHTMLInputElement(Wrapper.Find(ASelector));
end;

procedure FocusField(const ASelector: string);
begin
  document.body.appendChild(Wrapper.Element);
  Field(ASelector).focus();
  Expect(document.activeElement = Field(ASelector)).ToBe(True);
end;

procedure TypeText(const ASelector, AText: string);
begin
  Field(ASelector).value := AText;
  Field(ASelector).dispatchEvent(TJSEvent.new('input'));
end;

begin
  RegisterField;

  Describe('b-model on a focused text field', procedure
    begin
       It('should show a value loaded while the field has the focus', procedure
         begin
            Wrapper := Mount('test-focused-field');
            FocusField('.field');
            Wrapper.Find('.load').click();
            Expect(Field('.field').value).ToBe('loaded');
         end);

       It('should clear the field from code after typing', procedure
         begin
            Wrapper := Mount('test-focused-field');
            FocusField('.field');
            TypeText('.field', 'abc');
            Expect(Wrapper.Find('.shown').textContent).ToBe('abc');
            Wrapper.Find('.clear').click();
            Expect(Field('.field').value).ToBe('');
         end);

       It('should not rewrite the field when the model only echoes the typing', procedure
         var
           Writes: Integer;
           Proto, Native: TJSObject;
         begin
            Wrapper := Mount('test-focused-field');
            FocusField('.field');
            Writes := 0;
            Proto := TJSObject(Field('.field'));
            asm
              Native = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value');
              Object.defineProperty(Proto, 'value', {
                configurable: true,
                get: function() { return Native.get.call(this); },
                set: function(v) { Writes++; Native.set.call(this, v); }
              });
            end;
            TypeText('.field', 'abc');
            Expect(Writes).ToBe(1);
            Expect(Field('.field').value).ToBe('abc');
         end);

       It('should keep a number being typed as text when the model holds the same number', procedure
         begin
            Wrapper := Mount('test-focused-field');
            FocusField('.amount');
            Field('.amount').value := '12.0';
            Wrapper.Find('.number').click();
            Expect(Field('.amount').value).ToBe('12.0');
         end);
    end);
end.
