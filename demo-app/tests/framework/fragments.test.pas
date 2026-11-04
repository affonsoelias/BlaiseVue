program fragments_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, BVComponents, BVCompiler, BVReactivity;

var
  Wrapper: TWrapper;
  UnmountCount: Integer;

procedure SetupFragmentComponents;
var
  LayoutFrag, ExplicitAttrFrag, TableCellsFrag, TableHostComp: TJSObject;
  ConditionalHostComp,ClosableFrag, LoopItemFrag, LoopHostComp: TJSObject;
  ShowHostComp, SlottedFrag, SlotHostComp, HmrFrag: TJSObject;
begin
  UnmountCount := 0;

  // 1. Multi-root layout fragment (Automatic Option A fallthrough to first element)
  LayoutFrag := TJSObject.new;
  LayoutFrag['template'] :=
    '<header class="frag-header">{{ title }}</header>' +
    '<main class="frag-main">{{ body }}</main>' +
    '<footer class="frag-footer">Footer</footer>';
  LayoutFrag['data'] := function(): TJSObject
  begin
    Result := new(['title', 'Default Title', 'body', 'Default Body']);
  end;
  RegisterComponent('layout-frag', LayoutFrag);

  // 2. Multi-root fragment with explicit b-bind="$attrs" on the second root element
  ExplicitAttrFrag := TJSObject.new;
  ExplicitAttrFrag['template'] :=
    '<header class="exp-header">Top</header>' +
    '<main class="exp-main" b-bind="$attrs">{{ label }}</main>' +
    '<footer class="exp-footer">Bottom</footer>';
  ExplicitAttrFrag['data'] := function(): TJSObject
  begin
    Result := new(['label', 'Target Main']);
  end;
  RegisterComponent('explicit-attr-frag', ExplicitAttrFrag);

  // 3. Native HTML5 table cells fragment (<td> siblings inside <tr>)
  TableCellsFrag := TJSObject.new;
  TableCellsFrag['template'] :=
    '<td class="cell-name">{{ name }}</td>' +
    '<td class="cell-role">{{ role }}</td>';
  TableCellsFrag['data'] := function(): TJSObject
  begin
    Result := new(['name', 'Ada', 'role', 'Architect']);
  end;
  RegisterComponent('table-cells-frag', TableCellsFrag);

  TableHostComp := TJSObject.new;
  TableHostComp['template'] :=
    '<table class="data-table">' +
    '  <tbody>' +
    '    <tr class="data-row">' +
    '      <table-cells-frag name="Blaise" role="Mathematician"></table-cells-frag>' +
    '    </tr>' +
    '  </tbody>' +
    '</table>';
  TableHostComp['data'] := function(): TJSObject
  begin
    Result := TJSObject.new;
  end;
  RegisterComponent('table-host', TableHostComp);

  // 4. Fragment with lifecycle hook & b-if toggle
  ClosableFrag := TJSObject.new;
  ClosableFrag['template'] :=
    '<div class="cf-banner">Banner Open</div>' +
    '<button class="cf-close" @click="$emit(''close'')">Close</button>';
  ClosableFrag['data'] := function(): TJSObject
  begin
    Result := TJSObject.new;
  end;
  ClosableFrag['unmounted'] := procedure()
  begin
    Inc(UnmountCount);
  end;
  RegisterComponent('closable-frag', ClosableFrag);

  ConditionalHostComp := TJSObject.new;
  ConditionalHostComp['template'] :=
    '<div class="cond-host">' +
    '  <button class="btn-open" @click="visible = true">Open</button>' +
    '  <closable-frag b-if="visible" @close="visible = false"></closable-frag>' +
    '</div>';
  ConditionalHostComp['data'] := function(): TJSObject
  begin
    Result := new(['visible', True]);
  end;
  RegisterComponent('cond-frag-host', ConditionalHostComp);

  // 5. Fragment inside b-for loop
  LoopItemFrag := TJSObject.new;
  LoopItemFrag['template'] :=
    '<dt class="term-item">{{ term }}</dt>' +
    '<dd class="desc-item">{{ desc }}</dd>';
  LoopItemFrag['data'] := function(): TJSObject
  begin
    Result := new(['term', '', 'desc', '']);
  end;
  RegisterComponent('loop-item-frag', LoopItemFrag);

  LoopHostComp := TJSObject.new;
  LoopHostComp['template'] :=
    '<dl class="glossary">' +
    '  <loop-item-frag b-for="entry in entries" :term="entry.t" :desc="entry.d"></loop-item-frag>' +
    '</dl>';
  LoopHostComp['data'] := function(): TJSObject
  begin
    Result := new([
      'entries', TJSArray._of(
        new(['t', 'SSR', 'd', 'Server Rendering']),
        new(['t', 'HMR', 'd', 'Hot Replacement'])
      )
    ]);
  end;
  RegisterComponent('loop-frag-host', LoopHostComp);

  // 6. Fragment with b-show
  ShowHostComp := TJSObject.new;
  ShowHostComp['template'] :=
    '<div class="show-host">' +
    '  <button class="btn-toggle-show" @click="shown = !shown">Toggle</button>' +
    '  <layout-frag b-show="shown" title="ShowTitle" body="ShowBody"></layout-frag>' +
    '</div>';
  ShowHostComp['data'] := function(): TJSObject
  begin
    Result := new(['shown', True]);
  end;
  RegisterComponent('show-frag-host', ShowHostComp);

  // 7. Fragment with named and default slots
  SlottedFrag := TJSObject.new;
  SlottedFrag['template'] :=
    '<header class="sf-hdr"><slot name="header">Default Header</slot></header>' +
    '<section class="sf-body"><slot>Default Body</slot></section>';
  SlottedFrag['data'] := function(): TJSObject
  begin
    Result := TJSObject.new;
  end;
  RegisterComponent('slotted-frag', SlottedFrag);

  SlotHostComp := TJSObject.new;
  SlotHostComp['template'] :=
    '<div class="slot-host">' +
    '  <slotted-frag>' +
    '    <template #header><span class="custom-hdr">Injected Header</span></template>' +
    '    <p class="custom-body">Injected Body</p>' +
    '  </slotted-frag>' +
    '</div>';
  SlotHostComp['data'] := function(): TJSObject
  begin
    Result := TJSObject.new;
  end;
  RegisterComponent('slot-frag-host', SlotHostComp);

  // 8. Fragment for HMR live patching
  HmrFrag := TJSObject.new;
  HmrFrag['template'] :=
    '<span class="hmr-a">Count: {{ count }}</span>' +
    '<button class="hmr-inc" @click="count = count + 1">+</button>';
  HmrFrag['data'] := function(): TJSObject
  begin
    Result := new(['count', 10]);
  end;
  RegisterComponent('hmr-frag', HmrFrag);
