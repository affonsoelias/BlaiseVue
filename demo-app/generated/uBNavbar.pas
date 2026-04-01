unit uBNavbar;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uBNavbar;

implementation

procedure Register_uBNavbar;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  comp := TJSObject.new;
  comp['template'] :=
    '  <nav class="navbar navbar-expand-lg navbar-dark bg-dark rounded-3 mb-4">' +
    '    <div class="container-fluid">' +
    '      <a class="navbar-brand" href="#">{{ brand }}</a>' +
    '      <div class="collapse navbar-collapse d-flex">' +
    '        <ul class="navbar-nav me-auto mb-2 mb-lg-0 flex-row gap-3">' +
    '          <slot></slot>' +
    '        </ul>' +
    '      </div>' +
    '    </div>' +
    '  </nav>';


  m := TJSObject.new;
  comp['methods'] := m;


  RegisterComponent('b-navbar', comp);
end;

end.
