program radio_model_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, BVComponents, BVCompiler, BVReactivity;

var
  Wrapper: TWrapper;

procedure RegisterRadios(const AName, ATemplate: string);
var
  Comp: TJSObject;
begin
  Comp := TJSObject.new;
  Comp['template'] := ATemplate;
  Comp['data'] := function(): TJSObject
  begin
    Result := new(['kind', 'debit', 'other', 'credit', 'count', 1]);
  end;
  RegisterComponent(AName, Comp);
end;

function Radio(const ASelector: string): TJSHTMLInputElement;
begin
  Result := TJSHTMLInputElement(Wrapper.Find(ASelector));
end;

procedure Choose(const ASelector: string);
begin
  Radio(ASelector).checked := True;
  Radio(ASelector).dispatchEvent(TJSEvent.new('change'));
end;

begin
  RegisterRadios('test-radios',
    '<div>' +
    '  <input class="debit" type="radio" name="kind" value="debit" b-model="kind">' +
    '  <input class="credit" type="radio" name="kind" value="credit" b-model="kind">' +
    '  <button class="set" @click="kind = ''credit''">Set</button>' +
    '  <span class="shown">{{ kind }}</span>' +
    '</div>');

  RegisterRadios('test-bound-radios',
    '<div>' +
    '  <input class="first" type="radio" name="bound" :value="kind" b-model="other">' +
    '  <input class="second" type="radio" name="bound" :value="other" b-model="other">' +
    '</div>');

  RegisterRadios('test-number-radios',
    '<div>' +
    '  <input class="one" type="radio" name="count" value="1" b-model="count">' +
    '  <input class="two" type="radio" name="count" value="2" b-model="count">' +
    '</div>');

  Describe('b-model on radio inputs', procedure
    begin
       It('should keep the value of each radio', procedure
         begin
            Wrapper := Mount('test-radios');
            Expect(Radio('.debit').value).ToBe('debit');
            Expect(Radio('.credit').value).ToBe('credit');
         end);

       It('should check only the radio that matches the model', procedure
         begin
            Wrapper := Mount('test-radios');
            Expect(Radio('.debit').checked).ToBe(True);
            Expect(Radio('.credit').checked).ToBe(False);
         end);

       It('should write the value of the chosen radio to the model', procedure
         begin
            Wrapper := Mount('test-radios');
            Choose('.credit');
            Expect(Wrapper.Find('.shown').textContent).ToBe('credit');
            Expect(Radio('.debit').checked).ToBe(False);
         end);

       It('should follow a later model change', procedure
         begin
            Wrapper := Mount('test-radios');
            Wrapper.Find('.set').click();
            Expect(Radio('.credit').checked).ToBe(True);
            Expect(Radio('.debit').checked).ToBe(False);
            Expect(Radio('.credit').value).ToBe('credit');
         end);

       It('should work with a bound value', procedure
         begin
            Wrapper := Mount('test-bound-radios');
            Expect(Radio('.first').value).ToBe('debit');
            Expect(Radio('.second').value).ToBe('credit');
            Expect(Radio('.second').checked).ToBe(True);
            Expect(Radio('.first').checked).ToBe(False);
         end);

       It('should match a number in the model', procedure
         begin
            Wrapper := Mount('test-number-radios');
            Expect(Radio('.one').checked).ToBe(True);
            Expect(Radio('.two').checked).ToBe(False);
         end);
    end);
end.
