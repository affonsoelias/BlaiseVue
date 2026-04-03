unit uCard;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uCard;

implementation

procedure Register_uCard;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  _styleEl := TJSHTMLElement(document.createElement('style'));
  _styleEl.textContent := '.bv-card { border-radius: 12px; background: white; box-shadow: 0 4px 12px rgba(0,0,0,0.1); margin-bottom: 20px; overflow: hidden; border: 1px solid #eee; }   .bv-card-header { background: #f8f9fa; padding: 12px 20px; border-bottom: 1px solid #eee; color: #2c3e50; font-size: 16px; }   .bv-card-body { padding: 20px; color: #444; }   .bv-card-footer { background: #fdfdfd; padding: 10px 20px; font-size: 12px; color: #95a5a6; border-top: 1px solid #f0f0f0; }';
  document.head.appendChild(_styleEl);
  comp := TJSObject.new;
  comp['template'] :=
    '  <div class="bv-card">' +
    '    <div class="bv-card-header">' +
    '       <slot name="header"><strong>{{ titulo }}</strong></slot>' +
    '    </div>' +
    '    <div class="bv-card-body">' +
    '       <!-- SLOT: O buraco mágico para conteúdo externo -->' +
    '       <slot></slot>' +
    '    </div>' +
    '    <div class="bv-card-footer">' +
    '       <slot name="footer"></slot>' +
    '    </div>' +
    '  </div>';

  comp['data'] := function(): TJSObject
  var d: TJSObject;
  begin
    d := TJSObject.new;
    d['titulo'] := 'Título do Card';
    d['temFooter'] := false;
    d['footerTexto'] := 'Rodapé Padrão';
    Result := d;
  end;


  m := TJSObject.new;
  comp['methods'] := m;


  RegisterComponent('card', comp);
end;

end.
