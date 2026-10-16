unit uApp;

{$mode objfpc}

interface

uses JS, Web, BlaiseVue, BVComponents, BVStore, BVCompiler, BVDevTools, BVRouting, uCard, uCounter, uFormHeader, uInfoCard, uAbout, uCharts, uFormulario, uHome, uLibBootstrap, uProFeatures, uShowcase, uUserProfile, uBVAccordion, uBVAlert, uBVBadge, uBVBar, uBVBreadcrumb, uBVBreadcrumbItem, uBVBtn, uBVCard, uBVChart, uBVDataGrid, uBVDoughnut, uBVFormSelect, uBVIcon, uBVInput, uBVInputGroup, uBVLine, uBVListGroup, uBVListGroupItem, uBVModal, uBVNavbar, uBVNavItem, uBVPagination, uBVPie, uBVPolarArea, uBVProgress, uBVRadar, uBVSpinner, uBVTab, uBVTabs, uBVToast, uBVThemeSelect, uBVThemeToggle;

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
  _styleEl.textContent := '* { box-sizing: border-box; margin: 0; padding: 0; }   body { font-family: ''Segoe UI'', Arial, sans-serif; background: #f0f2f5; color: #2c3e50; }   .navbar { background: #2c3e50; padding: 12px 24px; display: flex; align-items: center; gap: 16px; flex-wrap: wrap; }   .brand { color: #42b883; font-size: 20px; font-weight: 700; }   .nav-links { display: flex; gap: 12px; align-items: center; }   .nav-links a { color: #ecf0f1; text-decoration: none; font-size: 14px; padding: 6px 10px; border-radius: 4px; transition: all 0.2s; }   .nav-links a:hover { background: rgba(255,255,255,0.12); color: #42b883; }   .lang-switcher { display: flex; gap: 6px; margin-left: 10px; }   .lang-btn { background: rgba(255,255,255,0.08); color: #ecf0f1; border: 1px solid rgba(255,255,255,0.2); padding: 4px 8px; font-size: 12px; border-radius: 4px; cursor: pointer; }   .lang-btn:hover { background: rgba(255,255,255,0.2); }   .lang-btn.active-lang { background: #42b883; color: white; border-color: #42b883; font-weight: bold; }   .theme-switcher { display: flex; align-items: center; gap: 6px; margin-left: 6px; }   .theme-toggle-btn { background: rgba(255,255,255,0.08); color: #ecf0f1; border: 1px solid rgba(255,255,255,0.2); padding: 4px 8px; font-size: 13px; border-radius: 4px; cursor: pointer; }   .theme-toggle-btn:hover { background: rgba(255,255,255,0.2); }   .theme-select { background: #1a252f; color: #ecf0f1; border: 1px solid rgba(255,255,255,0.2); padding: 4px 6px; font-size: 12px; border-radius: 4px; outline: none; cursor: pointer; }   .nav-msg { margin-left: auto; color: #95a5a6; font-size: 13px; }   .container { max-width: 900px; margin: 24px auto; padding: 0 20px; }   .footer-status { position: fixed; bottom: 0; left: 0; width: 100%; background: #2c3e50; color: #42b883; font-size: 11px; padding: 4px 10px; text-align: right; }   h1, h2, h3 { margin-bottom: 12px; }   .section { background: white; border-radius: 12px; padding: 24px; margin-bottom: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); }   .section-title { color: #42b883; border-bottom: 2px solid #42b883; padding-bottom: 8px; margin-bottom: 16px; }   button { padding: 8px 16px; border: none; border-radius: 6px; cursor: pointer; font-size: 14px; margin: 4px; }   .btn-primary { background: #42b883; color: white; }   .btn-primary:hover { background: #38a373; }   .btn-danger { background: #e74c3c; color: white; }   .btn-outline { background: white; border: 2px solid #42b883; color: #42b883; }   .btn-outline:hover { background: #42b883; color: white; }   input[type="text"] { width: 100%; padding: 10px; border: 2px solid #ddd; border-radius: 6px; font-size: 14px; margin: 6px 0; }   input[type="text"]:focus { border-color: #42b883; outline: none; }   table { width: 100%; border-collapse: collapse; margin: 12px 0; }   th, td { padding: 10px 14px; border: 1px solid #eee; text-align: left; }   th { background: #f8f9fa; font-weight: 600; }   .badge { display: inline-block; padding: 3px 10px; border-radius: 12px; color: white; font-weight: bold; font-size: 13px; }   .badge-green { background: #42b883; }   .badge-blue { background: #3498db; }   .badge-orange { background: #e67e22; }   .badge-gray { background: #95a5a6; }   code { background: #f0f0f0; padding: 2px 6px; border-radius: 3px; font-family: ''Consolas'', monospace; font-size: 13px; }   hr { border: none; border-top: 1px solid #eee; margin: 16px 0; }    /* Dark Mode & Bootswatch Integration */   html[data-bs-theme="dark"] body, body.theme-dark {     background: var(--bs-body-bg, #1a1a1a);     color: var(--bs-body-color, #e0e0e0);   }   html[data-bs-theme="dark"] .section, body.theme-dark .section {     background: var(--bs-card-bg, #22252a);     color: var(--bs-body-color, #e0e0e0);     box-shadow: 0 2px 8px rgba(0,0,0,0.4);     border: 1px solid rgba(255,255,255,0.08);   }   html[data-bs-theme="dark"] input[type="text"], body.theme-dark input[type="text"] {     background: #2b3035;     color: #fff;     border-color: #444;   }   html[data-bs-theme="dark"] table, body.theme-dark table {     color: #e0e0e0;   }   html[data-bs-theme="dark"] th, body.theme-dark th {     background: #2b3035;     border-color: #3e444a;   }   html[data-bs-theme="dark"] td, body.theme-dark td {     border-color: #3e444a;   }   html[data-bs-theme="dark"] .footer-status, body.theme-dark .footer-status {     background: #181b1e;     color: #42b883;     border-top: 1px solid rgba(255,255,255,0.1);   }';
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
  asm console.log("[Init] Registering uShowcase..."); end;
  Register_uShowcase;
  asm console.log("[Init] Registering uUserProfile..."); end;
  Register_uUserProfile;
  asm console.log("[Init] Registering uBVAccordion..."); end;
  Register_uBVAccordion;
  asm console.log("[Init] Registering uBVAlert..."); end;
  Register_uBVAlert;
  asm console.log("[Init] Registering uBVBadge..."); end;
  Register_uBVBadge;
  asm console.log("[Init] Registering uBVBar..."); end;
  Register_uBVBar;
  asm console.log("[Init] Registering uBVBreadcrumb..."); end;
  Register_uBVBreadcrumb;
  asm console.log("[Init] Registering uBVBreadcrumbItem..."); end;
  Register_uBVBreadcrumbItem;
  asm console.log("[Init] Registering uBVBtn..."); end;
  Register_uBVBtn;
  asm console.log("[Init] Registering uBVCard..."); end;
  Register_uBVCard;
  asm console.log("[Init] Registering uBVChart..."); end;
  Register_uBVChart;
  asm console.log("[Init] Registering uBVDataGrid..."); end;
  Register_uBVDataGrid;
  asm console.log("[Init] Registering uBVDoughnut..."); end;
  Register_uBVDoughnut;
  asm console.log("[Init] Registering uBVFormSelect..."); end;
  Register_uBVFormSelect;
  asm console.log("[Init] Registering uBVIcon..."); end;
  Register_uBVIcon;
  asm console.log("[Init] Registering uBVInput..."); end;
  Register_uBVInput;
  asm console.log("[Init] Registering uBVInputGroup..."); end;
  Register_uBVInputGroup;
  asm console.log("[Init] Registering uBVLine..."); end;
  Register_uBVLine;
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
  asm console.log("[Init] Registering uBVPie..."); end;
  Register_uBVPie;
  asm console.log("[Init] Registering uBVPolarArea..."); end;
  Register_uBVPolarArea;
  asm console.log("[Init] Registering uBVProgress..."); end;
  Register_uBVProgress;
  asm console.log("[Init] Registering uBVRadar..."); end;
  Register_uBVRadar;
  asm console.log("[Init] Registering uBVSpinner..."); end;
  Register_uBVSpinner;
  asm console.log("[Init] Registering uBVTab..."); end;
  Register_uBVTab;
  asm console.log("[Init] Registering uBVTabs..."); end;
  Register_uBVTabs;
  asm console.log("[Init] Registering uBVToast..."); end;
  Register_uBVToast;
  asm console.log("[Init] Registering uBVThemeSelect..."); end;
  Register_uBVThemeSelect;
  asm console.log("[Init] Registering uBVThemeToggle..."); end;
  Register_uBVThemeToggle;


  asm console.log("[Init] Setting #app template..."); end;
  TJSHTMLElement(document.querySelector('#app')).innerHTML :=
    '  <div translate="no" class="notranslate">' +
    '    <nav class="navbar">' +
    '      <strong class="brand">BlaiseVue Demo 2.5</strong>' +
    '      <div class="nav-links">' +
    '        <a href="#/">{{ $t(''nav.home'') }}</a>' +
    '        <a href="#/about">{{ $t(''nav.about'') }}</a>' +
    '        <a href="#/pro">{{ $t(''nav.pro'') }}</a>' +
    '        <a href="#/form">{{ $t(''nav.form'') }}</a>' +
    '        <a href="#/bootstrap">{{ $t(''nav.blaiseui'') }}</a>' +
    '        <a href="#/charts" style="background: #42b883; color: white;">{{ $t(''nav.charts'') }}</a>' +
    '        <a href="#/showcase" style="background: #3498db; color: white;">{{ $t(''nav.showcase'') }}</a>' +
    '      </div>' +
    '      <div class="lang-switcher">' +
    '        <button class="lang-btn" :class="{ ''active-lang'': $i18n.locale === ''pt'' }" @click="$setLocale(''pt'')">🇧🇷 PT</button>' +
    '        <button class="lang-btn" :class="{ ''active-lang'': $i18n.locale === ''en'' }" @click="$setLocale(''en'')">🇺🇸 EN</button>' +
    '      </div>' +
    '      <div class="theme-switcher">' +
    '        <button class="theme-toggle-btn" @click="$theme.toggle()" :title="$theme.isDark ? ''Modo Claro'' : ''Modo Escuro''">' +
    '          <span v-if="$theme.isDark">☀️</span>' +
    '          <span v-if="!$theme.isDark">🌙</span>' +
    '        </button>' +
    '        <select class="theme-select" :value="$theme.current" @change="onThemeSelect($event)">' +
    '          <option value="flatly">Flatly</option>' +
    '          <option value="cosmo">Cosmo</option>' +
    '          <option value="lux">Lux</option>' +
    '          <option value="zephyr">Zephyr</option>' +
    '          <option value="darkly">Darkly</option>' +
    '          <option value="cyborg">Cyborg</option>' +
    '          <option value="solar">Solar</option>' +
    '          <option value="vapor">Vapor</option>' +
    '          <option value="pulse">Pulse</option>' +
    '        </select>' +
    '      </div>' +
    '      <span class="nav-msg">{{ mensagem }}</span>' +
    '    </nav>' +
    '    <div class="container">' +
    '      <!-- The router-view tag is replaced by the component matching the current hash -->' +
    '      <router-view></router-view>' +
    '    </div>' +
    '    <div class="footer-status">' +
    '       {{ $t(''status.globalStore'') }}: {{ $store.appVersion }} | {{ $t(''status.localeActive'') }}: <strong>{{ $i18n.locale.toUpperCase() }}</strong> | {{ $t(''status.theme'') }}: <strong>{{ $theme.current.toUpperCase() }}</strong> | Dev: {{ $store.user }}' +
    '    </div>' +
    '  </div>';

  data := TJSObject.new;
  data['mensagem'] := 'BlaiseVue SPA v2.5 ENTERPRISE';

  methods := TJSObject.new;
  m['onThemeSelect'] := procedure(_this: TJSObject; e: JSValue)

    var
      sel: string;
    begin
      sel := string(TJSObject(TJSObject(e)['target'])['value']);
      if sel <> '' then
      begin
        asm
          if (window.$theme) window.$theme.setTheme(sel);
        end;
      end;
    end;
  { Router Configuration: Maps URI hashes to Component Tags }


  opts := TJSObject.new;
  comp := opts;
  comp['created'] := procedure(_this: TJSObject)
    begin
      TJSObject(_this['$store'])['appVersion'] := '2.5.0-ENTERPRISE';
      TJSObject(_this['$store'])['user'] := 'DevMaster 🏆';
      asm
        if (window.__BV_CORE__.i18n) {
          window.__BV_CORE__.i18n.addMessages('pt', {
            nav: {
              home: 'Início',
              about: 'Sobre',
              pro: 'Pro Features 🛡️',
              form: 'Formulário 📋',
              blaiseui: 'BlaiseUI Kit 🎨',
              charts: 'Gráficos 📊',
              showcase: 'Showcase ✨'
            },
            status: {
              globalStore: 'Memória Global',
              localeActive: 'Idioma Ativo',
              theme: 'Tema'
            },
            form: {
              title: 'Formulário de Validação Reativa',
              subtitle: 'Demonstração de b-validate, $errors e $v no BlaiseVue 2.5',
              name: 'Nome Completo',
              email: 'E-mail Corporativo',
              city: 'Cidade',
              submit: 'Validar & Enviar 🚀',
              reset: 'Limpar Formulário 🔄',
              fillValid: 'Preencher Válido ✨',
              statusValid: 'Válido ✅',
              statusInvalid: 'Inválido ❌',
              formState: 'Status do Formulário'
            },
            pro: {
              title: '🛡️ BlaiseVue 2.5 Pro: Novas Fronteiras',
              transitionTitle: '🎬 Lista com Animações FLIP (<transition-group>)',
              shuffle: 'Embaralhar 🔀',
              add: 'Adicionar Item ➕',
              remove: 'Remover Primeiro ➖',
              resetList: 'Resetar Lista 🔄'
            }
          });
          window.__BV_CORE__.i18n.addMessages('en', {
            nav: {
              home: 'Home',
              about: 'About',
              pro: 'Pro Features 🛡️',
              form: 'Form 📋',
              blaiseui: 'BlaiseUI Kit 🎨',
              charts: 'Charts 📊',
              showcase: 'Showcase ✨'
            },
            status: {
              globalStore: 'Global Store',
              localeActive: 'Active Locale',
              theme: 'Theme'
            },
            form: {
              title: 'Reactive Form Validation',
              subtitle: 'Demonstrating b-validate, $errors, and $v in BlaiseVue 2.5',
              name: 'Full Name',
              email: 'Corporate Email',
              city: 'City',
              submit: 'Validate & Submit 🚀',
              reset: 'Reset Form 🔄',
              fillValid: 'Fill Valid Sample ✨',
              statusValid: 'Valid ✅',
              statusInvalid: 'Invalid ❌',
              formState: 'Form Status'
            },
            pro: {
              title: '🛡️ BlaiseVue 2.5 Pro: New Frontiers',
              transitionTitle: '🎬 FLIP List Transitions (<transition-group>)',
              shuffle: 'Shuffle 🔀',
              add: 'Add Item ➕',
              remove: 'Remove First ➖',
              resetList: 'Reset List 🔄'
            }
          });
          window.__BV_CORE__.i18n.setLocale('pt');
        }
      end;
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

  r := TJSObject.new;
  r['path'] := '/showcase';
  r['component'] := 'showcase-page';
  routesArr.push(r);

  routerOpts['routes'] := routesArr;
  router := TBVRouter.Create(routerOpts);

  app := TBlaiseVue.Create('#app', data, methods, opts);
  app.UseRouter(router);
end;

end.
