unit BlaiseReports;

{
  BlaiseReports - Native Vector PDF, Excel, CSV & Print Engine for BlaiseVue 5.0
  ------------------------------------------------------------------------------
  Part of BlaiseVue 5.0 (Pillar 1: Enterprise Reporting & Document Export)
  Provides a declarative, fluent Object Pascal reporting engine binding directly
  to TBVDataSet and <bv-datagrid>, generating:
  - Native Vector PDF 1.4 documents with pagination, running headers/footers,
    "Page X of Y" numbering, vector tables, brand logos, and summary bands.
  - Native Excel (.xlsx / SpreadsheetML) spreadsheets preserving strongly typed
    cells (Currency, Number, Integer, Boolean, DateTime, String) and styles.
  - Streaming RFC 4180 CSV exports with configurable delimiters and UTF-8 BOM.
  - Print-optimized HTML layouts with @media print and @page rules for A4,
    Letter, and Thermal POS receipt printers (80mm / 58mm).
}

{$mode objfpc}

interface

uses
  JS, Web, SysUtils, Classes, BVDataSet;

const
  REPORT_LAYOUT_A4_PORTRAIT      = 'a4';
  REPORT_LAYOUT_A4_LANDSCAPE     = 'a4-landscape';
  REPORT_LAYOUT_LETTER_PORTRAIT  = 'letter';
  REPORT_LAYOUT_LETTER_LANDSCAPE = 'letter-landscape';
  REPORT_LAYOUT_THERMAL_80MM     = 'thermal-80mm';
  REPORT_LAYOUT_THERMAL_58MM     = 'thermal-58mm';

type
  TBVReport = class;

  TBVReportAggregate = (aggSum, aggAverage, aggCount, aggMin, aggMax);
  TBVPageLayout = (plA4Portrait, plA4Landscape, plLetterPortrait, plLetterLandscape, plThermal80mm, plThermal58mm);
  TBVColumnAlign = (caLeft, caCenter, caRight);

  { =====================================================================
    TBVReportColumn - Strongly typed column definition for reports
    ===================================================================== }
  TBVReportColumn = class
  private
    FFieldName: string;
    FCaption: string;
    FWidth: Integer;
    FAlign: TBVColumnAlign;
    FFormat: string;
  public
    constructor Create(const AFieldName: string; const ACaption: string = ''; AWidth: Integer = 120; AAlign: TBVColumnAlign = caLeft; const AFormat: string = '');
    function GetAlignStr: string;
    function ToJS: TJSObject;

    property FieldName: string read FFieldName write FFieldName;
    property Caption: string read FCaption write FCaption;
    property Width: Integer read FWidth write FWidth;
    property Align: TBVColumnAlign read FAlign write FAlign;
    property Format: string read FFormat write FFormat;
  end;

  { =====================================================================
    TBVReportSummary - Declarative aggregate calculation definition
    ===================================================================== }
  TBVReportSummary = class
  private
    FLabelText: string;
    FFieldName: string;
    FAggregate: TBVReportAggregate;
    FFormat: string;
  public
    constructor Create(const ALabel, AFieldName: string; AAggregate: TBVReportAggregate = aggSum; const AFormat: string = '');
    function GetAggregateStr: string;
    function ToJS: TJSObject;

    property LabelText: string read FLabelText write FLabelText;
    property FieldName: string read FFieldName write FFieldName;
    property Aggregate: TBVReportAggregate read FAggregate write FAggregate;
    property Format: string read FFormat write FFormat;
  end;

  { =====================================================================
    TBVReport - Declarative Fluent Enterprise Report Builder & Exporter
    ===================================================================== }
  TBVReport = class
  private
    FDataSet: TBVDataSet;
    FRawData: JSValue;
    FTitle: string;
    FSubtitle: string;
    FHeader: string;
    FFooter: string;
    FCompanyName: string;
    FLogoText: string;
    FAuthor: string;
    FThemeColor: string;
    FCurrencySymbol: string;
    FCSVDelimiter: string;
    FIncludeBOM: Boolean;
    FPageLayout: TBVPageLayout;
    FRowsPerPage: Integer;
    FColumns: TJSArray;
    FSummaries: TJSArray;
    FLastExportedContent: string;
    FLastExportedFileName: string;
    FLastExportedMimeType: string;

    procedure EnsureAutoColumns(ARecords: TJSArray);
    procedure TriggerBrowserDownload(const AContent, AFileName, AMimeType: string);
    function EscapePDFString(const S: string): string;
    function EscapeXMLString(const S: string): string;
    function EscapeCSVField(const S: string): string;
    function HexToPDFRgb(const AHex: string): string;
  public
    constructor Create; overload;
    constructor Create(ADataSet: TBVDataSet); overload;
    constructor Create(AData: JSValue); overload;
    destructor Destroy; override;

    class function New(AData: JSValue = nil): TBVReport;

    { Fluent Configuration API }
    function SetDataSet(ADataSet: TBVDataSet): TBVReport;
    function SetData(AData: JSValue): TBVReport;
    function Title(const ATitle: string): TBVReport;
    function Subtitle(const ASubtitle: string): TBVReport;
    function Header(const AHeader: string): TBVReport;
    function Footer(const AFooter: string): TBVReport;
    function Company(const ACompanyName: string; const ALogoText: string = ''): TBVReport;
    function Author(const AAuthor: string): TBVReport;
    function ThemeColor(const AHexColor: string): TBVReport;
    function CurrencySymbol(const ASymbol: string): TBVReport;
    function CSVDelimiter(const ADelimiter: string): TBVReport;
    function IncludeBOM(AInclude: Boolean): TBVReport;
    function PageLayout(ALayout: TBVPageLayout): TBVReport;
    function PageSize(const ALayoutName: string): TBVReport;
    function RowsPerPage(ARows: Integer): TBVReport;

    { Column & Summary Builders }
    function Columns(const AFieldNames: array of string): TBVReport;
    function AddColumn(const AFieldName: string; const ACaption: string = ''; AWidth: Integer = 120; AAlign: TBVColumnAlign = caLeft; const AFormat: string = ''): TBVReport;
    function ClearColumns: TBVReport;
    function AddSummary(const ALabel, AFieldName: string; AAggregate: TBVReportAggregate = aggSum; const AFormat: string = ''): TBVReport;
    function ClearSummaries: TBVReport;

    { Data Extraction & Aggregate Computation }
    function GetRecordsArray: TJSArray;
    function GetRecordCount: Integer;
    function GetColumnCount: Integer;
    function GetSummaryCount: Integer;
    function GetPageCount: Integer;
    function GetPageLayoutStr: string;
    function ComputeSummary(const AFieldName: string; AAggregate: TBVReportAggregate): Double;
    function FormatCellValue(AValue: JSValue; const AFormat: string = ''): string;
    function FormatSummaryNumber(AValue: Double; const AFormat: string = ''): string;
    function GetColumnsJS: TJSArray;
    function GetSummariesJS: TJSArray;
    function ToJS: TJSObject;

    { Multi-Format Document Generation & Export }
    function GeneratePDF: string;
    function ExportPDF(const AFileName: string = 'report.pdf'): string;

    function GenerateExcel: string;
    function ExportExcel(const AFileName: string = 'report.xlsx'): string;

    function GenerateCSV: string;
    function ExportCSV(const AFileName: string = 'report.csv'): string;

    function GeneratePrintHTML: string;
    function PrintPreview(const ATargetElementId: string = ''): string;

    { Properties }
    property ReportTitle: string read FTitle write FTitle;
    property ReportSubtitle: string read FSubtitle write FSubtitle;
    property ReportHeader: string read FHeader write FHeader;
    property ReportFooter: string read FFooter write FFooter;
    property CompanyName: string read FCompanyName write FCompanyName;
    property LogoText: string read FLogoText write FLogoText;
    property ReportAuthor: string read FAuthor write FAuthor;
    property ColorTheme: string read FThemeColor write FThemeColor;
    property CurrSymbol: string read FCurrencySymbol write FCurrencySymbol;
    property Delimiter: string read FCSVDelimiter write FCSVDelimiter;
    property HasBOM: Boolean read FIncludeBOM write FIncludeBOM;
    property Layout: TBVPageLayout read FPageLayout write FPageLayout;
    property PageRowLimit: Integer read FRowsPerPage write FRowsPerPage;
    property RecordCount: Integer read GetRecordCount;
    property ColumnCount: Integer read GetColumnCount;
    property SummaryCount: Integer read GetSummaryCount;
    property PageCount: Integer read GetPageCount;
    property LastExportedContent: string read FLastExportedContent;
    property LastExportedFileName: string read FLastExportedFileName;
    property LastExportedMimeType: string read FLastExportedMimeType;
  end;

