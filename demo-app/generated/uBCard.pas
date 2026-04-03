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
    '  <div class="card" style="position: relative; display: flex; flex-direction: column; min-width: 0; word-wrap: break-word; background-color: #fff; background-clip: border-box; border: 1px solid rgba(0,0,0,.125); border-radius: .25rem;">' +
    '    <div class="card-header" b-if="title" style="padding: .5rem 1rem; margin-bottom: 0; background-color: rgba(0,0,0,.03); border-bottom: 1px solid rgba(0,0,0,.125);">' +
    '      <slot name="header">{{ title }}</slot>' +
    '    </div>' +
    '    <div class="card-body" style="flex: 1 1 auto; padding: 1rem 1rem;">' +
    '      <slot></slot>' +
    '    </div>' +
    '  </div>';

  comp['data'] := function(): TJSObject
  var d: TJSObject;
  begin
    d := TJSObject.new;
    Result := d;
  end;

  comp['props'] := TJSArray.new;
  TJSArray(comp['props']).push('title');

  m := TJSObject.new;
  comp['methods'] := m;


  RegisterComponent('b-card', comp);
end;

end.
