unit uBBreadcrumb;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uBBreadcrumb;

implementation

procedure Register_uBBreadcrumb;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  comp := TJSObject.new;
  comp['template'] :=
    '  <nav aria-label="breadcrumb">' +
    '    <ol class="breadcrumb" style="display: flex; flex-wrap: wrap; list-style: none; padding: 0; margin-bottom: 1rem; border-radius: .25rem; background: transparent;">' +
    '      <slot></slot>' +
    '    </ol>' +
    '  </nav>';


  m := TJSObject.new;
  comp['methods'] := m;


  RegisterComponent('b-breadcrumb', comp);
end;

end.