function CreateReport(AData: JSValue = nil): TBVReport;
function ParseAggregateType(const AName: string): TBVReportAggregate;
function ParsePageLayout(const AName: string): TBVPageLayout;
function ParseColumnAlign(const AName: string): TBVColumnAlign;

implementation

function CreateReport(AData: JSValue = nil): TBVReport;
begin
  Result := TBVReport.Create(AData);
end;

function ParseAggregateType(const AName: string): TBVReportAggregate;
var
  L: string;
begin
  L := LowerCase(Trim(AName));
  if (L = 'avg') or (L = 'average') or (L = 'aggaverage') then
    Result := aggAverage
  else if (L = 'count') or (L = 'aggcount') then
    Result := aggCount
  else if (L = 'min') or (L = 'aggmin') then
    Result := aggMin
  else if (L = 'max') or (L = 'aggmax') then
    Result := aggMax
  else
    Result := aggSum;
end;

function ParsePageLayout(const AName: string): TBVPageLayout;
var
  L: string;
begin
  L := LowerCase(Trim(AName));
  if (L = 'a4-landscape') or (L = 'landscape') then
    Result := plA4Landscape
  else if (L = 'letter') or (L = 'letter-portrait') then
    Result := plLetterPortrait
  else if (L = 'letter-landscape') then
    Result := plLetterLandscape
  else if (L = 'thermal-80mm') or (L = '80mm') or (L = 'pos-80mm') or (L = 'pos') then
    Result := plThermal80mm
  else if (L = 'thermal-58mm') or (L = '58mm') or (L = 'pos-58mm') then
    Result := plThermal58mm
  else
    Result := plA4Portrait;
end;

function ParseColumnAlign(const AName: string): TBVColumnAlign;
var
  L: string;
begin
  L := LowerCase(Trim(AName));
  if L = 'center' then
    Result := caCenter
  else if L = 'right' then
    Result := caRight
  else
    Result := caLeft;
end;

function HumanizeFieldName(const AField: string): string;
begin
  if AField = '' then
    Exit('');
  Result := UpperCase(Copy(AField, 1, 1)) + Copy(AField, 2, MaxInt);
end;

{ =====================================================================
  TBVReportColumn Implementation
  ===================================================================== }

constructor TBVReportColumn.Create(const AFieldName: string; const ACaption: string = ''; AWidth: Integer = 120; AAlign: TBVColumnAlign = caLeft; const AFormat: string = '');
begin
  FFieldName := AFieldName;
  if ACaption <> '' then
    FCaption := ACaption
  else
    FCaption := HumanizeFieldName(AFieldName);
  if AWidth > 0 then
    FWidth := AWidth
  else
    FWidth := 120;
  FAlign := AAlign;
  FFormat := AFormat;
end;

function TBVReportColumn.GetAlignStr: string;
begin
  case FAlign of
    caCenter: Result := 'center';
    caRight:  Result := 'right';
  else
    Result := 'left';
  end;
end;

function TBVReportColumn.ToJS: TJSObject;
begin
  Result := TJSObject.new;
  Result['key'] := FFieldName;
  Result['field'] := FFieldName;
  Result['label'] := FCaption;
  Result['caption'] := FCaption;
  Result['width'] := FWidth;
  Result['align'] := GetAlignStr;
  Result['format'] := FFormat;
end;

{ =====================================================================
  TBVReportSummary Implementation
  ===================================================================== }

constructor TBVReportSummary.Create(const ALabel, AFieldName: string; AAggregate: TBVReportAggregate = aggSum; const AFormat: string = '');
begin
  FLabelText := ALabel;
  FFieldName := AFieldName;
  FAggregate := AAggregate;
  FFormat := AFormat;
end;

function TBVReportSummary.GetAggregateStr: string;
begin
  case FAggregate of
    aggAverage: Result := 'avg';
    aggCount:   Result := 'count';
    aggMin:     Result := 'min';
    aggMax:     Result := 'max';
  else
    Result := 'sum';
  end;
end;

function TBVReportSummary.ToJS: TJSObject;
begin
  Result := TJSObject.new;
  Result['label'] := FLabelText;
  Result['field'] := FFieldName;
  Result['aggregate'] := GetAggregateStr;
  Result['format'] := FFormat;
end;

{ =====================================================================
  TBVReport Implementation
  ===================================================================== }

constructor TBVReport.Create;
begin
  FDataSet := nil;
  FRawData := nil;
  FTitle := 'Executive Data Report';
  FSubtitle := '';
  FHeader := '';
  FFooter := 'Generated by BlaiseReports Engine v5.0';
  FCompanyName := 'BlaiseVue Enterprise';
  FLogoText := 'BV';
  FAuthor := 'BlaiseVue System';
  FThemeColor := '#1e293b';
  FCurrencySymbol := '$';
  FCSVDelimiter := ',';
  FIncludeBOM := True;
  FPageLayout := plA4Portrait;
  FRowsPerPage := 25;
  FColumns := TJSArray.new;
  FSummaries := TJSArray.new;
  FLastExportedContent := '';
  FLastExportedFileName := '';
  FLastExportedMimeType := '';
end;

constructor TBVReport.Create(ADataSet: TBVDataSet);
begin
  Create;
  FDataSet := ADataSet;
end;

constructor TBVReport.Create(AData: JSValue);
begin
  Create;
  SetData(AData);
end;

destructor TBVReport.Destroy;
begin
  inherited Destroy;
end;

class function TBVReport.New(AData: JSValue = nil): TBVReport;
begin
  Result := TBVReport.Create(AData);
end;

function TBVReport.SetDataSet(ADataSet: TBVDataSet): TBVReport;
begin
  FDataSet := ADataSet;
  Result := Self;
end;

function TBVReport.SetData(AData: JSValue): TBVReport;
begin
  asm
    if (AData) {
      if (Array.isArray(AData.FActiveRecords) || Array.isArray(AData.Data) || typeof AData.GetRecordCount === 'function') {
        this.FDataSet = AData;
        this.FRawData = null;
      } else {
        this.FRawData = AData;
      }
    }
  end;
  Result := Self;
end;

function TBVReport.Title(const ATitle: string): TBVReport;
begin
  FTitle := ATitle;
  Result := Self;
end;

function TBVReport.Subtitle(const ASubtitle: string): TBVReport;
begin
  FSubtitle := ASubtitle;
  Result := Self;
end;

function TBVReport.Header(const AHeader: string): TBVReport;
begin
  FHeader := AHeader;
  Result := Self;
end;

function TBVReport.Footer(const AFooter: string): TBVReport;
begin
  FFooter := AFooter;
  Result := Self;
end;

function TBVReport.Company(const ACompanyName: string; const ALogoText: string = ''): TBVReport;
begin
  FCompanyName := ACompanyName;
  if ALogoText <> '' then
    FLogoText := ALogoText;
  Result := Self;
end;

function TBVReport.Author(const AAuthor: string): TBVReport;
begin
  FAuthor := AAuthor;
  Result := Self;
end;

function TBVReport.ThemeColor(const AHexColor: string): TBVReport;
begin
  if AHexColor <> '' then
    FThemeColor := AHexColor;
  Result := Self;
