unit uBInputGroup;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uBInputGroup;

implementation

procedure Register_uBInputGroup;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  comp := TJSObject.new;
  comp['template'] :=
    '  <div class="row mb-3">' +
    '    <label class="form-label" v-if="label" style="font-weight: 600; color: #475569; display: block; margin-bottom: 8px;">{{ label }}</label>' +
    '    <div class="input-group" style="display: flex; align-items: stretch; width: 100%; border: 2px solid #e2e8f0; border-radius: 8px; overflow: hidden; transition: border-color 0.2s;">' +
    '       <span class="input-group-text" v-if="prepend" style="padding: 10px 15px; background: #f1f5f9; border-right: 1px solid #e2e8f0; color: #64748b; font-weight: 500;">{{ prepend }}</span>' +
    '       <input ' +
    '         type="text" ' +
    '         class="form-control flex-grow-1" ' +
    '         :placeholder="placeholder" ' +
    '         :value="value"' +
    '         @input="onInput"' +
    '         style="padding: 12px; border: none; outline: none; width: 100%;"' +
    '       >' +
    '       <span class="input-group-text" v-if="append" style="padding: 10px 15px; background: #f1f5f9; border-left: 1px solid #e2e8f0; color: #64748b; font-weight: 500;">{{ append }}</span>' +
    '    </div>' +
    '  </div>';


  m := TJSObject.new;
  m['onInput'] := procedure(_this: TJSObject; ev: JSValue)

    begin
       asm this.$emit('input', ev.target.value); end;
    end;

  comp['methods'] := m;


  RegisterComponent('b-input-group', comp);
end;

end.
