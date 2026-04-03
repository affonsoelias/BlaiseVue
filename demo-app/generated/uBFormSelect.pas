unit uBFormSelect;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uBFormSelect;

implementation

procedure Register_uBFormSelect;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  _styleEl := TJSHTMLElement(document.createElement('style'));
  _styleEl.textContent := '.form-select:focus { border-color: #0d6efd; box-shadow: 0 0 0 0.25rem rgba(13, 110, 253, 0.25); outline: 0; }';
  document.head.appendChild(_styleEl);
  comp := TJSObject.new;
  comp['template'] :=
    '  <div class="mb-3">' +
    '    <label class="form-label" v-if="label" style="font-weight: 600; color: #475569; display: block; margin-bottom: 8px;">{{ label }}</label>' +
    '    <select class="form-select" :value="value" @change="onChange" ' +
    '            style="width: 100%; padding: 12px; border: 2px solid #e2e8f0; border-radius: 8px; cursor: pointer; transition: border-color 0.2s; background-color: #fff;">' +
    '       <option b-for="opt in options" :value="opt.value">{{ opt.text }}</option>' +
    '    </select>' +
    '  </div>';

  comp['data'] := function(): TJSObject
  var d: TJSObject;
  begin
    d := TJSObject.new;
    Result := d;
  end;

  comp['props'] := TJSArray.new;
  TJSArray(comp['props']).push('label');
  TJSArray(comp['props']).push('value');
  TJSArray(comp['props']).push('options');

  m := TJSObject.new;
  m['onChange'] := procedure(_this: TJSObject; ev: JSValue)

    begin
       asm this.$emit('input', ev.target.value); this.$emit('change', ev.target.value); end;
    end;

  comp['methods'] := m;


  RegisterComponent('b-form-select', comp);
end;

end.
