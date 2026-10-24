unit BlaiseCharts;

{
  BlaiseCharts - High-Performance Reactive Charting Suite for BlaiseVue
  ---------------------------------------------------------------------
  Part of BlaiseVue 4.0 (Universal Pascal Ecosystem)
  Provides strongly typed Pascal classes, records, and builders for
  Chart.js integration with reactive HTML5 <canvas> acceleration.
}

{$mode objfpc}

interface

uses
  JS, Web, SysUtils;

const
  { Standard Chart Types }
  CHART_BAR        = 'bar';
  CHART_LINE       = 'line';
  CHART_PIE        = 'pie';
  CHART_DOUGHNUT   = 'doughnut';
  CHART_RADAR      = 'radar';
  CHART_POLAR_AREA = 'polarArea';
  CHART_SCATTER    = 'scatter';
  CHART_BUBBLE     = 'bubble';

type
  { Forward declarations }
  TBVChartDataset = class;
  TBVChartData = class;
  TBVChartOptions = class;
  TBVChartPalette = class;
  TBVChartBuilder = class;

  { =====================================================================
    TBVChartDataset - Strongly typed dataset representing a series
    ===================================================================== }
  TBVChartDataset = class
  private
    FJS: TJSObject;
  public
    constructor Create(const ALabel: string = ''); overload;
    constructor Create(AJS: TJSObject); overload;

    function SetLabel(const AVal: string): TBVChartDataset;
    function SetData(const AData: array of Double): TBVChartDataset; overload;
    function SetData(const AData: array of Integer): TBVChartDataset; overload;
    function SetDataPoints(const APoints: TJSArray): TBVChartDataset;
    function BackgroundColor(const AColor: string): TBVChartDataset;
    function BackgroundColors(const AColors: array of string): TBVChartDataset;
    function BorderColor(const AColor: string): TBVChartDataset;
    function BorderColors(const AColors: array of string): TBVChartDataset;
    function BorderWidth(AWidth: Integer): TBVChartDataset;
    function Fill(AFill: Boolean): TBVChartDataset;
    function Tension(ATension: Double): TBVChartDataset;
    function PointRadius(ARadius: Integer): TBVChartDataset;
    function PointHoverRadius(ARadius: Integer): TBVChartDataset;
    function ChartType(const AType: string): TBVChartDataset;

    function GetLabel: string;
    function GetData: TJSArray;
    property JS: TJSObject read FJS;
    function ToJS: TJSObject;
  end;

  { =====================================================================
    TBVChartData - Encapsulates labels and collections of datasets
    ===================================================================== }
  TBVChartData = class
  private
    FJS: TJSObject;
  public
    constructor Create; overload;
    constructor Create(AJS: TJSObject); overload;

    function Labels(const ALabels: array of string): TBVChartData;
    function AddLabel(const ALabel: string): TBVChartData;
    function ClearLabels: TBVChartData;

    function AddDataset(ADataset: TBVChartDataset): TBVChartDataset; overload;
    function AddDataset(const ALabel: string; const AData: array of Double; const ABgColor: string = ''; const ABorderColor: string = ''): TBVChartDataset; overload;
    function AddDataset(const ALabel: string; const AData: array of Integer; const ABgColor: string = ''; const ABorderColor: string = ''): TBVChartDataset; overload;
    function AddMultiColorDataset(const ALabel: string; const AData: array of Double; const AColors: array of string): TBVChartDataset; overload;
    function AddMultiColorDataset(const ALabel: string; const AData: array of Integer; const AColors: array of string): TBVChartDataset; overload;

    function Dataset(AIndex: Integer): TBVChartDataset;
    function DatasetCount: Integer;
    function ClearDatasets: TBVChartData;
    function Clear: TBVChartData;

    property JS: TJSObject read FJS;
    function ToJS: TJSObject;
  end;

  { =====================================================================
    TBVChartOptions - Highly customizable chart behavior and styles
    ===================================================================== }
  TBVChartOptions = class
  private
    FJS: TJSObject;
    function EnsurePlugins: TJSObject;
    function EnsureScales: TJSObject;
  public
    constructor Create; overload;
    constructor Create(AJS: TJSObject); overload;

    function Responsive(AVal: Boolean = True): TBVChartOptions;
    function MaintainAspectRatio(AVal: Boolean = False): TBVChartOptions;
    function Title(const AText: string; AFontSize: Integer = 16; const AColor: string = ''): TBVChartOptions;
    function Subtitle(const AText: string; AFontSize: Integer = 12): TBVChartOptions;
    function Legend(APosition: string = 'top'; ADisplay: Boolean = True): TBVChartOptions;
    function Tooltip(AEnabled: Boolean = True): TBVChartOptions;
    function Animation(AEnabled: Boolean = True): TBVChartOptions;
    function Scales(AXGrid: Boolean = True; AYGrid: Boolean = True; AYBeginAtZero: Boolean = True): TBVChartOptions;
    function DarkMode(AEnabled: Boolean): TBVChartOptions;
    function CustomOption(const APath: string; AValue: JSValue): TBVChartOptions;

    property JS: TJSObject read FJS;
    function ToJS: TJSObject;
  end;

  { =====================================================================
    TBVChartPalette - Modern curated color palettes
    ===================================================================== }
  TBVChartPalette = class
  public
    class function Color(AIndex: Integer; Alpha: Double = 1.0): string;
    class function HexToRgba(const AHex: string; Alpha: Double = 1.0): string;
    class function GetPalette(const AName: string = 'default'; Alpha: Double = 1.0): TJSArray;
    class function DefaultColors(Count: Integer = 8; Alpha: Double = 1.0): TJSArray;
    class function Emerald(Count: Integer = 6; Alpha: Double = 1.0): TJSArray;
    class function Sunset(Count: Integer = 6; Alpha: Double = 1.0): TJSArray;
    class function Neon(Count: Integer = 6; Alpha: Double = 1.0): TJSArray;
    class function Pastel(Count: Integer = 6; Alpha: Double = 1.0): TJSArray;
    class function Cyberpunk(Count: Integer = 6; Alpha: Double = 1.0): TJSArray;

    const
      PRIMARY   = '#3b82f6';
      SUCCESS   = '#10b981';
      WARNING   = '#f59e0b';
      DANGER    = '#ef4444';
      INFO      = '#06b6d4';
      INDIGO    = '#6366f1';
      PURPLE    = '#8b5cf6';
      PINK      = '#ec4899';
      TEAL      = '#14b8a6';
      AMBER     = '#f59e0b';
  end;

  { =====================================================================
    TBVChartBuilder - Single-chain fluent chart builder
    ===================================================================== }
  TBVChartBuilder = class
  private
    FType: string;
    FData: TBVChartData;
    FOptions: TBVChartOptions;
  public
    constructor Create(const AType: string = CHART_BAR);
    destructor Destroy; override;

    class function New(const AType: string = CHART_BAR): TBVChartBuilder;
    function WithLabels(const ALabels: array of string): TBVChartBuilder;
    function AddDataset(const ALabel: string; const AData: array of Double; const AColor: string = ''; const ABorderColor: string = ''): TBVChartBuilder; overload;
    function AddDataset(const ALabel: string; const AData: array of Integer; const AColor: string = ''; const ABorderColor: string = ''): TBVChartBuilder; overload;
    function AddMultiColorDataset(const ALabel: string; const AData: array of Double; const AColors: array of string): TBVChartBuilder; overload;
    function AddMultiColorDataset(const ALabel: string; const AData: array of Integer; const AColors: array of string): TBVChartBuilder; overload;
    function WithTitle(const ATitle: string): TBVChartBuilder;
    function WithLegend(const APosition: string = 'top'): TBVChartBuilder;
    function WithDarkMode(AEnabled: Boolean): TBVChartBuilder;
    function Responsive(AVal: Boolean = True): TBVChartBuilder;

    property Data: TBVChartData read FData;
    property Options: TBVChartOptions read FOptions;
    property ChartType: string read FType write FType;

    function BuildData: TJSObject;
    function BuildOptions: TJSObject;
  end;