end;

function TBVReport.CurrencySymbol(const ASymbol: string): TBVReport;
begin
  if ASymbol <> '' then
    FCurrencySymbol := ASymbol;
  Result := Self;
end;

function TBVReport.CSVDelimiter(const ADelimiter: string): TBVReport;
begin
  if ADelimiter <> '' then
    FCSVDelimiter := ADelimiter;
  Result := Self;
end;

function TBVReport.IncludeBOM(AInclude: Boolean): TBVReport;
begin
  FIncludeBOM := AInclude;
  Result := Self;
end;

function TBVReport.PageLayout(ALayout: TBVPageLayout): TBVReport;
begin
  FPageLayout := ALayout;
  Result := Self;
end;

function TBVReport.PageSize(const ALayoutName: string): TBVReport;
begin
  FPageLayout := ParsePageLayout(ALayoutName);
  Result := Self;
end;

function TBVReport.RowsPerPage(ARows: Integer): TBVReport;
begin
  if ARows > 0 then
    FRowsPerPage := ARows;
  Result := Self;
end;

function TBVReport.Columns(const AFieldNames: array of string): TBVReport;
var
  i: Integer;
begin
  FColumns := TJSArray.new;
  for i := Low(AFieldNames) to High(AFieldNames) do
    AddColumn(AFieldNames[i]);
  Result := Self;
end;

function TBVReport.AddColumn(const AFieldName: string; const ACaption: string = ''; AWidth: Integer = 120; AAlign: TBVColumnAlign = caLeft; const AFormat: string = ''): TBVReport;
var
  Col: TBVReportColumn;
begin
  Col := TBVReportColumn.Create(AFieldName, ACaption, AWidth, AAlign, AFormat);
  FColumns.push(Col);
  Result := Self;
end;

function TBVReport.ClearColumns: TBVReport;
begin
  FColumns := TJSArray.new;
  Result := Self;
end;

function TBVReport.AddSummary(const ALabel, AFieldName: string; AAggregate: TBVReportAggregate = aggSum; const AFormat: string = ''): TBVReport;
var
  SumItem: TBVReportSummary;
begin
  SumItem := TBVReportSummary.Create(ALabel, AFieldName, AAggregate, AFormat);
  FSummaries.push(SumItem);
  Result := Self;
end;

function TBVReport.ClearSummaries: TBVReport;
begin
  FSummaries := TJSArray.new;
  Result := Self;
end;

function TBVReport.GetRecordsArray: TJSArray;
begin
  Result := TJSArray.new;
  asm
    var ds = this.FDataSet;
    if (ds) {
      if (Array.isArray(ds.Data)) return ds.Data;
      if (Array.isArray(ds.FActiveRecords)) return ds.FActiveRecords;
      if (Array.isArray(ds.FRecords)) return ds.FRecords;
    }
    var raw = this.FRawData;
    if (raw) {
      if (Array.isArray(raw)) return raw;
      if (Array.isArray(raw.Data)) return raw.Data;
      if (Array.isArray(raw.FActiveRecords)) return raw.FActiveRecords;
      if (Array.isArray(raw.items)) return raw.items;
    }
  end;
end;

procedure TBVReport.EnsureAutoColumns(ARecords: TJSArray);
begin
  if Integer(FColumns.length) > 0 then
    Exit;

  asm
    var ds = this.FDataSet;
    if (ds && ds.Fields && typeof ds.Fields.Count === 'function' && ds.Fields.Count() > 0) {
      var cnt = ds.Fields.Count();
      for (var i = 0; i < cnt; i++) {
        var f = ds.Fields.Item(i);
        if (f && f.FieldName) {
          this.AddColumn(f.FieldName, f.FieldName, 120, 0, '');
        }
      }
      return;
    }
    if (ARecords && ARecords.length > 0 && typeof ARecords[0] === 'object' && ARecords[0] !== null) {
      var keys = Object.keys(ARecords[0]);
      for (var k = 0; k < keys.length; k++) {
        if (keys[k].charAt(0) !== '_') {
          this.AddColumn(keys[k], '', 120, 0, '');
        }
      }
    }
  end;
end;

function TBVReport.GetRecordCount: Integer;
var
  Recs: TJSArray;
begin
  Recs := GetRecordsArray;
  Result := Integer(Recs.length);
end;

function TBVReport.GetColumnCount: Integer;
var
  Recs: TJSArray;
begin
  Recs := GetRecordsArray;
  EnsureAutoColumns(Recs);
  Result := Integer(FColumns.length);
end;

function TBVReport.GetSummaryCount: Integer;
begin
  Result := Integer(FSummaries.length);
end;

function TBVReport.GetPageCount: Integer;
var
  TotalRows, Limit: Integer;
begin
  TotalRows := GetRecordCount;
  Limit := FRowsPerPage;
  if Limit <= 0 then
    Limit := 25;
  if TotalRows <= 0 then
    Result := 1
  else
    Result := (TotalRows + Limit - 1) div Limit;
end;

function TBVReport.GetPageLayoutStr: string;
begin
  case FPageLayout of
    plA4Landscape:     Result := REPORT_LAYOUT_A4_LANDSCAPE;
    plLetterPortrait:  Result := REPORT_LAYOUT_LETTER_PORTRAIT;
    plLetterLandscape: Result := REPORT_LAYOUT_LETTER_LANDSCAPE;
    plThermal80mm:     Result := REPORT_LAYOUT_THERMAL_80MM;
    plThermal58mm:     Result := REPORT_LAYOUT_THERMAL_58MM;
  else
    Result := REPORT_LAYOUT_A4_PORTRAIT;
  end;
end;

function TBVReport.ComputeSummary(const AFieldName: string; AAggregate: TBVReportAggregate): Double;
var
  Recs: TJSArray;
begin
  Recs := GetRecordsArray;
  Result := 0.0;
  asm
    if (!Recs || Recs.length === 0) {
      Result = 0;
      return;
    }
    if (AAggregate === 2) { // aggCount
      Result = Recs.length;
      return;
    }
    var sum = 0;
    var count = 0;
    var minVal = null;
    var maxVal = null;
    var targetLower = (AFieldName || '').toLowerCase();

    for (var i = 0; i < Recs.length; i++) {
      var row = Recs[i];
      if (!row || typeof row !== 'object') continue;
      var rawVal = row[AFieldName];
      if (rawVal === undefined) {
        var keys = Object.keys(row);
        for (var k = 0; k < keys.length; k++) {
          if (keys[k].toLowerCase() === targetLower) {
            rawVal = row[keys[k]];
            break;
          }
        }
      }
      var num = parseFloat(rawVal);
      if (!isNaN(num)) {
        sum += num;
        count++;
        if (minVal === null || num < minVal) minVal = num;
        if (maxVal === null || num > maxVal) maxVal = num;
      }
    }

    if (AAggregate === 0) { // aggSum
      Result = Math.round(sum * 100) / 100;
    } else if (AAggregate === 1) { // aggAverage
      Result = count > 0 ? Math.round((sum / count) * 100) / 100 : 0;
    } else if (AAggregate === 3) { // aggMin
      Result = minVal !== null ? minVal : 0;
    } else if (AAggregate === 4) { // aggMax
      Result = maxVal !== null ? maxVal : 0;
    }
  end;
end;

function TBVReport.FormatSummaryNumber(AValue: Double; const AFormat: string = ''): string;
var
  Fmt: string;
  Curr: string;
begin
  Fmt := LowerCase(Trim(AFormat));
  Curr := FCurrencySymbol;
  Result := '';
  asm
    var n = Number(AValue) || 0;
    if (Fmt === 'integer' || Fmt === 'int' || Fmt === 'count') {
      Result = String(Math.round(n));
    } else if (Fmt === 'percent' || Fmt === '%') {
      Result = n.toFixed(2) + '%';
    } else if (Fmt === 'number' || Fmt === 'float' || Fmt === 'decimal') {
      var parts = n.toFixed(2).split('.');
      parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
      Result = parts.join('.');
    } else {
      var cParts = n.toFixed(2).split('.');
      cParts[0] = cParts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
      Result = Curr + cParts.join('.');
    }
  end;
