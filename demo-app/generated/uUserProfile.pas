unit uUserProfile;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uUserProfile;

implementation

procedure Register_uUserProfile;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  comp := TJSObject.new;
  comp['template'] :=
    '  <div>' +
    '    <div class="section">' +
    '      <h1 class="section-title">Perfil do Usuario</h1>' +
    '      <p>Esta pagina demonstra <strong>Route Params</strong> e <strong>Query Strings</strong>.</p>' +
    '    </div>' +
    '' +
    '    <div class="section">' +
    '      <h2 class="section-title">Dados da Rota</h2>' +
    '      <table>' +
    '        <tr><th>Informacao</th><th>Valor</th></tr>' +
    '        <tr><td>Param <code>:id</code></td><td><span class="badge badge-blue">{{ id }}</span></td></tr>' +
    '        <tr><td>Query <code>?tab</code></td><td><span class="badge badge-orange">{{ tab }}</span></td></tr>' +
    '        <tr><td>Query <code>?tema</code></td><td><span class="badge badge-gray">{{ tema }}</span></td></tr>' +
    '        <tr><td>Nível (Computed)</td><td><span class="badge" :class="userLevel == ''Premium'' ? ''badge-orange'' : ''badge-gray''">{{ userLevel }}</span></td></tr>' +
    '      </table>' +
    '    </div>' +
    '' +
    '    <div class="section">' +
    '      <h2 class="section-title">Editar Nome (b-model)</h2>' +
    '      <input type="text" b-model="nomeUsuario">' +
    '      <p>Nome atual: <strong>{{ nomeUsuario }}</strong></p>' +
    '    </div>' +
    '' +
    '    <div class="section">' +
    '      <h2 class="section-title">Testar Outras Rotas</h2>' +
    '      <a href="#/user/1" class="btn-outline" style="text-decoration:none; display:inline-block;">User 1</a>' +
    '      <a href="#/user/100?tab=posts" class="btn-outline" style="text-decoration:none; display:inline-block;">User 100 + Posts</a>' +
    '      <a href="#/user/7?tab=config&tema=dark" class="btn-outline" style="text-decoration:none; display:inline-block;">User 7 + Multi Query</a>' +
    '      <a href="#/" class="btn-danger" style="text-decoration:none; display:inline-block;">Voltar ao Home</a>' +
    '    </div>' +
    '  </div>';

  comp['data'] := function(): TJSObject
  var d: TJSObject;
  begin
    d := TJSObject.new;
    d['id'] := '?';
    d['tab'] := '(nenhum)';
    d['tema'] := '(nenhum)';
    d['nomeUsuario'] := 'Usuario Padrao';
    Result := d;
  end;

  m := TJSObject.new;
  comp['methods'] := m;

  comp['computed'] := TJSObject.new;
  TJSObject(comp['computed'])['userLevel'] := function(_this: TJSObject): JSValue

    begin
      if Integer(_this['id']) > 50 then Result := 'Premium'
      else Result := 'Basico';
    end;

;

  RegisterComponent('user-profile-page', comp);
end;

end.
