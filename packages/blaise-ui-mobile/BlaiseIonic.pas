unit BlaiseIonic;

{
  BlaiseIonic - BlaiseVue 4.0 Mobile-First Ionic Ecosystem
  --------------------------------------------------------
  Provides strongly typed Object Pascal wrappers and controllers for
  Ionic Web Components and mobile-native UI elements:
  - TIonicToast: Animated floating or bottom toasts
  - TIonicAlert: Native iOS/Android dialogs (alert, confirm, prompt)
  - TIonicLoading: Fullscreen modal loader with animated spinner
  - TIonicActionSheet: Bottom action sheet with option callbacks
  - TIonicController: Adaptive platform switching (iOS Cupertino vs Android Material Design)
}

{$mode objfpc}

interface

uses JS, Web, SysUtils, BVReactivity;

type
  { TIonicToast: Mobile Toast Notification Controller }
  TIonicToast = class
  public
    class procedure Show(const Message: string; DurationMs: Integer = 2000; const Position: string = 'bottom'; const Color: string = 'dark');
    class procedure Dismiss;
  end;

  { TIonicAlert: Mobile Alert, Confirm and Prompt Dialog Controller }
  TIonicAlert = class
  public
    class procedure Alert(const Title, Message: string; const ButtonText: string = 'OK');
    class procedure Confirm(const Title, Message: string; OnConfirm: JSValue = nil; OnCancel: JSValue = nil);
    class procedure Prompt(const Title, Message, Placeholder: string; OnSubmit: JSValue = nil);
    class procedure Dismiss;
  end;

  { TIonicLoading: Mobile Fullscreen Loading Overlay Controller }
  TIonicLoading = class
  public
    class procedure Present(const Message: string = 'Loading...'; DurationMs: Integer = 0);
    class procedure Dismiss;
    class function IsLoading: Boolean;
  end;

  { TIonicActionSheet: Mobile Bottom Action Sheet Controller }
  TIonicActionSheet = class
  public
    class procedure Show(const Title: string; Options: array of string; OnSelect: JSValue = nil); overload;
    class procedure Show(const Title: string; Options: TJSArray; OnSelect: JSValue = nil); overload;
    class procedure Dismiss;
  end;

  { TIonicController: High-Level Ionic & Platform Configuration }
  TIonicController = class
  public
    class function GetMode: string;
    class procedure SetMode(const AMode: string);
    class function IsIos: Boolean;
    class function IsAndroid: Boolean;
    class procedure EnsureBridge;
  end;

implementation

{ TIonicToast Implementation }

class procedure TIonicToast.Show(const Message: string; DurationMs: Integer; const Position: string; const Color: string);
begin
  asm
    let ionic = window.__BV_CORE__.ionic;
    if (ionic && ionic.toast) {
      ionic.toast.show(Message, DurationMs, Position, Color);
    }
  end;
end;

class procedure TIonicToast.Dismiss;
begin
  asm
    let ionic = window.__BV_CORE__.ionic;
    if (ionic && ionic.toast) {
      ionic.toast.dismiss();
    }
  end;
end;

{ TIonicAlert Implementation }

class procedure TIonicAlert.Alert(const Title, Message: string; const ButtonText: string);
begin
  asm
    let ionic = window.__BV_CORE__.ionic;
    if (ionic && ionic.alert) {
      ionic.alert.alert(Title, Message, ButtonText);
    }
  end;
end;

class procedure TIonicAlert.Confirm(const Title, Message: string; OnConfirm: JSValue; OnCancel: JSValue);
begin
  asm
    let ionic = window.__BV_CORE__.ionic;
    if (ionic && ionic.alert) {
      ionic.alert.confirm(Title, Message, OnConfirm, OnCancel);
    }
  end;
end;

class procedure TIonicAlert.Prompt(const Title, Message, Placeholder: string; OnSubmit: JSValue);
begin
  asm
    let ionic = window.__BV_CORE__.ionic;
    if (ionic && ionic.alert) {
      ionic.alert.prompt(Title, Message, Placeholder, OnSubmit);
    }
  end;
