program exceptdemo;

{$mode objfpc}

uses
  BrowserConsole, BrowserApp, WasiEnv,WASIHostApp, JS, Classes, SysUtils, Web, WebAssembly;

type
  { TMyApplication }

  TMyApplication = class(TWASIHostApplication)
  private
    procedure DoAfter(Sender: TObject; aDescriptor: TWebAssemblyStartDescriptor);
    procedure ShowInfo(aInfo: TLastExceptionInfo);
  protected
    procedure DoRun; override;
  public
  end;

procedure TMyApplication.ShowInfo(aInfo : TLastExceptionInfo);

begin
  with aInfo do
    Writeln('Got exception during DoTest: ',ClassName,': "',Message,'", more: ',More)
end;

procedure TMyApplication.DoAfter(Sender: TObject; aDescriptor: TWebAssemblyStartDescriptor);

type
  TTestProc = procedure;

var
  lInfo : TLastExceptionInfo;

begin
  try
    TTestProc(aDescriptor.exported['DoTest'])();
  except
    on e : TJSWebAssemblyException do
      begin
      if Host.GetExceptionInfo(lInfo) then
         ShowInfo(lInfo)
      else
        Raise
      end;
  end;
  try
    TTestProc(aDescriptor.exported['DoTest2'])();
  except
    on e : TJSWebAssemblyException do
      begin
      if Host.GetExceptionInfo(lInfo) then
         ShowInfo(lInfo)
      else
        Raise
      end;
  end;
end;

procedure TMyApplication.DoRun;
begin
  // Let the wasi hosting environment know we'll handle exceptions.
  Host.ConvertNativeExceptions:=False;
  StartWebAssembly('demolib.wasm',True,Nil,@DoAfter);
end;

var
  Application : TMyApplication;

begin
  Application:=TMyApplication.Create(nil);
  Application.Initialize;
  Application.Run;
end.
