program productview_view_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, uProductView;

var
  Wrapper: TWrapper;

begin
  Register_uProductView;

  Describe('View: ProductView', procedure
    begin
       It('deve inicializar a view de produtos e renderizar header e barra de busca', procedure
         begin
            Wrapper := Mount('product-view-page');
            Expect(Wrapper.Element <> nil).ToBe(True);
            Expect(Wrapper.Find('.crud-title').textContent).ToContain('Product Management');
            Expect(Wrapper.Find('.crud-search-input')).toBeDefined;
            Expect(Wrapper.Find('.crud-table')).toBeDefined;
         end);

       It('deve abrir e fechar o modal de criacao ao clicar nos botoes', procedure
         begin
            Wrapper := Mount('product-view-page');
            // Modal inicialmente fechado (v-show = false)
            Expect(Wrapper.Find('.crud-modal-backdrop').style.getPropertyValue('display')).toBe('none');
            // Clica em "Novo Produto"
            TJSHTMLElement(Wrapper.Find('.crud-header-btns button:first-child')).click;
            Expect(Wrapper.Find('.crud-modal-backdrop').style.getPropertyValue('display')).NotToContain('none');
            // Clica em "Fechar" (x)
            TJSHTMLElement(Wrapper.Find('.modal-close-btn')).click;
            Expect(Wrapper.Find('.crud-modal-backdrop').style.getPropertyValue('display')).toBe('none');
         end);
    end);
end.
