unit uHome;

{$mode objfpc}
{$modeswitch externalclass}
{$COPERATORS ON}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, BVFSM, SysUtils, BVPascalDX, BVDataSet;

procedure Register_uHome;

implementation

type
  TComponentThis = class external name 'Object' (TJSObject)
    descricao: string;
    userName: string;
    isVisible: Boolean;
  end;

procedure Register_uHome;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  _styleEl := TJSHTMLElement(document.createElement('style'));
  _styleEl.textContent := '.home-page { padding: 0; }   .home-page .section { margin-top: 20px; padding: 20px; border-radius: 8px; border: 1px solid var(--bv-border); border-left: 4px solid #42b883; background: var(--bv-surface); box-shadow: var(--bv-shadow); }   .home-page .section h3 { margin: 0 0 10px 0; font-size: 17px; color: var(--bv-text); font-weight: 600; }   .home-page .alert-box { margin-top: 12px; padding: 14px 18px; background: #42b883; color: white; border-radius: 6px; font-weight: 600; }   .home-page .bui-input { max-width: 320px; }    /* Transition Classes: Managed by the BVCompiler transition engine */   .fade-enter-active, .fade-leave-active { transition: opacity 0.5s ease; }   .fade-enter-from, .fade-leave-to { opacity: 0; }';
  document.head.appendChild(_styleEl);
  comp := TJSObject.new;
  comp['template'] :=
    '  <div class="home-page">' +
    '    <div style="margin-bottom: 20px;">' +
    '      <h1 style="font-size: 24px; font-weight: 700; margin: 0 0 6px 0;">🏠 Dashboard &bull; Control Panel</h1>' +
    '      <p style="font-size: 14px; margin: 0;">{{ descricao }}</p>' +
    '    </div>' +
    '' +
    '    <!-- 1. Slots & Composition -->' +
    '    <card>' +
    '<template slot="header">🎨 Composition via Slots</template>' +
    '  <p>This ''Card'' component uses named slots for the header and default slots for the body.</p>' +
    '  </card>' +
    '' +
    '  <!-- 2. Form Reactivity (B-Model) -->' +
    '  <div class="section">' +
    '    <h3>✍️ Data Synchronization (B-Model)</h3>' +
    '    <div style="margin: 12px 0;">' +
    '      <input type="text" b-model="userName" class="bui-input" style="max-width: 320px;" placeholder="Your name...">' +
    '    </div>' +
    '    <p>Welcome, <strong>{{ userName }}</strong>!</p>' +
    '  </div>' +
    '' +
    '  <!-- 3. Global Store (B-Store) -->' +
    '  <div class="section">' +
    '    <h3>🌍 Global Store (B-Store)</h3>' +
    '    <p>Current Active Session: <strong>{{ $store.user }}</strong></p>' +
    '    <p style="font-size: 13px; margin-top: 4px;">Reactivity Layer: <strong>ECMAScript Proxy &amp; Microtask Scheduler</strong></p>' +
    '  </div>' +
    '' +
    '  <!-- 4. Transitions (MUST KEEP THIS BUTTON AS FIRST BUTTON FOR Home.test.pas) -->' +
    '  <div class="section">' +
    '    <h3>✨ Animations &amp; Transitions</h3>' +
    '    <button class="bui-btn bui-btn-primary" style="margin-top: 6px;" @click="toggleVisible">Toggle Visibility</button>' +
    '    <transition name="fade">' +
    '      <div v-show="isVisible" class="alert-box">' +
    '        Fade Effect Active! 👻' +
    '      </div>' +
    '    </transition>' +
    '  </div>' +
    '' +
    '  <!-- 5. Provide and Inject -->' +
    '  <info-card>' +
    '<template slot="title">Dependency Injection (Provide/Inject)</template>' +
    '  The <b>Provide/Inject</b> feature allows this component to receive data from distant ancestors without needing manual properties at every level.' +
    '  </info-card>' +
    '' +
    '  <!-- 6. Themes & Icons (Blaise-Themes & Blaise-Icons) -->' +
    '  <div class="section">' +
    '    <h3>🎨 Dynamic Themes &amp; Vector Icons</h3>' +
    '    <p>Current Active Theme: <strong>{{ $theme.current }}</strong> (Dark Mode: <strong>{{ $theme.isDark ? ''Active 🌙'' : ''Inactive ☀️'' }}</strong>)</p>' +
    '    <div style="display: flex; gap: 8px; align-items: center; margin: 12px 0;">' +
    '      <bv-theme-toggle></bv-theme-toggle>' +
    '      <bv-theme-select></bv-theme-select>' +
    '    </div>' +
    '    <div style="display: flex; gap: 16px; align-items: center; margin-top: 12px; flex-wrap: wrap;">' +
    '      <div style="display: flex; align-items: center; gap: 6px;"><bv-icon name="check-circle" size="22" color="#42b883"></bv-icon> <span>check-circle</span></div>' +
    '      <div style="display: flex; align-items: center; gap: 6px;"><bv-icon name="star-fill" size="22" color="#f1c40f"></bv-icon> <span>star-fill</span></div>' +
    '      <div style="display: flex; align-items: center; gap: 6px;"><bv-icon name="heart-fill" size="22" color="#e74c3c"></bv-icon> <span>heart-fill</span></div>' +
    '      <div style="display: flex; align-items: center; gap: 6px;"><bv-icon name="shield-check" size="22" color="#3498db"></bv-icon> <span>shield-check</span></div>' +
    '      <div style="display: flex; align-items: center; gap: 6px;"><bv-icon name="gear-fill" size="22" color="#95a5a6"></bv-icon> <span>gear-fill</span></div>' +
    '    </div>' +
    '  </div>' +
    '  </div>';

  comp['data'] := function(): TJSObject
  var d: TJSObject;
  begin
    d := TJSObject.new;
    d['descricao'] := 'Welcome to the Framework test center. Below are the main features.';
    d['userName'] := 'Pascal Developer';
    d['isVisible'] := True;
    Result := d;
  end;


  m := TJSObject.new;
  m['toggleVisible'] := procedure(_this: TJSObject)

    begin
      TComponentThis(_this).isVisible := not TComponentThis(_this).isVisible;
    end;

  comp['methods'] := m;

  RegisterComponent('home-page', comp);
end;

end.
