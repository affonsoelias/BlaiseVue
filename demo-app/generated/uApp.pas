unit uApp;

{$mode objfpc}

interface

uses JS, Web, BlaiseVue, BVComponents, BVStore, BVCompiler, BVDevTools, BVRouting, uCard, uCounter, uFormHeader, uInfoCard, uAbout, uCharts, uFormulario, uHome, uLibBootstrap, uProFeatures, uUserProfile, uBAccordion, uBAlert, uBBadge, uBBreadcrumb, uBBreadcrumbItem, uBBtn, uBCard, uBFormSelect, uBInput, uBInputGroup, uBListGroup, uBListGroupItem, uBModal, uBNavbar, uBNavItem, uBPagination, uBProgress, uBSpinner, uBTab, uBTabs, uBToast, uCArea, uCBar, uCBaseChart, uCBubble, uCDoughnut, uCLine, uCMixed, uCPie, uCPolarArea, uCRadar, uCScatter, uCStacked;

procedure Init_App;

implementation

procedure Init_App;
var
  data, methods, opts: TJSObject;
  app: TBlaiseVue;
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
  routerOpts: TJSObject;
  routesArr: TJSArray;
  r: TJSObject;
  router: TBVRouter;
begin
  asm console.log("[Init] Initing App..."); end;
  asm
    window.onerror = function(msg, url, line, col, error) {
      document.body.innerHTML = '<div style="background:red; color:white; padding:20px; font-family:monospace; position:fixed; top:0; left:0; width:100%; height:100%; z-index:10000;">'
        + '<h1>[BlaiseVue] ERROR</h1>'
        + '<p><b>Msg:</b> ' + msg + '</p>'
        + '<p><b>Line:</b> ' + line + ' <b>Col:</b> ' + col + '</p>'
        + '<p><b>Stack:</b><br><pre>' + (error ? error.stack : 'N/A') + '</pre></p></div>';
    };
  end;
  asm console.log("[Init] Injecting Styles..."); end;
  _styleEl := TJSHTMLElement(document.createElement('style'));
  _styleEl.textContent := '* { box-sizing: border-box; margin: 0; padding: 0; }   body { font-family: ''Segoe UI'', Arial, sans-serif; background: #f0f2f5; color: #2c3e50; }   .navbar { background: #2c3e50; padding: 12px 24px; display: flex; align-items: center; gap: 20px; flex-wrap: wrap; }   .brand { color: #42b883; font-size: 20px; }   .nav-links { display: flex; gap: 16px; }   .nav-links a { color: #ecf0f1; text-decoration: none; font-size: 14px; padding: 4px 8px; border-radius: 4px; }   .nav-links a:hover { background: rgba(255,255,255,0.1); color: #42b883; }   .nav-msg { margin-left: auto; color: #7f8c8d; font-size: 13px; }   .container { max-width: 900px; margin: 24px auto; padding: 0 20px; }   .footer-status { position: fixed; bottom: 0; left: 0; width: 100%; background: #2c3e50; color: #42b883; font-size: 11px; padding: 4px 10px; text-align: right; }   h1, h2, h3 { margin-bottom: 12px; }   .section { background: white; border-radius: 12px; padding: 24px; margin-bottom: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); }   .section-title { color: #42b883; border-bottom: 2px solid #42b883; padding-bottom: 8px; margin-bottom: 16px; }   button { padding: 8px 16px; border: none; border-radius: 6px; cursor: pointer; font-size: 14px; margin: 4px; }   .btn-primary { background: #42b883; color: white; }   .btn-primary:hover { background: #38a373; }   .btn-danger { background: #e74c3c; color: white; }   .btn-outline { background: white; border: 2px solid #42b883; color: #42b883; }   .btn-outline:hover { background: #42b883; color: white; }   input[type="text"] { width: 100%; padding: 10px; border: 2px solid #ddd; border-radius: 6px; font-size: 14px; margin: 6px 0; }   input[type="text"]:focus { border-color: #42b883; outline: none; }   table { width: 100%; border-collapse: collapse; margin: 12px 0; }   th, td { padding: 10px 14px; border: 1px solid #eee; text-align: left; }   th { background: #f8f9fa; font-weight: 600; }   .badge { display: inline-block; padding: 3px 10px; border-radius: 12px; color: white; font-weight: bold; font-size: 13px; }   .badge-green { background: #42b883; }   .badge-blue { background: #3498db; }   .badge-orange { background: #e67e22; }   .badge-gray { background: #95a5a6; }   code { background: #f0f0f0; padding: 2px 6px; border-radius: 3px; font-family: ''Consolas'', monospace; font-size: 13px; }   hr { border: none; border-top: 1px solid #eee; margin: 16px 0; }';
  document.head.appendChild(_styleEl);
  asm console.log("[Init] Registering uCard..."); end;
  Register_uCard;
  asm console.log("[Init] Registering uCounter..."); end;
  Register_uCounter;
  asm console.log("[Init] Registering uFormHeader..."); end;
  Register_uFormHeader;
  asm console.log("[Init] Registering uInfoCard..."); end;
  Register_uInfoCard;
  asm console.log("[Init] Registering uAbout..."); end;
  Register_uAbout;
  asm console.log("[Init] Registering uCharts..."); end;
  Register_uCharts;
  asm console.log("[Init] Registering uFormulario..."); end;
  Register_uFormulario;
  asm console.log("[Init] Registering uHome..."); end;
  Register_uHome;
  asm console.log("[Init] Registering uLibBootstrap..."); end;
  Register_uLibBootstrap;
  asm console.log("[Init] Registering uProFeatures..."); end;
  Register_uProFeatures;
  asm console.log("[Init] Registering uUserProfile..."); end;
  Register_uUserProfile;
  asm console.log("[Init] Registering uBAccordion..."); end;
  Register_uBAccordion;
  asm console.log("[Init] Registering uBAlert..."); end;
  Register_uBAlert;
  asm console.log("[Init] Registering uBBadge..."); end;
  Register_uBBadge;
  asm console.log("[Init] Registering uBBreadcrumb..."); end;
  Register_uBBreadcrumb;
  asm console.log("[Init] Registering uBBreadcrumbItem..."); end;
  Register_uBBreadcrumbItem;
  asm console.log("[Init] Registering uBBtn..."); end;
  Register_uBBtn;
  asm console.log("[Init] Registering uBCard..."); end;
  Register_uBCard;
  asm console.log("[Init] Registering uBFormSelect..."); end;
  Register_uBFormSelect;
  asm console.log("[Init] Registering uBInput..."); end;
  Register_uBInput;
  asm console.log("[Init] Registering uBInputGroup..."); end;
  Register_uBInputGroup;
  asm console.log("[Init] Registering uBListGroup..."); end;
  Register_uBListGroup;
  asm console.log("[Init] Registering uBListGroupItem..."); end;
  Register_uBListGroupItem;
  asm console.log("[Init] Registering uBModal..."); end;
  Register_uBModal;
  asm console.log("[Init] Registering uBNavbar..."); end;
  Register_uBNavbar;
  asm console.log("[Init] Registering uBNavItem..."); end;
  Register_uBNavItem;
  asm console.log("[Init] Registering uBPagination..."); end;
  Register_uBPagination;
  asm console.log("[Init] Registering uBProgress..."); end;
  Register_uBProgress;
  asm console.log("[Init] Registering uBSpinner..."); end;
  Register_uBSpinner;
  asm console.log("[Init] Registering uBTab..."); end;
  Register_uBTab;
  asm console.log("[Init] Registering uBTabs..."); end;
  Register_uBTabs;
  asm console.log("[Init] Registering uBToast..."); end;
  Register_uBToast;
  asm console.log("[Init] Registering uCArea..."); end;
  Register_uCArea;
  asm console.log("[Init] Registering uCBar..."); end;
  Register_uCBar;
  asm console.log("[Init] Registering uCBaseChart..."); end;
  Register_uCBaseChart;
  asm console.log("[Init] Registering uCBubble..."); end;
  Register_uCBubble;
  asm console.log("[Init] Registering uCDoughnut..."); end;
  Register_uCDoughnut;
  asm console.log("[Init] Registering uCLine..."); end;
  Register_uCLine;
  asm console.log("[Init] Registering uCMixed..."); end;
  Register_uCMixed;
  asm console.log("[Init] Registering uCPie..."); end;
  Register_uCPie;
  asm console.log("[Init] Registering uCPolarArea..."); end;
  Register_uCPolarArea;
  asm console.log("[Init] Registering uCRadar..."); end;
  Register_uCRadar;
  asm console.log("[Init] Registering uCScatter..."); end;
  Register_uCScatter;
  asm console.log("[Init] Registering uCStacked..."); end;
  Register_uCStacked;

  asm console.log("[Init] Setting #app template..."); end;
  TJSHTMLElement(document.querySelector('#app')).innerHTML :=
    '  <div>' +
    '    <nav class="navbar">' +
    '      <strong class="brand">BlaiseVue Demo 2.0</strong>' +
    '      <div class="nav-links">' +
    '        <a href="#/">Home</a>' +
    '        <a href="#/about">Sobre</a>' +
    '        <a href="#/pro">Pro Features 🛡️</a>' +
    '        <a href="#/form">Formulario</a>' +
    '        <a href="#/bootstrap">Bootstrap Lib 📦</a>' +
    '        <a href="#/charts" style="background: #42b883; color: white;">Charts 📊</a>' +
    '      </div>' +
    '      <span class="nav-msg">{{ mensagem }}</span>' +
    '    </nav>' +
    '    <div class="container">' +
    '      <router-view></router-view>' +
    '    </div>' +
    '    <div class="footer-status">' +
    '       Global Store: {{ $store.appVersion }} | Dev: {{ $store.user }}' +
    '    </div>' +
    '  </div>';

  data := TJSObject.new;
  data['mensagem'] := 'BlaiseVue SPA v2.0 PRO';

  methods := TJSObject.new;

  opts := TJSObject.new;
  comp := opts;
  comp['created'] := procedure(_this: TJSObject)
    begin
      // Inicializando dados globais com TBVStore
      TJSObject(_this['$store'])['appVersion'] := '2.0.0-PRO';
      TJSObject(_this['$store'])['user'] := 'DevMaster 🏆';
    end;

    ;
  comp['provide'] := function(_this: TJSObject): TJSObject
    begin
      Result := TJSObject.new;
      Result['getAmbiente'] := function(): TJSObject
        begin
           Result := TJSObject.new;
           Result['id'] := 42;
           Result['status'] := 'Produção 🛡️';
        end;
    end;

;
  routerOpts := TJSObject.new;
  routesArr := TJSArray.new;

  r := TJSObject.new;
  r['path'] := '/';
  r['component'] := 'home-page';
  routesArr.push(r);

  r := TJSObject.new;
  r['path'] := '/about';
  r['component'] := 'about-page';
  routesArr.push(r);

  r := TJSObject.new;
  r['path'] := '/form';
  r['component'] := 'formulario-page';
  routesArr.push(r);

  r := TJSObject.new;
  r['path'] := '/user/:id';
  r['component'] := 'user-profile-page';
  routesArr.push(r);

  r := TJSObject.new;
  r['path'] := '/pro';
  r['component'] := 'pro-features-page';
  routesArr.push(r);

  r := TJSObject.new;
  r['path'] := '/bootstrap';
  r['component'] := 'lib-bootstrap-page';
  routesArr.push(r);

  r := TJSObject.new;
  r['path'] := '/charts';
  r['component'] := 'charts-page';
  routesArr.push(r);

  routerOpts['routes'] := routesArr;
  router := TBVRouter.Create(routerOpts);

  app := TBlaiseVue.Create('#app', data, methods, opts);
  app.UseRouter(router);
end;

end.
