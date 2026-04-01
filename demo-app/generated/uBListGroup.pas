unit uBListGroup;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uBListGroup;

implementation

procedure Register_uBListGroup;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  comp := TJSObject.new;
  comp['template'] :=
    '  <ul class="list-group" style="list-style: none; padding: 0; border: 1px solid #dee2e6; border-radius: 8px; overflow: hidden;">' +
    '    <slot></slot>' +
    '  </ul>';


  m := TJSObject.new;
  comp['methods'] := m;


  RegisterComponent('b-list-group', comp);
end;

end.
