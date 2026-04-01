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
  _styleEl.textContent := '.home-page { padding: 20px; }   .section { margin-top: 24px; padding: 20px; border-left: 4px solid #42b883; background: #fff; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }   .alert-box { margin-top: 10px; padding: 15px; background: #42b883; color: white; border-radius: 8px; }      .fade-enter-active, .fade-leave-active { transition: opacity 0.5s ease; }   .fade-enter-from, .fade-leave-to { opacity: 0; }';
  document.head.appendChild(_styleEl);
  comp := TJSObject.new;
  comp['template'] :=
    '  <div class="home-page">' +
    '    <h2>🏠 Home: Painel de Controle (Recursos BlaiseVue)</h2>' +
    '    <p>{{ descricao }}</p>' +
    '' +
    '    <!-- 1. Slots & Composição -->' +
    '    <card>' +
    '      <template slot="header">🎨 Composição via Slots</template>' +
    '      <p>Este componente ''Card'' usa slots nomeados para o cabeçalho e slots padrão para o corpo.</p>' +
    '    </card>' +
    '' +
    '    <!-- 2. Reatividade em Formulário -->' +
    '    <div class="section">' +
    '      <h3>✍️ Sincronização de Dados (B-Model)</h3>' +
    '      <input type="text" b-model="userName" placeholder="Seu nome...">' +
    '      <p>Bem-vindo, <b>{{ userName }}</b>!</p>' +
    '    </div>' +
    '' +
    '    <!-- 3. Store Global -->' +
    '    <div class="section">' +
    '      <h3>🌍 Global Store (B-Store)</h3>' +
    '      <p>Versão do Framework: <badge-blue>{{ $store.appVersion }}</badge-blue></p>' +
    '      <p>Usuário Atual: <b>{{ $store.user }}</b></p>' +
    '    </div>' +
    '' +
    '    <!-- 4. Transições -->' +
    '    <div class="section">' +
    '      <h3>✨ Animações & Transições</h3>' +
    '      <button @click="toggleVisible">Alternar Visibilidade</button>' +
    '      <transition name="fade">' +
    '        <div v-show="isVisible" class="alert-box">' +
    '           Efeito Fade Ativo! 👻' +
    '        </div>' +
    '      </transition>' +
    '    </div>' +
    '' +
    '    <!-- 5. Provide e Inject -->' +
    '    <info-card>' +
    '       <template slot="title">Injeção de Dependências (Provide/Inject)</template>' +
    '       O recurso de <b>Provide/Inject</b> permite que este componente receba dados de ancestrais distantes sem precisar de propriedades manuais em cada nível.' +
    '    </info-card>' +
    '  </div>';

  comp['data'] := function(): TJSObject
  var d: TJSObject;
  begin
    d := TJSObject.new;
    d['descricao'] := 'Bem-vindo ao centro de testes do Framework. Abaixo estão as funcionalidades principais.';
    d['userName'] := 'Desenvolvedor Pascal';
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
