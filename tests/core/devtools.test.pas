program devtools_test;

{$mode objfpc}

uses JS, Web, BVDevTools, BVTestUtils;

procedure ResetDevToolsDom;
var
  Existing: TJSElement;
begin
  Existing := document.getElementById('bv-devtools');
  if (Existing <> nil) and (Existing.parentNode <> nil) then
    Existing.parentNode.removeChild(Existing);
  asm
    delete window.__BV_DEVTOOLS_HOOK__;
  end;
end;

begin
  Describe('BVDevTools', procedure
    begin
       It('auto-initializes panel, app version row, and devtools hook', procedure
         var
           Panel, AppRow: TJSElement;
           Hook: TJSObject;
         begin
            Panel := document.getElementById('bv-devtools');
            Expect(Panel <> nil).ToBeTruthy;

            AppRow := document.getElementById('bv-app-version');
            Expect(AppRow <> nil).ToBeTruthy;

            Hook := TJSObject(window['__BV_DEVTOOLS_HOOK__']);
            Expect(Hook <> nil).ToBeTruthy;
            Expect(Hook['frameworkVersion']).ToBeDefined;
            Expect(Hook['appVersion']).ToBeDefined;
         end);

       It('separates framework version from app version using injected globals', procedure
         var
           TagEl, AppSpan, Hook: TJSObject;
         begin
            ResetDevToolsDom;
            window['__BV_FRAMEWORK_VERSION__'] := '0.9.9';
            window['__BV_APP_VERSION__'] := '1.2.3';

            InitDevTools;

            TagEl := TJSObject(document.querySelector('#bv-devtools .bv-dt-tag'));
            AppSpan := TJSObject(document.querySelector('#bv-app-version span:last-child'));
            Hook := TJSObject(window['__BV_DEVTOOLS_HOOK__']);

            Expect(TagEl['textContent']).ToBe('v0.9.9');
            Expect(AppSpan['textContent']).ToBe('v1.2.3');
            Expect(Hook['frameworkVersion']).ToBe('0.9.9');
            Expect(Hook['version']).ToBe('0.9.9');
            Expect(Hook['appVersion']).ToBe('1.2.3');
         end);

       It('toggles collapsed state and records emitted timeline events', procedure
         var
           Panel, ToggleBtn, EventsEl: TJSHTMLElement;
           Hook: TJSObject;
         begin
            Panel := TJSHTMLElement(document.getElementById('bv-devtools'));
            ToggleBtn := TJSHTMLElement(document.getElementById('bv-dt-toggle'));
            Expect(Panel <> nil).ToBeTruthy;
            Expect(ToggleBtn <> nil).ToBeTruthy;

            if not Panel.classList.contains('bv-dt-collapsed') then
            begin
              ToggleBtn.click;
              Expect(Panel.classList.contains('bv-dt-collapsed')).ToBeTruthy;
            end;
            ToggleBtn.click;
            Expect(Panel.classList.contains('bv-dt-collapsed')).ToBeFalsy;

            Hook := TJSObject(window['__BV_DEVTOOLS_HOOK__']);
            asm
              Hook.emit('route:change', { path: '/about' });
            end;
            EventsEl := TJSHTMLElement(document.getElementById('bv-dt-events'));
            Expect(EventsEl.textContent).ToContain('route:change');

            ResetDevToolsDom;
            asm
              delete window.__BV_FRAMEWORK_VERSION__;
              delete window.__BV_APP_VERSION__;
            end;
         end);
    end);
end.
