program blaise_ui_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, BVComponents, uBVBtn, uBVCard, uBVModal, uBVDataGrid;

var
  Wrapper: TWrapper;
  BtnProps, CardProps, ModalProps: TJSObject;

begin
  Register_uBVBtn;
  Register_uBVCard;
  Register_uBVModal;
  Register_uBVDataGrid;

  Describe('BlaiseUI Official Component Kit', procedure
    begin
       It('deve renderizar bv-btn com classes padrao de estilo', procedure
         begin
            Wrapper := Mount('bv-btn');
            Expect(Wrapper.Find('button')).toBeDefined;
            Expect(Wrapper.Find('button').className).ToContain('bui-btn');
            Expect(Wrapper.Find('button').className).ToContain('bui-btn-primary');
            Expect(Wrapper.Find('button').className).ToContain('bui-btn-md');
         end);

       It('deve renderizar bv-btn com estado desabilitado', procedure
         begin
            BtnProps := TJSObject.new;
            BtnProps['disabled'] := true;
            Wrapper := Mount('bv-btn', BtnProps);
            Expect(TJSHTMLButtonElement(Wrapper.Find('button')).disabled).toBe(True);
         end);

       It('deve renderizar bv-card com titulo e estrutura de classes', procedure
         begin
            CardProps := TJSObject.new;
            CardProps['title'] := 'Card Title';
            Wrapper := Mount('bv-card', CardProps);
            Expect(Wrapper.Find('.bui-card')).toBeDefined;
            Expect(Wrapper.Find('.bui-card-header')).toBeDefined;
            Expect(Wrapper.Find('.bui-card-header').textContent).ToContain('Card Title');
            Expect(Wrapper.Find('.bui-card-body')).toBeDefined;
         end);

       It('deve instanciar bv-modal com teleport e titulo', procedure
         begin
            ModalProps := TJSObject.new;
            ModalProps['title'] := 'Confirm Dialog';
            ModalProps['show'] := true;
            Wrapper := Mount('bv-modal', ModalProps);
            // O modal usa <teleport to="body">
            Expect(document.body.querySelector('.bui-modal-backdrop')).toBeDefined;
            Expect(document.body.querySelector('.bui-modal-header').textContent).ToContain('Confirm Dialog');
         end);
    end);
end.
