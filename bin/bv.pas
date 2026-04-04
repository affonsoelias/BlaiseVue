program bv;
{
  BlaiseVue CLI & SFC (Single File Component) Preprocessor
  --------------------------------------------------------
  Build with: fpc bv.pas
  
  Usage:
    bv create <project-name>    - Scaffolds a new project structure
    bv build                     - Full compilation cycle: .bv -> .pas -> .js
    bv run dev                  - Real-time build with debug features
    bv new c <ComponentName>    - Scaffolds a new .bv component
    bv clean                     - Purges the dist/ and generated/ folders
}

{$mode objfpc}{$H+}

uses
  SysUtils, Classes, StrUtils, DateUtils, Process, Sockets,
  fphttpclient, openssl, zipper, fpjson, jsonparser;

// =====================================================================
//  UTILITY FUNCTIONS
// =====================================================================

{ Returns the absolute path to the BlaiseVue SDK root }
function GetSDKPath: string;
var
  BinDir: string;
begin
  BinDir := ExtractFilePath(ParamStr(0));
  Result := ExtractFilePath(ExcludeTrailingPathDelimiter(BinDir));
end;

{ Returns the path to the framework core unit folder }
function GetCorePath: string;
begin
  Result := GetSDKPath + 'core' + DirectorySeparator;
end;

{ Returns the absolute path to the pas2js compiler executable based on OS }
function GetPas2JSPath: string;
var
  OSFolder: string;
begin
  {$IFDEF WINDOWS}
    OSFolder := 'pas2js-win64-x86_64-3.2.0';
    Result := GetSDKPath + 'pas2js' + DirectorySeparator + OSFolder + DirectorySeparator + 'bin' + DirectorySeparator + 'pas2js.exe';
  {$ELSE}
    {$IFDEF LINUX}
      OSFolder := 'pas2js-linux-x86_64-3.2.0'; // Default to x64
    {$ELSE}
      OSFolder := 'pas2js-darwin-x86_64-3.2.0'; // Default to x64
    {$ENDIF}
    Result := GetSDKPath + 'pas2js' + DirectorySeparator + OSFolder + DirectorySeparator + 'bin' + DirectorySeparator + 'pas2js';
  {$ENDIF}
end;

{ Returns the library path for the pas2js system units }
function GetPas2JSLibPath: string;
var
  OSFolder: string;
begin
  {$IFDEF WINDOWS}
    OSFolder := 'pas2js-win64-x86_64-3.2.0';
  {$ELSE}
    {$IFDEF LINUX}
      OSFolder := 'pas2js-linux-x86_64-3.2.0';
    {$ELSE}
      OSFolder := 'pas2js-darwin-x86_64-3.2.0';
    {$ENDIF}
  {$ENDIF}
  Result := GetSDKPath + 'pas2js' + DirectorySeparator + OSFolder + DirectorySeparator + 'packages' + DirectorySeparator + '*' + DirectorySeparator + 'src';
end;

function GetRTLPath: string;
var
  SDK, OSFolder: string;
begin
  SDK := GetSDKPath;
  {$IFDEF WINDOWS}
    OSFolder := 'pas2js-win64-x86_64-3.2.0';
  {$ELSE}
    {$IFDEF LINUX}
      OSFolder := 'pas2js-linux-x86_64-3.2.0';
    {$ELSE}
      OSFolder := 'pas2js-darwin-x86_64-3.2.0';
    {$ENDIF}
  {$ENDIF}
  
  // 1. Tries the framework root
  if FileExists(SDK + 'rtl.js') then Exit(SDK + 'rtl.js');
  // 2. Tries the default Pas2JS local package path
  if FileExists(SDK + 'pas2js' + DirectorySeparator + OSFolder + DirectorySeparator + 'packages' + DirectorySeparator + 'rtl' + DirectorySeparator + 'src' + DirectorySeparator + 'rtl.js') then
    Exit(SDK + 'pas2js' + DirectorySeparator + OSFolder + DirectorySeparator + 'packages' + DirectorySeparator + 'rtl' + DirectorySeparator + 'src' + DirectorySeparator + 'rtl.js');
  // 3. Tries the Pas2JS bin folder
  if FileExists(SDK + 'pas2js' + DirectorySeparator + OSFolder + DirectorySeparator + 'bin' + DirectorySeparator + 'rtl.js') then
    Exit(SDK + 'pas2js' + DirectorySeparator + OSFolder + DirectorySeparator + 'bin' + DirectorySeparator + 'rtl.js');
  Result := '';
end;

