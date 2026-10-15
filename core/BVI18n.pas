unit BVI18n;

{
  BVI18n - Integrated Internationalization (BlaiseVue 2.5)
  --------------------------------------------------------
  Provides reactive multi-locale translation ($t), dynamic runtime
  language switching, nested dictionary lookup, and token interpolation.
}

{$mode objfpc}

interface

uses JS, Web, SysUtils, BVReactivity;

type
  { TBVI18n: Global Internationalization Controller }
  TBVI18n = class
  public
    class procedure Init(const DefaultLocale: string = 'en'; const FallbackLocale: string = 'en');
    class procedure SetLocale(const ALocale: string);
    class function GetLocale: string;
    class procedure AddMessages(const ALocale: string; AMessages: JSValue);
    class function T(const Key: string; Params: JSValue = nil): string;
    class function Has(const Key: string; const ALocale: string = ''): Boolean;
  end;

implementation

class procedure TBVI18n.Init(const DefaultLocale: string; const FallbackLocale: string);
begin
  asm
    let i18n = window.__BV_CORE__.i18n;
    if (!i18n) return;
    i18n.fallbackLocale = FallbackLocale || 'en';
    i18n.state.locale = DefaultLocale || 'en';
  end;
end;

class procedure TBVI18n.SetLocale(const ALocale: string);
begin
  asm
    let i18n = window.__BV_CORE__.i18n;
    if (i18n) i18n.setLocale(ALocale);
  end;
end;

class function TBVI18n.GetLocale: string;
var
  LocStr: JSValue;
begin
  asm
    let i18n = window.__BV_CORE__.i18n;
    LocStr = i18n ? i18n.getLocale() : 'en';
  end;
  Result := String(LocStr);
end;

class procedure TBVI18n.AddMessages(const ALocale: string; AMessages: JSValue);
begin
  asm
    let i18n = window.__BV_CORE__.i18n;
    if (i18n) i18n.addMessages(ALocale, AMessages);
  end;
end;

class function TBVI18n.T(const Key: string; Params: JSValue): string;
var
  ResVal: JSValue;
begin
  asm
    let i18n = window.__BV_CORE__.i18n;
    ResVal = i18n ? i18n.translate(Key, Params) : Key;
  end;
  Result := String(ResVal);
end;

class function TBVI18n.Has(const Key: string; const ALocale: string): Boolean;
var
  ResVal: Boolean;
begin
  asm
    let i18n = window.__BV_CORE__.i18n;
    ResVal = i18n ? i18n.has(Key, ALocale) : false;
  end;
  Result := ResVal;
end;

initialization
  asm
    if (!window.__BV_CORE__) window.__BV_CORE__ = {};
    const bv = window.__BV_CORE__;

    // Reactive State for locale tracking
    const i18nState = bv.defineReactive ? bv.defineReactive({ locale: 'en' }) : { locale: 'en' };

    const i18n = {
      state: i18nState,
      fallbackLocale: 'en',
      messages: {},

      setLocale: function(loc) {
        if (!loc) return;
        i18n.state.locale = String(loc);
        if (bv.trigger) {
          bv.trigger(i18n.state, 'locale');
          bv.trigger(i18n, 'locale');
        }
      },

      getLocale: function() {
        return i18n.state.locale;
      },

      addMessages: function(loc, msgs) {
        if (!i18n.messages[loc]) i18n.messages[loc] = {};
        i18n.mergeDeep(i18n.messages[loc], msgs);
      },

      mergeDeep: function(target, source) {
        if (!source || typeof source !== 'object') return target;
        Object.keys(source).forEach(function(k) {
          if (source[k] && typeof source[k] === 'object' && !Array.isArray(source[k])) {
            if (!target[k]) target[k] = {};
            i18n.mergeDeep(target[k], source[k]);
          } else {
            target[k] = source[k];
          }
        });
        return target;
      },

      resolvePath: function(obj, path) {
        if (!obj || !path) return undefined;
        let parts = path.split('.');
        let curr = obj;
        for (let i = 0; i < parts.length; i++) {
          if (curr === null || curr === undefined) return undefined;
          curr = curr[parts[i]];
        }
        return curr;
      },

      has: function(key, loc) {
        let l = loc || i18n.state.locale;
        let dict = i18n.messages[l];
        return (i18n.resolvePath(dict, key) !== undefined);
      },

      interpolate: function(tmpl, params) {
        if (typeof tmpl !== 'string') return String(tmpl);
        if (!params) return tmpl;
        return tmpl.replace(/\{(\w+)\}/g, function(match, paramKey) {
          if (params[paramKey] !== undefined) return String(params[paramKey]);
          return match;
        });
      },

      translate: function(key, params) {
        // Read reactive locale to trigger dependency tracking in active effect
        let currentLoc = i18n.state.locale;
        let dict = i18n.messages[currentLoc];
        let val = i18n.resolvePath(dict, key);

        if (val === undefined && i18n.fallbackLocale && i18n.fallbackLocale !== currentLoc) {
          let fbDict = i18n.messages[i18n.fallbackLocale];
          val = i18n.resolvePath(fbDict, key);
        }

        if (val === undefined) {
          return key;
        }

        return i18n.interpolate(val, params);
      }
    };

    Object.defineProperty(i18n, 'locale', {
      get: function() { return i18n.state.locale; },
      set: function(v) { i18n.setLocale(v); },
      enumerable: true,
      configurable: true
    });

    bv.i18n = i18n;
    bv.t = function(key, params) {
      return i18n.translate(key, params);
    };
  end;

end.
