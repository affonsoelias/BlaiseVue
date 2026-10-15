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
  _styleEl.textContent := 'label { display: block; margin-top: 8px; margin-bottom: 4px; color: #555; }';
  document.head.appendChild(_styleEl);
  comp := TJSObject.new;
  comp['template'] :=
    '  <div>' +
    '    <div class="section">' +
    '      <!-- 1. Passando props e escutando eventos -->' +
    '      <form-header ' +
    '        ref="headerComp"' +
    '        title="Formulário Especial" ' +
    '        :subtitle="meuSub"' +
    '        @header-clicked="onHeaderClick">' +
    '      </form-header>' +
    '      ' +
    '      <p>Este formulário demonstra <code>b-model</code>, <code>props</code>, <code>$refs</code> e o novo <strong>Motor de Validação Tipada v2.5</strong> (<code>b-validate</code>, <code>$errors</code>, <code>$v</code>).</p>' +
    '      <p>Todos os campos abaixo validam e atualizam em tempo real.</p>' +
    '      <button class="btn-outline" @click="mudarHeaderRef">Usar $refs no Header</button>' +
    '      <p>Mensagem do Header: <strong>{{ msgHeader }}</strong></p>' +
    '    </div>' +
    '' +
    '    <div class="section">' +
    '      <h2 class="section-title">{{ $t(''form.title'') }}</h2>' +
    '      <p style="color: #64748b; margin-bottom: 14px;">{{ $t(''form.subtitle'') }}</p>' +
    '' +
    '      <div style="margin-bottom: 14px;">' +
    '        <label><strong>{{ $t(''form.name'') }}:</strong></label>' +
    '        <input type="text" b-model="nome" b-validate="required|min:3" placeholder="Digite seu nome (mín. 3 letras)">' +
    '        <span b-if="$errors.nome" class="bv-error-msg">⚠️ {{ $errors.nome }}</span>' +
    '      </div>' +
    '' +
    '      <div style="margin-bottom: 14px;">' +
    '        <label><strong>{{ $t(''form.email'') }}:</strong></label>' +
    '        <input type="text" b-model="email" b-validate="required|email" placeholder="usuario@dominio.com">' +
    '        <span b-if="$errors.email" class="bv-error-msg">⚠️ {{ $errors.email }}</span>' +
    '      </div>' +
    '' +
    '      <div style="margin-bottom: 14px;">' +
    '        <label><strong>{{ $t(''form.city'') }}:</strong></label>' +
    '        <input type="text" b-model="cidade" b-validate="required" placeholder="Sua cidade">' +
    '        <span b-if="$errors.cidade" class="bv-error-msg">⚠️ {{ $errors.cidade }}</span>' +
    '      </div>' +
    '' +
    '      <!-- Card de Status Reativo de $v -->' +
    '      <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 14px; margin-top: 16px;">' +
    '        <div style="display: flex; align-items: center; justify-content: space-between;">' +
    '          <span><strong>{{ $t(''form.formState'') }}:</strong></span>' +
    '          <span class="badge" :class="{ ''badge-green'': !$v.$invalid && $v.$dirty, ''badge-orange'': $v.$invalid, ''badge-gray'': !$v.$dirty }">' +
    '            {{ $v.$dirty ? ($v.$invalid ? $t(''form.statusInvalid'') : $t(''form.statusValid'')) : ''Não modificado'' }}' +
    '          </span>' +
    '        </div>' +
    '        <div style="font-size: 13px; color: #64748b; margin-top: 6px;">' +
    '          Dirty: <code>{{ $v.$dirty }}</code> | Invalid: <code>{{ $v.$invalid }}</code>' +
    '        </div>' +
    '      </div>' +
    '' +
    '      <div b-if="msgSucesso" style="margin-top: 15px; padding: 12px; background: #ecfdf5; border: 1px solid #10b981; border-radius: 6px; color: #065f46;">' +
    '        {{ msgSucesso }}' +
    '      </div>' +
    '' +
    '      <div style="margin-top: 16px;">' +
    '        <button class="btn-primary" @click="enviar">{{ $t(''form.submit'') }}</button>' +
    '        <button class="btn-outline" @click="preencher">{{ $t(''form.fillValid'') }}</button>' +
    '        <button class="btn-danger" @click="limpar">{{ $t(''form.reset'') }}</button>' +
    '      </div>' +
    '    </div>' +
    '' +
    '    <div class="section">' +
    '      <h2 class="section-title">Preview dos Dados & Validação</h2>' +
    '      <table>' +
    '        <tr><th>Campo</th><th>Valor</th><th>Status</th></tr>' +
    '        <tr>' +
    '          <td>Nome</td>' +
    '          <td><strong>{{ nome }}</strong></td>' +
    '          <td><span class="badge" :class="{ ''badge-green'': !$errors.nome && nome, ''badge-orange'': $errors.nome, ''badge-gray'': !nome }">{{ $errors.nome ? ''Erro'' : (nome ? ''OK'' : ''Pendente'') }}</span></td>' +
    '        </tr>' +
    '        <tr>' +
    '          <td>Email</td>' +
    '          <td><strong>{{ email }}</strong></td>' +
    '          <td><span class="badge" :class="{ ''badge-green'': !$errors.email && email, ''badge-orange'': $errors.email, ''badge-gray'': !email }">{{ $errors.email ? ''Erro'' : (email ? ''OK'' : ''Pendente'') }}</span></td>' +
    '        </tr>' +
    '        <tr>' +
    '          <td>Cidade</td>' +
    '          <td><strong>{{ cidade }}</strong></td>' +
    '          <td><span class="badge" :class="{ ''badge-green'': !$errors.cidade && cidade, ''badge-orange'': $errors.cidade, ''badge-gray'': !cidade }">{{ $errors.cidade ? ''Erro'' : (cidade ? ''OK'' : ''Pendente'') }}</span></td>' +
    '        </tr>' +
    '      </table>' +
    '    </div>' +
    '  </div>';

  comp['data'] := function(): TJSObject
  var d: TJSObject;
  begin
    d := TJSObject.new;
    d['nome'] := '';
    d['email'] := '';
    d['cidade'] := '';
    d['meuSub'] := 'Este subtítulo é reativo do pai!';
    d['msgHeader'] := '(clique no título do header)';
    d['msgSucesso'] := '';
    Result := d;
  end;


  m := TJSObject.new;
  m['onHeaderClick'] := procedure(_this: TJSObject; arg: string)

    begin
      _this['msgHeader'] := arg;
      _this['meuSub'] := 'O subtítulo mudou reativamente via props!';
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
           header['title'] := 'Título alterado via $refs!';
      end;
    end;
    
  m['enviar'] := procedure(_this: TJSObject)

    var
      valido: Boolean;
    begin
      asm
        valido = this.$validate ? this.$validate() : true;
      end;
      if valido then
      begin
        _this['msgSucesso'] := '🎉 Parabéns ' + string(_this['nome']) + '! Formulário validado com sucesso.';
      end
      else
      begin
        _this['msgSucesso'] := '';
      end;
    end;
    
  m['preencher'] := procedure(_this: TJSObject)

    begin
      _this['nome'] := 'Blaise Pascal'; 
      _this['email'] := 'blaise@pascal.dev'; 
      _this['cidade'] := 'Clermont-Ferrand';
      _this['msgSucesso'] := '';
      asm
        if (this.$v && this.$v.$touch) this.$v.$touch();
      end;
    end;
    
  m['limpar'] := procedure(_this: TJSObject)

    begin
      _this['nome'] := ''; 
      _this['email'] := ''; 
      _this['cidade'] := '';
      _this['msgSucesso'] := '';
      asm
        if (this.$v && this.$v.$reset) this.$v.$reset();
      end;
    end;

  comp['methods'] := m;

  RegisterComponent('formulario-page', comp);
end;

end.
