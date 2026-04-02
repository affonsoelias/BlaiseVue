unit uFormulario;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uFormulario;

implementation

procedure Register_uFormulario;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  _styleEl := TJSHTMLElement(document.createElement('style'));
  _styleEl.textContent := 'label { display: block; margin-top: 12px; margin-bottom: 4px; color: #555; }';
  document.head.appendChild(_styleEl);
  comp := TJSObject.new;
  comp['template'] :=
    '  <div>' +
    '    <div class="section">' +
    '      <!-- 1. Passando props e escutando eventos -->' +
    '      <form-header ' +
    '        ref="headerComp"' +
    '        title="Formulario Especial" ' +
    '        :subtitle="meuSub"' +
    '        @header-clicked="onHeaderClick">' +
    '      </form-header>' +
    '      ' +
    '      <p>Este formulario demonstra o <code>b-model</code> (two-way data binding), <code>props</code>, <code>$refs</code> e <code>$emit</code>.</p>' +
    '      <p>Todos os campos abaixo atualizam em tempo real.</p>' +
    '      <button class="btn-outline" @click="mudarHeaderRef">Usar $refs no Header</button>' +
    '      <p>Mensagem do Header: <strong>{{ msgHeader }}</strong></p>' +
    '    </div>' +
    '' +
    '    <div class="section">' +
    '      <h2 class="section-title">Dados Pessoais</h2>' +
    '      <label><strong>Nome:</strong></label>' +
    '      <input type="text" b-model="nome">' +
    '' +
    '      <label><strong>Email:</strong></label>' +
    '      <input type="text" b-model="email">' +
    '' +
    '      <label><strong>Cidade:</strong></label>' +
    '      <input type="text" b-model="cidade">' +
    '    </div>' +
    '' +
    '    <div class="section">' +
    '      <h2 class="section-title">Preview dos Dados</h2>' +
    '      <table>' +
    '        <tr><th>Campo</th><th>Valor</th></tr>' +
    '        <tr><td>Nome</td><td><strong>{{ nome }}</strong></td></tr>' +
    '        <tr><td>Email</td><td><strong>{{ email }}</strong></td></tr>' +
    '        <tr><td>Cidade</td><td><strong>{{ cidade }}</strong></td></tr>' +
    '      </table>' +
    '      <hr>' +
    '      <button class="btn-primary" @click="preencher">Preencher Exemplo</button>' +
    '      <button class="btn-danger" @click="limpar">Limpar Tudo</button>' +
    '    </div>' +
    '  </div>';

  comp['data'] := function(): TJSObject
  var d: TJSObject;
  begin
    d := TJSObject.new;
    d['nome'] := '';
    d['email'] := '';
    d['cidade'] := '';
    d['meuSub'] := 'Este subtitulo e reativo do pai!';
    d['msgHeader'] := '(clique no titulo do header)';
    Result := d;
  end;

  m := TJSObject.new;
  m['onHeaderClick'] := procedure(_this: TJSObject; arg: string)

    begin
      _this['msgHeader'] := arg;
      _this['meuSub'] := 'O subtitulo mudou reativamente via props!';
    end;
    
  m['mudarHeaderRef'] := procedure(_this: TJSObject)

    var
      refs, header: TJSObject;
    begin
      refs := TJSObject(_this['$refs']);
      if Assigned(refs) then
      begin
        header := TJSObject(refs['headerComp']);
        if Assigned(header) then
           header['title'] := 'Titulo alterado via $refs!';
      end;
    end;
    
  m['preencher'] := procedure(_this: TJSObject)

    begin
      _this['nome'] := 'Blaise Pascal'; 
      _this['email'] := 'blaise@pascal.dev'; 
      _this['cidade'] := 'Clermont-Ferrand';
    end;
    
  m['limpar'] := procedure(_this: TJSObject)

    begin
      _this['nome'] := ''; 
      _this['email'] := ''; 
      _this['cidade'] := '';
    end;

  comp['methods'] := m;


  RegisterComponent('formulario-page', comp);
end;

end.
