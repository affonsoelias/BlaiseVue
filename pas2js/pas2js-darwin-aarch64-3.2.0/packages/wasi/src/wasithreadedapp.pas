{$IFNDEF FPC_DOTTEDUNITS}
unit wasithreadedapp;
{$ENDIF}

{$mode ObjFPC}
{$modeswitch externalclass}
{$modeswitch typehelpers}

interface

uses
{$IFDEF FPC_DOTTEDUNITS}
  System.SysUtils, System.WebThreads, Wasi.Env, Fcl.App.Wasi.Host, Rtl.WorkerCommands, Rtl.ThreadController
  BrowserApi.WebOrWorker;
{$ELSE} 
  SysUtils, Rtl.WebThreads, wasienv, wasihostapp, Rtl.WorkerCommands, Rtl.ThreadController;
{$ENDIF}

Type
  { TBrowserWASIThreadedHostApplication }

  TBrowserWASIThreadedHostApplication = TBrowserWASIHostApplication;

  { ThreadAppWASIHost }

  TThreadAppWASIHost = class(TWASIHost)
  private
  Protected
    class function NeedSharedMemory: Boolean; override;
    function GetThreadSupport: TThreadController; virtual;
    Procedure DoAfterInstantiate; override;
    Function CreateWasiEnvironment : TPas2JSWASIEnvironment; override;
  Public
    Property ThreadSupport : TThreadController Read GetThreadSupport;
  end;

implementation

class function TThreadAppWASIHost.NeedSharedMemory: Boolean;
begin
  Result:=True;
end;

function TThreadAppWASIHost.GetThreadSupport: TThreadController;
begin
  Result:=TThreadController.Instance as TThreadController;
end;

procedure TThreadAppWASIHost.DoAfterInstantiate;
begin
  inherited DoAfterInstantiate;
  Writeln('Setting wasm module and memory');
  If Assigned(ThreadSupport) then
    // Will send load commands
    ThreadSupport.SetWasmModuleAndMemory(PreparedStartDescriptor.Module,PreparedStartDescriptor.Memory);
end;

function TThreadAppWASIHost.CreateWasiEnvironment: TPas2JSWASIEnvironment;
begin
  Result:=inherited CreateWasiEnvironment;
  TWasmThreadSupportApi.Create(Result);
end;


initialization
  TCommandDispatcher.Instance.DefaultSenderID:='HTML page thread';
  TThreadConsoleOutput.Init;
  TWASIHostApplication.SetWasiHostClass(TThreadAppWASIHost);
end.