end;

class procedure TIonicAlert.Dismiss;
begin
  asm
    let ionic = window.__BV_CORE__.ionic;
    if (ionic && ionic.alert) {
      ionic.alert.dismiss();
    }
  end;
end;

{ TIonicLoading Implementation }

class procedure TIonicLoading.Present(const Message: string; DurationMs: Integer);
begin
  asm
    let ionic = window.__BV_CORE__.ionic;
    if (ionic && ionic.loading) {
      ionic.loading.present(Message, DurationMs);
    }
  end;
end;

class procedure TIonicLoading.Dismiss;
begin
  asm
    let ionic = window.__BV_CORE__.ionic;
    if (ionic && ionic.loading) {
      ionic.loading.dismiss();
    }
  end;
end;

class function TIonicLoading.IsLoading: Boolean;
var
  ResVal: JSValue;
begin
  asm
    let ionic = window.__BV_CORE__.ionic;
    ResVal = (ionic && ionic.loading) ? ionic.loading.isLoading() : false;
  end;
  Result := Boolean(ResVal);
end;

{ TIonicActionSheet Implementation }

class procedure TIonicActionSheet.Show(const Title: string; Options: array of string; OnSelect: JSValue);
var
  Arr: TJSArray;
  i: Integer;
begin
  Arr := TJSArray.new;
  for i := Low(Options) to High(Options) do
    Arr.push(Options[i]);
  Show(Title, Arr, OnSelect);
end;

class procedure TIonicActionSheet.Show(const Title: string; Options: TJSArray; OnSelect: JSValue);
begin
  asm
    let ionic = window.__BV_CORE__.ionic;
    if (ionic && ionic.actionSheet) {
      ionic.actionSheet.show(Title, Options, OnSelect);
    }
  end;
end;

class procedure TIonicActionSheet.Dismiss;
begin
  asm
    let ionic = window.__BV_CORE__.ionic;
    if (ionic && ionic.actionSheet) {
      ionic.actionSheet.dismiss();
    }
  end;
end;

{ TIonicController Implementation }

class function TIonicController.GetMode: string;
var
  ResVal: JSValue;
begin
  asm
    let ionic = window.__BV_CORE__.ionic;
    ResVal = ionic ? ionic.getMode() : 'md';
  end;
  Result := String(ResVal);
end;

class procedure TIonicController.SetMode(const AMode: string);
begin
  asm
    let ionic = window.__BV_CORE__.ionic;
    if (ionic) ionic.setMode(AMode);
  end;
end;

class function TIonicController.IsIos: Boolean;
begin
  Result := (GetMode = 'ios');
end;

class function TIonicController.IsAndroid: Boolean;
begin
  Result := (GetMode = 'md');
end;

