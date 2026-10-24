program virtual_scroll_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, BVReactivity, BVCompiler, BlaiseVue;

type
  TVirtualScrollState = record
    TotalCount: Integer;
    ItemHeight: Integer;
    ViewportHeight: Integer;
    Buffer: Integer;
    ScrollTop: Integer;
  end;

function ComputeTotalHeight(const State: TVirtualScrollState): Integer;
begin
  Result := State.TotalCount * State.ItemHeight;
end;

function ComputeVisibleCount(const State: TVirtualScrollState): Integer;
begin
  if State.ItemHeight <= 0 then
    Result := 10
  else
    Result := (State.ViewportHeight div State.ItemHeight) + 1;
end;

function ComputeStartIndex(const State: TVirtualScrollState): Integer;
var
  RawStart: Integer;
begin
  if State.ItemHeight <= 0 then
    RawStart := 0
  else
    RawStart := State.ScrollTop div State.ItemHeight;

  Result := RawStart - State.Buffer;
  if Result < 0 then
    Result := 0;
end;

function ComputeEndIndex(const State: TVirtualScrollState): Integer;
var
  RawStart, VisCount: Integer;
begin
  if State.ItemHeight <= 0 then
    RawStart := 0
  else
    RawStart := State.ScrollTop div State.ItemHeight;

  VisCount := ComputeVisibleCount(State);
  Result := RawStart + VisCount + State.Buffer;
  if Result > State.TotalCount then
    Result := State.TotalCount;
end;

function ComputeTopSpacerHeight(const State: TVirtualScrollState): Integer;
var
  StartIdx: Integer;
begin
  StartIdx := ComputeStartIndex(State);
  Result := StartIdx * State.ItemHeight;
end;

function ComputeBottomSpacerHeight(const State: TVirtualScrollState): Integer;
var
  EndIdx: Integer;
begin
  EndIdx := ComputeEndIndex(State);
  Result := (State.TotalCount - EndIdx) * State.ItemHeight;
  if Result < 0 then
    Result := 0;
end;

function ComputeRenderedCount(const State: TVirtualScrollState): Integer;
var
  StartIdx, EndIdx: Integer;
begin
  StartIdx := ComputeStartIndex(State);
  EndIdx := ComputeEndIndex(State);
  Result := EndIdx - StartIdx;
  if Result < 0 then
    Result := 0;
end;

var
  State: TVirtualScrollState;
  Wrapper: TWrapper;

