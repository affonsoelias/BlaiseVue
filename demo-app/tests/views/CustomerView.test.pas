program customerview_view_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, uCustomerView;

var
  Wrapper: TWrapper;

begin
  Register_uCustomerView;

  Describe('View: CustomerView', procedure
    begin
       It('deve inicializar a view de clientes e renderizar tabela e botao RPC', procedure
         begin
            Wrapper := Mount('customer-view-page');
            Expect(Wrapper.Element <> nil).ToBe(True);
            Expect(Wrapper.Find('.crud-title').textContent).ToContain('Customer Management');
            Expect(Wrapper.Find('.crud-search-input')).toBeDefined;
            Expect(Wrapper.Find('.crud-table')).toBeDefined;
         end);

       It('deve abrir e fechar o modal de cadastro ao clicar nos botoes', procedure
         begin
            Wrapper := Mount('customer-view-page');
            // Modal inicialmente fechado (v-show = false)
            Expect(Wrapper.Find('.crud-modal-backdrop').style.getPropertyValue('display')).toBe('none');
            // Clica em "Novo Cliente"
            TJSHTMLElement(Wrapper.Find('.crud-header-btns button:first-child')).click;
            Expect(Wrapper.Find('.crud-modal-backdrop').style.getPropertyValue('display')).NotToContain('none');
            // Clica no botao Cancel do modal
            TJSHTMLElement(Wrapper.Find('.modal-footer button:first-child')).click;
            Expect(Wrapper.Find('.crud-modal-backdrop').style.getPropertyValue('display')).toBe('none');
         end);
    end);
end.
