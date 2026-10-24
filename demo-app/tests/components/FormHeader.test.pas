program formheader_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, uFormHeader;

var
  Wrapper: TWrapper;
  CustomProps: TJSObject;

begin
  Register_uFormHeader;

  Describe('Component: FormHeader', procedure
    begin
       It('deve montar o componente no DOM com valores padrao de props', procedure
         begin
            Wrapper := Mount('form-header');
            Expect(Wrapper.Element <> nil).ToBe(True);
            Expect(Wrapper.Find('.form-header-title').textContent).ToContain('Formul');
            Expect(Wrapper.Find('.form-header-subtitle').textContent).ToContain('Preencha os campos');
         end);

       It('deve aceitar props customizadas de titulo e subtitulo', procedure
         begin
            CustomProps := TJSObject.new;
            CustomProps['title'] := 'Cadastro de Clientes';
            CustomProps['subtitle'] := 'Informe os dados do cliente';
            Wrapper := Mount('form-header', CustomProps);
            Expect(Wrapper.Find('.form-header-title').textContent).ToContain('Cadastro de Clientes');
            Expect(Wrapper.Find('.form-header-subtitle').textContent).ToContain('Informe os dados do cliente');
         end);

       It('deve emitir evento header-clicked ao clicar no titulo', procedure
         begin
            Wrapper := Mount('form-header');
            TJSHTMLElement(Wrapper.Find('.form-header-title')).click;
            Expect(Wrapper.Emitted('header-clicked')).toBe(True);
         end);
    end);
end.