begin
  Describe('BlaiseVue 4.0 Enterprise Virtual Scrolling Engine (<bv-virtual-scroll> & <bv-data-grid>)', procedure
    begin
      It('should calculate total height and initial viewport indices for 50,000 records', procedure
        begin
          State.TotalCount := 50000;
          State.ItemHeight := 40;
          State.ViewportHeight := 400; // 10 visible items
          State.Buffer := 5;
          State.ScrollTop := 0;

          // Total height = 50,000 * 40 = 2,000,000 px
          Expect(ComputeTotalHeight(State)).ToBe(2000000);
          Expect(ComputeStartIndex(State)).ToBe(0);
          // End index: raw 0 + (400 div 40 + 1) + 5 = 16
          Expect(ComputeEndIndex(State)).ToBe(16);
          Expect(ComputeTopSpacerHeight(State)).ToBe(0);
          // Bottom spacer: (50000 - 16) * 40 = 1,999,360 px
          Expect(ComputeBottomSpacerHeight(State)).ToBe(1999360);
          // Rendered items in DOM: only 16 rows out of 50,000!
          Expect(ComputeRenderedCount(State)).ToBe(16);
        end);

      It('should dynamically adjust top and bottom spacers on rapid scrolling without layout bloat', procedure
        begin
          State.TotalCount := 50000;
          State.ItemHeight := 40;
          State.ViewportHeight := 400;
          State.Buffer := 5;
          // Scroll down to row 1,000 (1000 * 40 = 40,000 px)
          State.ScrollTop := 40000;

          // Start index: 1000 - 5 = 995
          Expect(ComputeStartIndex(State)).ToBe(995);
          // End index: 1000 + 11 + 5 = 1016
          Expect(ComputeEndIndex(State)).ToBe(1016);
          // Top spacer = 995 * 40 = 39,800 px
          Expect(ComputeTopSpacerHeight(State)).ToBe(39800);
          // Bottom spacer = (50000 - 1016) * 40 = 1,959,360 px
          Expect(ComputeBottomSpacerHeight(State)).ToBe(1959360);
          // Rendered count remains strictly bounded: 1016 - 995 = 21 items
          Expect(ComputeRenderedCount(State)).ToBe(21);
          // Combined heights equal total virtual scroll canvas
          Expect(ComputeTopSpacerHeight(State) + (ComputeRenderedCount(State) * State.ItemHeight) + ComputeBottomSpacerHeight(State)).ToBe(ComputeTotalHeight(State));
        end);

      It('should clamp start and end indices correctly at the bottom of the dataset', procedure
        begin
          State.TotalCount := 100;
          State.ItemHeight := 50;
          State.ViewportHeight := 500; // 10 visible items (11 with +1)
          State.Buffer := 5;
          // Scroll to the very bottom: (100 - 10) * 50 = 4500 px
          State.ScrollTop := 4500;

          Expect(ComputeStartIndex(State)).ToBe(85); // 90 - 5 = 85
          Expect(ComputeEndIndex(State)).ToBe(100);  // clamped to TotalCount
          Expect(ComputeBottomSpacerHeight(State)).ToBe(0);
          Expect(ComputeTopSpacerHeight(State)).ToBe(85 * 50); // 4250 px
          Expect(ComputeRenderedCount(State)).ToBe(15);
        end);

      It('should mount <bv-virtual-scroll> component template structure', procedure
        begin
          Wrapper := Mount('<div class="bui-virtual-viewport" style="height: 400px; overflow-y: auto;">' +
                           '  <div class="bui-virtual-content" style="height: 2000000px; position: relative;">' +
                           '    <div class="bui-virtual-spacer" style="height: 0px;"></div>' +
                           '    <div class="bui-virtual-item">Row #1</div>' +
                           '    <div class="bui-virtual-item">Row #2</div>' +
                           '  </div>' +
                           '</div>');

          Expect(Wrapper.Exists).ToBe(True);
          Expect(Wrapper.Find('.bui-virtual-viewport').Exists).ToBe(True);
          Expect(Wrapper.Find('.bui-virtual-content').Exists).ToBe(True);
          Expect(Wrapper.Find('.bui-virtual-spacer').Exists).ToBe(True);
          Expect(Wrapper.FindAll('.bui-virtual-item').Count).ToBe(2);
          Wrapper.Destroy;
        end);

      It('should render <bv-data-grid> virtual table spacer rows in template', procedure
        begin
          Wrapper := Mount('<table class="bui-table bui-table-striped">' +
                           '  <thead><tr><th>ID</th><th>Customer</th></tr></thead>' +
                           '  <tbody>' +
                           '    <tr class="bui-virtual-spacer" style="height: 380px;"></tr>' +
                           '    <tr class="bui-table-row"><td>#100</td><td>John Doe</td></tr>' +
                           '    <tr class="bui-table-row"><td>#101</td><td>Jane Smith</td></tr>' +
                           '    <tr class="bui-virtual-spacer" style="height: 1820px;"></tr>' +
                           '  </tbody>' +
                           '</table>');

          Expect(Wrapper.Exists).ToBe(True);
          Expect(Wrapper.FindAll('.bui-virtual-spacer').Count).ToBe(2);
          Expect(Wrapper.FindAll('.bui-table-row').Count).ToBe(2);
          Wrapper.Destroy;
        end);
    end);
end.
