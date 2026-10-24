program transition_group_test;

{$mode objfpc}

uses JS, Web, SysUtils, BVTestUtils, BVReactivity, BVCompiler;

begin
  Describe('BlaiseVue 2.5 Reactive List Transitions (<transition-group>)', procedure
    begin
       It('deve renderizar a tag customizada do wrapper com a classe bv-transition-group', procedure
         var
           El: TJSHTMLElement;
           Data: TBlaiseData;
           UlEl: TJSHTMLElement;
         begin
            El := TJSHTMLElement(document.createElement('div'));
            El.innerHTML := '<transition-group name="list" tag="ul" id="my-list" class="my-group"><li>Item 1</li><li>Item 2</li></transition-group>';
            document.body.appendChild(El);

            Data := TBlaiseData.Create(TJSObject.new);
            Compile(El, Data, TJSObject.new);

            UlEl := TJSHTMLElement(El.querySelector('#my-list'));
            Expect(UlEl).toBeDefined;
            Expect(LowerCase(UlEl.tagName)).ToBe('ul');
            Expect(UlEl.className).ToContain('bv-transition-group');
            Expect(UlEl.className).ToContain('my-group');
            Expect(UlEl.children.length).toBe(2);

            El.remove();
         end);

       It('deve usar tag padrao div quando tag nao for informada', procedure
         var
           El: TJSHTMLElement;
           Data: TBlaiseData;
           GroupEl: TJSHTMLElement;
         begin
            El := TJSHTMLElement(document.createElement('div'));
            El.innerHTML := '<transition-group name="fade" id="default-group"><span>A</span><span>B</span></transition-group>';
            document.body.appendChild(El);

            Data := TBlaiseData.Create(TJSObject.new);
            Compile(El, Data, TJSObject.new);

            GroupEl := TJSHTMLElement(El.querySelector('#default-group'));
            Expect(GroupEl).toBeDefined;
            Expect(LowerCase(GroupEl.tagName)).ToBe('div');
            Expect(GroupEl.className).ToContain('bv-transition-group');

            El.remove();
         end);

       It('deve inicializar o observador de mutacao FLIP no elemento wrapper', procedure
         var
           El: TJSHTMLElement;
           Data: TBlaiseData;
           GroupEl: TJSHTMLElement;
           HasObserver: Boolean;
         begin
            El := TJSHTMLElement(document.createElement('div'));
            El.innerHTML := '<transition-group name="list" id="observed-group"><div>Item</div></transition-group>';
            document.body.appendChild(El);

            Data := TBlaiseData.Create(TJSObject.new);
            Compile(El, Data, TJSObject.new);

            GroupEl := TJSHTMLElement(El.querySelector('#observed-group'));
            asm
              HasObserver = !!(GroupEl && (GroupEl['__bv_transition_observer__'] || GroupEl['__bv_transition_group_init__']));
            end;
            Expect(HasObserver).toBe(True);

            El.remove();
         end);
    end);
end.
