unit uApp;

{$mode objfpc}
{$modeswitch externalclass}
{$COPERATORS ON}

interface

uses JS, Web, BlaiseVue, BVComponents, BVStore, BVFSM, BVCompiler, BVDevTools, BVPascalDX, BVDataSet, BVRouting, uAppVersion, uAppFooter, uAppHeader, uAppSidebar, uCard, uCounter, uFormHeader, uInfoCard, uStatPills, uTableCells, uAbout, uCharts, uCustomerView, uDatasetView, uFormulario, uFragmentsView, uHome, uI18nLabView, uLibBootstrap, uLoginView, uMobileView, uProductView, uProFeatures, uReportsView, uShowcase, uUserProfile, uBVBarChart, uBVBubbleChart, uBVChart, uBVDoughnutChart, uBVLineChart, uBVPieChart, uBVPolarAreaChart, uBVRadarChart, uBVScatterChart, uBVReportViewer, uBVAccordion, uBVAlert, uBVBadge, uBVBottomNav, uBVBottomNavItem, uBVBreadcrumb, uBVBreadcrumbItem, uBVBtn, uBVCard, uBVCheckbox, uBVCol, uBVContainer, uBVDataGrid, uBVDrawer, uBVDropdown, uBVDropdownItem, uBVFormSelect, uBVIcon, uBVInput, uBVInputGroup, uBVListGroup, uBVListGroupItem, uBVModal, uBVNavbar, uBVNavItem, uBVPagination, uBVProgress, uBVRadio, uBVRow, uBVSkeleton, uBVSlider, uBVSpinner, uBVSwitch, uBVTab, uBVTabs, uBVToast, uBVVirtualScroll, uBVIonApp, uBVIonBackButton, uBVIonBadge, uBVIonButton, uBVIonCard, uBVIonCheckbox, uBVIonContent, uBVIonFab, uBVIonFabButton, uBVIonHeader, uBVIonInput, uBVIonItem, uBVIonList, uBVIonRefresher, uBVIonSearchBar, uBVIonSelect, uBVIonTabBar, uBVIonTabButton, uBVIonTabs, uBVIonTitle, uBVIonToggle, uBVIonToolbar, uBVThemeSelect, uBVThemeToggle;

procedure Init_App;

implementation

