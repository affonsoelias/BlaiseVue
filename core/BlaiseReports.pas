unit BlaiseReports;

{
  BlaiseReports - Native Vector PDF, Excel, CSV & Print Engine for BlaiseVue 5.0
  ------------------------------------------------------------------------------
  Part of BlaiseVue 5.0 (Pillar 1: Enterprise Reporting & Document Export)
  Provides a declarative, fluent Object Pascal reporting engine binding directly
  to TBVDataSet and <bv-datagrid>, generating:
  - Native Vector PDF 1.4 documents with pagination, running headers/footers,
    "Page X of Y" numbering, vector tables, brand logos, and summary bands.
  - Native Excel (.xlsx, Office Open XML) spreadsheets preserving strongly typed
    cells (Currency, Number, Integer, Boolean, DateTime, String) and styles.
  - Streaming RFC 4180 CSV exports with configurable delimiters and UTF-8 BOM.
  - Print-optimized HTML layouts with @media print and @page rules for A4,
    Letter, and Thermal POS receipt printers (80mm / 58mm).
}

{$mode objfpc}

interface

uses
  JS, Web, SysUtils, Classes, BVDataSet, BlaiseReportsFonts;

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
    procedure DownloadBlobPart(APart: JSValue; const AFileName, AMimeType: string);
    function XlsxEscape(const S: string): string;
    function BuildXlsxSheetXml(ARecords: TJSArray): string;
    function BuildXlsxStylesXml: string;
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
    function GenerateXlsx: JSValue;
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
    property BadgeLogoText: string read FLogoText write FLogoText;
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
var
  RawSpec, ParsedField, ParsedCap, ParsedFmt, ParsedAlignStr: string;
  ParsedWidth: Integer;
