unit uBVSynMultiSyn;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics,
  SynEditHighlighter,
  SynHighlighterMulti,
  SynHighlighterHTML,
  SynHighlighterPas,
  SynHighlighterCSS,
  SrcEditorIntf;

type
  { TBVSynMultiSyn }
  TBVSynMultiSyn = class(TSynMultiSyn)
  private
    FHtmlSyn: TSynHTMLSyn;
    FPasSyn: TSynPasSyn;
    FCssSyn: TSynCssSyn;
    procedure InitSubHighlighters;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    class function GetLanguageName: string; override;
    procedure RefreshHighlighterSettings;
  end;

function GetBVSharedHighlighter: TBVSynMultiSyn;
procedure FreeBVSharedHighlighter;

implementation

var
  gBVSharedHighlighter: TBVSynMultiSyn = nil;

function GetBVSharedHighlighter: TBVSynMultiSyn;
begin
  if gBVSharedHighlighter = nil then
    gBVSharedHighlighter := TBVSynMultiSyn.Create(nil);
  Result := gBVSharedHighlighter;
end;

procedure FreeBVSharedHighlighter;
begin
  if Assigned(gBVSharedHighlighter) then
    FreeAndNil(gBVSharedHighlighter);
end;

{ TBVSynMultiSyn }

constructor TBVSynMultiSyn.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  DefaultLanguageName := 'BlaiseVue Component';
  InitSubHighlighters;
end;

destructor TBVSynMultiSyn.Destroy;
begin
  inherited Destroy;
end;

class function TBVSynMultiSyn.GetLanguageName: string;
begin
  Result := 'BlaiseVue Component (*.bv)';
end;

procedure TBVSynMultiSyn.RefreshHighlighterSettings;
begin
  if SourceEditorManagerIntf <> nil then
  begin
    SourceEditorManagerIntf.GetHighlighterSettings(FHtmlSyn);
    SourceEditorManagerIntf.GetHighlighterSettings(FPasSyn);
    SourceEditorManagerIntf.GetHighlighterSettings(FCssSyn);
  end;
end;

procedure TBVSynMultiSyn.InitSubHighlighters;
var
  SchemePas, SchemeCss: TSynHighlighterMultiScheme;
begin
  // 1. Default root highlighter: HTML for <template> and outer tags
  FHtmlSyn := TSynHTMLSyn.Create(Self);
  DefaultHighlighter := FHtmlSyn;

  // 2. Pascal script highlighter: active inside <script>...</script>
  FPasSyn := TSynPasSyn.Create(Self);

  // Set vibrant Pascal syntax colors as base fallback
  FPasSyn.KeyAttri.Foreground := clNavy;
  FPasSyn.KeyAttri.Style := [fsBold];
  FPasSyn.StringAttri.Foreground := clBlue;
  FPasSyn.NumberAttri.Foreground := clBlue;
  FPasSyn.CommentAttri.Foreground := clGray;
  FPasSyn.CommentAttri.Style := [fsItalic];
  FPasSyn.DirectiveAttri.Foreground := clTeal;
  FPasSyn.DirectiveAttri.Style := [fsBold];
  FPasSyn.SymbolAttri.Foreground := clMaroon;

  SchemePas := TSynHighlighterMultiScheme(Schemes.Add);
  SchemePas.SchemeName := 'BlaiseVuePascal';
  SchemePas.Highlighter := FPasSyn;
  SchemePas.StartExpr := '<script[^>]*>';
  SchemePas.EndExpr := '</script>';
  SchemePas.CaseSensitive := False;

  // REMOVE YELLOW BACKGROUND FROM <script> TAG
  SchemePas.MarkerAttri.Background := clNone;
  SchemePas.MarkerAttri.Foreground := clNavy;
  SchemePas.MarkerAttri.Style := [fsBold];

  // 3. CSS style highlighter: active inside <style>...</style>
  FCssSyn := TSynCssSyn.Create(Self);

  // Set vibrant CSS syntax colors as base fallback
  FCssSyn.SelectorAttri.Foreground := clNavy;
  FCssSyn.SelectorAttri.Style := [fsBold];
  FCssSyn.KeyAttri.Foreground := clNavy;       // Property names (padding, background, border)
  FCssSyn.KeyAttri.Style := [fsBold];
  FCssSyn.NumberAttri.Foreground := clBlue;    // Dimensions (24, 100, 14)
  FCssSyn.MeasurementUnitAttri.Foreground := clTeal; // Units (px, vh, rem, %)
  FCssSyn.StringAttri.Foreground := clBlue;
  FCssSyn.CommentAttri.Foreground := clGray;
  FCssSyn.CommentAttri.Style := [fsItalic];
  FCssSyn.SymbolAttri.Foreground := clMaroon;

  SchemeCss := TSynHighlighterMultiScheme(Schemes.Add);
  SchemeCss.SchemeName := 'BlaiseVueCSS';
  SchemeCss.Highlighter := FCssSyn;
  SchemeCss.StartExpr := '<style[^>]*>';
  SchemeCss.EndExpr := '</style>';
  SchemeCss.CaseSensitive := False;

  // REMOVE YELLOW BACKGROUND FROM <style> TAG
  SchemeCss.MarkerAttri.Background := clNone;
  SchemeCss.MarkerAttri.Foreground := clNavy;
  SchemeCss.MarkerAttri.Style := [fsBold];

  // 4. Try loading active Lazarus IDE theme colors if editor manager is alive
  RefreshHighlighterSettings;
end;

initialization

finalization
  FreeBVSharedHighlighter;

end.
