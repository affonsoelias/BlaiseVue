program validation_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, BVReactivity, BVCompiler, BVValidation;

var
  Wrapper: TWrapper;
  CustomRule: JSValue;

begin
  Describe('BlaiseVue 2.5 Form Validation Engine (b-validate)', procedure
    begin
       It('deve validar regra required para valores vazios e preenchidos', procedure
         begin
            Expect(TBVValidation.ValidateValue('required', nil, '', 'Email')).ToContain('is required');
            Expect(TBVValidation.ValidateValue('required', '', '', 'Email')).ToContain('is required');
            Expect(TBVValidation.ValidateValue('required', 'user@domain.com', '', 'Email')).ToBe('');
         end);

       It('deve validar regra email corretamente', procedure
         begin
            Expect(TBVValidation.ValidateValue('email', 'invalido', '', 'Email')).ToContain('must be a valid email');
            Expect(TBVValidation.ValidateValue('email', 'usuario@dominio.com', '', 'Email')).ToBe('');
         end);

       It('deve validar regras min e max de tamanho ou valor numerico', procedure
         begin
            Expect(TBVValidation.ValidateValue('min', 'abc', '5', 'Senha')).ToContain('at least 5');
            Expect(TBVValidation.ValidateValue('min', 'abcdef', '5', 'Senha')).ToBe('');
            Expect(TBVValidation.ValidateValue('max', '12345678', '5', 'Codigo')).ToContain('must not exceed 5');
            Expect(TBVValidation.ValidateValue('max', '123', '5', 'Codigo')).ToBe('');
         end);

       It('deve validar regra numeric', procedure
         begin
            Expect(TBVValidation.ValidateValue('numeric', 'abc12', '', 'Idade')).ToContain('must be numeric');
            Expect(TBVValidation.ValidateValue('numeric', '42', '', 'Idade')).ToBe('');
         end);

       It('deve encadear multiplas regras com pipe (|)', procedure
         var
           Err1, Err2: string;
         begin
            Err1 := TBVValidation.ValidateField('required|email|min:5', '', 'Email');
            Expect(Err1).ToContain('is required');

            Err2 := TBVValidation.ValidateField('required|email|min:10', 'a@b.co', 'Email');
            Expect(Err2).ToContain('at least 10');

            Expect(TBVValidation.ValidateField('required|email|min:5', 'contato@blaisevue.dev', 'Email')).ToBe('');
         end);

       It('deve permitir registro e execucao de regras customizadas', procedure
         var
           RuleFn: JSValue;
         begin
            asm
              RuleFn = function(val) {
                return (Number(val) % 2 === 0);
              };
            end;
            TBVValidation.RegisterRule('even', RuleFn, '{field} must be an even number');
            Expect(TBVValidation.ValidateValue('even', 3, '', 'Count')).ToContain('must be an even number');
            Expect(TBVValidation.ValidateValue('even', 4, '', 'Count')).ToBe('');
         end);

       It('deve integrar b-validate no DOM e atualizar $errors e $v no $validate()', procedure
         var
           El: TJSHTMLElement;
           Data: TBlaiseData;
           InitData: TJSObject;
           IsVal: Boolean;
         begin
            El := TJSHTMLElement(document.createElement('div'));
            El.innerHTML := '<input b-model="email" b-validate="required|email" id="email-input">';
            document.body.appendChild(El);

            InitData := TJSObject.new;
            InitData['email'] := 'not-email';
            Data := TBlaiseData.Create(InitData);

            Compile(El, Data, TJSObject.new);

            // Valida tudo atraves do $v.$validate()
            IsVal := TBVValidation.ValidateAll(Data);
            Expect(IsVal).ToBe(False);
            Expect(String(TJSObject(TJSObject(Data.FData)['$errors'])['email'])).ToContain('must be a valid email');

            // Corrige o email e revalida
            Data.SetValue('email', 'admin@blaisevue.org');
            IsVal := TBVValidation.ValidateAll(Data);
            Expect(IsVal).ToBe(True);
            Expect(String(TJSObject(TJSObject(Data.FData)['$errors'])['email'])).ToBe('');

            // Limpa o DOM
            El.remove();
         end);
    end);
end.
