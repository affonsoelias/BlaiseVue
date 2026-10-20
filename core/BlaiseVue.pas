unit BlaiseVue;

{
  BlaiseVue - Core Framework Entry Point
  --------------------------------------
  Main class for initializing a BlaiseVue application. 
  Responsible for mounting the app, setting up reactivity,
  injecting styles, and integrating the Router.
}

{$mode objfpc}

interface

uses JS, Web, SysUtils, BVReactivity, BVCompiler, BVRouting, BVComponents, BVValidation, BVI18n, BVTheme, BVWasm, BVMobile, BVDesktop, BVClient, BVAuth;

type
  { 
    TBlaiseVue: The main application controller.
    Manages the root element, global reactive data, methods, and routing.
  }
  TBlaiseVue = class
  private
    FRoot: TJSHTMLElement;   { The DOM element where the app is mounted (e.g. '#app') }
    FData: TBlaiseData;      { Global reactive storage (Proxied data) }
    FMethods: JSValue;       { Global methods accessible by the compiler }
    FRouter: TBVRouter;      { Optional Router instance for SPA navigation }
    procedure InjectStyles;  { Internal helper to inject framework-level CSS (e.g. fade transitions) }
  public
    { Standard constructor using explicit element ID and JS values }
    constructor Create(AEl: string; AData, AMethods, AOptions: JSValue); overload;
    
    { Advanced constructor using a single Options object (Vue-style) }
    constructor Create(Options: JSValue); overload;
    
    { Installs a global plugin }
    class procedure Use(APlugin: JSValue; AOptions: JSValue = nil);
    
    { Registers a global mixin for all components }
    class procedure Mixin(AMixin: JSValue);
    
    { Attaches a router to the application and triggers initial routing }
    procedure UseRouter(ARouter: TBVRouter);
    
    { Low-level method to trigger template compilation on a specific root }
    procedure Compile(ARoot: JSValue; AData: TBlaiseData; AMethods: JSValue);
    
    property Data: TBlaiseData read FData;
    property Router: TBVRouter read FRouter;
  end;

implementation

{ TBlaiseVue.Create (Legacy/Explicit) }
constructor TBlaiseVue.Create(AEl: string; AData, AMethods, AOptions: JSValue);
var
  opts: JSValue;
begin
  asm
    opts = AOptions || {};
    opts.el = AEl;
    opts.data = AData;
    opts.methods = AMethods;
  end;
  Self.Create(opts);
end;

{ TBlaiseVue.Create (Canonical/Options object) }
constructor TBlaiseVue.Create(Options: JSValue);
var
  AData, AMethods, AComputed, JS_rootID: JSValue;
  rootID: string;
  d, m, c: JSValue;
begin
  asm
    console.log("[Init] Initing App with Global Mixins...");
    // Apply global mixins to the root instance options
    if (window.__BV_CORE__.mixins && window.__BV_CORE__.mixins.length > 0) {
      window.__BV_CORE__.mixins.forEach(function(mix) {
        Options = window.__BV_CORE__.mergeOptions(Options, mix);
      });
    }
  end;

  InjectStyles;
  
  asm
    JS_rootID = Options.el || '#app';
    AData = Options.data || {};
    AMethods = Options.methods || null;
    AComputed = Options.computed || null;
  end;
  
  rootID := string(JS_rootID);
  FRoot := TJSHTMLElement(document.querySelector(rootID));

  { Create the main reactivity bridge }
  FData := TBlaiseData.Create(AData);
  FMethods := AMethods;
  
  d := FData;
  m := AMethods;
  c := AComputed;
  
  { Register app globally in the JS bridge (__BV_CORE__) }
  asm window.__BV_CORE__.initApp(d, m, c); end;
  asm window.__BV_CORE__.rootData = d.FData; end;
  
  { Bridge for Pro Features (Global Store integration) }
  asm
    if (window.__BV_PRO_STORE__) d.FData.$store = window.__BV_PRO_STORE__;
    if (window.__BV_CORE__.theme && !d.FData.$theme) d.FData.$theme = window.__BV_CORE__.theme;
    if (window.__BV_CORE__.wasm && !d.FData.$wasm) d.FData.$wasm = window.__BV_CORE__.wasm;
    if (window.__BV_CORE__.mobile && !d.FData.$mobile) d.FData.$mobile = window.__BV_CORE__.mobile;
    if (window.__BV_CORE__.desktop && !d.FData.$desktop) d.FData.$desktop = window.__BV_CORE__.desktop;
    if (window.__BV_CORE__.api && !d.FData.$api) d.FData.$api = window.__BV_CORE__.api;
    if (window.__BV_CORE__.ws && !d.FData.$ws) d.FData.$ws = window.__BV_CORE__.ws;
    if (window.__BV_CORE__.auth && !d.FData.$auth) d.FData.$auth = window.__BV_CORE__.auth;
    
    // Check for SSG Pre-rendered content for instant zero-flicker Hydration
    if (this.FRoot && (this.FRoot.hasAttribute('data-bv-ssg') || this.FRoot.querySelector('[data-bv-ssg]'))) {
      console.log("[Hydration] SSG pre-rendered content detected on " + rootID + ". Engaging Reactive Hydration...");
      this.FRoot.setAttribute('data-bv-hydrated', 'true');
    }
  end;

  asm
    // Initialize i18n configuration if passed in root options
    if (Options.i18n && window.__BV_CORE__.i18n) {
      if (Options.i18n.locale) window.__BV_CORE__.i18n.setLocale(Options.i18n.locale);
      if (Options.i18n.fallbackLocale) window.__BV_CORE__.i18n.fallbackLocale = Options.i18n.fallbackLocale;
      if (Options.i18n.messages) {
        Object.keys(Options.i18n.messages).forEach(function(l) {
          window.__BV_CORE__.i18n.addMessages(l, Options.i18n.messages[l]);
        });
      }
    }
    // Handle Provide/Inject dependency injection
    if (Options.provide) {
      d.FData.$provided = Options.provide.call(d.FData, d.FData);
    }
    // Execute 'created' lifecycle hook
    if (Options.created) {
      Options.created.call(d.FData, d.FData);
    }
  end;
  
  { If no router is detected after a short delay (allowing for .UseRouter calls), 
    we must compile the root template manually. }
  asm
    setTimeout(() => {
      if (!this.FRouter) {
        console.log("[Create] No router detected. Auto-compiling root...");
        window.__BV_CORE__.compile(this.FRoot, this.FData, this.FMethods);
      }
    }, 0);
  end;
    
  asm console.log("[Create] Instance ready."); end;
