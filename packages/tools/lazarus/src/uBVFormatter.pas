unit uBVFormatter;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

function FormatBVContent(const AContent: string): string;

implementation

function CountUnclosedTags(const S: string): Integer;
var
  P, TagStart, TagEnd: Integer;
  Tag: string;
  Balance: Integer;
  InQuotes: Boolean;
  QuoteChar: Char;
begin
  Balance := 0;
  P := 1;
  while P <= Length(S) do
  begin
    if (S[P] = '<') and (P < Length(S)) then
    begin
      if Copy(S, P, 4) = '<!--' then
      begin
        P := Pos('-->', S);
        if P = 0 then P := Length(S) + 1 else Inc(P, 3);
        Continue;
      end;

      TagStart := P;
      InQuotes := False;
      QuoteChar := #0;
      Inc(P);
      while (P <= Length(S)) do
      begin
        if S[P] in ['"', ''''] then
        begin
          if not InQuotes then begin InQuotes := True; QuoteChar := S[P]; end
          else if S[P] = QuoteChar then InQuotes := False;
        end
        else if (S[P] = '>') and not InQuotes then Break;
        Inc(P);
      end;
      TagEnd := P;
      Tag := Copy(S, TagStart, TagEnd - TagStart + 1);

      if (Length(Tag) >= 2) then
      begin
        if Copy(Tag, 1, 2) = '</' then
          Dec(Balance)
        else if (Copy(Tag, Length(Tag) - 1, 2) = '/>') or
                (Copy(LowerCase(Tag), 1, 3) = '<br') or
                (Copy(LowerCase(Tag), 1, 3) = '<hr') or
                (Copy(LowerCase(Tag), 1, 4) = '<img') or
                (Copy(LowerCase(Tag), 1, 6) = '<input') or
                ((Copy(LowerCase(Tag), 1, 5) = '<slot') and (Pos('</slot>', LowerCase(S)) = 0)) then
          // self closing or void
        else
          Inc(Balance);
      end;
    end;
    Inc(P);
  end;
  Result := Balance;
end;

function FormatBVContent(const AContent: string): string;
var
  InLines, OutLines: TStringList;
  i: Integer;
  Line, Trimmed, LowTrim: string;
  Section: Integer; // 0=none, 1=template, 2=script, 3=style
  TmplIndent: Integer;
  InMethodBody: Boolean;
  StyleIndent: Integer;
  LastEmpty: Boolean;
begin
  InLines := TStringList.Create;
  OutLines := TStringList.Create;
  try
    InLines.Text := AContent;
    Section := 0;
    TmplIndent := 1;
    InMethodBody := False;
    StyleIndent := 1;
    LastEmpty := False;

    for i := 0 to InLines.Count - 1 do
    begin
      Line := InLines[i];
      Trimmed := Trim(Line);
      LowTrim := LowerCase(Trimmed);

      if Trimmed = '' then
      begin
        if not LastEmpty and (OutLines.Count > 0) then
        begin
          OutLines.Add('');
          LastEmpty := True;
        end;
        Continue;
      end;
      LastEmpty := False;

      if Pos('<template', LowTrim) = 1 then
      begin
        Section := 1;
        TmplIndent := 1;
        OutLines.Add(Trimmed);
      end
      else if Pos('</template>', LowTrim) = 1 then
      begin
        Section := 0;
        OutLines.Add('</template>');
        OutLines.Add('');
        LastEmpty := True;
      end
      else if Pos('<script', LowTrim) = 1 then
      begin
        Section := 2;
        InMethodBody := False;
        OutLines.Add(Trimmed);
      end
      else if Pos('</script>', LowTrim) = 1 then
      begin
        Section := 0;
        OutLines.Add('</script>');
        OutLines.Add('');
        LastEmpty := True;
      end
      else if Pos('<style', LowTrim) = 1 then
      begin
        Section := 3;
        StyleIndent := 1;
        OutLines.Add(Trimmed);
      end
      else if Pos('</style>', LowTrim) = 1 then
      begin
        Section := 0;
        OutLines.Add('</style>');
      end
      else
      begin
        case Section of
          1: // Template
          begin
            if Copy(Trimmed, 1, 2) = '</' then
            begin
              if TmplIndent > 1 then Dec(TmplIndent);
              OutLines.Add(StringOfChar(' ', TmplIndent * 2) + Trimmed);
            end
            else
            begin
              OutLines.Add(StringOfChar(' ', TmplIndent * 2) + Trimmed);
              Inc(TmplIndent, CountUnclosedTags(Trimmed));
              if TmplIndent < 1 then TmplIndent := 1;
            end;
          end;

          2: // Script
          begin
            if (LowTrim = 'props:') or (LowTrim = 'data:') or (LowTrim = 'computed:') or
               (LowTrim = 'watch:') or (LowTrim = 'methods:') or (LowTrim = 'created:') or
               (LowTrim = 'mounted:') or (LowTrim = 'updated:') or (LowTrim = 'unmounted:') or
               (LowTrim = 'provide:') or (LowTrim = 'inject:') or (LowTrim = 'routes:') then
            begin
              InMethodBody := False;
              OutLines.Add('  ' + Trimmed);
            end
            else if (Pos('procedure ', LowTrim) = 1) or (Pos('function ', LowTrim) = 1) then
            begin
              InMethodBody := False;
              OutLines.Add('    ' + Trimmed);
            end
            else if (LowTrim = 'var') or (LowTrim = 'const') then
            begin
              InMethodBody := False;
              OutLines.Add('    ' + Trimmed);
            end
            else if (LowTrim = 'begin') then
            begin
              OutLines.Add('    begin');
              InMethodBody := True;
            end
            else if (LowTrim = 'end;') or (LowTrim = 'end') then
            begin
              InMethodBody := False;
              OutLines.Add('    ' + Trimmed);
            end
            else if InMethodBody then
            begin
              OutLines.Add('      ' + Trimmed);
            end
            else
            begin
              OutLines.Add('    ' + Trimmed);
            end;
          end;

          3: // Style
          begin
            if (Pos('{', Trimmed) > 0) and (Pos('}', Trimmed) > 0) then
            begin
              OutLines.Add('  ' + Trimmed);
            end
            else if Pos('{', Trimmed) > 0 then
            begin
              OutLines.Add('  ' + Trimmed);
              StyleIndent := 2;
            end
            else if Pos('}', Trimmed) = 1 then
            begin
              OutLines.Add('  }');
              StyleIndent := 1;
            end
            else
            begin
              OutLines.Add(StringOfChar(' ', StyleIndent * 2) + Trimmed);
            end;
          end;

          else
            OutLines.Add(Trimmed);
        end;
      end;
    end;

    Result := OutLines.Text;
  finally
    InLines.Free;
    OutLines.Free;
  end;
end;

end.
