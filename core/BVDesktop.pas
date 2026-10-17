unit BVDesktop;

{
  BVDesktop - BlaiseVue 3.5 Native Desktop & WebUI Integration
  ------------------------------------------------------------
  Provides unified Object Pascal access to native desktop window
  and OS-level capabilities:
  - Window Controls (Minimize, Maximize, Close, Fullscreen, SetTitle)
  - Native Dialogs (Open File, Save File)
  - Desktop Notifications
  - Process / Shell Execution & URL launch in external browser
  - High-performance bidirectional Pascal <-> JavaScript RPC (webui_bind)
  - Platform detection (Windows, Linux, macOS, or Browser fallback)
  
  Lightweight (<10 MB, 40 MB RAM), zero Electron bloat, 100% Pascal!
}

{$mode objfpc}

interface

uses JS, Web, SysUtils, BVReactivity;

type
  { TBVDesktop: Core Desktop Window & Hardware Controller }
  TBVDesktop = class
  public
    class function IsDesktop: Boolean;
    class function GetPlatform: string;
    class procedure Minimize;
    class procedure Maximize;
    class procedure Close;
    class procedure SetTitle(const ATitle: string);
    class procedure SetFullScreen(AValue: Boolean);
    class procedure OpenURL(const AURL: string);
    class procedure ShowNotification(const ATitle, ABody: string);
    class procedure OpenFileDialog(OnSuccess: JSValue; OnError: JSValue = nil);
    class procedure SaveFileDialog(const DefaultName: string; OnSuccess: JSValue; OnError: JSValue = nil);
    class procedure GetSystemInfo(OnSuccess: JSValue);
    class procedure Call(const AFuncName: string; const AArgs: JSValue; OnSuccess: JSValue = nil; OnError: JSValue = nil);
  end;

implementation

class function TBVDesktop.IsDesktop: Boolean;
var
  ResVal: JSValue;
begin
  asm
    let d = window.__BV_CORE__.desktop;
    ResVal = d ? d.isDesktop() : false;
  end;
  Result := Boolean(ResVal);
end;

class function TBVDesktop.GetPlatform: string;
var
  ResVal: JSValue;
begin
  asm
    let d = window.__BV_CORE__.desktop;
    ResVal = d ? d.getPlatform() : 'browser';
  end;
  Result := String(ResVal);
end;

class procedure TBVDesktop.Minimize;
begin
  asm
    let d = window.__BV_CORE__.desktop;
    if (d && d.window) d.window.minimize();
  end;
end;

class procedure TBVDesktop.Maximize;
begin
  asm
    let d = window.__BV_CORE__.desktop;
    if (d && d.window) d.window.maximize();
  end;
end;

class procedure TBVDesktop.Close;
begin
  asm
    let d = window.__BV_CORE__.desktop;
    if (d && d.window) d.window.close();
  end;
end;

class procedure TBVDesktop.SetTitle(const ATitle: string);
begin
  asm
    let d = window.__BV_CORE__.desktop;
    if (d && d.window) d.window.setTitle(ATitle);
  end;
end;

class procedure TBVDesktop.SetFullScreen(AValue: Boolean);
begin
  asm
    let d = window.__BV_CORE__.desktop;
    if (d && d.window) d.window.setFullScreen(AValue);
  end;
end;

class procedure TBVDesktop.OpenURL(const AURL: string);
begin
  asm
    let d = window.__BV_CORE__.desktop;
    if (d && d.shell) d.shell.openURL(AURL);
  end;
end;

class procedure TBVDesktop.ShowNotification(const ATitle, ABody: string);
begin
  asm
    let d = window.__BV_CORE__.desktop;
    if (d && d.notification) d.notification.show(ATitle, ABody);
  end;
end;

class procedure TBVDesktop.OpenFileDialog(OnSuccess: JSValue; OnError: JSValue);
begin
  asm
    let d = window.__BV_CORE__.desktop;
    if (d && d.dialog) d.dialog.openFile(OnSuccess, OnError);
  end;
end;

class procedure TBVDesktop.SaveFileDialog(const DefaultName: string; OnSuccess: JSValue; OnError: JSValue);
begin
  asm
    let d = window.__BV_CORE__.desktop;
    if (d && d.dialog) d.dialog.saveFile(DefaultName, OnSuccess, OnError);
  end;
end;

class procedure TBVDesktop.GetSystemInfo(OnSuccess: JSValue);
begin
  asm
    let d = window.__BV_CORE__.desktop;
    if (d && d.system) d.system.getInfo(OnSuccess);
  end;
end;

class procedure TBVDesktop.Call(const AFuncName: string; const AArgs: JSValue; OnSuccess: JSValue; OnError: JSValue);
begin
  asm
    let d = window.__BV_CORE__.desktop;
    if (d && d.rpc) d.rpc.call(AFuncName, AArgs, OnSuccess, OnError);
  end;
end;

