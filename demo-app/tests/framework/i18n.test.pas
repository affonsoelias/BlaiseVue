program i18n_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, BVReactivity, BVCompiler, BVI18n;

var
  EnMsgs, PtMsgs, Params: TJSObject;

begin
  Describe('BlaiseVue 2.5 Integrated Internationalization (Blaise-i18n)', procedure
    begin
       It('deve inicializar e registrar mensagens em multiplos idiomas', procedure
         begin
            TBVI18n.Init('en', 'en');

            EnMsgs := TJSObject.new;
            EnMsgs['hello'] := 'Hello';
            EnMsgs['save'] := 'Save';
            TBVI18n.AddMessages('en', EnMsgs);

            PtMsgs := TJSObject.new;
            PtMsgs['hello'] := 'Ola';
            PtMsgs['save'] := 'Salvar';
            TBVI18n.AddMessages('pt', PtMsgs);

            Expect(TBVI18n.GetLocale).ToBe('en');
            Expect(TBVI18n.T('hello')).ToBe('Hello');
            Expect(TBVI18n.T('save')).ToBe('Save');

            TBVI18n.SetLocale('pt');
            Expect(TBVI18n.GetLocale).ToBe('pt');
            Expect(TBVI18n.T('hello')).ToBe('Ola');
            Expect(TBVI18n.T('save')).ToBe('Salvar');
         end);

       It('deve resolver chaves aninhadas com notacao de ponto', procedure
         begin
            asm
              let nested = {
                actions: {
                  dialog: {
                    confirm: 'Are you sure?',
                    delete: 'Delete Item'
                  }
                }
              };
              pas.BVI18n.TBVI18n.AddMessages('en', nested);
            end;
            TBVI18n.SetLocale('en');
            Expect(TBVI18n.T('actions.dialog.confirm')).ToBe('Are you sure?');
            Expect(TBVI18n.T('actions.dialog.delete')).ToBe('Delete Item');
         end);

       It('deve interpolar parametros nomeados nas traducoes', procedure
         begin
            asm
              pas.BVI18n.TBVI18n.AddMessages('en', {
                welcome: 'Welcome back, {name}! You have {count} messages.'
              });
              pas.BVI18n.TBVI18n.AddMessages('pt', {
                welcome: 'Bem-vindo de volta, {name}! Voce tem {count} mensagens.'
              });
            end;

            Params := TJSObject.new;
            Params['name'] := 'Affonso';
            Params['count'] := 7;

            TBVI18n.SetLocale('en');
            Expect(TBVI18n.T('welcome', Params)).ToBe('Welcome back, Affonso! You have 7 messages.');

            TBVI18n.SetLocale('pt');
            Expect(TBVI18n.T('welcome', Params)).ToBe('Bem-vindo de volta, Affonso! Voce tem 7 mensagens.');
         end);

       It('deve recorrer ao fallbackLocale quando chave nao existir no idioma atual', procedure
         begin
            TBVI18n.Init('pt', 'en');
            asm
              pas.BVI18n.TBVI18n.AddMessages('en', { uniqueKey: 'English Only' });
            end;
            // Idioma atual e 'pt', mas uniqueKey so existe em 'en'
            Expect(TBVI18n.T('uniqueKey')).ToBe('English Only');
         end);

       It('deve atualizar o DOM de forma reativa quando o locale for alterado', procedure
         var
           El: TJSHTMLElement;
           Data: TBlaiseData;
         begin
            TBVI18n.Init('en', 'en');
            asm
              pas.BVI18n.TBVI18n.AddMessages('en', { greeting: 'Good Morning' });
              pas.BVI18n.TBVI18n.AddMessages('pt', { greeting: 'Bom Dia' });
            end;

            El := TJSHTMLElement(document.createElement('div'));
            El.innerHTML := '<h2 id="msg">{{ $t("greeting") }}</h2>';
            document.body.appendChild(El);

            Data := TBlaiseData.Create(TJSObject.new);
            Compile(El, Data, TJSObject.new);

            Expect(El.querySelector('#msg').textContent).ToBe('Good Morning');

            // Muda o idioma em tempo de execucao
            TBVI18n.SetLocale('pt');

            // Verifica se o no DOM reagiu e mudou o texto automaticamente
            Expect(El.querySelector('#msg').textContent).ToBe('Bom Dia');

            El.remove();
         end);
    end);
end.