implementation

{ =====================================================================
  TBVChartDataset Implementation
  ===================================================================== }

constructor TBVChartDataset.Create(const ALabel: string = '');
begin
  FJS := TJSObject.new;
  FJS['data'] := TJSArray.new;
  if ALabel <> '' then
    FJS['label'] := ALabel;
  FJS['borderWidth'] := 1;
end;

constructor TBVChartDataset.Create(AJS: TJSObject);
begin
  if AJS <> nil then
    FJS := AJS
  else
  begin
    FJS := TJSObject.new;
    FJS['data'] := TJSArray.new;
  end;
end;

function TBVChartDataset.SetLabel(const AVal: string): TBVChartDataset;
begin
  FJS['label'] := AVal;
  Result := Self;
end;

function TBVChartDataset.SetData(const AData: array of Double): TBVChartDataset;
var
  Arr: TJSArray;
  i: Integer;
begin
  Arr := TJSArray.new;
  for i := Low(AData) to High(AData) do
    Arr.push(AData[i]);
  FJS['data'] := Arr;
  Result := Self;
end;

function TBVChartDataset.SetData(const AData: array of Integer): TBVChartDataset;
var
  Arr: TJSArray;
  i: Integer;
begin
  Arr := TJSArray.new;
  for i := Low(AData) to High(AData) do
    Arr.push(AData[i]);
  FJS['data'] := Arr;
  Result := Self;
