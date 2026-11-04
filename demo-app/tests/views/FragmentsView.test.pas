program fragmentsview_view_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, uTableCells, uStatPills, uFragmentsView;

var
  Wrapper: TWrapper;

begin
  Register_uTableCells;
  Register_uStatPills;
  Register_uFragmentsView;

  Describe('View: FragmentsView (v5.0 Pillar 5 Multi-Root Fragments Showcase)', procedure
    begin
      It('should initialize FragmentsView and render <table-cells> and <stat-pills> as multi-root fragments', procedure
        var
          Rows, StatusCells, GridLabels: TJSArray;
          FirstStatusCell, FirstGridLabel: TJSElement;
          Html: string;
        begin
          Wrapper := Mount('fragments-view-page');
          Expect(Wrapper.Element <> nil).ToBe(True);
          Expect(Wrapper.Find('.fragments-view-page')).ToBeDefined;

          Rows := Wrapper.FindAll('tr.frag-table-row');
          Expect(Rows.length).ToBe(4);

          StatusCells := Wrapper.FindAll('tr.frag-table-row > td.frag-cell-status');
          Expect(StatusCells.length).ToBe(4);
          Expect(Wrapper.FindAll('tr.frag-table-row > td').length).ToBe(16);

          // Verify explicit b-bind="$attrs" on 3rd <td> of <table-cells>
          FirstStatusCell := TJSElement(StatusCells[0]);
          Expect(FirstStatusCell.classList.contains('clickable-status-cell')).ToBe(True);
          Expect(FirstStatusCell.getAttribute('data-fallthrough')).ToBe('explicit-attrs');

          // Verify automatic Option A fallthrough on 1st root of <stat-pills>
          GridLabels := Wrapper.FindAll('.frag-grid-label');
          Expect(GridLabels.length).ToBe(3);
          FirstGridLabel := TJSElement(GridLabels[0]);
          Expect(FirstGridLabel.classList.contains('frag-highlight-root')).ToBe(True);
          Expect(FirstGridLabel.getAttribute('data-mode')).ToBe('auto-first-root');

          // Verify live DOM inspector detected fragment anchors
          Html := Wrapper.HTML;
          Expect(Pos('FRAG-01', Html) > 0).ToBe(True);
          Expect(Pos('[bv-fragment:', Html) > 0).ToBe(True);
        end);

      It('should forward @click via b-bind="$attrs" on <table-cells> and update status reactively', procedure
        var
          FirstStatusCell: TJSElement;
        begin
          Wrapper := Mount('fragments-view-page');
          FirstStatusCell := Wrapper.Find('td.frag-cell-status');
          Expect(Pos('Ativo', FirstStatusCell.textContent) > 0).ToBe(True);

          TJSHTMLElement(FirstStatusCell).click();
          Expect(Pos('Em Revisão', FirstStatusCell.textContent) > 0).ToBe(True);
        end);
    end);
end.
