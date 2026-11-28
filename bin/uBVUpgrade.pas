unit uBVUpgrade;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, StrUtils, DateUtils, Process, fpjson, jsonparser;

type
  TBVUpgradeOptions = record
    CheckOnly: Boolean;
    FromSource: Boolean;
    BinaryMode: Boolean;
    Rollback: Boolean;
    DryRun: Boolean;
    Force: Boolean;
    Nightly: Boolean;
    AllowUnsigned: Boolean;
    Channel: string;
    TargetVersion: string;
    CustomUrl: string;
  end;

  { TBVUpgrade }
  TBVUpgrade = class
  public
    class function SHA256String(const S: string): string;
    class function SHA256File(const AFilePath: string): string;
    class function CompareSemVer(const V1, V2: string): Integer;

    class function CopyFileStream(const SrcPath, DstPath: string): Boolean;
    class function CopyDirectoryRecursive(const SrcDir, DstDir: string): Boolean;
    class function DeleteDirectoryRecursive(const DirPath: string): Boolean;
    class procedure EnsureExecutableBit(const FilePath: string);

    class function FileUrlToLocalPath(const Url: string): string;
    class function FetchUrlText(const Url: string; var OutText: string): Integer;
    class function DownloadUrlToFile(const Url, DstFile: string): Boolean;
    class function ExtractArchive(const ArchivePath, DstDir: string; out ErrMsg: string): Boolean;
    class function RunProcessWithOutput(const Executable, Params: string; var OutputLog: string): Integer;
    class function RunCommandStream(const CommandLineStr: string): Integer;
    class function DetectPlatform(out OSName, ArchName: string): Boolean;
    class function GetCurrentExePath: string;
    class procedure CleanupStaleOldBinary(const BinDir: string);

    class function NormalizeChannelName(const RawChannel: string): string;
    class function IsValidChannel(const ChannelName: string): Boolean;
    class function GetBlaiseVueConfigDir: string;
    class function GetConfigFilePath: string;
    class function GetConfiguredChannel(out SourceLabel: string): string; overload;
    class function GetConfiguredChannel: string; overload;
    class function SetConfiguredChannel(const NewChannel: string; out ErrorMsg: string): Boolean;

    class function GetReleasesRepo: string;
    class function FetchReleaseMetadata(const Repo, VersionTag, CustomUrl: string;
      Nightly: Boolean;
      out TagName, ReleaseNotes, AssetUrl, AssetName, ChecksumUrl, ChecksumValue: string;
      out ErrorMsg: string): Boolean;
    class function FetchAvailableReleaseTags(const Repo: string; Tags: TStringList;
      out ErrorMsg: string): Boolean;

    class procedure HandleBinaryUpgrade(const SDKDir, ExePath, CurVersion: string;
      const Opts: TBVUpgradeOptions);
    class function HandleBinaryRollback(const SDKDir: string; DryRun: Boolean): Boolean;
    class function DownloadFrameworkVersionBinary(const Repo, TargetVer, DestDir: string;
      AllowUnsigned: Boolean; out InstalledTag, ErrMsg: string): Boolean;
    class function EnsureDemoAppTemplate(const SDKDir, Repo, BranchOrTag: string;
      out ResolvedDemoDir, ErrMsg: string): Boolean;
    class function DownloadMormot2Archive(const TargetTag, DestDir: string;
      out ErrMsg: string): Boolean;
  end;

implementation

const
  K256: array[0..63] of Cardinal = (
    $428a2f98, $71374491, $b5c0fbcf, $e9b5dba5, $3956c25b, $59f111f1, $923f82a4, $ab1c5ed5,
    $d807aa98, $12835b01, $243185be, $550c7dc3, $72be5d74, $80deb1fe, $9bdc06a7, $c19bf174,
    $e49b69c1, $efbe4786, $0fc19dc6, $240ca1cc, $2de92c6f, $4a7484aa, $5cb0a9dc, $76f988da,
    $983e5152, $a831c66d, $b00327c8, $bf597fc7, $c6e00bf3, $d5a79147, $06ca6351, $14292967,
    $27b70a85, $2e1b2138, $4d2c6dfc, $53380d13, $650a7354, $766a0abb, $81c2c92e, $92722c85,
    $a2bfe8a1, $a81a664b, $c24b8b70, $c76c51a3, $d192e819, $d6990624, $f40e3585, $106aa070,
    $19a4c116, $1e376c08, $2748774c, $34b0bcb5, $391c0cb3, $4ed8aa4a, $5b9cca4f, $682e6ff3,
    $748f82ee, $78a5636f, $84c87814, $8cc70208, $90befffa, $a4506ceb, $bef9a3f7, $c67178f2
  );

type
  TSHA256Context = record
    State: array[0..7] of Cardinal;
    Count: QWord;
    Buffer: array[0..63] of Byte;
  end;

function ROR(X: Cardinal; N: Byte): Cardinal; inline;
begin
  Result := (X shr N) or (X shl (32 - N));
end;

procedure SHA256Init(var Ctx: TSHA256Context);
begin
  Ctx.State[0] := $6a09e667;
  Ctx.State[1] := $bb67ae85;
  Ctx.State[2] := $3c6ef372;
  Ctx.State[3] := $a54ff53a;
  Ctx.State[4] := $510e527f;
  Ctx.State[5] := $9b05688c;
  Ctx.State[6] := $1f83d9ab;
  Ctx.State[7] := $5be0cd19;
  Ctx.Count := 0;
  FillChar(Ctx.Buffer, SizeOf(Ctx.Buffer), 0);
end;

procedure SHA256Transform(var Ctx: TSHA256Context; const Data: array of Byte; Offset: Integer);
var
  W: array[0..63] of Cardinal;
  A, B, C, D, E, F, G, H: Cardinal;
  S0, S1, Maj, Ch, Temp1, Temp2: Cardinal;
  I: Integer;
begin
  for I := 0 to 15 do
  begin
    W[I] := (Cardinal(Data[Offset + (I * 4)]) shl 24) or
            (Cardinal(Data[Offset + (I * 4) + 1]) shl 16) or
            (Cardinal(Data[Offset + (I * 4) + 2]) shl 8) or
            (Cardinal(Data[Offset + (I * 4) + 3]));
  end;

  for I := 16 to 63 do
  begin
    S0 := ROR(W[I - 15], 7) xor ROR(W[I - 15], 18) xor (W[I - 15] shr 3);
    S1 := ROR(W[I - 2], 17) xor ROR(W[I - 2], 19) xor (W[I - 2] shr 10);
    W[I] := W[I - 16] + S0 + W[I - 7] + S1;
  end;

  A := Ctx.State[0];
  B := Ctx.State[1];
  C := Ctx.State[2];
  D := Ctx.State[3];
  E := Ctx.State[4];
  F := Ctx.State[5];
  G := Ctx.State[6];
  H := Ctx.State[7];

  for I := 0 to 63 do
  begin
    S1 := ROR(E, 6) xor ROR(E, 11) xor ROR(E, 25);
    Ch := (E and F) xor ((not E) and G);
    Temp1 := H + S1 + Ch + K256[I] + W[I];
    S0 := ROR(A, 2) xor ROR(A, 13) xor ROR(A, 22);
    Maj := (A and B) xor (A and C) xor (B and C);
    Temp2 := S0 + Maj;

    H := G;
    G := F;
    F := E;
    E := D + Temp1;
    D := C;
    C := B;
    B := A;
    A := Temp1 + Temp2;
  end;

  Inc(Ctx.State[0], A);
  Inc(Ctx.State[1], B);
  Inc(Ctx.State[2], C);
  Inc(Ctx.State[3], D);
  Inc(Ctx.State[4], E);
  Inc(Ctx.State[5], F);
  Inc(Ctx.State[6], G);
  Inc(Ctx.State[7], H);
end;

procedure SHA256Update(var Ctx: TSHA256Context; const Data: PByte; Len: Cardinal);
var
  Left, Fill, P: Cardinal;
begin
  if Len = 0 then Exit;
  Left := Cardinal(Ctx.Count and $3F);
  Fill := 64 - Left;
  Inc(Ctx.Count, Len);
  P := 0;

  if (Left > 0) and (Len >= Fill) then
  begin
    Move(Data[0], Ctx.Buffer[Left], Fill);
    SHA256Transform(Ctx, Ctx.Buffer, 0);
    P := Fill;
    Dec(Len, Fill);
    Left := 0;
  end;

  while Len >= 64 do
  begin
    SHA256Transform(Ctx, PByteArray(Data)^, P);
    Inc(P, 64);
    Dec(Len, 64);
  end;

  if Len > 0 then
    Move(Data[P], Ctx.Buffer[Left], Len);
end;

function SHA256Final(var Ctx: TSHA256Context): string;
var
  Bits: QWord;
  PadLen: Cardinal;
  Padding: array[0..63] of Byte;
  BitBytes: array[0..7] of Byte;
  I: Integer;
