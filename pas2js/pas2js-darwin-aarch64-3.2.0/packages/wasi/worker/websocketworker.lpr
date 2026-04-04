{
  Sample websocket worker process. 
  This must be used in conjunction with the use of the TWorkerWebSocketAPI class from the
  wasm.pas2js.websocket.worker unit in the thread worker.
}
program websocketworker;

{$mode objfpc}
{$modeswitch externalclass}

uses
    Classes
  , JS
  , weborworker
  , SysUtils
  , wasienv
  , WasiWorkerThreadHost
  , Rtl.WebThreads
  , wasm.websocket.shared
  , wasm.pas2js.websocketapi
  , wasm.pas2js.websocket.handler
  ;

Type
  { TWebSocketHandlerApplication }

  TWebSocketHandlerApplication = class(TWorkerThreadRunnerApplication)
  private
    FWebsocketAPI : TWasmWebSocketAPIHandler;
    procedure SetSharedMem(aData: TWorkerCommand);
  public
    constructor Create(aOwner: TComponent); override;
    function HandleCustomCommand(aData: TWorkerCommand): Boolean; override;
    procedure HandleError(Sender: TObject; Error: Exception; Args: TJSFunctionArguments; var ReRaise: Boolean);
    procedure HandleJSError(Sender: TObject; Error: TJSError; Args: TJSFunctionArguments; var ReRaise: Boolean);
    procedure dorun; override;
    procedure SetLogging(aEnable: boolean);
  end;

procedure TWebSocketHandlerApplication.SetLogging(aEnable : boolean);

begin
  FWebsocketAPI.LogAPICalls:=aEnable;
end;

constructor TWebSocketHandlerApplication.Create(aOwner : TComponent);

begin
  inherited Create(aOwner);
  FWebsocketAPI:=TWasmWebSocketAPIHandler.Create(WasiEnvironment);
  SetLogging(False);
end;

procedure TWebSocketHandlerApplication.SetSharedMem(aData : TWorkerCommand);

var
  lSetSharedMemCommand : TSetSharedMemWorkerCommand absolute aData;

begin
  FWebsocketAPI.SharedMem:=lSetSharedMemCommand.Buffer;
end;

function TWebSocketHandlerApplication.HandleCustomCommand(aData: TWorkerCommand): Boolean;
begin
  Case aData.Command of
   cmdRun : Result:=True; // Pretend it was run
   cmdCancel : Result:=True; // Pretend it was canceled
   cmdWebsocketSharedMem :
     SetSharedMem(aData);
   cmdEnableLog,
   cmdDisableLog:
     begin
     SetLogging(aData.Command=cmdEnableLog);
     Result:=true;
     end
  else
    Result:=False;
  end
end;

procedure TWebSocketHandlerApplication.HandleError(Sender: TObject; Error: Exception; Args: TJSFunctionArguments; var ReRaise: Boolean);
begin
  Log(etError,'Host: Error %s calling callback with %d arguments: %s',[Error.ClassName,Args.Length,Error.Message]);
  ReRaise:=True;
end;

procedure TWebSocketHandlerApplication.HandleJSError(Sender: TObject; Error: TJSError; Args: TJSFunctionArguments; var ReRaise: Boolean
  );
var
  CN : String;

begin
  CN:=GetJSClassName(Error);
  Log(etError,'Host: Error %s calling callback with %d arguments: %s',[CN,Args.Length,Error.Message]);
  if Reraise then
    Raise Error;
end;

procedure TWebSocketHandlerApplication.dorun;

begin
  inherited dorun;
end;

{ TApplication }

var
  App: TWebSocketHandlerApplication;

begin
  App:=TWebSocketHandlerApplication.Create(nil);
  App.Run;
end.
