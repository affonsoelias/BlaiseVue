unit uHome;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils, BVPascalDX;

procedure Register_uHome;

implementation

procedure Register_uHome;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  _styleEl := TJSHTMLElement(document.createElement('style'));
  _styleEl.textContent := '.home-page { padding: 20px; }   .section { margin-top: 24px; padding: 20px; border-left: 4px solid #42b883; background: #fff; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }   .alert-box { margin-top: 10px; padding: 15px; background: #42b883; color: white; border-radius: 8px; }      { Transition Classes: Managed by the BVCompiler transition engine }   .fade-enter-active, .fade-leave-active { transition: opacity 0.5s ease; }   .fade-enter-from, .fade-leave-to { opacity: 0; }';
  document.head.appendChild(_styleEl);
  comp := TJSObject.new;
  comp['template'] :=
    '  <div class="home-page">' +
    '    <h2>🏠 Home: Control Panel (BlaiseVue Features)</h2>' +
    '    <p>{{ descricao }}</p>' +
    '' +
    '    { 1. Slots & Composition }' +
    '    <card>' +
    '      <template slot="header">🎨 Composition via Slots</template>' +
    '      <p>This ''Card'' component uses named slots for the header and default slots for the body.</p>' +
    '    </card>' +
    '' +
    '    { 2. Form Reactivity (B-Model) }' +
    '    <div class="section">' +
    '      <h3>✍️ Data Synchronization (B-Model)</h3>' +
    '      <input type="text" b-model="userName" placeholder="Your name...">' +
    '      <p>Welcome, <b>{{ userName }}</b>!</p>' +
    '    </div>' +
    '' +
    '    { 3. Global Store (B-Store) }' +
    '    <div class="section">' +
    '      <h3>🌍 Global Store (B-Store)</h3>' +
    '      <p>Framework Version: <badge-blue>{{ $store.appVersion }}</badge-blue></p>' +
    '      <p>Current User: <b>{{ $store.user }}</b></p>' +
    '    </div>' +
    '' +
    '    { 4. Transitions }' +
    '    <div class="section">' +
    '      <h3>✨ Animations & Transitions</h3>' +
    '      <button @click="toggleVisible">Toggle Visibility</button>' +
    '      <transition name="fade">' +
    '        <div v-show="isVisible" class="alert-box">' +
    '           Fade Effect Active! 👻' +
    '        </div>' +
    '      </transition>' +
    '    </div>' +
    '' +
    '    { 5. Provide and Inject }' +
    '    <info-card>' +
    '       <template slot="title">Dependency Injection (Provide/Inject)</template>' +
    '       The <b>Provide/Inject</b> feature allows this component to receive data from distant ancestors without needing manual properties at every level.' +
    '    </info-card>' +
    '' +
    '    { 6. Themes & Icons (Blaise-Themes & Blaise-Icons) }' +
    '    <div class="section">' +
    '      <h3>🎨 Dynamic Themes & Vector Icons (v2.6)</h3>' +
    '      <p>Current Active Theme: <b>{{ $theme.current }}</b> (Dark Mode: <b>{{ $theme.isDark ? ''Active 🌙'' : ''Inactive ☀️'' }}</b>)</p>' +
    '      <div style="display: flex; gap: 8px; align-items: center; margin: 12px 0;">' +
    '        <bv-theme-toggle></bv-theme-toggle>' +
    '        <bv-theme-select></bv-theme-select>' +
    '      </div>' +
    '      <div style="display: flex; gap: 16px; align-items: center; margin-top: 12px; flex-wrap: wrap;">' +
    '        <div style="display: flex; align-items: center; gap: 6px;"><bv-icon name="check-circle" size="22" color="#42b883"></bv-icon> <span>check-circle</span></div>' +
    '        <div style="display: flex; align-items: center; gap: 6px;"><bv-icon name="star-fill" size="22" color="#f1c40f"></bv-icon> <span>star-fill</span></div>' +
    '        <div style="display: flex; align-items: center; gap: 6px;"><bv-icon name="heart-fill" size="22" color="#e74c3c"></bv-icon> <span>heart-fill</span></div>' +
    '        <div style="display: flex; align-items: center; gap: 6px;"><bv-icon name="shield-check" size="22" color="#3498db"></bv-icon> <span>shield-check</span></div>' +
    '        <div style="display: flex; align-items: center; gap: 6px;"><bv-icon name="gear-fill" size="22" color="#95a5a6"></bv-icon> <span>gear-fill</span></div>' +
    '      </div>' +
    '    </div>' +
    '  </div>';

  comp['data'] := function(): TJSObject
  var d: TJSObject;
  begin
    d := TJSObject.new;
    d['descricao'] := 'Welcome to the Framework test center. Below are the main features.';
    d['userName'] := 'Pascal Developer';
    d['isVisible'] := true;
    Result := d;
  end;


  m := TJSObject.new;
  m['toggleVisible'] := procedure(_this: TJSObject)

    begin
       _this['isVisible'] := not boolean(_this['isVisible']);
    end;

  comp['methods'] := m;

  RegisterComponent('home-page', comp);
end;

end.
