unit BVRouting;

{$mode objfpc}

interface

uses JS, Web, SysUtils, BVComponents, BVCompiler;

type
  TBVRoute = class
  public
    Path: string;
    Component: string;
    BeforeEnter: JSValue;
    constructor Create;
  end;

  TBVRouteInfo = class
  public
    FullPath: string;
    HashPath: string;
    Params: JSValue;
    Query: JSValue;
    Name: string;
    constructor Create;
  end;

  TBVRouter = class
  private
    FRoutes: JSValue;
    FBeforeEach: JSValue;
    FAppRoot: TJSHTMLElement;
    FRouterViewEl: TJSHTMLElement;
    FCurrentRoute: TBVRouteInfo;
    procedure HandleHashChange(Event: TJSEvent);
    function MatchRoute(APath: string): TBVRoute;
    function ParseParams(Pattern, Actual: string): JSValue;
    function ParseQuery(AHash: string): JSValue;
    function ExtractPath(AHash: string): string;
  public
    constructor Create(Options: JSValue);
    procedure Install(AppRoot: TJSHTMLElement);
    procedure Push(APath: string);
    procedure Back;
    procedure RenderCurrent;
    property CurrentRoute: TBVRouteInfo read FCurrentRoute;
  end;

implementation

constructor TBVRoute.Create; begin end;
constructor TBVRouteInfo.Create; begin end;

constructor TBVRouter.Create(Options: JSValue);
var
  routesList: TJSArray;
  idx: Integer;
  itemObj: JSValue;
  newRoute: TBVRoute;
begin
  FRoutes := TJSArray.new;
  routesList := TJSArray(TJSObject(Options)['routes']);
  if Assigned(routesList) then
  begin
    for idx := 0 to routesList.length - 1 do
    begin
      itemObj := routesList[idx];
      newRoute := TBVRoute.Create;
      newRoute.Path := string(TJSObject(itemObj)['path']);
      newRoute.Component := string(TJSObject(itemObj)['component']);
      if TJSObject(itemObj).hasOwnProperty('beforeEnter') then
        newRoute.BeforeEnter := TJSObject(itemObj)['beforeEnter']
      else
        newRoute.BeforeEnter := nil;
      TJSArray(FRoutes).push(newRoute);
    end;
  end;
  if TJSObject(Options).hasOwnProperty('beforeEach') then
    FBeforeEach := TJSObject(Options)['beforeEach']
  else
    FBeforeEach := nil;
  FCurrentRoute := TBVRouteInfo.Create;
  window.addEventListener('hashchange', @HandleHashChange);
end;

procedure TBVRouter.Install(AppRoot: TJSHTMLElement);
begin
  FAppRoot := AppRoot;
  FRouterViewEl := TJSHTMLElement(AppRoot.querySelector('router-view'));
  if (window.location.hash = '') or (window.location.hash = '#') then 
    window.location.hash := '#/';
  RenderCurrent;
end;

procedure TBVRouter.Push(APath: string); begin window.location.hash := '#' + APath; end;
procedure TBVRouter.Back; begin window.history.back(); end;

function TBVRouter.ExtractPath(AHash: string): string;
var qIdx: Integer;
begin
  qIdx := Pos('?', AHash);
  if qIdx > 0 then Result := Copy(AHash, 1, qIdx - 1) else Result := AHash;
end;

function TBVRouter.ParseQuery(AHash: string): JSValue;
var resObj: TJSObject;
begin
  resObj := TJSObject.new;
  asm
    let qp = AHash.indexOf('?');
    if (qp !== -1) {
      let qs = AHash.substring(qp + 1);
      qs.split('&').forEach(function(p) {
        let pts = p.split('=');
        if (pts.length > 0) resObj[decodeURIComponent(pts[0])] = decodeURIComponent(pts[1] || '');
      });
    }
  end;
  Result := resObj;
end;

function TBVRouter.MatchRoute(APath: string): TBVRoute;
var counter: Integer; rItem: TBVRoute; rsPat: string; reObj: TJSRegExp;
begin
  Result := nil;
  for counter := 0 to TJSArray(FRoutes).length - 1 do begin
    rItem := TBVRoute(TJSArray(FRoutes)[counter]);
    rsPat := '^' + String(TJSString(rItem.Path).replace(TJSRegExp.new(':[a-zA-Z_]+', 'g'), '([^/]+)')) + '$';
    reObj := TJSRegExp.new(rsPat);
    if reObj.test(APath) then begin Result := rItem; Exit; end;
  end;
end;