end;

function TBVChartDataset.SetDataPoints(const APoints: TJSArray): TBVChartDataset;
begin
  FJS['data'] := APoints;
  Result := Self;
end;

function TBVChartDataset.BackgroundColor(const AColor: string): TBVChartDataset;
begin
  FJS['backgroundColor'] := AColor;
  Result := Self;
end;

function TBVChartDataset.BackgroundColors(const AColors: array of string): TBVChartDataset;
var
  Arr: TJSArray;
  i: Integer;
begin
  Arr := TJSArray.new;
  for i := Low(AColors) to High(AColors) do
    Arr.push(AColors[i]);
  FJS['backgroundColor'] := Arr;
  Result := Self;
end;

function TBVChartDataset.BorderColor(const AColor: string): TBVChartDataset;
begin
  FJS['borderColor'] := AColor;
  Result := Self;
end;

function TBVChartDataset.BorderColors(const AColors: array of string): TBVChartDataset;
var
  Arr: TJSArray;
  i: Integer;
begin
  Arr := TJSArray.new;
  for i := Low(AColors) to High(AColors) do
    Arr.push(AColors[i]);
  FJS['borderColor'] := Arr;
  Result := Self;
end;

function TBVChartDataset.BorderWidth(AWidth: Integer): TBVChartDataset;
begin
  FJS['borderWidth'] := AWidth;
  Result := Self;
end;

function TBVChartDataset.Fill(AFill: Boolean): TBVChartDataset;
begin
  FJS['fill'] := AFill;
  Result := Self;
end;

function TBVChartDataset.Tension(ATension: Double): TBVChartDataset;
begin
  FJS['tension'] := ATension;
  Result := Self;
end;

function TBVChartDataset.PointRadius(ARadius: Integer): TBVChartDataset;
begin
  FJS['pointRadius'] := ARadius;
  Result := Self;
end;

function TBVChartDataset.PointHoverRadius(ARadius: Integer): TBVChartDataset;
begin
  FJS['pointHoverRadius'] := ARadius;
  Result := Self;
end;

function TBVChartDataset.ChartType(const AType: string): TBVChartDataset;
begin
  FJS['type'] := AType;
  Result := Self;
end;

function TBVChartDataset.GetLabel: string;
begin
  if FJS['label'] <> nil then
    Result := String(FJS['label'])
  else
    Result := '';
end;

function TBVChartDataset.GetData: TJSArray;
begin
  Result := TJSArray(FJS['data']);
end;

function TBVChartDataset.ToJS: TJSObject;
begin
  Result := FJS;
end;

{ =====================================================================
  TBVChartData Implementation
  ===================================================================== }

constructor TBVChartData.Create;
begin
  FJS := TJSObject.new;
  FJS['labels'] := TJSArray.new;
  FJS['datasets'] := TJSArray.new;
end;

constructor TBVChartData.Create(AJS: TJSObject);
begin
  if AJS <> nil then
    FJS := AJS
  else
    Create;
end;

