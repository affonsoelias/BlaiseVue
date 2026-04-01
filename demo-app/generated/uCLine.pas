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


  m := TJSObject.new;
  comp['methods'] := m;


  RegisterComponent('c-line', comp);
end;

end.
