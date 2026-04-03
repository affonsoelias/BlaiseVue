unit uBSpinner;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uBSpinner;

implementation

procedure Register_uBSpinner;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  comp := TJSObject.new;
  comp['template'] :=
    '  <div class="spinner-border" :class="''text-'' + variant" role="status" style="width: 2rem; height: 2rem;">' +
    '    <span class="visually-hidden">Loading...</span>' +
    '  </div>';

  comp['data'] := function(): TJSObject
  var d: TJSObject;
  begin
    d := TJSObject.new;
    Result := d;
  end;

  comp['props'] := TJSArray.new;
  TJSArray(comp['props']).push('variant');

  m := TJSObject.new;
  comp['methods'] := m;


  RegisterComponent('b-spinner', comp);
end;

end.