end;

{ Injects core framework CSS into the document head }
procedure TBlaiseVue.InjectStyles;
begin
  asm
    console.log("[Init] injecting styles...");
    let s = document.createElement('style');
    s.innerHTML = `
      .bv-fade-enter-active { transition: opacity .5s; }
      .bv-fade-enter { opacity: 0; }
      .v-move, .list-move { transition: transform 0.5s cubic-bezier(0.25, 1, 0.5, 1); }
      .v-enter-active, .list-enter-active { transition: all 0.4s ease; }
      .v-enter-from, .list-enter-from { opacity: 0; transform: translateY(15px); }
      .v-leave-active, .list-leave-active { transition: all 0.4s ease; position: absolute; }
      .v-leave-to, .list-leave-to { opacity: 0; transform: translateY(-15px); }
      .is-invalid, .bv-invalid { border-color: #ef4444 !important; }
      .is-valid, .bv-valid { border-color: #10b981 !important; }
      .bv-error-msg { color: #ef4444; font-size: 0.85rem; margin-top: 4px; display: block; }
    `;
    document.head.appendChild(s);
  end;
end;

{ Installs and activates the Router module }
procedure TBlaiseVue.UseRouter(ARouter: TBVRouter);
begin
  FRouter := ARouter;
  asm 
    console.log("[UserRouter] Installing router..."); 
    window.__BV_CORE__.router = ARouter;
  end;
  Router.Install(FRoot);
  asm console.log("[UserRouter] Compiling template..."); end;
  Compile(FRoot, FData, FMethods);
end;

{ Internal compile trigger to scan the DOM for directives (b-for, b-if, etc.) }
procedure TBlaiseVue.Compile(ARoot: JSValue; AData: TBlaiseData; AMethods: JSValue);
begin
  asm window.__BV_CORE__.compile(ARoot, AData, AMethods); end;
end;

class procedure TBlaiseVue.Use(APlugin: JSValue; AOptions: JSValue);
begin
  asm
    if (!window.__BV_CORE__.plugins) window.__BV_CORE__.plugins = new Set();
    if (window.__BV_CORE__.plugins.has(APlugin)) return;
    
    window.__BV_CORE__.plugins.add(APlugin);
    
    if (typeof APlugin.install === 'function') {
      APlugin.install(TBlaiseVue, AOptions);
    } else if (typeof APlugin === 'function') {
      APlugin(TBlaiseVue, AOptions);
    }
  end;
end;

class procedure TBlaiseVue.Mixin(AMixin: JSValue);
begin
  asm
    if (!window.__BV_CORE__.mixins) window.__BV_CORE__.mixins = [];
    window.__BV_CORE__.mixins.push(AMixin);
  end;
end;

initialization
  asm
    if (!window.__BV_CORE__) window.__BV_CORE__ = {};
    if (!window.__BV_CORE__.mixins) window.__BV_CORE__.mixins = [];
    if (!window.__BV_CORE__.plugins) window.__BV_CORE__.plugins = new Set();
    
    // Explicitly expose Mixin and Use to ensure they are available from JavaScript context
    // even if they were stripped during optimization.
    pas.BlaiseVue.TBlaiseVue.Mixin = function(m) { 
      if (!window.__BV_CORE__.mixins) window.__BV_CORE__.mixins = [];
      window.__BV_CORE__.mixins.push(m);
    };
    pas.BlaiseVue.TBlaiseVue.Use = function(p, o) {
      if (!window.__BV_CORE__.plugins) window.__BV_CORE__.plugins = new Set();
      if (window.__BV_CORE__.plugins.has(p)) return;
      window.__BV_CORE__.plugins.add(p);
      if (typeof p.install === 'function') p.install(pas.BlaiseVue.TBlaiseVue, o);
      else if (typeof p === 'function') p(pas.BlaiseVue.TBlaiseVue, o);
    };
  end;

end.