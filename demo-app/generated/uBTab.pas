unit uBTab;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uBTab;

implementation

procedure Register_uBTab;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  comp := TJSObject.new;
  comp['template'] :=
    '  <div class="tab-pane" b-show="active" v-if="render">' +
    '     <slot></slot>' +
    '  </div>';

  comp['data'] := function(): TJSObject
  var d: TJSObject;
  begin
    d := TJSObject.new;
    d['render'] := true;
    Result := d;
  end;

  m := TJSObject.new;
  comp['methods'] := m;

  comp['created'] := procedure(_this: TJSObject)
    begin
       if Assigned(_this['registerTab']) then
       begin
         asm 
           const t = { id: this.id, title: this.title };
           this.registerTab(t);
         end;
       end;
    end;

    ;
  comp['computed'] := TJSObject.new;
  comp['inject'] := TJSArray.new;
  TJSArray(comp['inject']).push('registerTab:');
  TJSArray(comp['inject']).push('pointer');
  TJSArray(comp['inject']).push('isActive:');
  TJSArray(comp['inject']).push('pointer');

  RegisterComponent('b-tab', comp);
end;

end.