function TBVChartData.Labels(const ALabels: array of string): TBVChartData;
var
  Arr: TJSArray;
  i: Integer;
begin
  Arr := TJSArray.new;
  for i := Low(ALabels) to High(ALabels) do
    Arr.push(ALabels[i]);
  FJS['labels'] := Arr;
  Result := Self;
end;

function TBVChartData.AddLabel(const ALabel: string): TBVChartData;
begin
  TJSArray(FJS['labels']).push(ALabel);
  Result := Self;
end;

function TBVChartData.ClearLabels: TBVChartData;
begin
  FJS['labels'] := TJSArray.new;
  Result := Self;
end;

function TBVChartData.AddDataset(ADataset: TBVChartDataset): TBVChartDataset;
begin
  TJSArray(FJS['datasets']).push(ADataset.ToJS);
  Result := ADataset;
end;

function TBVChartData.AddDataset(const ALabel: string; const AData: array of Double; const ABgColor: string = ''; const ABorderColor: string = ''): TBVChartDataset;
var
  Ds: TBVChartDataset;
begin
  Ds := TBVChartDataset.Create(ALabel);
  Ds.SetData(AData);
  if ABgColor <> '' then Ds.BackgroundColor(ABgColor)
  else Ds.BackgroundColor(TBVChartPalette.Color(DatasetCount, 0.4));

  if ABorderColor <> '' then Ds.BorderColor(ABorderColor)
  else Ds.BorderColor(TBVChartPalette.Color(DatasetCount, 1.0));

  AddDataset(Ds);
  Result := Ds;
end;

function TBVChartData.AddDataset(const ALabel: string; const AData: array of Integer; const ABgColor: string = ''; const ABorderColor: string = ''): TBVChartDataset;
var
  Ds: TBVChartDataset;
begin
  Ds := TBVChartDataset.Create(ALabel);
  Ds.SetData(AData);
  if ABgColor <> '' then Ds.BackgroundColor(ABgColor)
  else Ds.BackgroundColor(TBVChartPalette.Color(DatasetCount, 0.4));

  if ABorderColor <> '' then Ds.BorderColor(ABorderColor)
  else Ds.BorderColor(TBVChartPalette.Color(DatasetCount, 1.0));

  AddDataset(Ds);
  Result := Ds;
end;

function TBVChartData.AddMultiColorDataset(const ALabel: string; const AData: array of Double; const AColors: array of string): TBVChartDataset;
var
  Ds: TBVChartDataset;
begin
  Ds := TBVChartDataset.Create(ALabel);
  Ds.SetData(AData);
  Ds.BackgroundColors(AColors);
  Ds.BorderColors(AColors);
  AddDataset(Ds);
  Result := Ds;
end;

function TBVChartData.AddMultiColorDataset(const ALabel: string; const AData: array of Integer; const AColors: array of string): TBVChartDataset;
var
  Ds: TBVChartDataset;
begin
  Ds := TBVChartDataset.Create(ALabel);
  Ds.SetData(AData);
  Ds.BackgroundColors(AColors);
  Ds.BorderColors(AColors);
  AddDataset(Ds);
  Result := Ds;
end;

function TBVChartData.Dataset(AIndex: Integer): TBVChartDataset;
var
  Arr: TJSArray;
begin
  Arr := TJSArray(FJS['datasets']);
  if (AIndex >= 0) and (AIndex < Integer(Arr.length)) then
    Result := TBVChartDataset.Create(TJSObject(Arr[AIndex]))
  else
    Result := nil;
end;

function TBVChartData.DatasetCount: Integer;
begin
  if FJS['datasets'] <> nil then
    Result := Integer(TJSArray(FJS['datasets']).length)
  else
    Result := 0;
end;

function TBVChartData.ClearDatasets: TBVChartData;
begin
  FJS['datasets'] := TJSArray.new;
  Result := Self;
end;

function TBVChartData.Clear: TBVChartData;
begin
  ClearLabels;
  ClearDatasets;
  Result := Self;
end;

function TBVChartData.ToJS: TJSObject;
begin
  Result := FJS;
end;

{ =====================================================================
  TBVChartOptions Implementation
  ===================================================================== }

