unit uHome;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

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
