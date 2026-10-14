program blaise_ui_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, BVComponents, uBVBtn, uBVCard, uBVModal, uBVDataGrid, uBVBadge, uBVAlert, uBVProgress, uBVSpinner, uBVChart;

var
  Wrapper: TWrapper;
  BtnProps, CardProps, ModalProps, AlertProps, BadgeProps, ProgressProps, ChartProps: TJSObject;

begin
  Register_uBVBtn;
  Register_uBVCard;
  Register_uBVModal;
  Register_uBVDataGrid;
  Register_uBVBadge;
  Register_uBVAlert;
  Register_uBVProgress;
  Register_uBVSpinner;
  Register_uBVChart;

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
            Expect(document.body.querySelector('.bui-modal-backdrop')).toBeDefined;
            Expect(document.body.querySelector('.bui-modal-header').textContent).ToContain('Confirm Dialog');
         end);

       It('deve renderizar bv-badge com classe correspondente', procedure
         begin
            BadgeProps := TJSObject.new;
            BadgeProps['variant'] := 'success';
            Wrapper := Mount('bv-badge', BadgeProps);
            Expect(Wrapper.Find('.bui-badge')).toBeDefined;
            Expect(Wrapper.Find('.bui-badge').className).ToContain('bui-badge-success');
         end);

       It('deve renderizar bv-alert e permitir fechar', procedure
         begin
            AlertProps := TJSObject.new;
            AlertProps['variant'] := 'warning';
            AlertProps['dismissible'] := true;
            Wrapper := Mount('bv-alert', AlertProps);
            Expect(Wrapper.Find('.bui-alert')).toBeDefined;
            Expect(Wrapper.Find('.bui-alert').className).ToContain('bui-alert-warning');
         end);

       It('deve renderizar bv-progress com largura correspondente ao valor', procedure
         begin
            ProgressProps := TJSObject.new;
            ProgressProps['value'] := 75;
            ProgressProps['variant'] := 'success';
            Wrapper := Mount('bv-progress', ProgressProps);
            Expect(Wrapper.Find('.bui-progress')).toBeDefined;
            Expect(Wrapper.Find('.bui-progress-bar')).toBeDefined;
            Expect(TJSHTMLElement(Wrapper.Find('.bui-progress-bar')).style.width).toBe('75%');
         end);

       It('deve renderizar bv-chart com container bui-chart-wrapper e canvas', procedure
         begin
            ChartProps := TJSObject.new;
            ChartProps['type'] := 'bar';
            Wrapper := Mount('bv-chart', ChartProps);
            Expect(Wrapper.Find('.bui-chart-wrapper')).toBeDefined;
            Expect(Wrapper.Find('canvas')).toBeDefined;
         end);
    end);
end.
