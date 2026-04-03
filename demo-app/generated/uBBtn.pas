unit uBBtn;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uBBtn;

implementation

procedure Register_uBBtn;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  comp := TJSObject.new;
  comp['template'] :=
    '  <button :type="type" ' +
    '          class="btn" ' +
    '          :class="[(outline ? ''btn-outline-'' : ''btn-'') + variant, ''btn-'' + size]"' +
    '          @click="$emit(''click'', $event)"' +
    '          style="display: inline-block; font-weight: 400; line-height: 1.5; text-align: center; vertical-align: middle; cursor: pointer; user-select: none; border: 1px solid transparent; padding: .375rem .75rem; font-size: 1rem; border-radius: .25rem; transition: color .15s ease-in-out, background-color .15s ease-in-out, border-color .15s ease-in-out, box-shadow .15s ease-in-out;">' +
    '    <slot></slot>' +
    '  </button>';

  comp['data'] := function(): TJSObject
  var d: TJSObject;
  begin
    d := TJSObject.new;
    Result := d;
  end;

  comp['props'] := TJSArray.new;
  TJSArray(comp['props']).push('variant');
  TJSArray(comp['props']).push('outline');
  TJSArray(comp['props']).push('size');
  TJSArray(comp['props']).push('type');

  m := TJSObject.new;
  comp['methods'] := m;


  RegisterComponent('b-btn', comp);
end;

end.
