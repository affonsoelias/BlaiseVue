unit BVRouting;

{
  BVRouting - The SPA Navigation Engine
  --------------------------------------
  This unit implements advanced SPA routing for BlaiseVue SPAs:
  - Hash Mode (#/) and HTML5 History API Mode (/path)
  - Dynamic path parameters and query strings
  - Navigation guards: beforeEach, beforeEnter, afterEach
  - Nested routes and recursive <router-view>
  - Dynamic code splitting (lazy loading via dynamic import/async components)
}

{$mode objfpc}

interface

uses JS, Web, SysUtils, BVComponents, BVCompiler;

type
  { Represents a single route mapping }
  TBVRoute = class
  public
    Path: string;            { e.g. '/user/:id' }
    Component: string;       { Registered component tag name }
    BeforeEnter: JSValue;    { Local navigation guard }
    Children: JSValue;       { Nested child routes array }
    AsyncComponent: JSValue; { Function returning Promise for lazy loading }
    Meta: JSValue;           { Route metadata }
    ParentRoute: TBVRoute;   { Reference to parent route if nested }
    constructor Create;
  end;

  { Context object for the current active route }
  TBVRouteInfo = class
  public
    FullPath: string; { e.g. '/user/123?tab=profile' }
    HashPath: string; { e.g. '/user/123' }
    Params: JSValue;  { Reactive object containing path params {id: '123'} }
    Query: JSValue;   { Reactive object containing query params {tab: 'profile'} }
    Name: string;     { Component name }
    Meta: JSValue;    { Route metadata }
    constructor Create;
  end;

  { The main router controller }
  TBVRouter = class
  private
    FMode: string;            { 'hash' (default) or 'history' }
    FRoutes: JSValue;         { Store of all defined routes }
    FBeforeEach: JSValue;     { Global navigation guard }
    FAfterEach: JSValue;      { Global post-navigation hook }
    FAppRoot: TJSHTMLElement; { The root container of the app }
    FRouterViewEl: TJSHTMLElement; { Reference to the root <router-view> tag }
    FCurrentRoute: TBVRouteInfo; { Reactive state of the current navigation }
    procedure HandleHashChange(Event: TJSEvent);
    procedure HandlePopState(Event: TJSEvent);
    function MatchRoute(APath: string): TBVRoute;
    function MatchChildRoute(ParentRoute: TBVRoute; APath: string): TBVRoute;
    function ParseParams(Pattern, Actual: string): JSValue;
    function ParseQuery(AHash: string): JSValue;
    function ExtractPath(AHash: string): string;
    procedure MountRoute(RouteToMount, ChildRouteToMount: TBVRoute; const CleanPath, FullHashPath: string);
    procedure MountComponentIntoView(ViewEl: TJSHTMLElement; CompTag: string; CompOpt: JSValue; RouteParams, RouteQuery: JSValue);
  public
    constructor Create(Options: JSValue);
    procedure Install(AppRoot: TJSHTMLElement);
    procedure Push(APath: string);
    procedure Replace(APath: string);
    procedure Back;
    procedure Forward;
    procedure RenderCurrent;
    property CurrentRoute: TBVRouteInfo read FCurrentRoute;
    property Mode: string read FMode;
  end;

implementation

constructor TBVRoute.Create; begin end;
constructor TBVRouteInfo.Create; begin end;

{ TBVRouter Initialization }
constructor TBVRouter.Create(Options: JSValue);
var
  routesList: TJSArray;
  idx: Integer;
  itemObj: JSValue;
  newRoute: TBVRoute;
begin
  FRoutes := TJSArray.new;
  if TJSObject(Options).hasOwnProperty('mode') then
    FMode := LowerCase(string(TJSObject(Options)['mode']))
  else
    FMode := 'hash';

  routesList := TJSArray(TJSObject(Options)['routes']);
  if Assigned(routesList) then
  begin
    for idx := 0 to routesList.length - 1 do
    begin
      itemObj := routesList[idx];
      newRoute := TBVRoute.Create;
      newRoute.Path := string(TJSObject(itemObj)['path']);
      if TJSObject(itemObj).hasOwnProperty('component') then
      begin
        asm
          if (typeof itemObj.component === 'function') {
            newRoute.AsyncComponent = itemObj.component;
            newRoute.Component = '';
          } else {
            newRoute.Component = String(itemObj.component);
          }
        end;
      end;
      if TJSObject(itemObj).hasOwnProperty('asyncComponent') then
        newRoute.AsyncComponent := TJSObject(itemObj)['asyncComponent'];
      if TJSObject(itemObj).hasOwnProperty('beforeEnter') then
        newRoute.BeforeEnter := TJSObject(itemObj)['beforeEnter']
      else
        newRoute.BeforeEnter := nil;
      if TJSObject(itemObj).hasOwnProperty('children') then
        newRoute.Children := TJSObject(itemObj)['children']
      else
        newRoute.Children := nil;
      if TJSObject(itemObj).hasOwnProperty('meta') then
        newRoute.Meta := TJSObject(itemObj)['meta']
      else
        newRoute.Meta := TJSObject.new;
      TJSArray(FRoutes).push(newRoute);
    end;
  end;
  if TJSObject(Options).hasOwnProperty('beforeEach') then
    FBeforeEach := TJSObject(Options)['beforeEach']
  else
    FBeforeEach := nil;
  if TJSObject(Options).hasOwnProperty('afterEach') then
    FAfterEach := TJSObject(Options)['afterEach']
  else
    FAfterEach := nil;
    
  FCurrentRoute := TBVRouteInfo.Create;
  
  if FMode = 'history' then
  begin
    window.addEventListener('popstate', @HandlePopState);
    asm
      let self = this;
      document.addEventListener('click', function(ev) {
        let t = ev.target;
        while (t && t.tagName !== 'A') t = t.parentElement;
        if (t && (t.hasAttribute('to') || t.hasAttribute('bv-link') || (t.getAttribute('href') && t.getAttribute('href').startsWith('/')))) {
          let targetPath = t.getAttribute('to') || t.getAttribute('href');
          if (targetPath && !targetPath.startsWith('http://') && !targetPath.startsWith('https://') && !targetPath.startsWith('//')) {
            ev.preventDefault();
            self.Push(targetPath);
          }
        }
      });
    end;
  end
  else
    window.addEventListener('hashchange', @HandleHashChange);
end;

{ Sets up the router into the application context }
procedure TBVRouter.Install(AppRoot: TJSHTMLElement);
begin
  FAppRoot := AppRoot;
  FRouterViewEl := TJSHTMLElement(AppRoot.querySelector('router-view'));
  if FMode = 'history' then
  begin
    if (window.location.pathname = '') then
      Push('/')
    else
      RenderCurrent;
  end
  else
  begin
    if (window.location.hash = '') or (window.location.hash = '#') then 
      window.location.hash := '#/';
    RenderCurrent;
  end;
end;

procedure TBVRouter.Push(APath: string);
begin
  if FMode = 'history' then
  begin
    asm
      window.history.pushState(null, '', APath);
    end;
    RenderCurrent;
  end
  else
    window.location.hash := '#' + APath;
end;

procedure TBVRouter.Replace(APath: string);
begin
  if FMode = 'history' then
  begin
    asm
      window.history.replaceState(null, '', APath);
    end;
    RenderCurrent;
  end
  else
  begin
    asm
      let l = window.location.href.replace(/#(.*)$/, '') + '#' + APath;
      window.location.replace(l);
    end;
  end;
end;

procedure TBVRouter.Back; begin window.history.back(); end;
procedure TBVRouter.Forward; begin window.history.forward(); end;

{ Strips the query part for matching }
function TBVRouter.ExtractPath(AHash: string): string;
var qIdx: Integer;
begin
  qIdx := Pos('?', AHash);
  if qIdx > 0 then Result := Copy(AHash, 1, qIdx - 1) else Result := AHash;
end;

{ Converts query strings (?a=1&b=2) into a JS Object }
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

{ Finds the first route matching the current path using Regex }
function TBVRouter.MatchRoute(APath: string): TBVRoute;
var counter: Integer; rItem: TBVRoute; rsPat: string; reObj: TJSRegExp;
begin
  Result := nil;
  for counter := 0 to TJSArray(FRoutes).length - 1 do begin
    rItem := TBVRoute(TJSArray(FRoutes)[counter]);
    { Convert :param into regex groups (([^/]+)) }
    rsPat := '^' + String(TJSString(rItem.Path).replace(TJSRegExp.new(':[a-zA-Z_]+', 'g'), '([^/]+)')) + '$';
    reObj := TJSRegExp.new(rsPat);
    if reObj.test(APath) then begin Result := rItem; Exit; end;
    if Assigned(rItem.Children) then
    begin
      rsPat := '^' + String(TJSString(rItem.Path).replace(TJSRegExp.new(':[a-zA-Z_]+', 'g'), '([^/]+)')) + '(/.*)?$';
      reObj := TJSRegExp.new(rsPat);
      if reObj.test(APath) then begin Result := rItem; Exit; end;
    end;
  end;
end;

function TBVRouter.MatchChildRoute(ParentRoute: TBVRoute; APath: string): TBVRoute;
var
  childrenList: TJSArray;
  i: Integer;
  childObj: JSValue;
  childRoute: TBVRoute;
  fullChildPath, parentPrefix, rsPat: string;
  reObj: TJSRegExp;
begin
  Result := nil;
  if not Assigned(ParentRoute) or not Assigned(ParentRoute.Children) then Exit;
  childrenList := TJSArray(ParentRoute.Children);
  parentPrefix := ParentRoute.Path;
  if (parentPrefix <> '') and (parentPrefix[Length(parentPrefix)] = '/') then
    parentPrefix := Copy(parentPrefix, 1, Length(parentPrefix) - 1);

  for i := 0 to childrenList.length - 1 do
  begin
    childObj := childrenList[i];
    fullChildPath := string(TJSObject(childObj)['path']);
    if not ((fullChildPath <> '') and (fullChildPath[1] = '/')) then
      fullChildPath := parentPrefix + '/' + fullChildPath;
    rsPat := '^' + String(TJSString(fullChildPath).replace(TJSRegExp.new(':[a-zA-Z_]+', 'g'), '([^/]+)')) + '$';
    reObj := TJSRegExp.new(rsPat);
    if reObj.test(APath) then
    begin
      childRoute := TBVRoute.Create;
      childRoute.Path := fullChildPath;
      if TJSObject(childObj).hasOwnProperty('component') then
        childRoute.Component := string(TJSObject(childObj)['component']);
      if TJSObject(childObj).hasOwnProperty('asyncComponent') then
        childRoute.AsyncComponent := TJSObject(childObj)['asyncComponent'];
      if TJSObject(childObj).hasOwnProperty('beforeEnter') then
        childRoute.BeforeEnter := TJSObject(childObj)['beforeEnter']
      else
        childRoute.BeforeEnter := nil;
      childRoute.ParentRoute := ParentRoute;
      Result := childRoute;
      Exit;
    end;
  end;
end;

{ Extracts parameter values from the actual path based on the pattern }
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
procedure TBVRouter.HandlePopState(Event: TJSEvent); begin RenderCurrent; end;

procedure TBVRouter.MountComponentIntoView(ViewEl: TJSHTMLElement; CompTag: string; CompOpt: JSValue; RouteParams, RouteQuery: JSValue);
var
  navEl, rootPageEl: TJSHTMLElement;
  pageData: JSValue;
begin
  if not Assigned(ViewEl) or not Assigned(CompOpt) then Exit;
  navEl := TJSHTMLElement(document.createElement('div'));
  navEl.innerHTML := string(TJSObject(CompOpt)['template']);
  rootPageEl := TJSHTMLElement(navEl.firstElementChild);
  if not Assigned(rootPageEl) then Exit;
  asm 
    rootPageEl['bvManaged'] = true; 
    if (ViewEl.firstElementChild && window.__BV_CORE__ && window.__BV_CORE__.unmount) {
      window.__BV_CORE__.unmount(ViewEl.firstElementChild);
    }
  end;
  ViewEl.innerHTML := '';
  ViewEl.appendChild(rootPageEl);

  if TJSObject(CompOpt).hasOwnProperty('data') then 
    pageData := TJSFunction(TJSObject(CompOpt)['data']).apply(nil, []) 
  else 
    pageData := TJSObject.new;

  asm
    let pParams = RouteParams || {};
    Object.keys(pParams).forEach(function(k) { pageData[k] = pParams[k]; });
    let q = RouteQuery || {};
    Object.keys(q).forEach(function(k) { pageData[k] = q[k]; });

    let pRef = window.__BV_CORE__.defineReactive(pageData);
    rootPageEl['__bv_instance_data__'] = pRef;
    pRef['Router'] = this;
    pRef['$router'] = this;
    if (!pRef['$refs']) pRef['$refs'] = {};
    if (window['__BV_PRO_STORE__']) pRef['$store'] = window['__BV_PRO_STORE__'];
    if (window.__BV_CORE__.i18n) {
       pRef['$t'] = function(k, p) { return window.__BV_CORE__.t(k, p); };
       pRef['$i18n'] = window.__BV_CORE__.i18n;
       pRef['$setLocale'] = function(loc) { window.__BV_CORE__.i18n.setLocale(loc); };
    }
    if (window.__BV_CORE__.theme) {
       pRef['$theme'] = window.__BV_CORE__.theme;
    }
    if (window.__BV_CORE__.wasm) {
       pRef['$wasm'] = window.__BV_CORE__.wasm;
    }
    if (window.__BV_CORE__.validation) {
       window.__BV_CORE__.validation.initDataValidation(pRef);
    }
    if (window.__BV_CORE__.mobile) {
       pRef['$mobile'] = window.__BV_CORE__.mobile;
    }
    if (window.__BV_CORE__.desktop) {
       pRef['$desktop'] = window.__BV_CORE__.desktop;
    }
    if (window.__BV_CORE__.api) {
       pRef['$api'] = window.__BV_CORE__.api;
    }
    if (window.__BV_CORE__.ws) {
       pRef['$ws'] = window.__BV_CORE__.ws;
    }
    if (window.__BV_CORE__.auth) {
       pRef['$auth'] = window.__BV_CORE__.auth;
    }
    if (window.__BV_CORE__.ionic) {
       pRef['$ionic'] = window.__BV_CORE__.ionic;
    }

    if (CompOpt.inject) {
       CompOpt.inject.forEach(function(k) {
          let val = (window.__BV_CORE__.rootData && window.__BV_CORE__.rootData.$provided) ? window.__BV_CORE__.rootData.$provided[k] : null;
          if (val) pRef[k] = val;
       });
    }

    if (CompOpt.computed) { 
       Object.keys(CompOpt.computed).forEach(function(ck) { 
         window.__BV_CORE__.defineComputed(pRef, ck, CompOpt.computed[ck]); 
       }); 
    }
    
    if (CompOpt.methods) { 
       Object.keys(CompOpt.methods).forEach(function(k) { 
         let rM = CompOpt.methods[k];
         pageData[k] = function() { 
           if (arguments.length > 0 && arguments[0] === this) {
             return rM.apply(this, arguments);
           }
           return rM.apply(this, [this, ...arguments]); 
         }; 
       }); 
    }

    if (CompOpt.created) CompOpt.created.call(pRef, pRef);
    
    let cD = {
      FData: pRef,
      Evaluate: function(expr, ev) {
        try {
          let f = new Function('data', '$event', 'with(data) { return (' + expr + '); }');
          return f(pRef, ev);
        } catch(e1) {
          try {
            let f2 = new Function('data', '$event', 'with(data) { ' + expr + '; }');
            return f2(pRef, ev);
          } catch(e2) { return undefined; }
        }
      },
      SetValue: function(k, val) { pRef[k] = val; }
    };
    
    window.__BV_CORE__.compile(rootPageEl, cD, CompOpt.methods);

    let stopEffect = window.__BV_CORE__.effect(function() {
       let dummy = JSON.stringify(pRef);
       if (CompOpt.updated) CompOpt.updated.call(pRef, pRef);
    });

    if (CompOpt.mounted) CompOpt.mounted.call(pRef, pRef);

    rootPageEl['bvUnmount'] = function() {
       if (stopEffect && typeof stopEffect === 'function') stopEffect();
       if (CompOpt.unmounted) CompOpt.unmounted.call(pRef, pRef);
    };
  end;
end;

{ Main navigation and rendering logic for Router pages }
procedure TBVRouter.RenderCurrent;
var 
  fullHash, cleanP: string; 
  matchedRoute, matchedChild: TBVRoute; 
begin
  asm
    if (!this.FRouterViewEl || !document.body.contains(this.FRouterViewEl)) {
      let rv = null;
      if (this.FAppRoot) rv = this.FAppRoot.querySelector('router-view');
      if (!rv) rv = document.querySelector('router-view');
      if (rv) this.FRouterViewEl = rv;
    }
  end;
  if not Assigned(FRouterViewEl) then Exit;

  if FMode = 'history' then
  begin
    fullHash := string(window.location.pathname) + string(window.location.search);
    cleanP := ExtractPath(string(window.location.pathname));
  end
  else
  begin
    fullHash := string(window.location.hash);
    if fullHash <> '' then 
      fullHash := Copy(fullHash, 2, Length(fullHash)) 
    else 
      fullHash := '/';
    cleanP := ExtractPath(fullHash);
  end;

  matchedRoute := MatchRoute(cleanP);
  if not Assigned(matchedRoute) then begin 
    FRouterViewEl.innerHTML := '404 - Not Found'; 
    Exit; 
  end;

  matchedChild := nil;
  if Assigned(matchedRoute.Children) then
    matchedChild := MatchChildRoute(matchedRoute, cleanP);
  
  { Global Guard: beforeEach }
  if Assigned(FBeforeEach) then
  begin
    asm
      let toR = { path: cleanP, fullPath: fullHash, params: this.ParseParams(matchedRoute.Path, cleanP), query: this.ParseQuery(fullHash), meta: matchedRoute.Meta };
      let fromR = this.FCurrentRoute;
      let res = this.FBeforeEach.call(null, toR, fromR);
      
      if (res === false) return; // Navigation Aborted
      if (typeof res === 'string') {
        this.Push(res);
        return;
      }
    end;
  end;

  { Local Guard: beforeEnter }
  if Assigned(matchedRoute.BeforeEnter) then
  begin
    asm
      let r = matchedRoute.BeforeEnter.call(null);
      if (r === false) return;
      if (typeof r === 'string') {
        this.Push(r);
        return;
      }
    end;
  end;

  FCurrentRoute.FullPath := fullHash; 
  FCurrentRoute.HashPath := cleanP;
  FCurrentRoute.Params := ParseParams(matchedRoute.Path, cleanP); 
  FCurrentRoute.Query := ParseQuery(fullHash); 
  FCurrentRoute.Name := matchedRoute.Component;
  FCurrentRoute.Meta := matchedRoute.Meta;

  if Assigned(matchedRoute.AsyncComponent) then
  begin
    asm
      let self = this;
      let mRoute = matchedRoute;
      let mChild = matchedChild;
      let cP = cleanP;
      let fH = fullHash;
      Promise.resolve(mRoute.AsyncComponent()).then(function(mod) {
        let comp = (mod && mod.default) ? mod.default : mod;
        if (typeof comp === 'object') {
          let tName = comp.name || ('async-' + Math.random().toString(36).substr(2, 6));
          if (!window.__BV_CORE__.components) window.__BV_CORE__.components = {};
          window.__BV_CORE__.components[tName.toLowerCase()] = comp;
          mRoute.Component = tName;
        }
        self.MountRoute(mRoute, mChild, cP, fH);
      });
    end;
  end
  else
    MountRoute(matchedRoute, matchedChild, cleanP, fullHash);
end;

procedure TBVRouter.MountRoute(RouteToMount, ChildRouteToMount: TBVRoute; const CleanPath, FullHashPath: string);
var
  cOpt, childOpt, childParams: JSValue;
  nestedView: TJSHTMLElement;
begin
  cOpt := nil;
  if RouteToMount.Component <> '' then
  begin
    asm
      cOpt = (window.__BV_CORE__ && window.__BV_CORE__.components) ? window.__BV_CORE__.components[RouteToMount.Component.toLowerCase()] : null;
    end;
  end;

  if Assigned(cOpt) then
    MountComponentIntoView(FRouterViewEl, RouteToMount.Component, cOpt, FCurrentRoute.Params, FCurrentRoute.Query);

  if Assigned(ChildRouteToMount) and (FRouterViewEl <> nil) then
  begin
    nestedView := TJSHTMLElement(FRouterViewEl.querySelector('router-view'));
    if nestedView <> nil then
    begin
      childOpt := nil;
      if ChildRouteToMount.Component <> '' then
      begin
        asm
          childOpt = (window.__BV_CORE__ && window.__BV_CORE__.components) ? window.__BV_CORE__.components[ChildRouteToMount.Component.toLowerCase()] : null;
        end;
      end;
      childParams := ParseParams(ChildRouteToMount.Path, CleanPath);
      if Assigned(childOpt) then
        MountComponentIntoView(nestedView, ChildRouteToMount.Component, childOpt, childParams, FCurrentRoute.Query);
    end;
  end;

  if Assigned(FAfterEach) then
  begin
    asm
      let toR = { path: CleanPath, fullPath: FullHashPath, params: this.FCurrentRoute.Params, query: this.FCurrentRoute.Query, meta: RouteToMount.Meta };
      let fromR = this.FCurrentRoute;
      this.FAfterEach.call(null, toR, fromR);
    end;
  end;

  asm
    if (window.__BV_DEVTOOLS_HOOK__) {
      window.__BV_DEVTOOLS_HOOK__.emit('route:change', { path: CleanPath, component: RouteToMount.Component });
    }
  end;
end;

end.
