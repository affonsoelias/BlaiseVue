unit BlaiseVue;

{$mode objfpc}

interface

uses JS, Web, SysUtils, BVReactivity, BVCompiler, BVRouting, BVComponents;

type
  TBlaiseVue = class
  private
    FRoot: TJSHTMLElement;
    FData: TBlaiseData;
    FMethods: JSValue;
    FRouter: TBVRouter;
    procedure InjectStyles;
  public
    constructor Create(AEl: string; AData, AMethods, AOptions: JSValue); overload;
    constructor Create(Options: JSValue); overload;
    procedure UseRouter(ARouter: TBVRouter);
    procedure Compile(ARoot: JSValue; AData: TBlaiseData; AMethods: JSValue);
    property Data: TBlaiseData read FData;
    property Router: TBVRouter read FRouter;
  end;

implementation

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

constructor TBlaiseVue.Create(Options: JSValue);
var
  AData, AMethods, AComputed, JS_rootID: JSValue;
  rootID: string;
  d, m, c: JSValue;
begin
  asm console.log("[Init] Initing App..."); end;
  InjectStyles;
  
  asm
    JS_rootID = Options.el || '#app';
    AData = Options.data || {};
    AMethods = Options.methods || null;
    AComputed = Options.computed || null;
  end;
  
  rootID := string(JS_rootID);
  FRoot := TJSHTMLElement(document.querySelector(rootID));

  FData := TBlaiseData.Create(AData);
  FMethods := AMethods;
  
  d := FData;
  m := AMethods;
  c := AComputed;
  asm window.__BV_CORE__.initApp(d, m, c); end;
  asm window.__BV_CORE__.rootData = d.FData; end;
  asm if (window.__BV_PRO_STORE__) d.FData.$store = window.__BV_PRO_STORE__; end;

  asm
    if (Options.provide) {
      d.FData.$provided = Options.provide.call(d.FData, d.FData);
    }
    if (Options.created) {
      Options.created.call(d.FData, d.FData);
    }
  end;
    
  asm console.log("[Create] Instance ready."); end;
end;

procedure TBlaiseVue.InjectStyles;
begin
  asm
    console.log("[Init] injecting styles...");
    let s = document.createElement('style');
    s.innerHTML = `
      .bv-fade-enter-active { transition: opacity .5s; }
      .bv-fade-enter { opacity: 0; }
    `;
    document.head.appendChild(s);
  end;
end;

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

procedure TBlaiseVue.Compile(ARoot: JSValue; AData: TBlaiseData; AMethods: JSValue);
begin
  asm window.__BV_CORE__.compile(ARoot, AData, AMethods); end;
end;

end.