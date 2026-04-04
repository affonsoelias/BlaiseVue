unit wasizenfs;

{$mode ObjFPC}

interface

uses
  SysUtils, JS, libzenfs, Wasitypes;

Type
  EWASIZenFS = class(Exception);

  { TWASIZenFS }

  TWASIZenFS = class (TObject,IWasiFS)
  private
    //FRoot : TZenFSDir;
    FDirMap : TJSMap;
    FPositionMap : TJSMap;
  protected
    function AllocateDirFD(aDir: TZenFSDirentArray): Integer;
    function IsDirEnt(FD : Integer) : TZenFSDirentArray;
    Procedure RemoveDirent(FD : integer);
    function PrependFD(FD: Integer; aPath: String): string;
    class function ExceptToError(E : TJSObject) : Integer;
    class function ZenFSDateToWasiTimeStamp(aDate: TJSDate): Nativeint;
    class function ZenStatToWasiStat(ZSTat: TZenFSStats): TWasiFileStat;
  Public
    constructor create;
    Function MkDirAt(FD : Integer; const aPath : String) : NativeInt;
    Function RmDirAt(FD : Integer; const aPath : String) : NativeInt;
    function StatAt(FD : Integer; const aPath : String; var stat: TWasiFileStat) : NativeInt;
    function StatFD(FD : Integer; var stat: TWasiFileStat) : NativeInt;
    Function UTimesAt(FD : Integer; aPath : String; aTime,MTime : TJSDate; UpdateLink : boolean) : NativeInt;
    Function UTimes(FD : Integer; aTime,MTime : TJSDate; Flags : TSetTimesFlags) : NativeInt;
    Function LinkAt(OldFD : Integer; OldPath : String; NewFD : Integer; NewPath : String) : NativeInt;
    Function RenameAt(OldFD : Integer; OldPath : String; NewFD : Integer; NewPath : String) : NativeInt;
    Function SymLinkAt(FD : Integer; Path : String; Target : String) : NativeInt;
    Function UnLinkAt(FD : Integer; const aPath : String) : NativeInt;
    function OpenAt(FD : Integer; FDFlags : NativeInt; aPath : String; Flags, fsRightsBase, fsRightsInheriting, fsFlags: NativeInt; out Openfd: Integer): NativeInt;
    function ReadLinkAt(FD : Integer; aPath : String; out aTarget : String): NativeInt;
    function Close(FD: Integer): NativeInt;
    function Write(FD : Integer; Data : TJSUint8Array; AtPos : Integer; out Written :Integer) : NativeInt;
    function Sync(FD : Integer) : NativeInt;
    function DataSync(FD : Integer) : NativeInt;
    function Seek(FD : integer; Offset : Integer; Whence : TSeekWhence; out NewPos : Integer) : NativeInt;
    Function Read(FD : Integer; Data : TJSUint8Array; AtPos : Integer; Out BytesRead : Integer) : NativeInt;
    function ReadDir(FD: Integer; Cookie: NativeInt; out DirEnt: TWasiFSDirent): NativeInt;
    Function GetPrestat(FD: Integer) : String;
    Procedure PreLoadFile(aPath : String; aData : TJSDataView);
  end;

implementation

const
  ResOK = __WASI_ERRNO_SUCCESS;

{ TWASIZenFS }

function TWASIZenFS.AllocateDirFD(aDir : TZenFSDirentArray): Integer;
var
  I : integer;

begin
  I:=4;
  While (I<100) and (FDirMap.has(i)) do
    Inc(I);
  if I=100 then
    Raise EWASIZenFS.Create('Too many directories');
  FDirMap.&set(I,aDir);
  Result:=I;
end;

function TWASIZenFS.IsDirEnt(FD: Integer): TZenFSDirentArray;
begin
  if FDirMap.has(FD) then
    Result:=TZenFSDirentArray(FDirMap.get(FD))
  else
    Result:=Nil;
end;

procedure TWASIZenFS.RemoveDirent(FD: integer);
begin
  FDirMap.delete(FD);
end;

function TWASIZenFS.PrependFD(FD: Integer; aPath: String) : string;

begin
  if FD<>3 then
    Writeln('Warning, unknown CWD ID',FD);
  Result:='/'+aPath;
end;

class function TWASIZenFS.ExceptToError(E: TJSObject): Integer;
begin
  if Assigned(E) then;
  // For the moment.
  Result:=WASI_ENOSYS;
end;

function TWASIZenFS.MkDirAt(FD: Integer; const aPath: String): NativeInt;
begin
  try
    ZenFS.mkdirSync(PrependFD(FD,aPath),&777);
    Result:=ResOK;
  except
    on E : TJSObject do
      Result:=ExceptToError(E);
  end;
end;

