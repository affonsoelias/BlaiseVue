unit uCStacked;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uCStacked;

implementation

procedure Register_uCStacked;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  comp := TJSObject.new;
  comp['template'] :=
    '  <c-base-chart type="stacked" :data="data" :options="options" :width="width" :height="height"></c-base-chart>';


  m := TJSObject.new;
  comp['methods'] := m;


  RegisterComponent('c-stacked', comp);
end;

end.
