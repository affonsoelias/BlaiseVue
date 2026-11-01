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

procedure TBVSynMultiSyn.InitSubHighlighters;
var
  SchemePas, SchemeCss: TSynHighlighterMultiScheme;
begin
  // 1. Default root highlighter: HTML for <template> and root document
  FHtmlSyn := TSynHTMLSyn.Create(Self);
  DefaultHighlighter := FHtmlSyn;

  // 2. Pascal script highlighter: active inside <script>...</script>
  FPasSyn := TSynPasSyn.Create(Self);
  SchemePas := TSynHighlighterMultiScheme(Schemes.Add);
  SchemePas.SchemeName := 'BlaiseVuePascal';
  SchemePas.Highlighter := FPasSyn;
  SchemePas.StartExpr := '<script[^>]*>';
  SchemePas.EndExpr := '</script>';
  SchemePas.CaseSensitive := False;

  // 3. CSS style highlighter: active inside <style>...</style>
  FCssSyn := TSynCssSyn.Create(Self);
  SchemeCss := TSynHighlighterMultiScheme(Schemes.Add);
  SchemeCss.SchemeName := 'BlaiseVueCSS';
  SchemeCss.Highlighter := FCssSyn;
  SchemeCss.StartExpr := '<style[^>]*>';
  SchemeCss.EndExpr := '</style>';
  SchemeCss.CaseSensitive := False;
end;

initialization

finalization
  FreeBVSharedHighlighter;

end.