initialization
  asm
    if (typeof window !== 'undefined') {
      window.__BV_CORE__ = window.__BV_CORE__ || {};
      let bv = window.__BV_CORE__;

      let desktopBridge = {
        isDesktop: function() {
          if (typeof window === 'undefined') return false;
          if (window.webui) return true;
          if (window.__BV_DESKTOP__ === true) return true;
          if (navigator && navigator.userAgent && navigator.userAgent.indexOf('BlaiseVueDesktop') !== -1) return true;
          return false;
        },

        getPlatform: function() {
          if (typeof navigator === 'undefined') return 'browser';
          let ua = navigator.userAgent || '';
          let plat = navigator.platform || '';
          if (plat.indexOf('Win') !== -1 || ua.indexOf('Windows') !== -1) return 'windows';
          if (plat.indexOf('Mac') !== -1 || ua.indexOf('Macintosh') !== -1) return 'macos';
          if (plat.indexOf('Linux') !== -1 || ua.indexOf('Linux') !== -1) return 'linux';
          return 'browser';
        },

        window: {
          minimize: function() {
            if (window.webui && typeof window.webui.call === 'function') {
              window.webui.call('bv_minimize');
            } else {
              console.log('[BVDesktop] window.minimize() (no-op in browser)');
            }
          },

          maximize: function() {
            if (window.webui && typeof window.webui.call === 'function') {
              window.webui.call('bv_maximize');
            } else {
              console.log('[BVDesktop] window.maximize() (no-op in browser)');
            }
          },

          close: function() {
            if (window.webui && typeof window.webui.call === 'function') {
              window.webui.call('bv_close');
            } else {
              console.log('[BVDesktop] window.close()');
              try { window.close(); } catch(e) {}
            }
          },

          setTitle: function(title) {
            if (typeof document !== 'undefined') document.title = title;
            if (window.webui && typeof window.webui.call === 'function') {
              window.webui.call('bv_set_title', title);
            }
          },

          setFullScreen: function(val) {
            if (window.webui && typeof window.webui.call === 'function') {
              window.webui.call('bv_set_fullscreen', !!val);
            } else if (typeof document !== 'undefined') {
              if (val) {
                if (document.documentElement.requestFullscreen) document.documentElement.requestFullscreen();
              } else {
                if (document.exitFullscreen) document.exitFullscreen();
              }
            }
          }
        },

        notification: {
          show: function(title, body) {
            if (window.webui && typeof window.webui.call === 'function') {
              window.webui.call('bv_notify', title, body);
            } else if (typeof Notification !== 'undefined') {
              if (Notification.permission === 'granted') {
                new Notification(title, { body: body });
              } else if (Notification.permission !== 'denied') {
                Notification.requestPermission().then(function(perm) {
                  if (perm === 'granted') new Notification(title, { body: body });
                });
              }
            } else {
              console.log('[BVDesktop] Notification: ' + title + ' - ' + body);
            }
          }
        },

        shell: {
          openURL: function(url) {
            if (window.webui && typeof window.webui.call === 'function') {
              window.webui.call('bv_open_url', url);
            } else if (typeof window !== 'undefined') {
              try { window.open(url, '_blank', 'noopener,noreferrer'); } catch(e) {}
            }
          }
        },

        dialog: {
          openFile: function(onSuccess, onError) {
            if (window.webui && typeof window.webui.call === 'function') {
              window.webui.call('bv_open_file_dialog').then(function(res) {
                if (typeof onSuccess === 'function') onSuccess(res);
              }).catch(function(err) {
                if (typeof onError === 'function') onError(err);
              });
            } else if (typeof document !== 'undefined') {
              let fi = document.createElement('input');
              fi.type = 'file';
              fi.style.display = 'none';
              fi.onchange = function(e) {
                let f = e.target.files && e.target.files[0];
                if (f && typeof onSuccess === 'function') {
                  onSuccess({ name: f.name, size: f.size, type: f.type });
                }
              };
              document.body.appendChild(fi);
              fi.click();
              setTimeout(function() { fi.remove(); }, 1000);
            } else {
              if (typeof onError === 'function') onError(new Error('File dialog not supported'));
            }
          },

          saveFile: function(defaultName, onSuccess, onError) {
            if (window.webui && typeof window.webui.call === 'function') {
              window.webui.call('bv_save_file_dialog', defaultName).then(function(res) {
                if (typeof onSuccess === 'function') onSuccess(res);
              }).catch(function(err) {
                if (typeof onError === 'function') onError(err);
              });
            } else {
              if (typeof onSuccess === 'function') onSuccess(defaultName || 'download.txt');
            }
          }
        },

        system: {
          getInfo: function(onSuccess) {
            if (window.webui && typeof window.webui.call === 'function') {
              window.webui.call('bv_get_system_info').then(function(res) {
                if (typeof onSuccess === 'function') onSuccess(res);
              });
            } else {
              let info = {
                platform: desktopBridge.getPlatform(),
                userAgent: (typeof navigator !== 'undefined') ? navigator.userAgent : 'unknown',
                isDesktop: desktopBridge.isDesktop(),
                framework: 'BlaiseVue 3.5 Desktop',
                runtime: 'WebUI Engine (Free Pascal)'
              };
              if (typeof onSuccess === 'function') onSuccess(info);
            }
          }
        },

        rpc: {
          call: function(fnName, args, onSuccess, onError) {
            if (window.webui && typeof window.webui.call === 'function') {
              window.webui.call(fnName, args)
                .then(function(res) {
                  if (typeof onSuccess === 'function') onSuccess(res);
                })
                .catch(function(err) {
                  if (typeof onError === 'function') onError(err);
                });
            } else {
              console.log('[BVDesktop] RPC call to: ' + fnName, args);
              if (typeof onSuccess === 'function') onSuccess({ status: 'mock_browser_success', func: fnName, result: null });
            }
          }
        }
      };

      bv.desktop = desktopBridge;
      window.$desktop = desktopBridge;
    }
  end;

end.
