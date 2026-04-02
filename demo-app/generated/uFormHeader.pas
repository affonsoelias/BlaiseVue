unit uFormHeader;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uFormHeader;

implementation

procedure Register_uFormHeader;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  _styleEl := TJSHTMLElement(document.createElement('style'));
  _styleEl.textContent := '.form-header { margin-bottom: 24px; padding: 12px; border-left: 4px solid #42b883; background-color: rgba(66, 184, 131, 0.05); border-radius: 0 8px 8px 0; cursor: pointer; transition: background 0.3s; }   .form-header:hover { background-color: rgba(66, 184, 131, 0.1); }   .form-header-title { color: inherit !important; margin: 0; font-size: 1.5rem; }   .form-header-subtitle { color: inherit !important; opacity: 0.8; margin: 4px 0 0 0; font-size: 0.9rem; }   .form-header-line { height: 2px; background: rgba(128,128,128,0.2); margin-top: 12px; }';
  document.head.appendChild(_styleEl);
  comp := TJSObject.new;
  comp['template'] :=
    '  <div class="form-header">' +
    '    <h2 class="form-header-title" @click="headerClick">{{ title }}</h2>' +
    '    <p class="form-header-subtitle">{{ subtitle }}</p>' +
    '    <div class="form-header-line"></div>' +
    '  </div>';

  comp['data'] := function(): TJSObject
  var d: TJSObject;
  begin
    d := TJSObject.new;
    d['title'] := 'Formulario do Sistema';
    d['subtitle'] := 'Preencha os campos abaixo para atualizar o estado reativo.';
    Result := d;
  end;

  m := TJSObject.new;
  m['headerClick'] := procedure(_this: TJSObject)

    begin
      TJSFunction(_this['$emit']).call(_this, 'header-clicked', 'Ola do Header!');
    end;

  comp['methods'] := m;


  RegisterComponent('form-header', comp);
end;

end.