function TWASIZenFS.RmDirAt(FD: Integer; const aPath: String): NativeInt;
begin
  try
    ZenFS.rmdirSync(PrependFD(FD,aPath));
    Result:=ResOK;
  except
    on E : TJSObject do
      Result:=ExceptToError(E);
  end;
end;

class function TWASIZenFS.ZenFSDateToWasiTimeStamp(aDate: TJSDate): Nativeint;
begin
  Result:=aDate.Time;
end;

class function TWASIZenFS.ZenStatToWasiStat(ZSTat: TZenFSStats): TWasiFileStat;

begin
  Result.dev:=0;
  Result.ino:=0;
  if ZStat.isDirectory then
    Result.filetype:=__WASI_FILETYPE_DIRECTORY
  else if ZSTat.isBlockDevice then
    Result.filetype:=__WASI_FILETYPE_BLOCK_DEVICE
  else if ZStat.isCharacterDevice then
    Result.filetype:=__WASI_FILETYPE_CHARACTER_DEVICE
  else if ZStat.isFile then
    Result.filetype:=__WASI_FILETYPE_REGULAR_FILE
  else if ZStat.isSocket() then
    Result.filetype:=__WASI_FILETYPE_SOCKET_DGRAM
  else if ZStat.isSymbolicLink() then
    Result.filetype:=__WASI_FILETYPE_SYMBOLIC_LINK
  else
    Result.filetype:=__WASI_FILETYPE_UNKNOWN;
  Result.nlink:=AsIntNumber(ZStat.nlink);
  Result.size:=AsIntNumber(ZStat.Size);
  Result.atim:=ZenFSDateToWasiTimeStamp(ZStat.aTime);
  Result.mtim:=ZenFSDateToWasiTimeStamp(ZStat.mTime);
  Result.ctim:=ZenFSDateToWasiTimeStamp(ZStat.cTime);
end;

constructor TWASIZenFS.create;
begin
  FDirMap:=TJSMap.new;
  FPositionMap:=TJSMap.New;
end;

function TWASIZenFS.StatAt(FD: Integer; const aPath: String;
  var stat: TWasiFileStat): NativeInt;

var
  ZStat : TZenFSStats;

begin
  try
    ZStat:=ZenFS.statSync(PrependFD(FD,aPath));
    Stat:=ZenStatToWasiStat(ZStat);
    Result:=ResOK;
  except
    on E : TJSObject do
      Result:=ExceptToError(E);
  end;
end;

function TWASIZenFS.StatFD(FD: Integer; var stat: TWasiFileStat): NativeInt;
var
  ZStat : TZenFSStats;

begin
  try
    ZStat:=ZenFS.fstatSync(FD);
    Stat:=ZenStatToWasiStat(ZStat);
    Result:=ResOK;
  except
    on E : TJSObject do
      Result:=ExceptToError(E);
  end;
end;

function TWASIZenFS.UTimesAt(FD : Integer; aPath: String; aTime, MTime: TJSDate; UpdateLink: boolean): NativeInt;

var
  lPath : String;

begin
  lPath:=PrependFD(FD,aPath);
  try
    if UpdateLink then
      ZenFS.lutimesSync(lPath,aTime,mTime)
    else
      ZenFS.utimesSync(lPath,aTime,mTime);
    Result:=resOK;
  except
    on E : TJSObject do
      Result:=ExceptToError(E);
  end;
end;

function TWASIZenFS.UTimes(FD: Integer; aTime, MTime: TJSDate;
  Flags: TSetTimesFlags): NativeInt;
begin
  try
    ZenFS.futimes(fd,aTime,mTime);
    Result:=resOK;
  except
    on E : TJSObject do
      Result:=ExceptToError(E);
  end;
  if Flags=[] then;
end;

function TWASIZenFS.LinkAt(OldFD: Integer; OldPath: String; NewFD: Integer;
  NewPath: String): NativeInt;

var
  lOld,lNew : String;

begin
  lOld:=PrependFD(OldFD,OldPath);
  lNew:=PrependFD(NewFD,NewPath);
  try
    ZenFS.linkSync(lOld,lNew);
    Result:=resOK;
  except
    on E : TJSObject do
      Result:=ExceptToError(E);
  end;
end;

function TWASIZenFS.RenameAt(OldFD: Integer; OldPath: String; NewFD: Integer;
  NewPath: String): NativeInt;
var
  lOld,lNew : String;

begin
  lOld:=PrependFD(OldFD,OldPath);
  lNew:=PrependFD(NewFD,NewPath);
  try
    ZenFS.renameSync(lOld,lNew);
  except
    on E : TJSObject do
      Result:=ExceptToError(E);
  end;
end;

function TWASIZenFS.SymLinkAt(FD: Integer; Path: String; Target: String
  ): NativeInt;
