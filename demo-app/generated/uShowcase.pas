unit uShowcase;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uShowcase;

implementation

procedure Register_uShowcase;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  _styleEl := TJSHTMLElement(document.createElement('style'));
  _styleEl.textContent := '.showcase-container { max-width: 1000px; margin: 20px auto; padding: 30px; border-radius: 12px; border-left: 5px solid #2ecc71 !important; box-shadow: 0 4px 15px rgba(0,0,0,0.1); }   .showcase-header { border-bottom: 2px solid #2ecc71; margin-bottom: 25px; padding-bottom: 10px; }   .section-card { background-color: rgba(128,128,128,0.08); padding: 20px; border-radius: 10px; margin-bottom: 30px; border-left: 4px solid #3498db; }   .icon-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(120px, 1fr)); gap: 15px; margin-top: 15px; }   .icon-box { background-color: rgba(128,128,128,0.05); padding: 15px; border-radius: 8px; text-align: center; border: 1px solid rgba(128,128,128,0.1); }   .text-primary { color: #0d6efd !important; }   .text-success { color: #198754 !important; }   .text-warning { color: #ffc107 !important; }   .text-danger { color: #dc3545 !important; }   .text-info { color: #0dcaf0 !important; }   .text-secondary { color: #6c757d !important; }';
  document.head.appendChild(_styleEl);
  comp := TJSObject.new;
  comp['template'] :=
    '  <div class="showcase-container">' +
    '    <div class="showcase-header">' +
    '      <h1>Showcase: Local Assets 🛡️</h1>' +
    '      <p>Fonte atual: <strong>Inter & Outfit</strong> (100% Local)</p>' +
    '    </div>' +
    '' +
    '    <!-- Galeria de Ícones -->' +
    '    <div class="section-card">' +
    '      <h3>Galeria de Ícones (Inline Local SVGs)</h3>' +
    '      <div class="icon-grid">' +
    '        <div class="icon-box">' +
    '          <b-icon name="bootstrap-fill" size="32" class="text-primary" />' +
    '          <div class="small mt-1">bootstrap-fill</div>' +
    '        </div>' +
    '        <div class="icon-box">' +
    '          <b-icon name="check-circle" size="32" class="text-success" />' +
    '          <div class="small mt-1">check-circle</div>' +
    '        </div>' +
    '        <div class="icon-box">' +
    '          <b-icon name="warning" size="32" class="text-warning" />' +
    '          <div class="small mt-1">warning</div>' +
    '        </div>' +
    '        <div class="icon-box">' +
    '          <b-icon name="gear-fill" size="32" class="text-secondary" />' +
    '          <div class="small mt-1">gear-fill</div>' +
    '        </div>' +
    '        <div class="icon-box">' +
    '          <b-icon name="heart-fill" size="32" class="text-danger" />' +
    '          <div class="small mt-1">heart-fill</div>' +
    '        </div>' +
    '        <div class="icon-box">' +
    '          <b-icon name="weather" size="32" class="text-info" />' +
    '          <div class="small mt-1">weather</div>' +
    '        </div>' +
    '        <div class="icon-box">' +
    '          <b-icon name="code-slash" size="32" class="text-dark" />' +
    '          <div class="small mt-1">code-slash</div>' +
    '        </div>' +
    '        <div class="icon-box">' +
    '          <b-icon name="cpu" size="32" class="text-primary" />' +
    '          <div class="small mt-1">cpu</div>' +
    '        </div>' +
    '      </div>' +
    '    </div>' +
    '' +
    '    <!-- Seletor de Temas -->' +
    '    <div class="section-card">' +
    '      <h3>Seletor de Temas (Dynamic CSS)</h3>' +
    '      <div class="theme-buttons d-flex gap-2 flex-wrap">' +
    '        <button class="btn btn-outline-secondary" @click="handleTheme(''default'')">Padrão</button>' +
    '        <button class="btn btn-primary" @click="handleTheme(''darkly'')">Darkly</button>' +
    '        <button class="btn btn-success" @click="handleTheme(''flatly'')">Flatly</button>' +
    '        <button class="btn btn-info" @click="handleTheme(''cosmo'')">Cosmo</button>' +
    '      </div>' +
    '      <div class="mt-3">' +
    '         Tema Selecionado: <span class="badge bg-secondary">{{ currentThemeName }}</span>' +
    '      </div>' +
    '    </div>' +
    '  </div>';

  comp['data'] := function(): TJSObject
  var d: TJSObject;
  begin
    d := TJSObject.new;
    d['currentThemeName'] := 'default';
    Result := d;
  end;

  m := TJSObject.new;
  m['handleTheme'] := procedure(_this: TJSObject; ATheme: string)

    begin
      asm
         var link = document.getElementById('theme-link');
         if (link) {
            if (ATheme === 'default') {
              link.href = 'css/lib/bootstrap.css';
            } else {
              link.href = 'assets/themes/' + ATheme + '.min.css';
            }
            document.body.className = 'theme-' + ATheme;
            document.head.appendChild(link);
            console.log('BlaiseVue: Tema ' + ATheme + ' aplicado.');
         }
      end;
      _this['currentThemeName'] := ATheme;
    end;

  comp['methods'] := m;


  RegisterComponent('showcase-page', comp);
end;

end.