begin
  Bits := Ctx.Count * 8;
  for I := 0 to 7 do
    BitBytes[7 - I] := Byte((Bits shr (I * 8)) and $FF);

  FillChar(Padding, SizeOf(Padding), 0);
  Padding[0] := $80;

  if (Ctx.Count and $3F) < 56 then
    PadLen := 56 - Cardinal(Ctx.Count and $3F)
  else
    PadLen := 120 - Cardinal(Ctx.Count and $3F);

  SHA256Update(Ctx, @Padding[0], PadLen);
  SHA256Update(Ctx, @BitBytes[0], 8);

  Result := '';
  for I := 0 to 7 do
    Result := Result + IntToHex(Ctx.State[I], 8);
  Result := LowerCase(Result);
end;

class function TBVUpgrade.SHA256String(const S: string): string;
var
  Ctx: TSHA256Context;
begin
  SHA256Init(Ctx);
  if Length(S) > 0 then
    SHA256Update(Ctx, PByte(@S[1]), Length(S));
  Result := SHA256Final(Ctx);
end;

class function TBVUpgrade.SHA256File(const AFilePath: string): string;
var
  F: TFileStream;
  Ctx: TSHA256Context;
  Buffer: array[0..65535] of Byte;
  BytesRead: Integer;
begin
  if not FileExists(AFilePath) then
    Exit('');

  try
    F := TFileStream.Create(AFilePath, fmOpenRead or fmShareDenyNone);
    try
      SHA256Init(Ctx);
      repeat
        BytesRead := F.Read(Buffer, SizeOf(Buffer));
        if BytesRead > 0 then
          SHA256Update(Ctx, @Buffer[0], BytesRead);
      until BytesRead <= 0;
      Result := SHA256Final(Ctx);
    finally
      F.Free;
    end;
  except
    Result := '';
  end;
end;

function ParseSemVer(const RawVer: string; out Maj, Min, Pat: Integer): Boolean;
var
  Clean: string;
  DashPos, PlusPos: Integer;
  Parts: TStringArray;
begin
  Maj := 0;
  Min := 0;
  Pat := 0;
  Result := False;
  Clean := Trim(RawVer);
  if Clean = '' then Exit;
  if (Clean[1] = 'v') or (Clean[1] = 'V') then
    Delete(Clean, 1, 1);

  DashPos := Pos('-', Clean);
  if DashPos > 0 then Clean := Copy(Clean, 1, DashPos - 1);
  PlusPos := Pos('+', Clean);
  if PlusPos > 0 then Clean := Copy(Clean, 1, PlusPos - 1);

  Parts := Clean.Split(['.']);
  if Length(Parts) = 0 then Exit;
  if not TryStrToInt(Parts[0], Maj) then Exit;
  if Length(Parts) > 1 then
  begin
    if not TryStrToInt(Parts[1], Min) then Exit;
  end;
  if Length(Parts) > 2 then
  begin
    if not TryStrToInt(Parts[2], Pat) then Exit;
  end;
  Result := True;
end;

class function TBVUpgrade.CompareSemVer(const V1, V2: string): Integer;
var
  Maj1, Min1, Pat1: Integer;
  Maj2, Min2, Pat2: Integer;
begin
  ParseSemVer(V1, Maj1, Min1, Pat1);
  ParseSemVer(V2, Maj2, Min2, Pat2);
  if Maj1 <> Maj2 then Exit(Maj1 - Maj2);
  if Min1 <> Min2 then Exit(Min1 - Min2);
  Exit(Pat1 - Pat2);
end;

class function TBVUpgrade.CopyFileStream(const SrcPath, DstPath: string): Boolean;
var
  SrcStream, DstStream: TFileStream;
begin
  Result := False;
  try
    if ExtractFileDir(DstPath) <> '' then
      ForceDirectories(ExtractFileDir(DstPath));
    SrcStream := TFileStream.Create(SrcPath, fmOpenRead or fmShareDenyWrite);
    try
      DstStream := TFileStream.Create(DstPath, fmCreate);
      try
        DstStream.CopyFrom(SrcStream, SrcStream.Size);
        Result := True;
      finally
        DstStream.Free;
      end;
    finally
      SrcStream.Free;
    end;
  except
    Result := False;
  end;
end;

class function TBVUpgrade.CopyDirectoryRecursive(const SrcDir, DstDir: string): Boolean;
var
  SR: TSearchRec;
  SrcItem, DstItem: string;
begin
  Result := True;
  if not DirectoryExists(SrcDir) then Exit(False);
  if not ForceDirectories(DstDir) then Exit(False);

  if SysUtils.FindFirst(IncludeTrailingPathDelimiter(SrcDir) + '*', faAnyFile, SR) = 0 then
  begin
    try
      repeat
        if (SR.Name = '.') or (SR.Name = '..') then Continue;
        SrcItem := IncludeTrailingPathDelimiter(SrcDir) + SR.Name;
        DstItem := IncludeTrailingPathDelimiter(DstDir) + SR.Name;
        if (SR.Attr and faDirectory) <> 0 then
        begin
          if not CopyDirectoryRecursive(SrcItem, DstItem) then
            Result := False;
        end
        else
        begin
          if not CopyFileStream(SrcItem, DstItem) then
            Result := False;
        end;
      until SysUtils.FindNext(SR) <> 0;
    finally
      SysUtils.FindClose(SR);
    end;
  end;
end;

class function TBVUpgrade.DeleteDirectoryRecursive(const DirPath: string): Boolean;
var
  SR: TSearchRec;
  ItemPath, CurrentExe: string;
begin
  Result := True;
  if not DirectoryExists(DirPath) then Exit(True);
  CurrentExe := ExpandFileName(GetCurrentExePath);
  if SysUtils.FindFirst(IncludeTrailingPathDelimiter(DirPath) + '*', faAnyFile, SR) = 0 then
  begin
    try
      repeat
        if (SR.Name = '.') or (SR.Name = '..') then Continue;
        ItemPath := IncludeTrailingPathDelimiter(DirPath) + SR.Name;
        if (SR.Attr and faDirectory) <> 0 then
        begin
          if not DeleteDirectoryRecursive(ItemPath) then
            Result := False;
        end
        else
        begin
          if not SameText(ExpandFileName(ItemPath), CurrentExe) then
          begin
            if not DeleteFile(ItemPath) then
              Result := False;
          end;
        end;
      until SysUtils.FindNext(SR) <> 0;
    finally
      SysUtils.FindClose(SR);
    end;
  end;
  if not RemoveDir(DirPath) then
    Result := False;
end;

class procedure TBVUpgrade.EnsureExecutableBit(const FilePath: string);
{$IFNDEF MSWINDOWS}
var
  LogText: string;
{$ENDIF}
begin
  {$IFNDEF MSWINDOWS}
  if FileExists(FilePath) then
    RunProcessWithOutput('chmod', '+x "' + FilePath + '"', LogText);
  {$ENDIF}
end;

class function TBVUpgrade.FileUrlToLocalPath(const Url: string): string;
var
  Raw: string;