constructor TBVChartOptions.Create;
begin
  FJS := TJSObject.new;
  FJS['responsive'] := True;
  FJS['maintainAspectRatio'] := False;
  FJS['resizeDelay'] := 50;
end;

constructor TBVChartOptions.Create(AJS: TJSObject);
begin
  if AJS <> nil then
    FJS := AJS
  else
    Create;
end;

function TBVChartOptions.EnsurePlugins: TJSObject;
begin
  if FJS['plugins'] = nil then
    FJS['plugins'] := TJSObject.new;
  Result := TJSObject(FJS['plugins']);
end;

function TBVChartOptions.EnsureScales: TJSObject;
begin
  if FJS['scales'] = nil then
    FJS['scales'] := TJSObject.new;
  Result := TJSObject(FJS['scales']);
end;

function TBVChartOptions.Responsive(AVal: Boolean = True): TBVChartOptions;
begin
  FJS['responsive'] := AVal;
  Result := Self;
end;

function TBVChartOptions.MaintainAspectRatio(AVal: Boolean = False): TBVChartOptions;
begin
  FJS['maintainAspectRatio'] := AVal;
  Result := Self;
end;

function TBVChartOptions.Title(const AText: string; AFontSize: Integer = 16; const AColor: string = ''): TBVChartOptions;
var
  Plugins, TitleObj, FontObj: TJSObject;
begin
  Plugins := EnsurePlugins;
  TitleObj := TJSObject.new;
  TitleObj['display'] := True;
  TitleObj['text'] := AText;
  
  FontObj := TJSObject.new;
  FontObj['size'] := AFontSize;
  FontObj['weight'] := 'bold';
  TitleObj['font'] := FontObj;

  if AColor <> '' then
    TitleObj['color'] := AColor;

  Plugins['title'] := TitleObj;
  Result := Self;
end;

function TBVChartOptions.Subtitle(const AText: string; AFontSize: Integer = 12): TBVChartOptions;
var
  Plugins, SubObj, FontObj: TJSObject;
begin
  Plugins := EnsurePlugins;
  SubObj := TJSObject.new;
  SubObj['display'] := True;
  SubObj['text'] := AText;

  FontObj := TJSObject.new;
  FontObj['size'] := AFontSize;
  SubObj['font'] := FontObj;

  Plugins['subtitle'] := SubObj;
  Result := Self;
end;

function TBVChartOptions.Legend(APosition: string = 'top'; ADisplay: Boolean = True): TBVChartOptions;
var
  Plugins, LegObj: TJSObject;
begin
  Plugins := EnsurePlugins;
  LegObj := TJSObject.new;
  LegObj['display'] := ADisplay;
  LegObj['position'] := APosition;
  Plugins['legend'] := LegObj;
  Result := Self;
end;

function TBVChartOptions.Tooltip(AEnabled: Boolean = True): TBVChartOptions;
var
  Plugins, ToolObj: TJSObject;
begin
  Plugins := EnsurePlugins;
  ToolObj := TJSObject.new;
  ToolObj['enabled'] := AEnabled;
  Plugins['tooltip'] := ToolObj;
  Result := Self;
end;

function TBVChartOptions.Animation(AEnabled: Boolean = True): TBVChartOptions;
var
  AnimObj: TJSObject;
begin
  if AEnabled then
  begin
    AnimObj := TJSObject.new;
    AnimObj['duration'] := 750;
    AnimObj['easing'] := 'easeInOutQuart';
    FJS['animation'] := AnimObj;
  end
  else
    FJS['animation'] := False;
  Result := Self;
end;

function TBVChartOptions.Scales(AXGrid: Boolean = True; AYGrid: Boolean = True; AYBeginAtZero: Boolean = True): TBVChartOptions;
var
  S, XObj, YObj, XGridObj, YGridObj, TicksObj: TJSObject;
begin
  S := EnsureScales;

  XObj := TJSObject.new;
  XGridObj := TJSObject.new;
  XGridObj['display'] := AXGrid;
  XObj['grid'] := XGridObj;
  S['x'] := XObj;

  YObj := TJSObject.new;
  YGridObj := TJSObject.new;
  YGridObj['display'] := AYGrid;
  YObj['grid'] := YGridObj;
  
  TicksObj := TJSObject.new;
  TicksObj['beginAtZero'] := AYBeginAtZero;
  YObj['ticks'] := TicksObj;
  S['y'] := YObj;

  Result := Self;
