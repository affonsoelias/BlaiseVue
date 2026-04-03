unit uBProgress;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uBProgress;

implementation

procedure Register_uBProgress;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  comp := TJSObject.new;
  comp['template'] :=
    '  <div class="progress" style="margin-top: 15px; margin-bottom: 20px; background: #e2e8f0; border-radius: 8px; height: 1.5rem; overflow: hidden;">' +
    '    <div class="progress-bar-fill" ' +
    '         :style="{ width: value + ''%'', backgroundColor: (variant == ''success'' ? ''#10b981'' : ''#3b82f6'') }"' +
    '         style="height: 100%; display: flex; align-items: center; justify-content: center; color: white; transition: width 0.4s ease-in-out; font-weight: 600; font-size: 0.8rem;">' +
    '       {{ value }}%' +
    '    </div>' +
    '  </div>';

  comp['data'] := function(): TJSObject
  var d: TJSObject;
  begin
    d := TJSObject.new;
    Result := d;
  end;

  comp['props'] := TJSArray.new;
  TJSArray(comp['props']).push('value');
  TJSArray(comp['props']).push('variant');
  TJSArray(comp['props']).push('label');

  m := TJSObject.new;
  comp['methods'] := m;


  RegisterComponent('b-progress', comp);
end;

end.