class procedure TIonicController.EnsureBridge;
begin
  asm
    if (!window.__BV_CORE__) window.__BV_CORE__ = {};
    if (!window.__BV_CORE__.ionic) {
      let activeMode = 'md';
      // Detect platform
      if (typeof navigator !== 'undefined' && /iPhone|iPad|iPod|Macintosh/i.test(navigator.userAgent || '')) {
        activeMode = 'ios';
      }

      let activeToastTimer = null;
      let activeLoadingCount = 0;

      const ionicBridge = {
        getMode: function() {
          return activeMode;
        },
        setMode: function(m) {
          activeMode = (m === 'ios') ? 'ios' : 'md';
          if (typeof document !== 'undefined' && document.documentElement) {
            document.documentElement.setAttribute('mode', activeMode);
            if (activeMode === 'ios') {
              document.documentElement.classList.add('ionic-mode-ios');
              document.documentElement.classList.remove('ionic-mode-md');
            } else {
              document.documentElement.classList.add('ionic-mode-md');
              document.documentElement.classList.remove('ionic-mode-ios');
            }
          }
        },
        get isIos() {
          return activeMode === 'ios';
        },
        get isAndroid() {
          return activeMode === 'md';
        },

        // Toast controller
        toast: {
          show: function(msg, duration, pos, color) {
            this.dismiss();
            duration = (typeof duration === 'number') ? duration : 2000;
            pos = pos || 'bottom';
            color = color || 'dark';

            if (typeof document === 'undefined') return;

            let el = document.createElement('div');
            el.className = 'ionic-toast-wrapper ionic-toast-' + pos + ' ionic-toast-' + color;
            el.setAttribute('role', 'alert');
            el.innerHTML = '<div class="ionic-toast-message">' + msg + '</div>';

            document.body.appendChild(el);

            if (duration > 0) {
              activeToastTimer = setTimeout(() => {
                this.dismiss();
              }, duration);
            }
          },
          dismiss: function() {
            if (activeToastTimer) {
              clearTimeout(activeToastTimer);
              activeToastTimer = null;
            }
            if (typeof document !== 'undefined') {
              let existing = document.querySelectorAll('.ionic-toast-wrapper');
              for (let i = 0; i < existing.length; i++) {
                existing[i].remove();
              }
            }
          }
        },

        // Alert controller
        alert: {
          alert: function(title, msg, btnText) {
            this.dismiss();
            btnText = btnText || 'OK';
            if (typeof document === 'undefined') return;

            let backdrop = document.createElement('div');
            backdrop.className = 'ionic-alert-backdrop';

            let wrapper = document.createElement('div');
            wrapper.className = 'ionic-alert-wrapper mode-' + activeMode;
            wrapper.innerHTML = 
              '<div class="ionic-alert-head">' +
                '<h2 class="ionic-alert-title">' + title + '</h2>' +
                '<div class="ionic-alert-sub-title">' + (msg || '') + '</div>' +
              '</div>' +
              '<div class="ionic-alert-button-group">' +
                '<button type="button" class="ionic-alert-button bui-btn-ok">' + btnText + '</button>' +
              '</div>';

            backdrop.appendChild(wrapper);
            document.body.appendChild(backdrop);

            let okBtn = wrapper.querySelector('.bui-btn-ok');
            if (okBtn) {
              okBtn.addEventListener('click', () => {
                this.dismiss();
              });
            }
          },
          confirm: function(title, msg, onConfirm, onCancel) {
            this.dismiss();
            if (typeof document === 'undefined') return;

            let backdrop = document.createElement('div');
            backdrop.className = 'ionic-alert-backdrop';

            let wrapper = document.createElement('div');
            wrapper.className = 'ionic-alert-wrapper mode-' + activeMode;
            wrapper.innerHTML = 
              '<div class="ionic-alert-head">' +
                '<h2 class="ionic-alert-title">' + title + '</h2>' +
                '<div class="ionic-alert-sub-title">' + (msg || '') + '</div>' +
              '</div>' +
              '<div class="ionic-alert-button-group">' +
                '<button type="button" class="ionic-alert-button bui-btn-cancel">Cancel</button>' +
                '<button type="button" class="ionic-alert-button bui-btn-confirm">Confirm</button>' +
              '</div>';

            backdrop.appendChild(wrapper);
            document.body.appendChild(backdrop);

            let cancelBtn = wrapper.querySelector('.bui-btn-cancel');
            let confirmBtn = wrapper.querySelector('.bui-btn-confirm');

            if (cancelBtn) {
              cancelBtn.addEventListener('click', () => {
                this.dismiss();
                if (typeof onCancel === 'function') onCancel();
              });
            }
            if (confirmBtn) {
              confirmBtn.addEventListener('click', () => {
                this.dismiss();
                if (typeof onConfirm === 'function') onConfirm();
              });
            }
          },
          prompt: function(title, msg, placeholder, onSubmit) {
            this.dismiss();
            placeholder = placeholder || '';
            if (typeof document === 'undefined') return;

            let backdrop = document.createElement('div');
            backdrop.className = 'ionic-alert-backdrop';

            let wrapper = document.createElement('div');
            wrapper.className = 'ionic-alert-wrapper mode-' + activeMode;
            wrapper.innerHTML = 
              '<div class="ionic-alert-head">' +
                '<h2 class="ionic-alert-title">' + title + '</h2>' +
                '<div class="ionic-alert-sub-title">' + (msg || '') + '</div>' +
              '</div>' +
              '<div class="ionic-alert-input-group">' +
                '<input type="text" class="ionic-alert-input" placeholder="' + placeholder + '">' +
              '</div>' +
              '<div class="ionic-alert-button-group">' +
                '<button type="button" class="ionic-alert-button bui-btn-cancel">Cancel</button>' +
                '<button type="button" class="ionic-alert-button bui-btn-submit">Submit</button>' +
              '</div>';

            backdrop.appendChild(wrapper);
            document.body.appendChild(backdrop);

            let cancelBtn = wrapper.querySelector('.bui-btn-cancel');
            let submitBtn = wrapper.querySelector('.bui-btn-submit');
            let inputEl = wrapper.querySelector('.ionic-alert-input');

            if (cancelBtn) {
              cancelBtn.addEventListener('click', () => {
                this.dismiss();
              });
            }
            if (submitBtn) {
              submitBtn.addEventListener('click', () => {
                let val = inputEl ? inputEl.value : '';
                this.dismiss();
                if (typeof onSubmit === 'function') onSubmit(val);
              });
            }
          },
          dismiss: function() {
            if (typeof document !== 'undefined') {
              let existing = document.querySelectorAll('.ionic-alert-backdrop');
              for (let i = 0; i < existing.length; i++) {
                existing[i].remove();
              }
            }
          }
        },

        // Loading controller
        loading: {
          present: function(msg, duration) {
            this.dismiss();
            msg = msg || 'Loading...';
            activeLoadingCount = 1;

            if (typeof document === 'undefined') return;

            let backdrop = document.createElement('div');
            backdrop.className = 'ionic-loading-backdrop';

            let box = document.createElement('div');
            box.className = 'ionic-loading-box mode-' + activeMode;
            box.innerHTML = 
              '<div class="ionic-loading-spinner"></div>' +
              '<div class="ionic-loading-content">' + msg + '</div>';

            backdrop.appendChild(box);
            document.body.appendChild(backdrop);

            if (duration && duration > 0) {
              setTimeout(() => {
                this.dismiss();
              }, duration);
            }
          },
          dismiss: function() {
            activeLoadingCount = 0;
            if (typeof document !== 'undefined') {
              let existing = document.querySelectorAll('.ionic-loading-backdrop');
              for (let i = 0; i < existing.length; i++) {
                existing[i].remove();
              }
            }
          },
          isLoading: function() {
            if (typeof document !== 'undefined') {
              return Boolean(document.querySelector('.ionic-loading-backdrop'));
            }
            return activeLoadingCount > 0;
          }
        },

        // ActionSheet controller
        actionSheet: {
          show: function(title, options, onSelect) {
            this.dismiss();
            if (typeof document === 'undefined') return;

            let backdrop = document.createElement('div');
            backdrop.className = 'ionic-action-sheet-backdrop';

            let wrapper = document.createElement('div');
            wrapper.className = 'ionic-action-sheet-wrapper mode-' + activeMode;

            let headHtml = title ? ('<div class="ionic-action-sheet-title">' + title + '</div>') : '';
            let btnListHtml = '';
            let optArray = Array.isArray(options) ? options : [];
            for (let i = 0; i < optArray.length; i++) {
              btnListHtml += '<button type="button" class="ionic-action-sheet-button" data-index="' + i + '">' + optArray[i] + '</button>';
            }

            wrapper.innerHTML = 
              '<div class="ionic-action-sheet-group">' +
                headHtml +
                btnListHtml +
              '</div>' +
              '<div class="ionic-action-sheet-group ionic-action-sheet-cancel-group">' +
                '<button type="button" class="ionic-action-sheet-button bui-btn-cancel">Cancel</button>' +
              '</div>';

            backdrop.appendChild(wrapper);
            document.body.appendChild(backdrop);

            // Wire option buttons
            let btns = wrapper.querySelectorAll('.ionic-action-sheet-button[data-index]');
            for (let j = 0; j < btns.length; j++) {
              btns[j].addEventListener('click', function(ev) {
                let idx = parseInt(this.getAttribute('data-index'), 10);
                let selectedVal = optArray[idx];
                ionicBridge.actionSheet.dismiss();
                if (typeof onSelect === 'function') {
                  onSelect(selectedVal, idx);
                }
              });
            }

            // Wire cancel button
            let cancelBtn = wrapper.querySelector('.bui-btn-cancel');
            if (cancelBtn) {
              cancelBtn.addEventListener('click', () => {
                this.dismiss();
              });
            }

            // Backdrop click dismiss
            backdrop.addEventListener('click', function(ev) {
              if (ev.target === backdrop) {
                ionicBridge.actionSheet.dismiss();
              }
            });
          },
          dismiss: function() {
            if (typeof document !== 'undefined') {
              let existing = document.querySelectorAll('.ionic-action-sheet-backdrop');
              for (let i = 0; i < existing.length; i++) {
                existing[i].remove();
              }
            }
          }
        }
      };

      // Set initial HTML mode attribute
      ionicBridge.setMode(activeMode);

      // Attach PascalCase aliases
      ionicBridge.toast.Show = ionicBridge.toast.show;
      ionicBridge.toast.Dismiss = ionicBridge.toast.dismiss;

      ionicBridge.alert.Alert = ionicBridge.alert.alert;
      ionicBridge.alert.Confirm = ionicBridge.alert.confirm;
      ionicBridge.alert.Prompt = ionicBridge.alert.prompt;
      ionicBridge.alert.Dismiss = ionicBridge.alert.dismiss;

      ionicBridge.loading.Present = ionicBridge.loading.present;
      ionicBridge.loading.Dismiss = ionicBridge.loading.dismiss;
      ionicBridge.loading.IsLoading = ionicBridge.loading.isLoading;

      ionicBridge.actionSheet.Show = ionicBridge.actionSheet.show;
      ionicBridge.actionSheet.Dismiss = ionicBridge.actionSheet.dismiss;

      ionicBridge.GetMode = ionicBridge.getMode;
      ionicBridge.SetMode = ionicBridge.setMode;
      ionicBridge.IsIos = function() { return ionicBridge.getMode() === 'ios'; };
      ionicBridge.IsAndroid = function() { return ionicBridge.getMode() === 'md'; };

      window.__BV_CORE__.ionic = ionicBridge;
      window.$ionic = ionicBridge;

      // Global window controllers
      window.TIonicToast = ionicBridge.toast;
      window.TIonicAlert = ionicBridge.alert;
      window.TIonicLoading = ionicBridge.loading;
      window.TIonicActionSheet = ionicBridge.actionSheet;
      window.TIonicController = ionicBridge;

      // Safe pas.BlaiseIonic registration for runtime interop
      if (typeof window.pas === 'undefined') window.pas = {};
      if (!window.pas.BlaiseIonic) window.pas.BlaiseIonic = {};
      window.pas.BlaiseIonic.TIonicToast = ionicBridge.toast;
      window.pas.BlaiseIonic.TIonicAlert = ionicBridge.alert;
      window.pas.BlaiseIonic.TIonicLoading = ionicBridge.loading;
      window.pas.BlaiseIonic.TIonicActionSheet = ionicBridge.actionSheet;
      window.pas.BlaiseIonic.TIonicController = ionicBridge;
    }
  end;
end;

initialization
  TIonicController.EnsureBridge;
end.
