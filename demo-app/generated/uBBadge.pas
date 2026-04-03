unit uBBadge;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uBBadge;

implementation

procedure Register_uBBadge;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  comp := TJSObject.new;
  comp['template'] :=
    '  <span class="badge" ' +
    '        :class="[''badge-'' + variant, pill ? ''rounded-pill'' : '''']"' +
    '        style="display: inline-block; padding: .35em .65em; font-size: .75em; font-weight: 700; line-height: 1; color: #fff; text-align: center; white-space: nowrap; vertical-align: baseline; border-radius: .25rem;">' +
    '    <slot></slot>' +
    '  </span>';

  comp['data'] := function(): TJSObject
  var d: TJSObject;
  begin
    d := TJSObject.new;
    Result := d;
  end;

  comp['props'] := TJSArray.new;
  TJSArray(comp['props']).push('variant');
  TJSArray(comp['props']).push('pill');

  m := TJSObject.new;
  comp['methods'] := m;


  RegisterComponent('b-badge', comp);
end;

end.
