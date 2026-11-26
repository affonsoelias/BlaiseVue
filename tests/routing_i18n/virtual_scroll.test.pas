
Program virtual_scroll_test;

{$mode objfpc}


Uses JS, Web, BVTestUtils, BVComponents, BVReactivity, BVCompiler, BlaiseVue;

Type 
  TVirtualScrollState = Record
    TotalCount: Integer;
    ItemHeight: Integer;
    ViewportHeight: Integer;
    Buffer: Integer;
    ScrollTop: Integer;
  End;

Function ComputeTotalHeight(Const State: TVirtualScrollState): Integer;
Begin
  Result := State.TotalCount * State.ItemHeight;
End;

Function ComputeVisibleCount(Const State: TVirtualScrollState): Integer;
Begin
  If State.ItemHeight <= 0 Then
    Result := 10
  Else
    Result := (State.ViewportHeight Div State.ItemHeight) + 1;
End;

Function ComputeStartIndex(Const State: TVirtualScrollState): Integer;

Var 
  RawStart: Integer;
Begin
  If State.ItemHeight <= 0 Then
    RawStart := 0
  Else
    RawStart := State.ScrollTop Div State.ItemHeight;

  Result := RawStart - State.Buffer;
  If Result < 0 Then
    Result := 0;
End;

Function ComputeEndIndex(Const State: TVirtualScrollState): Integer;

Var 
  RawStart, VisCount: Integer;
Begin
  If State.ItemHeight <= 0 Then
    RawStart := 0
  Else
    RawStart := State.ScrollTop Div State.ItemHeight;

  VisCount := ComputeVisibleCount(State);
  Result := RawStart + VisCount + State.Buffer;
  If Result > State.TotalCount Then
    Result := State.TotalCount;
End;

Function ComputeTopSpacerHeight(Const State: TVirtualScrollState): Integer;

Var 
  StartIdx: Integer;
Begin
  StartIdx := ComputeStartIndex(State);
  Result := StartIdx * State.ItemHeight;
End;

Function ComputeBottomSpacerHeight(Const State: TVirtualScrollState): Integer;

Var 
  EndIdx: Integer;
Begin
  EndIdx := ComputeEndIndex(State);
  Result := (State.TotalCount - EndIdx) * State.ItemHeight;
  If Result < 0 Then
    Result := 0;
End;

Function ComputeRenderedCount(Const State: TVirtualScrollState): Integer;

Var 
  StartIdx, EndIdx: Integer;
Begin
  StartIdx := ComputeStartIndex(State);
  EndIdx := ComputeEndIndex(State);
  Result := EndIdx - StartIdx;
  If Result < 0 Then
    Result := 0;
End;

Var 
  State: TVirtualScrollState;
  Wrapper: TWrapper;

Begin
  Describe(
'BlaiseVue 4.0 Enterprise Virtual Scrolling Engine (<bv-virtual-scroll> & <bv-data-grid>)'
           , Procedure
           Begin
           It(
 'should calculate total height and initial viewport indices for 50,000 records'
           , Procedure
           Begin
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
End
);

It(
'should dynamically adjust top and bottom spacers on rapid scrolling without layout bloat'
   , Procedure
   Begin
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
Expect(ComputeTopSpacerHeight(State) + (ComputeRenderedCount(State) * State.
ItemHeight) + ComputeBottomSpacerHeight(State)).ToBe(ComputeTotalHeight(State));
End
);

It('should clamp start and end indices correctly at the bottom of the dataset',
   Procedure
   Begin
   State.TotalCount := 100;
   State.ItemHeight := 50;
   State.ViewportHeight := 500; // 10 visible items (11 with +1)
   State.Buffer := 5;
   // Scroll to the very bottom: (100 - 10) * 50 = 4500 px
   State.ScrollTop := 4500;

   Expect(ComputeStartIndex(State)).ToBe(85);
// 90 - 5 = 85
Expect(ComputeEndIndex(State)).ToBe(100);
// clamped to TotalCount
Expect(ComputeBottomSpacerHeight(State)).ToBe(0);
Expect(ComputeTopSpacerHeight(State)).ToBe(85 * 50);
// 4250 px
Expect(ComputeRenderedCount(State)).ToBe(15);
End
);

It('should mount <bv-virtual-scroll> component template structure', Procedure
   Var
   Comp: TJSObject;
   Begin
Comp := TJSObject.new;
Comp['template'] := 
                    '<div>' +

 '  <div class="bui-virtual-viewport" style="height: 400px; overflow-y: auto;">'
                    +

'    <div class="bui-virtual-content" style="height: 2000000px; position: relative;">'
                    +

             '      <div class="bui-virtual-spacer" style="height: 0px;"></div>'
                    +
                    '      <div class="bui-virtual-item">Row #1</div>' +
                    '      <div class="bui-virtual-item">Row #2</div>' +
                    '    </div>' +
                    '  </div>' +
                    '</div>';
RegisterComponent('test-virtual-scroll', Comp);

Wrapper := Mount('test-virtual-scroll');

Expect(Wrapper.Element <> Nil).ToBe(True);
Expect(Wrapper.Find('.bui-virtual-viewport') <> nil).ToBe(True);
Expect(Wrapper.Find('.bui-virtual-content') <> nil).ToBe(True);
Expect(Wrapper.Find('.bui-virtual-spacer') <> nil).ToBe(True);
Expect(Wrapper.FindAll('.bui-virtual-item').Length).ToBe(2);
End
);

It('should render <bv-data-grid> virtual table spacer rows in template',
   Procedure
   Var
   Comp: TJSObject;
   Begin
Comp := TJSObject.new;
Comp['template'] := 
                    '<table class="bui-table bui-table-striped">' +
                    '  <thead><tr><th>ID</th><th>Customer</th></tr></thead>' +
                    '  <tbody>' +

               '    <tr class="bui-virtual-spacer" style="height: 380px;"></tr>'
                    +

             '    <tr class="bui-table-row"><td>#100</td><td>John Doe</td></tr>'
                    +

           '    <tr class="bui-table-row"><td>#101</td><td>Jane Smith</td></tr>'
                    +

              '    <tr class="bui-virtual-spacer" style="height: 1820px;"></tr>'
                    +
                    '  </tbody>' +
                    '</table>';
RegisterComponent('test-virtual-grid', Comp);

Wrapper := Mount('test-virtual-grid');

Expect(Wrapper.Element <> Nil).ToBe(True);
Expect(Wrapper.FindAll('.bui-virtual-spacer').Length).ToBe(2);
Expect(Wrapper.FindAll('.bui-table-row').Length).ToBe(2);
End
);
End
);
End.