var
  lPath : String;

begin
  lPath:=PrependFD(FD,Path);
  try
    ZenFS.symLinkSync(Target,lPath);
    Result:=resOK;
  except
    on E : TJSObject do
      Result:=ExceptToError(E);
  end;
end;

function TWASIZenFS.Close(FD : Integer): NativeInt;

begin
  try
    if IsDirEnt(FD)<>Nil then
      begin
      RemoveDirent(FD);
      Result:=WASI_ESUCCESS;
      end
    else
      begin
      ZenFS.closeSync(fd);
      FPositionMap.delete(FD);
      end;
    Result:=resOK;
  except
    on E : TJSObject do
      Result:=ExceptToError(E);
  end;
end;

function TWASIZenFS.Write(FD: Integer; Data: TJSUint8Array; AtPos : Integer; out Written : Integer): NativeInt;

var
  DS : TJSDataView;
  lPos : Integer;
  lMapPos : JSValue;
begin
  try
    DS:=TJSDataView.New(Data.buffer);
    lPos:=atPos;
    if lPos=-1 then
      begin
      lMapPos:=FPositionMap.get(FD);
      if not IsNumber(lMapPos) then
        Raise TZenFSErrnoError.new(TZenFSErrNo.EBADF);
      lPos:=Integer(lMapPos);
      end;
    if lPos<>-1 then
      Written:=ZenFS.writeSync(fd,DS,0,Data.byteLength,lPos)
    else
      Written:=ZenFS.writeSync(fd,DS,0,Data.byteLength);
    Result:=resOK;
    if atPos=-1 then
      // update position
      FPositionMap.&set(FD,lPos+Written);
  except
    on E : TJSObject do
      Result:=ExceptToError(E);
  end;
end;

function TWASIZenFS.Sync(FD: Integer): NativeInt;
begin
  try
    ZenFS.fSyncSync(fd);
    Result:=resOK;
  except
    on E : TJSObject do
      Result:=ExceptToError(E);
  end;
end;

function TWASIZenFS.DataSync(FD: Integer): NativeInt;
begin
  try
    ZenFS.fdatasyncSync(fd);
    Result:=resOK;
  except
    on E : TJSObject do
      Result:=ExceptToError(E);
  end;
end;

function TWASIZenFS.Seek(FD: integer; Offset: Integer; Whence: TSeekWhence; out
  NewPos: Integer): NativeInt;

var
  lPos : JSValue;
  lIntPos : Integer absolute lPos;
  Stat : TZenFSStats;


begin
  try
    case whence of
      swBeginning :
        begin
        lIntPos:=AsIntNumber(OffSet);
        FPositionMap.&set(FD,lIntPos);
        end;
      swCurrent :
        begin
        lPos:=FPositionMap.get(FD);
        if isUndefined(lPos) then
          Raise TZenFSErrnoError.new(TZenFSErrNo.EBADF);
        lIntPos:=lIntPos+AsIntNumber(Offset);
        end;
      swEnd :
        begin
        Stat:=ZenFS.fstatSync(fd);
        if Assigned(stat) then
          begin
          lIntPos:=AsIntNumber(Stat.size)+AsIntNumber(Offset);
          FPositionMap.&set(FD,lIntPos);
          end
        else
          Raise TZenFSErrnoError.new(TZenFSErrNo.EBADF);
        end;
    end;
    newPos:=lIntPos;
  except
    on E : TJSObject do
      Result:=ExceptToError(E);
  end;
end;

function TWASIZenFS.Read(FD: Integer; Data: TJSUint8Array; AtPos: Integer; out
  BytesRead: Integer): NativeInt;

Var
  V : TJSDataView;
  lPos : jsValue;
  lIntPos : Integer absolute lPos;
  opts : TZenFSReadSyncOptions;

begin
  V:=TJSDataView.new(Data.buffer);
  try
    opts:=TZenFSReadSyncOptions.new;
    opts.offset:=0;
    opts.length:=Data.byteLength;
    if AtPos<>-1 then
      lIntPos:=AtPos
    else
      begin
      lPos:=FPositionMap.get(FD);
      if isUndefined(lPos) then
        Raise TZenFSErrnoError.new(TZenFSErrNo.EBADF);
      end;
    opts.position:=lIntPos;
    BytesRead:=ZenFS.readSync(FD,V,Opts);
    if atPos=-1 then
      // update position
      FPositionMap.&set(FD,lIntPos+BytesRead);
    Result:=resOK;
  except
    on E : TJSObject do
      Result:=ExceptToError(E);
  end;
end;

function TWASIZenFS.ReadDir(FD: Integer; Cookie : NativeInt; out DirEnt: TWasiFSDirent): NativeInt;

