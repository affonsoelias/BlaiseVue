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
    '  <nav class="navbar navbar-expand-lg navbar-dark bg-dark rounded-3 mb-4" style="padding: 0.5rem 1rem;">' +
    '    <div class="container-fluid d-flex">' +
    '      <a class="navbar-brand" href="#" style="font-weight: 700; color: #42b883;">{{ brand }}</a>' +
    '      <div class="collapse navbar-collapse d-flex">' +
    '        <ul class="navbar-nav me-auto mb-2 mb-lg-0 flex-row gap-3" style="list-style: none; margin: 0; padding-left: 20px;">' +
    '          <slot></slot>' +
    '        </ul>' +
    '      </div>' +
    '    </div>' +
    '  </nav>';

  comp['data'] := function(): TJSObject
  var d: TJSObject;
  begin
    d := TJSObject.new;
    Result := d;
  end;

  comp['props'] := TJSArray.new;
  TJSArray(comp['props']).push('brand');

  m := TJSObject.new;
  comp['methods'] := m;


  RegisterComponent('b-navbar', comp);
end;

end.