end;

function TBVChartOptions.DarkMode(AEnabled: Boolean): TBVChartOptions;
var
  Plugins, LegObj, LabelsObj, S, XObj, YObj, XGridObj, YGridObj, XTicksObj, YTicksObj, TitleObj: TJSObject;
  TextColor, GridColor: string;
begin
  if AEnabled then
  begin
    TextColor := '#e5e7eb';
    GridColor := 'rgba(255, 255, 255, 0.1)';
  end
  else
  begin
    TextColor := '#4b5563';
    GridColor := 'rgba(0, 0, 0, 0.06)';
  end;

  Plugins := EnsurePlugins;

  // Title color
  if Plugins['title'] <> nil then
    TJSObject(Plugins['title'])['color'] := TextColor;

  // Legend color
  if Plugins['legend'] = nil then
    Plugins['legend'] := TJSObject.new;
  LegObj := TJSObject(Plugins['legend']);
  if LegObj['labels'] = nil then
    LegObj['labels'] := TJSObject.new;
  TJSObject(LegObj['labels'])['color'] := TextColor;

  // Scales
  S := EnsureScales;
  if S['x'] = nil then S['x'] := TJSObject.new;
  XObj := TJSObject(S['x']);
  if XObj['grid'] = nil then XObj['grid'] := TJSObject.new;
  TJSObject(XObj['grid'])['color'] := GridColor;
  if XObj['ticks'] = nil then XObj['ticks'] := TJSObject.new;
  TJSObject(XObj['ticks'])['color'] := TextColor;

  if S['y'] = nil then S['y'] := TJSObject.new;
  YObj := TJSObject(S['y']);
  if YObj['grid'] = nil then YObj['grid'] := TJSObject.new;
  TJSObject(YObj['grid'])['color'] := GridColor;
  if YObj['ticks'] = nil then YObj['ticks'] := TJSObject.new;
  TJSObject(YObj['ticks'])['color'] := TextColor;

  Result := Self;
end;

function TBVChartOptions.CustomOption(const APath: string; AValue: JSValue): TBVChartOptions;
begin
  asm
    let parts = APath.split('.');
    let cur = this.FJS;
    for (let i = 0; i < parts.length - 1; i++) {
      if (!cur[parts[i]]) cur[parts[i]] = {};
      cur = cur[parts[i]];
    }
    cur[parts[parts.length - 1]] = AValue;
  end;
  Result := Self;
end;

function TBVChartOptions.ToJS: TJSObject;
begin
  Result := FJS;
end;

{ =====================================================================
  TBVChartPalette Implementation
  ===================================================================== }

class function TBVChartPalette.HexToRgba(const AHex: string; Alpha: Double = 1.0): string;
var
  H: string;
  R, G, B: Integer;
begin
  H := AHex;
  if (Length(H) > 0) and (H[1] = '#') then
    H := Copy(H, 2, MaxInt);

  if Length(H) = 3 then
    H := H[1] + H[1] + H[2] + H[2] + H[3] + H[3];

  if Length(H) = 6 then
  begin
    R := StrToIntDef('$' + Copy(H, 1, 2), 0);
    G := StrToIntDef('$' + Copy(H, 3, 2), 0);
    B := StrToIntDef('$' + Copy(H, 5, 2), 0);
    Result := 'rgba(' + IntToStr(R) + ', ' + IntToStr(G) + ', ' + IntToStr(B) + ', ' + FloatToStr(Alpha) + ')';
  end
  else
    Result := AHex;
end;

class function TBVChartPalette.Color(AIndex: Integer; Alpha: Double = 1.0): string;
var
  Colors: array[0..7] of string = (
    '#3b82f6', // blue
    '#10b981', // emerald
    '#f59e0b', // amber
    '#ef4444', // red
    '#8b5cf6', // purple
    '#06b6d4', // cyan
    '#ec4899', // pink
    '#6366f1'  // indigo
  );
  Idx: Integer;
