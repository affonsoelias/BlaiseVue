unit BVDevTools;

{$mode objfpc}

interface

uses JS, Web, SysUtils;

procedure LogError(const Msg, Source: string; Err: JSValue);
procedure LogEvent(const Msg: string; Data: JSValue = nil);
procedure LogTrace(const Msg: string; Data: JSValue = nil);

implementation

var
  OverlayEl: TJSHTMLElement = nil;

procedure CreateOverlay;
begin
  if OverlayEl <> nil then Exit;
  OverlayEl := TJSHTMLElement(document.createElement('div'));
  OverlayEl.style.setProperty('position', 'fixed');
  OverlayEl.style.setProperty('top', '0');
  OverlayEl.style.setProperty('left', '0');
  OverlayEl.style.setProperty('width', '100%');
  OverlayEl.style.setProperty('height', '100%');
  OverlayEl.style.setProperty('background', 'rgba(255, 0, 0, 0.9)');
  OverlayEl.style.setProperty('color', 'white');
  OverlayEl.style.setProperty('padding', '40px');
  OverlayEl.style.setProperty('font-family', 'monospace');
  OverlayEl.style.setProperty('z-index', '9999');
  OverlayEl.style.setProperty('display', 'none');
  OverlayEl.style.setProperty('overflow', 'auto');
  
  OverlayEl.innerHTML := '<h1>[BlaiseVue] Dev Error</h1><div id="bv-error-content"></div>' +
                        '<button onclick="this.parentNode.style.display=''none''" style="margin-top:20px;padding:10px;cursor:pointer">Fechar</button>';
  
  document.body.appendChild(OverlayEl);
end;

procedure LogError(const Msg, Source: string; Err: JSValue);
var
  Content: TJSHTMLElement;
begin
  {$IFNDEF PRODUCTION}
  CreateOverlay;
  OverlayEl.style.setProperty('display', 'block');
  Content := TJSHTMLElement(document.getElementById('bv-error-content'));
  Content.innerHTML := '<h3>' + Msg + '</h3>' +
                       '<p><b>Origem:</b> ' + Source + '</p>' +
                       '<pre>' + string(TJSObject(Err)['stack']) + '</pre>';
  asm
    console.group('%c[BlaiseVue Error]', 'color: white; background: red; padding: 2px 5px; border-radius: 3px');
    console.error(Msg);
    console.error('Source:', Source);
    console.error(Err);
    console.groupEnd();
  end;
  {$ENDIF}
end;

procedure LogEvent(const Msg: string; Data: JSValue = nil);
begin
  {$IFNDEF PRODUCTION}
  asm
    console.log('%c[BlaiseVue EVENT]', 'color: #fff; background: #41b883; padding: 2px 5px; border-radius: 3px; font-weight: bold', Msg, Data || '');
  end;
  {$ENDIF}
end;

procedure LogTrace(const Msg: string; Data: JSValue = nil);
begin
  {$IFNDEF PRODUCTION}
  asm
    console.log('%c[BlaiseVue TRACE]', 'color: #fff; background: #35495e; padding: 2px 5px; border-radius: 3px; font-weight: bold', Msg, Data || '');
  end;
  {$ENDIF}
end;

initialization
  {$IFNDEF PRODUCTION}
  asm
    console.log('%c BlaiseVue DevTools %c v1.3.0-dev %c', 
      'background: #35495e; color: #fff; padding: 1px; border-radius: 3px 0 0 3px;', 
      'background: #41b883; color: #fff; padding: 1px; border-radius: 0 3px 3px 0;', 
      'background: transparent');
    window.__BLAISE_VUE_DEVTOOLS__ = true;
  end;
  {$ENDIF}
end.
