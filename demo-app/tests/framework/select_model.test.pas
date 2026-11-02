program select_model_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, BVComponents, BVCompiler, BVReactivity;

var
  Wrapper: TWrapper;

procedure RegisterSelect(const AName, AOptions: string);
var
  Comp: TJSObject;
begin
  Comp := TJSObject.new;
  Comp['template'] :=
    '<div>' +
    '  <select class="sel" b-model="rate">' + AOptions + '</select>' +
    '  <button class="clear" @click="rate = ''''">Clear</button>' +
    '</div>';
  Comp['data'] := function(): TJSObject
  begin
    Result := new(['rate', '24']);
  end;
  RegisterComponent(AName, Comp);
end;

function Sel: TJSHTMLSelectElement;
begin
  Result := TJSHTMLSelectElement(Wrapper.Find('.sel'));
end;

// A select keeps the focus after the user picks an option
procedure FocusSelect;
begin
  document.body.appendChild(Wrapper.Element);
  Sel.focus();
  Expect(document.activeElement = Sel).ToBe(True);
end;

begin
  RegisterSelect('test-select-empty', '<option value="">-</option><option value="24">24</option>');
  RegisterSelect('test-select-no-empty', '<option value="13">13</option><option value="24">24</option>');

  Describe('b-model on select set to an empty string', procedure
    begin
       It('should show the empty option', procedure
         begin
            Wrapper := Mount('test-select-empty');
            Expect(Sel.value).ToBe('24');
            Wrapper.Find('.clear').click();
            Expect(Sel.value).ToBe('');
         end);

       It('should show the empty option while the select has the focus', procedure
         begin
            Wrapper := Mount('test-select-empty');
            FocusSelect;
            Wrapper.Find('.clear').click();
            Expect(Sel.value).ToBe('');
         end);

       It('should select nothing when there is no empty option', procedure
         begin
            Wrapper := Mount('test-select-no-empty');
            FocusSelect;
            Wrapper.Find('.clear').click();
            Expect(Sel.selectedIndex).ToBe(-1);
         end);
    end);
end.