function TBVRouter.ParseParams(Pattern, Actual: string): JSValue;
var finalRes: TJSObject;
begin
  finalRes := TJSObject.new;
  asm
    let names = [];
    let nRE = /:([a-zA-Z_]+)/g;
    let m;
    while ((m = nRE.exec(Pattern)) !== null) { names.push(m[1]); }
    if (names.length > 0) {
      let vRS = '^' + Pattern.replace(/:[a-zA-Z_]+/g, '([^/]+)') + '$';
      let vRE = new RegExp(vRS);
      let vM = vRE.exec(Actual);
      if (vM) {
        for (let i=0; i<names.length; i++) {
          finalRes[names[i]] = decodeURIComponent(vM[i+1]);
        }
      }
    }
  end;
  Result := finalRes;
end;

procedure TBVRouter.HandleHashChange(Event: TJSEvent); begin RenderCurrent; end;

procedure TBVRouter.RenderCurrent;
var 
  fullHash, cleanP: string; 
  matchedRoute: TBVRoute; 
  compOptions, pageData, pParams, qQuery: JSValue; 
  navEl, rootPageEl: TJSHTMLElement; 
begin
  if not Assigned(FRouterViewEl) then Exit;
  fullHash := string(window.location.hash);
  if fullHash <> '' then 
    fullHash := Copy(fullHash, 2, Length(fullHash)) 
  else 
    fullHash := '/';
    
  cleanP := ExtractPath(fullHash);
  matchedRoute := MatchRoute(cleanP);
  if not Assigned(matchedRoute) then begin FRouterViewEl.innerHTML := '404 - Not Found'; Exit; end;
  
  FCurrentRoute.FullPath := fullHash; FCurrentRoute.HashPath := cleanP;
  FCurrentRoute.Params := ParseParams(matchedRoute.Path, cleanP); FCurrentRoute.Query := ParseQuery(fullHash); FCurrentRoute.Name := matchedRoute.Component;
  
  compOptions := GetComponent(matchedRoute.Component);
  if not Assigned(compOptions) then Exit;
  
  navEl := TJSHTMLElement(document.createElement('div'));
  navEl.innerHTML := string(TJSObject(compOptions)['template']);
  rootPageEl := TJSHTMLElement(navEl.firstElementChild);
  asm rootPageEl['bvManaged'] = true; end; 
  FRouterViewEl.innerHTML := '';
  FRouterViewEl.appendChild(rootPageEl);

  if TJSObject(compOptions).hasOwnProperty('data') then 
    pageData := TJSFunction(TJSObject(compOptions)['data']).apply(nil, []) 
  else 
    pageData := TJSObject.new;

  pParams := FCurrentRoute.Params; 
  asm
    Object.keys(pParams).forEach(function(k) { pageData[k] = pParams[k]; });
    let q = this.FCurrentRoute.Query;
    Object.keys(q).forEach(function(k) { pageData[k] = q[k]; });
  end;

  asm
    let pRef = window.__BV_CORE__.defineReactive(pageData);
    
    // Inject $store
    if (window['__BV_PRO_STORE__']) pRef['$store'] = window['__BV_PRO_STORE__'];
    
    // Inject from Parent (App)
    if (compOptions.inject) {
       compOptions.inject.forEach(function(k) {
          let val = (window.__BV_CORE__.rootData && window.__BV_CORE__.rootData.$provided) ? window.__BV_CORE__.rootData.$provided[k] : null;
          if (val) pRef[k] = val;
       });
    }

    if (compOptions.computed) { 
       Object.keys(compOptions.computed).forEach(function(ck) { 
         window.__BV_CORE__.defineComputed(pRef, ck, compOptions.computed[ck]); 
       }); 
    }
    
    if (compOptions.methods) { 
       Object.keys(compOptions.methods).forEach(function(k) { 
         let rM = compOptions.methods[k];
         pageData[k] = function() { return rM.apply(this, [this, ...arguments]); }; 
       }); 
    }

    if (compOptions.created) compOptions.created.call(pRef);
    
    let cD = {
      FData: pRef,
      Evaluate: function(expr, ev) {
        try {
          let f = new Function('data', '$event', 'with(data) { try { return ' + expr + '; } catch(e) { return undefined; } }');
          return f(pRef, ev);
        } catch(ex) { return undefined; }
      },
      SetValue: function(k, val) { pRef[k] = val; }
    };
    
    window.__BV_CORE__.compile(rootPageEl, cD, compOptions.methods);

    // Lifecycle: updated
    let stopEffect = window.__BV_CORE__.effect(function() {
       let dummy = JSON.stringify(pRef);
       if (compOptions.updated) compOptions.updated.call(pRef);
    });

    if (compOptions.mounted) compOptions.mounted.call(pRef);

    // Handle Unmount cleanup for routes
    rootPageEl['bvUnmount'] = function() {
       if (stopEffect && typeof stopEffect === 'function') stopEffect();
       if (compOptions.unmounted) compOptions.unmounted.call(pRef);
    };
  end;
end;

end.
