unit uBNavItem;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uBNavItem;

implementation

procedure Register_uBNavItem;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  comp := TJSObject.new;
  comp['template'] :=
    '  <li class="nav-item">' +
    '     <a class="nav-link" style="color: inherit; text-decoration: none;" href="#" @click="$emit(''click'')">' +
    '        {{ label }}' +
    '     </a>' +
    '  </li>';


  m := TJSObject.new;
  comp['methods'] := m;


  RegisterComponent('b-nav-item', comp);
end;

end.
