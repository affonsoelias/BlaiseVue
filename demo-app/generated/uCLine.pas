unit uCLine;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uCLine;

implementation

procedure Register_uCLine;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  comp := TJSObject.new;
  comp['template'] :=
    '  <c-base-chart type="line" :data="data" :options="options" :width="width" :height="height"></c-base-chart>';

  comp['data'] := function(): TJSObject
  var d: TJSObject;
  begin
    d := TJSObject.new;
    Result := d;
  end;

  comp['props'] := TJSArray.new;
  TJSArray(comp['props']).push('data');
  TJSArray(comp['props']).push('options');
  TJSArray(comp['props']).push('width');
  TJSArray(comp['props']).push('height');

  m := TJSObject.new;
  comp['methods'] := m;


  RegisterComponent('c-line', comp);
end;

end.