function PascalToKebab(const S: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(S) do
  begin
    if (i > 1) and (S[i] >= 'A') and (S[i] <= 'Z') then
      Result := Result + '-';
    Result := Result + LowerCase(S[i]);
  end;
end;

function EscapeQuotes(const S: string): string;
begin
  Result := StringReplace(S, '''', '''''', [rfReplaceAll]);
end;

function TrimLine(const S: string): string;
begin
  Result := Trim(S);
end;

procedure ForceDir(const D: string);
begin
  if not DirectoryExists(D) then
    ForceDirectories(D);
end;

procedure DeleteDir(Path: string);
var
  SR: TSearchRec;
begin
  if Path[Length(Path)] <> DirectorySeparator then Path := Path + DirectorySeparator;
  if FindFirst(Path + '*', faAnyFile, SR) = 0 then
  begin
    repeat
      if (SR.Name <> '.') and (SR.Name <> '..') then
      begin
        if (SR.Attr and faDirectory) <> 0 then
          DeleteDir(Path + SR.Name)
        else
          DeleteFile(Path + SR.Name);
      end;
    until FindNext(SR) <> 0;
    FindClose(SR);
  end;
  RemoveDir(Path);
end;

function ReadFileToString(const FileName: string): string;
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    SL.LoadFromFile(FileName);
    Result := SL.Text;
  finally
    SL.Free;
  end;
end;

procedure WriteStringToFile(const FileName, Content: string);
var
  SL: TStringList;
begin
  ForceDir(ExtractFilePath(FileName));
  SL := TStringList.Create;
  try
    SL.Text := Content;
    SL.SaveToFile(FileName);
  finally
    SL.Free;
  end;
end;

function GetFileHash(const FileName: string): string;
var
  S: string;
  Output: TStringList;
begin
  // On Windows, use certutil for a fast MD5 hash
  Output := TStringList.Create;
  try
    if RunCommand('certutil', ['-hashfile', FileName, 'MD5'], S) then
    begin
      Output.Text := S;
      if Output.Count > 1 then
      begin
        Result := Trim(Output[1]); // The second line contains the hash
        Result := StringReplace(Result, ' ', '', [rfReplaceAll]);
        Result := LowerCase(Result);
        Result := Copy(Result, 1, 8); // Uses only 8 chars
      end
      else
        Result := IntToStr(DateTimeToUnix(Now));
    end
    else
      Result := IntToStr(DateTimeToUnix(Now));
  finally
    Output.Free;
  end;
end;

// =====================================================================
//  .BV (Single File Component) PARSER
// =====================================================================

type
  TDataField = record
    Name: string;
    FieldType: string;
    DefaultValue: string;
    IsProp: Boolean;
  end;

  TRouteEntry = record
    Path: string;
    Component: string;
  end;

  TBVParsed = record
    Template: string;
    Style: string;
    ScriptUses: string;
    DataFields: array of TDataField;
    Routes: array of TRouteEntry;
    MethodsCode: string;
    BeforeEachCode: string;
    CreatedCode: string;
    MountedCode: string;
    UpdatedCode: string;
    WatchCode: string;
    ComputedCode: string;
    ProvideCode: string;
    InjectCode: string;
    HasRouter: Boolean;
  end;

procedure ParseScriptBlock(const Block: string; var Parsed: TBVParsed); forward;
procedure ScanDirForBV(const Path: string; List: TStringList); forward;
procedure ScanDirForCSS(const Path: string; List: TStringList); forward;
procedure ScanDirForJS(const Path: string; List: TStringList); forward;
procedure CmdLibList; forward;
procedure CmdLibInstall(const URL: string); forward;
procedure CmdLibRemove(const LibName: string); forward;

{ Main Parser: Orchestrates the separation of <template>, <script>, and <style> sections }
procedure ParseBVFile(const FileName: string; out Parsed: TBVParsed);
var
  Lines: TStringList;
  i: Integer;
  Line, Trimmed: string;
  Section: Integer; // 0=none, 1=template, 2=script, 3=style
  ScriptBlock: string;
  P: Integer;
begin
  Parsed.Template := '';
  Parsed.Style := '';
  Parsed.ScriptUses := '';
  Parsed.MethodsCode := '';
  Parsed.BeforeEachCode := '';
  Parsed.CreatedCode := '';
  Parsed.MountedCode := '';
  Parsed.WatchCode := '';
  Parsed.ComputedCode := '';
  Parsed.UpdatedCode := ''; // New
  Parsed.ProvideCode := ''; // New
  Parsed.InjectCode := '';  // New
  Parsed.HasRouter := False;
  SetLength(Parsed.DataFields, 0);
  SetLength(Parsed.Routes, 0);

  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(FileName);
    Section := 0;
    ScriptBlock := '';

    for i := 0 to Lines.Count - 1 do
    begin
      Line := Lines[i];
      Trimmed := Trim(Line);

      // Section opening detection
      if Pos('<template>', LowerCase(Trimmed)) = 1 then
      begin
        Section := 1;
        Continue;
      end;
      if Pos('<script', LowerCase(Trimmed)) = 1 then
      begin
        Section := 2;
        // Extract uses="..."
        P := Pos('uses="', LowerCase(Trimmed));
        if P > 0 then
        begin
          Parsed.ScriptUses := Copy(Trimmed, P + 6, Length(Trimmed));
          P := Pos('"', Parsed.ScriptUses);
          if P > 0 then
            Parsed.ScriptUses := Copy(Parsed.ScriptUses, 1, P - 1);
        end;
        Continue;
      end;
      if Pos('<style>', LowerCase(Trimmed)) = 1 then
      begin
        Section := 3;
        Continue;
      end;

      // Section closing detection
      if Pos('</template>', LowerCase(Trimmed)) = 1 then begin Section := 0; Continue; end;
      if Pos('</script>', LowerCase(Trimmed)) = 1 then begin Section := 0; Continue; end;
      if Pos('</style>', LowerCase(Trimmed)) = 1 then begin Section := 0; Continue; end;

      // Acumula conteudo por secao
      case Section of
        1: Parsed.Template := Parsed.Template + Line + #10;
        2: ScriptBlock := ScriptBlock + Line + #10;
        3: Parsed.Style := Parsed.Style + Line + #10;
      end;
    end;

    // Agora parseia o ScriptBlock em sub-secoes: data, router, methods
    ParseScriptBlock(ScriptBlock, Parsed);

  finally
    Lines.Free;
  end;
end;

procedure ParseScriptBlock(const Block: string; var Parsed: TBVParsed);
var
  Lines: TStringList;
  i: Integer;
  Trimmed: string;
  SubSection: Integer; // 0=none, 1=data, 2=router, 3=methods, 4=beforeEach, 5=created, 6=mounted, 7=watch
  InRoutes, InQuotes: Boolean;
  P, P2, j: Integer;
  DF: TDataField;
  RE: TRouteEntry;
  S: string;
begin
  Lines := TStringList.Create;
  try
    Lines.Text := Block;
    SubSection := 0;
    InRoutes := False;

    for i := 0 to Lines.Count - 1 do
    begin
      Trimmed := Trim(Lines[i]);

      if Trimmed = '' then Continue;

      // Detection of comments at top level within script
      if (Trimmed[1] = '{') or (Copy(Trimmed, 1, 2) = '//') then
      begin
         // If a comment is followed by a known block name, don't capture it yet
         // or just skip adding to current SubSection if it's likely a separator
         if SubSection <> 0 then
         begin
            // Check next lines to see if we are switching
            // For now, if we are in 3 (Methods) or similar, we might want to keep it.
            // But for 5 (Created), we usually don't want trailing comments from the next block.
         end;
      end;

      // Sub-section detection
      if Trimmed = 'data:' then begin SubSection := 1; Continue; end;
      if Trimmed = 'props:' then begin SubSection := 12; Continue; end;
      if Trimmed = 'router:' then begin SubSection := 2; Parsed.HasRouter := True; Continue; end;
      if Trimmed = 'methods:' then begin SubSection := 3; Continue; end;
      if Trimmed = 'provide:' then begin SubSection := 9; Continue; end;
      if Trimmed = 'inject:' then begin SubSection := 10; Continue; end;
      if Trimmed = 'created:' then begin SubSection := 5; Continue; end;
      if Trimmed = 'mounted:' then begin SubSection := 6; Continue; end;
      if Trimmed = 'updated:' then begin SubSection := 11; Continue; end;
      if Trimmed = 'watch:' then begin SubSection := 7; Continue; end;
      if Trimmed = 'computed:' then begin SubSection := 8; Continue; end;
      if Trimmed = 'routes:' then begin InRoutes := True; Continue; end;

      case SubSection of
        1, 12: // DATA or PROPS
        begin
          // Skips comments
          if (Trimmed = '') or (Trimmed[1] = '{') or (Copy(Trimmed, 1, 2) = '//') then Continue;

          P := Pos(':', Trimmed);
          if P > 0 then
          begin
            DF.Name := Trim(Copy(Trimmed, 1, P - 1));
            DF.IsProp := (SubSection = 12);
            // Depois do ":" tem "type = value;"
            Trimmed := Trim(Copy(Trimmed, P + 1, Length(Trimmed)));
            // Remove ; no final
            if (Length(Trimmed) > 0) and (Trimmed[Length(Trimmed)] = ';') then
              Trimmed := Copy(Trimmed, 1, Length(Trimmed) - 1);

            P2 := Pos('=', Trimmed);
            if P2 > 0 then
            begin
              DF.FieldType := Trim(Copy(Trimmed, 1, P2 - 1));
              DF.DefaultValue := Trim(Copy(Trimmed, P2 + 1, Length(Trimmed)));
            end
            else
            begin
              DF.FieldType := Trim(Trimmed);
              DF.DefaultValue := '';
            end;

            SetLength(Parsed.DataFields, Length(Parsed.DataFields) + 1);
            Parsed.DataFields[High(Parsed.DataFields)] := DF;
          end;
        end;

        2: // ROUTER: rotas e configuracao
        begin
          if InRoutes then
          begin
            // format: '/path' : 'component-name';
            P := 0;
            InQuotes := False;
            for j := 1 to Length(Trimmed) do
            begin
              if Trimmed[j] = '''' then InQuotes := not InQuotes
              else if (Trimmed[j] = ':') and not InQuotes then
              begin
                P := j;
                Break;
              end;
            end;
            if P > 0 then
            begin
              RE.Path := Trim(Copy(Trimmed, 1, P - 1));
              RE.Component := Trim(Copy(Trimmed, P + 1, Length(Trimmed)));
              // Remove aspas e ;
              RE.Path := StringReplace(RE.Path, '''', '', [rfReplaceAll]);
              RE.Component := StringReplace(RE.Component, '''', '', [rfReplaceAll]);
              RE.Component := StringReplace(RE.Component, ';', '', [rfReplaceAll]);
              RE.Path := Trim(RE.Path);
              RE.Component := Trim(RE.Component);

              SetLength(Parsed.Routes, Length(Parsed.Routes) + 1);
              Parsed.Routes[High(Parsed.Routes)] := RE;
            end;
          end;
        end;

        3: // METHODS: raw Pascal code
        begin
          Parsed.MethodsCode := Parsed.MethodsCode + Lines[i] + #10;
        end;

        4: // BEFOREEACH: codigo Pascal bruto
        begin
          Parsed.BeforeEachCode := Parsed.BeforeEachCode + Lines[i] + #10;
        end;
        5: // CREATED
        begin
          Parsed.CreatedCode := Parsed.CreatedCode + Lines[i] + #10;
        end;
        6: // MOUNTED
        begin
          Parsed.MountedCode := Parsed.MountedCode + Lines[i] + #10;
        end;
        7: // WATCH
        begin
          Parsed.WatchCode := Parsed.WatchCode + Lines[i] + #10;
        end;
        8: // COMPUTED
        begin
          Parsed.ComputedCode := Parsed.ComputedCode + Lines[i] + #10;
        end;
        9: // PROVIDE
        begin
          Parsed.ProvideCode := Parsed.ProvideCode + Lines[i] + #10;
        end;
        10: // INJECT
        begin
          Parsed.InjectCode := Parsed.InjectCode + Lines[i] + #10;
        end;
        11: // UPDATED
        begin
          Parsed.UpdatedCode := Parsed.UpdatedCode + Lines[i] + #10;
        end;
      end;
    end;
  finally
    Lines.Free;
  end;
end;

// =====================================================================
//  GERADOR DE CODIGO PASCAL
// =====================================================================

function CleanPascalProps(const S: string): string;
var
  i, j, k: Integer;
  Identifier: string;
  Res: string;
  InQuote, InAsm: Boolean;
begin
  Res := S;
  InQuote := False;
  InAsm := False;
  i := 1;
  while i <= Length(Res) - 4 do
  begin
    if Res[i] = '''' then InQuote := not InQuote;
    
    if not InQuote then
    begin
       if (i <= Length(Res)-2) and (LowerCase(Copy(Res, i, 3)) = 'asm') and ((i=1) or (not (Res[i-1] in ['a'..'z', '0'..'9']))) then InAsm := True;
       if (i <= Length(Res)-2) and (LowerCase(Copy(Res, i, 3)) = 'end') and (InAsm) then
       begin
          k := i+3;
          while (k <= Length(Res)) and (Res[k] <= ' ') do Inc(k);
          if (k <= Length(Res)) and (Res[k] = ';') then InAsm := False;
       end;
    end;

    if (not InQuote) and (not InAsm) and (i <= Length(Res) - 5) and (Copy(Res, i, 5) = 'this.') then
    begin
       j := i + 5;
       while (j <= Length(Res)) and (Res[j] in ['a'..'z', 'A'..'Z', '0'..'9', '_', '$']) do Inc(j);
       Identifier := Copy(Res, i + 5, j - (i + 5));
       Delete(Res, i, j - i);
       Insert('TJSObject(_this)[''' + Identifier + ''']', Res, i);
       i := i + Length(Identifier) + 18;
    end
    else if (not InQuote) and (not InAsm) and (Copy(Res, i, 4) = 'this') and not (Res[i+4] in ['a'..'z', 'A'..'Z', '0'..'9', '_', '.', '$']) then
    begin
       Delete(Res, i, 4);
       Insert('_this', Res, i);
       i := i + 5;
    end
    else
       Inc(i);
  end;
  Result := Res;
end;

function GenerateDataCode(const Fields: array of TDataField): string;
var
  i: Integer;
  Val: string;
begin
  if Length(Fields) = 0 then
  begin
    Result := '';
    Exit;
  end;

  Result :=
    '  comp[''data''] := function(): TJSObject' + #10 +
    '  var d: TJSObject;' + #10 +
    '  begin' + #10 +
    '    d := TJSObject.new;' + #10;

  for i := 0 to High(Fields) do
  begin
    if Fields[i].IsProp then Continue; // Props don't go into initial data return
    Val := Fields[i].DefaultValue;
    if Val = '' then
    begin
      if LowerCase(Fields[i].FieldType) = 'string' then
        Val := ''''''
      else if LowerCase(Fields[i].FieldType) = 'integer' then
        Val := '0'
      else if LowerCase(Fields[i].FieldType) = 'boolean' then
        Val := 'False'
      else
        Val := '''''';
    end;
    Result := Result + '    d[''' + Fields[i].Name + '''] := ' + Val + ';' + #10;
  end;

  Result := Result +
    '    Result := d;' + #10 +
    '  end;' + #10;
end;

function GeneratePropsCode(const Fields: array of TDataField): string;
var
  i: Integer;
  First: Boolean;
begin
  Result := '';
  First := True;
  for i := 0 to High(Fields) do
  begin
    if Fields[i].IsProp then
    begin
      if First then
      begin
        Result := '  comp[''props''] := TJSArray.new;' + #10;
        First := False;
      end;
      Result := Result + '  TJSArray(comp[''props'']).push(''' + Fields[i].Name + ''');' + #10;
    end;
  end;
end;

function GenerateMethodsCode(const RawCode: string): string;
var
  Parts, SubParts: TStringList;
  i, p: Integer;
  Sig, Body, Name, Params, Block: string;
begin
  Result := '';
  if Trim(RawCode) = '' then Exit;
  
  Parts := TStringList.Create;
  SubParts := TStringList.Create;
  try
    // Split by 'procedure '
    Block := RawCode;
    p := Pos('procedure ', LowerCase(Block));
    while p > 0 do
    begin
      Block := Copy(Block, p + 10, Length(Block)); // Depois de 'procedure '
      
      // Encontra o fim da assinatura (primeiro ;)
      p := Pos(';', Block);
      if p = 0 then Break;
      Sig := Trim(Copy(Block, 1, p - 1));
      
      // Finds the body end (delimited by the next procedure or the end of the block)
      Body := Copy(Block, p + 1, Length(Block));
      p := Pos('procedure ', LowerCase(Body));
      if p > 0 then Body := Copy(Body, 1, p - 1);
      
      // Extracts name and parameters from the signature
      p := Pos('(', Sig);
      if p > 0 then
      begin
        Name := Trim(Copy(Sig, 1, p - 1));
        Params := Copy(Sig, p, Length(Sig));
      end
      else
      begin
        Name := Trim(Sig);
        Params := '';
      end;
      
      // Strips Pascal keywords from the JS property name
      Name := StringReplace(Name, 'procedure ', '', [rfReplaceAll, rfIgnoreCase]);
      Name := StringReplace(Name, 'function ', '', [rfReplaceAll, rfIgnoreCase]);
      Name := Trim(Name);
      
      if Params = '' then Params := '(_this: TJSObject)'
      else Params := '(_this: TJSObject; ' + Copy(Params, 2, Length(Params));
      
      Result := Result + '  m[''' + Name + '''] := procedure' + Params + #10 +
                CleanPascalProps(Body) + #10;
      
      p := Pos('procedure ', LowerCase(Block));
    end;
  finally
    Parts.Free;
    SubParts.Free;
  end;
end;

function GenerateTemplateString(const Template: string): string;
var
  Lines: TStringList;
  i: Integer;
  L: string;
begin
  Lines := TStringList.Create;
  try
    Lines.Text := Template;
    Result := '';
    for i := 0 to Lines.Count - 1 do
    begin
      L := EscapeQuotes(Lines[i]);
      if i = 0 then
        Result := '    ''' + L + ''''
      else
        Result := Result + ' +' + #10 + '    ''' + L + '''';
    end;
    // Remove trailing empty line artifacts
    if Result = '' then
      Result := '    ''''';
  finally
    Lines.Free;
  end;
end;

function GenerateStyleInjection(const Style: string): string;
var
  CleanCSS: string;
begin
  if Trim(Style) = '' then
  begin
    Result := '';
    Exit;
  end;
  // Clean CSS: remove line breaks and escape quotes for JS
  CleanCSS := StringReplace(Trim(Style), #13, '', [rfReplaceAll]);
  CleanCSS := StringReplace(CleanCSS, #10, ' ', [rfReplaceAll]);
  // Pascal uses doubled single quotes for strings
  CleanCSS := StringReplace(CleanCSS, '''', '''''', [rfReplaceAll]);
  
  Result :=
    '  _styleEl := TJSHTMLElement(document.createElement(''style''));' + #10 +
    '  _styleEl.textContent := ''' + CleanCSS + ''';' + #10 +
    '  document.head.appendChild(_styleEl);' + #10;
end;

function GenerateLifecycleCode(const Key, RawCode: string): string;
begin
  if Trim(RawCode) = '' then
  begin
    Result := '';
    Exit;
  end;
  
  // If it already has begin/end or variables, just wrap it. 
  // We use CleanPascalProps to ensure it matches Pascal standards for the Unit generation.
  Result := '  comp[''' + Key + '''] := procedure(_this: TJSObject)' + #10;
  if (Pos('begin', LowerCase(RawCode)) > 0) or (Pos('var', LowerCase(RawCode)) > 0) then
    Result := Result + CleanPascalProps(RawCode) + #10 + '    ;' + #10
  else
    Result := Result + '    begin' + #10 + CleanPascalProps(RawCode) + #10 + '    end;' + #10;
end;

function GenerateWatchCode(const RawCode: string): string;
var
  Parts, SubParts: TStringList;
  i, p, p2: Integer;
  Sig, Body, Name, Params, Block: string;
begin
  Result := '';
  if Trim(RawCode) = '' then Exit;
  
  Result := '  comp[''watch''] := TJSObject.new;' + #10;
  
  Parts := TStringList.Create;
  try
    Block := RawCode;
    p := Pos('procedure ', LowerCase(Block));
    while p > 0 do
    begin
      Block := Copy(Block, p + 10, Length(Block));
      p := Pos(';', Block);
      if p = 0 then Break;
      Sig := Trim(Copy(Block, 1, p - 1));
      
      Body := Copy(Block, p + 1, Length(Block));
      p2 := Pos('procedure ', LowerCase(Body));
      if p2 > 0 then Body := Copy(Body, 1, p2 - 1);
      
      p2 := Pos('(', Sig);
      if p2 > 0 then
      begin
        Name := Trim(Copy(Sig, 1, p2 - 1));
        Params := Copy(Sig, p2, Length(Sig));
      end
      else
      begin
        Name := Sig;
        Params := '';
      end;
      
      if Params = '' then Params := '(_this: TJSObject)'
      else Params := '(_this: TJSObject; ' + Copy(Params, 2, Length(Params));
      
      Result := Result + '  TJSObject(comp[''watch''])[''' + Name + '''] := procedure' + Params + #10 +
                CleanPascalProps(Body) + #10 +
                ';' + #10;
      
      p := Pos('procedure ', LowerCase(Block));
    end;
  finally
    Parts.Free;
  end;
end;

function GenerateComputedCode(const RawCode: string): string;
var
  p: Integer;
  Name, Block, Body: string;
begin
  Result := '';
  if Trim(RawCode) = '' then Exit;
  
  Result := '  comp[''computed''] := TJSObject.new;' + #10;
  Block := RawCode;
  p := Pos('function ', LowerCase(Block));
  while p > 0 do
  begin
    Block := Copy(Block, p + 9, Length(Block));
    p := Pos(':', Block);
    if p = 0 then Break;
    Name := Trim(Copy(Block, 1, p - 1));
    
    p := Pos(';', Block);
    if p = 0 then Break;
    
    Body := Copy(Block, p + 1, Length(Block));
    p := Pos('function ', LowerCase(Body));
    if p > 0 then Body := Copy(Body, 1, p - 1);
    
    Result := Result + '  TJSObject(comp[''computed''])[''' + Name + '''] := function(_this: TJSObject): JSValue' + #10 +
              CleanPascalProps(Body) + #10 +
              ';' + #10;
    
    p := Pos('function ', LowerCase(Block));
  end;
end;

function GenerateProvideCode(const RawCode: string): string;
var
  CleanCode: string;
begin
  if Trim(RawCode) = '' then begin Result := ''; Exit; end;
  
  CleanCode := CleanPascalProps(RawCode);
  
  // If it already has structured begin/end (rare in .bv), just wrap it
  if (Pos('begin', LowerCase(CleanCode)) > 0) and (Pos('result', LowerCase(CleanCode)) > 0) then
  begin
    Result := '  comp[''provide''] := function(_this: TJSObject): TJSObject' + #10 +
              CleanCode + #10 + ';' + #10;
  end
  else
  begin
    // Common case: list of procedures or assignments
    Result := '  comp[''provide''] := function(_this: TJSObject): TJSObject' + #10 +
              '    ' + CleanCode + #10 +
              '    begin' + #10 +
              '       Result := TJSObject.new;' + #10 +
              '    end;' + #10 + ';' + #10;
  end;
end;

function GenerateInjectCode(const RawCode: string): string;
var
  SL: TStringList;
  i: Integer;
begin
  if Trim(RawCode) = '' then begin Result := ''; Exit; end;
  SL := TStringList.Create;
  try
    SL.CommaText := StringReplace(RawCode, ';', ',', [rfReplaceAll]);
    Result := '  comp[''inject''] := TJSArray.new;' + #10;
    for i := 0 to SL.Count - 1 do
      if Trim(SL[i]) <> '' then
        Result := Result + '  TJSArray(comp[''inject'']).push(''' + Trim(SL[i]) + ''');' + #10;
  finally
    SL.Free;
  end;
end;

// =====================================================================
//  PASCAL CODE GENERATORS
// =====================================================================

{ Generates a Pascal unit from a standard .bv component }
function GenerateComponentUnit(const UnitName, TagName, BVFileName: string; const Parsed: TBVParsed): string;
var
  UsesLine: string;
begin
  UsesLine := 'JS, Web, BVComponents, BVReactivity, BVStore, SysUtils';
  if Parsed.ScriptUses <> '' then
    UsesLine := UsesLine + ', ' + Parsed.ScriptUses;

  Result :=
    'unit ' + UnitName + ';' + #10 +
    #10 +
    '{$mode objfpc}' + #10 +
    #10 +
    'interface' + #10 +
    #10 +
    'uses ' + UsesLine + ';' + #10 +
    #10 +
    'procedure Register_' + UnitName + ';' + #10 +
    #10 +
    'implementation' + #10 +
    #10 +
    'procedure Register_' + UnitName + ';' + #10 +
    'var' + #10 +
    '  comp: TJSObject;' + #10 +
    '  m: TJSObject;' + #10 +
    '  _styleEl: TJSHTMLElement;' + #10 +
    'begin' + #10 +
    GenerateStyleInjection(Parsed.Style) +
    '  comp := TJSObject.new;' + #10 +
    '  comp[''template''] :=' + #10 +
    GenerateTemplateString(Parsed.Template) + ';' + #10 +
    #10 +
    GenerateDataCode(Parsed.DataFields) + #10 +
    GeneratePropsCode(Parsed.DataFields) + #10 +
    '  m := TJSObject.new;' + #10 +
    GenerateMethodsCode(Parsed.MethodsCode) +
    '  comp[''methods''] := m;' + #10 +
    #10 +
    GenerateLifecycleCode('created', Parsed.CreatedCode) +
    GenerateLifecycleCode('mounted', Parsed.MountedCode) +
    GenerateLifecycleCode('updated', Parsed.UpdatedCode) +
    GenerateWatchCode(Parsed.WatchCode) +
    GenerateComputedCode(Parsed.ComputedCode) +
    GenerateProvideCode(Parsed.ProvideCode) +
    GenerateInjectCode(Parsed.InjectCode) +
    #10 +
    '  RegisterComponent(''' + TagName + ''', comp);' + #10 +
    'end;' + #10 +
    #10 +
    'end.' + #10;
end;

{ Generates the root application unit (app.bv) which handles global state and routing }
function GenerateAppUnit(const Parsed: TBVParsed; const AllUnits: TStringList): string;
var
  UsesLine, RouteCode, DataCode: string;
  i: Integer;
begin
  UsesLine := 'JS, Web, BlaiseVue, BVComponents, BVStore, BVCompiler, BVDevTools';
  if Parsed.HasRouter then
    UsesLine := UsesLine + ', BVRouting';
  if Parsed.ScriptUses <> '' then
    UsesLine := UsesLine + ', ' + Parsed.ScriptUses;
  // Automatically import all compiled component units for auto-registration
  for i := 0 to AllUnits.Count - 1 do
  begin
    if AllUnits[i] <> 'uApp' then
      UsesLine := UsesLine + ', ' + AllUnits[i];
  end;

  // Data fields
  DataCode := '';
  if Length(Parsed.DataFields) > 0 then
  begin
    DataCode := '  data := TJSObject.new;' + #10;
    for i := 0 to High(Parsed.DataFields) do
      DataCode := DataCode + '  data[''' + Parsed.DataFields[i].Name + '''] := ' +
        Parsed.DataFields[i].DefaultValue + ';' + #10;
  end
  else
    DataCode := '  data := TJSObject.new;' + #10;

  // Router setup
  RouteCode := '';
  if Parsed.HasRouter and (Length(Parsed.Routes) > 0) then
  begin
    RouteCode :=
      '  routerOpts := TJSObject.new;' + #10 +
      '  routesArr := TJSArray.new;' + #10 + #10;

    for i := 0 to High(Parsed.Routes) do
      RouteCode := RouteCode +
        '  r := TJSObject.new;' + #10 +
        '  r[''path''] := ''' + Parsed.Routes[i].Path + ''';' + #10 +
        '  r[''component''] := ''' + Parsed.Routes[i].Component + ''';' + #10 +
        '  routesArr.push(r);' + #10 + #10;

    RouteCode := RouteCode +
      '  routerOpts[''routes''] := routesArr;' + #10 +
      '  router := TBVRouter.Create(routerOpts);' + #10;
  end;

  Result :=
    'unit uApp;' + #10 +
    #10 +
    '{$mode objfpc}' + #10 +
    #10 +
    'interface' + #10 +
    #10 +
    'uses ' + UsesLine + ';' + #10 +
    #10 +
    'procedure Init_App;' + #10 +
    #10 +
    'implementation' + #10 +
    #10 +
    'procedure Init_App;' + #10 +
    'var' + #10 +
    '  data, methods, opts: TJSObject;' + #10 +
    '  app: TBlaiseVue;' + #10 +
    '  comp: TJSObject;' + #10 +
    '  m: TJSObject;' + #10 +
    '  _styleEl: TJSHTMLElement;' + #10;

  if Parsed.HasRouter then
    Result := Result +
      '  routerOpts: TJSObject;' + #10 +
      '  routesArr: TJSArray;' + #10 +
      '  r: TJSObject;' + #10 +
      '  router: TBVRouter;' + #10;

  Result := Result +
    'begin' + #10 +
    '  asm console.log("[Init] Initing App..."); end;' + #10 +
    '  asm' + #10 +
    '    window.onerror = function(msg, url, line, col, error) {' + #10 +
    '      document.body.innerHTML = ''<div style="background:red; color:white; padding:20px; font-family:monospace; position:fixed; top:0; left:0; width:100%; height:100%; z-index:10000;">''' + #10 +
    '        + ''<h1>[BlaiseVue] ERROR</h1>''' + #10 +
    '        + ''<p><b>Msg:</b> '' + msg + ''</p>''' + #10 +
    '        + ''<p><b>Line:</b> '' + line + '' <b>Col:</b> '' + col + ''</p>''' + #10 +
    '        + ''<p><b>Stack:</b><br><pre>'' + (error ? error.stack : ''N/A'') + ''</pre></p></div>'';' + #10 +
    '    };' + #10 +
    '  end;' + #10 +
    '  asm console.log("[Init] Injecting Styles..."); end;' + #10 +
    GenerateStyleInjection(Parsed.Style);

  // Registra componentes
  for i := 0 to AllUnits.Count - 1 do
  begin
    if AllUnits[i] <> 'uApp' then
      Result := Result + '  asm console.log("[Init] Registering ' + AllUnits[i] + '..."); end;' + #10 +
               '  ' + 'Register_' + AllUnits[i] + ';' + #10;
  end;

  Result := Result + #10;

  // Template do root (registra como componente invisivel e seta innerHTML)
  Result := Result + #10;

  // Root template (registers as invisible component and sets innerHTML)
  Result := Result +
    '  asm console.log("[Init] Setting #app template..."); end;' + #10 +
    '  TJSHTMLElement(document.querySelector(''#app'')).innerHTML :=' + #10 +
    GenerateTemplateString(Parsed.Template) + ';' + #10 + #10;

  // Data
  Result := Result + DataCode + #10;

  // Methods
  Result := Result + '  methods := TJSObject.new;' + #10 +
    GenerateMethodsCode(Parsed.MethodsCode) + #10;

  // Options (Lifecycle, Watch & Computed)
  Result := Result + '  opts := TJSObject.new;' + #10 +
            '  comp := opts;' + #10 +
    GenerateLifecycleCode('created', Parsed.CreatedCode) +
    GenerateLifecycleCode('mounted', Parsed.MountedCode) +
    GenerateLifecycleCode('updated', Parsed.UpdatedCode);
  Result := Result + 
    GenerateWatchCode(Parsed.WatchCode) +
    GenerateComputedCode(Parsed.ComputedCode) +
    GenerateProvideCode(Parsed.ProvideCode) +
    GenerateInjectCode(Parsed.InjectCode);

  // Router
  if RouteCode <> '' then
    Result := Result + RouteCode + #10;

  // Cria a instancia
  Result := Result +
    '  app := TBlaiseVue.Create(''#app'', data, methods, opts);' + #10;

  if Parsed.HasRouter then
    Result := Result +
      '  app.UseRouter(router);' + #10
  else
    // Sem router: compilar o template diretamente
    Result := Result +
      '  Compile(TJSHTMLElement(document.querySelector(''#app'')), app.Data, methods);' + #10;

  Result := Result +
    'end;' + #10 +
    #10 +
    'end.' + #10;
end;

{ Generates the main entry point program (main.pas) }
function GenerateMainProgram: string;
begin
  Result :=
    'program main;' + #10 +
    #10 +
    '{$mode objfpc}' + #10 +
    #10 +
    'uses uApp;' + #10 +
    #10 +
    'begin' + #10 +
    '  Init_App;' + #10 +
    'end.' + #10;
end;

// =====================================================================
//  COMMAND: CREATE PROJECT
// =====================================================================

procedure CopyFile(const Src, Dest: string);
var
  SrcStream, DestStream: TFileStream;
begin
  SrcStream := TFileStream.Create(Src, fmOpenRead or fmShareDenyWrite);
  try
    DestStream := TFileStream.Create(Dest, fmCreate);
    try
      DestStream.CopyFrom(SrcStream, SrcStream.Size);
    finally
      DestStream.Free;
    end;
  finally
    SrcStream.Free;
  end;
end;

procedure CopyDir(const Source, Dest: string; const ExcludeList: array of string);
var
  SR: TSearchRec;
  i: Integer;
  IsExcluded: Boolean;
  SrcPath, DestPath: string;
begin
  SrcPath := IncludeTrailingPathDelimiter(Source);
  DestPath := IncludeTrailingPathDelimiter(Dest);
  ForceDir(DestPath);
  
  if FindFirst(SrcPath + '*', faAnyFile, SR) = 0 then
  begin
    repeat
      if (SR.Name <> '.') and (SR.Name <> '..') then
      begin
        IsExcluded := False;
        for i := 0 to High(ExcludeList) do
          if LowerCase(SR.Name) = LowerCase(ExcludeList[i]) then
          begin
            IsExcluded := True;
            Break;
          end;

        if not IsExcluded then
        begin
          if (SR.Attr and faDirectory) <> 0 then
            CopyDir(SrcPath + SR.Name, DestPath + SR.Name, ExcludeList)
          else
            CopyFile(SrcPath + SR.Name, DestPath + SR.Name);
        end;
      end;
    until FindNext(SR) <> 0;
    FindClose(SR);
  end;
end;

{ Scaffolds a complete project directory structure with sample pages }
procedure CmdCreate(const ProjectName: string);
var
  Base, TemplatePath: string;
  Content: string;
begin
  Base := GetCurrentDir + DirectorySeparator + ProjectName + DirectorySeparator;
  TemplatePath := GetSDKPath + 'demo-app' + DirectorySeparator;

  if DirectoryExists(Base) then
  begin
    WriteLn('ERROR: Folder "', ProjectName, '" already exists.');
    Halt(1);
  end;

  if DirectoryExists(TemplatePath) then
  begin
    WriteLn('Scaffolding BlaiseVue project from demo-app template: ', ProjectName);
    CopyDir(TemplatePath, Base, ['.git', '.github', 'node_modules', 'dist', 'generated']);
    
    // Customize project name in package.json if it was copied
    if FileExists(Base + 'package.json') then
    begin
      Content := ReadFileToString(Base + 'package.json');
      Content := StringReplace(Content, '"name": "demo-app"', '"name": "' + ProjectName + '"', [rfReplaceAll]);
      WriteStringToFile(Base + 'package.json', Content);
    end;
    
    // Customize title in index.html if it was copied
    if FileExists(Base + 'public' + DirectorySeparator + 'index.html') then
    begin
      Content := ReadFileToString(Base + 'public' + DirectorySeparator + 'index.html');
      Content := StringReplace(Content, '<title>BlaiseVue Demo 2.0</title>', '<title>' + ProjectName + '</title>', [rfReplaceAll]);
      Content := StringReplace(Content, '<title>BlaiseVue Demo</title>', '<title>' + ProjectName + '</title>', [rfReplaceAll]);
      WriteStringToFile(Base + 'public' + DirectorySeparator + 'index.html', Content);
    end;
    
    WriteLn('  Project cloned from demo-app successfully.');
  end
  else
  begin
    WriteLn('WARNING: demo-app template not found in SDK root. Falling back to minimal scaffolding.');
    WriteLn('Scaffolding BlaiseVue project: ', ProjectName);

    // Create directories
    ForceDir(Base + 'public');
    ForceDir(Base + 'src' + DirectorySeparator + 'components');
    ForceDir(Base + 'src' + DirectorySeparator + 'views');
    ForceDir(Base + 'generated');
    ForceDir(Base + 'dist' + DirectorySeparator + 'js');
    ForceDir(Base + 'tests');

    // Minimal public/index.html
    WriteStringToFile(Base + 'public' + DirectorySeparator + 'index.html',
      '<!DOCTYPE html>' + #10 +
      '<html>' + #10 +
      '<head>' + #10 +
      '  <meta charset="utf-8"/>' + #10 +
      '  <title>' + ProjectName + '</title>' + #10 +
      '  <script type="application/javascript" src="js/rtl.js"></script>' + #10 +
      '  <script type="application/javascript" src="js/main.js"></script>' + #10 +
      '</head>' + #10 +
      '<body>' + #10 +
      '  <div id="app"></div>' + #10 +
      '  <script>rtl.run("program");</script>' + #10 +
      '</body>' + #10 +
      '</html>' + #10
    );

    // Minimal src/app.bv
    WriteStringToFile(Base + 'src' + DirectorySeparator + 'app.bv',
      '<template>' + #10 +
      '  <div>' + #10 +
      '    <nav>' + #10 +
      '      <strong>BlaiseVue</strong>' + #10 +
      '      <a href="#/">Home</a>' + #10 +
      '      <a href="#/about">About</a>' + #10 +
      '    </nav>' + #10 +
      '    <h1>{{ message }}</h1>' + #10 +
      '    <router-view></router-view>' + #10 +
      '  </div>' + #10 +
      '</template>' + #10 +
      #10 +
      '<script>' + #10 +
      '  data:' + #10 +
      '    message: string = ''Welcome to BlaiseVue!'';' + #10 +
      #10 +
      '  router:' + #10 +
      '    routes:' + #10 +
      '      ''/'': ''home-page'';' + #10 +
      '      ''/about'': ''about-page'';' + #10 +
      '</script>' + #10 +
      #10 +
      '<style>' + #10 +
      '  nav { background: #2c3e50; padding: 10px 20px; }' + #10 +
      '  nav a { color: #ecf0f1; text-decoration: none; margin-left: 15px; }' + #10 +
      '  nav strong { color: #42b883; font-size: 18px; }' + #10 +
      '</style>' + #10
    );

    // Minimal src/views/Home.bv
    WriteStringToFile(Base + 'src' + DirectorySeparator + 'views' + DirectorySeparator + 'Home.bv',
      '<template>' + #10 +
      '  <div>' + #10 +
      '    <h2>Homepage</h2>' + #10 +
      '    <p>{{ description }}</p>' + #10 +
      '    <button @click="greet">Click here</button>' + #10 +
      '  </div>' + #10 +
      '</template>' + #10 +
      #10 +
      '<script>' + #10 +
      '  data:' + #10 +
      '    description: string = ''Welcome to my BlaiseVue app!'';' + #10 +
      #10 +
      '  methods:' + #10 +
      '    procedure greet;' + #10 +
      '    begin' + #10 +
      '      window.alert(''Hello from BlaiseVue!'');' + #10 +
      '    end;' + #10 +
      '</script>' + #10 +
      #10 +
      '<style>' + #10 +
      '  h2 { color: #3498db; }' + #10 +
      '</style>' + #10
    );

    // Minimal src/views/About.bv
    WriteStringToFile(Base + 'src' + DirectorySeparator + 'views' + DirectorySeparator + 'About.bv',
      '<template>' + #10 +
      '  <div>' + #10 +
      '    <h2>About</h2>' + #10 +
      '    <p>This project was created with BlaiseVue PRO.</p>' + #10 +
      '  </div>' + #10 +
      '</template>' + #10 +
      #10 +
      '<script>' + #10 +
      '</script>' + #10 +
      #10 +
      '<style>' + #10 +
      '  h2 { color: #27ae60; }' + #10 +
      '</style>' + #10
    );
  end;

  // --- Ensure Standalone Infrastructure Files ---

  // Ensure app.cfg exists
  if not FileExists(Base + 'app.cfg') then
    WriteStringToFile(Base + 'app.cfg',
      '-l' + #10 +
      '-vwnh' + #10 +
      '-Sc' + #10 +
      '-Tbrowser' + #10 +
      '-Jc' + #10 +
      '-Fugenerated' + #10
    );

  // Ensure package.json exists
  if not FileExists(Base + 'package.json') then
    WriteStringToFile(Base + 'package.json',
      '{' + #10 +
      '  "name": "' + ProjectName + '",' + #10 +
      '  "version": "1.0.0",' + #10 +
      '  "type": "module",' + #10 +
      '  "scripts": {' + #10 +
      '    "test": "vitest"' + #10 +
      '  },' + #10 +
      '  "devDependencies": {' + #10 +
      '    "vitest": "^3.0.0",' + #10 +
      '    "jsdom": "^26.0.0"' + #10 +
      '  }' + #10 +
      '}'
    );

  // Ensure tests/setup.js exists
  if not FileExists(Base + 'tests' + DirectorySeparator + 'setup.js') then
  begin
    ForceDir(Base + 'tests');
    WriteStringToFile(Base + 'tests' + DirectorySeparator + 'setup.js',
      'import { readFileSync } from ''fs'';' + #10 +
      'import { resolve } from ''path'';' + #10 +
      #10 +
      '// Mock environment' + #10 +
      'globalThis.window = globalThis;' + #10 +
      'if (typeof document !== ''undefined'') globalThis.document = document;' + #10 +
      'if (typeof navigator !== ''undefined'') globalThis.navigator = navigator;' + #10 +
      #10 +
      '// Load Pascal RTL' + #10 +
      'const rtlContent = readFileSync(resolve(process.cwd(), ''rtl.js''), ''utf8'');' + #10 +
      '// Use global eval to let ''var pas'' and ''var rtl'' become globals' + #10 +
      '(0, eval)(rtlContent);' + #10 +
      #10 +
      'if (!globalThis.__BV_CORE__) globalThis.__BV_CORE__ = {};' + #10
    );
  end;

  // Ensure vitest.config.js exists
  if not FileExists(Base + 'vitest.config.js') then
    WriteStringToFile(Base + 'vitest.config.js',
      'import { defineConfig } from ''vitest/config'';' + #10 +
      #10 +
      'export default defineConfig({' + #10 +
      '  test: {' + #10 +
      '    globals: true,' + #10 +
      '    environment: ''jsdom'',' + #10 +
      '    setupFiles: [''./tests/setup.js''],' + #10 +
      '  },' + #10 +
      '});'
    );

  // Always ensure rtl.js exists
  if not FileExists(Base + 'rtl.js') then
  begin
    if GetRTLPath <> '' then
    begin
      CopyFile(GetRTLPath, Base + 'rtl.js');
      WriteLn('  rtl.js                 copied');
    end
    else
      WriteLn('  WARNING: rtl.js not found. Copy it manually to the project root.');
  end;

  WriteLn('');
  WriteLn('Installing dependencies (npm install)...');
  
  {$IFDEF WINDOWS}
  ExecuteProcess('cmd', '/c cd /d "' + Base + '" && npm install');
  {$ELSE}
  ExecuteProcess('npm', 'install --prefix "' + Base + '"');
  {$ENDIF}

  WriteLn('');
  WriteLn('Project created successfully!');
  WriteLn('');
  WriteLn('Next steps:');
  WriteLn('  cd ', ProjectName);
  WriteLn('  bv run dev');
end;

// =====================================================================
//  COMANDO: TRANSPILE (Gera apenas .pas)
// =====================================================================

procedure CmdTranspile;
var
  SR: TSearchRec;
  BVFiles: TStringList;
  UnitNames: TStringList;
  i: Integer;
  FileName, UnitName, TagName, GenPath: string;
  Parsed: TBVParsed;
  GeneratedCode: string;
  IsApp: Boolean;
begin
  GenPath := GetCurrentDir + DirectorySeparator + 'generated' + DirectorySeparator;

  if not DirectoryExists(GetCurrentDir + DirectorySeparator + 'src') then
  begin
    Exit;
  end;

  ForceDir(GenPath);

  BVFiles := TStringList.Create;
  UnitNames := TStringList.Create;
  try
    WriteLn('=== BlaiseVue Transpile ===');
    WriteLn('');

    // Prepares app.bv first
    if FileExists(GetCurrentDir + DirectorySeparator + 'src' + DirectorySeparator + 'app.bv') then
      BVFiles.Add(GetCurrentDir + DirectorySeparator + 'src' + DirectorySeparator + 'app.bv');

    // Scans src and lib recursively
    ScanDirForBV(GetCurrentDir + DirectorySeparator + 'src' + DirectorySeparator + 'components', BVFiles);
    ScanDirForBV(GetCurrentDir + DirectorySeparator + 'src' + DirectorySeparator + 'views', BVFiles);
    ScanDirForBV(GetCurrentDir + DirectorySeparator + 'lib', BVFiles);

    if BVFiles.Count = 0 then
    begin
      WriteLn('  (No .bv components found in src/ or lib/)');
      Exit;
    end;

    WriteLn('Processing ', BVFiles.Count, ' .bv file(s) ...');
    WriteLn('');

    // Passo 1: Identifica units
    for i := 0 to BVFiles.Count - 1 do
    begin
      FileName := ExtractFileName(BVFiles[i]);
      FileName := ChangeFileExt(FileName, '');
      if LowerCase(FileName) = 'app' then
        UnitName := 'uApp'
      else
        UnitName := 'u' + FileName;
      UnitNames.Add(UnitName);
    end;

    // Passo 2: Gera codigo .pas
    for i := 0 to BVFiles.Count - 1 do
    begin
      FileName := ExtractFileName(BVFiles[i]);
      IsApp := (LowerCase(ChangeFileExt(FileName, '')) = 'app');
      UnitName := UnitNames[i];
      TagName := PascalToKebab(ChangeFileExt(FileName, ''));
      if (not IsApp) and (Pos('src' + DirectorySeparator + 'views', BVFiles[i]) > 0) then
        TagName := TagName + '-page';

      WriteLn('  ', FileName, ' -> ', UnitName, '.pas');
      ParseBVFile(BVFiles[i], Parsed);

      if IsApp then
        GeneratedCode := GenerateAppUnit(Parsed, UnitNames)
      else
        GeneratedCode := GenerateComponentUnit(UnitName, TagName, FileName, Parsed);

      WriteStringToFile(GenPath + UnitName + '.pas', GeneratedCode);
    end;

    // Generates main.pas
    GeneratedCode := GenerateMainProgram;
    WriteStringToFile(GenPath + 'main.pas', GeneratedCode);
    WriteLn('  main.pas (generated)');
    WriteLn('');
    WriteLn('Transpile completed successfully! Files generated in: ', GenPath);
  finally
    BVFiles.Free;
    UnitNames.Free;
  end;
end;

// =====================================================================
//  COMMAND: CLEAN
// =====================================================================

{ Purges temporary build files and result artifacts }
procedure CmdClean;
var
  Base: string;
begin
  Base := GetCurrentDir + DirectorySeparator;
  WriteLn('=== BlaiseVue Clean ===');
  WriteLn('Cleaning generated files...');
  
  if DirectoryExists(Base + 'generated') then
  begin
    DeleteDir(Base + 'generated');
    WriteLn('  [v] /generated folder removed.');
  end;
  
  if DirectoryExists(Base + 'dist' + DirectorySeparator + 'js') then
  begin
    DeleteDir(Base + 'dist' + DirectorySeparator + 'js');
    WriteLn('  [v] Generated JS in /dist/js removed.');
  end;
  
  if FileExists(Base + 'dist' + DirectorySeparator + 'index.html') then
  begin
    DeleteFile(Base + 'dist' + DirectorySeparator + 'index.html');
    WriteLn('  [v] /dist/index.html removed.');
  end;

  WriteLn('');
  WriteLn('Cleanup completed successfully!');
end;

// =====================================================================
//  COMMAND: FULL BUILD & RUN DEV
// =====================================================================

{ Execution cycle: Transpile .bv -> Pascal -> JS and setup public assets }
procedure CmdBuild;
var
  SR: TSearchRec;
  BVFiles, UnitNames, CSSFiles: TStringList;
  i: Integer;
  FileName, UnitName, TagName, GenPath, DistPath, PublicPath, GeneratedCode, Pas2jsCmd, CSSTags, JSTags: string;
  Parsed: TBVParsed;
  IsApp: Boolean;
  JSFiles: TStringList;
begin
  GenPath := GetCurrentDir + DirectorySeparator + 'generated' + DirectorySeparator;
  DistPath := GetCurrentDir + DirectorySeparator + 'dist' + DirectorySeparator;
  PublicPath := GetCurrentDir + DirectorySeparator + 'public' + DirectorySeparator;

  if not DirectoryExists(GetCurrentDir + DirectorySeparator + 'src') then
  begin
    WriteLn('ERROR: "src/" folder not found. Are you in a BlaiseVue project root?');
    Halt(1);
  end;

  ForceDir(GenPath);
  ForceDir(DistPath + 'js');

  BVFiles := TStringList.Create;
  UnitNames := TStringList.Create;
  try
    // Escaneia .bv recursivamente em src/
    WriteLn('=== BlaiseVue Development Build (Debug Mode) ===');
    WriteLn('  Info: Injecting debug features (BVDevTools)');
    WriteLn('  Cache: Injecting timestamp to prevent browser caching');
    WriteLn('');

    // 1. Get app.bv first
    if FileExists(GetCurrentDir + DirectorySeparator + 'src' + DirectorySeparator + 'app.bv') then
      BVFiles.Add(GetCurrentDir + DirectorySeparator + 'src' + DirectorySeparator + 'app.bv');

    // 2. Scan src and lib recursively using the established helper
    ScanDirForBV(GetCurrentDir + DirectorySeparator + 'src' + DirectorySeparator + 'components', BVFiles);
    ScanDirForBV(GetCurrentDir + DirectorySeparator + 'src' + DirectorySeparator + 'views', BVFiles);

    // NOVO: Pega bibliotecas em lib/ recursivamente
    CSSFiles := TStringList.Create;
    JSFiles := TStringList.Create;
    ScanDirForBV(GetCurrentDir + DirectorySeparator + 'lib', BVFiles);
    ScanDirForCSS(GetCurrentDir + DirectorySeparator + 'lib', CSSFiles);
    ScanDirForJS(GetCurrentDir + DirectorySeparator + 'lib', JSFiles);

    if BVFiles.Count = 0 then
    begin
      WriteLn('No .bv files found in src/ or lib/');
      Halt(1);
    end;

    WriteLn('[1/3] Processing ', BVFiles.Count, ' .bv file(s) ...');
    WriteLn('');

    // Primeiro passo: identifica todas as units (precisa da lista completa pra app.bv)
    for i := 0 to BVFiles.Count - 1 do
    begin
      FileName := ExtractFileName(BVFiles[i]);
      FileName := ChangeFileExt(FileName, '');
      if LowerCase(FileName) = 'app' then
        UnitName := 'uApp'
      else
        UnitName := 'u' + FileName;
      UnitNames.Add(UnitName);
    end;

    // Segundo passo: parseia e gera codigo
    for i := 0 to BVFiles.Count - 1 do
    begin
      FileName := ExtractFileName(BVFiles[i]);
      IsApp := (LowerCase(ChangeFileExt(FileName, '')) = 'app');
      UnitName := UnitNames[i];
      TagName := PascalToKebab(ChangeFileExt(FileName, ''));
      // Apenas views (src/views/) ganham sufixo -page. 
      // Arquivos em src/components/ e lib/ mantem o nome natural.
      IsApp := (LowerCase(ChangeFileExt(FileName, '')) = 'app');
      
      // Checa se o arquivo estah em componentes ou lib (pelo caminho)
      if (not IsApp) and (Pos('src' + DirectorySeparator + 'views', BVFiles[i]) > 0) then
        TagName := TagName + '-page';

      WriteLn('  ', FileName, ' -> ', UnitName, '.pas');

      ParseBVFile(BVFiles[i], Parsed);

      if IsApp then
        GeneratedCode := GenerateAppUnit(Parsed, UnitNames)
      else
        GeneratedCode := GenerateComponentUnit(UnitName, TagName, FileName, Parsed);

      WriteStringToFile(GenPath + UnitName + '.pas', GeneratedCode);
    end;

    // Gera main.pas
    GeneratedCode := GenerateMainProgram;
    WriteStringToFile(GenPath + 'main.pas', GeneratedCode);
    WriteLn('  main.pas (gerado)');
    WriteLn('');

    // [2/3] Calling pas2js
    WriteLn('[2/3] Compiling with pas2js ...');
    WriteLn('');

    Pas2jsCmd := '"' + GetPas2JSPath + '" -Fu"' + GetCorePath + '" -Fu"' + GetPas2JSLibPath + '" "@app.cfg" generated' + DirectorySeparator + 'main.pas -o' + DistPath + 'js' + DirectorySeparator + 'main.js';
    WriteLn('  > ', Pas2jsCmd);
    WriteLn('');

    i := ExecuteProcess(GetPas2JSPath, '"@app.cfg" -Fu"' + GetCorePath + '" -Fu"' + GetPas2JSLibPath + '" generated' + DirectorySeparator + 'main.pas -o' +
      DistPath + 'js' + DirectorySeparator + 'main.js');

    if i <> 0 then
    begin
      WriteLn('');
      WriteLn('ERROR: pas2js returned code ', i);
      Halt(1);
    end;

    // [3/3] Copying public/ to dist/
    WriteLn('[3/3] Copying public files ...');
    WriteLn('');

    if FileExists(PublicPath + 'index.html') then
    begin
      UnitName := ReadFileToString(PublicPath + 'index.html');
      TagName := IntToStr(DateTimeToUnix(Now));
      
      // Injeta cache buster real nos placeholders
      UnitName := StringReplace(UnitName, '__CACHE_BUST__', TagName, [rfReplaceAll]);
      
      // Coleta e copia CSS das bibliotecas
      CSSTags := '';
      if CSSFiles.Count > 0 then
      begin
        ForceDir(DistPath + 'css' + DirectorySeparator + 'lib');
        for i := 0 to CSSFiles.Count - 1 do
        begin
           FileName := ExtractFileName(CSSFiles[i]);
           try
             WriteStringToFile(DistPath + 'css' + DirectorySeparator + 'lib' + DirectorySeparator + FileName, ReadFileToString(CSSFiles[i]));
           except
             WriteLn('  WARNING: Could not update ', FileName, ' (locked). Skipping.');
           end;
           CSSTags := CSSTags + '  <link rel="stylesheet" href="css/lib/' + FileName + '?v=' + TagName + '">' + #10;
        end;
      end;

      // Coleta e copia JS das bibliotecas
      JSTags := '';
      if JSFiles.Count > 0 then
      begin
        ForceDir(DistPath + 'js' + DirectorySeparator + 'lib');
        for i := 0 to JSFiles.Count - 1 do
        begin
           FileName := ExtractFileName(JSFiles[i]);
           WriteStringToFile(DistPath + 'js' + DirectorySeparator + 'lib' + DirectorySeparator + FileName, ReadFileToString(JSFiles[i]));
           JSTags := JSTags + '  <script src="js/lib/' + FileName + '?v=' + TagName + '"></script>' + #10;
        end;
      end;

      // Injeta bibliotecas no final do <head> para CSS e antes do rtl.js para scripts
      if CSSTags <> '' then
        UnitName := StringReplace(UnitName, '</head>', CSSTags + '</head>', [rfIgnoreCase]);

      if JSTags <> '' then
      begin
        // Tenta injetar JS de lib antes do runtime e app logic para garantir disponibilidade
        if Pos('js/rtl.js', UnitName) > 0 then
          UnitName := StringReplace(UnitName, '<script src="js/rtl.js', JSTags + '    <script src="js/rtl.js', [rfIgnoreCase])
        else
          UnitName := StringReplace(UnitName, '</head>', JSTags + '</head>', [rfIgnoreCase]);
      end;
      
      // Fallback: se o usuario nao usou __CACHE_BUST__, tentamos injetar v= no main.js
      if Pos('main.js?v=', UnitName) = 0 then
        UnitName := StringReplace(UnitName, 'main.js', 'main.js?v=' + TagName, [rfReplaceAll]);
      if Pos('rtl.js?v=', UnitName) = 0 then
        UnitName := StringReplace(UnitName, 'rtl.js', 'rtl.js?v=' + TagName, [rfReplaceAll]);

      WriteStringToFile(DistPath + 'index.html', UnitName);
      WriteLn('  index.html -> dist/ (cache bust v=' + TagName + ')');
    end;

    // NOVO: Copia o restante da pasta public/ (assets, etc) recursivamente
    if DirectoryExists(PublicPath) then
    begin
       WriteLn('  Copying assets from /public to /dist...');
       CopyDir(PublicPath, DistPath, ['index.html']); // Pula index.html pois ja processamos acima
    end;

    // Copies rtl.js to dist/js/ using automatic SDK lookup
    FileName := GetRTLPath;
    if FileName <> '' then
    begin
      WriteStringToFile(DistPath + 'js' + DirectorySeparator + 'rtl.js',
        ReadFileToString(FileName));
      WriteLn('  rtl.js -> dist/js/ (from SDK)');
    end
    else
    begin
      WriteLn('  WARNING: rtl.js not found in SDK.');
      WriteLn('  Look for rtl.js and place it in the root or SDK folder: ', GetSDKPath);
    end;

    WriteLn('');
    WriteLn('=== Build completed successfully! ===');
    WriteLn('');
    WriteLn('Open dist/index.html in your browser to see the result.');

  finally
    BVFiles.Free;
    UnitNames.Free;
  end;
end;

// =====================================================================
//  COMANDO: NEW COMPONENT
// =====================================================================

procedure CmdNewComponent(const CompName: string);
var
  CompPath, TargetPath: string;
begin
  CompPath := GetCurrentDir + DirectorySeparator + 'src' + DirectorySeparator + 'components' + DirectorySeparator;
  TargetPath := CompPath + CompName + '.bv';

  if FileExists(TargetPath) then
  begin
    WriteLn('ERROR: Component "', CompName, '.bv" already exists!');
    Halt(1);
  end;

  ForceDir(CompPath);

  WriteStringToFile(TargetPath,
    '<template>' + #10 +
    '  <div>' + #10 +
    '    <h3>' + CompName + '</h3>' + #10 +
    '    <p>{{ info }}</p>' + #10 +
    '  </div>' + #10 +
    '</template>' + #10 +
    #10 +
    '<script>' + #10 +
    '  data:' + #10 +
    '    info: string = ''Component ' + CompName + ' created!'';' + #10 +
    '</script>' + #10 +
    #10 +
    '<style>' + #10 +
    '</style>' + #10
  );

  WriteLn('Component created: src/components/', CompName, '.bv');
  WriteLn('HTML Tag: <', PascalToKebab(CompName), '>');
end;

// =====================================================================
//  CCOMMAND: REMOVE COMPONENT
// =====================================================================

procedure CmdRemoveComponent(const CompName: string);
var
  BVPath, PasPath: string;
begin
  BVPath := GetCurrentDir + DirectorySeparator + 'src' + DirectorySeparator + 'components' + DirectorySeparator + CompName + '.bv';
  PasPath := GetCurrentDir + DirectorySeparator + 'generated' + DirectorySeparator + 'u' + CompName + '.pas';

  if FileExists(BVPath) then
  begin
    DeleteFile(BVPath);
    WriteLn('Removed: src/components/', CompName, '.bv');
  end
  else
    WriteLn('File not found: src/components/', CompName, '.bv');

  if FileExists(PasPath) then
  begin
    DeleteFile(PasPath);
    WriteLn('Removed: generated/u', CompName, '.pas');
  end;

  WriteLn('Component "', CompName, '" removed.');
end;

// =====================================================================
//  COMMAND: NEW VIEW
// =====================================================================

procedure CmdNewView(const ViewName: string);
var
  ViewPath, TargetPath: string;
begin
  ViewPath := GetCurrentDir + DirectorySeparator + 'src' + DirectorySeparator + 'views' + DirectorySeparator;
  TargetPath := ViewPath + ViewName + '.bv';

  if FileExists(TargetPath) then
  begin
    WriteLn('ERROR: View "', ViewName, '.bv" already exists!');
    Halt(1);
  end;

  ForceDir(ViewPath);

  WriteStringToFile(TargetPath,
    '<template>' + #10 +
    '  <div class="' + PascalToKebab(ViewName) + '-page">' + #10 +
    '    <h2>' + ViewName + ' View</h2>' + #10 +
    '    <p>This is the new ' + ViewName + ' view.</p>' + #10 +
    '  </div>' + #10 +
    '</template>' + #10 +
    #10 +
    '<script>' + #10 +
    '  data:' + #10 +
    '    title: string = ''' + ViewName + ''';' + #10 +
    '</script>' + #10 +
    #10 +
    '<style>' + #10 +
    '  .' + PascalToKebab(ViewName) + '-page { padding: 20px; }' + #10 +
    '</style>' + #10
  );

  WriteLn('View created: src/views/', ViewName, '.bv');
  WriteLn('HTML Tag (internal): <', PascalToKebab(ViewName), '-page>');
end;

// =====================================================================
//  COMMAND: REMOVE VIEW
// =====================================================================

procedure ScanDirForBV(const Path: string; List: TStringList);
var
  SR: TSearchRec;
  D: string;
begin
  if not DirectoryExists(Path) then Exit;
  D := IncludeTrailingPathDelimiter(Path);
  if FindFirst(D + '*', faAnyFile, SR) = 0 then
  begin
    repeat
       if (SR.Name <> '.') and (SR.Name <> '..') then
       begin
          if (SR.Attr and faDirectory) <> 0 then
            ScanDirForBV(D + SR.Name, List)
          else if LowerCase(ExtractFileExt(SR.Name)) = '.bv' then
            List.Add(D + SR.Name);
       end;
    until FindNext(SR) <> 0;
    FindClose(SR);
  end;
end;

function RunSetupScript(const LibName, Action: string): Boolean;
var
  LibPath, ScriptPath, ExecPath: string;
  ExitCode: Integer;
begin
  Result := False;
  LibPath := GetCurrentDir + DirectorySeparator + 'lib' + DirectorySeparator + LibName + DirectorySeparator;
  ScriptPath := LibPath + 'setup.pas';
  
  if not FileExists(ScriptPath) then Exit(True); // No script = success (nothing to do)

  WriteLn('Preparing setup script for "' + LibName + '"...');
  
  {$IFDEF WINDOWS}
  ExecPath := LibPath + 'setup.exe';
  ExitCode := ExecuteProcess('cmd', '/c fpc "' + ScriptPath + '" -o"' + ExecPath + '" > nul');
  {$ELSE}
  ExecPath := LibPath + 'setup';
  ExitCode := ExecuteProcess('fpc', '-o' + ExecPath + ' ' + ScriptPath);
  {$ENDIF}

  if (ExitCode <> 0) or not FileExists(ExecPath) then
  begin
    WriteLn('ERROR: Failed to compile setup script for ' + LibName);
    Exit(False);
  end;

  WriteLn('Executing action: ' + Action);
  ExitCode := ExecuteProcess(ExecPath, Action);
  
  // Cleanup
  DeleteFile(ExecPath);
  if FileExists(ChangeFileExt(ExecPath, '.o')) then DeleteFile(ChangeFileExt(ExecPath, '.o'));
  if FileExists(ChangeFileExt(ExecPath, '.ppu')) then DeleteFile(ChangeFileExt(ExecPath, '.ppu'));
  
  Result := (ExitCode = 0);
end;

procedure CmdSetup(const LibName: string);
var
  Path, Choice: string;
begin
  Path := GetCurrentDir + DirectorySeparator + 'lib' + DirectorySeparator + LibName + DirectorySeparator;
  if not DirectoryExists(Path) then
  begin
    WriteLn('Error: Library "' + LibName + '" not found in /lib.');
    Exit;
  end;

  if not FileExists(Path + 'setup.pas') then
  begin
    WriteLn('The library "' + LibName + '" does not have a setup script (setup.pas).');
    Exit;
  end;

  WriteLn('');
  WriteLn('--- Component Setup: ' + LibName + ' ---');
  WriteLn('1. Install (Create folders and configurations)');
  WriteLn('2. Reinstall (Perform updates)');
  WriteLn('3. Delete (Cleanup actions)');
  WriteLn('0. Cancel');
  WriteLn('');
  Write('Select an option: ');
  ReadLn(Choice);

  if Choice = '1' then RunSetupScript(LibName, 'install')
  else if Choice = '2' then RunSetupScript(LibName, 'reinstall')
  else if Choice = '3' then 
  begin
    if RunSetupScript(LibName, 'remove') then
       WriteLn('Cleanup completed.')
    else
       WriteLn('Cleanup finished with issues.');
  end
  else WriteLn('Action cancelled.');
end;


procedure CmdLibList;
var
  SR: TSearchRec;
  Path: string;
  Extra: string;
begin
  Path := GetCurrentDir + DirectorySeparator + 'lib' + DirectorySeparator;
  WriteLn('');
  WriteLn('Installed Libs in /lib:');
  WriteLn(StringOfChar('-', 40));
  if FindFirst(Path + '*', faDirectory, SR) = 0 then
  begin
    repeat
      if (SR.Name <> '.') and (SR.Name <> '..') then
      begin
        Extra := '';
        if FileExists(Path + SR.Name + DirectorySeparator + 'setup.pas') then
          Extra := ' [Scripted]';
        WriteLn('  - ', SR.Name, Extra);
      end;
    until FindNext(SR) <> 0;
    FindClose(SR);
  end;
  WriteLn(StringOfChar('-', 40));
end;

procedure CmdLibRemove(const LibName: string);
var
  Path: string;
begin
  Path := GetCurrentDir + DirectorySeparator + 'lib' + DirectorySeparator + LibName;
  if DirectoryExists(Path) then
  begin
    if FileExists(Path + DirectorySeparator + 'setup.pas') then
    begin
       WriteLn('Detected setup script. Running cleanup...');
       RunSetupScript(LibName, 'remove');
    end;
    DeleteDir(Path);
    WriteLn('Library "', LibName, '" removed.');
  end
  else
    WriteLn('Error: Library "', LibName, '" not found in /lib.');
end;

procedure CmdLibInstall(const URL: string);
var
  LibPath, ZipName: string;
  Client: TFPHTTPClient;
  UnZipper: TUnZipper;
begin
  LibPath := GetCurrentDir + DirectorySeparator + 'lib' + DirectorySeparator;
  ForceDir(LibPath);
  ZipName := LibPath + 'temp_lib.zip';
  
  WriteLn('Downloading from: ', URL);
  Client := TFPHTTPClient.Create(nil);
  try
    try
      Client.AllowRedirect := True;
      Client.Get(URL, ZipName);
    except
      on E: Exception do begin WriteLn('Download error: ', E.Message); Halt(1); end;
    end;
  finally
    Client.Free;
  end;
  
  WriteLn('Extracting into /lib folder...');
  UnZipper := TUnZipper.Create;
  try
    UnZipper.FileName := ZipName;
    UnZipper.OutputPath := LibPath;
    UnZipper.Examine;
    UnZipper.UnZipAllFiles;
  finally
    UnZipper.Free;
  end;
  
  DeleteFile(ZipName);
  WriteLn('Installation completed successfully!');
end;

procedure ScanDirForCSS(const Path: string; List: TStringList);
var
  SR: TSearchRec;
begin
  if not DirectoryExists(Path) then Exit;
  if FindFirst(Path + DirectorySeparator + '*', faAnyFile, SR) = 0 then
  begin
    repeat
       if (SR.Name <> '.') and (SR.Name <> '..') then
       begin
          if (SR.Attr and faDirectory) <> 0 then
            ScanDirForCSS(Path + DirectorySeparator + SR.Name, List)
          else if ExtractFileExt(SR.Name) = '.css' then
            List.Add(Path + DirectorySeparator + SR.Name);
       end;
    until FindNext(SR) <> 0;
    FindClose(SR);
  end;
end;

procedure ScanDirForJS(const Path: string; List: TStringList);
var
  SR: TSearchRec;
begin
  if not DirectoryExists(Path) then Exit;
  if FindFirst(Path + DirectorySeparator + '*', faAnyFile, SR) = 0 then
  begin
    repeat
       if (SR.Name <> '.') and (SR.Name <> '..') then
       begin
          if (SR.Attr and faDirectory) <> 0 then
            ScanDirForJS(Path + DirectorySeparator + SR.Name, List)
          else if ExtractFileExt(SR.Name) = '.js' then
            List.Add(Path + DirectorySeparator + SR.Name);
       end;
    until FindNext(SR) <> 0;
    FindClose(SR);
  end;
end;

procedure CmdRemoveView(const ViewName: string);
var
  BVPath, PasPath: string;
begin
  BVPath := GetCurrentDir + DirectorySeparator + 'src' + DirectorySeparator + 'views' + DirectorySeparator + ViewName + '.bv';
  PasPath := GetCurrentDir + DirectorySeparator + 'generated' + DirectorySeparator + 'u' + ViewName + '.pas';

  if FileExists(BVPath) then
  begin
    DeleteFile(BVPath);
    WriteLn('Removed: src/views/', ViewName, '.bv');
  end;

  if FileExists(PasPath) then
    DeleteFile(PasPath);
end;

// =====================================================================
//  COMMAND: NEW TEST
// =====================================================================

procedure CmdNewTest(const TestName: string);
var
  TestPath, TargetPath: string;
begin
  TestPath := GetCurrentDir + DirectorySeparator + 'tests' + DirectorySeparator;
  TargetPath := TestPath + TestName + '.test.pas';

  if FileExists(TargetPath) then
  begin
    WriteLn('ERROR: Test "', TestName, '.test.pas" already exists!');
    Halt(1);
  end;

  ForceDir(TestPath);

  WriteStringToFile(TargetPath,
    'program ' + TestName + '_test;' + #10 +
    #10 +
    '{$mode objfpc}' + #10 +
    #10 +
    'uses JS, Web, BVTestUtils;' + #10 +
    #10 +
    'var' + #10 +
    '  Wrapper: TWrapper;' + #10 +
    #10 +
    'begin' + #10 +
    '  Describe(''' + TestName + ''', procedure' + #10 +
    '    begin' + #10 +
    '       It(''should work'', procedure' + #10 +
    '         begin' + #10 +
    '            Expect(True).ToEqual(True);' + #10 +
    '         end);' + #10 +
    '    end);' + #10 +
    'end.' + #10
  );

  WriteLn('Test created: tests/', TestName, '.test.pas');
end;

// =====================================================================
//  COMMAND: REMOVE TEST
// =====================================================================

procedure CmdRemoveTest(const TestName: string);
var
  TestPath, GenPath: string;
begin
  TestPath := GetCurrentDir + DirectorySeparator + 'tests' + DirectorySeparator + TestName + '.test.pas';
  GenPath := GetCurrentDir + DirectorySeparator + 'generated' + DirectorySeparator + 'tests' + DirectorySeparator + TestName + '.test.js';

  if FileExists(TestPath) then
  begin
    DeleteFile(TestPath);
    WriteLn('Removed: tests/', TestName, '.test.pas');
  end;

  if FileExists(GenPath) then
    DeleteFile(GenPath);

  WriteLn('Test "', TestName, '" removed.');
end;

// =====================================================================
//  COMANDO: LIST
// =====================================================================

procedure CmdList(const Kind: string);
var
  SR: TSearchRec;
  Path, SearchKind: string;
  Count: Integer;
begin
  Count := 0;
  if LowerCase(Kind) = 'c' then
  begin
    Path := GetCurrentDir + DirectorySeparator + 'src' + DirectorySeparator + 'components' + DirectorySeparator;
    SearchKind := 'Components';
  end
  else if LowerCase(Kind) = 'v' then
  begin
    Path := GetCurrentDir + DirectorySeparator + 'src' + DirectorySeparator + 'views' + DirectorySeparator;
    SearchKind := 'Views';
  end
  else if LowerCase(Kind) = 't' then
  begin
    Path := GetCurrentDir + DirectorySeparator + 'tests' + DirectorySeparator;
    SearchKind := 'Tests';
  end
  else
  begin
    WriteLn('Usage: bv list <c|v|t>');
    Halt(1);
  end;

  WriteLn('');
  WriteLn('Listing ', SearchKind, ' in: ', Path);
  WriteLn(StringOfChar('-', 40));

  if FindFirst(Path + '*', faAnyFile, SR) = 0 then
  begin
    repeat
      if (ExtractFileExt(SR.Name) = '.bv') or (Pos('.test.pas', SR.Name) > 0) then
      begin
        Inc(Count);
        WriteLn('  [', Count, '] ', SR.Name);
      end;
    until FindNext(SR) <> 0;
    FindClose(SR);
  end;

  if Count = 0 then
    WriteLn('  (No matches found)')
  else
  begin
    WriteLn(StringOfChar('-', 40));
    WriteLn('Total: ', Count, ' ', SearchKind);
  end;
  WriteLn('');
end;

// =====================================================================
//  COMANDO: SERVE (antigo run dev)
// =====================================================================

procedure CmdRunBuild;
var
  GenPath, DistPath, PublicPath: string;
  Hash, IndexHTML: string;
  JSFiles: TStringList;
  JSTags, FileName: string;
  i: Integer;
begin
  WriteLn('=== BlaiseVue Professional Build (ProductionMode) ===');
  
  // 1. Transpile
  CmdTranspile;

  GenPath := GetCurrentDir + DirectorySeparator + 'generated' + DirectorySeparator;
  DistPath := GetCurrentDir + DirectorySeparator + 'dist' + DirectorySeparator;
  PublicPath := GetCurrentDir + DirectorySeparator + 'public' + DirectorySeparator;

  // 2. Limpa dist/
  if DirectoryExists(DistPath) then
    DeleteDir(DistPath);
  ForceDir(DistPath + 'js');

  // 3. Compiles with pas2js (Production mode: -PRODUCTION defines)
  WriteLn('[2/3] Compiling for production (pas2js)...');
  ExecuteProcess(GetPas2JSPath, '"@app.cfg" -Fu"' + GetCorePath + '" -Fu"' + GetPas2JSLibPath + '" -dPRODUCTION generated/main.pas -o' + DistPath + 'js/main.js');

  // 4. Hashing
  Hash := GetFileHash(DistPath + 'js/main.js');
  RenameFile(DistPath + 'js/main.js', DistPath + 'js/main.' + Hash + '.js');
  
  FileName := GetRTLPath;
  if FileName <> '' then
    WriteStringToFile(DistPath + 'js/rtl.js', ReadFileToString(FileName));

  // 5. Index.html com Hash
  if FileExists(PublicPath + 'index.html') then
  begin
    IndexHTML := ReadFileToString(PublicPath + 'index.html');
    IndexHTML := StringReplace(IndexHTML, 'src="js/main.js', 'src="js/main.' + Hash + '.js', [rfReplaceAll]);
    IndexHTML := StringReplace(IndexHTML, 'src="main.js', 'src="js/main.' + Hash + '.js', [rfReplaceAll]);
    IndexHTML := StringReplace(IndexHTML, 'js/rtl.js', 'js/rtl.js', [rfReplaceAll]);

    // Injeta JS das bibliotecas (Produção)
    JSFiles := TStringList.Create;
    ScanDirForJS(GetCurrentDir + DirectorySeparator + 'lib', JSFiles);
    if JSFiles.Count > 0 then
    begin
      JSTags := '';
      ForceDir(DistPath + 'js/lib');
      for i := 0 to JSFiles.Count - 1 do
      begin
         FileName := ExtractFileName(JSFiles[i]);
         WriteStringToFile(DistPath + 'js/lib/' + FileName, ReadFileToString(JSFiles[i]));
         JSTags := JSTags + '  <script src="js/lib/' + FileName + '"></script>' + #10;
      end;
      IndexHTML := StringReplace(IndexHTML, '</head>', JSTags + '</head>', [rfIgnoreCase]);
    end;

    WriteStringToFile(DistPath + 'index.html', IndexHTML);
  end;

  // NOVO: Copia ativos em producao
  if DirectoryExists(PublicPath) then
  begin
     WriteLn('[3/3] Copying production assets (public/assets/)...');
     CopyDir(PublicPath, DistPath, ['index.html']);
  end;

  WriteLn('');
  WriteLn('Production build generated in /dist');
  WriteLn('Main file: main.' + Hash + '.js');
  WriteLn('DevTools disabled via -dPRODUCTION');
end;

procedure CmdServe;
begin
  WriteLn('=== BlaiseVue Dev Server (Static Server) ===');
  WriteLn('  Logs: Showing server access logs (HTTP)');
  WriteLn('  Local: http://localhost:8080');
  WriteLn('');
  {$IFDEF WINDOWS}
  ExecuteProcess('cmd', '/c npx http-server dist -p 8080 -c-1');
  {$ELSE}
  ExecuteProcess('npx', 'http-server dist -p 8080 -c-1');
  {$ENDIF}
end;

procedure CmdRunPreview;
begin
  WriteLn('=== BlaiseVue Production Preview ===');
  if not DirectoryExists('dist') then
  begin
    WriteLn('ERROR: /dist folder not found. Run "bv run build" first.');
    Exit;
  end;
  WriteLn('Serving /dist at http://localhost:5000...');
  {$IFDEF WINDOWS}
  ExecuteProcess('cmd', '/c npx http-server dist -p 5000');
  {$ELSE}
  ExecuteProcess('npx', 'http-server dist -p 5000');
  {$ENDIF}
end;

function GenerateComponentJS(const UnitName, TagName: string; const Parsed: TBVParsed): string;
var
  Tpl, Style, DataCode, MethodsCode, CreatedCode, MountedCode, UpdatedCode, WatchCode, ComputedCode, ProvideCode, InjectCode: string;
  i: Integer;
begin
  Tpl := StringReplace(Parsed.Template, #10, ' ', [rfReplaceAll]);
  Tpl := StringReplace(Tpl, '''', '''''', [rfReplaceAll]);
  Style := StringReplace(Parsed.Style, #10, ' ', [rfReplaceAll]);
  Style := StringReplace(Style, '''', '''''', [rfReplaceAll]);

  DataCode := 'function() { return { ';
  for i := 0 to High(Parsed.DataFields) do
  begin
    if i > 0 then DataCode := DataCode + ', ';
    DataCode := DataCode + Parsed.DataFields[i].Name + ': ' + Parsed.DataFields[i].DefaultValue;
  end;
  DataCode := DataCode + ' }; }';

  // Note: Standard methods implementation for JS transformer is tricky because they are written in Pascal.
  // HOWEVER, for Vitest to work with .bv imports, we either:
  // A) Need to transpile the whole thing through pas2js (Slow)
  // B) Just provide the structure and let the transformer handle the script separately.
  // The user wanted a transformer that uses the compiler.

  // Let's stick to the .pas -> .js pipeline for tests for now as it's more robust,
  // but I'll add the 'compile-sfc' to help the transformer if they want to go that way.
  Result := '/* Generated by BlaiseVue CLI */' + #10 +
            'export default {' + #10 +
            '  template: `' + Parsed.Template + '`,' + #10 +
            '  style: `' + Parsed.Style + '`,' + #10 +
            '  data: ' + DataCode + ',' + #10 +
            '  tagName: ''' + TagName + '''' + #10 +
            '};';
end;

procedure CmdCompileSFC(const FileName: string);
var
  Parsed: TBVParsed;
begin
  if not FileExists(FileName) then Halt(1);
  ParseBVFile(FileName, Parsed);
  Write(GenerateComponentJS(ChangeFileExt(ExtractFileName(FileName), ''), PascalToKebab(ChangeFileExt(ExtractFileName(FileName), '')), Parsed));
end;

procedure CmdTest;
var
  SR: TSearchRec;
  TestFiles: TStringList;
  i: Integer;
  GenPath, TestPath, UnitName, CorePath: string;
begin
  WriteLn('=== BlaiseVue Unit Testing ===');
  GenPath := GetCurrentDir + DirectorySeparator + 'generated' + DirectorySeparator + 'tests' + DirectorySeparator;
  TestPath := GetCurrentDir + DirectorySeparator + 'tests' + DirectorySeparator;
  CorePath := GetCorePath;
  
  ForceDir(GenPath);
  
  TestFiles := TStringList.Create;
  try
    if FindFirst(TestPath + '*.test.pas', faAnyFile, SR) = 0 then
    begin
      repeat
        TestFiles.Add(TestPath + SR.Name);
      until FindNext(SR) <> 0;
      FindClose(SR);
    end;
    
    if TestFiles.Count = 0 then
    begin
      WriteLn('No .test.pas files found in /tests');
      Exit;
    end;
    
    // Transpile all .bv to .pas first so tests can use them
    WriteLn('[1/3] Preparing components...');
    CmdTranspile;
    
    WriteLn('[2/3] Compiling ', TestFiles.Count, ' test file(s)...');
    for i := 0 to TestFiles.Count - 1 do
    begin
       UnitName := ChangeFileExt(ExtractFileName(TestFiles[i]), '.js');
       WriteLn('  - ', ExtractFileName(TestFiles[i]));
       ExecuteProcess('cmd', '/c "' + GetPas2JSPath + '" "@app.cfg" -Fu"' + CorePath + '" -Fu"' + GetPas2JSLibPath + '" "' + TestFiles[i] + '" -o"' + GenPath + UnitName + '" -O- -v > "' + GenPath + 'pas2js.log"');
       // NEW: Add rtl.run() for Vitest to execute the program module code
       WriteStringToFile(GenPath + UnitName, ReadFileToString(GenPath + UnitName) + #10 + 'rtl.run();' + #10);
    end;
    
    WriteLn('');
    WriteLn('[3/3] Running Vitest...');
    WriteLn('');
    
    {$IFDEF WINDOWS}
    ExecuteProcess('cmd', '/c npm test');
    {$ELSE}
    ExecuteProcess('npm', 'test');
    {$ENDIF}
    
  finally
    TestFiles.Free;
  end;
end;

// =====================================================================
//  MAIN ENTRY POINT
// =====================================================================

var
  Cmd: string;
begin
  if ParamCount < 1 then
  begin
    WriteLn('');
    WriteLn('  BlaiseVue CLI v1.0 PRO');
    WriteLn('  ======================');
    WriteLn('');
    WriteLn('  Usage:');
    WriteLn('    bv create <name>       Scaffolds a new project');
    WriteLn('    bv clean               Cleans generated files (generated/ and dist/)');
    WriteLn('    bv run dev             DEBUG build with timestamp (SFC -> Pas -> JS)');
    WriteLn('    bv run build           PRODUCTION build with hashes (SFC -> Pas -> JS)');
    WriteLn('    bv serve               Starts development server (server logs enabled)');
    WriteLn('    bv transpile           Generates only .pas files');
    WriteLn('    bv run preview         Tests the production build locally');
    WriteLn('    bv new c <Name>        Creates a new component');
    WriteLn('    bv new v <Name>        Creates a new view');
    WriteLn('    bv new t <Name>        Creates a new test file (.test.pas)');
    WriteLn('    bv remove c <Name>     Removes a component');
    WriteLn('    bv remove v <Name>     Removes a view');
    WriteLn('    bv remove t <Name>     Removes a test file');
    WriteLn('    bv list c              Lists components');
    WriteLn('    bv list v              Lists views');
    WriteLn('    bv list t              Lists test files');
    WriteLn('    bv lib list            Lists all installed components in lib/');
    WriteLn('    bv lib install <url>   Downloads and installs a component from a URL');
    WriteLn('    bv lib remove <name>    Removes an installed component from lib/');
    WriteLn('    bv s <name>            Runs setup script for a component in lib/');
    WriteLn('    bv test                Runs unit tests (.test.pas)');
    WriteLn('');
    Halt(0);
  end;

  Cmd := LowerCase(ParamStr(1));

  if Cmd = 'create' then
  begin
    if ParamCount < 2 then
    begin
      WriteLn('Usage: bv create <project-name>');
      Halt(1);
    end;
    CmdCreate(ParamStr(2));
  end
  else if Cmd = 'clean' then
  begin
    CmdClean;
  end
  else if Cmd = 'test' then
  begin
    CmdTest;
  end
  else if Cmd = 'build' then
  begin
    WriteLn('Warning: "bv build" has been renamed to "bv run dev".');
    CmdBuild;
  end
  else if Cmd = 'serve' then
  begin
    CmdServe;
  end
  else if Cmd = 'transpile' then
  begin
    CmdTranspile;
  end
  else if Cmd = 'new' then
  begin
    if (ParamCount < 3) then
    begin
      WriteLn('Usage: bv new <c|v|t> <Name>');
      Halt(1);
    end;
    if LowerCase(ParamStr(2)) = 'c' then
      CmdNewComponent(ParamStr(3))
    else if LowerCase(ParamStr(2)) = 'v' then
      CmdNewView(ParamStr(3))
    else if LowerCase(ParamStr(2)) = 't' then
      CmdNewTest(ParamStr(3))
    else
    begin
      WriteLn('Unknown type: ', ParamStr(2), '. Use "c" for component, "v" for view or "t" for test.');
      Halt(1);
    end;
  end
  else if Cmd = 'remove' then
  begin
    if (ParamCount < 3) then
    begin
      WriteLn('Usage: bv remove <c|v|t> <Name>');
      Halt(1);
    end;
    if LowerCase(ParamStr(2)) = 'c' then
      CmdRemoveComponent(ParamStr(3))
    else if LowerCase(ParamStr(2)) = 'v' then
      CmdRemoveView(ParamStr(3))
    else if LowerCase(ParamStr(2)) = 't' then
      CmdRemoveTest(ParamStr(3))
    else
    begin
      WriteLn('Unknown type: ', ParamStr(2), '. Use "c" for component, "v" for view or "t" for test.');
      Halt(1);
    end;
  end
  else if Cmd = 'list' then
  begin
    if (ParamCount < 2) then
    begin
      WriteLn('Usage: bv list <c|v|t|lib>');
      Halt(1);
    end;
    if (ParamStr(2) = 'lib') then
      CmdLibList
    else
      CmdList(ParamStr(2));
  end
  else if Cmd = 's' then
  begin
    if ParamCount < 2 then
    begin
       WriteLn('Usage: bv s <nome-do-componente>');
       Halt(1);
    end;
    CmdSetup(ParamStr(2));
  end
  else if Cmd = 'lib' then
  begin
    if (ParamCount < 2) then
    begin
       WriteLn('Usage: bv lib <list|install|remove> [params]');
       Halt(1);
    end;
    Cmd := LowerCase(ParamStr(2));
    if Cmd = 'list' then CmdLibList
    else if Cmd = 'install' then
    begin
       if ParamCount < 3 then begin WriteLn('Usage: bv lib install <url>'); Halt(1); end;
       CmdLibInstall(ParamStr(3));
    end
    else if Cmd = 'remove' then
    begin
       if ParamCount < 3 then begin WriteLn('Usage: bv lib remove <name>'); Halt(1); end;
       CmdLibRemove(ParamStr(3));
    end;
  end
  else if Cmd = 'run' then
  begin
    if ParamCount < 2 then
    begin
      WriteLn('Usage: bv run <build|dev|preview>');
      Halt(1);
    end;
    Cmd := LowerCase(ParamStr(2));
    if Cmd = 'build' then CmdRunBuild
    else if Cmd = 'dev' then CmdBuild // Old bv build is now bv run dev
    else if Cmd = 'preview' then CmdRunPreview
    else if Cmd = 'compile-sfc' then
    begin
      if ParamCount < 2 then Halt(1);
      CmdCompileSFC(ParamStr(2));
    end
    else
    begin
      WriteLn('Unknown run subcommand: ', Cmd);
      Halt(1);
    end;
  end
  else
  begin
    WriteLn('Unknown command: ', Cmd);
    WriteLn('Use "bv" without arguments for help.');
    Halt(1);
  end;
end.
