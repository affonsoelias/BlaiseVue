unit BVComponents;

{$mode objfpc}

interface

uses JS, Web, SysUtils;

procedure RegisterComponent(Name: string; Options: TJSObject);
function GetComponent(Name: string): TJSObject;

implementation

procedure RegisterComponent(Name: string; Options: TJSObject);
begin
  asm
    let core = window.__BV_CORE__;
    if (!core.components) core.components = {};
    core.components[Name.toLowerCase()] = Options;
  end;
end;

function GetComponent(Name: string): TJSObject;
begin
  asm
    let core = window.__BV_CORE__;
    if (!core.components) return null;
    Result = core.components[Name.toLowerCase()] || null;
  end;
end;

initialization
  asm
    if (!window.__BV_CORE__) window.__BV_CORE__ = {};
    window.__BV_CORE__.getComponent = function(n) {
      let core = window.__BV_CORE__;
      return (core.components && core.components[n.toLowerCase()]) || null;
    };
  end;

end.
