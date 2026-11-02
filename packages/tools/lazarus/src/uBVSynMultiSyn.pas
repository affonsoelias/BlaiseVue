unit uBVSynMultiSyn;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics,
  SynEditHighlighter,
  SynHighlighterMulti,
  SynHighlighterHTML,
  SynHighlighterPas,
  SynHighlighterCSS;

type
  { Friend class to access protected GetDefaultAttribute on sub-highlighters without unsafe casts }
  TSynCustomHighlighterFriend = class(TSynCustomHighlighter);

  { TBVSynMultiSyn }
  TBVSynMultiSyn = class(TSynMultiSyn)
  private
    FHtmlSyn: TSynHTMLSyn;
    FPasSyn: TSynPasSyn;
    FCssSyn: TSynCssSyn;
    procedure InitSubHighlighters;
  protected
    function GetDefaultAttribute(Index: integer): TSynHighlighterAttributes; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    class function GetLanguageName: string; override;
  end;

implementation

{ TBVSynMultiSyn }

function TBVSynMultiSyn.GetDefaultAttribute(Index: integer): TSynHighlighterAttributes;
var
  iHL: TSynCustomHighlighter;
begin
  // TSynMultiSyn has a bug where it performs an invalid cast TSynMultiSyn(iHL)
  // on sub-highlighters, raising EInvalidCast under FPC runtime checks (-CR).
  // Overriding it here intercepts IdentifierAttribute calls safely inside BlaiseVue.
  if FHtmlSyn <> nil then
    iHL := FHtmlSyn
  else
    iHL := DefaultHighlighter;

  if iHL <> nil then
    Result := TSynCustomHighlighterFriend(iHL).GetDefaultAttribute(Index)
  else
    Result := nil;
end;

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

procedure TBVSynMultiSyn.InitSubHighlighters;
var
  SchemePas, SchemeCss: TSynHighlighterMultiScheme;
begin
  // 1. Default root highlighter: HTML for <template> and outer tags
  FHtmlSyn := TSynHTMLSyn.Create(Self);
  DefaultHighlighter := FHtmlSyn;

  // 2. Pascal script highlighter: active inside <script>...</script>
  FPasSyn := TSynPasSyn.Create(Self);

  // Set vibrant Pascal syntax colors
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

  // Set vibrant CSS syntax colors
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
end;

end.