begin
  Idx := Abs(AIndex) mod 8;
  if Alpha < 1.0 then
    Result := HexToRgba(Colors[Idx], Alpha)
  else
    Result := Colors[Idx];
end;

class function TBVChartPalette.DefaultColors(Count: Integer = 8; Alpha: Double = 1.0): TJSArray;
var
  Arr: TJSArray;
  i: Integer;
begin
  Arr := TJSArray.new;
  for i := 0 to Count - 1 do
    Arr.push(Color(i, Alpha));
  Result := Arr;
end;

class function TBVChartPalette.Emerald(Count: Integer = 6; Alpha: Double = 1.0): TJSArray;
var
  Colors: array[0..5] of string = ('#059669', '#10b981', '#34d399', '#6ee7b7', '#a7f3d0', '#047857');
  Arr: TJSArray;
  i: Integer;
begin
  Arr := TJSArray.new;
  for i := 0 to Count - 1 do
    Arr.push(HexToRgba(Colors[i mod 6], Alpha));
  Result := Arr;
end;

class function TBVChartPalette.Sunset(Count: Integer = 6; Alpha: Double = 1.0): TJSArray;
var
  Colors: array[0..5] of string = ('#f43f5e', '#fb923c', '#facc15', '#a855f7', '#ec4899', '#f97316');
  Arr: TJSArray;
  i: Integer;
begin
  Arr := TJSArray.new;
  for i := 0 to Count - 1 do
    Arr.push(HexToRgba(Colors[i mod 6], Alpha));
  Result := Arr;
end;

class function TBVChartPalette.Neon(Count: Integer = 6; Alpha: Double = 1.0): TJSArray;
var
  Colors: array[0..5] of string = ('#00f0ff', '#ff007f', '#7000ff', '#00ff66', '#ffe600', '#ff3366');
  Arr: TJSArray;
  i: Integer;
begin
  Arr := TJSArray.new;
  for i := 0 to Count - 1 do
    Arr.push(HexToRgba(Colors[i mod 6], Alpha));
  Result := Arr;
end;

class function TBVChartPalette.Pastel(Count: Integer = 6; Alpha: Double = 1.0): TJSArray;
var
  Colors: array[0..5] of string = ('#a5b4fc', '#fbcfe8', '#fed7aa', '#bbf7d0', '#bae6fd', '#ddd6fe');
  Arr: TJSArray;
  i: Integer;
begin
  Arr := TJSArray.new;
  for i := 0 to Count - 1 do
    Arr.push(HexToRgba(Colors[i mod 6], Alpha));
  Result := Arr;
end;

class function TBVChartPalette.Cyberpunk(Count: Integer = 6; Alpha: Double = 1.0): TJSArray;
var
  Colors: array[0..5] of string = ('#fcee0a', '#00f0ff', '#ff003c', '#711c91', '#133e7c', '#0abdc6');
  Arr: TJSArray;
  i: Integer;
begin
  Arr := TJSArray.new;
  for i := 0 to Count - 1 do
    Arr.push(HexToRgba(Colors[i mod 6], Alpha));
  Result := Arr;
end;

class function TBVChartPalette.GetPalette(const AName: string = 'default'; Alpha: Double = 1.0): TJSArray;
var
  N: string;
begin
  N := LowerCase(AName);
  if N = 'emerald' then Result := Emerald(6, Alpha)
  else if N = 'sunset' then Result := Sunset(6, Alpha)
  else if N = 'neon' then Result := Neon(6, Alpha)
  else if N = 'pastel' then Result := Pastel(6, Alpha)
  else if N = 'cyberpunk' then Result := Cyberpunk(6, Alpha)
  else Result := DefaultColors(8, Alpha);
end;

{ =====================================================================
  TBVChartBuilder Implementation
  ===================================================================== }

constructor TBVChartBuilder.Create(const AType: string = CHART_BAR);
begin
  FType := AType;
  FData := TBVChartData.Create;
  FOptions := TBVChartOptions.Create;
end;

destructor TBVChartBuilder.Destroy;
begin
  inherited Destroy;
end;

class function TBVChartBuilder.New(const AType: string = CHART_BAR): TBVChartBuilder;
begin
  Result := TBVChartBuilder.Create(AType);
end;