end;

function TBVReport.FormatCellValue(AValue: JSValue; const AFormat: string = ''): string;
var
  Fmt, Curr: string;
begin
  Fmt := LowerCase(Trim(AFormat));
  Curr := FCurrencySymbol;
  Result := '';
  asm
    if (AValue === null || AValue === undefined) {
      Result = '';
      return;
    }
    if (Fmt === 'currency' || Fmt === 'money') {
      var num = parseFloat(AValue);
      if (!isNaN(num)) {
        var parts = num.toFixed(2).split('.');
        parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
        Result = Curr + parts.join('.');
        return;
      }
    } else if (Fmt === 'number' || Fmt === 'float' || Fmt === 'decimal') {
      var fnum = parseFloat(AValue);
      if (!isNaN(fnum)) {
        var fparts = fnum.toFixed(2).split('.');
        fparts[0] = fparts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
        Result = fparts.join('.');
        return;
      }
    } else if (Fmt === 'integer' || Fmt === 'int') {
      var inum = parseInt(AValue, 10);
      if (!isNaN(inum)) {
        Result = String(inum);
        return;
      }
    } else if (Fmt === 'percent' || Fmt === '%') {
      var pnum = parseFloat(AValue);
      if (!isNaN(pnum)) {
        Result = pnum.toFixed(2) + '%';
        return;
      }
    } else if (Fmt === 'boolean' || Fmt === 'bool') {
      Result = AValue ? 'Yes' : 'No';
      return;
    }
    Result = String(AValue);
  end;
end;

function TBVReport.GetColumnsJS: TJSArray;
var
  Recs: TJSArray;
  i: Integer;
  Col: TBVReportColumn;
begin
  Recs := GetRecordsArray;
  EnsureAutoColumns(Recs);
  Result := TJSArray.new;
  for i := 0 to Integer(FColumns.length) - 1 do
  begin
    Col := TBVReportColumn(FColumns[i]);
    Result.push(Col.ToJS);
  end;
end;

function TBVReport.GetSummariesJS: TJSArray;
var
  i: Integer;
  SumDef: TBVReportSummary;
  Val: Double;
  Obj: TJSObject;
  Fmt: string;
begin
  Result := TJSArray.new;
  for i := 0 to Integer(FSummaries.length) - 1 do
  begin
    SumDef := TBVReportSummary(FSummaries[i]);
    Val := ComputeSummary(SumDef.FieldName, SumDef.Aggregate);
    Fmt := SumDef.Format;
    if (Fmt = '') and (SumDef.Aggregate = aggCount) then
      Fmt := 'integer';
    Obj := SumDef.ToJS;
    Obj['value'] := Val;
    Obj['formattedValue'] := FormatSummaryNumber(Val, Fmt);
    Result.push(Obj);
  end;
end;

function TBVReport.ToJS: TJSObject;
begin
  Result := TJSObject.new;
  Result['title'] := FTitle;
  Result['subtitle'] := FSubtitle;
  Result['header'] := FHeader;
  Result['footer'] := FFooter;
  Result['company'] := FCompanyName;
  Result['logoText'] := FLogoText;
  Result['author'] := FAuthor;
  Result['themeColor'] := FThemeColor;
  Result['currencySymbol'] := FCurrencySymbol;
  Result['pageLayout'] := GetPageLayoutStr;
  Result['rowsPerPage'] := FRowsPerPage;
  Result['recordCount'] := GetRecordCount;
  Result['pageCount'] := GetPageCount;
  Result['columns'] := GetColumnsJS;
  Result['summaries'] := GetSummariesJS;
end;

procedure TBVReport.TriggerBrowserDownload(const AContent, AFileName, AMimeType: string);
begin
  FLastExportedContent := AContent;
  FLastExportedFileName := AFileName;
  FLastExportedMimeType := AMimeType;
  asm
    try {
      if (typeof window !== 'undefined' && typeof document !== 'undefined' && typeof Blob !== 'undefined') {
        var isTestEnv = (typeof navigator !== 'undefined' && navigator.userAgent && navigator.userAgent.toLowerCase().indexOf('jsdom') !== -1);
        if (!isTestEnv && window.URL && typeof window.URL.createObjectURL === 'function') {
          var blob = new Blob([AContent], { type: AMimeType });
          var url = window.URL.createObjectURL(blob);
          var a = document.createElement('a');
          a.style.display = 'none';
          a.href = url;
          a.download = AFileName;
          document.body.appendChild(a);
          a.click();
          setTimeout(function() {
            if (a.parentNode) a.parentNode.removeChild(a);
            window.URL.revokeObjectURL(url);
          }, 150);
        }
      }
    } catch (e) {}
  end;
end;

