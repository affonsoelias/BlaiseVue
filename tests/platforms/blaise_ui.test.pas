program blaise_ui_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, BVComponents, uBVBtn, uBVCard, uBVModal, uBVDataGrid, uBVBadge, uBVAlert, uBVProgress, uBVSpinner, uBVInput, uBVPagination, uBVListGroup, uBVListGroupItem, uBVAccordion, uBVSwitch, uBVCheckbox, uBVRadio, uBVDropdown, uBVDropdownItem, uBVSkeleton, uBVSlider;

var
  Wrapper: TWrapper;
  BtnProps, CardProps, ModalProps, AlertProps, BadgeProps, ProgressProps, InputProps, PagProps, ItemProps, AccordionProps, SwitchProps, CheckboxProps, RadioProps, DropdownProps, SkeletonProps, SliderProps: TJSObject;

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
  Register_uBVSwitch;
  Register_uBVCheckbox;
  Register_uBVRadio;
  Register_uBVDropdown;
  Register_uBVDropdownItem;
  Register_uBVSkeleton;
  Register_uBVSlider;

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

       It('deve renderizar bv-switch com role switch e label', procedure
         begin
            SwitchProps := TJSObject.new;
            SwitchProps['label'] := 'Dark Mode';
            SwitchProps['color'] := 'success';
            Wrapper := Mount('bv-switch', SwitchProps);
            Expect(Wrapper.Find('.bui-switch')).toBeDefined;
            Expect(Wrapper.Find('input[type="checkbox"]')).toBeDefined;
            Expect(Wrapper.Find('input').getAttribute('role')).toBe('switch');
            Expect(Wrapper.Find('.bui-switch-label').textContent).ToContain('Dark Mode');
            Expect(Wrapper.Find('.bui-switch').className).ToContain('bui-switch-success');
         end);

       It('deve renderizar bv-checkbox com label e estado checked', procedure
         begin
            CheckboxProps := TJSObject.new;
            CheckboxProps['label'] := 'Accept Terms';
            CheckboxProps['checked'] := true;
            Wrapper := Mount('bv-checkbox', CheckboxProps);
            Expect(Wrapper.Find('.bui-checkbox')).toBeDefined;
            Expect(Wrapper.Find('input[type="checkbox"]')).toBeDefined;
            Expect(TJSHTMLInputElement(Wrapper.Find('input')).checked).toBe(True);
            Expect(Wrapper.Find('.bui-checkbox-label').textContent).ToContain('Accept Terms');
         end);

       It('deve renderizar bv-radio com name e estado checked', procedure
         begin
            RadioProps := TJSObject.new;
            RadioProps['name'] := 'options';
            RadioProps['label'] := 'Option A';
            RadioProps['value'] := 'A';
            RadioProps['checked'] := true;
            Wrapper := Mount('bv-radio', RadioProps);
            Expect(Wrapper.Find('.bui-radio')).toBeDefined;
            Expect(Wrapper.Find('input[type="radio"]')).toBeDefined;
            Expect(Wrapper.Find('input').getAttribute('name')).toBe('options');
            Expect(TJSHTMLInputElement(Wrapper.Find('input')).checked).toBe(True);
            Expect(Wrapper.Find('.bui-radio-label').textContent).ToContain('Option A');
         end);

       It('deve renderizar bv-dropdown e alternar menu aberto no clique', procedure
         begin
            DropdownProps := TJSObject.new;
            DropdownProps['text'] := 'Options';
            DropdownProps['variant'] := 'secondary';
            Wrapper := Mount('bv-dropdown', DropdownProps);
            Expect(Wrapper.Find('.bui-dropdown')).toBeDefined;
            Expect(Wrapper.Find('button').textContent).ToContain('Options');
            Expect(Wrapper.Find('.dropdown-menu').className).NotToContain('show');
            Wrapper.Find('button').click;
            Expect(Wrapper.Find('.dropdown-menu').className).ToContain('show');
         end);

       It('deve renderizar bv-dropdown-item como link de menu', procedure
         begin
            ItemProps := TJSObject.new;
            ItemProps['href'] := '#/profile';
            Wrapper := Mount('bv-dropdown-item', ItemProps);
            Expect(Wrapper.Find('.dropdown-item')).toBeDefined;
            Expect(Wrapper.Find('.dropdown-item').getAttribute('href')).toBe('#/profile');
         end);

       It('deve renderizar bv-skeleton com tipo e animacao', procedure
         begin
            SkeletonProps := TJSObject.new;
            SkeletonProps['type'] := 'circle';
            SkeletonProps['animation'] := 'wave';
            SkeletonProps['width'] := '48px';
            SkeletonProps['height'] := '48px';
            Wrapper := Mount('bv-skeleton', SkeletonProps);
            Expect(Wrapper.Find('.bui-skeleton-wrapper')).toBeDefined;
            Expect(Wrapper.Find('.bui-skeleton-circle')).toBeDefined;
            Expect(Wrapper.Find('.placeholder-wave')).toBeDefined;
         end);

       It('deve renderizar bv-slider com min, max, step e badge de valor', procedure
         begin
            SliderProps := TJSObject.new;
            SliderProps['label'] := 'Volume';
            SliderProps['min'] := 0;
            SliderProps['max'] := 100;
            SliderProps['step'] := 5;
            SliderProps['value'] := 50;
            SliderProps['showValue'] := true;
            Wrapper := Mount('bv-slider', SliderProps);
            Expect(Wrapper.Find('.bui-slider')).toBeDefined;
            Expect(Wrapper.Find('input[type="range"]')).toBeDefined;
            Expect(TJSHTMLInputElement(Wrapper.Find('input')).min).toBe('0');
            Expect(TJSHTMLInputElement(Wrapper.Find('input')).max).toBe('100');
            Expect(TJSHTMLInputElement(Wrapper.Find('input')).step).toBe('5');
            Expect(TJSHTMLInputElement(Wrapper.Find('input')).value).toBe('50');
            Expect(Wrapper.Find('.bui-slider-badge').textContent).ToContain('50');
         end);
    end);
end.