function TBVChartBuilder.WithLabels(const ALabels: array of string): TBVChartBuilder;
begin
  FData.Labels(ALabels);
  Result := Self;
end;

function TBVChartBuilder.AddDataset(const ALabel: string; const AData: array of Double; const AColor: string = ''; const ABorderColor: string = ''): TBVChartBuilder;
begin
  FData.AddDataset(ALabel, AData, AColor, ABorderColor);
  Result := Self;
end;

function TBVChartBuilder.AddDataset(const ALabel: string; const AData: array of Integer; const AColor: string = ''; const ABorderColor: string = ''): TBVChartBuilder;
begin
  FData.AddDataset(ALabel, AData, AColor, ABorderColor);
  Result := Self;
end;

function TBVChartBuilder.AddMultiColorDataset(const ALabel: string; const AData: array of Double; const AColors: array of string): TBVChartBuilder;
begin
  FData.AddMultiColorDataset(ALabel, AData, AColors);
  Result := Self;
end;

function TBVChartBuilder.AddMultiColorDataset(const ALabel: string; const AData: array of Integer; const AColors: array of string): TBVChartBuilder;
begin
  FData.AddMultiColorDataset(ALabel, AData, AColors);
  Result := Self;
end;

function TBVChartBuilder.WithTitle(const ATitle: string): TBVChartBuilder;
begin
  FOptions.Title(ATitle);
  Result := Self;
end;

function TBVChartBuilder.WithLegend(const APosition: string = 'top'): TBVChartBuilder;
begin
  FOptions.Legend(APosition);
  Result := Self;
end;

function TBVChartBuilder.WithDarkMode(AEnabled: Boolean): TBVChartBuilder;
begin
  FOptions.DarkMode(AEnabled);
  Result := Self;
end;

function TBVChartBuilder.Responsive(AVal: Boolean = True): TBVChartBuilder;
begin
  FOptions.Responsive(AVal);
  Result := Self;
end;

function TBVChartBuilder.BuildData: TJSObject;
begin
  Result := FData.ToJS;
end;

function TBVChartBuilder.BuildOptions: TJSObject;
begin
  Result := FOptions.ToJS;
end;

initialization
  asm
    // Expose BlaiseCharts globally for window.$charts / __BV_CORE__.charts
    if (typeof window !== 'undefined') {
      if (!window.__BV_CORE__) window.__BV_CORE__ = {};
      window.__BV_CORE__.charts = {
        types: {
          bar: 'bar',
          line: 'line',
          pie: 'pie',
          doughnut: 'doughnut',
          radar: 'radar',
          polarArea: 'polarArea',
          scatter: 'scatter',
          bubble: 'bubble'
        }
      };
      window.$charts = window.__BV_CORE__.charts;

      // Universal Chart.js Safety Guard (neutralizes resize/update timers on destroyed charts)
      function __bv_install_chart_guard() {
        var C = (typeof window.Chart !== "undefined") ? window.Chart : ((typeof Chart !== "undefined") ? Chart : null);
        if (!C || !C.prototype || C.prototype.__bv_safe_guard) return;
        C.prototype.__bv_safe_guard = true;

        var origDestroy = C.prototype.destroy;
        C.prototype.destroy = function() {
          this._doResize = function() { return 0; };
          this.update = function() {};
          this.render = function() {};
          this.draw = function() {};
          return origDestroy.apply(this, arguments);
        };

        var origUpdate = C.prototype.update;
        C.prototype.update = function() {
          if (!this.canvas || !this.ctx) return;
          return origUpdate.apply(this, arguments);
        };

        var origRender = C.prototype.render;
        C.prototype.render = function() {
          if (!this.canvas || !this.ctx) return;
          return origRender.apply(this, arguments);
        };

        var origResize = C.prototype._resize;
        if (origResize) {
          C.prototype._resize = function() {
            if (!this.canvas || !this.ctx) return;
            return origResize.apply(this, arguments);
          };
        }
      }

      __bv_install_chart_guard();
      if (typeof window.addEventListener === "function") {
        window.addEventListener("DOMContentLoaded", __bv_install_chart_guard);
        window.addEventListener("load", __bv_install_chart_guard);
      }
    }
  end;

end.
