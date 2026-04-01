unit uBInput;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uBInput;

implementation

procedure Register_uBInput;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  _styleEl := TJSHTMLElement(document.createElement('style'));
  _styleEl.textContent := '.form-control:focus { outline: none; border-color: #3b82f6; box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1); }';
  document.head.appendChild(_styleEl);
  comp := TJSObject.new;
  comp['template'] :=
    '  <div class="mb-3">' +
    '    <label class="form-label" v-if="label" style="font-weight: 600; color: #475569; display: block; margin-bottom: 8px;">{{ label }}</label>' +
    '    <input ' +
    '      type="text" ' +
    '      class="form-control" ' +
    '      :placeholder="placeholder" ' +
    '      :value="value"' +
    '      @input="onInput"' +
    '      style="padding: 12px; border: 2px solid #e2e8f0; border-radius: 8px; width: 100%; transition: border-color 0.2s;"' +
    '    >' +
    '  </div>';


  m := TJSObject.new;
  m['onInput'] := procedure(_this: TJSObject; ev: JSValue)

    begin
       asm
         this.$emit('input', ev.target.value);
       end;
    end;

  comp['methods'] := m;


  RegisterComponent('b-input', comp);
end;

end.
