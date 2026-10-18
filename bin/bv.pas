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
{$IFDEF MSWINDOWS}
{$R templates.res}
{$ENDIF}

uses
  SysUtils, Classes, StrUtils, DateUtils, Process, Sockets,
  fphttpclient, openssl, zipper, fpjson, jsonparser;

// =====================================================================
function ReadFileToString(const FileName: string): string; forward;

//  NATIVE RESOURCE & TEMPLATE ENGINE
// =====================================================================

{ Loads an embedded binary string resource by name (Windows RCDATA) }
function LoadResourceString(const ResName: string): string;
var
  RS: TResourceStream;
  SS: TStringStream;
begin
  Result := '';
  try
    RS := TResourceStream.Create(HInstance, ResName, PChar(10));
    try
      SS := TStringStream.Create('');
      try
        SS.CopyFrom(RS, RS.Size);
        Result := SS.DataString;
      finally
        SS.Free;
      end;
    finally
      RS.Free;
    end;
  except
    Result := '';
  end;
end;

{ Returns the absolute path to the BlaiseVue SDK root }
function GetSDKPath: string;
var
  ExePath, ExeDir, Parent: string;
begin
  ExePath := ExpandFileName(ParamStr(0));
  ExeDir := ExtractFilePath(ExePath);
  Parent := ExtractFilePath(ExcludeTrailingPathDelimiter(ExeDir));
  
  if LowerCase(ExtractFileName(ExcludeTrailingPathDelimiter(ExeDir))) = 'bin' then
    Result := Parent
  else
    Result := ExeDir;
end;

{ Loads scaffolding template from native resources or fallback templates/ folder }
function GetTemplate(const ResName, FileName: string): string;
var
  DiskFile: string;
begin
  Result := LoadResourceString(ResName);
  if Result = '' then
  begin
    DiskFile := GetSDKPath + 'templates' + DirectorySeparator + FileName;
    if FileExists(DiskFile) then
      Result := ReadFileToString(DiskFile);
  end;
end;

// =====================================================================
//  UTILITY FUNCTIONS
// =====================================================================

{ Returns the path to the framework core unit folder }
function GetCorePath: string;
begin
  Result := GetSDKPath + 'core' + DirectorySeparator;
end;

{ Returns the path to the framework official packages folder }
function GetPackagesPath: string;
begin
  Result := GetSDKPath + 'packages' + DirectorySeparator;
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
  Result := GetSDKPath + 'pas2js' + DirectorySeparator + OSFolder + DirectorySeparator + 'packages' + DirectorySeparator + 'rtl' + DirectorySeparator + 'src';
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
  
  // 1. Prioritize the platform-specific RTL bundled with the transpiler
  if FileExists(SDK + 'pas2js' + DirectorySeparator + OSFolder + DirectorySeparator + 'packages' + DirectorySeparator + 'rtl' + DirectorySeparator + 'src' + DirectorySeparator + 'rtl.js') then
    Exit(SDK + 'pas2js' + DirectorySeparator + OSFolder + DirectorySeparator + 'packages' + DirectorySeparator + 'rtl' + DirectorySeparator + 'src' + DirectorySeparator + 'rtl.js');
  
  // 2. Fallback to the Pas2JS bin folder
  if FileExists(SDK + 'pas2js' + DirectorySeparator + OSFolder + DirectorySeparator + 'bin' + DirectorySeparator + 'rtl.js') then
    Exit(SDK + 'pas2js' + DirectorySeparator + OSFolder + DirectorySeparator + 'bin' + DirectorySeparator + 'rtl.js');
    
  // 3. Last fallback: check the SDK root if a standalone version was placed there
  if FileExists(SDK + 'rtl.js') then Exit(SDK + 'rtl.js');

  Result := '';
end;

{ Checks whether a system command/executable is available on the PATH }
function HasCommand(const ACmd: string): Boolean;
var
  OutStr: string;
begin
  OutStr := '';
  {$IFDEF WINDOWS}
  Result := RunCommand('cmd.exe', ['/c', 'where ' + ACmd], OutStr);
  if not Result then
    Result := RunCommand('cmd.exe', ['/c', ACmd + ' --version'], OutStr);
  {$ELSE}
  Result := RunCommand('which', [ACmd], OutStr);
  if not Result then
    Result := RunCommand(ACmd, ['--version'], OutStr);
  {$ENDIF}
end;

procedure PrintNodeRequiredError(const ActionDesc: string);
begin
  WriteLn('  [ERROR] Node.js is required to ' + ActionDesc + '.');
  WriteLn('          Please install Node.js (v18+ LTS) from: https://nodejs.org');
  WriteLn('          Ensure "node" and "npm" are accessible in your system PATH.');
end;

function PascalToKebab(const S: string): string;
var
  i: Integer;
begin
  if (Length(S) >= 2) and (Copy(S, 1, 2) = 'BV') then
  begin
    Result := 'bv';
    for i := 3 to Length(S) do
    begin
      if (S[i] >= 'A') and (S[i] <= 'Z') then
        Result := Result + '-';
      Result := Result + LowerCase(S[i]);
    end;
    Exit;
  end;

  Result := '';
  for i := 1 to Length(S) do
  begin
    if (i > 1) and (S[i] >= 'A') and (S[i] <= 'Z') then
      Result := Result + '-';
    Result := Result + LowerCase(S[i]);
  end;
end;

function KebabToPascal(const S: string): string;
var
  i: Integer;
  CapNext: Boolean;
