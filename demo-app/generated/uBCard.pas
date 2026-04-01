unit uBCard;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uBCard;

implementation

procedure Register_uBCard;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  comp := TJSObject.new;
  comp['template'] :=
    '  <div class="card">' +
    '    <div class="card-header" b-if="title">' +
    '      <slot name="header">{{ title }}</slot>' +
    '    </div>' +
    '    <div class="card-body">' +
    '      <slot></slot>' +
    '    </div>' +
    '  </div>';

  comp['data'] := function(): TJSObject
  var d: TJSObject;
  begin
    d := TJSObject.new;
    d['title'] := '';
    Result := d;
  end;

  m := TJSObject.new;
  comp['methods'] := m;


  RegisterComponent('b-card', comp);
end;

end.
