program datasetview_view_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, uDatasetView;

var
  Wrapper: TWrapper;

begin
  Register_uDatasetView;

  Describe('View: DatasetView', procedure
    begin
       It('deve inicializar a view e renderizar sem erros', procedure
         begin
            Wrapper := Mount('dataset-view-page');
            Expect(Wrapper.Element <> nil).ToBe(True);
            Expect(Wrapper.Find('.dataset-view-page')).toBeDefined;
         end);

       It('deve abrir modal ao clicar no botao de novo produto', procedure
         begin
            Wrapper := Mount('dataset-view-page');
            // Inicialmente modal fechado
            Expect(Wrapper.Find('.crud-modal-backdrop') = nil).ToBe(True);
            // Simula clique em "Novo Produto" (primeiro botao do header)
            Wrapper.Find('.crud-header-btns button:first-child').click();
            // Agora o modal deve estar visivel
            Expect(Wrapper.Find('.crud-modal-backdrop')).toBeDefined;
            Expect(Wrapper.Find('.crud-modal')).toBeDefined;
         end);
    end);
end.
