program fsdemo;

uses SysUtils;

Const
  {$ifdef cpuwasm32}
  OurDir = '/tmp';
  {$else}
  OurDir = '/tmp/something';
  {$Endif}
  OurFile = OurDir+'/test.txt';

Procedure ShowDir(aDir : String);

var
  Info : TSearchRec;
  aFileCount : Integer;
  TotalSize : Int64;
  S : String;
begin
  TotalSize:=0;
  aFileCount:=0;
  If FindFirst(aDir+'*',faAnyFile,Info)=0 then
    try
      Repeat
        S:=Info.Name;
        if (Info.Attr and faDirectory)<>0 then
          S:=S+'/';
        if (Info.Attr and faSymLink)<>0 then
          S:=S+'@';
        Writeln(FormatDateTime('yyyy-mm-dd"T"hh:nn:ss',Info.TimeStamp),' ',Info.Size:10,' '+S);
        TotalSize:=TotalSize+Info.Size;
        inc(aFileCount);
      until FindNext(Info)<>0;
    finally
      FindClose(Info)
    end;
  Writeln('Total: ',TotalSize,' bytes in ',aFileCount,' files');
end;

var
  HasDir : Boolean;
  HasFile: Boolean;
  S : UTF8String;
  aSize,FD,byteCount : Integer;

begin
  HasDir:=DirectoryExists(OurDir);
  if HasDir then
    Writeln('Directory already exists: ',OurDir)
  else if CreateDir(OurDir) then
    Writeln('Created new directory: ',OurDir)
  else
    Writeln('Failed to create directory: ',OurDir);
  Writeln('Contents of root:');
  ShowDir('/');
  HasFile:=FileExists(OurFile);
  If HasFile then
    Writeln('File exists: ',OurFile)
  else
    begin
    Writeln('Creating file: ',OurFile);
    FD:=FileCreate(OurFile);
    if FD=-1 then
      Writeln('Failed to get fileHandle: ',FD)
    else
      begin
      Writeln('Got fileHandle: ',FD);
      S:='Hello, WebAssembly World!';
      ByteCount:=FileWrite(FD,S[1],Length(S));
      Writeln('Wrote ',byteCount,' bytes to file. Expected: ',Length(S));
      FileClose(FD);
      Writeln('Closed file');
      end;
    end;
  Writeln('Contents of ',OurDir,':');
  ShowDir(ourdir+'/');
  If FileExists(OurFile) then
    begin
    Writeln('Opening file: ',OurFile);
    FD:=FileOpen(OurFile,fmOpenRead);
    if FD=-1 then
      Writeln('Failed to get fileHandle: ',FD)
    else
      begin
      Writeln('Got fileHandle: ',FD);
      aSize:=FileSeek(FD,0,fsFromEnd);
      Writeln('Got file size: ',aSize);
      FileSeek(FD,0,fsFromBeginning);
      SetLength(S,aSize);
      if aSize>0 then
        ByteCount:=FileRead(FD,S[1],aSize);
      Writeln('Read ',byteCount,' bytes from file. Expected: ',aSize);
      Writeln('File contents: "',S,'"');
      FileClose(FD);
      Writeln('Closed file');
      end;
    end;
  if Not HasFile then
    Writeln('Deleting file ',DeleteFile(OurFile));
  if Not HasDir then
    Writeln('Deleting directory ',RemoveDir(OurDir));
  Writeln('All done!');
end.