begin
  Raw := Trim(Url);
  if Pos('file://', LowerCase(Raw)) <> 1 then Exit(Raw);
  Delete(Raw, 1, 7);
  {$IFDEF MSWINDOWS}
  while (Length(Raw) > 2) and (Raw[1] = '/') and (Raw[3] = ':') do
    Delete(Raw, 1, 1);
  if (Length(Raw) >= 2) and (Raw[1] = '/') and (Raw[2] <> '/') then
    Delete(Raw, 1, 1);
  Raw := StringReplace(Raw, '/', '\', [rfReplaceAll]);
  {$ENDIF}
  Raw := StringReplace(Raw, '%20', ' ', [rfReplaceAll]);
  Result := Raw;
end;

class function TBVUpgrade.FetchUrlText(const Url: string; var OutText: string): Integer;
var
  LocalPath, CurlCmd: string;
  FS: TFileStream;
  SS: TStringStream;
begin
  OutText := '';
  if Pos('file://', LowerCase(Trim(Url))) = 1 then
  begin
    LocalPath := FileUrlToLocalPath(Url);
    if not FileExists(LocalPath) then
    begin
      OutText := 'Local file not found: ' + LocalPath;
      Exit(1);
    end;
    FS := TFileStream.Create(LocalPath, fmOpenRead or fmShareDenyWrite);
    SS := TStringStream.Create('');
    try
      SS.CopyFrom(FS, FS.Size);
      OutText := Trim(SS.DataString);
      Exit(0);
    finally
      SS.Free;
      FS.Free;
    end;
  end;

  CurlCmd := Format('-sL -H "User-Agent: BlaiseVue-Upgrader" -H "Accept: application/vnd.github.v3+json" "%s"', [Url]);
  Result := RunProcessWithOutput('curl', CurlCmd, OutText);
end;

class function TBVUpgrade.DownloadUrlToFile(const Url, DstFile: string): Boolean;
var
  LocalPath, CurlCmd: string;
begin
  if Pos('file://', LowerCase(Trim(Url))) = 1 then
  begin
    LocalPath := FileUrlToLocalPath(Url);
    Exit(CopyFileStream(LocalPath, DstFile));
  end;

  if ExtractFileDir(DstFile) <> '' then
    ForceDirectories(ExtractFileDir(DstFile));
  CurlCmd := Format('-fSL -H "User-Agent: BlaiseVue-Upgrader" -o "%s" "%s"', [DstFile, Url]);
  Result := (RunCommandStream('curl ' + CurlCmd) = 0) and FileExists(DstFile);
end;

class function TBVUpgrade.ExtractArchive(const ArchivePath, DstDir: string; out ErrMsg: string): Boolean;
var
  ExtLow, TarCmd: string;
  ExitCode: Integer;
begin
  Result := False;
  ErrMsg := '';
  if not ForceDirectories(DstDir) then
  begin
    ErrMsg := 'Could not create extraction directory: ' + DstDir;
    Exit(False);
  end;

  ExtLow := LowerCase(ExtractFileExt(ArchivePath));
  {$IFDEF MSWINDOWS}
  if ExtLow = '.zip' then
  begin
    ExitCode := RunProcessWithOutput('powershell',
      Format('-NoProfile -Command "Expand-Archive -Force -Path ''%s'' -DestinationPath ''%s''"', [ArchivePath, DstDir]),
      ErrMsg);
    if ExitCode = 0 then Exit(True);
  end;
  {$ENDIF}

  TarCmd := Format('-xf "%s" -C "%s"', [ArchivePath, DstDir]);
  ExitCode := RunProcessWithOutput('tar', TarCmd, ErrMsg);
  if ExitCode = 0 then Exit(True);

  {$IFNDEF MSWINDOWS}
  if ExtLow = '.zip' then
  begin
    ExitCode := RunProcessWithOutput('unzip', Format('-oq "%s" -d "%s"', [ArchivePath, DstDir]), ErrMsg);
    if ExitCode = 0 then Exit(True);
  end;
  {$ENDIF}
end;

class function TBVUpgrade.RunProcessWithOutput(const Executable, Params: string; var OutputLog: string): Integer;
var
  Proc: TProcess;
  Buffer: array[0..4095] of Byte;
  BytesRead: LongInt;
  StringStream: TStringStream;
begin
  Result := -1;
  OutputLog := '';
  Proc := TProcess.Create(nil);
  StringStream := TStringStream.Create('');
  try
    Proc.Executable := Executable;
    {$PUSH}{$WARN 5044 OFF}
    Proc.CommandLine := '"' + Executable + '" ' + Params;
    {$POP}
    Proc.Options := [poUsePipes, poStderrToOutPut];
    Proc.ShowWindow := swoNone;
    try
      Proc.Execute;
      while Proc.Running or (Proc.Output.NumBytesAvailable > 0) do
      begin
        if Proc.Output.NumBytesAvailable > 0 then
        begin
          BytesRead := Proc.Output.Read(Buffer[0], SizeOf(Buffer));
          if BytesRead > 0 then
            StringStream.WriteBuffer(Buffer[0], BytesRead);
        end
        else
          Sleep(10);
      end;
      Result := Proc.ExitStatus;
      OutputLog := Trim(StringStream.DataString);
    except
      on E: Exception do
      begin
        OutputLog := E.Message;
        Result := -1;
      end;
    end;
  finally
    StringStream.Free;
    Proc.Free;
  end;
end;

class function TBVUpgrade.RunCommandStream(const CommandLineStr: string): Integer;
var
  Proc: TProcess;
  Buffer: array[0..2047] of Byte;
  BytesRead: LongInt;
  LineChunk: string;
begin
  Result := -1;
  Proc := TProcess.Create(nil);
  try
    {$PUSH}{$WARN 5044 OFF}
    Proc.CommandLine := CommandLineStr;
    {$POP}
    Proc.Options := [poUsePipes, poStderrToOutPut];
    Proc.ShowWindow := swoNone;
    try
      Proc.Execute;
      while Proc.Running or (Proc.Output.NumBytesAvailable > 0) do
      begin
        if Proc.Output.NumBytesAvailable > 0 then
        begin
          BytesRead := Proc.Output.Read(Buffer[0], SizeOf(Buffer) - 1);
          if BytesRead > 0 then
          begin
            Buffer[BytesRead] := 0;
            SetString(LineChunk, PAnsiChar(@Buffer[0]), BytesRead);
            Write(LineChunk);
          end;
        end
        else
          Sleep(15);
      end;
      Result := Proc.ExitStatus;
    except
      on E: Exception do
      begin
        WriteLn(ErrOutput, 'Error executing command: ', E.Message);
        Result := -1;
      end;
    end;
  finally
    Proc.Free;
  end;
end;

class function TBVUpgrade.DetectPlatform(out OSName, ArchName: string): Boolean;
begin
  {$IFDEF MSWINDOWS}
  OSName := 'windows';
  {$ELSE}
    {$IFDEF DARWIN}
    OSName := 'macos';
    {$ELSE}
    OSName := 'linux';
    {$ENDIF}
  {$ENDIF}

  {$IFDEF CPUX86_64}
  ArchName := 'x86_64';
  {$ELSE}
    {$IFDEF CPUAARCH64}
    ArchName := 'aarch64';
    {$ELSE}
      {$IFDEF CPUARM}
      ArchName := 'arm';
      {$ELSE}
      ArchName := 'x86';
      {$ENDIF}
    {$ENDIF}
  {$ENDIF}

  Result := True;
end;

class function TBVUpgrade.GetCurrentExePath: string;
begin
  Result := ParamStr(0);
  if not FileExists(Result) then
    Result := GetCurrentDir + PathDelim + ExtractFileName(ParamStr(0));
  Result := ExpandFileName(Result);
end;

class procedure TBVUpgrade.CleanupStaleOldBinary(const BinDir: string);
var
  OldExe: string;
begin
  {$IFDEF MSWINDOWS}
  OldExe := IncludeTrailingPathDelimiter(BinDir) + 'bv_old.exe';
  if FileExists(OldExe) then
    DeleteFile(OldExe);
  {$ENDIF}
end;

class function TBVUpgrade.NormalizeChannelName(const RawChannel: string): string;
var
  S: string;
begin
  S := LowerCase(Trim(RawChannel));
  if (S = 'stable') or (S = 'main') then
    Result := 'stable'
  else if (S = 'nightly') or (S = 'develop') or (S = 'dev') then
    Result := 'nightly'
  else
    Result := '';
end;

class function TBVUpgrade.IsValidChannel(const ChannelName: string): Boolean;
begin
  Result := NormalizeChannelName(ChannelName) <> '';
end;

class function TBVUpgrade.GetBlaiseVueConfigDir: string;
var
  HomeDir: string;
begin
  HomeDir := Trim(SysUtils.GetEnvironmentVariable('BLAISEVUE_HOME'));
  if HomeDir <> '' then
    Exit(ExcludeTrailingPathDelimiter(HomeDir));

  {$IFDEF MSWINDOWS}
  HomeDir := SysUtils.GetEnvironmentVariable('USERPROFILE');
  if HomeDir = '' then HomeDir := SysUtils.GetEnvironmentVariable('APPDATA');
  {$ELSE}
  HomeDir := SysUtils.GetEnvironmentVariable('HOME');
  {$ENDIF}
  if HomeDir = '' then
    Result := ''
  else
    Result := IncludeTrailingPathDelimiter(HomeDir) + '.blaisevue';
end;

class function TBVUpgrade.GetConfigFilePath: string;
var
  ConfigDir: string;
begin
  ConfigDir := GetBlaiseVueConfigDir;
  if ConfigDir = '' then
    Result := ''
  else
    Result := ConfigDir + PathDelim + 'config.json';
end;

class function TBVUpgrade.GetConfiguredChannel(out SourceLabel: string): string;
var
  EnvVal, ConfigPath, FileVal, Norm: string;
  SL: TStringList;
  JSON: TJSONData;
  Obj: TJSONObject;
begin
  Result := 'stable';
  SourceLabel := 'default';

  EnvVal := Trim(SysUtils.GetEnvironmentVariable('BLAISEVUE_CHANNEL'));
  Norm := NormalizeChannelName(EnvVal);
  if Norm <> '' then
  begin
    Result := Norm;
    SourceLabel := 'env (BLAISEVUE_CHANNEL)';
    Exit;
  end;

  ConfigPath := GetConfigFilePath;
  if (ConfigPath <> '') and FileExists(ConfigPath) then
  begin
    SL := TStringList.Create;
    JSON := nil;
    try
      try
        SL.LoadFromFile(ConfigPath);
        JSON := GetJSON(SL.Text);
        if (JSON <> nil) and (JSON.JSONType = jtObject) then
        begin
          Obj := TJSONObject(JSON);
          FileVal := Obj.Get('channel', '');
          Norm := NormalizeChannelName(FileVal);
          if Norm <> '' then
          begin
            Result := Norm;
            SourceLabel := ConfigPath;
          end;
        end;
      except
        // Malformed config.json falls back cleanly
      end;
    finally
      JSON.Free;
      SL.Free;
    end;
  end;
end;

class function TBVUpgrade.GetConfiguredChannel: string;
var
  DummySource: string;
begin
  Result := GetConfiguredChannel(DummySource);
end;

class function TBVUpgrade.SetConfiguredChannel(const NewChannel: string; out ErrorMsg: string): Boolean;
var
  Norm, ConfigDir, ConfigPath: string;
  SL: TStringList;
  JSON: TJSONData;
  Obj: TJSONObject;
  Idx: Integer;
begin
  Result := False;
  ErrorMsg := '';
  Norm := NormalizeChannelName(NewChannel);
  if Norm = '' then
  begin
    ErrorMsg := Format('Invalid channel "%s". Valid channels: stable (main), nightly (develop).', [NewChannel]);
    Exit;
  end;

  ConfigDir := GetBlaiseVueConfigDir;
  ConfigPath := GetConfigFilePath;
  if (ConfigDir = '') or (ConfigPath = '') then
  begin
    ErrorMsg := 'Could not determine user home directory for ~/.blaisevue/config.json.';
    Exit;
  end;

  if not ForceDirectories(ConfigDir) then
  begin
    ErrorMsg := Format('Could not create configuration directory "%s".', [ConfigDir]);
    Exit;
  end;

  Obj := nil;
  JSON := nil;
  SL := TStringList.Create;
  try
    if FileExists(ConfigPath) then
    begin
      try
        SL.LoadFromFile(ConfigPath);
        JSON := GetJSON(SL.Text);
        if (JSON <> nil) and (JSON.JSONType = jtObject) then
          Obj := TJSONObject(JSON)
        else
        begin
          JSON.Free;
          JSON := nil;
        end;
      except
        JSON.Free;
        JSON := nil;
      end;
    end;

    if Obj = nil then
      Obj := TJSONObject.Create;

    Idx := Obj.IndexOfName('channel');
    if Idx >= 0 then
      Obj.Delete(Idx);
    Obj.Add('channel', Norm);

    SL.Text := Obj.FormatJSON;
    SL.SaveToFile(ConfigPath);
    Result := True;
  except
    on E: Exception do
    begin
      ErrorMsg := E.Message;
      Result := False;
    end;
  end;
  if JSON <> nil then
    JSON.Free
  else if Obj <> nil then
    Obj.Free;
  SL.Free;
end;

class function TBVUpgrade.GetReleasesRepo: string;
begin
  Result := Trim(SysUtils.GetEnvironmentVariable('BLAISEVUE_UPGRADE_REPO'));
  if Result = '' then
    Result := 'affonsoelias/BlaiseVue';
end;

function SelectReleaseObject(JsonData: TJSONData; Nightly: Boolean): TJSONObject;
var
  Arr: TJSONArray;
  Candidate: TJSONObject;
  I: Integer;
  TagLower: string;
begin
  Result := nil;
  if JsonData is TJSONObject then
    Exit(TJSONObject(JsonData));
  if JsonData is TJSONArray then
  begin
    Arr := TJSONArray(JsonData);
    if Arr.Count = 0 then Exit(nil);
    if Nightly then
    begin
      for I := 0 to Arr.Count - 1 do
      begin
        if Arr.Items[I] is TJSONObject then
        begin
          Candidate := TJSONObject(Arr.Items[I]);
          TagLower := LowerCase(Candidate.Get('tag_name', ''));
          if Candidate.Get('prerelease', False) or (Pos('nightly', TagLower) > 0) or (TagLower = 'dev') then
            Exit(Candidate);
        end;
      end;
    end;
    if Arr.Items[0] is TJSONObject then
      Result := TJSONObject(Arr.Items[0]);
  end;
end;

function MatchesChecksumName(const CurName: string): Boolean;
begin
  Result := (Pos('.sha256', CurName) > 0) or (Pos('checksum', CurName) > 0) or
            (Pos('sha256sums', CurName) > 0);
end;

function VerifySha256TextMatchesAsset(const ChecksumText, HashLower, AssetName: string): Boolean;
var
  Lines: TStringList;
  I: Integer;
  Line, LowLine, LowAsset: string;
begin
  Result := False;
  LowAsset := LowerCase(ExtractFileName(AssetName));
  Lines := TStringList.Create;
  try
    Lines.Text := ChecksumText;
    for I := 0 to Lines.Count - 1 do
    begin
      Line := Trim(Lines[I]);
      if Line = '' then Continue;
      LowLine := LowerCase(Line);
      if (Pos(LowAsset, LowLine) > 0) and (Pos(HashLower, LowLine) > 0) then
        Exit(True);
    end;
    if (Lines.Count = 1) and (Pos(HashLower, LowerCase(Lines[0])) > 0) then
      Result := True;
  finally
    Lines.Free;
  end;
end;

class function TBVUpgrade.FetchReleaseMetadata(const Repo, VersionTag, CustomUrl: string;
  Nightly: Boolean;
  out TagName, ReleaseNotes, AssetUrl, AssetName, ChecksumUrl, ChecksumValue: string;
  out ErrorMsg: string): Boolean;
var
  TargetUrl, OutputLog, NormTag: string;
  ExitCode, I: Integer;
  JsonData, AssetsData, ItemData: TJSONData;
  RootObj, AssetObj: TJSONObject;
  OSName, ArchName, CurName, CurDownloadUrl, SpecificSumUrl: string;
  FoundAsset, ArchMatch: Boolean;
begin
  Result := False;
  ErrorMsg := '';
  TagName := '';
  ReleaseNotes := '';
  AssetUrl := '';
  AssetName := '';
  ChecksumUrl := '';
  ChecksumValue := '';
  SpecificSumUrl := '';

  DetectPlatform(OSName, ArchName);

  if CustomUrl <> '' then
    TargetUrl := CustomUrl
  else if VersionTag <> '' then
  begin
    NormTag := Trim(VersionTag);
    if (Length(NormTag) > 0) and (NormTag[1] >= '0') and (NormTag[1] <= '9') then
      NormTag := 'v' + NormTag;
    TargetUrl := Format('https://api.github.com/repos/%s/releases/tags/%s', [Repo, NormTag]);
  end
  else if Nightly then
    TargetUrl := Format('https://api.github.com/repos/%s/releases?per_page=15', [Repo])
  else
    TargetUrl := Format('https://api.github.com/repos/%s/releases/latest', [Repo]);

  ExitCode := FetchUrlText(TargetUrl, OutputLog);
  if ExitCode <> 0 then
  begin
    ErrorMsg := 'Failed to connect to GitHub Releases (' + TargetUrl + ', exit ' +
                IntToStr(ExitCode) + '). Check your internet connection or use "bv self-update --from-source".';
    Exit(False);
  end;

  if (OutputLog = '') or ((Pos('{', OutputLog) = 0) and (Pos('[', OutputLog) = 0)) then
  begin
    ErrorMsg := 'Unexpected response from GitHub Releases API.';
    Exit(False);
  end;

  try
    JsonData := GetJSON(OutputLog);
  except
    on E: Exception do
    begin
      ErrorMsg := 'Failed to parse GitHub Releases JSON: ' + E.Message;
      Exit(False);
    end;
  end;

  try
    RootObj := SelectReleaseObject(JsonData, Nightly);
    if not Assigned(RootObj) then
    begin
      ErrorMsg := 'No published releases were found for ' + Repo + ' yet.';
      Exit(False);
    end;

    if RootObj.IndexOfName('message') >= 0 then
    begin
      if SameText(RootObj.Get('message', ''), 'Not Found') then
        ErrorMsg := 'No published release found yet for ' + Repo + ' on the selected channel.'
      else
        ErrorMsg := 'GitHub API: ' + RootObj.Get('message', 'Unknown error');
      Exit(False);
    end;

    TagName := RootObj.Get('tag_name', '');
    ReleaseNotes := RootObj.Get('body', '');

    FoundAsset := False;
    AssetsData := RootObj.FindPath('assets');
    if (AssetsData <> nil) and (AssetsData is TJSONArray) then
    begin
      for I := 0 to TJSONArray(AssetsData).Count - 1 do
      begin
        ItemData := TJSONArray(AssetsData).Items[I];
        if ItemData is TJSONObject then
        begin
          AssetObj := TJSONObject(ItemData);
          CurName := LowerCase(AssetObj.Get('name', ''));
          CurDownloadUrl := AssetObj.Get('browser_download_url', '');

          if MatchesChecksumName(CurName) then
          begin
            if (Pos(OSName, CurName) > 0) and (Pos(ArchName, CurName) > 0) then
              SpecificSumUrl := CurDownloadUrl
            else if (Pos(OSName, CurName) > 0) and (SpecificSumUrl = '') then
              SpecificSumUrl := CurDownloadUrl
            else if ChecksumUrl = '' then
              ChecksumUrl := CurDownloadUrl;
          end
          else if (Pos(OSName, CurName) > 0) and
                  (Pos('.sig', CurName) = 0) and
                  (Pos('.asc', CurName) = 0) then
          begin
            ArchMatch := (Pos(ArchName, CurName) > 0) or
                         ((ArchName = 'x86_64') and ((Pos('x64', CurName) > 0) or (Pos('amd64', CurName) > 0))) or
                         ((ArchName = 'aarch64') and (Pos('arm64', CurName) > 0));
            if ArchMatch then
            begin
              AssetName := AssetObj.Get('name', '');
              AssetUrl := CurDownloadUrl;
              FoundAsset := True;
            end;
          end;
        end;
      end;
    end;

    if SpecificSumUrl <> '' then
      ChecksumUrl := SpecificSumUrl;
  finally
    JsonData.Free;
  end;

  if not FoundAsset and (AssetUrl = '') then
  begin
    ErrorMsg := Format('No binary package compatible with (%s-%s) was found in release %s.',
      [OSName, ArchName, TagName]);
    Exit(False);
  end;

  Result := True;
end;

class function TBVUpgrade.FetchAvailableReleaseTags(const Repo: string; Tags: TStringList;
  out ErrorMsg: string): Boolean;
var
  Url, OutputLog, TagStr: string;
  ExitCode, I: Integer;
  JsonData: TJSONData;
  Arr: TJSONArray;
  Obj: TJSONObject;
begin
  Result := False;
  ErrorMsg := '';
  if not Assigned(Tags) then Exit(False);

  Url := Format('https://api.github.com/repos/%s/releases?per_page=15', [Repo]);
  ExitCode := FetchUrlText(Url, OutputLog);
  if ExitCode <> 0 then
  begin
    ErrorMsg := 'Failed to query GitHub Releases (exit ' + IntToStr(ExitCode) + ').';
    Exit(False);
  end;

  try
    JsonData := GetJSON(OutputLog);
  except
    on E: Exception do
    begin
      ErrorMsg := 'Failed to parse GitHub Releases JSON: ' + E.Message;
      Exit(False);
    end;
  end;

  try
    if JsonData is TJSONArray then
    begin
      Arr := TJSONArray(JsonData);
      for I := 0 to Arr.Count - 1 do
      begin
        if Arr.Items[I] is TJSONObject then
        begin
          Obj := TJSONObject(Arr.Items[I]);
          TagStr := Trim(Obj.Get('tag_name', ''));
          if (TagStr <> '') and (Tags.IndexOf(TagStr) < 0) then
            Tags.Add(TagStr);
        end;
      end;
      Result := True;
    end
    else
      ErrorMsg := 'Unexpected GitHub Releases response format.';
  finally
    JsonData.Free;
  end;
end;

function FindExtractedSDKRoot(const ExtractDir: string): string;
var
  SR: TSearchRec;
  SubDir, ExeBase: string;
begin
  {$IFDEF MSWINDOWS}
  ExeBase := 'bv.exe';
  {$ELSE}
  ExeBase := 'bv';
  {$ENDIF}
  if FileExists(IncludeTrailingPathDelimiter(ExtractDir) + 'bin' + PathDelim + ExeBase) then
    Exit(ExcludeTrailingPathDelimiter(ExtractDir));

  if SysUtils.FindFirst(IncludeTrailingPathDelimiter(ExtractDir) + '*', faDirectory, SR) = 0 then
  begin
    try
      repeat
        if (SR.Name = '.') or (SR.Name = '..') or ((SR.Attr and faDirectory) = 0) then Continue;
        SubDir := IncludeTrailingPathDelimiter(ExtractDir) + SR.Name;
        if FileExists(SubDir + PathDelim + 'bin' + PathDelim + ExeBase) then
          Exit(SubDir);
      until SysUtils.FindNext(SR) <> 0;
    finally
      SysUtils.FindClose(SR);
    end;
  end;
  Result := '';
end;

function BackupSDKRuntime(const SDKDir, BackupDir: string): Boolean;
var
  RelDirs: array[0..5] of string = ('core', 'templates', 'packages' + PathDelim + 'core',
                                     'vendor' + PathDelim + 'zephyr', 'bin' + PathDelim + 'studio', '');
  I: Integer;
  SrcPath, DstPath: string;
begin
  Result := True;
  if DirectoryExists(BackupDir) then
    TBVUpgrade.DeleteDirectoryRecursive(BackupDir);
  if not ForceDirectories(BackupDir) then
    Exit(False);

  for I := 0 to 4 do
  begin
    SrcPath := IncludeTrailingPathDelimiter(SDKDir) + RelDirs[I];
    DstPath := IncludeTrailingPathDelimiter(BackupDir) + RelDirs[I];
    if DirectoryExists(SrcPath) then
      if not TBVUpgrade.CopyDirectoryRecursive(SrcPath, DstPath) then
        Result := False;
  end;

  for SrcPath in ['package.json', 'bin' + PathDelim + 'dev-server.js', 'bin' + PathDelim + 'studio-server.js'] do
  begin
    if FileExists(IncludeTrailingPathDelimiter(SDKDir) + SrcPath) then
      if not TBVUpgrade.CopyFileStream(IncludeTrailingPathDelimiter(SDKDir) + SrcPath,
                                       IncludeTrailingPathDelimiter(BackupDir) + SrcPath) then
        Result := False;
  end;
end;

function RestoreSDKRuntime(const BackupDir, SDKDir: string): Boolean;
var
  RelDirs: array[0..4] of string = ('core', 'templates', 'packages' + PathDelim + 'core',
                                     'vendor' + PathDelim + 'zephyr', 'bin' + PathDelim + 'studio');
  I: Integer;
  SrcPath, DstPath, FileRel: string;
begin
  Result := True;
  if not DirectoryExists(BackupDir) then Exit(False);

  for I := 0 to High(RelDirs) do
  begin
    SrcPath := IncludeTrailingPathDelimiter(BackupDir) + RelDirs[I];
    DstPath := IncludeTrailingPathDelimiter(SDKDir) + RelDirs[I];
    if DirectoryExists(SrcPath) then
    begin
      if DirectoryExists(DstPath) then
        TBVUpgrade.DeleteDirectoryRecursive(DstPath);
      if not TBVUpgrade.CopyDirectoryRecursive(SrcPath, DstPath) then
        Result := False;
    end;
  end;

  for FileRel in ['package.json', 'bin' + PathDelim + 'dev-server.js', 'bin' + PathDelim + 'studio-server.js'] do
  begin
    SrcPath := IncludeTrailingPathDelimiter(BackupDir) + FileRel;
    DstPath := IncludeTrailingPathDelimiter(SDKDir) + FileRel;
    if FileExists(SrcPath) then
      if not TBVUpgrade.CopyFileStream(SrcPath, DstPath) then
        Result := False;
  end;
end;

function SyncExtractedSDKToDir(const ExtractedSDKRoot, DestSDKDir: string;
  IncludePas2JS: Boolean): Boolean;
var
  RelDirs: TStringArray;
  I: Integer;
  SrcPath, DstPath, FileRel, Pas2Dir, SRName: string;
  SR, SubSR: TSearchRec;
begin
  Result := True;
  if IncludePas2JS then
    RelDirs := ['core', 'templates', 'packages' + PathDelim + 'core',
                'vendor' + PathDelim + 'zephyr', 'vendor' + PathDelim + 'pas2js',
                'bin' + PathDelim + 'studio']
  else
    RelDirs := ['core', 'templates', 'packages' + PathDelim + 'core',
                'vendor' + PathDelim + 'zephyr', 'bin' + PathDelim + 'studio'];

  for I := 0 to High(RelDirs) do
  begin
    SrcPath := IncludeTrailingPathDelimiter(ExtractedSDKRoot) + RelDirs[I];
    DstPath := IncludeTrailingPathDelimiter(DestSDKDir) + RelDirs[I];
    if DirectoryExists(SrcPath) then
    begin
      if DirectoryExists(DstPath) then
        TBVUpgrade.DeleteDirectoryRecursive(DstPath);
      if not TBVUpgrade.CopyDirectoryRecursive(SrcPath, DstPath) then
        Result := False;
    end;
  end;

  for FileRel in ['package.json', 'README.md', 'LICENSE',
                  'bin' + PathDelim + 'dev-server.js', 'bin' + PathDelim + 'studio-server.js'] do
  begin
    SrcPath := IncludeTrailingPathDelimiter(ExtractedSDKRoot) + FileRel;
    DstPath := IncludeTrailingPathDelimiter(DestSDKDir) + FileRel;
    if FileExists(SrcPath) then
      if not TBVUpgrade.CopyFileStream(SrcPath, DstPath) then
        Result := False;
  end;

  {$IFNDEF MSWINDOWS}
  Pas2Dir := IncludeTrailingPathDelimiter(DestSDKDir) + 'vendor' + PathDelim + 'pas2js';
  if DirectoryExists(Pas2Dir) and
     (SysUtils.FindFirst(IncludeTrailingPathDelimiter(Pas2Dir) + '*', faDirectory, SR) = 0) then
  begin
    try
      repeat
        if (SR.Name = '.') or (SR.Name = '..') or ((SR.Attr and faDirectory) = 0) then Continue;
        SRName := IncludeTrailingPathDelimiter(Pas2Dir) + SR.Name + PathDelim + 'bin';
        if DirectoryExists(SRName) and
           (SysUtils.FindFirst(IncludeTrailingPathDelimiter(SRName) + '*', faAnyFile, SubSR) = 0) then
        begin
          try
            repeat
              if (SubSR.Attr and faDirectory) = 0 then
                TBVUpgrade.EnsureExecutableBit(IncludeTrailingPathDelimiter(SRName) + SubSR.Name);
            until SysUtils.FindNext(SubSR) <> 0;
          finally
            SysUtils.FindClose(SubSR);
          end;
        end;
      until SysUtils.FindNext(SR) <> 0;
    finally
      SysUtils.FindClose(SR);
    end;
  end;
  {$ENDIF}
end;

function InstallExtractedBinary(const NewExeSrc, LiveExe, BakExe: string): Boolean;
var
  BinDir, OldExe: string;
begin
  Result := False;
  BinDir := ExtractFileDir(LiveExe);
  OldExe := IncludeTrailingPathDelimiter(BinDir) +
            {$IFDEF MSWINDOWS}'bv_old.exe'{$ELSE}'bv_old'{$ENDIF};

  if FileExists(OldExe) then
    DeleteFile(OldExe);
  if FileExists(BakExe) then
    DeleteFile(BakExe);

  if FileExists(LiveExe) then
  begin
    if not TBVUpgrade.CopyFileStream(LiveExe, BakExe) then
      Exit(False);
    {$IFDEF MSWINDOWS}
    // Windows locks a running .exe against overwrite, so rename it out of the way first
    if not RenameFile(LiveExe, OldExe) then
    begin
      DeleteFile(BakExe);
      Exit(False);
    end;
    {$ELSE}
    DeleteFile(LiveExe);
    {$ENDIF}
  end;

  if not TBVUpgrade.CopyFileStream(NewExeSrc, LiveExe) then
  begin
    if FileExists(OldExe) and (not FileExists(LiveExe)) then
      RenameFile(OldExe, LiveExe);
    Exit(False);
  end;
  TBVUpgrade.EnsureExecutableBit(LiveExe);
  Result := True;
end;

class procedure TBVUpgrade.HandleBinaryUpgrade(const SDKDir, ExePath, CurVersion: string;
  const Opts: TBVUpgradeOptions);
var
  RepoName, EffChan, ChanSrc, TagName, Notes, AssetUrl, AssetName, ChecksumUrl, ChecksumVal, ErrorMsg: string;
  TempDir, DownloadedFile, ExtractDir, ExtractedRoot, NewExeCandidate: string;
  BinDir, BakPath, RuntimeBakDir, HashCalc, TestLog, OldExe: string;
  ExitCode: Integer;
  OSName, ArchName: string;
  IsNightly: Boolean;
begin
  RepoName := GetReleasesRepo;
  BinDir := IncludeTrailingPathDelimiter(SDKDir) + 'bin';
  CleanupStaleOldBinary(BinDir);

  if Trim(Opts.Channel) <> '' then
    EffChan := NormalizeChannelName(Opts.Channel)
  else if Opts.Nightly then
    EffChan := 'nightly'
  else
    EffChan := GetConfiguredChannel(ChanSrc);

  if EffChan = '' then
    EffChan := 'stable';

  IsNightly := (EffChan = 'nightly') or Opts.Nightly;
  DetectPlatform(OSName, ArchName);

  WriteLn('');
  WriteLn('======================================================================');
  WriteLn('  BlaiseVue Binary Updater (bv self-update --binary)');
  WriteLn('======================================================================');
  WriteLn('  Installed Version : v', CurVersion);
  WriteLn('  Update Channel    : ', EffChan);
  WriteLn('  Platform          : ', OSName, '-', ArchName);
  WriteLn('  Repository        : ', RepoName);
  WriteLn('  Fetching release metadata from GitHub...');

  if not FetchReleaseMetadata(RepoName, Opts.TargetVersion, Opts.CustomUrl, IsNightly,
                              TagName, Notes, AssetUrl, AssetName, ChecksumUrl, ChecksumVal, ErrorMsg) then
  begin
    WriteLn('');
    WriteLn('  [INFO] ', ErrorMsg);
    WriteLn('======================================================================');
    if (Pos('No published release', ErrorMsg) > 0) or (Pos('not found', LowerCase(ErrorMsg)) > 0) then
      Exit
    else
      Halt(1);
  end;

  WriteLn('');
  WriteLn('  Latest Release    : ', TagName);
  if AssetName <> '' then
    WriteLn('  Package Asset     : ', AssetName);

  if (not IsNightly) and (not Opts.Force) and
     (CompareSemVer(TagName, CurVersion) <= 0) and (Opts.TargetVersion = '') then
  begin
    WriteLn('');
    WriteLn('  [v] BlaiseVue is already up to date at v', CurVersion, '!');
    WriteLn('======================================================================');
    Exit;
  end;

  if Opts.CheckOnly then
  begin
    WriteLn('');
    WriteLn('----------------------------------------------------------------------');
    WriteLn('  New release available: ', TagName, ' (installed: v', CurVersion, ')');
    if Trim(Notes) <> '' then
    begin
      WriteLn('');
      WriteLn(Copy(Notes, 1, 400));
      if Length(Notes) > 400 then WriteLn('...');
    end;
    WriteLn('----------------------------------------------------------------------');
    WriteLn('  Run "bv self-update --binary" to download and install.');
    Exit;
  end;

  if Opts.DryRun then
  begin
    WriteLn('');
    WriteLn('  [DRY-RUN] Execution plan:');
    WriteLn('    1. Download asset   : ', AssetUrl);
    if ChecksumUrl <> '' then
      WriteLn('    2. Verify SHA-256   : ', ChecksumUrl)
    else if Opts.AllowUnsigned then
      WriteLn('    2. Verify SHA-256   : skipped (--allow-unsigned)')
    else
      WriteLn('    2. Verify SHA-256   : REQUIRED (would abort without checksum)');
    WriteLn('    3. Extract archive  : ', AssetName);
    WriteLn('    4. Atomic swap      : ', ExePath, ' (backup -> .bak)');
    WriteLn('    5. Sync SDK runtime : core, packages/core, templates, vendor/zephyr, vendor/pas2js');
    WriteLn('    6. Smoke test       : "', ExePath, '" --version');
    Exit;
  end;

  TempDir := GetTempDir + 'bv_upgrade_' + IntToStr(DateTimeToFileDate(Now));
  if not ForceDirectories(TempDir) then
  begin
    WriteLn(ErrOutput, '  [ERROR] Failed to create temp directory: ', TempDir);
    Halt(1);
  end;

  DownloadedFile := TempDir + PathDelim + AssetName;
  ExtractDir := TempDir + PathDelim + 'extracted';
  ForceDirectories(ExtractDir);

  try
    WriteLn('');
    WriteLn('-> [1/4] Downloading ', TagName, ' (', AssetName, ')...');
    if not DownloadUrlToFile(AssetUrl, DownloadedFile) then
    begin
      WriteLn(ErrOutput, '  [ERROR] Failed to download artifact from: ', AssetUrl);
      Halt(1);
    end;

    WriteLn('-> [2/4] Verifying SHA-256 cryptographic integrity...');
    HashCalc := LowerCase(SHA256File(DownloadedFile));
    WriteLn('   SHA-256: ', HashCalc);

    if ChecksumUrl <> '' then
    begin
      ExitCode := FetchUrlText(ChecksumUrl, ChecksumVal);
      if (ExitCode <> 0) or (Trim(ChecksumVal) = '') then
      begin
        WriteLn(ErrOutput, '  [SECURITY ERROR] Failed to fetch SHA-256 checksum from: ', ChecksumUrl);
        Halt(1);
      end;
      if not VerifySha256TextMatchesAsset(ChecksumVal, HashCalc, AssetName) then
      begin
        WriteLn(ErrOutput, '  [SECURITY ERROR] SHA-256 mismatch! Downloaded archive is corrupted or tampered.');
        Halt(1);
      end;
      WriteLn('   [OK] SHA-256 checksum verified.');
    end
    else if not Opts.AllowUnsigned then
    begin
      WriteLn(ErrOutput, '  [SECURITY ERROR] Release has no SHA-256 checksum. Pass --allow-unsigned to override.');
      Halt(1);
    end
    else
      WriteLn('   [WARNING] Verification skipped (--allow-unsigned).');

    WriteLn('-> [3/4] Extracting archive...');
    if not ExtractArchive(DownloadedFile, ExtractDir, ErrorMsg) then
    begin
      WriteLn(ErrOutput, '  [ERROR] Failed to extract archive: ', ErrorMsg);
      Halt(1);
    end;

    ExtractedRoot := FindExtractedSDKRoot(ExtractDir);
    if ExtractedRoot = '' then
    begin
      WriteLn(ErrOutput, '  [ERROR] Invalid BlaiseVue release package: bin/bv executable not found.');
      Halt(1);
    end;

    NewExeCandidate := IncludeTrailingPathDelimiter(ExtractedRoot) + 'bin' + PathDelim +
                       {$IFDEF MSWINDOWS}'bv.exe'{$ELSE}'bv'{$ENDIF};

    WriteLn('-> [4/4] Applying atomic update to ', SDKDir, '...');
    RuntimeBakDir := IncludeTrailingPathDelimiter(SDKDir) + '.bv_upgrade_backup';
    if not BackupSDKRuntime(SDKDir, RuntimeBakDir) then
      WriteLn('   [WARNING] Could not complete full runtime directory backup.');

    BakPath := IncludeTrailingPathDelimiter(BinDir) +
               {$IFDEF MSWINDOWS}'bv.bak.exe'{$ELSE}'bv.bak'{$ENDIF};
    if not InstallExtractedBinary(NewExeCandidate, ExePath, BakPath) then
    begin
      WriteLn(ErrOutput, '  [ERROR] Failed to replace CLI executable atomically.');
      Halt(1);
    end;

    if not SyncExtractedSDKToDir(ExtractedRoot, SDKDir, True) then
      WriteLn('   [WARNING] Some SDK runtime files reported copy warnings.');

    // Self-test updated CLI
    ExitCode := RunProcessWithOutput(ExePath, '--version', TestLog);
    if ExitCode <> 0 then
    begin
      WriteLn(ErrOutput, '  [ERROR] Updated binary failed --version smoke test. Rolling back automatically...');
      OldExe := IncludeTrailingPathDelimiter(BinDir) +
                {$IFDEF MSWINDOWS}'bv_old.exe'{$ELSE}'bv_old'{$ENDIF};
      if FileExists(ExePath) then
      begin
        {$IFDEF MSWINDOWS}
        if FileExists(OldExe) then DeleteFile(OldExe);
        RenameFile(ExePath, OldExe);
        {$ELSE}
        DeleteFile(ExePath);
        {$ENDIF}
      end;
      if FileExists(BakPath) then
      begin
        CopyFileStream(BakPath, ExePath);
        EnsureExecutableBit(ExePath);
      end;
      RestoreSDKRuntime(RuntimeBakDir, SDKDir);
      WriteLn(ErrOutput, '  [ROLLBACK] Previous BlaiseVue binary and SDK runtime restored.');
      Halt(1);
    end;

    WriteLn('');
    WriteLn('======================================================================');
    WriteLn('  [SUCCESS] BlaiseVue updated to ', TagName, '!');
    WriteLn('  Backup preserved at: ', BakPath);
    WriteLn('  Revert anytime with: bv rollback');
    WriteLn('======================================================================');
    WriteLn('');
  finally
    DeleteDirectoryRecursive(TempDir);
  end;
end;

class function TBVUpgrade.HandleBinaryRollback(const SDKDir: string; DryRun: Boolean): Boolean;
var
  BinDir, LiveExe, BakExe, OldExe, RuntimeBakDir, VerOut: string;
  RC: Integer;
begin
  Result := False;
  BinDir := IncludeTrailingPathDelimiter(SDKDir) + 'bin';
  LiveExe := BinDir + PathDelim + {$IFDEF MSWINDOWS}'bv.exe'{$ELSE}'bv'{$ENDIF};
  BakExe := BinDir + PathDelim + {$IFDEF MSWINDOWS}'bv.bak.exe'{$ELSE}'bv.bak'{$ENDIF};
  OldExe := BinDir + PathDelim + {$IFDEF MSWINDOWS}'bv_old.exe'{$ELSE}'bv_old'{$ENDIF};
  RuntimeBakDir := IncludeTrailingPathDelimiter(SDKDir) + '.bv_upgrade_backup';

  WriteLn('');
  WriteLn('======================================================================');
  WriteLn('  BlaiseVue Binary Rollback');
  WriteLn('======================================================================');

  if not FileExists(BakExe) then
  begin
    WriteLn('  [ERROR] No backup binary found at: ', BakExe);
    WriteLn('  A backup is created automatically whenever "bv self-update" runs.');
    WriteLn('======================================================================');
    Exit(False);
  end;

  WriteLn('  Current CLI   : ', LiveExe);
  WriteLn('  Backup Binary : ', BakExe);
  if DirectoryExists(RuntimeBakDir) then
    WriteLn('  Runtime Backup: ', RuntimeBakDir);

  if DryRun then
  begin
    WriteLn('');
    WriteLn('  [DRY-RUN] Would restore ', BakExe, ' -> ', LiveExe);
    if DirectoryExists(RuntimeBakDir) then
      WriteLn('  [DRY-RUN] Would restore SDK runtime directories from ', RuntimeBakDir);
    Exit(True);
  end;

  if FileExists(OldExe) then
    DeleteFile(OldExe);
  if FileExists(LiveExe) then
  begin
    {$IFDEF MSWINDOWS}
    if not RenameFile(LiveExe, OldExe) then
    begin
      WriteLn(ErrOutput, '  [ERROR] Failed to stage current running executable for rollback.');
      Exit(False);
    end;
    {$ELSE}
    DeleteFile(LiveExe);
    {$ENDIF}
  end;

  if not CopyFileStream(BakExe, LiveExe) then
  begin
    if FileExists(OldExe) and (not FileExists(LiveExe)) then
      RenameFile(OldExe, LiveExe);
    WriteLn(ErrOutput, '  [ERROR] Failed to copy backup binary.');
    Exit(False);
  end;
  EnsureExecutableBit(LiveExe);

  if DirectoryExists(RuntimeBakDir) then
  begin
    if RestoreSDKRuntime(RuntimeBakDir, SDKDir) then
      WriteLn('  [v] Restored SDK runtime directories from backup.');
  end;

  RC := RunProcessWithOutput(LiveExe, '--version', VerOut);
  if RC = 0 then
  begin
    WriteLn('  [SUCCESS] Restored previous BlaiseVue binary!');
    if Trim(VerOut) <> '' then
      WriteLn('  Active CLI: ', Trim(VerOut));
    Result := True;
  end
  else
    WriteLn('  [WARNING] Restored binary exited with code ', RC);

  WriteLn('======================================================================');
  WriteLn('');
end;

class function TBVUpgrade.DownloadFrameworkVersionBinary(const Repo, TargetVer, DestDir: string;
  AllowUnsigned: Boolean; out InstalledTag, ErrMsg: string): Boolean;
var
  TagName, Notes, AssetUrl, AssetName, ChecksumUrl, ChecksumVal: string;
  TempDir, DownloadedFile, ExtractDir, ExtractedRoot, HashCalc, StageDir: string;
  IsNightly: Boolean;
  ExitCode: Integer;
begin
  Result := False;
  InstalledTag := '';
  ErrMsg := '';

  IsNightly := SameText(TargetVer, 'nightly') or SameText(TargetVer, 'develop') or SameText(TargetVer, 'dev');
  if IsNightly then
    Result := FetchReleaseMetadata(Repo, '', '', True, TagName, Notes, AssetUrl, AssetName, ChecksumUrl, ChecksumVal, ErrMsg)
  else if SameText(TargetVer, 'main') or SameText(TargetVer, 'stable') or SameText(TargetVer, 'latest') then
    Result := FetchReleaseMetadata(Repo, '', '', False, TagName, Notes, AssetUrl, AssetName, ChecksumUrl, ChecksumVal, ErrMsg)
  else
    Result := FetchReleaseMetadata(Repo, TargetVer, '', False, TagName, Notes, AssetUrl, AssetName, ChecksumUrl, ChecksumVal, ErrMsg);

  if not Result then Exit(False);

  InstalledTag := TagName;
  TempDir := GetTempDir + 'bv_fw_' + IntToStr(DateTimeToFileDate(Now));
  if not ForceDirectories(TempDir) then
  begin
    ErrMsg := 'Could not create temp directory: ' + TempDir;
    Exit(False);
  end;

  DownloadedFile := TempDir + PathDelim + AssetName;
  ExtractDir := TempDir + PathDelim + 'extracted';
  StageDir := ExcludeTrailingPathDelimiter(DestDir) + '.tmp';

  try
    WriteLn('  [*] Downloading prebuilt release ', TagName, ' (', AssetName, ')...');
    if not DownloadUrlToFile(AssetUrl, DownloadedFile) then
    begin
      ErrMsg := 'Download failed from ' + AssetUrl;
      Exit(False);
    end;

    HashCalc := LowerCase(SHA256File(DownloadedFile));
    if ChecksumUrl <> '' then
    begin
      ExitCode := FetchUrlText(ChecksumUrl, ChecksumVal);
      if (ExitCode <> 0) or (Trim(ChecksumVal) = '') or
         (not VerifySha256TextMatchesAsset(ChecksumVal, HashCalc, AssetName)) then
      begin
        ErrMsg := 'SHA-256 verification failed for ' + AssetName;
        Exit(False);
      end;
      WriteLn('  [v] SHA-256 verified: ', HashCalc);
    end
    else if not AllowUnsigned then
    begin
      ErrMsg := 'Release has no checksum asset (pass --allow-unsigned to override).';
      Exit(False);
    end;

    if not ExtractArchive(DownloadedFile, ExtractDir, ErrMsg) then
      Exit(False);

    ExtractedRoot := FindExtractedSDKRoot(ExtractDir);
    if ExtractedRoot = '' then
    begin
      ErrMsg := 'Extracted release does not contain bin/bv executable.';
      Exit(False);
    end;

    if DirectoryExists(StageDir) then
      DeleteDirectoryRecursive(StageDir);
    if not CopyDirectoryRecursive(ExtractedRoot, StageDir) then
    begin
      ErrMsg := 'Failed to stage framework version into ' + StageDir;
      Exit(False);
    end;

    {$IFNDEF MSWINDOWS}
    EnsureExecutableBit(IncludeTrailingPathDelimiter(StageDir) + 'bin' + PathDelim + 'bv');
    {$ENDIF}

    if DirectoryExists(DestDir) then
      DeleteDirectoryRecursive(DestDir);
    if not RenameFile(StageDir, DestDir) then
    begin
      ErrMsg := 'Failed to promote ' + StageDir + ' -> ' + DestDir;
      Exit(False);
    end;

    Result := True;
  finally
    if DirectoryExists(StageDir) then DeleteDirectoryRecursive(StageDir);
    DeleteDirectoryRecursive(TempDir);
  end;
end;

class function TBVUpgrade.EnsureDemoAppTemplate(const SDKDir, Repo, BranchOrTag: string;
  out ResolvedDemoDir, ErrMsg: string): Boolean;
var
  LocalDemo, CacheDemo, TempDir, ArchiveUrl, ArchiveFile, ExtractDir, DemoSrc, CleanRef: string;
  SR: TSearchRec;
  SubRoot: string;
begin
  Result := False;
  ResolvedDemoDir := '';
  ErrMsg := '';

  LocalDemo := IncludeTrailingPathDelimiter(SDKDir) + 'demo-app';
  if DirectoryExists(LocalDemo + PathDelim + 'src') then
  begin
    ResolvedDemoDir := LocalDemo;
    Exit(True);
  end;

  CacheDemo := IncludeTrailingPathDelimiter(GetBlaiseVueConfigDir) + 'cache' + PathDelim + 'demo-app';
  if DirectoryExists(CacheDemo + PathDelim + 'src') then
  begin
    ResolvedDemoDir := CacheDemo;
    Exit(True);
  end;

  CleanRef := Trim(BranchOrTag);
  if CleanRef = '' then CleanRef := 'main';

  TempDir := GetTempDir + 'bv_demo_' + IntToStr(DateTimeToFileDate(Now));
  ForceDirectories(TempDir);
  ArchiveFile := TempDir + PathDelim + 'blaisevue-demo.tar.gz';
  ExtractDir := TempDir + PathDelim + 'extracted';

  if (Length(CleanRef) > 0) and ((CleanRef[1] = 'v') or (CleanRef[1] = 'V')) then
    ArchiveUrl := Format('https://github.com/%s/archive/refs/tags/%s.tar.gz', [Repo, CleanRef])
  else
    ArchiveUrl := Format('https://github.com/%s/archive/refs/heads/%s.tar.gz', [Repo, CleanRef]);

  try
    WriteLn('  [*] Downloading demo-app showcase template on demand from GitHub...');
    if not DownloadUrlToFile(ArchiveUrl, ArchiveFile) then
    begin
      // Fallback to main branch archive if tag archive didn't exist yet
      ArchiveUrl := Format('https://github.com/%s/archive/refs/heads/main.tar.gz', [Repo]);
      if not DownloadUrlToFile(ArchiveUrl, ArchiveFile) then
      begin
        ErrMsg := 'Failed to download demo-app archive from ' + ArchiveUrl;
        Exit(False);
      end;
    end;

    if not ExtractArchive(ArchiveFile, ExtractDir, ErrMsg) then
      Exit(False);

    DemoSrc := '';
    if DirectoryExists(ExtractDir + PathDelim + 'demo-app' + PathDelim + 'src') then
      DemoSrc := ExtractDir + PathDelim + 'demo-app'
    else if SysUtils.FindFirst(IncludeTrailingPathDelimiter(ExtractDir) + '*', faDirectory, SR) = 0 then
    begin
      try
        repeat
          if (SR.Name = '.') or (SR.Name = '..') or ((SR.Attr and faDirectory) = 0) then Continue;
          SubRoot := IncludeTrailingPathDelimiter(ExtractDir) + SR.Name + PathDelim + 'demo-app';
          if DirectoryExists(SubRoot + PathDelim + 'src') then
          begin
            DemoSrc := SubRoot;
            Break;
          end;
        until SysUtils.FindNext(SR) <> 0;
      finally
        SysUtils.FindClose(SR);
      end;
    end;

    if DemoSrc = '' then
    begin
      ErrMsg := 'demo-app folder was not found inside downloaded repository archive.';
      Exit(False);
    end;

    // Trim heavy generated artifacts before caching cleanly
    for SubRoot in ['node_modules', 'dist', 'android', 'generated'] do
      if DirectoryExists(IncludeTrailingPathDelimiter(DemoSrc) + SubRoot) then
        DeleteDirectoryRecursive(IncludeTrailingPathDelimiter(DemoSrc) + SubRoot);

    if DirectoryExists(CacheDemo) then
      DeleteDirectoryRecursive(CacheDemo);
    ForceDirectories(ExtractFileDir(CacheDemo));
    if not CopyDirectoryRecursive(DemoSrc, CacheDemo) then
    begin
      ErrMsg := 'Failed to cache demo-app template at ' + CacheDemo;
      Exit(False);
    end;

    ResolvedDemoDir := CacheDemo;
    Result := True;
  finally
    DeleteDirectoryRecursive(TempDir);
  end;
end;

class function TBVUpgrade.DownloadMormot2Archive(const TargetTag, DestDir: string;
  out ErrMsg: string): Boolean;
var
  CleanTag, ArchiveUrl, ArchiveFile, TempDir, ExtractDir, SrcRoot, SubRoot: string;
  SR: TSearchRec;
begin
  Result := False;
  ErrMsg := '';
  CleanTag := Trim(TargetTag);
  if (CleanTag = '') or SameText(CleanTag, 'latest') or SameText(CleanTag, 'main') or SameText(CleanTag, 'master') then
    ArchiveUrl := 'https://github.com/synopse/mORMot2/archive/refs/heads/master.tar.gz'
  else
    ArchiveUrl := Format('https://github.com/synopse/mORMot2/archive/refs/tags/%s.tar.gz', [CleanTag]);

  TempDir := GetTempDir + 'bv_mormot2_' + IntToStr(DateTimeToFileDate(Now));
  ForceDirectories(TempDir);
  ArchiveFile := TempDir + PathDelim + 'mormot2.tar.gz';
  ExtractDir := TempDir + PathDelim + 'extracted';

  try
    WriteLn('  [*] Downloading Synopse mORMot 2 archive (', ArchiveUrl, ')...');
    if not DownloadUrlToFile(ArchiveUrl, ArchiveFile) then
    begin
      ErrMsg := 'Failed to download mORMot 2 archive from GitHub.';
      Exit(False);
    end;

    WriteLn('  [*] Extracting mORMot 2 source tree...');
    if not ExtractArchive(ArchiveFile, ExtractDir, ErrMsg) then
      Exit(False);

    SrcRoot := '';
    if FileExists(ExtractDir + PathDelim + 'src' + PathDelim + 'core' + PathDelim + 'mormot.core.base.pas') then
      SrcRoot := ExtractDir
    else if SysUtils.FindFirst(IncludeTrailingPathDelimiter(ExtractDir) + '*', faDirectory, SR) = 0 then
    begin
      try
        repeat
          if (SR.Name = '.') or (SR.Name = '..') or ((SR.Attr and faDirectory) = 0) then Continue;
          SubRoot := IncludeTrailingPathDelimiter(ExtractDir) + SR.Name;
          if FileExists(SubRoot + PathDelim + 'src' + PathDelim + 'core' + PathDelim + 'mormot.core.base.pas') then
          begin
            SrcRoot := SubRoot;
            Break;
          end;
        until SysUtils.FindNext(SR) <> 0;
      finally
        SysUtils.FindClose(SR);
      end;
    end;

    if SrcRoot = '' then
    begin
      ErrMsg := 'Downloaded archive does not contain valid mORMot 2 sources (src/core/mormot.core.base.pas).';
      Exit(False);
    end;

    if DirectoryExists(DestDir) then
      DeleteDirectoryRecursive(DestDir);
    ForceDirectories(ExtractFileDir(ExcludeTrailingPathDelimiter(DestDir)));
    if not CopyDirectoryRecursive(SrcRoot, DestDir) then
    begin
      ErrMsg := 'Failed to install mORMot 2 into ' + DestDir;
      Exit(False);
    end;

    Result := FileExists(IncludeTrailingPathDelimiter(DestDir) + 'src' + PathDelim + 'core' + PathDelim + 'mormot.core.base.pas');
  finally
    DeleteDirectoryRecursive(TempDir);
  end;
end;

end.
