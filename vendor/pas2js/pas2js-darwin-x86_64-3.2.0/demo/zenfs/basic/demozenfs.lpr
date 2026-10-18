program demozenfs;

{$mode objfpc}

uses
{$IFDEF FPC_DOTTEDUNITS}
  Browser.Console, JSApi.JS, Api.ZenFS.Core, Api.ZenFS.Dom;
{$ELSE}
  BrowserConsole, JS, libzenfs, libzenfsdom;
{$ENDIF}

Procedure DoTest; async;

var
  Buf : TZenFSBuffer;
  aView : TJSDataView;
  BufStr : String absolute Buf;
  ArrayBuf : TJSArrayBuffer;
  I,Errs : Integer;

begin
  await(tjsobject,  ZenFS.configure(
    new(
      ['mounts', new([
        '/', DomBackends.WebStorage
       ])
      ])
    )
  );
  if ZenFS.existsSync('/something') then
    Writeln('Text file already exists')
  else
    begin
    Writeln('Creating new file');
    ZenFS.writeFileSync('/something', 'a nice text', TZenFSBufferEncoding.UTF8);
    end;
  Buf:=ZenFS.readFileSync('/something',TZenFSBufferEncoding.UTF8);
  if IsString(Buf) then
    Writeln('Read : ',BufStr)
  else
    Writeln('Got buffer with ',Buf.length,' bytes');
  if ZenFS.existsSync('/data.dat') then
    Writeln('Binary file already exists')
  else
    begin
    Writeln('Creating new binary file');
    ArrayBuf:=TJSarrayBuffer.new(3);
    Buf:=TZenFSBuffer.New(ArrayBuf);
    Buf._set([1,2,3]);
    aView:=TJSDataView.New(ArrayBuf);
    ZenFS.writeFileSync('/data.dat', aView);
    end;
  Writeln('Reading from binary file');
  Buf:=ZenFS.readFileSync('/data.dat');
  aView:=TJSDataView.New(Buf.buffer);
  Writeln('Read : ',aView.byteLength,' bytes');
  Errs:=0;
  For I:=1 to 3 do
    If aView.getInt8(i-1)<>i then
      begin
      Writeln('Error, expected ',I,' got ',aView.getInt8(i-1));
      inc(Errs);
      end;
  if Errs=0 then
    Writeln('All binary data read OK')
  else
    Writeln('Got ',Errs,' errors when reading binary');
end;

begin
  ConsoleStyle:=DefaultCRTConsoleStyle;
  HookConsole;
  DoTest;
end.
