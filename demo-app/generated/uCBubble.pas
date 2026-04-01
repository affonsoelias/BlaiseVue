unit uCBubble;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uCBubble;

implementation

procedure Register_uCBubble;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  comp := TJSObject.new;
  comp['template'] :=
    '  <c-base-chart type="bubble" :data="data" :options="options" :width="width" :height="height"></c-base-chart>';


  m := TJSObject.new;
  comp['methods'] := m;


  RegisterComponent('c-bubble', comp);
end;

end.
