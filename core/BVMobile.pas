unit BVMobile;

{
  BVMobile - BlaiseVue 3.5 Mobile Hardware & Capacitor Integration
  ---------------------------------------------------------------
  Provides unified Object Pascal access to mobile device hardware:
  - Camera & QR/Barcode capture
  - Geolocation (GPS coordinates)
  - Haptics & Vibration feedback
  - Device & Battery status
  - Status Bar styling
  - Platform detection (Android, iOS, Web)

  Features full transparent fallback when running in a standard web browser!
}

{$mode objfpc}

interface

uses JS, Web, SysUtils, BVReactivity;

type
  { TBVMobile: Core Mobile Hardware Controller }
  TBVMobile = class
  public
    class function IsNative: Boolean;
    class function GetPlatform: string;
    class procedure Vibrate(DurationMs: Integer = 200);
    class procedure Impact(const Style: string = 'medium');
    class procedure Notification(const AType: string = 'success');
    class procedure GetCurrentPosition(OnSuccess: JSValue; OnError: JSValue = nil);
    class procedure TakePhoto(OnSuccess: JSValue; OnError: JSValue = nil);
    class procedure GetDeviceInfo(OnSuccess: JSValue);
    class procedure SetStatusBarColor(const ColorHex: string);
  end;

implementation

class function TBVMobile.IsNative: Boolean;
var
  ResVal: JSValue;
begin
  asm
    let m = window.__BV_CORE__.mobile;
    ResVal = m ? m.isNative() : false;
  end;
  Result := Boolean(ResVal);
end;

class function TBVMobile.GetPlatform: string;
var
  ResVal: JSValue;
begin
  asm
    let m = window.__BV_CORE__.mobile;
    ResVal = m ? m.getPlatform() : 'web';
  end;
  Result := String(ResVal);
end;

class procedure TBVMobile.Vibrate(DurationMs: Integer);
begin
  asm
    let m = window.__BV_CORE__.mobile;
    if (m && m.haptics) m.haptics.vibrate(DurationMs);
  end;
end;

class procedure TBVMobile.Impact(const Style: string);
begin
  asm
    let m = window.__BV_CORE__.mobile;
    if (m && m.haptics) m.haptics.impact(Style);
  end;
end;

class procedure TBVMobile.Notification(const AType: string);
begin
  asm
    let m = window.__BV_CORE__.mobile;
    if (m && m.haptics) m.haptics.notification(AType);
  end;
end;

class procedure TBVMobile.GetCurrentPosition(OnSuccess: JSValue; OnError: JSValue);
begin
  asm
    let m = window.__BV_CORE__.mobile;
    if (m && m.geolocation) m.geolocation.getCurrentPosition(OnSuccess, OnError);
  end;
end;

class procedure TBVMobile.TakePhoto(OnSuccess: JSValue; OnError: JSValue);
begin
  asm
    let m = window.__BV_CORE__.mobile;
    if (m && m.camera) m.camera.takePhoto(OnSuccess, OnError);
  end;
end;

class procedure TBVMobile.GetDeviceInfo(OnSuccess: JSValue);
begin
  asm
    let m = window.__BV_CORE__.mobile;
    if (m && m.device) m.device.getInfo(OnSuccess);
  end;
end;

class procedure TBVMobile.SetStatusBarColor(const ColorHex: string);
begin
  asm
    let m = window.__BV_CORE__.mobile;
    if (m && m.statusBar) m.statusBar.setBackgroundColor(ColorHex);
  end;
end;

