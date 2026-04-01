unit uCScatter;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uCScatter;

implementation

procedure Register_uCScatter;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  comp := TJSObject.new;
  comp['template'] :=
    '  <c-base-chart type="scatter" :data="data" :options="options" :width="width" :height="height"></c-base-chart>';


  m := TJSObject.new;
  comp['methods'] := m;


  RegisterComponent('c-scatter', comp);
end;

end.
