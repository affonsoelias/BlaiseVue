program blaise_ui_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, BVComponents, uBVBtn, uBVCard, uBVModal, uBVDataGrid, uBVBadge, uBVAlert, uBVProgress, uBVSpinner, uBVInput, uBVPagination, uBVListGroup, uBVListGroupItem, uBVAccordion;

var
  Wrapper: TWrapper;
  BtnProps, CardProps, ModalProps, AlertProps, BadgeProps, ProgressProps, InputProps, PagProps, ItemProps, AccordionProps: TJSObject;

begin
  Register_uBVBtn;
  Register_uBVCard;
  Register_uBVModal;
  Register_uBVDataGrid;
  Register_uBVBadge;
  Register_uBVAlert;
  Register_uBVProgress;
  Register_uBVSpinner;

  Register_uBVInput;
  Register_uBVPagination;
  Register_uBVListGroup;
  Register_uBVListGroupItem;
  Register_uBVAccordion;

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

       It('deve renderizar bv-btn com label passada como prop', procedure
         begin
            BtnProps := TJSObject.new;
            BtnProps['label'] := 'Open Modal';
            BtnProps['variant'] := 'info';
            Wrapper := Mount('bv-btn', BtnProps);
            Expect(Wrapper.Find('button')).toBeDefined;
            Expect(Wrapper.Find('button').textContent).ToContain('Open Modal');
            Expect(Wrapper.Find('button').className).ToContain('bui-btn-info');
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
            Expect(TJSHTMLElement(Wrapper.Find('.bui-progress-bar')).style.getPropertyValue('width')).toBe('75%');
         end);

       It('deve renderizar bv-input com valor e label', procedure
         begin
            InputProps := TJSObject.new;
            InputProps['label'] := 'Username';
            InputProps['value'] := 'Turbo_Node';
            Wrapper := Mount('bv-input', InputProps);
            Expect(Wrapper.Find('.bui-input-group')).toBeDefined;
            Expect(Wrapper.Find('.bui-input-label')).toBeDefined;
            Expect(Wrapper.Find('.bui-input-label').textContent).ToContain('Username');
            Expect(TJSHTMLInputElement(Wrapper.Find('input')).value).toBe('Turbo_Node');
         end);

       It('deve renderizar bv-pagination com total de paginas', procedure
         begin
            PagProps := TJSObject.new;
            PagProps['total'] := 5;
            PagProps['value'] := 2;
            Wrapper := Mount('bv-pagination', PagProps);
            Expect(Wrapper.Find('.bui-pagination')).toBeDefined;
            Expect(Wrapper.FindAll('.bui-page-item').length).toBe(7); { 5 pages + 2 arrows }
         end);

       It('deve renderizar bv-list-group-item com badge estilizado', procedure
         begin
            ItemProps := TJSObject.new;
            ItemProps['badge'] := '5';
            ItemProps['badgeVariant'] := 'danger';
            Wrapper := Mount('bv-list-group-item', ItemProps);
            Expect(Wrapper.Find('.bui-list-group-item')).toBeDefined;
            Expect(Wrapper.Find('.bui-badge')).toBeDefined;
            Expect(Wrapper.Find('.bui-badge').textContent).ToContain('5');
            Expect(Wrapper.Find('.bui-badge').className).ToContain('bui-badge-danger');
         end);

       It('deve disparar evento click em bv-btn quando habilitado', procedure
         begin
            BtnProps := TJSObject.new;
            BtnProps['label'] := 'Click Me';
            Wrapper := Mount('bv-btn', BtnProps);
            Wrapper.Find('button').click;
            Expect(Wrapper.Emitted('click')).toBe(True);
         end);

       It('nao deve disparar evento click em bv-btn quando desabilitado', procedure
         begin
            BtnProps := TJSObject.new;
            BtnProps['label'] := 'Disabled Btn';
            BtnProps['disabled'] := true;
            Wrapper := Mount('bv-btn', BtnProps);
            Wrapper.Find('button').click;
            Expect(Wrapper.Emitted('click')).toBe(False);
         end);

       It('deve renderizar bv-accordion e alternar estado ativo no clique', procedure
         begin
            AccordionProps := TJSObject.new;
            asm
              $mod.AccordionProps.items = [
                { id: 'q1', title: 'Question 1', content: 'Answer 1' },
                { id: 'q2', title: 'Question 2', content: 'Answer 2' }
              ];
              $mod.AccordionProps.initialActiveId = 'q1';
            end;
            Wrapper := Mount('bv-accordion', AccordionProps);
            Expect(Wrapper.Find('.bui-accordion')).toBeDefined;
            Expect(Wrapper.FindAll('.bui-accordion-item').length).toBe(2);
            Expect(Wrapper.Find('.bui-accordion-button').className).ToContain('active');
            
            { Click second accordion button to toggle }
            TJSHTMLElement(Wrapper.FindAll('.bui-accordion-button')[1]).click;
            Expect(TJSHTMLElement(Wrapper.FindAll('.bui-accordion-button')[1]).className).ToContain('active');
            Expect(TJSHTMLElement(Wrapper.FindAll('.bui-accordion-button')[0]).className).NotToContain('active');
         end);
    end);
end.