type
  TComponentThis = class external name 'Object' (TJSObject)
    isMobileMenuOpen: Boolean;
    isSidebarCollapsed: Boolean;
  end;

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
  _styleEl.textContent := ':root {     --bv-bg: var(--bs-body-bg, #f8fafc);     --bv-surface: var(--bs-tertiary-bg, #ffffff);     --bv-surface-subtle: var(--bs-secondary-bg, #f8fafc);     --bv-border: var(--bs-border-color, #e2e8f0);     --bv-text: var(--bs-body-color, #1e293b);     --bv-text-muted: var(--bs-secondary-color, #64748b);     --bv-input-bg: #ffffff;     --bv-hover-bg: #f1f5f9;     --bv-code-bg: #f1f5f9;     --bv-code-color: #0f172a;     --bv-shadow: 0 1px 3px rgba(0, 0, 0, 0.06);   }    html[data-bs-theme="dark"],   html.theme-dark,   body.theme-dark {     --bv-bg: var(--bs-body-bg, #0f172a);     --bv-surface: var(--bs-tertiary-bg, #1e293b);     --bv-surface-subtle: var(--bs-secondary-bg, #162032);     --bv-border: var(--bs-border-color, rgba(255, 255, 255, 0.14));     --bv-text: var(--bs-body-color, #f1f5f9);     --bv-text-muted: var(--bs-secondary-color, #94a3b8);     --bv-input-bg: var(--bs-body-bg, #0f172a);     --bv-hover-bg: rgba(255, 255, 255, 0.06);     --bv-code-bg: #0f172a;     --bv-code-color: #38bdf8;     --bv-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);   }    * { box-sizing: border-box; margin: 0; padding: 0; }   body { font-family: -apple-system, BlinkMacSystemFont, ''Segoe UI'', Roboto, Helvetica, Arial, sans-serif; background: var(--bv-bg); color: var(--bv-text); min-height: 100vh; }    .app-shell {     display: flex;     min-height: 100vh;   }   .app-main-layout {     flex: 1;     min-width: 0;     display: flex;     flex-direction: column;     min-height: 100vh;     margin-left: 260px; /* Sidebar width on desktop */     transition: margin-left 0.3s ease;   }   .app-shell.sidebar-collapsed .app-main-layout {     margin-left: 0;   }   .app-content-body {     flex: 1;     padding: 24px 0;   }   .main-content-container {     max-width: 1100px;     margin: 0 auto;     padding: 0 24px;   }   .mobile-bottom-bar {     display: none;   }    /* Responsive layout for tablets and mobile */   @media (max-width: 992px) {   html, body {     overflow-x: clip;   }   .app-main-layout {     margin-left: 0;     overflow-x: clip;   }   .main-content-container {     padding: 0 12px;   }   .mobile-bottom-bar {     display: flex;     position: fixed;     bottom: 0;     left: 0;     width: 100%;     z-index: 1010;   }   .app-content-body {     padding: 16px 0 80px 0; /* Room for bottom bar on mobile */   }   }   @media (max-width: 768px) {   .section { padding: 16px; }   pre {     max-width: 100%;     white-space: pre-wrap;     word-break: break-word;     overflow-x: auto;     -webkit-overflow-scrolling: touch;   }   }    /* Global typography & shared view utility classes */   h1, h2, h3, h4 { color: var(--bv-text); font-weight: 700; margin-bottom: 12px; }   p { line-height: 1.6; color: var(--bv-text-muted); }   .section { background: var(--bv-surface); color: var(--bv-text); border-radius: 12px; padding: 24px; margin-bottom: 24px; box-shadow: var(--bv-shadow); border: 1px solid var(--bv-border); }   .section-title { color: #42b883; border-bottom: 2px solid #42b883; padding-bottom: 8px; margin-bottom: 16px; }    .btn-primary, .btn-danger, .btn-outline {     display: inline-flex;     align-items: center;     justify-content: center;     gap: 6px;     padding: 8px 16px;     border-radius: 6px;     font-size: 14px;     font-weight: 600;     line-height: 1.4;     cursor: pointer;     margin: 4px 4px 4px 0;     text-decoration: none;     transition: all 0.2s ease;   }   .btn-primary {     background: #42b883;     color: #ffffff;     border: 2px solid #42b883;   }   .btn-primary:hover {     background: #33a06f;     border-color: #33a06f;   }   .btn-danger {     background: #e74c3c;     color: #ffffff;     border: 2px solid #e74c3c;   }   .btn-danger:hover {     background: #c0392b;     border-color: #c0392b;   }   .btn-outline {     background: transparent;     border: 2px solid #42b883;     color: #42b883;   }   .btn-outline:hover {     background: #42b883;     color: #ffffff;   }    .badge {     display: inline-block;     padding: 4px 10px;     border-radius: 12px;     color: #ffffff;     font-weight: 600;     font-size: 12px;     line-height: 1.3;   }   .badge-green { background: #42b883; }   .badge-blue { background: #3498db; }   .badge-orange { background: #e67e22; }   .badge-gray { background: #64748b; }    .section input[type="text"],   .section input[type="number"],   .section select {     width: 100%;     padding: 10px 12px;     border: 1.5px solid var(--bv-border);     border-radius: 6px;     font-size: 14px;     margin: 6px 0;     background: var(--bv-input-bg);     color: var(--bv-text);   }   .section input[type="text"]:focus,   .section input[type="number"]:focus,   .section select:focus {     border-color: #42b883;     outline: none;     box-shadow: 0 0 0 3px rgba(66, 184, 131, 0.15);   }   .section table { width: 100%; border-collapse: collapse; margin: 12px 0; }   .section th, .section td { padding: 10px 14px; border: 1px solid var(--bv-border); text-align: left; color: var(--bv-text); }   .section th { background: var(--bv-surface-subtle); font-weight: 600; color: var(--bv-text); }   code { background: var(--bv-code-bg); color: var(--bv-code-color); padding: 2px 6px; border-radius: 4px; font-family: ''Consolas'', monospace; font-size: 13px; }   hr { border: none; border-top: 1px solid var(--bv-border); margin: 16px 0; }';
  document.head.appendChild(_styleEl);
  asm console.log("[Init] Registering uAppFooter..."); end;
  Register_uAppFooter;
  asm console.log("[Init] Registering uAppHeader..."); end;
  Register_uAppHeader;
  asm console.log("[Init] Registering uAppSidebar..."); end;
  Register_uAppSidebar;
  asm console.log("[Init] Registering uCard..."); end;
  Register_uCard;
  asm console.log("[Init] Registering uCounter..."); end;
  Register_uCounter;
  asm console.log("[Init] Registering uFormHeader..."); end;
  Register_uFormHeader;
  asm console.log("[Init] Registering uInfoCard..."); end;
  Register_uInfoCard;
  asm console.log("[Init] Registering uStatPills..."); end;
  Register_uStatPills;
  asm console.log("[Init] Registering uTableCells..."); end;
  Register_uTableCells;
  asm console.log("[Init] Registering uAbout..."); end;
  Register_uAbout;
  asm console.log("[Init] Registering uCharts..."); end;
  Register_uCharts;
  asm console.log("[Init] Registering uCustomerView..."); end;
  Register_uCustomerView;
  asm console.log("[Init] Registering uDatasetView..."); end;
  Register_uDatasetView;
  asm console.log("[Init] Registering uFormulario..."); end;
  Register_uFormulario;
  asm console.log("[Init] Registering uFragmentsView..."); end;
  Register_uFragmentsView;
  asm console.log("[Init] Registering uHome..."); end;
  Register_uHome;
  asm console.log("[Init] Registering uI18nLabView..."); end;
  Register_uI18nLabView;
  asm console.log("[Init] Registering uLibBootstrap..."); end;
  Register_uLibBootstrap;
  asm console.log("[Init] Registering uLoginView..."); end;
  Register_uLoginView;
  asm console.log("[Init] Registering uMobileView..."); end;
  Register_uMobileView;
  asm console.log("[Init] Registering uProductView..."); end;
  Register_uProductView;
  asm console.log("[Init] Registering uProFeatures..."); end;
  Register_uProFeatures;
  asm console.log("[Init] Registering uReportsView..."); end;
  Register_uReportsView;
  asm console.log("[Init] Registering uShowcase..."); end;
  Register_uShowcase;
  asm console.log("[Init] Registering uUserProfile..."); end;
  Register_uUserProfile;
  asm console.log("[Init] Registering uBVBarChart..."); end;
  Register_uBVBarChart;
  asm console.log("[Init] Registering uBVBubbleChart..."); end;
  Register_uBVBubbleChart;
  asm console.log("[Init] Registering uBVChart..."); end;
  Register_uBVChart;
  asm console.log("[Init] Registering uBVDoughnutChart..."); end;
  Register_uBVDoughnutChart;
  asm console.log("[Init] Registering uBVLineChart..."); end;
  Register_uBVLineChart;
  asm console.log("[Init] Registering uBVPieChart..."); end;
  Register_uBVPieChart;
  asm console.log("[Init] Registering uBVPolarAreaChart..."); end;
  Register_uBVPolarAreaChart;
  asm console.log("[Init] Registering uBVRadarChart..."); end;
  Register_uBVRadarChart;
  asm console.log("[Init] Registering uBVScatterChart..."); end;
  Register_uBVScatterChart;
  asm console.log("[Init] Registering uBVReportViewer..."); end;
  Register_uBVReportViewer;
  asm console.log("[Init] Registering uBVAccordion..."); end;
  Register_uBVAccordion;
  asm console.log("[Init] Registering uBVAlert..."); end;
  Register_uBVAlert;
  asm console.log("[Init] Registering uBVBadge..."); end;
  Register_uBVBadge;
  asm console.log("[Init] Registering uBVBottomNav..."); end;
  Register_uBVBottomNav;
  asm console.log("[Init] Registering uBVBottomNavItem..."); end;
  Register_uBVBottomNavItem;
  asm console.log("[Init] Registering uBVBreadcrumb..."); end;
  Register_uBVBreadcrumb;
  asm console.log("[Init] Registering uBVBreadcrumbItem..."); end;
  Register_uBVBreadcrumbItem;
  asm console.log("[Init] Registering uBVBtn..."); end;
  Register_uBVBtn;
  asm console.log("[Init] Registering uBVCard..."); end;
  Register_uBVCard;
  asm console.log("[Init] Registering uBVCheckbox..."); end;
  Register_uBVCheckbox;
  asm console.log("[Init] Registering uBVCol..."); end;
  Register_uBVCol;
  asm console.log("[Init] Registering uBVContainer..."); end;
  Register_uBVContainer;
  asm console.log("[Init] Registering uBVDataGrid..."); end;
  Register_uBVDataGrid;
  asm console.log("[Init] Registering uBVDrawer..."); end;
  Register_uBVDrawer;
  asm console.log("[Init] Registering uBVDropdown..."); end;
  Register_uBVDropdown;
  asm console.log("[Init] Registering uBVDropdownItem..."); end;
  Register_uBVDropdownItem;
  asm console.log("[Init] Registering uBVFormSelect..."); end;
  Register_uBVFormSelect;
  asm console.log("[Init] Registering uBVIcon..."); end;
  Register_uBVIcon;
  asm console.log("[Init] Registering uBVInput..."); end;
  Register_uBVInput;
  asm console.log("[Init] Registering uBVInputGroup..."); end;
  Register_uBVInputGroup;
  asm console.log("[Init] Registering uBVListGroup..."); end;
  Register_uBVListGroup;
  asm console.log("[Init] Registering uBVListGroupItem..."); end;
  Register_uBVListGroupItem;
  asm console.log("[Init] Registering uBVModal..."); end;
  Register_uBVModal;
  asm console.log("[Init] Registering uBVNavbar..."); end;
  Register_uBVNavbar;
  asm console.log("[Init] Registering uBVNavItem..."); end;
  Register_uBVNavItem;
  asm console.log("[Init] Registering uBVPagination..."); end;
  Register_uBVPagination;
  asm console.log("[Init] Registering uBVProgress..."); end;
  Register_uBVProgress;
  asm console.log("[Init] Registering uBVRadio..."); end;
  Register_uBVRadio;
  asm console.log("[Init] Registering uBVRow..."); end;
  Register_uBVRow;
  asm console.log("[Init] Registering uBVSkeleton..."); end;
  Register_uBVSkeleton;
  asm console.log("[Init] Registering uBVSlider..."); end;
  Register_uBVSlider;
  asm console.log("[Init] Registering uBVSpinner..."); end;
  Register_uBVSpinner;
  asm console.log("[Init] Registering uBVSwitch..."); end;
  Register_uBVSwitch;
  asm console.log("[Init] Registering uBVTab..."); end;
  Register_uBVTab;
  asm console.log("[Init] Registering uBVTabs..."); end;
  Register_uBVTabs;
  asm console.log("[Init] Registering uBVToast..."); end;
  Register_uBVToast;
  asm console.log("[Init] Registering uBVVirtualScroll..."); end;
  Register_uBVVirtualScroll;
  asm console.log("[Init] Registering uBVIonApp..."); end;
  Register_uBVIonApp;
  asm console.log("[Init] Registering uBVIonBackButton..."); end;
  Register_uBVIonBackButton;
  asm console.log("[Init] Registering uBVIonBadge..."); end;
  Register_uBVIonBadge;
  asm console.log("[Init] Registering uBVIonButton..."); end;
  Register_uBVIonButton;
  asm console.log("[Init] Registering uBVIonCard..."); end;
  Register_uBVIonCard;
  asm console.log("[Init] Registering uBVIonCheckbox..."); end;
  Register_uBVIonCheckbox;
  asm console.log("[Init] Registering uBVIonContent..."); end;
  Register_uBVIonContent;
  asm console.log("[Init] Registering uBVIonFab..."); end;
  Register_uBVIonFab;
  asm console.log("[Init] Registering uBVIonFabButton..."); end;
  Register_uBVIonFabButton;
  asm console.log("[Init] Registering uBVIonHeader..."); end;
  Register_uBVIonHeader;
  asm console.log("[Init] Registering uBVIonInput..."); end;
  Register_uBVIonInput;
  asm console.log("[Init] Registering uBVIonItem..."); end;
  Register_uBVIonItem;
  asm console.log("[Init] Registering uBVIonList..."); end;
  Register_uBVIonList;
  asm console.log("[Init] Registering uBVIonRefresher..."); end;
  Register_uBVIonRefresher;
  asm console.log("[Init] Registering uBVIonSearchBar..."); end;
  Register_uBVIonSearchBar;
  asm console.log("[Init] Registering uBVIonSelect..."); end;
  Register_uBVIonSelect;
  asm console.log("[Init] Registering uBVIonTabBar..."); end;
  Register_uBVIonTabBar;
  asm console.log("[Init] Registering uBVIonTabButton..."); end;
  Register_uBVIonTabButton;
  asm console.log("[Init] Registering uBVIonTabs..."); end;
  Register_uBVIonTabs;
  asm console.log("[Init] Registering uBVIonTitle..."); end;
  Register_uBVIonTitle;
  asm console.log("[Init] Registering uBVIonToggle..."); end;
  Register_uBVIonToggle;
  asm console.log("[Init] Registering uBVIonToolbar..."); end;
  Register_uBVIonToolbar;
  asm console.log("[Init] Registering uBVThemeSelect..."); end;
  Register_uBVThemeSelect;
  asm console.log("[Init] Registering uBVThemeToggle..."); end;
  Register_uBVThemeToggle;


  asm console.log("[Init] Setting #app template..."); end;
  TJSHTMLElement(document.querySelector('#app')).innerHTML :=
    '  <div translate="no" class="notranslate app-shell" :class="{ ''sidebar-collapsed'': isSidebarCollapsed }">' +
    '    <!-- RESPONSIVE SIDEBAR NAVIGATION (DRAWER ON MOBILE, PINNED ON DESKTOP) -->' +
    '    <app-sidebar :is-open="isMobileMenuOpen" :is-collapsed="isSidebarCollapsed" @close="closeMobileMenu"></app-sidebar>' +
    '' +
    '    <!-- MAIN APPLICATION WRAPPER -->' +
    '    <div class="app-main-layout">' +
    '      <!-- HEADER WITH BREADCRUMBS, THEME SWITCHER & LOCALE CONTROLS -->' +
    '      <app-header @toggle-sidebar="toggleSidebar"></app-header>' +
    '' +
    '      <!-- RESPONSIVE VIEW OUTLET -->' +
    '      <main class="app-content-body">' +
    '        <bv-container class="main-content-container">' +
    '          <router-view></router-view>' +
    '        </bv-container>' +
    '      </main>' +
    '' +
    '      <!-- STATUS BAR FOOTER -->' +
    '      <app-footer></app-footer>' +
    '    </div>' +
    '' +
    '    <!-- MOBILE BOTTOM NAVIGATION BAR (QUICK THUMB ACCESSIBILITY) -->' +
    '    <bv-bottom-nav class="mobile-bottom-bar">' +
    '      <bv-bottom-nav-item href="#/" icon="🏠" label="Home"></bv-bottom-nav-item>' +
    '      <bv-bottom-nav-item href="#/pro" icon="⚡" label="Pro"></bv-bottom-nav-item>' +
    '      <bv-bottom-nav-item href="#/dataset" icon="💾" label="Data"></bv-bottom-nav-item>' +
    '      <bv-bottom-nav-item href="#/bootstrap" icon="🎨" label="BlaiseUI"></bv-bottom-nav-item>' +
    '      <bv-bottom-nav-item href="#/mobile" icon="📱" label="Mobile"></bv-bottom-nav-item>' +
    '      <bv-bottom-nav-item href="docs/index.html" icon="📚" label="Docs"></bv-bottom-nav-item>' +
    '    </bv-bottom-nav>' +
    '  </div>';

  data := TJSObject.new;
  data['isMobileMenuOpen'] := false;
  data['isSidebarCollapsed'] := true;

  methods := TJSObject.new;
  m := methods;
  m['toggleSidebar'] := procedure(_this: TJSObject)

    begin
      if window.innerWidth <= 992 then
      TComponentThis(_this).isMobileMenuOpen := not TComponentThis(_this).isMobileMenuOpen
      else
      TComponentThis(_this).isSidebarCollapsed := not TComponentThis(_this).isSidebarCollapsed;
    end;
    
  m['closeMobileMenu'] := procedure(_this: TJSObject)

    begin
      TComponentThis(_this).isMobileMenuOpen := false;
    end;
    { Router Configuration: Maps URI hashes to Component Tags }


  opts := TJSObject.new;
  comp := opts;
  comp['created'] := procedure(_this: TJSObject)
    begin
      asm if (!_this) _this = this; end;

      if APP_VERSION = '' then;
      TJSObject(_this['$store'])['user'] := 'Pascal Master 🚀';
      I18nAddMessages('en', '{"nav":{"home":"Home","about":"About","pro":"Pro & Wasm ⚡","form":"Form 📋","blaiseui":"BlaiseUI Kit 🎨","charts":"Charts 📊","showcase":"Showcase ✨"},"status":{"globalStore":"Global Store","localeActive":"Active Locale","theme":"Theme"},"form":{"title":"Reactive Form Validation","subtitle":"Demonstrating b-validate, $errors, and $v in BlaiseVue","name":"Full Name","email":"Corporate Email","city":"City","submit":"Validate & Submit 🚀","reset":"Reset Form 🔄","fillValid":"Fill Valid Sample ✨","statusValid":"Valid ✅","statusInvalid":"Invalid ❌","formState":"Form Status"},"pro":{"title":"⚡ BlaiseVue Pro & WebAssembly Engine","transitionTitle":"🎬 FLIP List Transitions (<transition-group>)","shuffle":"Shuffle 🔀","add":"Add Item ➕","remove":"Remove First ➖","resetList":"Reset List 🔄"}}');
      I18nAddMessages('pt', '{"nav":{"home":"Início","about":"Sobre","pro":"Pro & Wasm ⚡","form":"Formulário 📋","blaiseui":"BlaiseUI Kit 🎨","charts":"Gráficos 📊","showcase":"Showcase ✨"},"status":{"globalStore":"Memória Global","localeActive":"Idioma Ativo","theme":"Tema"},"form":{"title":"Formulário de Validação Reativa","subtitle":"Demonstração de b-validate, $errors e $v no BlaiseVue","name":"Nome Completo","email":"E-mail Corporativo","city":"Cidade","submit":"Validar & Enviar 🚀","reset":"Limpar Formulário 🔄","fillValid":"Preencher Válido ✨","statusValid":"Válido ✅","statusInvalid":"Inválido ❌","formState":"Status do Formulário"},"pro":{"title":"⚡ BlaiseVue Pro & WebAssembly Engine","transitionTitle":"🎬 Lista com Animações FLIP (<transition-group>)","shuffle":"Embaralhar 🔀","add":"Adicionar Item ➕","remove":"Remover Primeiro ➖","resetList":"Resetar Lista 🔄"}}');
      { Default to English as the primary framework showcase language }
      I18nSetLocale('en');
    end;

    ;
  comp['provide'] := function(_this: TJSObject): TJSObject
    begin
      Result := TJSObject.new;
      Result['getAmbiente'] := function(): TJSObject
    begin
      Result := TJSObject.new;
      Result['id'] := 42;
      Result['status'] := 'Production 🛡️';
    end;
    end;
    { Lifecycle: Initialize global state in the centralized store }

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
  r['path'] := '/fragments';
  r['component'] := 'fragments-view-page';
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

  r := TJSObject.new;
  r['path'] := '/reports';
  r['component'] := 'reports-view-page';
  routesArr.push(r);

  r := TJSObject.new;
  r['path'] := '/showcase';
  r['component'] := 'showcase-page';
  routesArr.push(r);

  r := TJSObject.new;
  r['path'] := '/dataset';
  r['component'] := 'dataset-view-page';
  routesArr.push(r);

  r := TJSObject.new;
  r['path'] := '/customers';
  r['component'] := 'customer-view-page';
  routesArr.push(r);

  r := TJSObject.new;
  r['path'] := '/products';
  r['component'] := 'product-view-page';
  routesArr.push(r);

  r := TJSObject.new;
  r['path'] := '/login';
  r['component'] := 'login-view-page';
  routesArr.push(r);

  r := TJSObject.new;
  r['path'] := '/mobile';
  r['component'] := 'mobile-view-page';
  routesArr.push(r);

  r := TJSObject.new;
  r['path'] := '/form';
  r['component'] := 'formulario-page';
  routesArr.push(r);

  r := TJSObject.new;
  r['path'] := '/i18n';
  r['component'] := 'i18n-lab-view-page';
  routesArr.push(r);

  r := TJSObject.new;
  r['path'] := '/user/:id';
  r['component'] := 'user-profile-page';
  routesArr.push(r);

  routerOpts['routes'] := routesArr;
  router := TBVRouter.Create(routerOpts);

  app := TBlaiseVue.Create('#app', data, methods, opts);
  app.UseRouter(router);
end;

end.
