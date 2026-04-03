unit uCRadar;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uCRadar;

implementation

procedure Register_uCRadar;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  comp := TJSObject.new;
  comp['template'] :=
    '  <c-base-chart type="radar" :data="data" :options="options" :width="width" :height="height"></c-base-chart>';

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


  RegisterComponent('c-radar', comp);
end;

end.
