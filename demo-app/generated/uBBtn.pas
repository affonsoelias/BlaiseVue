unit uBBtn;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uBBtn;

implementation

procedure Register_uBBtn;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  comp := TJSObject.new;
  comp['template'] :=
    '  <button class="btn" :class="''btn-'' + variant" @click="handleClick" style="min-width: 100px; padding: 10px 20px; font-weight: 600;">' +
    '    <span v-if="label">{{ label }}</span>' +
    '    <slot v-if="!label"></slot>' +
    '  </button>';


  m := TJSObject.new;
  m['handleClick'] := procedure(_this: TJSObject)

    begin
       asm this.$emit('click'); end;
    end;

  comp['methods'] := m;


  RegisterComponent('b-btn', comp);
end;

end.
