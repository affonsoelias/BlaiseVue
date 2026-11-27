unit uCard;

{$mode objfpc}
{$modeswitch externalclass}
{$COPERATORS ON}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, BVFSM, SysUtils, BVPascalDX, BVDataSet;

procedure Register_uCard;

implementation

type
  TComponentThis = class external name 'Object' (TJSObject)
    titulo: string;
    temFooter: Boolean;
    footerTexto: string;
  end;

procedure Register_uCard;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  _styleEl := TJSHTMLElement(document.createElement('style'));
  _styleEl.textContent := '.bv-card { border-radius: 12px; background: var(--bv-surface); box-shadow: var(--bv-shadow); margin-bottom: 20px; overflow: hidden; border: 1px solid var(--bv-border); color: var(--bv-text); }   .bv-card-header { background: var(--bv-surface-subtle); padding: 12px 20px; border-bottom: 1px solid var(--bv-border); color: var(--bv-text); font-size: 16px; font-weight: 600; }   .bv-card-body { padding: 20px; color: var(--bv-text); }   .bv-card-footer { background: var(--bv-surface-subtle); padding: 10px 20px; font-size: 12px; color: var(--bv-text-muted); border-top: 1px solid var(--bv-border); }';
  document.head.appendChild(_styleEl);
  comp := TJSObject.new;
  comp['template'] :=
    '  <div class="bv-card">' +
    '    <div class="bv-card-header">' +
    '      <slot name="header"><strong>{{ titulo }}</strong></slot>' +
    '    </div>' +
    '    <div class="bv-card-body">' +
    '      <!-- SLOT: O buraco mágico para conteúdo externo -->' +
    '      <slot></slot>' +
    '    </div>' +
    '    <div class="bv-card-footer">' +
    '      <slot name="footer"></slot>' +
    '    </div>' +
    '  </div>';

  comp['data'] := function(): TJSObject
  var d: TJSObject;
  begin
    d := TJSObject.new;
    d['titulo'] := 'Título do Card';
    d['temFooter'] := False;
    d['footerTexto'] := 'Rodapé Padrão';
    Result := d;
  end;


  m := TJSObject.new;
  comp['methods'] := m;

  RegisterComponent('card', comp);
end;

end.