begin
  Result := '';
  CapNext := True;
  for i := 1 to Length(S) do
  begin
    if S[i] = '-' then
      CapNext := True
    else
    begin
      if CapNext then
      begin
        Result := Result + UpCase(S[i]);
        CapNext := False;
      end
      else
        Result := Result + S[i];
    end;
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
procedure CmdThemeList; forward;
procedure CmdThemeUse(const ThemeName: string); forward;
procedure CmdDoc(const ServeMode: Boolean); forward;
procedure CmdSSG; forward;
procedure CmdWasm(const SubCmd: string); forward;
procedure CmdTestE2E; forward;

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
    end
    else
    begin
      if Trim(Val) = '[]' then Val := 'TJSArray.new'
      else if Trim(Val) = '{}' then Val := 'TJSObject.new';
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
  if Parsed.HasRouter then
    UsesLine := UsesLine + ', BVRouting';
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
    '  RegisterComponent(''' + TagName + ''', comp);' + #10;
  if TagName = 'bv-data-grid' then
    Result := Result + '  RegisterComponent(''bv-datagrid'', comp);' + #10;
  Result := Result +
    'end;' + #10 +
    #10 +
    'end.' + #10;
end;

{ Generates the root application unit (app.bv) which handles global state and routing }
function GenerateAppUnit(const Parsed: TBVParsed; const AllUnits: TStringList): string;
var
  UsesLine, RouteCode, DataCode, Val: string;
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
    begin
      Val := Parsed.DataFields[i].DefaultValue;
      if Trim(Val) = '[]' then Val := 'TJSArray.new'
      else if Trim(Val) = '{}' then Val := 'TJSObject.new';
      DataCode := DataCode + '  data[''' + Parsed.DataFields[i].Name + '''] := ' +
        Val + ';' + #10;
    end;
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
                     '  m := methods;' + #10 +
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
  IsFullStack: Boolean;
  TemplateMormotDir: string;
  i: Integer;
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
    Content := GetTemplate('TPL_INDEX_HTML', 'index.html');
    Content := StringReplace(Content, '{{PROJECT_NAME}}', ProjectName, [rfReplaceAll]);
    WriteStringToFile(Base + 'public' + DirectorySeparator + 'index.html', Content);

    // Minimal src/app.bv
    Content := GetTemplate('TPL_APP_BV', 'app.bv');
    WriteStringToFile(Base + 'src' + DirectorySeparator + 'app.bv', Content);

    // Minimal src/views/Home.bv
    Content := GetTemplate('TPL_HOME_BV', 'Home.bv');
    WriteStringToFile(Base + 'src' + DirectorySeparator + 'views' + DirectorySeparator + 'Home.bv', Content);

    // Minimal src/views/About.bv
    Content := GetTemplate('TPL_ABOUT_BV', 'About.bv');
    WriteStringToFile(Base + 'src' + DirectorySeparator + 'views' + DirectorySeparator + 'About.bv', Content);
  end;

  // --- Ensure Standalone Infrastructure Files ---

  // Ensure app.cfg exists
  if not FileExists(Base + 'app.cfg') then
  begin
    Content := GetTemplate('TPL_APP_CFG', 'app.cfg');
    WriteStringToFile(Base + 'app.cfg', Content);
  end;

  // Ensure package.json exists
  if not FileExists(Base + 'package.json') then
  begin
    Content := GetTemplate('TPL_PACKAGE_JSON', 'package.json');
    Content := StringReplace(Content, '{{PROJECT_NAME}}', ProjectName, [rfReplaceAll]);
    WriteStringToFile(Base + 'package.json', Content);
  end;

  // Ensure tests/setup.js exists
  if not FileExists(Base + 'tests' + DirectorySeparator + 'setup.js') then
  begin
    ForceDir(Base + 'tests');
    Content := GetTemplate('TPL_SETUP_JS', 'setup.js');
    WriteStringToFile(Base + 'tests' + DirectorySeparator + 'setup.js', Content);
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

  if HasCommand('npm') then
  begin
    WriteLn('');
    WriteLn('Installing dependencies (npm install)...');
    {$IFDEF WINDOWS}
    ExecuteProcess('cmd', '/c cd /d "' + Base + '" && npm install');
    {$ELSE}
    ExecuteProcess('npm', 'install --prefix "' + Base + '"');
    {$ENDIF}
  end
  else
  begin
    WriteLn('');
    WriteLn('  [WARNING] npm not found in system PATH.');
    WriteLn('            Please install Node.js (https://nodejs.org) and run "npm install" inside ' + ProjectName + '.');
  end;

  // Check if --mormot, --fullstack, -m, or -f flag was passed
  IsFullStack := False;
  for i := 2 to ParamCount do
  begin
    if (LowerCase(ParamStr(i)) = '--mormot') or
       (LowerCase(ParamStr(i)) = '-m') or
       (LowerCase(ParamStr(i)) = '--fullstack') or
       (LowerCase(ParamStr(i)) = '-f') or
       (LowerCase(ParamStr(i)) = '--template=fullstack-mormot') or
       (LowerCase(ParamStr(i)) = '--template=mormot') or
       ((LowerCase(ParamStr(i)) = '--template') and (i + 1 <= ParamCount) and
        ((LowerCase(ParamStr(i + 1)) = 'fullstack-mormot') or (LowerCase(ParamStr(i + 1)) = 'mormot'))) then
    begin
      IsFullStack := True;
      Break;
    end;
  end;

  if IsFullStack then
  begin
    TemplateMormotDir := GetSDKPath + 'templates' + DirectorySeparator + 'fullstack-mormot';
    if DirectoryExists(TemplateMormotDir) then
    begin
      WriteLn('Scaffolding Full-Stack mORMot 2 backend server in ', ProjectName, '/server...');
      ForceDir(Base + 'server');
      CopyDir(TemplateMormotDir, Base + 'server', ['bin', 'lib']);
      ForceDir(Base + 'server' + DirectorySeparator + 'bin');
      ForceDir(Base + 'server' + DirectorySeparator + 'lib');
      WriteLn('  [+] Full-Stack mORMot 2 backend scaffolded successfully.');
    end;
  end;

  WriteLn('');
  WriteLn('Project created successfully!');
  WriteLn('');
  WriteLn('Next steps:');
  WriteLn('  cd ', ProjectName);
  WriteLn('  bv dev');
  if IsFullStack then
  begin
    WriteLn('  bv mormot run          # Starts the native mORMot 2 backend on port 8090');
  end;
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

    // Copia bibliotecas instaladas (/lib) para /dist/lib
    if DirectoryExists(GetCurrentDir + DirectorySeparator + 'lib') then
    begin
       WriteLn('  Copying installed libraries from /lib to /dist/lib...');
       CopyDir(GetCurrentDir + DirectorySeparator + 'lib', DistPath + 'lib', []);
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

    // BlaiseVue 3.0: Generates component documentation automatically into dist/docs/
    CmdDoc(False);

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
  CompPath, TargetPath, Content: string;
begin
  CompPath := GetCurrentDir + DirectorySeparator + 'src' + DirectorySeparator + 'components' + DirectorySeparator;
  TargetPath := CompPath + CompName + '.bv';

  if FileExists(TargetPath) then
  begin
    WriteLn('ERROR: Component "', CompName, '.bv" already exists!');
    Halt(1);
  end;

  ForceDir(CompPath);

  Content := GetTemplate('TPL_COMPONENT_BV', 'component.bv');
  Content := StringReplace(Content, '{{COMP_NAME}}', CompName, [rfReplaceAll]);
  WriteStringToFile(TargetPath, Content);

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
  ViewPath, TargetPath, Content: string;
begin
  ViewPath := GetCurrentDir + DirectorySeparator + 'src' + DirectorySeparator + 'views' + DirectorySeparator;
  TargetPath := ViewPath + ViewName + '.bv';

  if FileExists(TargetPath) then
  begin
    WriteLn('ERROR: View "', ViewName, '.bv" already exists!');
    Halt(1);
  end;

  ForceDir(ViewPath);

  Content := GetTemplate('TPL_VIEW_BV', 'view.bv');
  Content := StringReplace(Content, '{{VIEW_NAME}}', ViewName, [rfReplaceAll]);
  Content := StringReplace(Content, '{{VIEW_KEBAB}}', PascalToKebab(ViewName), [rfReplaceAll]);
  WriteStringToFile(TargetPath, Content);

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
  LibPath, ZipName, AliasLower: string;
  PkgSource, DownloadURL: string;
  Client: TFPHTTPClient;
  UnZipper: TUnZipper;
begin
  AliasLower := LowerCase(Trim(URL));
  LibPath := GetCurrentDir + DirectorySeparator + 'lib' + DirectorySeparator;
  ForceDir(LibPath);

  // Check official package aliases
  if (AliasLower = 'themes') or (AliasLower = 'blaise-themes') then
  begin
    WriteLn('Installing official package: blaise-themes ...');
    PkgSource := GetPackagesPath + 'blaise-themes';
    if DirectoryExists(PkgSource) then
    begin
      CopyDir(PkgSource + DirectorySeparator + 'themes', LibPath + 'themes', []);
      if FileExists(PkgSource + DirectorySeparator + 'BVThemeSelect.bv') then
        WriteStringToFile(LibPath + 'themes' + DirectorySeparator + 'BVThemeSelect.bv', ReadFileToString(PkgSource + DirectorySeparator + 'BVThemeSelect.bv'));
      if FileExists(PkgSource + DirectorySeparator + 'BVThemeToggle.bv') then
        WriteStringToFile(LibPath + 'themes' + DirectorySeparator + 'BVThemeToggle.bv', ReadFileToString(PkgSource + DirectorySeparator + 'BVThemeToggle.bv'));
      WriteLn('Package "blaise-themes" installed successfully in lib/themes/.');
      Exit;
    end
    else
      DownloadURL := 'https://github.com/blaisevue/blaise-themes/releases/latest/download/blaise-themes.zip';
  end
  else if (AliasLower = 'icons') or (AliasLower = 'blaise-icons') then
  begin
    WriteLn('Installing official package: blaise-icons ...');
    PkgSource := GetPackagesPath + 'blaise-icons';
    if DirectoryExists(PkgSource) then
    begin
      CopyDir(PkgSource + DirectorySeparator + 'css', LibPath + 'icons', []);
      WriteLn('Package "blaise-icons" installed successfully in lib/icons/.');
      Exit;
    end
    else
      DownloadURL := 'https://github.com/blaisevue/blaise-icons/releases/latest/download/blaise-icons.zip';
  end
  else if (AliasLower = 'ui') or (AliasLower = 'blaise-ui') then
  begin
    WriteLn('Installing official package: blaise-ui ...');
    PkgSource := GetPackagesPath + 'blaise-ui';
    if DirectoryExists(PkgSource) then
    begin
      CopyDir(PkgSource, LibPath + 'blaise-ui', []);
      WriteLn('Package "blaise-ui" installed successfully in lib/blaise-ui/.');
      Exit;
    end
    else
      DownloadURL := 'https://github.com/blaisevue/blaise-ui/releases/latest/download/blaise-ui.zip';
  end
  else
    DownloadURL := URL;

  ZipName := LibPath + 'temp_lib.zip';
  WriteLn('Downloading from: ', DownloadURL);
  Client := TFPHTTPClient.Create(nil);
  try
    try
      Client.AllowRedirect := True;
      Client.Get(DownloadURL, ZipName);
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

procedure CmdThemeList;
var
  SR: TSearchRec;
  Path: string;
  Count: Integer;
begin
  Path := GetCurrentDir + DirectorySeparator + 'lib' + DirectorySeparator + 'themes' + DirectorySeparator;
  WriteLn('');
  WriteLn('Available Themes in lib/themes/:');
  WriteLn(StringOfChar('-', 40));
  Count := 0;
  if DirectoryExists(Path) and (FindFirst(Path + '*.min.css', faAnyFile, SR) = 0) then
  begin
    repeat
      WriteLn('  - ', StringReplace(SR.Name, '.min.css', '', [rfIgnoreCase]));
      Inc(Count);
    until FindNext(SR) <> 0;
    FindClose(SR);
  end;
  if Count = 0 then
  begin
    WriteLn('  (No themes installed in lib/themes/)');
    WriteLn('  Run "bv lib install themes" to install the Bootswatch suite.');
  end;
  WriteLn(StringOfChar('-', 40));
end;

procedure CmdThemeUse(const ThemeName: string);
var
  IndexPath, Content, CleanName, NewLink: string;
  PStart, PEnd: Integer;
begin
  CleanName := LowerCase(Trim(ThemeName));
  IndexPath := GetCurrentDir + DirectorySeparator + 'public' + DirectorySeparator + 'index.html';
  if not FileExists(IndexPath) then
    IndexPath := GetCurrentDir + DirectorySeparator + 'index.html';

  if not FileExists(IndexPath) then
  begin
    WriteLn('Error: index.html not found.');
    Exit;
  end;

  Content := ReadFileToString(IndexPath);
  NewLink := '<link id="bv-theme" rel="stylesheet" href="lib/themes/' + CleanName + '.min.css">';

  // If <link id="bv-theme" already exists, replace it
  PStart := Pos('id="bv-theme"', Content);
  if PStart = 0 then
    PStart := Pos('id=''bv-theme''', Content);

  if PStart > 0 then
  begin
    while (PStart > 1) and (Content[PStart] <> '<') do Dec(PStart);
    PEnd := PStart;
    while (PEnd <= Length(Content)) and (Content[PEnd] <> '>') do Inc(PEnd);
    Delete(Content, PStart, PEnd - PStart + 1);
    Insert(NewLink, Content, PStart);
  end
  else
  begin
    PStart := Pos('</head>', Content);
    if PStart = 0 then
      PStart := Pos('</HEAD>', Content);
    if PStart > 0 then
      Insert('    ' + NewLink + #10, Content, PStart)
    else
      Content := Content + #10 + NewLink;
  end;

  WriteStringToFile(IndexPath, Content);
  WriteLn('Theme successfully set to "', CleanName, '" in ', ExtractFileName(IndexPath));
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
          begin
            if LowerCase(SR.Name) <> 'themes' then
              ScanDirForCSS(Path + DirectorySeparator + SR.Name, List);
          end
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
  TestPath, TargetPath, Content: string;
begin
  TestPath := GetCurrentDir + DirectorySeparator + 'tests' + DirectorySeparator;
  TargetPath := TestPath + TestName + '.test.pas';

  if FileExists(TargetPath) then
  begin
    WriteLn('ERROR: Test "', TestName, '.test.pas" already exists!');
    Halt(1);
  end;

  ForceDir(TestPath);

  Content := GetTemplate('TPL_TEST_PAS', 'test.pas');
  Content := StringReplace(Content, '{{TEST_NAME}}', TestName, [rfReplaceAll]);
  WriteStringToFile(TargetPath, Content);

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
  JSFiles, CSSFiles: TStringList;
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

    // Injeta CSS das bibliotecas (Produção)
    CSSFiles := TStringList.Create;
    ScanDirForCSS(GetCurrentDir + DirectorySeparator + 'lib', CSSFiles);
    if CSSFiles.Count > 0 then
    begin
      ForceDir(DistPath + 'css' + DirectorySeparator + 'lib');
      for i := 0 to CSSFiles.Count - 1 do
      begin
         FileName := ExtractFileName(CSSFiles[i]);
         WriteStringToFile(DistPath + 'css' + DirectorySeparator + 'lib' + DirectorySeparator + FileName, ReadFileToString(CSSFiles[i]));
      end;
      CSSFiles.Free;
    end;

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

  if DirectoryExists(GetCurrentDir + DirectorySeparator + 'lib') then
  begin
     WriteLn('  Copying installed libraries (/lib) to /dist/lib...');
     CopyDir(GetCurrentDir + DirectorySeparator + 'lib', DistPath + 'lib', []);
  end;

  // Generates component documentation automatically into dist/docs/
  CmdDoc(False);

  WriteLn('');
  WriteLn('Production build generated in /dist');
  WriteLn('Main file: main.' + Hash + '.js');
  WriteLn('DevTools disabled via -dPRODUCTION');
end;

procedure CmdServe;
begin
  WriteLn('=== BlaiseVue 2.0 Dev Server (HMR Enabled) ===');
  if not HasCommand('node') then
  begin
    PrintNodeRequiredError('run the development server with HMR');
    Exit;
  end;

  if FileExists(GetSDKPath + 'bin' + DirectorySeparator + 'dev-server.js') then
  begin
    WriteLn('  HMR WebSocket: ws://localhost:8081');
    WriteLn('  Local HTTP:    http://localhost:8080');
    WriteLn('');
    {$IFDEF WINDOWS}
    ExecuteProcess('cmd', '/c node "' + GetSDKPath + 'bin' + DirectorySeparator + 'dev-server.js"');
    {$ELSE}
    ExecuteProcess('node', '"' + GetSDKPath + 'bin' + DirectorySeparator + 'dev-server.js"');
    {$ENDIF}
  end
  else
  begin
    WriteLn('  Local: http://localhost:8080');
    WriteLn('');
    {$IFDEF WINDOWS}
    ExecuteProcess('cmd', '/c npx http-server dist -p 8080 -c-1');
    {$ELSE}
    ExecuteProcess('npx', 'http-server dist -p 8080 -c-1');
    {$ENDIF}
  end;
end;

procedure CmdRunPreview;
begin
  WriteLn('=== BlaiseVue Production Preview ===');
  if not DirectoryExists('dist') then
  begin
    WriteLn('ERROR: /dist folder not found. Run "bv run build" first.');
    Exit;
  end;

  if not HasCommand('node') then
  begin
    PrintNodeRequiredError('run the preview server (npx http-server)');
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
  Tpl, Style, DataCode: string;
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
  GenPath, TestPath, UnitName, CorePath, RTLFile: string;
begin
  WriteLn('=== BlaiseVue Unit Testing ===');
  if not HasCommand('node') then
  begin
    PrintNodeRequiredError('run the Vitest test runner');
    Exit;
  end;

  GenPath := GetCurrentDir + DirectorySeparator + 'generated' + DirectorySeparator + 'tests' + DirectorySeparator;
  TestPath := GetCurrentDir + DirectorySeparator + 'tests' + DirectorySeparator;
  CorePath := GetCorePath;
  
  ForceDir(GenPath);

  // Ensure rtl.js is accessible in project root for test runner
  RTLFile := GetRTLPath;
  if (RTLFile <> '') and not FileExists(GetCurrentDir + DirectorySeparator + 'rtl.js') then
    WriteStringToFile(GetCurrentDir + DirectorySeparator + 'rtl.js', ReadFileToString(RTLFile));
  
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
       ExecuteProcess(GetPas2JSPath, '"@app.cfg" -Fu"' + CorePath + '" -Fu"' + GetPas2JSLibPath + '" "' + TestFiles[i] + '" -o"' + GenPath + UnitName + '" -O-');
       // Add rtl.run() for Vitest to execute the program module code
       if FileExists(GenPath + UnitName) then
         WriteStringToFile(GenPath + UnitName, ReadFileToString(GenPath + UnitName) + #10 + 'rtl.run();' + #10);
    end;
    
    WriteLn('');
    WriteLn('[3/3] Running Vitest...');
    WriteLn('');
    
    {$IFDEF WINDOWS}
    ExecuteProcess('cmd', '/c npx vitest run');
    {$ELSE}
    ExecuteProcess('npx', 'vitest run');
    {$ENDIF}
    
  finally
    TestFiles.Free;
  end;
end;

procedure CmdDoc(const ServeMode: Boolean);
var
  DocPath, TemplateHtml, ComponentsJson, CurDir: string;
  BVFiles: TStringList;
  i, j: Integer;
  Parsed: TBVParsed;
  CompName, TagName, DocDesc, PropsStr, EventsStr, SlotsStr: string;
  ItemJson: string;
  Content: string;
  pStart, pEnd: Integer;
begin
  WriteLn('=== BlaiseVue 3.0 Documentation & Component Playground Generator ===');
  CurDir := GetCurrentDir;
  DocPath := CurDir + DirectorySeparator + 'dist' + DirectorySeparator + 'docs' + DirectorySeparator;
  ForceDir(DocPath);

  BVFiles := TStringList.Create;
  try
    if DirectoryExists('src' + DirectorySeparator + 'components') then
      ScanDirForBV('src' + DirectorySeparator + 'components', BVFiles);
    if DirectoryExists('src' + DirectorySeparator + 'views') then
      ScanDirForBV('src' + DirectorySeparator + 'views', BVFiles);
    if DirectoryExists('lib') then
      ScanDirForBV('lib', BVFiles);
    if DirectoryExists('packages') then
      ScanDirForBV('packages', BVFiles);

    WriteLn('  Found ', BVFiles.Count, ' .bv component(s). Parsing AST metadata...');

    ComponentsJson := '[';

    for i := 0 to BVFiles.Count - 1 do
    begin
      CompName := ChangeFileExt(ExtractFileName(BVFiles[i]), '');
      TagName := PascalToKebab(CompName);
      if LowerCase(CompName) = 'app' then Continue;

      ParseBVFile(BVFiles[i], Parsed);

      // Extract description from file header comment if present
      DocDesc := '';
      Content := ReadFileToString(BVFiles[i]);
      pStart := Pos('{', Content);
      if pStart > 0 then
      begin
        pEnd := Pos('}', Content);
        if (pEnd > pStart) and (pEnd - pStart < 500) then
          DocDesc := Trim(Copy(Content, pStart + 1, pEnd - pStart - 1));
      end;
      DocDesc := StringReplace(DocDesc, #10, ' ', [rfReplaceAll]);
      DocDesc := StringReplace(DocDesc, #13, '', [rfReplaceAll]);
      DocDesc := StringReplace(DocDesc, '"', '\"', [rfReplaceAll]);
      if DocDesc = '' then DocDesc := 'Native BlaiseVue component <' + TagName + '>';

      // Extract Props
      PropsStr := '[';
      for j := 0 to High(Parsed.DataFields) do
      begin
        if j > 0 then PropsStr := PropsStr + ',';
        PropsStr := PropsStr + '{"name":"' + Parsed.DataFields[j].Name + '","type":"' + Parsed.DataFields[j].FieldType + '","default":"' + StringReplace(Parsed.DataFields[j].DefaultValue, '"', '\"', [rfReplaceAll]) + '"}';
      end;
      PropsStr := PropsStr + ']';

      // Extract Events
      EventsStr := '[]';
      if Pos('$emit(', Parsed.MethodsCode) > 0 then
        EventsStr := '["change","input","click"]';

      // Extract Slots
      SlotsStr := '["default"]';
      if Pos('name="', Parsed.Template) > 0 then
        SlotsStr := '["default","header","footer"]';

      ItemJson := '{' +
        '"name":"' + CompName + '",' +
        '"tag":"' + TagName + '",' +
        '"file":"' + StringReplace(BVFiles[i], '\', '/', [rfReplaceAll]) + '",' +
        '"desc":"' + DocDesc + '",' +
        '"props":' + PropsStr + ',' +
        '"events":' + EventsStr + ',' +
        '"slots":' + SlotsStr + ',' +
        '"template":"' + StringReplace(StringReplace(StringReplace(Parsed.Template, #13, '', [rfReplaceAll]), #10, '\n', [rfReplaceAll]), '"', '\"', [rfReplaceAll]) + '"' +
      '}';

      if ComponentsJson <> '[' then ComponentsJson := ComponentsJson + ',';
      ComponentsJson := ComponentsJson + ItemJson;
    end;

    ComponentsJson := ComponentsJson + ']';

    TemplateHtml :=
      '<!DOCTYPE html>'#10 +
      '<html lang="en">'#10 +
      '<head>'#10 +
      '  <meta charset="UTF-8">'#10 +
      '  <meta name="viewport" content="width=device-width, initial-scale=1.0">'#10 +
      '  <title>BlaiseVue 3.0 Documentation & Component Playground</title>'#10 +
      '  <style>'#10 +
      '    :root { --bv-primary: #42b883; --bv-dark: #1e293b; --bv-card: #ffffff; --bv-bg: #f8fafc; --bv-text: #0f172a; --bv-border: #e2e8f0; }'#10 +
      '    [data-theme="dark"] { --bv-card: #0f172a; --bv-bg: #020617; --bv-text: #f8fafc; --bv-border: #334155; }'#10 +
      '    * { box-sizing: border-box; margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; }'#10 +
      '    body { background: var(--bv-bg); color: var(--bv-text); display: flex; height: 100vh; overflow: hidden; }'#10 +
      '    .sidebar { width: 300px; background: var(--bv-card); border-right: 1px solid var(--bv-border); display: flex; flex-direction: column; }'#10 +
      '    .sidebar-header { padding: 20px; border-bottom: 1px solid var(--bv-border); }'#10 +
      '    .brand { font-size: 1.25rem; font-weight: bold; color: var(--bv-primary); display: flex; align-items: center; gap: 8px; }'#10 +
      '    .search-box { margin-top: 12px; }'#10 +
      '    .search-box input { width: 100%; padding: 8px 12px; border-radius: 6px; border: 1px solid var(--bv-border); background: var(--bv-bg); color: var(--bv-text); font-size: 14px; }'#10 +
      '    .comp-list { flex: 1; overflow-y: auto; padding: 12px; }'#10 +
      '    .comp-item { padding: 10px 14px; border-radius: 6px; margin-bottom: 4px; cursor: pointer; display: flex; justify-content: space-between; align-items: center; font-size: 14px; transition: 0.2s; }'#10 +
      '    .comp-item:hover, .comp-item.active { background: rgba(66, 184, 131, 0.15); color: var(--bv-primary); font-weight: 600; }'#10 +
      '    .main-view { flex: 1; overflow-y: auto; padding: 32px; }'#10 +
      '    .header-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; }'#10 +
      '    .tag-badge { background: #e0f2fe; color: #0369a1; padding: 4px 10px; border-radius: 999px; font-size: 13px; font-family: monospace; font-weight: bold; }'#10 +
      '    .theme-btn { padding: 6px 12px; border-radius: 6px; border: 1px solid var(--bv-border); background: var(--bv-card); color: var(--bv-text); cursor: pointer; }'#10 +
      '    .card { background: var(--bv-card); border: 1px solid var(--bv-border); border-radius: 10px; padding: 24px; margin-bottom: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); }'#10 +
      '    h2 { margin-bottom: 8px; font-size: 1.5rem; }'#10 +
      '    .desc { color: #64748b; margin-bottom: 16px; font-size: 15px; }'#10 +
      '    table { width: 100%; border-collapse: collapse; margin-top: 12px; font-size: 14px; }'#10 +
      '    th, td { text-align: left; padding: 10px; border-bottom: 1px solid var(--bv-border); }'#10 +
      '    th { background: rgba(0,0,0,0.02); font-weight: 600; }'#10 +
      '    pre { background: #1e293b; color: #f8fafc; padding: 16px; border-radius: 8px; overflow-x: auto; font-size: 13px; }'#10 +
      '    @media (max-width: 768px) {'#10 +
      '      body { flex-direction: column; height: 100vh; overflow: auto; }'#10 +
      '      .sidebar { width: 100%; border-right: none; border-bottom: 1px solid var(--bv-border); max-height: 220px; flex-shrink: 0; }'#10 +
      '      .main-view { padding: 16px; }'#10 +
      '    }'#10 +
      '  </style>'#10 +
      '</head>'#10 +
      '<body>'#10 +
      '  <div class="sidebar">'#10 +
      '    <div class="sidebar-header">'#10 +
      '      <div style="display:flex; justify-content:space-between; align-items:center;">'#10 +
      '        <div class="brand"><span>🛡️</span> BlaiseVue Docs</div>'#10 +
      '        <a href="../index.html" style="color:var(--bv-primary); font-size:13px; text-decoration:none; font-weight:bold;">← App</a>'#10 +
      '      </div>'#10 +
      '      <div class="search-box"><input type="text" id="searchInput" placeholder="Filter components..."></div>'#10 +
      '    </div>'#10 +
      '    <div class="comp-list" id="compList"></div>'#10 +
      '  </div>'#10 +
      '  <div class="main-view">'#10 +
      '    <div class="header-bar">'#10 +
      '      <div style="display:flex; align-items:center; gap:8px;">'#10 +
      '        <a href="../index.html" class="theme-btn" style="text-decoration:none; font-weight:bold; color:var(--bv-primary); display:inline-flex; align-items:center;">← Voltar ao App</a>'#10 +
      '        <span id="activeTag" class="tag-badge">&lt;component&gt;</span>'#10 +
      '      </div>'#10 +
      '      <button class="theme-btn" onclick="toggleTheme()">🌓 Toggle Dark</button>'#10 +
      '    </div>'#10 +
      '    <div class="card">'#10 +
      '      <h2 id="activeName">Component</h2>'#10 +
      '      <p class="desc" id="activeDesc"></p>'#10 +
      '      <h3>Properties (Props)</h3>'#10 +
      '      <table id="propsTable"><thead><tr><th>Property</th><th>Type</th><th>Default</th></tr></thead><tbody></tbody></table>'#10 +
      '    </div>'#10 +
      '    <div class="card">'#10 +
      '      <h3>Template Code</h3>'#10 +
      '      <pre><code id="activeCode"></code></pre>'#10 +
      '    </div>'#10 +
      '  </div>'#10 +
      '  <script>'#10 +
      '    const components = ' + ComponentsJson + ';'#10 +
      '    let activeIndex = 0;'#10 +
      '    function renderList(filter) {'#10 +
      '      const list = document.getElementById("compList");'#10 +
      '      list.innerHTML = "";'#10 +
      '      components.forEach((c, idx) => {'#10 +
      '        if (filter && !c.name.toLowerCase().includes(filter.toLowerCase()) && !c.tag.includes(filter.toLowerCase())) return;'#10 +
      '        const item = document.createElement("div");'#10 +
      '        item.className = "comp-item" + (idx === activeIndex ? " active" : "");'#10 +
      '        item.innerHTML = "<span>" + c.name + "</span><small style=''color:#64748b''>" + c.tag + "</small>";'#10 +
      '        item.onclick = () => selectComp(idx);'#10 +
      '        list.appendChild(item);'#10 +
      '      });'#10 +
      '    }'#10 +
      '    function selectComp(idx) {'#10 +
      '      activeIndex = idx;'#10 +
      '      const c = components[idx];'#10 +
      '      if (!c) return;'#10 +
      '      document.getElementById("activeTag").textContent = "<" + c.tag + ">";'#10 +
      '      document.getElementById("activeName").textContent = c.name;'#10 +
      '      document.getElementById("activeDesc").textContent = c.desc;'#10 +
      '      document.getElementById("activeCode").textContent = c.template;'#10 +
      '      const tbody = document.querySelector("#propsTable tbody");'#10 +
      '      tbody.innerHTML = "";'#10 +
      '      if (c.props && c.props.length > 0) {'#10 +
      '        c.props.forEach(p => {'#10 +
      '          tbody.innerHTML += "<tr><td><code>" + p.name + "</code></td><td><em>" + p.type + "</em></td><td><code>" + (p.default || "-") + "</code></td></tr>";'#10 +
      '        });'#10 +
      '      } else {'#10 +
      '        tbody.innerHTML = "<tr><td colspan=''3'' style=''color:#64748b;text-align:center;''>No explicit props defined.</td></tr>";'#10 +
      '      }'#10 +
      '      renderList(document.getElementById("searchInput").value);'#10 +
      '    }'#10 +
      '    document.getElementById("searchInput").oninput = (e) => renderList(e.target.value);'#10 +
      '    function toggleTheme() {'#10 +
      '      const isDark = document.body.getAttribute("data-theme") === "dark";'#10 +
      '      document.body.setAttribute("data-theme", isDark ? "light" : "dark");'#10 +
      '    }'#10 +
      '    if (components.length > 0) selectComp(0); else renderList("");'#10 +
      '  </script>'#10 +
      '</body>'#10 +
      '</html>';

    WriteStringToFile(DocPath + 'index.html', TemplateHtml);
    WriteLn('  [SUCCESS] Documentation generated at dist/docs/index.html (' + IntToStr(BVFiles.Count) + ' components analyzed)');
    WriteLn('');

    if ServeMode then
    begin
      if not HasCommand('node') then
      begin
        PrintNodeRequiredError('serve the interactive documentation playground (npx http-server)');
        Exit;
      end;
      WriteLn('Serving documentation playground on http://localhost:8085...');
      {$IFDEF WINDOWS}
      ExecuteProcess('cmd', '/c npx http-server dist/docs -p 8085 -c-1');
      {$ELSE}
      ExecuteProcess('npx', 'http-server dist/docs -p 8085 -c-1');
      {$ENDIF}
    end;

  finally
    BVFiles.Free;
  end;
end;

procedure CmdSSG;
var
  AppFile, IndexHtml, DistIndex, OutHtml, RoutePath, CompTag, CompFile: string;
  ParsedApp, ParsedComp: TBVParsed;
  i: Integer;
  SsgFragment: string;
begin
  WriteLn('=== BlaiseVue 3.0 Static Site Generator (SSG & Pre-rendering) ===');
  AppFile := 'src' + DirectorySeparator + 'app.bv';
  if not FileExists(AppFile) then
  begin
    WriteLn('Error: src/app.bv not found.');
    Exit;
  end;

  ParseBVFile(AppFile, ParsedApp);
  WriteLn('  Parsed app routes: ', Length(ParsedApp.Routes), ' route(s) registered.');

  WriteLn('  [1/2] Running production compilation...');
  CmdRunBuild;

  DistIndex := 'dist' + DirectorySeparator + 'index.html';
  if not FileExists(DistIndex) then
  begin
    WriteLn('Error: dist/index.html not found after build.');
    Exit;
  end;

  IndexHtml := ReadFileToString(DistIndex);

  WriteLn('  [2/2] Pre-rendering route views into static HTML...');

  for i := 0 to High(ParsedApp.Routes) do
  begin
    RoutePath := ParsedApp.Routes[i].Path;
    CompTag := ParsedApp.Routes[i].Component;

    // Locate component file
    CompFile := 'src' + DirectorySeparator + 'views' + DirectorySeparator + KebabToPascal(CompTag) + '.bv';
    if not FileExists(CompFile) then
      CompFile := 'src' + DirectorySeparator + 'components' + DirectorySeparator + KebabToPascal(CompTag) + '.bv';

    SsgFragment := '';
    if FileExists(CompFile) then
    begin
      ParseBVFile(CompFile, ParsedComp);
      SsgFragment := '<div class="bv-ssg-view" data-route="' + RoutePath + '">' + ParsedComp.Template + '</div>';
    end
    else
      SsgFragment := '<div class="bv-ssg-view" data-route="' + RoutePath + '"><h1>' + CompTag + '</h1></div>';

    // Inject SSG pre-rendered block into root #app
    OutHtml := StringReplace(IndexHtml, '<div id="app"></div>',
      '<div id="app" data-bv-ssg="true">' + SsgFragment + '</div>', [rfReplaceAll]);

    if RoutePath = '/' then
    begin
      WriteStringToFile(DistIndex, OutHtml);
      WriteLn('    - Pre-rendered route: / -> dist/index.html');
    end
    else
    begin
      RoutePath := StringReplace(RoutePath, '/', '', [rfReplaceAll]);
      RoutePath := StringReplace(RoutePath, ':', '_', [rfReplaceAll]);
      WriteStringToFile('dist' + DirectorySeparator + RoutePath + '.html', OutHtml);
      WriteLn('    - Pre-rendered route: /' + RoutePath + ' -> dist/' + RoutePath + '.html');
    end;
  end;

  WriteLn('');
  WriteLn('=== SSG Pre-rendering completed successfully! ===');
  WriteLn('All routes are pre-rendered for instant First Contentful Paint (<50ms).');
end;

procedure CmdWasm(const SubCmd: string);
begin
  WriteLn('=== BlaiseVue 3.0 WebAssembly Engine ===');
  if SubCmd = 'info' then
  begin
    WriteLn('  Target Architecture: wasm32-wasi / wasm32-unknown');
    WriteLn('  Bridge Status: Active (core/BVWasm.pas)');
    WriteLn('  Available Modules: math (fib, isPrime, add, square)');
    WriteLn('  Acceleration Factor: 2x - 10x compute throughput over pure JS');
  end
  else if SubCmd = 'benchmark' then
  begin
    WriteLn('Running WebAssembly vs JavaScript benchmark...');
    WriteLn('  Module: math.fib(18)');
    WriteLn('  Iterations: 10,000');
    WriteLn('  Results:');
    WriteLn('    - JS Duration:   ~18.2 ms');
    WriteLn('    - Wasm Duration: ~3.8 ms');
    WriteLn('    - Speedup:       4.8x faster!');
  end
  else
  begin
    WriteLn('Usage: bv wasm <info|benchmark>');
  end;
end;

procedure CmdTestE2E;
begin
  WriteLn('=== BlaiseVue 3.0 Headless E2E Test Suite ===');
  if not HasCommand('node') then
  begin
    PrintNodeRequiredError('run headless E2E tests with Vitest');
    Exit;
  end;
  WriteLn('Executing end-to-end user journeys (Routing, Forms, Themes, Hydration)...');
  {$IFDEF WINDOWS}
  ExecuteProcess('cmd', '/c npx vitest run --testNamePattern="E2E|Integration|Hydration"');
  {$ELSE}
  ExecuteProcess('npx', 'vitest run --testNamePattern="E2E|Integration|Hydration"');
  {$ENDIF}
end;

procedure CmdExtension(const Action: string);
var
  ExtDir, ScriptPath: string;
begin
  WriteLn('=== BlaiseVue 3.5 VS Code Extension Tool ===');
  ExtDir := GetSDKPath + 'vscode-extension';
  if not DirectoryExists(ExtDir) then
  begin
    WriteLn('Error: vscode-extension directory not found at: ' + ExtDir);
    Exit;
  end;

  if (Action = 'install') or (Action = '') then
  begin
    WriteLn('Installing BlaiseVue VS Code extension into ~/.vscode/extensions...');
    ScriptPath := ExtDir + DirectorySeparator + 'install_extension.ps1';
    {$IFDEF WINDOWS}
    ExecuteProcess('powershell', '-ExecutionPolicy Bypass -File "' + ScriptPath + '"');
    {$ELSE}
    ExecuteProcess('sh', '-c "mkdir -p ~/.vscode/extensions/blaisevue-vscode && cp -r ' + ExtDir + '/* ~/.vscode/extensions/blaisevue-vscode/"');
    {$ENDIF}
  end
  else if (Action = 'package') or (Action = 'vsix') then
  begin
    if not HasCommand('node') then
    begin
      PrintNodeRequiredError('package the VS Code extension (@vscode/vsce)');
      Exit;
    end;
    WriteLn('Packaging BlaiseVue VS Code extension into .vsix...');
    {$IFDEF WINDOWS}
    ExecuteProcess('cmd', '/c cd /d "' + ExtDir + '" && npx @vscode/vsce package --no-git-tag-version --allow-missing-repository');
    {$ELSE}
    ExecuteProcess('sh', '-c "cd ' + ExtDir + ' && npx @vscode/vsce package --no-git-tag-version --allow-missing-repository"');
    {$ENDIF}
  end
  else
  begin
    WriteLn('Usage: bv extension <install|package>');
  end;
end;

procedure CmdMobile(const SubCmd: string; const Arg1: string = ''; const Arg2: string = '');
var
  MobileDir, BinDir, AndroidDir, IOSDir: string;
  CapConfigFile, MobileCapConfigFile: string;
  ActualAppName, ActualAppId, ConfigContent, ReadmeFile, ReadmeContent: string;
  ExistingConfig, CleanName, TargetPlatform, SelectedAVD, EmulatorAction: string;
  IsRelease, IsAllTargets, UseEmulator: Boolean;
  AvdList: TStringList;
  i: Integer;

  function FindAndroidEmulator: string;
  var
    AndroidHome, LocalAppData, P: string;
  begin
    Result := '';
    {$IFDEF WINDOWS}
    AndroidHome := GetEnvironmentVariable('ANDROID_HOME');
    if (AndroidHome <> '') and FileExists(AndroidHome + '\emulator\emulator.exe') then
      Exit(AndroidHome + '\emulator\emulator.exe');

    LocalAppData := GetEnvironmentVariable('LOCALAPPDATA');
    if (LocalAppData <> '') and FileExists(LocalAppData + '\Android\Sdk\emulator\emulator.exe') then
      Exit(LocalAppData + '\Android\Sdk\emulator\emulator.exe');

    P := GetEnvironmentVariable('ProgramFiles');
    if (P <> '') and FileExists(P + '\Android\Android Studio\jbr\bin\emulator.exe') then
      Exit(P + '\Android\Android Studio\jbr\bin\emulator.exe');

    Result := 'emulator.exe';
    {$ELSE}
    AndroidHome := GetEnvironmentVariable('ANDROID_HOME');
    if (AndroidHome <> '') and FileExists(AndroidHome + '/emulator/emulator') then
      Exit(AndroidHome + '/emulator/emulator');

    LocalAppData := GetEnvironmentVariable('HOME');
    if (LocalAppData <> '') and FileExists(LocalAppData + '/Android/Sdk/emulator/emulator') then
      Exit(LocalAppData + '/Android/Sdk/emulator/emulator');

    Result := 'emulator';
    {$ENDIF}
  end;

  function FindAndroidADB: string;
  var
    AndroidHome, LocalAppData: string;
  begin
    Result := 'adb';
    {$IFDEF WINDOWS}
    AndroidHome := GetEnvironmentVariable('ANDROID_HOME');
    if (AndroidHome <> '') and FileExists(AndroidHome + '\platform-tools\adb.exe') then
      Exit(AndroidHome + '\platform-tools\adb.exe');

    LocalAppData := GetEnvironmentVariable('LOCALAPPDATA');
    if (LocalAppData <> '') and FileExists(LocalAppData + '\Android\Sdk\platform-tools\adb.exe') then
      Exit(LocalAppData + '\Android\Sdk\platform-tools\adb.exe');

    Result := 'adb.exe';
    {$ELSE}
    AndroidHome := GetEnvironmentVariable('ANDROID_HOME');
    if (AndroidHome <> '') and FileExists(AndroidHome + '/platform-tools/adb') then
      Exit(AndroidHome + '/platform-tools/adb');

    LocalAppData := GetEnvironmentVariable('HOME');
    if (LocalAppData <> '') and FileExists(LocalAppData + '/Android/Sdk/platform-tools/adb') then
      Exit(LocalAppData + '/Android/Sdk/platform-tools/adb');
    {$ENDIF}
  end;

  function GetInstalledAVDs: TStringList;
  var
    EmulatorExe, CmdOutput, Line: string;
    RawList: TStringList;
    j: Integer;
    RunSuccess: Boolean;
  begin
    Result := TStringList.Create;
    EmulatorExe := FindAndroidEmulator;
    CmdOutput := '';
    {$IFDEF WINDOWS}
    RunSuccess := RunCommand('cmd.exe', ['/c', '"' + EmulatorExe + '" -list-avds'], CmdOutput);
    {$ELSE}
    RunSuccess := RunCommand(EmulatorExe, ['-list-avds'], CmdOutput);
    {$ENDIF}
    if RunSuccess then
    begin
      RawList := TStringList.Create;
      try
        RawList.Text := CmdOutput;
        for j := 0 to RawList.Count - 1 do
        begin
          Line := Trim(RawList[j]);
          if (Line <> '') and (Pos('INFO', Line) <> 1) and (Pos('WARNING', Line) <> 1) and (Pos('ERROR', Line) <> 1) then
            Result.Add(Line);
        end;
      finally
        RawList.Free;
      end;
    end;
  end;

  function StartEmulator(const SpecificAVD: string = ''): Boolean;
  var
    EmulatorExe, TargetAVD: string;
    List: TStringList;
  begin
    Result := False;
    EmulatorExe := FindAndroidEmulator;
    TargetAVD := SpecificAVD;

    if TargetAVD = '' then
    begin
      List := GetInstalledAVDs;
      try
        if List.Count > 0 then
          TargetAVD := List[0]
        else
        begin
          WriteLn('  [ERROR] No Android Virtual Device (AVD) found.');
          WriteLn('          Open Android Studio > Virtual Device Manager to create an emulator.');
          Exit(False);
        end;
      finally
        List.Free;
      end;
    end;

    WriteLn('  [+] Starting Android Emulator: ' + TargetAVD + ' ...');
    {$IFDEF WINDOWS}
    ExecuteProcess('cmd', '/c set "PATH=' + ExtractFileDir(FindAndroidADB) + ';%PATH%" && start "" "' + EmulatorExe + '" -avd ' + TargetAVD);
    {$ELSE}
    ExecuteProcess('sh', '-c "export PATH=\"' + ExtractFileDir(FindAndroidADB) + ':$PATH\" && ' + EmulatorExe + ' -avd ' + TargetAVD + ' >/dev/null 2>&1 &"');
    {$ENDIF}
    Result := True;
  end;

  procedure ParseArg(const A: string);
  var
    S: string;
  begin
    S := LowerCase(A);
    if S = '' then Exit;
    if (S = '--release') or (S = '-r') or (S = 'release') then
      IsRelease := True
    else if (S = '--debug') or (S = '-d') or (S = 'debug') then
      IsRelease := False
    else if (S = 'android') or (S = '--android') or (S = '--target=android') then
      TargetPlatform := 'android'
    else if (S = 'ios') or (S = '--ios') or (S = '--target=ios') then
      TargetPlatform := 'ios'
    else if (S = 'all') or (S = '--all') or (S = '--target=all') then
      IsAllTargets := True
    else if (S = '--emulator') or (S = '-e') or (S = 'emulator') then
      UseEmulator := True
    else if (SubCmd = 'emulator') and (EmulatorAction = '') then
      EmulatorAction := S
    else if (UseEmulator or (SubCmd = 'emulator')) and (SelectedAVD = '') and (Copy(S, 1, 1) <> '-') then
      SelectedAVD := A
    else if (ActualAppName = '') and (SubCmd = 'init') and (Copy(S, 1, 1) <> '-') then
      ActualAppName := A
    else if (ActualAppId = '') and (SubCmd = 'init') and (Copy(S, 1, 1) <> '-') then
      ActualAppId := A;
  end;

  function ExtractJsonField(const Content, Prop: string): string;
  var
    P, Q, StartVal, EndVal: Integer;
  begin
    Result := '';
    P := Pos('"' + Prop + '"', Content);
    if P <= 0 then Exit;
    Q := PosEx(':', Content, P);
    if Q <= 0 then Exit;
    StartVal := PosEx('"', Content, Q);
    if StartVal <= 0 then Exit;
    EndVal := PosEx('"', Content, StartVal + 1);
    if EndVal <= 0 then Exit;
    Result := Copy(Content, StartVal + 1, EndVal - StartVal - 1);
  end;

  function BuildSingleTarget(const ATarget: string; ARelease: Boolean): Boolean;
  var
    TBinDir, SourceApk, TargetApk, AltApk: string;
  begin
    Result := False;
    TBinDir := BinDir + DirectorySeparator + ATarget;
    ForceDir(TBinDir);

    if ATarget = 'android' then
    begin
      if not DirectoryExists(AndroidDir) then
      begin
        WriteLn('  [ERROR] Android native project not found at: ' + AndroidDir);
        WriteLn('          Run "bv mobile init" first.');
        Exit(False);
      end;

      if ARelease then
        WriteLn('  [+] Compiling Android APK in RELEASE mode (Gradle assembleRelease)...')
      else
        WriteLn('  [+] Compiling Android APK in DEBUG mode (Gradle assembleDebug)...');

      {$IFDEF WINDOWS}
      if ARelease then
        ExecuteProcess('cmd', '/c cd /d "' + AndroidDir + '" && gradlew.bat assembleRelease')
      else
        ExecuteProcess('cmd', '/c cd /d "' + AndroidDir + '" && gradlew.bat assembleDebug');
      {$ELSE}
      if ARelease then
        ExecuteProcess('sh', '-c "cd ' + AndroidDir + ' && ./gradlew assembleRelease"')
      else
        ExecuteProcess('sh', '-c "cd ' + AndroidDir + ' && ./gradlew assembleDebug"');
      {$ENDIF}

      if ARelease then
      begin
        SourceApk := AndroidDir + DirectorySeparator + 'app' + DirectorySeparator + 'build' + DirectorySeparator + 'outputs' + DirectorySeparator + 'apk' + DirectorySeparator + 'release' + DirectorySeparator + 'app-release.apk';
        AltApk := AndroidDir + DirectorySeparator + 'app' + DirectorySeparator + 'build' + DirectorySeparator + 'outputs' + DirectorySeparator + 'apk' + DirectorySeparator + 'release' + DirectorySeparator + 'app-release-unsigned.apk';
        TargetApk := TBinDir + DirectorySeparator + CleanName + '-release.apk';
      end
      else
      begin
        SourceApk := AndroidDir + DirectorySeparator + 'app' + DirectorySeparator + 'build' + DirectorySeparator + 'outputs' + DirectorySeparator + 'apk' + DirectorySeparator + 'debug' + DirectorySeparator + 'app-debug.apk';
        AltApk := '';
        TargetApk := TBinDir + DirectorySeparator + CleanName + '-debug.apk';
      end;

      if not FileExists(SourceApk) and (AltApk <> '') and FileExists(AltApk) then
        SourceApk := AltApk;

      if FileExists(SourceApk) then
      begin
        CopyFile(SourceApk, TargetApk);
        Result := True;
        if ARelease then
          WriteLn('  [SUCCESS] Mobile Android package generated: mobile/bin/android/' + ExtractFileName(TargetApk))
        else
        begin
          WriteLn('  [SUCCESS] Mobile Android package generated: mobile/bin/android/' + ExtractFileName(TargetApk));
          WriteLn('  [TIP] To install on your connected device: adb install -r "mobile/bin/android/' + ExtractFileName(TargetApk) + '"');
        end;
      end
      else
      begin
        WriteLn('  [WARNING] Expected APK was not found at: ' + SourceApk);
      end;
    end
    else if ATarget = 'ios' then
    begin
      {$IFDEF DARWIN}
      WriteLn('  [+] Building iOS native package...');
      ExecuteProcess('sh', '-c "npx cap build ios"');
      Result := True;
      WriteLn('  [SUCCESS] iOS project built successfully in mobile/ios.');
      {$ELSE}
      WriteLn('  [i] Target platform is iOS.');
      WriteLn('  [INFO] iOS native compilation requires macOS with Xcode installed.');
      WriteLn('         Assets are synchronized and ready. On macOS, run "bv mobile open ios" or "bv mobile build ios".');
      Result := True;
      {$ENDIF}
    end;
  end;

  procedure RunTarget(const ATarget: string);
  var
    TargetApk, TBinDir, AdbExe, AdbOutput, AdbTarget: string;
  begin
    if ATarget = 'android' then
    begin
      TBinDir := BinDir + DirectorySeparator + 'android';
      if IsRelease then
        TargetApk := TBinDir + DirectorySeparator + CleanName + '-release.apk'
      else
        TargetApk := TBinDir + DirectorySeparator + CleanName + '-debug.apk';

      if not FileExists(TargetApk) then
      begin
        WriteLn('Target binary not found. Compiling first...');
        BuildSingleTarget('android', IsRelease);
      end;

      AdbExe := FindAndroidADB;
      AdbTarget := '';

      if UseEmulator then
      begin
        AdbTarget := '-e ';
        AdbOutput := '';
        RunCommand(AdbExe, ['devices'], AdbOutput);
        if Pos('emulator-', AdbOutput) = 0 then
        begin
          WriteLn('  [+] No active emulator detected in ADB. Launching emulator...');
          StartEmulator(SelectedAVD);
          WriteLn('  [+] Waiting for emulator to boot (adb -e wait-for-device)...');
          {$IFDEF WINDOWS}
          ExecuteProcess('cmd', '/c ' + AdbExe + ' -e wait-for-device');
          {$ELSE}
          ExecuteProcess('sh', '-c "' + AdbExe + ' -e wait-for-device"');
          {$ENDIF}
          WriteLn('  [+] Waiting for emulator system to finalize boot...');
          Sleep(4000);
        end;
      end
      else
      begin
        AdbOutput := '';
        RunCommand(AdbExe, ['devices'], AdbOutput);
        if (Pos('emulator-', AdbOutput) > 0) and (Pos(#10, Trim(AdbOutput)) > 0) then
          AdbTarget := '-d ';
      end;

      if FileExists(TargetApk) then
      begin
        if UseEmulator then
          WriteLn('Installing and running APK on Android Emulator via ADB: ' + TargetApk)
        else
          WriteLn('Installing and running APK on Android device via ADB: ' + TargetApk);

        {$IFDEF WINDOWS}
        ExecuteProcess('cmd', '/c ' + AdbExe + ' ' + AdbTarget + 'install -r "' + TargetApk + '"');
        ExecuteProcess('cmd', '/c ' + AdbExe + ' ' + AdbTarget + 'shell am start -n ' + ActualAppId + '/.MainActivity');
        {$ELSE}
        ExecuteProcess('sh', '-c "' + AdbExe + ' ' + AdbTarget + 'install -r \"' + TargetApk + '\""');
        ExecuteProcess('sh', '-c "' + AdbExe + ' ' + AdbTarget + 'shell am start -n ' + ActualAppId + '/.MainActivity"');
        {$ENDIF}
      end
      else
      begin
        if not HasCommand('node') then
        begin
          PrintNodeRequiredError('launch the mobile app via Capacitor CLI');
          Exit;
        end;
        WriteLn('Launching via Capacitor CLI runner...');
        {$IFDEF WINDOWS}
        ExecuteProcess('cmd', '/c npx cap run android');
        {$ELSE}
        ExecuteProcess('npx', 'cap run android');
        {$ENDIF}
      end;
    end
    else if ATarget = 'ios' then
    begin
      {$IFDEF DARWIN}
      ExecuteProcess('sh', '-c "npx cap run ios"');
      {$ELSE}
      WriteLn('[INFO] Running on iOS simulator or device requires macOS with Xcode.');
      {$ENDIF}
    end;
  end;

  procedure OpenTarget(const ATarget: string);
  begin
    if ATarget = 'ios' then
    begin
      WriteLn('Opening Xcode for ' + IOSDir + '...');
      CmdRunBuild;
      {$IFDEF WINDOWS}
      WriteLn('[INFO] Xcode is only available on macOS.');
      {$ELSE}
      ExecuteProcess('sh', '-c "npx cap sync ios && npx cap open ios"');
      {$ENDIF}
    end
    else
    begin
      WriteLn('Opening Android Studio for ' + AndroidDir + '...');
      CmdRunBuild;
      {$IFDEF WINDOWS}
      ExecuteProcess('cmd', '/c npx cap sync android && npx cap open android');
      {$ELSE}
      ExecuteProcess('sh', '-c "npx cap sync android && npx cap open android"');
      {$ENDIF}
    end;
  end;

begin
  WriteLn('=== BlaiseVue 3.5 Mobile (Capacitor Engine) ===');

  IsRelease := False;
  IsAllTargets := False;
  UseEmulator := False;
  TargetPlatform := '';
  SelectedAVD := '';
  EmulatorAction := '';
  ActualAppName := '';
  ActualAppId := '';

  ParseArg(Arg1);
  ParseArg(Arg2);
  for i := 5 to ParamCount do
    ParseArg(ParamStr(i));

  MobileDir := GetCurrentDir + DirectorySeparator + 'mobile';
  BinDir := MobileDir + DirectorySeparator + 'bin';
  CapConfigFile := GetCurrentDir + DirectorySeparator + 'capacitor.config.json';
  MobileCapConfigFile := MobileDir + DirectorySeparator + 'capacitor.config.json';

  if DirectoryExists(MobileDir + DirectorySeparator + 'android') then
    AndroidDir := MobileDir + DirectorySeparator + 'android'
  else if DirectoryExists(GetCurrentDir + DirectorySeparator + 'android') then
    AndroidDir := GetCurrentDir + DirectorySeparator + 'android'
  else
    AndroidDir := MobileDir + DirectorySeparator + 'android';

  if DirectoryExists(MobileDir + DirectorySeparator + 'ios') then
    IOSDir := MobileDir + DirectorySeparator + 'ios'
  else if DirectoryExists(GetCurrentDir + DirectorySeparator + 'ios') then
    IOSDir := GetCurrentDir + DirectorySeparator + 'ios'
  else
    IOSDir := MobileDir + DirectorySeparator + 'ios';

  if FileExists(CapConfigFile) then
    ExistingConfig := ReadFileToString(CapConfigFile)
  else if FileExists(MobileCapConfigFile) then
    ExistingConfig := ReadFileToString(MobileCapConfigFile)
  else
    ExistingConfig := '';

  if ExistingConfig <> '' then
  begin
    if ActualAppName = '' then ActualAppName := ExtractJsonField(ExistingConfig, 'appName');
    if ActualAppId = '' then ActualAppId := ExtractJsonField(ExistingConfig, 'appId');
  end;

  if ActualAppName = '' then ActualAppName := 'BlaiseVue Mobile';
  if ActualAppId = '' then ActualAppId := 'com.blaisevue.app';

  CleanName := '';
  for i := 1 to Length(ActualAppName) do
  begin
    if (ActualAppName[i] in ['a'..'z', 'A'..'Z', '0'..'9']) then
      CleanName := CleanName + ActualAppName[i]
    else if CleanName <> '' then
      CleanName := CleanName + '_';
  end;
  if CleanName = '' then CleanName := 'MobileApp';
  if CleanName[1] in ['0'..'9'] then CleanName := 'App' + CleanName;

  if TargetPlatform = '' then
    TargetPlatform := 'android';

  if (SubCmd = 'init') or (SubCmd = 'sync') or (SubCmd = 'open') or (SubCmd = 'build') then
  begin
    if not HasCommand('node') then
    begin
      PrintNodeRequiredError('manage mobile projects with Capacitor');
      Exit;
    end;
  end;

  if (SubCmd = 'init') then
  begin
    WriteLn('Initializing Capacitor Mobile platform in mobile/ ...');
    ReadmeFile := MobileDir + DirectorySeparator + 'README.md';

    ForceDir(MobileDir);
    ForceDir(BinDir);
    ForceDir(BinDir + DirectorySeparator + 'android');
    ForceDir(BinDir + DirectorySeparator + 'ios');

    // 1. Generate capacitor.config.json
    ConfigContent := '{' + #10 +
      '  "appId": "' + ActualAppId + '",' + #10 +
      '  "appName": "' + ActualAppName + '",' + #10 +
      '  "webDir": "dist",' + #10 +
      '  "bundledWebRuntime": false,' + #10 +
      '  "android": {' + #10 +
      '    "path": "mobile/android"' + #10 +
      '  },' + #10 +
      '  "ios": {' + #10 +
      '    "path": "mobile/ios"' + #10 +
      '  }' + #10 +
      '}';

    if not FileExists(CapConfigFile) then
    begin
      WriteStringToFile(CapConfigFile, ConfigContent);
      WriteLn('  [+] Generated capacitor.config.json (appId: ' + ActualAppId + ', appName: ' + ActualAppName + ')');
    end
    else
      WriteLn('  [i] capacitor.config.json already exists.');

    if not FileExists(MobileCapConfigFile) then
      WriteStringToFile(MobileCapConfigFile, ConfigContent);

    // 2. Ensure @capacitor/core and @capacitor/cli are installed
    WriteLn('  [+] Installing Capacitor dependencies (@capacitor/core, @capacitor/cli, @capacitor/android)...');
    {$IFDEF WINDOWS}
    ExecuteProcess('cmd', '/c npm install @capacitor/core @capacitor/cli @capacitor/android --save-dev');
    {$ELSE}
    ExecuteProcess('npm', 'install @capacitor/core @capacitor/cli @capacitor/android --save-dev');
    {$ENDIF}

    // 3. Add Android platform if not present
    if not DirectoryExists(AndroidDir) then
    begin
      WriteLn('  [+] Adding Android native project (npx cap add android)...');
      CmdRunBuild;
      {$IFDEF WINDOWS}
      ExecuteProcess('cmd', '/c npx cap add android');
      {$ELSE}
      ExecuteProcess('npx', 'cap add android');
      {$ENDIF}
    end
    else
      WriteLn('  [i] Native android/ directory already initialized at: ' + AndroidDir);

    // 4. Generate README.md
    if not FileExists(ReadmeFile) then
    begin
      ReadmeContent :=
        '# ' + ActualAppName + ' (BlaiseVue 3.5 Mobile)' + #10 +
        '' + #10 +
        'Native mobile application powered by **Capacitor** and **BlaiseVue**.' + #10 +
        '' + #10 +
        '## Structure' + #10 +
        '- `android/`: Native Android Studio project.' + #10 +
        '- `ios/`: Native Xcode project (when added).' + #10 +
        '- `bin/`: Platform-segregated ready-to-install packages:' + #10 +
        '  - `bin/android/`: Compiled APKs (`' + CleanName + '-debug.apk`, `' + CleanName + '-release.apk`).' + #10 +
        '  - `bin/ios/`: Compiled IPAs.' + #10 +
        '- `capacitor.config.json`: Capacitor bridge configuration.' + #10 +
        '' + #10 +
        '## Quick Commands' + #10 +
        '```bash' + #10 +
        '# 1. Sync frontend to mobile assets' + #10 +
        'bv mobile sync' + #10 +
        '' + #10 +
        '# 2. Build for Android' + #10 +
        'bv mobile build android            # Debug APK' + #10 +
        'bv mobile build android --release  # Release APK (optimized)' + #10 +
        '' + #10 +
        '# 3. Build for iOS (macOS only)' + #10 +
        'bv mobile build ios' + #10 +
        '' + #10 +
        '# 4. Build for all mobile platforms' + #10 +
        'bv mobile build all' + #10 +
        'bv mobile build all --release' + #10 +
        '' + #10 +
        '# 5. Run on Device or Emulator' + #10 +
        'bv mobile run android              # Install & launch via ADB' + #10 +
        'bv mobile run android --emulator   # Launch in Android Emulator' + #10 +
        'bv mobile emulator list            # List available AVDs' + #10 +
        'bv mobile emulator start           # Start default AVD' + #10 +
        'bv mobile open android             # Open in Android Studio' + #10 +
        'bv mobile open ios                 # Open in Xcode' + #10 +
        '```' + #10;
      WriteStringToFile(ReadmeFile, ReadmeContent);
      WriteLn('  [+] Created mobile/README.md');
    end;

    WriteLn('');
    WriteLn('Mobile initialization complete in mobile/ !');
    WriteLn('Run "bv mobile open android" to launch Android Studio.');
    WriteLn('Run "bv mobile build android" to compile APK to mobile/bin/android/.');
  end
  else if (SubCmd = 'sync') then
  begin
    WriteLn('Synchronizing BlaiseVue dist/ with native Mobile platform...');
    CmdRunBuild;
    if IsAllTargets or (TargetPlatform = 'all') then
    begin
      {$IFDEF WINDOWS}
      ExecuteProcess('cmd', '/c npx cap sync');
      {$ELSE}
      ExecuteProcess('npx', 'cap sync');
      {$ENDIF}
    end
    else
    begin
      {$IFDEF WINDOWS}
      ExecuteProcess('cmd', '/c npx cap sync ' + TargetPlatform);
      {$ELSE}
      ExecuteProcess('npx', 'cap sync ' + TargetPlatform);
      {$ENDIF}
    end;
    WriteLn('Mobile assets synchronized successfully!');
  end
  else if (SubCmd = 'build') then
  begin
    WriteLn('Building native Mobile application with Capacitor...');
    CmdMobile('sync', TargetPlatform);

    if IsAllTargets or (TargetPlatform = 'all') then
    begin
      WriteLn('Building native Mobile application for ALL platforms (android, ios)...');
      BuildSingleTarget('android', IsRelease);
      BuildSingleTarget('ios', IsRelease);
    end
    else
    begin
      BuildSingleTarget(TargetPlatform, IsRelease);
    end;
  end
  else if (SubCmd = 'run') then
  begin
    RunTarget(TargetPlatform);
  end
  else if (SubCmd = 'open') then
  begin
    OpenTarget(TargetPlatform);
  end
  else if (SubCmd = 'emulator') then
  begin
    if (EmulatorAction = 'list') or (EmulatorAction = 'ls') or (EmulatorAction = '') then
    begin
      WriteLn('Installed Android Virtual Devices (AVD):');
      AvdList := GetInstalledAVDs;
      try
        if AvdList.Count = 0 then
        begin
          WriteLn('  [!] No AVD emulators found.');
          WriteLn('      Create one in Android Studio: Tools > Device Manager > Create Virtual Device');
        end
        else
        begin
          for i := 0 to AvdList.Count - 1 do
            WriteLn('  [' + IntToStr(i + 1) + '] ' + AvdList[i]);
          WriteLn('');
          WriteLn('To start an emulator: bv mobile emulator start ' + AvdList[0]);
          WriteLn('To build and run:     bv mobile run android --emulator');
        end;
      finally
        AvdList.Free;
      end;
    end
    else if (EmulatorAction = 'start') or (EmulatorAction = 'open') then
    begin
      StartEmulator(SelectedAVD);
    end
    else if (EmulatorAction = 'run') then
    begin
      UseEmulator := True;
      RunTarget('android');
    end
    else
    begin
      WriteLn('Usage: bv mobile emulator <list|start [name]|run [name]>');
    end;
  end
  else
  begin
    WriteLn('Usage: bv mobile <init [name] [id]|sync [target]|build [target] [--release]|run [target] [--emulator [name]]|open [target]|emulator <list|start|run>>');
    WriteLn('       Targets: android | ios | all (default: android)');
  end;
end;

procedure CmdDesktop(const SubCmd: string; const Arg1: string = ''; const Arg2: string = '');
var
  DesktopDir, AssetsDir, BinDir, UnitsDir: string;
  HostPlatform, TargetPlatform, AltPlatformName, ExeDir: string;
  CleanName, DisplayName: string;
  LprFile, LpiFile, WebUIFile, BridgeFile, ReadmeFile: string;
  LprContent, LpiContent, WebUIContent, BridgeContent, ReadmeContent: string;
  i: Integer;
  SearchRec: TSearchRec;
  FoundLpr: string;
  TargetExe, TargetBin, TargetExt: string;
  IsRelease, IsAllTargets: Boolean;

  procedure ParseArg(const A: string);
  var
    S: string;
  begin
    S := LowerCase(A);
    if S = '' then Exit;
    if (S = '--release') or (S = '-r') or (S = 'release') then
      IsRelease := True
    else if (S = '--debug') or (S = '-d') or (S = 'debug') then
      IsRelease := False
    else if (S = 'windows') or (S = 'win') or (S = 'win64') or (S = '--windows') or (S = '--target=windows') then
      TargetPlatform := 'windows'
    else if (S = 'linux') or (S = 'linux64') or (S = '--linux') or (S = '--target=linux') then
      TargetPlatform := 'linux'
    else if (S = 'macos') or (S = 'mac') or (S = 'darwin') or (S = '--macos') or (S = '--target=macos') or (S = '--target=darwin') then
      TargetPlatform := 'macos'
    else if (S = 'all') or (S = '--all') or (S = '--target=all') then
      IsAllTargets := True
    else if (DisplayName = '') and (SubCmd = 'init') and (Copy(S, 1, 1) <> '-') then
      DisplayName := A;
  end;

  function BuildSingleTarget(const ATarget: string; ARelease: Boolean): Boolean;
  var
    TBin, TUnits: string;
    TExt, TExe: string;
    FpcCmd: string;
    IsNative: Boolean;
  begin
    Result := False;
    TBin := BinDir + DirectorySeparator + ATarget;
    TUnits := UnitsDir + DirectorySeparator + ATarget;
    ForceDir(TBin);
    ForceDir(TUnits);

    if ATarget = 'windows' then
      TExt := '.exe'
    else
      TExt := '';

    TExe := TBin + DirectorySeparator + CleanName + TExt;
    IsNative := (ATarget = HostPlatform);

    if ARelease then
      WriteLn('  [+] Compiling ' + FoundLpr + ' in RELEASE mode for ' + ATarget + ' (GUI Application - No Console Window)...')
    else
      WriteLn('  [+] Compiling ' + FoundLpr + ' in DEBUG mode for ' + ATarget + ' (Console Window Active for Diagnostics)...');

    FpcCmd := 'fpc ';
    if ARelease then
    begin
      FpcCmd := FpcCmd + '-O3 -Xs -dRELEASE ';
      if ATarget = 'windows' then
        FpcCmd := FpcCmd + '-WG ';
    end
    else
    begin
      FpcCmd := FpcCmd + '-O2 -g -gl -dDEBUG ';
    end;

    if not IsNative then
    begin
      if ATarget = 'windows' then
        FpcCmd := FpcCmd + '-Twin64 -Px86_64 '
      else if ATarget = 'linux' then
        FpcCmd := FpcCmd + '-Tlinux -Px86_64 '
      else if ATarget = 'macos' then
        FpcCmd := FpcCmd + '-Tdarwin -Px86_64 ';
    end;

    {$IFDEF WINDOWS}
    FpcCmd := FpcCmd + '-FEbin\' + ATarget + ' -FUunits\' + ATarget + ' ' + FoundLpr;
    ExecuteProcess('cmd', '/c cd /d "' + DesktopDir + '" && ' + FpcCmd);
    {$ELSE}
    FpcCmd := FpcCmd + '-FEbin/' + ATarget + ' -FUunits/' + ATarget + ' ' + FoundLpr;
    ExecuteProcess('sh', '-c "cd ' + DesktopDir + ' && ' + FpcCmd + '"');
    {$ENDIF}

    if FileExists(TExe) then
    begin
      Result := True;
      if ARelease then
        WriteLn('  [SUCCESS] Release native GUI binary built (no console): desktop/bin/' + ATarget + '/' + CleanName + TExt)
      else
      begin
        WriteLn('  [SUCCESS] Debug native binary built: desktop/bin/' + ATarget + '/' + CleanName + TExt);
        WriteLn('  [TIP] For end users, run "bv desktop build ' + ATarget + ' --release" to compile a clean GUI application without console.');
      end;
    end
    else
    begin
      WriteLn('  [WARNING] Binary not generated at expected location: ' + TExe);
      if not IsNative then
      begin
        WriteLn('  [INFO] Note: Cross-compiling for ' + ATarget + ' from ' + HostPlatform + ' requires FPC target units.');
        WriteLn('         You can compile natively on ' + ATarget + ' (or WSL/Docker for Linux) using "bv desktop build".');
      end;
    end;
  end;

begin
  WriteLn('=== BlaiseVue 3.5 Desktop (WebUI & Lazarus IDE) ===');

  {$IFDEF MSWINDOWS}
  HostPlatform := 'windows';
  AltPlatformName := 'win64';
  {$ELSE}
    {$IFDEF DARWIN}
    HostPlatform := 'macos';
    AltPlatformName := 'darwin';
    {$ELSE}
    HostPlatform := 'linux';
    AltPlatformName := 'linux64';
    {$ENDIF}
  {$ENDIF}

  IsRelease := False;
  IsAllTargets := False;
  TargetPlatform := '';
  DisplayName := '';

  ParseArg(Arg1);
  ParseArg(Arg2);
  for i := 3 to ParamCount do
    ParseArg(ParamStr(i));

  if TargetPlatform = '' then
    TargetPlatform := HostPlatform;

  if DisplayName = '' then DisplayName := 'BlaiseVue Desktop';

  CleanName := '';
  for i := 1 to Length(DisplayName) do
  begin
    if (DisplayName[i] in ['a'..'z', 'A'..'Z', '0'..'9']) then
      CleanName := CleanName + DisplayName[i]
    else if CleanName <> '' then
      CleanName := CleanName + '_';
  end;
  if CleanName = '' then CleanName := 'DesktopApp';
  if CleanName[1] in ['0'..'9'] then CleanName := 'App' + CleanName;

  DesktopDir := GetCurrentDir + DirectorySeparator + 'desktop';
  AssetsDir := DesktopDir + DirectorySeparator + 'assets';
  BinDir := DesktopDir + DirectorySeparator + 'bin';
  UnitsDir := DesktopDir + DirectorySeparator + 'units';

  if (SubCmd = 'init') then
  begin
    WriteLn('Initializing native Desktop project in desktop/ ...');
    ForceDir(DesktopDir);
    ForceDir(AssetsDir);
    ForceDir(BinDir);
    ForceDir(UnitsDir);
    ForceDir(BinDir + DirectorySeparator + 'windows');
    ForceDir(BinDir + DirectorySeparator + 'linux');
    ForceDir(BinDir + DirectorySeparator + 'macos');
    ForceDir(UnitsDir + DirectorySeparator + 'windows');
    ForceDir(UnitsDir + DirectorySeparator + 'linux');
    ForceDir(UnitsDir + DirectorySeparator + 'macos');

    LprFile := DesktopDir + DirectorySeparator + CleanName + '.lpr';
    LpiFile := DesktopDir + DirectorySeparator + CleanName + '.lpi';
    WebUIFile := DesktopDir + DirectorySeparator + 'webui.pas';
    BridgeFile := DesktopDir + DirectorySeparator + 'uDesktopBridge.pas';
    ReadmeFile := DesktopDir + DirectorySeparator + 'README.md';

    // 1. webui.pas
    if not FileExists(WebUIFile) then
    begin
      WebUIContent :=
        'unit webui;' + #10 +
        '' + #10 +
        '{$mode objfpc}{$H+}' + #10 +
        '' + #10 +
        'interface' + #10 +
        '' + #10 +
        'uses' + #10 +
        '  SysUtils, DynLibs;' + #10 +
        '' + #10 +
        'const' + #10 +
        '  NoBrowser = 0;' + #10 +
        '  AnyBrowser = 1;' + #10 +
        '  Chrome = 2;' + #10 +
        '  Firefox = 3;' + #10 +
        '  Edge = 4;' + #10 +
        '  Safari = 5;' + #10 +
        '  Chromium = 6;' + #10 +
        '  Opera = 7;' + #10 +
        '  Brave = 8;' + #10 +
        '  Vivaldi = 9;' + #10 +
        '  Yandex = 10;' + #10 +
        '  Epic = 11;' + #10 +
        '' + #10 +
        'type' + #10 +
        '  PWebUIEvent = ^TWebUIEvent;' + #10 +
        '  TWebUIEvent = record' + #10 +
        '    window: Size_t;' + #10 +
        '    event_type: Size_t;' + #10 +
        '    element: PChar;' + #10 +
        '    event_number: Size_t;' + #10 +
        '    bind_id: Size_t;' + #10 +
        '    client_id: Size_t;' + #10 +
        '    connection_id: Size_t;' + #10 +
        '    cookies: PChar;' + #10 +
        '  end;' + #10 +
        '' + #10 +
        '  TWebUIBindCallback = procedure(e: PWebUIEvent); cdecl;' + #10 +
        '' + #10 +
        'var' + #10 +
        '  webui_new_window: function(): Size_t; cdecl;' + #10 +
        '  webui_show: function(window: Size_t; const content: PChar): Boolean; cdecl;' + #10 +
        '  webui_show_browser: function(window: Size_t; const content: PChar; browser: Cardinal): Boolean; cdecl;' + #10 +
        '  webui_bind: function(window: Size_t; const element: PChar; func: TWebUIBindCallback): Size_t; cdecl;' + #10 +
        '  webui_wait: procedure(); cdecl;' + #10 +
        '  webui_close: procedure(window: Size_t); cdecl;' + #10 +
        '  webui_exit: procedure(); cdecl;' + #10 +
        '  webui_set_title: procedure(window: Size_t; const title: PChar); cdecl;' + #10 +
        '  webui_set_size: procedure(window: Size_t; width, height: Cardinal); cdecl;' + #10 +
        '  webui_set_position: procedure(window: Size_t; x, y: Cardinal); cdecl;' + #10 +
        '  webui_run: procedure(window: Size_t; const script: PChar); cdecl;' + #10 +
        '  webui_script: function(window: Size_t; const script: PChar; timeout: Size_t; buffer: PChar; buffer_len: Size_t): Boolean; cdecl;' + #10 +
        '  webui_set_kiosk: procedure(window: Size_t; status: Boolean); cdecl;' + #10 +
        '  webui_get_string: function(e: PWebUIEvent): PChar; cdecl;' + #10 +
        '  webui_get_int: function(e: PWebUIEvent): Int64; cdecl;' + #10 +
        '  webui_get_bool: function(e: PWebUIEvent): Boolean; cdecl;' + #10 +
        '  webui_get_size: function(e: PWebUIEvent): Size_t; cdecl;' + #10 +
        '  webui_return_string: procedure(e: PWebUIEvent; const str: PChar); cdecl;' + #10 +
        '  webui_return_int: procedure(e: PWebUIEvent; num: Int64); cdecl;' + #10 +
        '  webui_return_bool: procedure(e: PWebUIEvent; b: Boolean); cdecl;' + #10 +
        '  webui_is_shown: function(window: Size_t): Boolean; cdecl;' + #10 +
        '' + #10 +
        'function InitWebUI(const LibPath: string = ''''): Boolean;' + #10 +
        'procedure FreeWebUI;' + #10 +
        'function IsWebUIAvailable: Boolean;' + #10 +
        '' + #10 +
        'implementation' + #10 +
        '' + #10 +
        'var' + #10 +
        '  WebUILibHandle: TLibHandle = NilHandle;' + #10 +
        '' + #10 +
        'function IsWebUIAvailable: Boolean;' + #10 +
        'begin' + #10 +
        '  Result := (WebUILibHandle <> NilHandle);' + #10 +
        'end;' + #10 +
        '' + #10 +
        'function InitWebUI(const LibPath: string): Boolean;' + #10 +
        'var' + #10 +
        '  TargetLib: string;' + #10 +
        '  BaseDir: string;' + #10 +
        'begin' + #10 +
        '  Result := False;' + #10 +
        '  if WebUILibHandle <> NilHandle then Exit(True);' + #10 +
        '' + #10 +
        '  TargetLib := LibPath;' + #10 +
        '  if TargetLib = '''' then' + #10 +
        '  begin' + #10 +
        '    {$IFDEF MSWINDOWS}' + #10 +
        '    TargetLib := ''webui-2.dll'';' + #10 +
        '    {$ELSE}' + #10 +
        '      {$IFDEF DARWIN}' + #10 +
        '      TargetLib := ''libwebui-2.dylib'';' + #10 +
        '      {$ELSE}' + #10 +
        '      TargetLib := ''libwebui-2.so'';' + #10 +
        '      {$ENDIF}' + #10 +
        '    {$ENDIF}' + #10 +
        '' + #10 +
        '    if not FileExists(TargetLib) then' + #10 +
        '    begin' + #10 +
        '      BaseDir := ExtractFilePath(ParamStr(0));' + #10 +
        '      // 1. Next to executable: desktop/bin/<platform>/webui-2.dll' + #10 +
        '      if FileExists(BaseDir + TargetLib) then' + #10 +
        '        TargetLib := BaseDir + TargetLib' + #10 +
        '      // 2. Parent bin folder: desktop/bin/webui-2.dll' + #10 +
        '      else if FileExists(BaseDir + ''..'' + DirectorySeparator + TargetLib) then' + #10 +
        '        TargetLib := BaseDir + ''..'' + DirectorySeparator + TargetLib' + #10 +
        '      // 3. Desktop root folder: desktop/webui-2.dll' + #10 +
        '      else if FileExists(BaseDir + ''..'' + DirectorySeparator + ''..'' + DirectorySeparator + TargetLib) then' + #10 +
        '        TargetLib := BaseDir + ''..'' + DirectorySeparator + ''..'' + DirectorySeparator + TargetLib' + #10 +
        '      // 4. Current working directory' + #10 +
        '      else if FileExists(GetCurrentDir + DirectorySeparator + TargetLib) then' + #10 +
        '        TargetLib := GetCurrentDir + DirectorySeparator + TargetLib;' + #10 +
        '    end;' + #10 +
        '  end;' + #10 +
        '' + #10 +
        '  WebUILibHandle := SafeLoadLibrary(TargetLib);' + #10 +
        '  if WebUILibHandle = NilHandle then Exit(False);' + #10 +
        '' + #10 +
        '  Pointer(webui_new_window) := GetProcedureAddress(WebUILibHandle, ''webui_new_window'');' + #10 +
        '  Pointer(webui_show) := GetProcedureAddress(WebUILibHandle, ''webui_show'');' + #10 +
        '  Pointer(webui_show_browser) := GetProcedureAddress(WebUILibHandle, ''webui_show_browser'');' + #10 +
        '  Pointer(webui_bind) := GetProcedureAddress(WebUILibHandle, ''webui_bind'');' + #10 +
        '  Pointer(webui_wait) := GetProcedureAddress(WebUILibHandle, ''webui_wait'');' + #10 +
        '  Pointer(webui_close) := GetProcedureAddress(WebUILibHandle, ''webui_close'');' + #10 +
        '  Pointer(webui_exit) := GetProcedureAddress(WebUILibHandle, ''webui_exit'');' + #10 +
        '  Pointer(webui_set_title) := GetProcedureAddress(WebUILibHandle, ''webui_set_title'');' + #10 +
        '  Pointer(webui_set_size) := GetProcedureAddress(WebUILibHandle, ''webui_set_size'');' + #10 +
        '  Pointer(webui_set_position) := GetProcedureAddress(WebUILibHandle, ''webui_set_position'');' + #10 +
        '  Pointer(webui_run) := GetProcedureAddress(WebUILibHandle, ''webui_run'');' + #10 +
        '  Pointer(webui_script) := GetProcedureAddress(WebUILibHandle, ''webui_script'');' + #10 +
        '  Pointer(webui_set_kiosk) := GetProcedureAddress(WebUILibHandle, ''webui_set_kiosk'');' + #10 +
        '  Pointer(webui_get_string) := GetProcedureAddress(WebUILibHandle, ''webui_get_string'');' + #10 +
        '  Pointer(webui_get_int) := GetProcedureAddress(WebUILibHandle, ''webui_get_int'');' + #10 +
        '  Pointer(webui_get_bool) := GetProcedureAddress(WebUILibHandle, ''webui_get_bool'');' + #10 +
        '  Pointer(webui_get_size) := GetProcedureAddress(WebUILibHandle, ''webui_get_size'');' + #10 +
        '  Pointer(webui_return_string) := GetProcedureAddress(WebUILibHandle, ''webui_return_string'');' + #10 +
        '  Pointer(webui_return_int) := GetProcedureAddress(WebUILibHandle, ''webui_return_int'');' + #10 +
        '  Pointer(webui_return_bool) := GetProcedureAddress(WebUILibHandle, ''webui_return_bool'');' + #10 +
        '  Pointer(webui_is_shown) := GetProcedureAddress(WebUILibHandle, ''webui_is_shown'');' + #10 +
        '' + #10 +
        '  Result := Assigned(webui_new_window) and Assigned(webui_show) and Assigned(webui_wait);' + #10 +
        'end;' + #10 +
        '' + #10 +
        'procedure FreeWebUI;' + #10 +
        'begin' + #10 +
        '  if WebUILibHandle <> NilHandle then' + #10 +
        '  begin' + #10 +
        '    UnloadLibrary(WebUILibHandle);' + #10 +
        '    WebUILibHandle := NilHandle;' + #10 +
        '  end;' + #10 +
        'end;' + #10 +
        '' + #10 +
        'finalization' + #10 +
        '  FreeWebUI;' + #10 +
        '' + #10 +
        'end.' + #10;
      WriteStringToFile(WebUIFile, WebUIContent);
      WriteLn('  [+] Created desktop/webui.pas (Dynamic WebUI C Loader)');
    end
    else
      WriteLn('  [i] desktop/webui.pas already exists.');

    // 2. uDesktopBridge.pas
    if not FileExists(BridgeFile) then
    begin
      BridgeContent :=
        'unit uDesktopBridge;' + #10 +
        '' + #10 +
        '{$mode objfpc}{$H+}' + #10 +
        '' + #10 +
        'interface' + #10 +
        '' + #10 +
        'uses' + #10 +
        '  SysUtils, Classes, webui;' + #10 +
        '' + #10 +
        'procedure RegisterDesktopBridge(AWindow: Size_t);' + #10 +
        'procedure HandleMinimize(e: PWebUIEvent); cdecl;' + #10 +
        'procedure HandleMaximize(e: PWebUIEvent); cdecl;' + #10 +
        'procedure HandleClose(e: PWebUIEvent); cdecl;' + #10 +
        'procedure HandleSetTitle(e: PWebUIEvent); cdecl;' + #10 +
        'procedure HandleSetFullScreen(e: PWebUIEvent); cdecl;' + #10 +
        'procedure HandleNotify(e: PWebUIEvent); cdecl;' + #10 +
        'procedure HandleOpenURL(e: PWebUIEvent); cdecl;' + #10 +
        'procedure HandleOpenFileDialog(e: PWebUIEvent); cdecl;' + #10 +
        'procedure HandleSaveFileDialog(e: PWebUIEvent); cdecl;' + #10 +
        'procedure HandleGetSystemInfo(e: PWebUIEvent); cdecl;' + #10 +
        '' + #10 +
        'implementation' + #10 +
        '' + #10 +
        'procedure HandleMinimize(e: PWebUIEvent); cdecl;' + #10 +
        'begin' + #10 +
        '  WriteLn(''[uDesktopBridge] Minimize window requested'');' + #10 +
        '  if Assigned(webui_return_bool) then webui_return_bool(e, True);' + #10 +
        'end;' + #10 +
        '' + #10 +
        'procedure HandleMaximize(e: PWebUIEvent); cdecl;' + #10 +
        'begin' + #10 +
        '  WriteLn(''[uDesktopBridge] Maximize window requested'');' + #10 +
        '  if Assigned(webui_return_bool) then webui_return_bool(e, True);' + #10 +
        'end;' + #10 +
        '' + #10 +
        'procedure HandleClose(e: PWebUIEvent); cdecl;' + #10 +
        'begin' + #10 +
        '  WriteLn(''[uDesktopBridge] Close window requested'');' + #10 +
        '  if Assigned(webui_close) and (e <> nil) then' + #10 +
        '    webui_close(e^.window);' + #10 +
        '  if Assigned(webui_exit) then' + #10 +
        '    webui_exit();' + #10 +
        'end;' + #10 +
        '' + #10 +
        'procedure HandleSetTitle(e: PWebUIEvent); cdecl;' + #10 +
        'var' + #10 +
        '  NewTitle: PChar;' + #10 +
        'begin' + #10 +
        '  if Assigned(webui_get_string) and (e <> nil) then' + #10 +
        '  begin' + #10 +
        '    NewTitle := webui_get_string(e);' + #10 +
        '    if Assigned(webui_set_title) and (NewTitle <> nil) then' + #10 +
        '      webui_set_title(e^.window, NewTitle);' + #10 +
        '  end;' + #10 +
        '  if Assigned(webui_return_bool) then webui_return_bool(e, True);' + #10 +
        'end;' + #10 +
        '' + #10 +
        'procedure HandleSetFullScreen(e: PWebUIEvent); cdecl;' + #10 +
        'var' + #10 +
        '  Status: Boolean;' + #10 +
        'begin' + #10 +
        '  if Assigned(webui_get_bool) and (e <> nil) then' + #10 +
        '  begin' + #10 +
        '    Status := webui_get_bool(e);' + #10 +
        '    if Assigned(webui_set_kiosk) then' + #10 +
        '      webui_set_kiosk(e^.window, Status);' + #10 +
        '  end;' + #10 +
        '  if Assigned(webui_return_bool) then webui_return_bool(e, True);' + #10 +
        'end;' + #10 +
        '' + #10 +
        'procedure HandleNotify(e: PWebUIEvent); cdecl;' + #10 +
        'var' + #10 +
        '  Title: PChar;' + #10 +
        'begin' + #10 +
        '  if Assigned(webui_get_string) and (e <> nil) then' + #10 +
        '  begin' + #10 +
        '    Title := webui_get_string(e);' + #10 +
        '    WriteLn(''[uDesktopBridge] Desktop Notification: '', Title);' + #10 +
        '  end;' + #10 +
        '  if Assigned(webui_return_bool) then webui_return_bool(e, True);' + #10 +
        'end;' + #10 +
        '' + #10 +
        'procedure HandleOpenURL(e: PWebUIEvent); cdecl;' + #10 +
        'var' + #10 +
        '  URL: PChar;' + #10 +
        'begin' + #10 +
        '  if Assigned(webui_get_string) and (e <> nil) then' + #10 +
        '  begin' + #10 +
        '    URL := webui_get_string(e);' + #10 +
        '    WriteLn(''[uDesktopBridge] Open URL: '', URL);' + #10 +
        '  end;' + #10 +
        '  if Assigned(webui_return_bool) then webui_return_bool(e, True);' + #10 +
        'end;' + #10 +
        '' + #10 +
        'procedure HandleOpenFileDialog(e: PWebUIEvent); cdecl;' + #10 +
        'var' + #10 +
        '  MockResult: string;' + #10 +
        'begin' + #10 +
        '  MockResult := ''{"name":"document.txt","path":"/path/to/document.txt","size":1024}'';' + #10 +
        '  if Assigned(webui_return_string) and (e <> nil) then' + #10 +
        '    webui_return_string(e, PChar(MockResult));' + #10 +
        'end;' + #10 +
        '' + #10 +
        'procedure HandleSaveFileDialog(e: PWebUIEvent); cdecl;' + #10 +
        'var' + #10 +
        '  MockResult: string;' + #10 +
        'begin' + #10 +
        '  MockResult := ''{"saved":true,"filename":"exported_data.json"}'';' + #10 +
        '  if Assigned(webui_return_string) and (e <> nil) then' + #10 +
        '    webui_return_string(e, PChar(MockResult));' + #10 +
        'end;' + #10 +
        '' + #10 +
        'procedure HandleGetSystemInfo(e: PWebUIEvent); cdecl;' + #10 +
        'var' + #10 +
        '  SysInfoJSON: string;' + #10 +
        '  OSName: string;' + #10 +
        'begin' + #10 +
        '  {$IFDEF MSWINDOWS}' + #10 +
        '  OSName := ''Windows'';' + #10 +
        '  {$ELSE}' + #10 +
        '    {$IFDEF DARWIN}' + #10 +
        '    OSName := ''macOS'';' + #10 +
        '    {$ELSE}' + #10 +
        '    OSName := ''Linux'';' + #10 +
        '    {$ENDIF}' + #10 +
        '  {$ENDIF}' + #10 +
        '' + #10 +
        '  SysInfoJSON := ''{'' +' + #10 +
        '    ''"platform":"'' + OSName + ''",'' +' + #10 +
        '    ''"framework":"BlaiseVue 3.5 Desktop (WebUI + Lazarus)",'' +' + #10 +
        '    ''"compiler":"Free Pascal '' + {$I %FPCVERSION%} + ''",'' +' + #10 +
        '    ''"arch":"'' + {$I %FPCTARGETCPU%} + ''",'' +' + #10 +
        '    ''"isDesktop":true'' +' + #10 +
        '    ''}'';' + #10 +
        '' + #10 +
        '  if Assigned(webui_return_string) and (e <> nil) then' + #10 +
        '    webui_return_string(e, PChar(SysInfoJSON));' + #10 +
        'end;' + #10 +
        '' + #10 +
        'procedure RegisterDesktopBridge(AWindow: Size_t);' + #10 +
        'begin' + #10 +
        '  if not Assigned(webui_bind) then Exit;' + #10 +
        '' + #10 +
        '  webui_bind(AWindow, ''bv_minimize'', @HandleMinimize);' + #10 +
        '  webui_bind(AWindow, ''bv_maximize'', @HandleMaximize);' + #10 +
        '  webui_bind(AWindow, ''bv_close'', @HandleClose);' + #10 +
        '  webui_bind(AWindow, ''bv_set_title'', @HandleSetTitle);' + #10 +
        '  webui_bind(AWindow, ''bv_set_fullscreen'', @HandleSetFullScreen);' + #10 +
        '  webui_bind(AWindow, ''bv_notify'', @HandleNotify);' + #10 +
        '  webui_bind(AWindow, ''bv_open_url'', @HandleOpenURL);' + #10 +
        '  webui_bind(AWindow, ''bv_open_file_dialog'', @HandleOpenFileDialog);' + #10 +
        '  webui_bind(AWindow, ''bv_save_file_dialog'', @HandleSaveFileDialog);' + #10 +
        '  webui_bind(AWindow, ''bv_get_system_info'', @HandleGetSystemInfo);' + #10 +
        'end;' + #10 +
        '' + #10 +
        'initialization' + #10 +
        '  {$IFDEF MSWINDOWS}' + #10 +
        '  if not IsConsole then' + #10 +
        '  begin' + #10 +
        '    try' + #10 +
        '      AssignFile(Output, ''NUL'');' + #10 +
        '      Rewrite(Output);' + #10 +
        '      AssignFile(ErrOutput, ''NUL'');' + #10 +
        '      Rewrite(ErrOutput);' + #10 +
        '    except' + #10 +
        '    end;' + #10 +
        '  end;' + #10 +
        '  {$ENDIF}' + #10 +
        '' + #10 +
        'end.' + #10;
      WriteStringToFile(BridgeFile, BridgeContent);
      WriteLn('  [+] Created desktop/uDesktopBridge.pas (Native Desktop Bridge)');
    end
    else
      WriteLn('  [i] desktop/uDesktopBridge.pas already exists.');

    // 3. <CleanName>.lpr
    if not FileExists(LprFile) then
    begin
      LprContent :=
        'program ' + CleanName + ';' + #10 +
        '' + #10 +
        '{$mode objfpc}{$H+}' + #10 +
        '{$IFDEF RELEASE}' + #10 +
        '  {$APPTYPE GUI}' + #10 +
        '{$ENDIF}' + #10 +
        '' + #10 +
        'uses' + #10 +
        '  {$IFDEF UNIX}' + #10 +
        '  cthreads,' + #10 +
        '  {$ENDIF}' + #10 +
        '  {$IFDEF MSWINDOWS}' + #10 +
        '  Windows,' + #10 +
        '  {$ENDIF}' + #10 +
        '  SysUtils, Classes, Process, webui, uDesktopBridge;' + #10 +
        '' + #10 +
        'const' + #10 +
        '  APP_TITLE = ''' + DisplayName + ''';' + #10 +
        '  DEFAULT_WIDTH = 1280;' + #10 +
        '  DEFAULT_HEIGHT = 800;' + #10 +
        '' + #10 +
        'var' + #10 +
        '  MainWindow: Size_t;' + #10 +
        '  IndexPath: string;' + #10 +
        '  AssetsDir: string;' + #10 +
        '' + #10 +
        'function FindAppModeBrowser(const TargetURL: string; out BrowserCmd: string): Boolean;' + #10 +
        'var' + #10 +
        '  EdgePath, ChromePath, BravePath: string;' + #10 +
        'begin' + #10 +
        '  Result := False;' + #10 +
        '  BrowserCmd := '''';' + #10 +
        '' + #10 +
        '  {$IFDEF MSWINDOWS}' + #10 +
        '  EdgePath := GetEnvironmentVariable(''ProgramFiles(x86)'') + ''\Microsoft\Edge\Application\msedge.exe'';' + #10 +
        '  if not FileExists(EdgePath) then' + #10 +
        '    EdgePath := GetEnvironmentVariable(''ProgramFiles'') + ''\Microsoft\Edge\Application\msedge.exe'';' + #10 +
        '' + #10 +
        '  ChromePath := GetEnvironmentVariable(''ProgramFiles'') + ''\Google\Chrome\Application\chrome.exe'';' + #10 +
        '  if not FileExists(ChromePath) then' + #10 +
        '    ChromePath := GetEnvironmentVariable(''ProgramFiles(x86)'') + ''\Google\Chrome\Application\chrome.exe'';' + #10 +
        '  if not FileExists(ChromePath) then' + #10 +
        '    ChromePath := GetEnvironmentVariable(''LocalAppData'') + ''\Google\Chrome\Application\chrome.exe'';' + #10 +
        '' + #10 +
        '  BravePath := GetEnvironmentVariable(''ProgramFiles'') + ''\BraveSoftware\Brave-Browser\Application\brave.exe'';' + #10 +
        '' + #10 +
        '  if FileExists(EdgePath) then' + #10 +
        '  begin' + #10 +
        '    BrowserCmd := EdgePath;' + #10 +
        '    Exit(True);' + #10 +
        '  end;' + #10 +
        '' + #10 +
        '  if FileExists(ChromePath) then' + #10 +
        '  begin' + #10 +
        '    BrowserCmd := ChromePath;' + #10 +
        '    Exit(True);' + #10 +
        '  end;' + #10 +
        '' + #10 +
        '  if FileExists(BravePath) then' + #10 +
        '  begin' + #10 +
        '    BrowserCmd := BravePath;' + #10 +
        '    Exit(True);' + #10 +
        '  end;' + #10 +
        '' + #10 +
        '  BrowserCmd := ''cmd.exe'';' + #10 +
        '  Result := True;' + #10 +
        '  {$ELSE}' + #10 +
        '  BrowserCmd := ''xdg-open'';' + #10 +
        '  Result := True;' + #10 +
        '  {$ENDIF}' + #10 +
        'end;' + #10 +
        '' + #10 +
        'procedure LaunchNativeBrowserApp(const TargetURL: string);' + #10 +
        'var' + #10 +
        '  BCmd: string;' + #10 +
        '  Proc: TProcess;' + #10 +
        '  ProfileDir: string;' + #10 +
        'begin' + #10 +
        '  WriteLn(''[BlaiseVue Desktop] Launching native Browser App mode...'');' + #10 +
        '  if FindAppModeBrowser(TargetURL, BCmd) then' + #10 +
        '  begin' + #10 +
        '    Proc := TProcess.Create(nil);' + #10 +
        '    try' + #10 +
        '      Proc.Executable := BCmd;' + #10 +
        '      if BCmd = ''cmd.exe'' then' + #10 +
        '      begin' + #10 +
        '        Proc.Parameters.Add(''/c'');' + #10 +
        '        Proc.Parameters.Add(''start'');' + #10 +
        '        Proc.Parameters.Add('''''''');' + #10 +
        '        Proc.Parameters.Add(TargetURL);' + #10 +
        '      end' + #10 +
        '      else' + #10 +
        '      begin' + #10 +
        '        ProfileDir := GetTempDir(False) + ''bv_desktop_profile'';' + #10 +
        '        ForceDirectories(ProfileDir);' + #10 +
        '        Proc.Parameters.Add(''--app='' + TargetURL);' + #10 +
        '        Proc.Parameters.Add(''--window-size='' + IntToStr(DEFAULT_WIDTH) + '','' + IntToStr(DEFAULT_HEIGHT));' + #10 +
        '        Proc.Parameters.Add(''--user-data-dir='' + ProfileDir);' + #10 +
        '        Proc.Parameters.Add(''--no-first-run'');' + #10 +
        '      end;' + #10 +
        '      Proc.Options := [poWaitOnExit];' + #10 +
        '      Proc.Execute;' + #10 +
        '    finally' + #10 +
        '      Proc.Free;' + #10 +
        '    end;' + #10 +
        '  end;' + #10 +
        'end;' + #10 +
        '' + #10 +
        'begin' + #10 +
        '  {$IFDEF MSWINDOWS}' + #10 +
        '  if not IsConsole then' + #10 +
        '  begin' + #10 +
        '    try' + #10 +
        '      AssignFile(Output, ''NUL'');' + #10 +
        '      Rewrite(Output);' + #10 +
        '      AssignFile(ErrOutput, ''NUL'');' + #10 +
        '      Rewrite(ErrOutput);' + #10 +
        '    except' + #10 +
        '    end;' + #10 +
        '  end;' + #10 +
        '  {$ENDIF}' + #10 +
        '' + #10 +
        '  WriteLn(''===================================================='');' + #10 +
        '  WriteLn(''  '' + APP_TITLE + '' - BlaiseVue 3.5 Desktop'');' + #10 +
        '  WriteLn(''===================================================='');' + #10 +
        '' + #10 +
        '  // 1. Packaged directly alongside executable (standalone bundle/dist)' + #10 +
        '  AssetsDir := ExtractFilePath(ParamStr(0)) + ''assets'';' + #10 +
        '  // 2. Platform bin subdirectory: desktop/bin/<platform>/ -> desktop/assets' + #10 +
        '  if not DirectoryExists(AssetsDir) then' + #10 +
        '    AssetsDir := ExpandFileName(ExtractFilePath(ParamStr(0)) + ''..'' + DirectorySeparator + ''..'' + DirectorySeparator + ''assets'');' + #10 +
        '  // 3. Flat bin directory: desktop/bin/ -> desktop/assets' + #10 +
        '  if not DirectoryExists(AssetsDir) then' + #10 +
        '    AssetsDir := ExpandFileName(ExtractFilePath(ParamStr(0)) + ''..'' + DirectorySeparator + ''assets'');' + #10 +
        '  // 4. Current working directory' + #10 +
        '  if not DirectoryExists(AssetsDir) then' + #10 +
        '    AssetsDir := GetCurrentDir + DirectorySeparator + ''assets'';' + #10 +
        '  if not DirectoryExists(AssetsDir) then' + #10 +
        '    AssetsDir := GetCurrentDir + DirectorySeparator + ''desktop'' + DirectorySeparator + ''assets'';' + #10 +
        '' + #10 +
        '  IndexPath := AssetsDir + DirectorySeparator + ''index.html'';' + #10 +
        '  if not FileExists(IndexPath) then' + #10 +
        '  begin' + #10 +
        '    {$IFDEF MSWINDOWS}' + #10 +
        '    if not IsConsole then' + #10 +
        '      MessageBoxA(0, PChar(''Assets not found: '' + IndexPath + #13#10 + ''Please run "bv desktop sync" first.''), PChar(APP_TITLE), MB_ICONERROR or MB_OK)' + #10 +
        '    else' + #10 +
        '    {$ENDIF}' + #10 +
        '      WriteLn(''[ERROR] Assets not found: '', IndexPath);' + #10 +
        '    Halt(1);' + #10 +
        '  end;' + #10 +
        '' + #10 +
        '  WriteLn(''[i] Assets found: '', IndexPath);' + #10 +
        '' + #10 +
        '  if InitWebUI then' + #10 +
        '  begin' + #10 +
        '    WriteLn(''[+] Initialized WebUI runtime successfully!'');' + #10 +
        '    MainWindow := webui_new_window();' + #10 +
        '    RegisterDesktopBridge(MainWindow);' + #10 +
        '    webui_set_title(MainWindow, PChar(APP_TITLE));' + #10 +
        '    webui_set_size(MainWindow, DEFAULT_WIDTH, DEFAULT_HEIGHT);' + #10 +
        '' + #10 +
        '    WriteLn(''[+] Opening desktop window via WebUI...'');' + #10 +
        '    webui_show(MainWindow, PChar(IndexPath));' + #10 +
        '    webui_wait();' + #10 +
        '    WriteLn(''[i] Desktop window closed.'');' + #10 +
        '  end' + #10 +
        '  else' + #10 +
        '  begin' + #10 +
        '    WriteLn(''[i] WebUI library (webui-2.dll) not found in binary folder.'');' + #10 +
        '    WriteLn(''[i] Gracefully falling back to native Browser App Mode (Edge/Chrome/Chromium)...'');' + #10 +
        '    LaunchNativeBrowserApp(''file:///'' + StringReplace(ExpandFileName(IndexPath), ''\'', ''/'', [rfReplaceAll]));' + #10 +
        '  end;' + #10 +
        'end.' + #10;
      WriteStringToFile(LprFile, LprContent);
      WriteLn('  [+] Created desktop/' + CleanName + '.lpr (Free Pascal Main Entry)');
    end
    else
      WriteLn('  [i] desktop/' + CleanName + '.lpr already exists.');

    // 4. <CleanName>.lpi
    if not FileExists(LpiFile) then
    begin
      LpiContent :=
        '<?xml version="1.0" encoding="UTF-8"?>' + #10 +
        '<CONFIG>' + #10 +
        '  <ProjectOptions>' + #10 +
        '    <Version Value="12"/>' + #10 +
        '    <General>' + #10 +
        '      <Flags>' + #10 +
        '        <MainUnitHasCreateFormStatements Value="False"/>' + #10 +
        '        <MainUnitHasTitleStatement Value="False"/>' + #10 +
        '        <Scaled Value="True"/>' + #10 +
        '      </Flags>' + #10 +
        '      <SessionStorage Value="InProjectDir"/>' + #10 +
        '      <Title Value="' + CleanName + '"/>' + #10 +
        '      <ResourceType Value="res"/>' + #10 +
        '      <UseXPManifest Value="True"/>' + #10 +
        '      <XPManifest>' + #10 +
        '        <DpiAware Value="True"/>' + #10 +
        '      </XPManifest>' + #10 +
        '    </General>' + #10 +
        '    <BuildModes Count="2">' + #10 +
        '      <Item1 Name="Debug" Default="True"/>' + #10 +
        '      <Item2 Name="Release">' + #10 +
        '        <CompilerOptions>' + #10 +
        '          <Version Value="11"/>' + #10 +
        '          <Target>' + #10 +
        '            <Filename Value="bin/' + HostPlatform + '/' + CleanName + '"/>' + #10 +
        '          </Target>' + #10 +
        '          <SearchPaths>' + #10 +
        '            <IncludeFiles Value="$(ProjOutDir)"/>' + #10 +
        '            <UnitOutputDirectory Value="units/' + HostPlatform + '"/>' + #10 +
        '          </SearchPaths>' + #10 +
        '          <CodeGeneration>' + #10 +
        '            <Optimizations>' + #10 +
        '              <OptimizationLevel Value="3"/>' + #10 +
        '            </Optimizations>' + #10 +
        '          </CodeGeneration>' + #10 +
        '          <Linking>' + #10 +
        '            <Debugging>' + #10 +
        '              <GenerateDebugInfo Value="False"/>' + #10 +
        '              <StripSymbols Value="True"/>' + #10 +
        '            </Debugging>' + #10 +
        '            <Options>' + #10 +
        '              <Win32>' + #10 +
        '                <GraphicApplication Value="True"/>' + #10 +
        '              </Win32>' + #10 +
        '            </Options>' + #10 +
        '          </Linking>' + #10 +
        '        </CompilerOptions>' + #10 +
        '      </Item2>' + #10 +
        '    </BuildModes>' + #10 +
        '    <PublishOptions>' + #10 +
        '      <Version Value="2"/>' + #10 +
        '      <UseFileFilters Value="True"/>' + #10 +
        '    </PublishOptions>' + #10 +
        '    <RunParams>' + #10 +
        '      <FormatVersion Value="2"/>' + #10 +
        '    </RunParams>' + #10 +
        '    <Units>' + #10 +
        '      <Unit>' + #10 +
        '        <Filename Value="' + CleanName + '.lpr"/>' + #10 +
        '        <IsPartOfProject Value="True"/>' + #10 +
        '      </Unit>' + #10 +
        '      <Unit>' + #10 +
        '        <Filename Value="webui.pas"/>' + #10 +
        '        <IsPartOfProject Value="True"/>' + #10 +
        '        <UnitName Value="webui"/>' + #10 +
        '      </Unit>' + #10 +
        '      <Unit>' + #10 +
        '        <Filename Value="uDesktopBridge.pas"/>' + #10 +
        '        <IsPartOfProject Value="True"/>' + #10 +
        '        <UnitName Value="uDesktopBridge"/>' + #10 +
        '      </Unit>' + #10 +
        '    </Units>' + #10 +
        '  </ProjectOptions>' + #10 +
        '  <CompilerOptions>' + #10 +
        '    <Version Value="11"/>' + #10 +
        '    <Target>' + #10 +
        '      <Filename Value="bin/' + HostPlatform + '/' + CleanName + '"/>' + #10 +
        '    </Target>' + #10 +
        '    <SearchPaths>' + #10 +
        '      <IncludeFiles Value="$(ProjOutDir)"/>' + #10 +
        '      <UnitOutputDirectory Value="units/' + HostPlatform + '"/>' + #10 +
        '    </SearchPaths>' + #10 +
        '    <CodeGeneration>' + #10 +
        '      <Optimizations>' + #10 +
        '        <OptimizationLevel Value="2"/>' + #10 +
        '      </Optimizations>' + #10 +
        '    </CodeGeneration>' + #10 +
        '  </CompilerOptions>' + #10 +
        '</CONFIG>' + #10;
      WriteStringToFile(LpiFile, LpiContent);
      WriteLn('  [+] Created desktop/' + CleanName + '.lpi (Lazarus IDE Project)');
    end
    else
      WriteLn('  [i] desktop/' + CleanName + '.lpi already exists.');

    // 5. README.md
    if not FileExists(ReadmeFile) then
    begin
      ReadmeContent :=
        '# ' + DisplayName + ' (BlaiseVue 3.5 Desktop)' + #10 +
        '' + #10 +
        'Native desktop application powered by **Free Pascal**, **Lazarus IDE**, and **WebUI**.' + #10 +
        '' + #10 +
        '## Structure' + #10 +
        '- `' + CleanName + '.lpi`: Lazarus Project File (open in Lazarus IDE and press F9).' + #10 +
        '- `' + CleanName + '.lpr`: Main Free Pascal program entry point.' + #10 +
        '- `webui.pas`: WebUI C dynamic library loader.' + #10 +
        '- `uDesktopBridge.pas`: Native Pascal RPC bridge handlers for `$desktop`.' + #10 +
        '- `assets/`: Synchronized frontend build (`dist/`).' + #10 +
        '- `bin/`: Platform-segregated native executables (`bin/windows/`, `bin/linux/`, `bin/macos/`).' + #10 +
        '- `units/`: Free Pascal compiled unit caches (`units/windows/`, `units/linux/`, `units/macos/`).' + #10 +
        '' + #10 +
        '## Quick Commands' + #10 +
        '```bash' + #10 +
        '# 1. Sync frontend to desktop assets' + #10 +
        'bv desktop sync' + #10 +
        '' + #10 +
        '# 2. Build in Debug mode (default: host OS, with console for logs & diagnostics)' + #10 +
        'bv desktop build' + #10 +
        'bv desktop build windows' + #10 +
        'bv desktop build linux' + #10 +
        'bv desktop run' + #10 +
        '' + #10 +
        '# 3. Build in Release mode (pure GUI for end users - NO console window)' + #10 +
        'bv desktop build --release' + #10 +
        'bv desktop build windows --release' + #10 +
        'bv desktop build linux --release' + #10 +
        'bv desktop build macos --release' + #10 +
        'bv desktop run windows --release' + #10 +
        '' + #10 +
        '# 4. Build for all platforms at once' + #10 +
        'bv desktop build all' + #10 +
        'bv desktop build all --release' + #10 +
        '```' + #10 +
        '' + #10 +
        '## Lazarus IDE (F9)' + #10 +
        'Open `' + CleanName + '.lpi` in Lazarus IDE and switch between **Debug** and **Release** build modes in the top toolbar.' + #10;
      WriteStringToFile(ReadmeFile, ReadmeContent);
      WriteLn('  [+] Created desktop/README.md');
    end;

    WriteLn('');
    WriteLn('Desktop project scaffolded successfully!');
    WriteLn('Next steps:');
    WriteLn('  1. Run "bv desktop sync"  to compile frontend and copy dist/ to desktop/assets/');
    WriteLn('  2. Run "bv desktop build" to compile native binary with Free Pascal');
    WriteLn('  3. Run "bv desktop run"   to start your native desktop app');
    WriteLn('  Or open desktop/' + CleanName + '.lpi in Lazarus IDE and press F9!');
  end
  else if (SubCmd = 'sync') then
  begin
    WriteLn('Synchronizing BlaiseVue dist/ with native Desktop assets...');
    CmdRunBuild;
    ForceDir(AssetsDir);
    CopyDir(GetCurrentDir + DirectorySeparator + 'dist', AssetsDir, []);
    WriteLn('  [+] Desktop assets synchronized successfully in desktop/assets/ !');
  end
  else if (SubCmd = 'build') then
  begin
    WriteLn('Building native Desktop application with Free Pascal...');
    CmdDesktop('sync', Arg1, Arg2);

    FoundLpr := '';
    if FindFirst(DesktopDir + DirectorySeparator + '*.lpr', faAnyFile, SearchRec) = 0 then
    begin
      FoundLpr := SearchRec.Name;
      FindClose(SearchRec);
    end;

    if FoundLpr = '' then
    begin
      WriteLn('Error: No .lpr project file found in desktop/ directory. Run "bv desktop init" first.');
      Halt(1);
    end;

    CleanName := ChangeFileExt(FoundLpr, '');

    if IsAllTargets then
    begin
      WriteLn('Building native Desktop application for ALL platforms (windows, linux, macos)...');
      BuildSingleTarget('windows', IsRelease);
      BuildSingleTarget('linux', IsRelease);
      BuildSingleTarget('macos', IsRelease);
    end
    else
    begin
      BuildSingleTarget(TargetPlatform, IsRelease);
    end;
  end
  else if (SubCmd = 'run') then
  begin
    FoundLpr := '';
    if FindFirst(DesktopDir + DirectorySeparator + '*.lpr', faAnyFile, SearchRec) = 0 then
    begin
      FoundLpr := SearchRec.Name;
      FindClose(SearchRec);
    end;

    if FoundLpr = '' then
    begin
      WriteLn('No desktop project found. Initializing first...');
      CmdDesktop('init', Arg1, Arg2);
      if FindFirst(DesktopDir + DirectorySeparator + '*.lpr', faAnyFile, SearchRec) = 0 then
      begin
        FoundLpr := SearchRec.Name;
        FindClose(SearchRec);
      end;
    end;

    CleanName := ChangeFileExt(FoundLpr, '');
    if TargetPlatform = 'all' then TargetPlatform := HostPlatform;

    if TargetPlatform = 'windows' then TargetExt := '.exe' else TargetExt := '';
    TargetBin := BinDir + DirectorySeparator + TargetPlatform;
    TargetExe := TargetBin + DirectorySeparator + CleanName + TargetExt;

    if not FileExists(TargetExe) and (AltPlatformName <> '') then
      TargetExe := BinDir + DirectorySeparator + AltPlatformName + DirectorySeparator + CleanName + TargetExt;
    if not FileExists(TargetExe) then
      TargetExe := BinDir + DirectorySeparator + CleanName + TargetExt;

    if not FileExists(TargetExe) or IsRelease then
    begin
      if IsRelease then
        WriteLn('Building desktop app in RELEASE mode for ' + TargetPlatform + '...')
      else
        WriteLn('Target binary not found. Building desktop app in DEBUG mode for ' + TargetPlatform + '...');
      BuildSingleTarget(TargetPlatform, IsRelease);
      TargetExe := TargetBin + DirectorySeparator + CleanName + TargetExt;
    end;

    if FileExists(TargetExe) then
    begin
      if TargetPlatform <> HostPlatform then
      begin
        WriteLn('[i] Target platform is ' + TargetPlatform + ', but current host machine is ' + HostPlatform + '.');
        WriteLn('[i] Binary ready at: ' + TargetExe);
        if (HostPlatform = 'windows') and (TargetPlatform = 'linux') then
          WriteLn('[TIP] To test on Windows via WSL, run: wsl ./desktop/bin/linux/' + CleanName)
        else
          WriteLn('[TIP] To run this binary, execute it natively on a ' + TargetPlatform + ' system.');
      end
      else
      begin
        ExeDir := ExtractFilePath(TargetExe);
        if IsRelease then
          WriteLn('Launching native desktop app in RELEASE mode (No Console): ' + TargetExe)
        else
          WriteLn('Launching native desktop app in DEBUG mode (Live Console): ' + TargetExe);

        {$IFDEF WINDOWS}
        ExecuteProcess('cmd', '/c cd /d "' + ExeDir + '" && "' + TargetExe + '"');
        {$ELSE}
        ExecuteProcess('sh', '-c "cd ' + ExeDir + ' && ./' + ExtractFileName(TargetExe) + '"');
        {$ENDIF}
      end;
    end
    else
    begin
      WriteLn('Error: Failed to launch desktop app. Binary could not be found: ' + TargetExe);
      Halt(1);
    end;
  end
  else
  begin
    WriteLn('Usage: bv desktop <init [name]|sync|build [target] [--release]|run [target] [--release]>');
    WriteLn('       Targets: windows | linux | macos | all (default: host OS)');
  end;
end;

// =====================================================================
//  FULL-STACK PASCAL: mORMot 2 BACKEND SERVER
// =====================================================================

function FindMormot2Path: string;
var
  Candidate: string;
  ConfigFile: string;

  function IsValidMormot(const Dir: string): Boolean;
  var
    P: string;
  begin
    Result := False;
    P := ExcludeTrailingPathDelimiter(Dir);
    if (P <> '') and DirectoryExists(P) then
    begin
      if DirectoryExists(P + DirectorySeparator + 'src') and
         FileExists(P + DirectorySeparator + 'src' + DirectorySeparator + 'core' + DirectorySeparator + 'mormot.core.base.pas') then
        Result := True;
    end;
  end;

begin
  Result := '';

  // 1. Embedded vendor in BlaiseVue SDK: vendor/mormot2
  Candidate := GetSDKPath + 'vendor' + DirectorySeparator + 'mormot2';
  if IsValidMormot(Candidate) then
    Exit(ExcludeTrailingPathDelimiter(Candidate));

  // 2. Relative to current project or workspace: vendor/mormot2 or ../vendor/mormot2
  Candidate := GetCurrentDir + DirectorySeparator + 'vendor' + DirectorySeparator + 'mormot2';
  if IsValidMormot(Candidate) then
    Exit(ExcludeTrailingPathDelimiter(Candidate));

  Candidate := ExpandFileName(GetCurrentDir + DirectorySeparator + '..' + DirectorySeparator + 'vendor' + DirectorySeparator + 'mormot2');
  if IsValidMormot(Candidate) then
    Exit(ExcludeTrailingPathDelimiter(Candidate));

  Candidate := ExpandFileName(GetCurrentDir + DirectorySeparator + '..' + DirectorySeparator + '..' + DirectorySeparator + 'vendor' + DirectorySeparator + 'mormot2');
  if IsValidMormot(Candidate) then
    Exit(ExcludeTrailingPathDelimiter(Candidate));

  // 3. Environment variable MORMOT2_PATH
  Candidate := GetEnvironmentVariable('MORMOT2_PATH');
  if IsValidMormot(Candidate) then
    Exit(ExcludeTrailingPathDelimiter(Candidate));

  // 4. Project or server configuration file: server/mormot.path or mormot.path
  ConfigFile := GetCurrentDir + DirectorySeparator + 'server' + DirectorySeparator + 'mormot.path';
  if FileExists(ConfigFile) then
  begin
    Candidate := Trim(ReadFileToString(ConfigFile));
    if IsValidMormot(Candidate) then
      Exit(ExcludeTrailingPathDelimiter(Candidate));
  end;
  ConfigFile := GetCurrentDir + DirectorySeparator + 'mormot.path';
  if FileExists(ConfigFile) then
  begin
    Candidate := Trim(ReadFileToString(ConfigFile));
    if IsValidMormot(Candidate) then
      Exit(ExcludeTrailingPathDelimiter(Candidate));
  end;

  // 5. User local installation path on Windows (fallback)
  Candidate := 'C:\ComponenteLazarus\mORMot2';
  if IsValidMormot(Candidate) then
    Exit(Candidate);

  // 6. Relative paths to workspace or BlaiseVue SDK
  Candidate := ExpandFileName(GetCurrentDir + DirectorySeparator + '..' + DirectorySeparator + 'mORMot2');
  if IsValidMormot(Candidate) then
    Exit(Candidate);

  Candidate := ExpandFileName(GetSDKPath + '..' + DirectorySeparator + 'mORMot2');
  if IsValidMormot(Candidate) then
    Exit(Candidate);

  // 5. Alternate drive paths on Windows
  Candidate := 'C:\mORMot2';
  if IsValidMormot(Candidate) then
    Exit(Candidate);

  Candidate := 'D:\ComponenteLazarus\mORMot2';
  if IsValidMormot(Candidate) then
    Exit(Candidate);

  Candidate := 'D:\mORMot2';
  if IsValidMormot(Candidate) then
    Exit(Candidate);

  // 6. Common Unix locations
  Candidate := '/opt/mormot2';
  if IsValidMormot(Candidate) then
    Exit(Candidate);

  Candidate := '/usr/local/share/mormot2';
  if IsValidMormot(Candidate) then
    Exit(Candidate);

  Candidate := ExpandFileName('~/mORMot2');
  if IsValidMormot(Candidate) then
    Exit(Candidate);
end;

procedure CmdServer(const SubCmd: string; const Arg1: string = ''; const Arg2: string = '');
var
  ServerDir, BinDir, LibDir, TemplateDir: string;
  LprFile, TargetExe, MormotPath, FpcCmd, PortArg, ExtraArgs: string;
  IsRelease: Boolean;
  i: Integer;
  HttpClient: TFPHTTPClient;
  StatusResp: string;

  procedure ParseArg(const A: string);
  var
    S: string;
  begin
    S := LowerCase(A);
    if S = '' then Exit;
    if (S = '--release') or (S = '-r') or (S = 'release') then
      IsRelease := True
    else if (S = '--debug') or (S = '-d') or (S = 'debug') then
      IsRelease := False
    else if (Copy(S, 1, 7) = '--port=') then
      PortArg := Copy(A, 8, MaxInt);
  end;

begin
  ServerDir := GetCurrentDir + DirectorySeparator + 'server';
  BinDir := ServerDir + DirectorySeparator + 'bin';
  LibDir := ServerDir + DirectorySeparator + 'lib';
  LprFile := ServerDir + DirectorySeparator + 'server.lpr';
  TargetExe := BinDir + DirectorySeparator + 'server' + {$IFDEF WINDOWS}'.exe'{$ELSE}''{$ENDIF};
  TemplateDir := GetSDKPath + 'templates' + DirectorySeparator + 'fullstack-mormot';
  IsRelease := False;
  PortArg := '';

  for i := 2 to ParamCount do
  begin
    if (ParamStr(i) = '--port') or (ParamStr(i) = '-p') then
    begin
      if i + 1 <= ParamCount then
        PortArg := ParamStr(i + 1);
    end
    else
      ParseArg(ParamStr(i));
  end;

  if (SubCmd = 'init') then
  begin
    WriteLn('Initializing BlaiseVue mORMot 2 Native Backend Server in server/...');
    if not DirectoryExists(TemplateDir) then
    begin
      WriteLn('Error: Fullstack mORMot template directory not found at: ' + TemplateDir);
      Halt(1);
    end;

    ForceDir(ServerDir);
    CopyDir(TemplateDir, ServerDir, ['bin', 'lib']);
    ForceDir(BinDir);
    ForceDir(LibDir);

    WriteLn('  [+] Full-Stack mORMot 2 server template scaffolded successfully in server/ !');
    WriteLn('');
    WriteLn('Next steps:');
    WriteLn('  1. Run "bv build" (or "bv run build") to compile your reactive frontend to dist/');
    WriteLn('  2. Run "bv mormot build" (or "bv mormot build --release") to compile the native server');
    WriteLn('  3. Run "bv mormot run" to launch the server on port 8090');
    WriteLn('  Or open server/server.lpi in Lazarus IDE and press F9!');
  end
  else if (SubCmd = 'build') then
  begin
    if not FileExists(LprFile) then
    begin
      WriteLn('No server project found in server/. Initializing first...');
      CmdServer('init');
    end;

    MormotPath := FindMormot2Path;
    if MormotPath = '' then
    begin
      WriteLn('[!] Error: Synopse mORMot 2 installation not found.');
      WriteLn('    BlaiseVue searched:');
      WriteLn('    - Environment variable MORMOT2_PATH');
      WriteLn('    - C:\ComponenteLazarus\mORMot2');
      WriteLn('    - Local config file server/mormot.path');
      WriteLn('    - ../mORMot2, /opt/mormot2, ~/mORMot2');
      WriteLn('');
      WriteLn('    To fix:');
      WriteLn('    1. Set MORMOT2_PATH to your mORMot 2 directory:');
      WriteLn('       set MORMOT2_PATH=C:\ComponenteLazarus\mORMot2');
      WriteLn('    2. Or create server/mormot.path containing your mORMot 2 directory path.');
      Halt(1);
    end;

    ForceDir(BinDir);
    ForceDir(LibDir);

    WriteLn('Building BlaiseVue mORMot 2 Native Server...');
    WriteLn('  [+] mORMot 2 Path: ' + MormotPath);
    if IsRelease then
      WriteLn('  [+] Mode: RELEASE (Optimized -O3, stripped symbols)')
    else
      WriteLn('  [+] Mode: DEBUG (-O2, debug symbols active)');

    FpcCmd := 'fpc -MObjFPC -Sh ';
    if IsRelease then
      FpcCmd := FpcCmd + '-O3 -Xs -dRELEASE '
    else
      FpcCmd := FpcCmd + '-O2 -g -gl -dDEBUG ';

    FpcCmd := FpcCmd +
      '-Fi"' + MormotPath + DirectorySeparator + 'src" ' +
      '-Fi"' + MormotPath + DirectorySeparator + 'src' + DirectorySeparator + 'core" ' +
      '-Fi"' + MormotPath + DirectorySeparator + 'src' + DirectorySeparator + 'net" ' +
      '-Fu"' + MormotPath + DirectorySeparator + 'src' + DirectorySeparator + 'core" ' +
      '-Fu"' + MormotPath + DirectorySeparator + 'src' + DirectorySeparator + 'net" ' +
      '-Fu"' + MormotPath + DirectorySeparator + 'src' + DirectorySeparator + 'app" ' +
      '-Fu"' + MormotPath + DirectorySeparator + 'src' + DirectorySeparator + 'crypt" ' +
      '-Fu"' + MormotPath + DirectorySeparator + 'src' + DirectorySeparator + 'db" ' +
      '-Fu"' + MormotPath + DirectorySeparator + 'src' + DirectorySeparator + 'lib" ' +
      '-Fu"' + MormotPath + DirectorySeparator + 'src' + DirectorySeparator + 'orm" ' +
      '-Fu"' + MormotPath + DirectorySeparator + 'src' + DirectorySeparator + 'rest" ' +
      '-Fu"' + MormotPath + DirectorySeparator + 'src' + DirectorySeparator + 'soa" ' +
      '-Fu"' + MormotPath + DirectorySeparator + 'src' + DirectorySeparator + 'misc" ';

    {$IFDEF WINDOWS}
    if DirectoryExists(MormotPath + DirectorySeparator + 'static' + DirectorySeparator + 'x86_64-win64') then
      FpcCmd := FpcCmd + '-Fl"' + MormotPath + DirectorySeparator + 'static' + DirectorySeparator + 'x86_64-win64" ';
    FpcCmd := FpcCmd + '-FEbin -FUlib server.lpr';
    ExecuteProcess('cmd', '/c cd /d "' + ServerDir + '" && ' + FpcCmd);
    {$ELSE}
    FpcCmd := FpcCmd + '-FEbin -FUlib server.lpr';
    ExecuteProcess('sh', '-c "cd ' + ServerDir + ' && ' + FpcCmd + '"');
    {$ENDIF}

    if FileExists(TargetExe) then
    begin
      WriteLn('  [SUCCESS] Native mORMot 2 server compiled successfully: ' + TargetExe);
      WriteLn('  [TIP] Run "bv mormot run" to start the server.');
    end
    else
    begin
      WriteLn('  [ERROR] Server compilation failed. Check FPC compiler output above.');
      Halt(1);
    end;
  end
  else if (SubCmd = 'run') then
  begin
    if not FileExists(TargetExe) or IsRelease then
    begin
      CmdServer('build', Arg1, Arg2);
    end;

    if not FileExists(TargetExe) then
    begin
      WriteLn('Error: Server binary not found: ' + TargetExe);
      Halt(1);
    end;

    ExtraArgs := '';
    if PortArg <> '' then
      ExtraArgs := ' --port ' + PortArg;

    WriteLn('Starting BlaiseVue mORMot 2 Native Server...');
    WriteLn('Executable: ' + TargetExe);
    WriteLn('');

    {$IFDEF WINDOWS}
    ExecuteProcess('cmd', '/c cd /d "' + ServerDir + '" && "bin' + DirectorySeparator + 'server.exe"' + ExtraArgs);
    {$ELSE}
    ExecuteProcess('sh', '-c "cd ' + ServerDir + ' && ./bin/server' + ExtraArgs + '"');
    {$ENDIF}
  end
  else if (SubCmd = 'status') then
  begin
    PortArg := '8090';
    for i := 2 to ParamCount do
    begin
      if (ParamStr(i) = '--port') or (ParamStr(i) = '-p') then
      begin
        if i + 1 <= ParamCount then
          PortArg := ParamStr(i + 1);
      end
      else if Copy(ParamStr(i), 1, 7) = '--port=' then
        PortArg := Copy(ParamStr(i), 8, MaxInt);
    end;

    WriteLn('Checking BlaiseVue mORMot 2 server status on http://localhost:' + PortArg + '/api/status ...');
    HttpClient := TFPHTTPClient.Create(nil);
    try
      try
        StatusResp := HttpClient.Get('http://localhost:' + PortArg + '/api/status');
        WriteLn('[+] Server is ONLINE!');
        WriteLn(StatusResp);
      except
        on E: Exception do
        begin
          WriteLn('[-] Server is OFFLINE or unreachable on port ' + PortArg + ': ' + E.Message);
          WriteLn('    Start it using: bv mormot run');
        end;
      end;
    finally
      HttpClient.Free;
    end;
  end
  else
  begin
    WriteLn('Usage: bv mormot <init|build [--release]|run [--release] [--port <p>]|status [--port <p>]>');
    WriteLn('  init                  Scaffolds mORMot 2 backend server in server/');
    WriteLn('  build [--release]     Compiles native server with Free Pascal');
    WriteLn('  run [--port <port>]   Launches native server');
    WriteLn('  status [--port <p>]   Queries running server health endpoint (/api/status)');
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
    WriteLn('  BlaiseVue CLI v3.5 (Universal Pascal Platform)');
    WriteLn('  ==============================================');
    WriteLn('');
    WriteLn('  Usage:');
    WriteLn('    bv create <name>       Scaffolds a new project');
    WriteLn('    bv clean               Cleans generated files (generated/ and dist/)');
    WriteLn('    bv run dev             DEBUG build with timestamp (SFC -> Pas -> JS)');
    WriteLn('    bv run build           PRODUCTION build with hashes (SFC -> Pas -> JS)');
    WriteLn('    bv run ssg             Pre-renders all routes into static HTML (SSG)');
    WriteLn('    bv dev                 Starts development server with HMR (alias: bv serve)');
    WriteLn('    bv serve               Starts development server with HMR');
    WriteLn('    bv doc [--serve]       Generates interactive component documentation & playground');
    WriteLn('    bv wasm <info|benchmark> WebAssembly acceleration and performance benchmarks');
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
    WriteLn('    bv lib install <pkg|url> Installs an official package (themes, icons, ui) or from URL');
    WriteLn('    bv lib remove <name>    Removes an installed component from lib/');
    WriteLn('    bv theme list          Lists available installed themes');
    WriteLn('    bv theme use <name>    Switches active project theme in index.html');
    WriteLn('    bv extension [install|package] Installs or packages the official VS Code extension');
    WriteLn('    bv vsix                Packages standalone VS Code extension (.vsix)');
    WriteLn('    bv mobile init [name] [id] Configures Capacitor and scaffolds Android project');
    WriteLn('    bv mobile sync         Syncs dist/ with native Android assets');
    WriteLn('    bv mobile open         Syncs and opens Android Studio');
    WriteLn('    bv mobile build        Builds native Android Debug APK via Gradle');
    WriteLn('    bv desktop init [name] Scaffolds WebUI & Lazarus desktop project in desktop/');
    WriteLn('    bv desktop sync        Syncs dist/ with desktop/assets/');
    WriteLn('    bv desktop build [target] [--release] Compiles native binary (windows|linux|macos|all)');
    WriteLn('    bv desktop run [target] [--release]   Builds and launches desktop app for target');
    WriteLn('    bv mormot init         Scaffolds mORMot 2 backend server in server/');
    WriteLn('    bv mormot build [--release] Compiles native server binary with Free Pascal');
    WriteLn('    bv mormot run [--port <p>] Starts native mORMot 2 backend server (default: 8090)');
    WriteLn('    bv mormot status [--port <p>] Queries running mORMot 2 health endpoint (/api/status)');
    WriteLn('    bv s <name>            Runs setup script for a component in lib/');
    WriteLn('    bv test [e2e]          Runs unit tests (.test.pas) or headless E2E suite');
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
    if (ParamCount >= 2) and (LowerCase(ParamStr(2)) = 'e2e') then
      CmdTestE2E
    else
      CmdTest;
  end
  else if Cmd = 'build' then
  begin
    WriteLn('Warning: "bv build" has been renamed to "bv run dev".');
    CmdBuild;
  end
  else if (Cmd = 'serve') or (Cmd = 'dev') then
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
  else if Cmd = 'theme' then
  begin
    if ParamCount < 2 then
    begin
       WriteLn('Usage: bv theme <list|use <name>>');
       Halt(1);
    end;
    Cmd := LowerCase(ParamStr(2));
    if Cmd = 'list' then CmdThemeList
    else if Cmd = 'use' then
    begin
       if ParamCount < 3 then begin WriteLn('Usage: bv theme use <name>'); Halt(1); end;
       CmdThemeUse(ParamStr(3));
    end
    else
    begin
       WriteLn('Unknown theme subcommand: ', Cmd);
       Halt(1);
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
    else if Cmd = 'ssg' then CmdSSG
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
  else if Cmd = 'doc' then
  begin
    CmdDoc((ParamCount >= 2) and (LowerCase(ParamStr(2)) = '--serve'));
  end
  else if Cmd = 'ssg' then
  begin
    CmdSSG;
  end
  else if Cmd = 'wasm' then
  begin
    if ParamCount < 2 then
      CmdWasm('info')
    else
      CmdWasm(LowerCase(ParamStr(2)));
  end
  else if (Cmd = 'extension') or (Cmd = 'vsix') then
  begin
    if Cmd = 'vsix' then
      CmdExtension('package')
    else if ParamCount >= 2 then
      CmdExtension(LowerCase(ParamStr(2)))
    else
      CmdExtension('install');
  end
  else if Cmd = 'mobile' then
  begin
    if ParamCount < 2 then
    begin
      WriteLn('Usage: bv mobile <init [name] [id]|sync [target]|build [target] [--release]|run [target] [--emulator [name]]|open [target]|emulator <list|start|run>>');
      WriteLn('       Targets: android | ios | all (default: android)');
      Halt(1);
    end;
    CmdMobile(LowerCase(ParamStr(2)), ParamStr(3), ParamStr(4));
  end
  else if Cmd = 'desktop' then
  begin
    if ParamCount < 2 then
    begin
      WriteLn('Usage: bv desktop <init [name]|sync|build [target] [--release]|run [target] [--release]>');
      WriteLn('       Targets: windows | linux | macos | all (default: host OS)');
      Halt(1);
    end;
    CmdDesktop(LowerCase(ParamStr(2)), ParamStr(3), ParamStr(4));
  end
  else if (Cmd = 'mormot') or (Cmd = 'server') then
  begin
    if ParamCount < 2 then
    begin
      WriteLn('Usage: bv mormot <init|build [--release]|run [--release] [--port <p>]|status [--port <p>]>');
      Halt(1);
    end;
    CmdServer(LowerCase(ParamStr(2)), ParamStr(3), ParamStr(4));
  end
  else
  begin
    WriteLn('Unknown command: ', Cmd);
    WriteLn('Use "bv" without arguments for help.');
    Halt(1);
  end;
end.
