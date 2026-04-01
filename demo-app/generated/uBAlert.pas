unit uBAlert;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uBAlert;

implementation

procedure Register_uBAlert;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  _styleEl := TJSHTMLElement(document.createElement('style'));
  _styleEl.textContent := '.alert { padding: 15px; border-radius: 8px; margin-bottom: 20px; border-left: 5px solid transparent; }   .alert-primary { background: #cfe2ff; color: #084298; border-color: #084298; }   .alert-success { background: #d1e7dd; color: #0f5132; border-color: #0f5132; }   .alert-danger { background: #f8d7da; color: #842029; border-color: #842029; }   .alert-info { background: #cff4fc; color: #055160; border-color: #055160; }';
  document.head.appendChild(_styleEl);
  comp := TJSObject.new;
  comp['template'] :=
    '  <div class="alert" :class="''alert-'' + variant" v-if="visible">' +
    '    <div class="flex justify-between align-center" style="display:flex; justify-content:space-between; align-items:center;">' +
    '       <div><slot></slot></div>' +
    '       <button v-if="dismissible" type="button" class="btn-close" @click="close" style="background:none; border:none; cursor:pointer; font-weight:bold; font-size:1.5rem; line-height:1;">&times;</button>' +
    '    </div>' +
    '  </div>';

  comp['data'] := function(): TJSObject
  var d: TJSObject;
  begin
    d := TJSObject.new;
    d['visible'] := true;
    Result := d;
  end;

  m := TJSObject.new;
  m['close'] := procedure(_this: TJSObject)

    begin
       _this['visible'] := false;
       asm this.$emit('close'); end;
    end;

  comp['methods'] := m;


  RegisterComponent('b-alert', comp);
end;

end.
