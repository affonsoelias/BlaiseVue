unit BVTheme;

{
  BVTheme - Integrated Reactive Theme Manager (BlaiseVue 2.6)
  -----------------------------------------------------------
  Provides reactive theme switching ($theme), Bootswatch support,
  dark/light mode toggling, dynamic DOM stylesheet updating (<link id="bv-theme">),
  and automatic localStorage persistence.
}

{$mode objfpc}

interface

uses JS, Web, SysUtils, BVReactivity;

type
  { TBVTheme: Global Reactive Theme Controller }
  TBVTheme = class
  public
    class procedure Init(const DefaultTheme: string = 'flatly');
    class procedure SetTheme(const ATheme: string);
    class function GetTheme: string;
    class procedure ToggleDarkLight;
    class function IsDark: Boolean;
  end;

implementation

class procedure TBVTheme.Init(const DefaultTheme: string);
begin
  asm
    let th = window.__BV_CORE__.theme;
    if (th) th.init(DefaultTheme || 'flatly');
  end;
end;

class procedure TBVTheme.SetTheme(const ATheme: string);
begin
  asm
    let th = window.__BV_CORE__.theme;
    if (th) th.setTheme(ATheme);
  end;
end;

class function TBVTheme.GetTheme: string;
var
  ResVal: JSValue;
begin
  asm
    let th = window.__BV_CORE__.theme;
    ResVal = th ? th.getTheme() : 'flatly';
  end;
  Result := String(ResVal);
end;

class procedure TBVTheme.ToggleDarkLight;
begin
  asm
    let th = window.__BV_CORE__.theme;
    if (th) th.toggleDarkLight();
  end;
end;

class function TBVTheme.IsDark: Boolean;
var
  ResVal: Boolean;
begin
  asm
    let th = window.__BV_CORE__.theme;
    ResVal = th ? th.isDarkTheme() : false;
  end;
  Result := ResVal;
end;

initialization
  asm
    if (!window.__BV_CORE__) window.__BV_CORE__ = {};
    const bv = window.__BV_CORE__;

    // Dark themes list for auto-detection of isDark
    const darkThemes = ['darkly', 'cyborg', 'solar', 'vapor'];

    // Reactive state for theme tracking
    const themeState = bv.defineReactive ? 
      bv.defineReactive({ current: 'flatly', isDark: false }) : 
      { current: 'flatly', isDark: false };

    function applyThemeDOM(themeName) {
      if (typeof document === 'undefined') return;
      let link = document.getElementById('bv-theme');
      if (!link) {
        link = document.createElement('link');
        link.id = 'bv-theme';
        link.rel = 'stylesheet';
        if (document.head) document.head.appendChild(link);
      }
      link.href = 'lib/themes/' + themeName + '.min.css';

      const isD = darkThemes.indexOf(themeName.toLowerCase()) >= 0;
      themeState.isDark = isD;

      if (document.documentElement) {
        document.documentElement.setAttribute('data-bs-theme', isD ? 'dark' : 'light');
        if (isD) {
          document.documentElement.classList.add('theme-dark');
          document.documentElement.classList.remove('theme-light');
        } else {
          document.documentElement.classList.add('theme-light');
          document.documentElement.classList.remove('theme-dark');
        }
      }

      try {
        if (window.localStorage) {
          window.localStorage.setItem('bv_theme', themeName);
        }
      } catch(e) {}
    }

    const theme = {
      state: themeState,
      darkThemes: darkThemes,
      available: ['flatly', 'darkly', 'cosmo', 'cyborg', 'lux', 'pulse', 'solar', 'vapor', 'zephyr'],

      setTheme: function(name) {
        if (!name) return;
        const lower = String(name).toLowerCase().trim();
        themeState.current = lower;
        themeState.isDark = (darkThemes.indexOf(lower) >= 0);
        applyThemeDOM(lower);
        if (bv.trigger) {
          bv.trigger(themeState, 'current');
          bv.trigger(themeState, 'isDark');
          bv.trigger(theme, 'current');
          bv.trigger(theme, 'isDark');
        }
      },

      getTheme: function() {
        return themeState.current;
      },

      isDarkTheme: function() {
        return !!themeState.isDark;
      },

      toggleDarkLight: function() {
        if (themeState.isDark) {
          theme.setTheme('flatly');
        } else {
          theme.setTheme('darkly');
        }
      },

      toggle: function() {
        theme.toggleDarkLight();
      },

      init: function(defaultTheme) {
        let saved = null;
        try {
          if (typeof window !== 'undefined' && window.localStorage) {
            saved = window.localStorage.getItem('bv_theme');
          }
        } catch(e) {}
        const initial = saved || defaultTheme || 'flatly';
        theme.setTheme(initial);
      }
    };

    Object.defineProperty(theme, 'current', {
      get: function() { return themeState.current; },
      set: function(v) { theme.setTheme(v); },
      enumerable: true,
      configurable: true
    });

    Object.defineProperty(theme, 'isDark', {
      get: function() { return themeState.isDark; },
      enumerable: true,
      configurable: true
    });

    bv.theme = theme;
    if (typeof window !== 'undefined') {
      window.$theme = theme;
    }
  end;

end.