{ Auto-register the JavaScript Bridge for $mobile in browser runtime }
initialization
  asm
    if (typeof window !== 'undefined') {
      if (!window.__BV_CORE__) window.__BV_CORE__ = {};
      const bv = window.__BV_CORE__;

      // Detect Capacitor or Web runtime
      const hasCapacitor = Boolean(window.Capacitor && window.Capacitor.isNativePlatform && window.Capacitor.isNativePlatform());
      const capPlatform = hasCapacitor ? (window.Capacitor.getPlatform() || 'android') : 'web';

      const mobileBridge = {
        isNative: function() {
          if (window.Capacitor && typeof window.Capacitor.isNativePlatform === 'function') {
            return window.Capacitor.isNativePlatform();
          }
          return false;
        },

        getPlatform: function() {
          if (window.Capacitor && typeof window.Capacitor.getPlatform === 'function') {
            return window.Capacitor.getPlatform();
          }
          const userAgent = navigator.userAgent || '';
          if (/android/i.test(userAgent)) return 'android';
          if (/iPad|iPhone|iPod/.test(userAgent)) return 'ios';
          return 'web';
        },

        haptics: {
          vibrate: function(durationMs) {
            const ms = durationMs || 200;
            if (window.Capacitor && window.Capacitor.Plugins && window.Capacitor.Plugins.Haptics) {
              window.Capacitor.Plugins.Haptics.vibrate({ duration: ms });
            } else if (typeof navigator !== 'undefined' && navigator.vibrate) {
              navigator.vibrate(ms);
            } else {
              console.log('[BVMobile] Haptics.vibrate simulation (' + ms + 'ms)');
            }
          },

          impact: function(style) {
            const s = style || 'medium';
            if (window.Capacitor && window.Capacitor.Plugins && window.Capacitor.Plugins.Haptics) {
              window.Capacitor.Plugins.Haptics.impact({ style: s.toUpperCase() });
            } else if (typeof navigator !== 'undefined' && navigator.vibrate) {
              navigator.vibrate(s === 'heavy' ? 40 : (s === 'light' ? 15 : 25));
            } else {
              console.log('[BVMobile] Haptics.impact simulation (' + s + ')');
            }
          },

          notification: function(type) {
            const t = type || 'success';
            if (window.Capacitor && window.Capacitor.Plugins && window.Capacitor.Plugins.Haptics) {
              window.Capacitor.Plugins.Haptics.notification({ type: t.toUpperCase() });
            } else if (typeof navigator !== 'undefined' && navigator.vibrate) {
              navigator.vibrate([20, 40, 20]);
            } else {
              console.log('[BVMobile] Haptics.notification simulation (' + t + ')');
            }
          }
        },

        geolocation: {
          getCurrentPosition: function(onSuccess, onError) {
            if (window.Capacitor && window.Capacitor.Plugins && window.Capacitor.Plugins.Geolocation) {
              window.Capacitor.Plugins.Geolocation.getCurrentPosition()
                .then(function(pos) {
                  if (typeof onSuccess === 'function') onSuccess(pos);
                })
                .catch(function(err) {
                  if (typeof onError === 'function') onError(err);
                });
            } else if (typeof navigator !== 'undefined' && navigator.geolocation) {
              navigator.geolocation.getCurrentPosition(
                function(pos) {
                  const coords = {
                    coords: {
                      latitude: pos.coords.latitude,
                      longitude: pos.coords.longitude,
                      accuracy: pos.coords.accuracy,
                      altitude: pos.coords.altitude
                    },
                    timestamp: pos.timestamp
                  };
                  if (typeof onSuccess === 'function') onSuccess(coords);
                },
                function(err) {
                  if (typeof onError === 'function') onError(err);
                }
              );
            } else {
              if (typeof onError === 'function') onError(new Error('Geolocation not supported'));
            }
          }
        },

        camera: {
          takePhoto: function(onSuccess, onError) {
            if (window.Capacitor && window.Capacitor.Plugins && window.Capacitor.Plugins.Camera) {
              window.Capacitor.Plugins.Camera.getPhoto({
                quality: 90,
                allowEditing: false,
                resultType: 'dataUrl'
              })
              .then(function(img) {
                if (typeof onSuccess === 'function') onSuccess(img.dataUrl);
              })
              .catch(function(err) {
                if (typeof onError === 'function') onError(err);
              });
            } else if (typeof document !== 'undefined') {
              // Web Camera Fallback using file input
              let fileInput = document.getElementById('__bv_camera_input__');
              if (!fileInput) {
                fileInput = document.createElement('input');
                fileInput.id = '__bv_camera_input__';
                fileInput.type = 'file';
                fileInput.accept = 'image/*';
                fileInput.capture = 'environment';
                fileInput.style.display = 'none';
                document.body.appendChild(fileInput);
              }
              fileInput.onchange = function(e) {
                const file = e.target.files && e.target.files[0];
                if (file) {
                  const reader = new FileReader();
                  reader.onload = function(re) {
                    if (typeof onSuccess === 'function') onSuccess(re.target.result);
                  };
                  reader.readAsDataURL(file);
                }
              };
              fileInput.click();
            } else {
              if (typeof onError === 'function') onError(new Error('Camera not supported'));
            }
          }
        },

        device: {
          getInfo: function(onSuccess) {
            if (window.Capacitor && window.Capacitor.Plugins && window.Capacitor.Plugins.Device) {
              window.Capacitor.Plugins.Device.getInfo().then(function(info) {
                if (typeof onSuccess === 'function') onSuccess(info);
              });
            } else {
              const info = {
                model: 'Browser Client',
                platform: mobileBridge.getPlatform(),
                operatingSystem: navigator.platform || 'web',
                osVersion: navigator.userAgent || 'unknown',
                manufacturer: 'Standard Hardware',
                isVirtual: false
              };
              if (typeof onSuccess === 'function') onSuccess(info);
            }
          }
        },

        statusBar: {
          setBackgroundColor: function(colorHex) {
            if (window.Capacitor && window.Capacitor.Plugins && window.Capacitor.Plugins.StatusBar) {
              window.Capacitor.Plugins.StatusBar.setBackgroundColor({ color: colorHex });
            } else {
              console.log('[BVMobile] StatusBar color: ' + colorHex);
            }
          }
        }
      };

      bv.mobile = mobileBridge;
      window.$mobile = mobileBridge;
    }
  end;

end.