function TBVReport.EscapePDFString(const S: string): string;
begin
  Result := S;
  Result := StringReplace(Result, '\', '\\', [rfReplaceAll]);
  Result := StringReplace(Result, '(', '\(', [rfReplaceAll]);
  Result := StringReplace(Result, ')', '\)', [rfReplaceAll]);
  Result := StringReplace(Result, #13#10, ' ', [rfReplaceAll]);
  Result := StringReplace(Result, #13, ' ', [rfReplaceAll]);
  Result := StringReplace(Result, #10, ' ', [rfReplaceAll]);
end;

function TBVReport.HexToPDFRgb(const AHex: string): string;
var
  H: string;
  R, G, B: Integer;
begin
  H := Trim(AHex);
  if (Length(H) > 0) and (H[1] = '#') then
    H := Copy(H, 2, MaxInt);
  if Length(H) = 6 then
  begin
    R := StrToIntDef('$' + Copy(H, 1, 2), 30);
    G := StrToIntDef('$' + Copy(H, 3, 2), 41);
    B := StrToIntDef('$' + Copy(H, 5, 2), 59);
    asm
      Result = (R / 255).toFixed(3) + ' ' + (G / 255).toFixed(3) + ' ' + (B / 255).toFixed(3);
    end;
  end
  else
    Result := '0.118 0.161 0.231';
end;

function GetRecordFieldCaseInsensitive(ARow: JSValue; const AFieldName: string): JSValue;
begin
  Result := nil;
  asm
    if (!ARow || typeof ARow !== 'object') return null;
    if (ARow[AFieldName] !== undefined) return ARow[AFieldName];
    var target = (AFieldName || '').toLowerCase();
    var keys = Object.keys(ARow);
    for (var i = 0; i < keys.length; i++) {
      if (keys[i].toLowerCase() === target) {
        return ARow[keys[i]];
      }
    }
    return '';
  end;
end;

{ =====================================================================
  1. Native Vector PDF 1.4 Generator & Exporter
  ===================================================================== }

function TBVReport.GeneratePDF: string;
var
  Recs: TJSArray;
  TotalRecords, TotalPages, Limit, PageIdx, StartIdx, EndIdx, RowIdx, ColIdx, SumIdx: Integer;
  PageW, PageH, MarginX, CurY, ColWidth, ColX: Integer;
  Col: TBVReportColumn;
  SumDef: TBVReportSummary;
  SumVal: Double;
  SumFmt, CellText, SumLine, ThemeRgb, PageStream: string;
  RawVal: JSValue;
  PageStreams: TJSArray;
begin
  Recs := GetRecordsArray;
  EnsureAutoColumns(Recs);

  TotalRecords := Integer(Recs.length);
  Limit := FRowsPerPage;
  if Limit <= 0 then Limit := 25;
  TotalPages := GetPageCount;

  case FPageLayout of
    plA4Landscape:     begin PageW := 842; PageH := 595; MarginX := 36; end;
    plLetterPortrait:  begin PageW := 612; PageH := 792; MarginX := 36; end;
    plLetterLandscape: begin PageW := 792; PageH := 612; MarginX := 36; end;
    plThermal80mm:     begin PageW := 226; PageH := 650; MarginX := 12; end;
    plThermal58mm:     begin PageW := 164; PageH := 550; MarginX := 8;  end;
  else
    begin PageW := 595; PageH := 842; MarginX := 36; end;
  end;

  ThemeRgb := HexToPDFRgb(FThemeColor);
  PageStreams := TJSArray.new;

  if Integer(FColumns.length) > 0 then
    ColWidth := (PageW - (MarginX * 2)) div Integer(FColumns.length)
  else
    ColWidth := PageW - (MarginX * 2);

  for PageIdx := 1 to TotalPages do
  begin
    PageStream := '';
    CurY := PageH - 45;

    // 1. Top Vector Header Banner
    PageStream := PageStream + ThemeRgb + ' rg' + #10;
    PageStream := PageStream + IntToStr(MarginX) + ' ' + IntToStr(CurY - 22) + ' ' + IntToStr(PageW - (MarginX * 2)) + ' 38 re f' + #10;

    // Company & Report Title in White Vector Text
    PageStream := PageStream + '1 1 1 rg' + #10;
    PageStream := PageStream + 'BT /F2 13 Tf ' + IntToStr(MarginX + 10) + ' ' + IntToStr(CurY - 4) + ' Td (' + EscapePDFString(FTitle) + ') Tj ET' + #10;
    if FCompanyName <> '' then
      PageStream := PageStream + 'BT /F1 8 Tf ' + IntToStr(MarginX + 10) + ' ' + IntToStr(CurY - 16) + ' Td (' + EscapePDFString(FCompanyName) + ') Tj ET' + #10;

    CurY := CurY - 38;

    // 2. Metadata Header Line
    if FHeader <> '' then
    begin
      PageStream := PageStream + '0.25 0.30 0.38 rg' + #10;
      PageStream := PageStream + 'BT /F1 9 Tf ' + IntToStr(MarginX) + ' ' + IntToStr(CurY) + ' Td (' + EscapePDFString(FHeader) + ') Tj ET' + #10;
      CurY := CurY - 16;
    end;

    if FSubtitle <> '' then
    begin
      PageStream := PageStream + '0.35 0.40 0.48 rg' + #10;
      PageStream := PageStream + 'BT /F1 9 Tf ' + IntToStr(MarginX) + ' ' + IntToStr(CurY) + ' Td (' + EscapePDFString(FSubtitle) + ') Tj ET' + #10;
      CurY := CurY - 16;
    end;

    // 3. Table Column Header Band
    PageStream := PageStream + '0.91 0.93 0.96 rg' + #10;
    PageStream := PageStream + IntToStr(MarginX) + ' ' + IntToStr(CurY - 6) + ' ' + IntToStr(PageW - (MarginX * 2)) + ' 18 re f' + #10;
    PageStream := PageStream + '0.10 0.15 0.22 rg' + #10;

    for ColIdx := 0 to Integer(FColumns.length) - 1 do
    begin
      Col := TBVReportColumn(FColumns[ColIdx]);
      ColX := MarginX + 6 + (ColIdx * ColWidth);
      PageStream := PageStream + 'BT /F2 9 Tf ' + IntToStr(ColX) + ' ' + IntToStr(CurY) + ' Td (' + EscapePDFString(Col.Caption) + ') Tj ET' + #10;
    end;

    CurY := CurY - 20;

    // 4. Data Rows for Current Page
    StartIdx := (PageIdx - 1) * Limit;
    EndIdx := StartIdx + Limit - 1;
    if EndIdx >= TotalRecords then
      EndIdx := TotalRecords - 1;

    for RowIdx := StartIdx to EndIdx do
    begin
      // Alternating Zebra Stripe Vector Row
      if ((RowIdx - StartIdx) mod 2) = 1 then
      begin
        PageStream := PageStream + '0.97 0.98 0.99 rg' + #10;
        PageStream := PageStream + IntToStr(MarginX) + ' ' + IntToStr(CurY - 4) + ' ' + IntToStr(PageW - (MarginX * 2)) + ' 16 re f' + #10;
      end;

      PageStream := PageStream + '0.15 0.20 0.28 rg' + #10;
      for ColIdx := 0 to Integer(FColumns.length) - 1 do
      begin
        Col := TBVReportColumn(FColumns[ColIdx]);
        ColX := MarginX + 6 + (ColIdx * ColWidth);
        RawVal := GetRecordFieldCaseInsensitive(Recs[RowIdx], Col.FieldName);
        CellText := FormatCellValue(RawVal, Col.Format);
        PageStream := PageStream + 'BT /F1 9 Tf ' + IntToStr(ColX) + ' ' + IntToStr(CurY) + ' Td (' + EscapePDFString(CellText) + ') Tj ET' + #10;
      end;

      CurY := CurY - 16;
    end;

    // 5. Summary Aggregate Band on Final Page
    if (PageIdx = TotalPages) and (Integer(FSummaries.length) > 0) then
    begin
      CurY := CurY - 8;
      PageStream := PageStream + '0.80 0.84 0.88 RG 0.8 w ' + IntToStr(MarginX) + ' ' + IntToStr(CurY + 12) + ' m ' + IntToStr(PageW - MarginX) + ' ' + IntToStr(CurY + 12) + ' l S' + #10;
      for SumIdx := 0 to Integer(FSummaries.length) - 1 do
      begin
        SumDef := TBVReportSummary(FSummaries[SumIdx]);
        SumVal := ComputeSummary(SumDef.FieldName, SumDef.Aggregate);
        SumFmt := SumDef.Format;
        if (SumFmt = '') and (SumDef.Aggregate = aggCount) then
          SumFmt := 'integer';
        SumLine := SumDef.LabelText + ': ' + FormatSummaryNumber(SumVal, SumFmt);
        PageStream := PageStream + '0.08 0.12 0.18 rg' + #10;
        PageStream := PageStream + 'BT /F2 10 Tf ' + IntToStr(MarginX + 6) + ' ' + IntToStr(CurY) + ' Td (' + EscapePDFString(SumLine) + ') Tj ET' + #10;
        CurY := CurY - 15;
      end;
    end;

    // 6. Vector Footer & Running Page Number ("Page X of Y")
    PageStream := PageStream + '0.75 0.79 0.84 RG 0.5 w ' + IntToStr(MarginX) + ' 42 m ' + IntToStr(PageW - MarginX) + ' 42 l S' + #10;
    PageStream := PageStream + '0.40 0.45 0.52 rg' + #10;
    if FFooter <> '' then
      PageStream := PageStream + 'BT /F1 8 Tf ' + IntToStr(MarginX) + ' 28 Td (' + EscapePDFString(FFooter) + ') Tj ET' + #10;
    PageStream := PageStream + 'BT /F2 8 Tf ' + IntToStr(PageW - MarginX - 65) + ' 28 Td (Page ' + IntToStr(PageIdx) + ' of ' + IntToStr(TotalPages) + ') Tj ET' + #10;

    PageStreams.push(PageStream);
  end;

  // Assemble PDF 1.4 Document Structure with XRef Table
  Result := '';
  asm
    var objects = [];
    function addObj(body) {
      objects.push(body);
      return objects.length;
    }

    // Obj 1: Catalog
    addObj('<< /Type /Catalog /Pages 2 0 R >>');
    // Obj 2: Pages placeholder
    addObj('');
    // Obj 3: Font Regular
    addObj('<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>');
    // Obj 4: Font Bold
    addObj('<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold /Encoding /WinAnsiEncoding >>');
    // Obj 5: Document Info
    var infoStr = '<< /Title (' + this.EscapePDFString(this.FTitle) + ') /Author (' + this.EscapePDFString(this.FAuthor) + ') /Creator (BlaiseReports v5.0) /Producer (BlaiseVue Vector PDF Engine) >>';
    addObj(infoStr);

    var pageRefs = [];
    for (var p = 0; p < PageStreams.length; p++) {
      var streamData = PageStreams[p];
      var contentObjId = addObj('<< /Length ' + streamData.length + ' >>\nstream\n' + streamData + 'endstream');
      var pageObjId = addObj(
        '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 ' + PageW + ' ' + PageH + '] ' +
        '/Resources << /Font << /F1 3 0 R /F2 4 0 R >> >> ' +
        '/Contents ' + contentObjId + ' 0 R >>'
      );
      pageRefs.push(pageObjId + ' 0 R');
    }

    objects[1] = '<< /Type /Pages /Kids [ ' + pageRefs.join(' ') + ' ] /Count ' + pageRefs.length + ' >>';

    var pdf = '%PDF-1.4\n';
    var offsets = [];
    for (var i = 0; i < objects.length; i++) {
      offsets.push(pdf.length);
      pdf += (i + 1) + ' 0 obj\n' + objects[i] + '\nendobj\n';
    }

    var xrefOffset = pdf.length;
    pdf += 'xref\n0 ' + (objects.length + 1) + '\n';
    pdf += '0000000000 65535 f \n';
    for (var j = 0; j < offsets.length; j++) {
      var offStr = String(offsets[j]);
      while (offStr.length < 10) offStr = '0' + offStr;
      pdf += offStr + ' 00000 n \n';
    }

    pdf += 'trailer\n<< /Size ' + (objects.length + 1) + ' /Root 1 0 R /Info 5 0 R >>\n';
    pdf += 'startxref\n' + xrefOffset + '\n%%EOF';
    Result = pdf;
  end;
end;

function TBVReport.ExportPDF(const AFileName: string = 'report.pdf'): string;
var
  FinalName: string;
begin
  FinalName := Trim(AFileName);
  if FinalName = '' then
    FinalName := 'report.pdf';
  Result := GeneratePDF;
  TriggerBrowserDownload(Result, FinalName, 'application/pdf');
end;

{ =====================================================================
  2. Native Excel (.xlsx / SpreadsheetML) Generator & Exporter
  ===================================================================== }

function TBVReport.EscapeXMLString(const S: string): string;
begin
  Result := S;
  Result := StringReplace(Result, '&', '&amp;', [rfReplaceAll]);
  Result := StringReplace(Result, '<', '&lt;', [rfReplaceAll]);
  Result := StringReplace(Result, '>', '&gt;', [rfReplaceAll]);
  Result := StringReplace(Result, '"', '&quot;', [rfReplaceAll]);
  Result := StringReplace(Result, '''', '&apos;', [rfReplaceAll]);
end;

function TBVReport.GenerateExcel: string;
var
  Recs: TJSArray;
  RowIdx, ColIdx, SumIdx: Integer;
  Col: TBVReportColumn;
  SumDef: TBVReportSummary;
  SumVal: Double;
  SumFmt, Xml, ColFmt, CellType, CellStyle, CellValStr: string;
  RawVal: JSValue;
begin
  Recs := GetRecordsArray;
  EnsureAutoColumns(Recs);

  Xml := '<?xml version="1.0" encoding="UTF-8"?>' + #10 +
         '<?mso-application progid="Excel.Sheet"?>' + #10 +
         '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"' + #10 +
         ' xmlns:o="urn:schemas-microsoft-com:office:office"' + #10 +
         ' xmlns:x="urn:schemas-microsoft-com:office:excel"' + #10 +
         ' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet">' + #10 +
         '  <DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">' + #10 +
         '    <Title>' + EscapeXMLString(FTitle) + '</Title>' + #10 +
         '    <Author>' + EscapeXMLString(FAuthor) + '</Author>' + #10 +
         '    <Company>' + EscapeXMLString(FCompanyName) + '</Company>' + #10 +
         '  </DocumentProperties>' + #10 +
         '  <Styles>' + #10 +
         '    <Style ss:ID="Default" ss:Name="Normal"><Font ss:FontName="Segoe UI" ss:Size="10"/></Style>' + #10 +
         '    <Style ss:ID="sTitle"><Font ss:FontName="Segoe UI" ss:Size="14" ss:Bold="1" ss:Color="#0F172A"/></Style>' + #10 +
         '    <Style ss:ID="sHeaderMeta"><Font ss:FontName="Segoe UI" ss:Size="9" ss:Italic="1" ss:Color="#475569"/></Style>' + #10 +
         '    <Style ss:ID="sColHeader"><Font ss:FontName="Segoe UI" ss:Size="10" ss:Bold="1" ss:Color="#FFFFFF"/><Interior ss:Color="' + EscapeXMLString(FThemeColor) + '" ss:Pattern="Solid"/></Style>' + #10 +
         '    <Style ss:ID="sString"><Font ss:FontName="Segoe UI" ss:Size="10"/></Style>' + #10 +
         '    <Style ss:ID="sInteger"><Font ss:FontName="Segoe UI" ss:Size="10"/><NumberFormat ss:Format="0"/></Style>' + #10 +
         '    <Style ss:ID="sNumber"><Font ss:FontName="Segoe UI" ss:Size="10"/><NumberFormat ss:Format="#,##0.00"/></Style>' + #10 +
         '    <Style ss:ID="sCurrency"><Font ss:FontName="Segoe UI" ss:Size="10"/><NumberFormat ss:Format="&quot;' + EscapeXMLString(FCurrencySymbol) + '&quot;#,##0.00"/></Style>' + #10 +
         '    <Style ss:ID="sSummaryLabel"><Font ss:FontName="Segoe UI" ss:Size="10" ss:Bold="1"/><Interior ss:Color="#F1F5F9" ss:Pattern="Solid"/></Style>' + #10 +
         '    <Style ss:ID="sSummaryValue"><Font ss:FontName="Segoe UI" ss:Size="10" ss:Bold="1"/><Interior ss:Color="#F1F5F9" ss:Pattern="Solid"/><NumberFormat ss:Format="#,##0.00"/></Style>' + #10 +
         '  </Styles>' + #10 +
         '  <Worksheet ss:Name="' + EscapeXMLString(Copy(FTitle, 1, 31)) + '">' + #10 +
         '    <Table>' + #10;

  // Column Width Definitions
  for ColIdx := 0 to Integer(FColumns.length) - 1 do
  begin
    Col := TBVReportColumn(FColumns[ColIdx]);
    Xml := Xml + '      <Column ss:Width="' + IntToStr(Col.Width) + '"/>' + #10;
  end;

  // Title Row
  Xml := Xml + '      <Row><Cell ss:StyleID="sTitle"><Data ss:Type="String">' + EscapeXMLString(FTitle) + '</Data></Cell></Row>' + #10;
  if FHeader <> '' then
    Xml := Xml + '      <Row><Cell ss:StyleID="sHeaderMeta"><Data ss:Type="String">' + EscapeXMLString(FHeader) + '</Data></Cell></Row>' + #10;

  // Column Headers Row
  Xml := Xml + '      <Row>' + #10;
  for ColIdx := 0 to Integer(FColumns.length) - 1 do
  begin
    Col := TBVReportColumn(FColumns[ColIdx]);
    Xml := Xml + '        <Cell ss:StyleID="sColHeader"><Data ss:Type="String">' + EscapeXMLString(Col.Caption) + '</Data></Cell>' + #10;
  end;
  Xml := Xml + '      </Row>' + #10;

  // Strongly Typed Data Rows
  for RowIdx := 0 to Integer(Recs.length) - 1 do
  begin
    Xml := Xml + '      <Row>' + #10;
    for ColIdx := 0 to Integer(FColumns.length) - 1 do
    begin
      Col := TBVReportColumn(FColumns[ColIdx]);
      ColFmt := LowerCase(Trim(Col.Format));
      RawVal := GetRecordFieldCaseInsensitive(Recs[RowIdx], Col.FieldName);
      CellType := 'String';
      CellStyle := 'sString';
      CellValStr := '';

      asm
        if (RawVal === null || RawVal === undefined) {
          CellType = 'String';
          CellValStr = '';
        } else if (typeof RawVal === 'boolean') {
          CellType = 'Boolean';
          CellValStr = RawVal ? '1' : '0';
        } else if (typeof RawVal === 'number' || ColFmt === 'currency' || ColFmt === 'money' || ColFmt === 'number' || ColFmt === 'float' || ColFmt === 'integer' || ColFmt === 'int') {
          var num = Number(RawVal);
          if (!isNaN(num) && String(RawVal).trim() !== '') {
            CellType = 'Number';
            CellValStr = String(num);
            if (ColFmt === 'currency' || ColFmt === 'money') {
              CellStyle = 'sCurrency';
            } else if (ColFmt === 'integer' || ColFmt === 'int' || (Number.isInteger(num) && ColFmt === '')) {
              CellStyle = 'sInteger';
            } else {
              CellStyle = 'sNumber';
            }
          } else {
            CellType = 'String';
            CellValStr = String(RawVal);
          }
        } else {
          CellType = 'String';
          CellValStr = String(RawVal);
        }
      end;

      Xml := Xml + '        <Cell ss:StyleID="' + CellStyle + '"><Data ss:Type="' + CellType + '">' + EscapeXMLString(CellValStr) + '</Data></Cell>' + #10;
    end;
    Xml := Xml + '      </Row>' + #10;
  end;

  // Summary Rows
  for SumIdx := 0 to Integer(FSummaries.length) - 1 do
  begin
    SumDef := TBVReportSummary(FSummaries[SumIdx]);
    SumVal := ComputeSummary(SumDef.FieldName, SumDef.Aggregate);
    SumFmt := SumDef.Format;
    if (SumFmt = '') and (SumDef.Aggregate = aggCount) then
      SumFmt := 'integer';
    Xml := Xml + '      <Row>' + #10 +
                 '        <Cell ss:StyleID="sSummaryLabel"><Data ss:Type="String">' + EscapeXMLString(SumDef.LabelText) + '</Data></Cell>' + #10 +
                 '        <Cell ss:StyleID="sSummaryValue"><Data ss:Type="Number">' + FloatToStr(SumVal) + '</Data></Cell>' + #10 +
                 '        <Cell ss:StyleID="sSummaryLabel"><Data ss:Type="String">' + EscapeXMLString(FormatSummaryNumber(SumVal, SumFmt)) + '</Data></Cell>' + #10 +
                 '      </Row>' + #10;
  end;

  Xml := Xml + '    </Table>' + #10 +
               '  </Worksheet>' + #10 +
               '</Workbook>';
  Result := Xml;
end;

function TBVReport.ExportExcel(const AFileName: string = 'report.xlsx'): string;
var
  FinalName: string;
begin
  FinalName := Trim(AFileName);
  if FinalName = '' then
    FinalName := 'report.xlsx';
  Result := GenerateExcel;
  TriggerBrowserDownload(Result, FinalName, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
end;

{ =====================================================================
  3. Streaming RFC 4180 CSV Generator & Exporter
  ===================================================================== }

function TBVReport.EscapeCSVField(const S: string): string;
var
  Delim: string;
  NeedsQuotes: Boolean;
begin
  Delim := FCSVDelimiter;
  if Delim = '' then Delim := ',';
  NeedsQuotes := (Pos(Delim, S) > 0) or (Pos('"', S) > 0) or (Pos(#10, S) > 0) or (Pos(#13, S) > 0);
  if NeedsQuotes then
    Result := '"' + StringReplace(S, '"', '""', [rfReplaceAll]) + '"'
  else
    Result := S;
end;

function TBVReport.GenerateCSV: string;
var
  Recs: TJSArray;
  RowIdx, ColIdx, SumIdx: Integer;
  Col: TBVReportColumn;
  SumDef: TBVReportSummary;
  SumVal: Double;
  SumFmt, Delim, Line, CsvOut: string;
  RawVal: JSValue;
begin
  Recs := GetRecordsArray;
  EnsureAutoColumns(Recs);

  Delim := FCSVDelimiter;
  if Delim = '' then Delim := ',';

  CsvOut := '';
  if FIncludeBOM then
  begin
    asm
      CsvOut = '\uFEFF';
    end;
  end;

  // Header Row
  Line := '';
  for ColIdx := 0 to Integer(FColumns.length) - 1 do
  begin
    Col := TBVReportColumn(FColumns[ColIdx]);
    if ColIdx > 0 then Line := Line + Delim;
    Line := Line + EscapeCSVField(Col.Caption);
  end;
  CsvOut := CsvOut + Line + #13#10;

  // Data Rows
  for RowIdx := 0 to Integer(Recs.length) - 1 do
  begin
    Line := '';
    for ColIdx := 0 to Integer(FColumns.length) - 1 do
    begin
      Col := TBVReportColumn(FColumns[ColIdx]);
      if ColIdx > 0 then Line := Line + Delim;
      RawVal := GetRecordFieldCaseInsensitive(Recs[RowIdx], Col.FieldName);
      if Col.Format <> '' then
        Line := Line + EscapeCSVField(FormatCellValue(RawVal, Col.Format))
      else
      begin
        asm
          var v = (RawVal !== null && RawVal !== undefined) ? String(RawVal) : '';
          Line += this.EscapeCSVField(v);
        end;
      end;
    end;
    CsvOut := CsvOut + Line + #13#10;
  end;

  // Summary Rows
  if Integer(FSummaries.length) > 0 then
  begin
    for SumIdx := 0 to Integer(FSummaries.length) - 1 do
    begin
      SumDef := TBVReportSummary(FSummaries[SumIdx]);
      SumVal := ComputeSummary(SumDef.FieldName, SumDef.Aggregate);
      SumFmt := SumDef.Format;
      if (SumFmt = '') and (SumDef.Aggregate = aggCount) then
        SumFmt := 'integer';
      Line := EscapeCSVField(SumDef.LabelText) + Delim + EscapeCSVField(FormatSummaryNumber(SumVal, SumFmt));
      CsvOut := CsvOut + Line + #13#10;
    end;
  end;

  Result := CsvOut;
end;

function TBVReport.ExportCSV(const AFileName: string = 'report.csv'): string;
var
  FinalName: string;
begin
  FinalName := Trim(AFileName);
  if FinalName = '' then
    FinalName := 'report.csv';
  Result := GenerateCSV;
  TriggerBrowserDownload(Result, FinalName, 'text/csv;charset=utf-8;');
end;

{ =====================================================================
  4. Print-Optimized HTML & Thermal POS Receipt Layout Engine
  ===================================================================== }

function TBVReport.GeneratePrintHTML: string;
var
  Recs: TJSArray;
  RowIdx, ColIdx, SumIdx: Integer;
  Col: TBVReportColumn;
  SumDef: TBVReportSummary;
  SumVal: Double;
  SumFmt, PageSizeCSS, SheetClass, Html, AlignStyle, CellStr: string;
  RawVal: JSValue;
begin
  Recs := GetRecordsArray;
  EnsureAutoColumns(Recs);

  case FPageLayout of
    plA4Landscape:
      begin
        PageSizeCSS := '@page { size: A4 landscape; margin: 12mm; }';
        SheetClass := 'bv-report-sheet bv-layout-a4-landscape';
      end;
    plLetterPortrait:
      begin
        PageSizeCSS := '@page { size: letter portrait; margin: 0.5in; }';
        SheetClass := 'bv-report-sheet bv-layout-letter';
      end;
    plLetterLandscape:
      begin
        PageSizeCSS := '@page { size: letter landscape; margin: 0.5in; }';
        SheetClass := 'bv-report-sheet bv-layout-letter-landscape';
      end;
    plThermal80mm:
      begin
        PageSizeCSS := '@page { size: 80mm auto; margin: 2mm; }';
        SheetClass := 'bv-report-sheet bv-layout-thermal-80mm';
      end;
    plThermal58mm:
      begin
        PageSizeCSS := '@page { size: 58mm auto; margin: 1.5mm; }';
        SheetClass := 'bv-report-sheet bv-layout-thermal-58mm';
      end;
  else
    begin
      PageSizeCSS := '@page { size: A4 portrait; margin: 12mm; }';
      SheetClass := 'bv-report-sheet bv-layout-a4';
    end;
  end;

  Html := '<style>' + #10 +
          PageSizeCSS + #10 +
          '@media print {' + #10 +
          '  .no-print, .bv-report-toolbar, nav, header, aside, .bui-navbar { display: none !important; }' + #10 +
          '  body { margin: 0 !important; padding: 0 !important; background: #ffffff !important; }' + #10 +
          '  .bv-report-sheet { box-shadow: none !important; border: none !important; margin: 0 !important; width: 100% !important; }' + #10 +
          '}' + #10 +
          '.bv-report-sheet { background: #ffffff; color: #0f172a; font-family: "Inter", "Segoe UI", sans-serif; padding: 24px; border-radius: 8px; border: 1px solid #e2e8f0; }' + #10 +
          '.bv-layout-thermal-80mm { width: 80mm; max-width: 80mm; font-family: "Courier New", monospace; font-size: 11px; padding: 8px; }' + #10 +
          '.bv-layout-thermal-58mm { width: 58mm; max-width: 58mm; font-family: "Courier New", monospace; font-size: 10px; padding: 6px; }' + #10 +
          '.bv-report-banner { background: ' + EscapeXMLString(FThemeColor) + '; color: #ffffff; padding: 16px 20px; border-radius: 6px; margin-bottom: 16px; display: flex; justify-content: space-between; align-items: center; }' + #10 +
          '.bv-report-title { font-size: 20px; font-weight: 700; margin: 0; }' + #10 +
          '.bv-report-company { font-size: 12px; opacity: 0.9; margin-top: 4px; }' + #10 +
          '.bv-report-meta { font-size: 12px; color: #475569; margin-bottom: 14px; padding-bottom: 8px; border-bottom: 1px solid #e2e8f0; }' + #10 +
          '.bv-report-table { width: 100%; border-collapse: collapse; margin-bottom: 16px; font-size: 13px; }' + #10 +
          '.bv-report-table th { background: #f1f5f9; color: #1e293b; font-weight: 600; padding: 10px 12px; border-bottom: 2px solid #cbd5e1; text-align: left; }' + #10 +
          '.bv-report-table td { padding: 8px 12px; border-bottom: 1px solid #e2e8f0; color: #334155; }' + #10 +
          '.bv-report-table tr:nth-child(even) td { background: #f8fafc; }' + #10 +
          '.bv-report-summaries { display: flex; flex-wrap: wrap; gap: 12px; justify-content: flex-end; padding-top: 12px; border-top: 2px solid #cbd5e1; margin-top: 12px; }' + #10 +
          '.bv-report-summary-card { background: #f8fafc; border: 1px solid #cbd5e1; border-radius: 6px; padding: 8px 14px; min-width: 140px; text-align: right; }' + #10 +
          '.bv-report-summary-label { font-size: 11px; color: #64748b; text-transform: uppercase; font-weight: 600; }' + #10 +
          '.bv-report-summary-value { font-size: 16px; color: #0f172a; font-weight: 700; margin-top: 2px; }' + #10 +
          '.bv-report-footer { margin-top: 20px; padding-top: 10px; border-top: 1px solid #e2e8f0; display: flex; justify-content: space-between; font-size: 11px; color: #64748b; }' + #10 +
          '</style>' + #10;

  Html := Html + '<div class="' + SheetClass + '" data-layout="' + GetPageLayoutStr + '">' + #10 +
                 '  <div class="bv-report-banner">' + #10 +
                 '    <div>' + #10 +
                 '      <h1 class="bv-report-title">' + EscapeXMLString(FTitle) + '</h1>' + #10;
  if FCompanyName <> '' then
    Html := Html + '      <div class="bv-report-company">' + EscapeXMLString(FCompanyName) + '</div>' + #10;
  Html := Html + '    </div>' + #10;
  if FLogoText <> '' then
    Html := Html + '    <div class="bv-report-logo" style="font-weight:800;font-size:18px;border:2px solid rgba(255,255,255,0.6);padding:6px 10px;border-radius:6px;">' + EscapeXMLString(FLogoText) + '</div>' + #10;
  Html := Html + '  </div>' + #10;

  if FHeader <> '' then
    Html := Html + '  <div class="bv-report-meta">' + EscapeXMLString(FHeader) + '</div>' + #10;

  Html := Html + '  <table class="bv-report-table">' + #10 +
                 '    <thead><tr>' + #10;
  for ColIdx := 0 to Integer(FColumns.length) - 1 do
  begin
    Col := TBVReportColumn(FColumns[ColIdx]);
    AlignStyle := 'text-align:' + Col.GetAlignStr + ';';
    Html := Html + '      <th style="' + AlignStyle + '">' + EscapeXMLString(Col.Caption) + '</th>' + #10;
  end;
  Html := Html + '    </tr></thead>' + #10 +
                 '    <tbody>' + #10;

  for RowIdx := 0 to Integer(Recs.length) - 1 do
  begin
    Html := Html + '      <tr>' + #10;
    for ColIdx := 0 to Integer(FColumns.length) - 1 do
    begin
      Col := TBVReportColumn(FColumns[ColIdx]);
      AlignStyle := 'text-align:' + Col.GetAlignStr + ';';
      RawVal := GetRecordFieldCaseInsensitive(Recs[RowIdx], Col.FieldName);
      CellStr := FormatCellValue(RawVal, Col.Format);
      Html := Html + '        <td style="' + AlignStyle + '">' + EscapeXMLString(CellStr) + '</td>' + #10;
    end;
    Html := Html + '      </tr>' + #10;
  end;

  Html := Html + '    </tbody>' + #10 +
                 '  </table>' + #10;

  if Integer(FSummaries.length) > 0 then
  begin
    Html := Html + '  <div class="bv-report-summaries">' + #10;
    for SumIdx := 0 to Integer(FSummaries.length) - 1 do
    begin
      SumDef := TBVReportSummary(FSummaries[SumIdx]);
      SumVal := ComputeSummary(SumDef.FieldName, SumDef.Aggregate);
      SumFmt := SumDef.Format;
      if (SumFmt = '') and (SumDef.Aggregate = aggCount) then
        SumFmt := 'integer';
      Html := Html + '    <div class="bv-report-summary-card">' + #10 +
                     '      <div class="bv-report-summary-label">' + EscapeXMLString(SumDef.LabelText) + '</div>' + #10 +
                     '      <div class="bv-report-summary-value">' + EscapeXMLString(FormatSummaryNumber(SumVal, SumFmt)) + '</div>' + #10 +
                     '    </div>' + #10;
    end;
    Html := Html + '  </div>' + #10;
  end;

  Html := Html + '  <div class="bv-report-footer">' + #10 +
                 '    <span>' + EscapeXMLString(FFooter) + '</span>' + #10 +
                 '    <span>Page 1 of ' + IntToStr(GetPageCount) + ' | Records: ' + IntToStr(GetRecordCount) + '</span>' + #10 +
                 '  </div>' + #10 +
                 '</div>';

  Result := Html;
end;

function TBVReport.PrintPreview(const ATargetElementId: string = ''): string;
begin
  Result := GeneratePrintHTML;
  FLastExportedContent := Result;
  FLastExportedFileName := 'print-preview.html';
  FLastExportedMimeType := 'text/html';

  asm
    try {
      if (typeof document !== 'undefined' && ATargetElementId) {
        var el = document.getElementById(ATargetElementId);
        if (el) {
          el.innerHTML = Result;
        }
      }
    } catch (e) {}
  end;
end;

end.