begin
  RawSpec := Trim(AFieldName);
  if (Pos(':', RawSpec) > 0) and (ACaption = '') and (AFormat = '') then
  begin
    ParsedField := '';
    ParsedCap := '';
    ParsedFmt := '';
    ParsedAlignStr := '';
    ParsedWidth := AWidth;
    asm
      var parts = RawSpec.split(':');
      ParsedField = (parts[0] || '').trim();
      ParsedCap = (parts.length > 1 && parts[1]) ? parts[1].trim() : '';
      ParsedFmt = (parts.length > 2 && parts[2]) ? parts[2].trim() : '';
      ParsedAlignStr = (parts.length > 3 && parts[3]) ? parts[3].trim() : '';
      if (parts.length > 4 && parts[4]) {
        var pw = parseInt(parts[4], 10);
        if (!isNaN(pw) && pw > 0) ParsedWidth = pw;
      }
    end;
    FFieldName := ParsedField;
    if ParsedCap <> '' then
      FCaption := ParsedCap
    else
      FCaption := HumanizeFieldName(ParsedField);
    FFormat := ParsedFmt;
    if ParsedAlignStr <> '' then
      FAlign := ParseColumnAlign(ParsedAlignStr)
    else if (LowerCase(ParsedFmt) = 'currency') or (LowerCase(ParsedFmt) = 'money') or
            (LowerCase(ParsedFmt) = 'number') or (LowerCase(ParsedFmt) = 'float') then
      FAlign := caRight
    else
      FAlign := AAlign;
    if ParsedWidth > 0 then
      FWidth := ParsedWidth
    else
      FWidth := 120;
  end
  else
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
  Result['fieldName'] := FFieldName;
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
      if (Array.isArray(ds.Data)) {
        Result = ds.Data;
      } else if (Array.isArray(ds.FActiveRecords)) {
        Result = ds.FActiveRecords;
      } else if (Array.isArray(ds.FRecords)) {
        Result = ds.FRecords;
      }
      return Result;
    }
    var raw = this.FRawData;
    if (raw) {
      if (Array.isArray(raw)) {
        Result = raw;
      } else if (Array.isArray(raw.Data)) {
        Result = raw.Data;
      } else if (Array.isArray(raw.FActiveRecords)) {
        Result = raw.FActiveRecords;
      } else if (Array.isArray(raw.items)) {
        Result = raw.items;
      }
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
  AggIdx: Integer;
begin
  Recs := GetRecordsArray;
  AggIdx := Ord(AAggregate);
  Result := 0.0;
  asm
    if (!Recs || Recs.length === 0) {
      Result = 0;
      return;
    }
    if (AggIdx === 2) { // aggCount
      Result = Recs.length;
    } else {
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

      if (AggIdx === 0) { // aggSum
        Result = Math.round(sum * 100) / 100;
      } else if (AggIdx === 1) { // aggAverage
        Result = count > 0 ? Math.round((sum / count) * 100) / 100 : 0;
      } else if (AggIdx === 3) { // aggMin
        Result = minVal !== null ? minVal : 0;
      } else if (AggIdx === 4) { // aggMax
        Result = maxVal !== null ? maxVal : 0;
      }
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
    } else if (Fmt === 'currency' || Fmt === 'money') {
      var num = parseFloat(AValue);
      if (!isNaN(num)) {
        var parts = num.toFixed(2).split('.');
        parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
        Result = Curr + parts.join('.');
      } else {
        Result = String(AValue);
      }
    } else if (Fmt === 'number' || Fmt === 'float' || Fmt === 'decimal') {
      var fnum = parseFloat(AValue);
      if (!isNaN(fnum)) {
        var fparts = fnum.toFixed(2).split('.');
        fparts[0] = fparts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
        Result = fparts.join('.');
      } else {
        Result = String(AValue);
      }
    } else if (Fmt === 'integer' || Fmt === 'int') {
      var inum = parseInt(AValue, 10);
      if (!isNaN(inum)) {
        Result = String(inum);
      } else {
        Result = String(AValue);
      }
    } else if (Fmt === 'percent' || Fmt === '%') {
      var pnum = parseFloat(AValue);
      if (!isNaN(pnum)) {
        Result = pnum.toFixed(2) + '%';
      } else {
        Result = String(AValue);
      }
    } else if (Fmt === 'boolean' || Fmt === 'bool') {
      Result = AValue ? 'Yes' : 'No';
    } else {
      Result = String(AValue);
    }
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
  DownloadBlobPart(AContent, AFileName, AMimeType);
end;

procedure TBVReport.DownloadBlobPart(APart: JSValue; const AFileName, AMimeType: string);
begin
  asm
    try {
      if (typeof window !== 'undefined' && typeof document !== 'undefined' && typeof Blob !== 'undefined') {
        var isTestEnv = (typeof navigator !== 'undefined' && navigator.userAgent && navigator.userAgent.toLowerCase().indexOf('jsdom') !== -1);
        if (!isTestEnv && window.URL && typeof window.URL.createObjectURL === 'function') {
          var blob = new Blob([APart], { type: AMimeType });
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
  Result := '';
  asm
    if (ARow && typeof ARow === 'object') {
      if (ARow[AFieldName] !== undefined) {
        Result = ARow[AFieldName];
      } else {
        var target = (AFieldName || '').toLowerCase();
        var keys = Object.keys(ARow);
        for (var i = 0; i < keys.length; i++) {
          if (keys[i].toLowerCase() === target) {
            Result = ARow[keys[i]];
            break;
          }
        }
      }
    }
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
  FontRegular, FontBold: TJSObject;
begin
  Recs := GetRecordsArray;
  EnsureAutoColumns(Recs);
  FontRegular := TJSObject.new;
  FontRegular['name'] := BVPdfFontRegularName;
  FontRegular['length1'] := BVPdfFontRegularLength1;
  FontRegular['bbox'] := BVPdfFontRegularBBox;
  FontRegular['ascent'] := BVPdfFontRegularAscent;
  FontRegular['descent'] := BVPdfFontRegularDescent;
  FontRegular['cap'] := BVPdfFontRegularCapHeight;
  FontRegular['cmap'] := BVPdfFontRegularCmap;
  FontRegular['widths'] := BVPdfFontRegularWidths;
  FontRegular['data'] := BVPdfFontRegularData;
  FontRegular['stemV'] := 80;
  FontBold := TJSObject.new;
  FontBold['name'] := BVPdfFontBoldName;
  FontBold['length1'] := BVPdfFontBoldLength1;
  FontBold['bbox'] := BVPdfFontBoldBBox;
  FontBold['ascent'] := BVPdfFontBoldAscent;
  FontBold['descent'] := BVPdfFontBoldDescent;
  FontBold['cap'] := BVPdfFontBoldCapHeight;
  FontBold['cmap'] := BVPdfFontBoldCmap;
  FontBold['widths'] := BVPdfFontBoldWidths;
  FontBold['data'] := BVPdfFontBoldData;
  FontBold['stemV'] := 140;

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
    var self = this;
    function infoText(text) {
      if (!new RegExp('[^\\x00-\\x7F]').test(text)) return '(' + self.EscapePDFString(text) + ')';
      var hex = 'FEFF';
      for (var h = 0; h < text.length; h++) hex += hex4(text.charCodeAt(h));
      return '<' + hex + '>';
    }
    function hex4(n) {
      var out = n.toString(16).toUpperCase();
      while (out.length < 4) out = '0' + out;
      return out;
    }
    var infoStr = '<< /Title ' + infoText(this.FTitle) + ' /Author ' + infoText(this.FAuthor) + ' /Creator (BlaiseReports v5.0) /Producer (BlaiseVue Vector PDF Engine) >>';
    addObj(infoStr);

    // The page streams still hold raw characters inside their text operands, and every
    // byte of the file must stay ASCII because the xref offsets count string length.
    // Helvetica covers WinAnsi only, so any other character switches both fonts to the
    // embedded Latin + Greek subset, drawn through glyph ids in hex strings.
    var winAnsiHigh = {0x20AC:0x80,0x201A:0x82,0x0192:0x83,0x201E:0x84,0x2026:0x85,0x2020:0x86,0x2021:0x87,0x02C6:0x88,0x2030:0x89,0x0160:0x8A,0x2039:0x8B,0x0152:0x8C,0x017D:0x8E,0x2018:0x91,0x2019:0x92,0x201C:0x93,0x201D:0x94,0x2022:0x95,0x2013:0x96,0x2014:0x97,0x02DC:0x98,0x2122:0x99,0x0161:0x9A,0x203A:0x9B,0x0153:0x9C,0x017E:0x9E,0x0178:0x9F};
    var needsEmbed = false;
    var nonAscii = new RegExp('[^\\x00-\\x7F]', 'g');
    var streams = [];
    for (var s = 0; s < PageStreams.length; s++) {
      var normalized = PageStreams[s].normalize('NFC');
      var found = normalized.match(nonAscii) || [];
      for (var k = 0; k < found.length; k++) {
        var code = found[k].charCodeAt(0);
        if (code < 0xA0 && winAnsiHigh[code] === undefined || code > 0xFF && winAnsiHigh[code] === undefined) needsEmbed = true;
      }
      streams.push(normalized);
    }

    function parseCmap(text) {
      var map = {};
      var entries = text.split(',');
      for (var e = 0; e < entries.length; e++) {
        var pair = entries[e].split(':');
        map[parseInt(pair[0], 16)] = parseInt(pair[1], 16);
      }
      return map;
    }

    function addEmbeddedFont(slot, font, tag) {
      var baseName = tag + '+' + font.name;
      var fileId = addObj('<< /Length ' + font.data.length + ' /Length1 ' + font.length1 + ' /Filter [/ASCII85Decode /FlateDecode] >>\nstream\n' + font.data + '\nendstream');
      var descId = addObj('<< /Type /FontDescriptor /FontName /' + baseName + ' /Flags 4 /FontBBox [' + font.bbox + '] /ItalicAngle 0 /Ascent ' + font.ascent + ' /Descent ' + font.descent + ' /CapHeight ' + font.cap + ' /StemV ' + font.stemV + ' /FontFile2 ' + fileId + ' 0 R >>');
      var cidId = addObj('<< /Type /Font /Subtype /CIDFontType2 /BaseFont /' + baseName + ' /CIDSystemInfo << /Registry (Adobe) /Ordering (Identity) /Supplement 0 >> /FontDescriptor ' + descId + ' 0 R /W [0 [' + font.widths + ']] /CIDToGIDMap /Identity >>');
      var seen = {};
      var lines = [];
      var entries = font.cmap.split(',');
      for (var e = 0; e < entries.length; e++) {
        var pair = entries[e].split(':');
        var gid = parseInt(pair[1], 16);
        if (seen[gid]) continue;
        seen[gid] = true;
        lines.push('<' + hex4(gid) + '> <' + hex4(parseInt(pair[0], 16)) + '>');
      }
      var cmapText = '/CIDInit /ProcSet findresource begin\n12 dict begin\nbegincmap\n/CIDSystemInfo << /Registry (Adobe) /Ordering (UCS) /Supplement 0 >> def\n/CMapName /Adobe-Identity-UCS def\n/CMapType 2 def\n1 begincodespacerange\n<0000> <FFFF>\nendcodespacerange\n';
      for (var b = 0; b < lines.length; b += 100) {
        var block = lines.slice(b, b + 100);
        cmapText += block.length + ' beginbfchar\n' + block.join('\n') + '\nendbfchar\n';
      }
      cmapText += 'endcmap\nCMapName currentdict /CMap defineresource pop\nend\nend\n';
      var unicodeId = addObj('<< /Length ' + cmapText.length + ' >>\nstream\n' + cmapText + 'endstream');
      objects[slot] = '<< /Type /Font /Subtype /Type0 /BaseFont /' + baseName + ' /Encoding /Identity-H /DescendantFonts [' + cidId + ' 0 R] /ToUnicode ' + unicodeId + ' 0 R >>';
    }

    function encodeGlyphs(text, map) {
      var hex = '';
      var fallback = map[0x3F];
      for (var c = 0; c < text.length; c++) {
        var unit = text.charCodeAt(c);
        if (unit >= 0xD800 && unit <= 0xDBFF) c++;
        var gid = map[unit];
        hex += hex4(gid === undefined ? fallback : gid);
      }
      return '<' + hex + '>';
    }

    if (needsEmbed) {
      addEmbeddedFont(2, FontRegular, 'BVAAAA');
      addEmbeddedFont(3, FontBold, 'BVAAAB');
      var maps = {'1': parseCmap(FontRegular.cmap), '2': parseCmap(FontBold.cmap)};
      var textOp = new RegExp('/F([12]) ([0-9.]+) Tf ([^(]*)\\(((?:[^\\\\()]|\\\\.)*)\\) Tj', 'g');
      var unescapePdf = new RegExp('\\\\(.)', 'g');
      for (var t = 0; t < streams.length; t++) {
        streams[t] = streams[t].replace(textOp, function (all, fontNo, size, between, text) {
          return '/F' + fontNo + ' ' + size + ' Tf ' + between + encodeGlyphs(text.replace(unescapePdf, '$1'), maps[fontNo]) + ' Tj';
        });
      }
    } else {
      for (var w = 0; w < streams.length; w++) {
        streams[w] = streams[w].replace(nonAscii, function (ch) {
          var unit = ch.charCodeAt(0);
          var octal = (winAnsiHigh[unit] === undefined ? unit : winAnsiHigh[unit]).toString(8);
          return '\\' + octal;
        });
      }
    }

    var pageRefs = [];
    for (var p = 0; p < streams.length; p++) {
      var streamData = streams[p];
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

{ =====================================================================
  Office Open XML (.xlsx) package writer
  An .xlsx file is a ZIP archive of XML parts; entries are stored without
  compression, which every spreadsheet reader accepts.
  ===================================================================== }

function XlsxColumnName(AIndex: Integer): string;
var
  N: Integer;
begin
  Result := '';
  N := AIndex + 1;
  while N > 0 do
  begin
    Result := Chr(65 + ((N - 1) mod 26)) + Result;
    N := (N - 1) div 26;
  end;
end;

function XlsxBuildZip(AEntries: JSValue): JSValue;
begin
  Result := nil;
  asm
    if (typeof TextEncoder !== 'undefined') {
      var encoder = new TextEncoder();
      var crcTable = [];
      for (var n = 0; n < 256; n++) {
        var c = n;
        for (var k = 0; k < 8; k++) {
          c = (c & 1) ? (3988292384 ^ (c >>> 1)) : (c >>> 1);
        }
        crcTable[n] = c >>> 0;
      }
      var parts = [];
      var total = 0;
      var centralSize = 0;
      for (var i = 0; i < AEntries.length; i++) {
        var nameBytes = encoder.encode(AEntries[i].name);
        var dataBytes = encoder.encode(AEntries[i].text);
        var crc = 4294967295;
        for (var b = 0; b < dataBytes.length; b++) {
          crc = crcTable[(crc ^ dataBytes[b]) & 255] ^ (crc >>> 8);
        }
        crc = (crc ^ 4294967295) >>> 0;
        parts.push({ nameBytes: nameBytes, dataBytes: dataBytes, crc: crc, offset: total });
        total += 30 + nameBytes.length + dataBytes.length;
        centralSize += 46 + nameBytes.length;
      }
      var zip = new Uint8Array(total + centralSize + 22);
      var view = new DataView(zip.buffer);
      var writeHeaderFields = function (at, part) {
        view.setUint16(at, 20, true);
        view.setUint16(at + 2, 2048, true);
        view.setUint16(at + 4, 0, true);
        view.setUint16(at + 6, 0, true);
        view.setUint16(at + 8, 33, true);
        view.setUint32(at + 10, part.crc, true);
        view.setUint32(at + 14, part.dataBytes.length, true);
        view.setUint32(at + 18, part.dataBytes.length, true);
        view.setUint16(at + 22, part.nameBytes.length, true);
        view.setUint16(at + 24, 0, true);
      };
      for (var p = 0; p < parts.length; p++) {
        var part = parts[p];
        view.setUint32(part.offset, 67324752, true);
        writeHeaderFields(part.offset + 4, part);
        zip.set(part.nameBytes, part.offset + 30);
        zip.set(part.dataBytes, part.offset + 30 + part.nameBytes.length);
      }
      var cursor = total;
      for (var q = 0; q < parts.length; q++) {
        var entry = parts[q];
        view.setUint32(cursor, 33639248, true);
        view.setUint16(cursor + 4, 20, true);
        writeHeaderFields(cursor + 6, entry);
        view.setUint32(cursor + 42, entry.offset, true);
        zip.set(entry.nameBytes, cursor + 46);
        cursor += 46 + entry.nameBytes.length;
      }
      view.setUint32(cursor, 101010256, true);
      view.setUint16(cursor + 8, parts.length, true);
      view.setUint16(cursor + 10, parts.length, true);
      view.setUint32(cursor + 12, centralSize, true);
      view.setUint32(cursor + 16, total, true);
      Result = zip;
    }
  end;
end;

function TBVReport.XlsxEscape(const S: string): string;
var
  Clean: string;
begin
  Clean := S;
  asm
    Clean = String(Clean).replace(new RegExp('[\\u0000-\\u0008\\u000B\\u000C\\u000E-\\u001F\\uFFFE\\uFFFF]', 'g'), '');
  end;
  Result := EscapeXMLString(Clean);
end;

function TBVReport.BuildXlsxSheetXml(ARecords: TJSArray): string;
const
  STYLE_TITLE = 1;
  STYLE_META = 2;
  STYLE_COL_HEADER = 3;
  STYLE_SUMMARY_LABEL = 8;
  STYLE_SUMMARY_VALUE = 9;
var
  RowNum, RowIdx, ColIdx, SumIdx, CellStyle: Integer;
  Col: TBVReportColumn;
  SumDef: TBVReportSummary;
  SumVal: Double;
  SumFmt, Cols, Rows, RowXml, ColFmt, CellKind, CellValStr, WidthStr, NumStr: string;
  RawVal: JSValue;

  function TextCell(const ARef: string; AStyle: Integer; const AText: string): string;
  begin
    if AText = '' then
      Result := '<c r="' + ARef + '" s="' + IntToStr(AStyle) + '"/>'
    else
      Result := '<c r="' + ARef + '" s="' + IntToStr(AStyle) + '" t="inlineStr"><is><t xml:space="preserve">' + XlsxEscape(AText) + '</t></is></c>';
  end;

begin
  Cols := '';
  for ColIdx := 0 to Integer(FColumns.length) - 1 do
  begin
    Col := TBVReportColumn(FColumns[ColIdx]);
    WidthStr := '';
    asm
      WidthStr = (Math.max(Number(Col.FWidth) || 120, 20) / 7).toFixed(2);
    end;
    Cols := Cols + '<col min="' + IntToStr(ColIdx + 1) + '" max="' + IntToStr(ColIdx + 1) + '" width="' + WidthStr + '" customWidth="1"/>';
  end;
  if Cols <> '' then
    Cols := '<cols>' + Cols + '</cols>';

  RowNum := 1;
  Rows := '<row r="1">' + TextCell('A1', STYLE_TITLE, FTitle) + '</row>';
  if FHeader <> '' then
  begin
    RowNum := RowNum + 1;
    Rows := Rows + '<row r="' + IntToStr(RowNum) + '">' + TextCell('A' + IntToStr(RowNum), STYLE_META, FHeader) + '</row>';
  end;

  RowNum := RowNum + 1;
  RowXml := '';
  for ColIdx := 0 to Integer(FColumns.length) - 1 do
  begin
    Col := TBVReportColumn(FColumns[ColIdx]);
    RowXml := RowXml + TextCell(XlsxColumnName(ColIdx) + IntToStr(RowNum), STYLE_COL_HEADER, Col.Caption);
  end;
  Rows := Rows + '<row r="' + IntToStr(RowNum) + '">' + RowXml + '</row>';

  for RowIdx := 0 to Integer(ARecords.length) - 1 do
  begin
    RowNum := RowNum + 1;
    RowXml := '';
    for ColIdx := 0 to Integer(FColumns.length) - 1 do
    begin
      Col := TBVReportColumn(FColumns[ColIdx]);
      ColFmt := LowerCase(Trim(Col.Format));
      RawVal := GetRecordFieldCaseInsensitive(ARecords[RowIdx], Col.FieldName);
      CellKind := 'text';
      CellStyle := 4;
      CellValStr := '';
      asm
        if (RawVal === null || RawVal === undefined) {
          CellValStr = '';
        } else if (typeof RawVal === 'boolean') {
          CellKind = 'bool';
          CellValStr = RawVal ? '1' : '0';
        } else if (typeof RawVal === 'number' || ColFmt === 'currency' || ColFmt === 'money' || ColFmt === 'number' || ColFmt === 'float' || ColFmt === 'integer' || ColFmt === 'int') {
          var num = Number(RawVal);
          if (isFinite(num) && String(RawVal).trim() !== '') {
            CellKind = 'number';
            CellValStr = String(num);
            if (ColFmt === 'currency' || ColFmt === 'money') {
              CellStyle = 7;
            } else if (ColFmt === 'integer' || ColFmt === 'int' || (Number.isInteger(num) && ColFmt === '')) {
              CellStyle = 5;
            } else {
              CellStyle = 6;
            }
          } else {
            CellValStr = String(RawVal);
          }
        } else {
          CellValStr = String(RawVal);
        }
      end;
      if CellKind = 'number' then
        RowXml := RowXml + '<c r="' + XlsxColumnName(ColIdx) + IntToStr(RowNum) + '" s="' + IntToStr(CellStyle) + '"><v>' + CellValStr + '</v></c>'
      else if CellKind = 'bool' then
        RowXml := RowXml + '<c r="' + XlsxColumnName(ColIdx) + IntToStr(RowNum) + '" s="' + IntToStr(CellStyle) + '" t="b"><v>' + CellValStr + '</v></c>'
      else
        RowXml := RowXml + TextCell(XlsxColumnName(ColIdx) + IntToStr(RowNum), CellStyle, CellValStr);
    end;
    Rows := Rows + '<row r="' + IntToStr(RowNum) + '">' + RowXml + '</row>';
  end;

  for SumIdx := 0 to Integer(FSummaries.length) - 1 do
  begin
    SumDef := TBVReportSummary(FSummaries[SumIdx]);
    SumVal := ComputeSummary(SumDef.FieldName, SumDef.Aggregate);
    SumFmt := SumDef.Format;
    if (SumFmt = '') and (SumDef.Aggregate = aggCount) then
      SumFmt := 'integer';
    NumStr := '0';
    asm
      NumStr = isFinite(SumVal) ? String(SumVal) : '0';
    end;
    RowNum := RowNum + 1;
    Rows := Rows + '<row r="' + IntToStr(RowNum) + '">' +
      TextCell('A' + IntToStr(RowNum), STYLE_SUMMARY_LABEL, SumDef.LabelText) +
      '<c r="B' + IntToStr(RowNum) + '" s="' + IntToStr(STYLE_SUMMARY_VALUE) + '"><v>' + NumStr + '</v></c>' +
      TextCell('C' + IntToStr(RowNum), STYLE_SUMMARY_LABEL, FormatSummaryNumber(SumVal, SumFmt)) +
      '</row>';
  end;

  Result := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' + #10 +
    '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">' +
    Cols + '<sheetData>' + Rows + '</sheetData></worksheet>';
end;

function TBVReport.BuildXlsxStylesXml: string;
var
  ThemeArgb: string;
begin
  ThemeArgb := FThemeColor;
  asm
    var hex = String(ThemeArgb).trim();
    ThemeArgb = new RegExp('^#?[0-9a-fA-F]{6}$').test(hex) ? ('FF' + hex.replace('#', '').toUpperCase()) : 'FF334155';
  end;
  Result := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' + #10 +
    '<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">' +
    '<numFmts count="1"><numFmt numFmtId="164" formatCode="&quot;' + XlsxEscape(FCurrencySymbol) + '&quot;#,##0.00"/></numFmts>' +
    '<fonts count="5">' +
    '<font><sz val="10"/><name val="Segoe UI"/></font>' +
    '<font><b/><sz val="14"/><color rgb="FF0F172A"/><name val="Segoe UI"/></font>' +
    '<font><i/><sz val="9"/><color rgb="FF475569"/><name val="Segoe UI"/></font>' +
    '<font><b/><sz val="10"/><color rgb="FFFFFFFF"/><name val="Segoe UI"/></font>' +
    '<font><b/><sz val="10"/><name val="Segoe UI"/></font>' +
    '</fonts>' +
    '<fills count="4">' +
    '<fill><patternFill patternType="none"/></fill>' +
    '<fill><patternFill patternType="gray125"/></fill>' +
    '<fill><patternFill patternType="solid"><fgColor rgb="' + ThemeArgb + '"/><bgColor indexed="64"/></patternFill></fill>' +
    '<fill><patternFill patternType="solid"><fgColor rgb="FFF1F5F9"/><bgColor indexed="64"/></patternFill></fill>' +
    '</fills>' +
    '<borders count="1"><border><left/><right/><top/><bottom/><diagonal/></border></borders>' +
    '<cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>' +
    '<cellXfs count="10">' +
    '<xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>' +
    '<xf numFmtId="0" fontId="1" fillId="0" borderId="0" xfId="0" applyFont="1"/>' +
    '<xf numFmtId="0" fontId="2" fillId="0" borderId="0" xfId="0" applyFont="1"/>' +
    '<xf numFmtId="0" fontId="3" fillId="2" borderId="0" xfId="0" applyFont="1" applyFill="1"/>' +
    '<xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>' +
    '<xf numFmtId="1" fontId="0" fillId="0" borderId="0" xfId="0" applyNumberFormat="1"/>' +
    '<xf numFmtId="4" fontId="0" fillId="0" borderId="0" xfId="0" applyNumberFormat="1"/>' +
    '<xf numFmtId="164" fontId="0" fillId="0" borderId="0" xfId="0" applyNumberFormat="1"/>' +
    '<xf numFmtId="0" fontId="4" fillId="3" borderId="0" xfId="0" applyFont="1" applyFill="1"/>' +
    '<xf numFmtId="4" fontId="4" fillId="3" borderId="0" xfId="0" applyNumberFormat="1" applyFont="1" applyFill="1"/>' +
    '</cellXfs>' +
    '<cellStyles count="1"><cellStyle name="Normal" xfId="0" builtinId="0"/></cellStyles>' +
    '</styleSheet>';
end;

function TBVReport.GenerateXlsx: JSValue;
const
  XML_DECL = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' + #10;
var
  Recs: TJSArray;
  SheetName, SheetXml, StylesXml, ContentTypes, RootRels, WorkbookXml, WorkbookRels, CoreXml, AppXml: string;
  Entries: JSValue;
begin
  Recs := GetRecordsArray;
  EnsureAutoColumns(Recs);

  SheetName := FTitle;
  asm
    SheetName = String(SheetName).replace(new RegExp('[\\[\\]:*?/\\\\]', 'g'), ' ').trim().substring(0, 31);
    SheetName = SheetName.replace(new RegExp('^\\u0027+|\\u0027+$', 'g'), '').trim();
    if (SheetName === '') SheetName = 'Report';
  end;

  SheetXml := BuildXlsxSheetXml(Recs);
  StylesXml := BuildXlsxStylesXml;
  ContentTypes := XML_DECL +
    '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">' +
    '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>' +
    '<Default Extension="xml" ContentType="application/xml"/>' +
    '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>' +
    '<Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>' +
    '<Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>' +
    '<Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>' +
    '<Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>' +
    '</Types>';
  RootRels := XML_DECL +
    '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">' +
    '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>' +
    '<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>' +
    '<Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>' +
    '</Relationships>';
  WorkbookXml := XML_DECL +
    '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">' +
    '<sheets><sheet name="' + XlsxEscape(SheetName) + '" sheetId="1" r:id="rId1"/></sheets></workbook>';
  WorkbookRels := XML_DECL +
    '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">' +
    '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>' +
    '<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>' +
    '</Relationships>';
  CoreXml := XML_DECL +
    '<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/">' +
    '<dc:title>' + XlsxEscape(FTitle) + '</dc:title><dc:creator>' + XlsxEscape(FAuthor) + '</dc:creator></cp:coreProperties>';
  AppXml := XML_DECL +
    '<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties">' +
    '<Application>BlaiseVue</Application><Company>' + XlsxEscape(FCompanyName) + '</Company></Properties>';

  Entries := nil;
  asm
    Entries = [
      { name: '[Content_Types].xml', text: ContentTypes },
      { name: '_rels/.rels', text: RootRels },
      { name: 'docProps/core.xml', text: CoreXml },
      { name: 'docProps/app.xml', text: AppXml },
      { name: 'xl/workbook.xml', text: WorkbookXml },
      { name: 'xl/_rels/workbook.xml.rels', text: WorkbookRels },
      { name: 'xl/styles.xml', text: StylesXml },
      { name: 'xl/worksheets/sheet1.xml', text: SheetXml }
    ];
  end;
  Result := XlsxBuildZip(Entries);
end;

function TBVReport.ExportExcel(const AFileName: string = 'report.xlsx'): string;
const
  XLSX_MIME = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
var
  FinalName: string;
  Package: JSValue;
begin
  FinalName := Trim(AFileName);
  if FinalName = '' then
    FinalName := 'report.xlsx';
  { The returned string stays the readable SpreadsheetML preview; the file saved
    by the browser is the binary .xlsx package. }
  Result := GenerateExcel;
  FLastExportedContent := Result;
  FLastExportedFileName := FinalName;
  FLastExportedMimeType := XLSX_MIME;
  Package := GenerateXlsx;
  if Assigned(Package) then
    DownloadBlobPart(Package, FinalName, XLSX_MIME);
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
