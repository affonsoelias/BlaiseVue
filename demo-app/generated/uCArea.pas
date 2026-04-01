unit uCArea;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uCArea;

implementation

procedure Register_uCArea;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  comp := TJSObject.new;
  comp['template'] :=
    '  <c-base-chart type="area" :data="data" :options="options" :width="width" :height="height"></c-base-chart>';


  m := TJSObject.new;
  comp['methods'] := m;


  RegisterComponent('c-area', comp);
end;

end.