var
  DirEnts : TZenFSDirentArray;
  ZDirEntry : TZenFSDirent;

begin
  DirEnts:=IsDirEnt(FD);
  if Not Assigned(DirEnts) then
    Exit(WASI_EBADF);
  if (Cookie<0) or (Cookie>=Length(Dirents)) then
    Exit(WASI_ENOENT);
  ZDirEntry:=Dirents[Cookie];
  DirEnt.name:=ZDirEntry.path;
  if ZDirEntry.isFile() then
    Dirent.EntryType:=dtFile
  else if ZDirEntry.isDirectory() then
    Dirent.EntryType:=dtDirectory
  else if ZDirEntry.isSymbolicLink() then
    Dirent.EntryType:=dtSymlink
  else if ZDirEntry.isFIFO() then
    Dirent.EntryType:=dtFIFO
  else if ZDirEntry.isBlockDevice() then
    Dirent.EntryType:=dtBlockDevice
  else if ZDirEntry.isCharacterDevice() then
    Dirent.EntryType:=dtCharacterDevice
  else if ZDirEntry.isSocket() then
    Dirent.EntryType:=dtSocket;
  Dirent.Next:=Cookie+1;
  Result:=ResOK;
end;

function TWASIZenFS.GetPrestat(FD: Integer): String;
begin
  if (FD=3) then
    begin
    {FRoot:=}ZenFS.OpenDirSync('/');
    Result:='/';
    end;
end;

procedure TWASIZenFS.PreLoadFile(aPath: String; aData: TJSDataView);
begin
  ZenFS.WriteFileSync(aPath,aData);
end;

function TWASIZenFS.UnLinkAt(FD: Integer; const aPath: String): NativeInt;

var
  lPath : String;

begin
  lPath:=PrependFD(FD,aPath);
  try
    ZenFS.unlinkSync(lPath);
    Result:=resOK;
  except
    on E : TJSObject do
      Result:=ExceptToError(E);
  end;
end;

function TWASIZenFS.OpenAt(FD : Integer; FDFlags : NativeInt; aPath : String; Flags, fsRightsBase, fsRightsInheriting, fsFlags: NativeInt; out Openfd: Integer): NativeInt;

var
  lPath : String;
  lFlags : String;
  Rights : NativeInt;
  Reading,Writing : Boolean;
  Dir : TZenFSDirentArray;
  Opts : TZenFSReadDirOptions;

  Function HasFlag(aFlag : Integer) : Boolean;
  begin
    Result:=(Flags and aFlag)<>0;
  end;

  Function HasRight(aRight : Integer) : Boolean;
  begin
    if IsBigint(Rights) then
      begin
      asm
        Result = ((Rights & BigInt(aRight)) != 0)
      end;
      end
    else
      Result:=(Rights and aRight)<>0;
  end;

begin
  if (fdFlags<>0) and (fsFlags<>0) and (fsRightsInheriting<>0) then ;
  lPath:=PrependFD(FD,aPath);
  if Not HasFlag(__WASI_OFLAGS_DIRECTORY) then
    begin
    Rights:=AsIntNumber(fsRightsBase);
    Writing:=HasFlag(__WASI_OFLAGS_CREAT) or HasRight(__WASI_RIGHTS_FD_WRITE);
    Reading:=HasRight(__WASI_RIGHTS_FD_READ);
    if Writing then
      begin
      if HasFlag(__WASI_OFLAGS_TRUNC) then
        lFLags:='w'
      else
        lFLags:='a';
      if HasFlag(__WASI_OFLAGS_EXCL) then
        lFLags:=lFLags+'x';
      if Reading then
        lFLags:=lFLags+'+';
      end
    else
      begin
      lFlags:='r';
      end;
    end;
  try
    if HasFlag(__WASI_OFLAGS_DIRECTORY) then
      begin
      Opts:=TZenFSReadDirOptions.New;
      Opts.withFileTypes:=True;
      Dir:=ZenFS.readdirSyncDirent(lpath,Opts);
      OpenFD:=AllocateDirFD(Dir);
      end
    else
      begin
      OpenFD:=ZenFS.openSync(lPath,lFlags);
      if OpenFD<>-1 then
        FPositionMap.&set(OpenFD,0);
      end;
    Result:=resOK;
  except
    on E : TJSObject do
      Result:=ExceptToError(E);
  end;
end;

function TWASIZenFS.ReadLinkAt(FD: Integer; aPath: String; out aTarget: String): NativeInt;

var
  lPath : String;

begin
  lPath:=PrependFD(FD,aPath);
  try
    aTarget:=ZenFS.readlinkSync(lPath);
    Result:=resOK;
  except
    on E : TJSObject do
      Result:=ExceptToError(E);
  end;
end;

end.