end;

begin
  SetupFragmentComponents;

  Describe('BlaiseVue 4.4 Vue 3-Style Component Fragments (Multi-Root Templates)', procedure
    begin
      It('should mount multi-root sibling elements without a wrapper div and support TWrapper queries', procedure
        begin
          Wrapper := Mount('layout-frag', new(['title', 'Hero', 'body', 'Content']));
          Expect(Wrapper.Find('.frag-header')).ToBeDefined;
          Expect(Wrapper.Find('.frag-main')).ToBeDefined;
          Expect(Wrapper.Find('.frag-footer')).ToBeDefined;
          Expect(Wrapper.Find('.frag-header').textContent).ToBe('Hero');
          Expect(Wrapper.Find('.frag-main').textContent).ToBe('Content');
          Expect(Wrapper.Text).ToContain('HeroContentFooter');
        end);

      It('should preserve native HTML5 table elements (td/tr) using <template> parser without stripping tags', procedure
        begin
          Wrapper := Mount('table-host');
          Expect(Wrapper.FindAll('td.cell-name, td.cell-role')).ToHaveLength(2);
          Expect(Wrapper.Find('.cell-name').textContent).ToBe('Blaise');
          Expect(Wrapper.Find('.cell-role').textContent).ToBe('Mathematician');
        end);

      It('should automatically fallthrough class, style, id and data-* onto the first visible element (Option A)', procedure
        var
          Hdr, MainEl: TJSHTMLElement;
        begin
          Wrapper := Mount('layout-frag', new([
            'title', 'Fallthrough',
            'class', 'theme-dark highlighted',
            'id', 'hero-header',
            'data-testid', 'frag-auto'
          ]));
          Hdr := Wrapper.Find('.frag-header');
          MainEl := Wrapper.Find('.frag-main');
          Expect(Hdr.classList.contains('frag-header')).ToBe(True);
          Expect(Hdr.classList.contains('theme-dark')).ToBe(True);
          Expect(Hdr.classList.contains('highlighted')).ToBe(True);
          Expect(Hdr.getAttribute('id')).ToBe('hero-header');
          Expect(Hdr.getAttribute('data-testid')).ToBe('frag-auto');
          Expect(MainEl.classList.contains('theme-dark')).ToBe(False);
          Expect(MainEl.getAttribute('id')).ToBeNull;
        end);

      It('should direct fallthrough $attrs to the specific element marked with b-bind="$attrs"', procedure
        var
          Hdr, MainEl: TJSHTMLElement;
        begin
          Wrapper := Mount('explicit-attr-frag', new([
            'label', 'Custom Target',
            'class', 'explicit-cls',
            'id', 'target-main-id',
            'data-role', 'primary-panel'
          ]));
          Hdr := Wrapper.Find('.exp-header');
          MainEl := Wrapper.Find('.exp-main');
          Expect(Hdr.classList.contains('explicit-cls')).ToBe(False);
          Expect(Hdr.getAttribute('id')).ToBeNull;
          Expect(MainEl.classList.contains('exp-main')).ToBe(True);
          Expect(MainEl.classList.contains('explicit-cls')).ToBe(True);
          Expect(MainEl.getAttribute('id')).ToBe('target-main-id');
          Expect(MainEl.getAttribute('data-role')).ToBe('primary-panel');
        end);

      It('should tear down all fragment sibling nodes on b-if=false, trigger unmounted, and re-mount on b-if=true', procedure
        begin
          UnmountCount := 0;
          Wrapper := Mount('cond-frag-host');
          Expect(Wrapper.Find('.cf-banner')).ToBeDefined;
          Wrapper.Find('.cf-close').click();
          Expect(Wrapper.Find('.cf-banner')).ToBeNull;
          Expect(Wrapper.Find('.cf-close')).ToBeNull;
          Expect(UnmountCount).ToBe(1);

          Wrapper.Find('.btn-open').click();
          Expect(Wrapper.Find('.cf-banner')).ToBeDefined;
          Expect(Wrapper.Find('.cf-banner').textContent).ToBe('Banner Open');
        end);

      It('should render multi-root fragments inside b-for lists', procedure
        begin
          Wrapper := Mount('loop-frag-host');
          Expect(Wrapper.FindAll('.term-item')).ToHaveLength(2);
          Expect(Wrapper.FindAll('.desc-item')).ToHaveLength(2);
          Expect(Wrapper.Text).ToContain('SSRServer RenderingHMRHot Replacement');
        end);

      It('should toggle display on all root elements of a fragment when using b-show', procedure
        var
          Hdr, MainEl, FooterEl: TJSHTMLElement;
        begin
          Wrapper := Mount('show-frag-host');
          Hdr := Wrapper.Find('.frag-header');
          MainEl := Wrapper.Find('.frag-main');
          FooterEl := Wrapper.Find('.frag-footer');
          Expect(Hdr.style.getPropertyValue('display')).ToBe('');
          Expect(MainEl.style.getPropertyValue('display')).ToBe('');

          Wrapper.Find('.btn-toggle-show').click();
          Expect(Hdr.style.getPropertyValue('display')).ToBe('none');
          Expect(MainEl.style.getPropertyValue('display')).ToBe('none');
          Expect(FooterEl.style.getPropertyValue('display')).ToBe('none');

          Wrapper.Find('.btn-toggle-show').click();
          Expect(Hdr.style.getPropertyValue('display')).ToBe('');
          Expect(MainEl.style.getPropertyValue('display')).ToBe('');
          Expect(FooterEl.style.getPropertyValue('display')).ToBe('');
        end);

      It('should resolve named and default slots inside a multi-root fragment', procedure
        begin
          Wrapper := Mount('slot-frag-host');
          Expect(Wrapper.Find('.custom-hdr')).ToBeDefined;
          Expect(Wrapper.Find('.custom-hdr').textContent).ToBe('Injected Header');
          Expect(Wrapper.Find('.custom-body')).ToBeDefined;
          Expect(Wrapper.Find('.custom-body').textContent).ToBe('Injected Body');
        end);

      It('should hot-patch a multi-root fragment in-place via HMR preserving reactive state', procedure
        var
          PatchedOpts: TJSObject;
        begin
          Wrapper := Mount('hmr-frag');
          Wrapper.Find('.hmr-inc').click();
          Expect(Wrapper.Find('.hmr-a').textContent).ToBe('Count: 11');

          PatchedOpts := TJSObject.new;
          PatchedOpts['template'] :=
            '<div class="hmr-patched-1">Patched: {{ count }}</div>' +
            '<div class="hmr-patched-2">Extra Root</div>' +
            '<button class="hmr-inc" @click="count = count + 1">+</button>';
          asm
            window.__BV_CORE__.patchComponent('hmr-frag', PatchedOpts);
          end;

          Expect(Wrapper.Find('.hmr-patched-1')).ToBeDefined;
          Expect(Wrapper.Find('.hmr-patched-2')).ToBeDefined;
          Expect(Wrapper.Find('.hmr-patched-1').textContent).ToBe('Patched: 11');
        end);
    end);
end.
