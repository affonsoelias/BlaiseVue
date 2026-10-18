unit workerapp;

{$mode ObjFPC}

interface

uses
  Classes, SysUtils, CustApp, WebWorker, Rtl.WorkerCommands;

Type

  { TWorkerApplication }

  TWorkerApplication = class(TCustomApplication)
  Private
    FSendOutputToConsole: Boolean;
  protected
    procedure DoLog(EventType: TEventType; const Msg: String); override;
  Public
    constructor Create(AOwner: TComponent); override;
    procedure ShowException(aError: Exception); override;
    function GetConsoleApplication: boolean; override;
    function GetLocation: String; override;
    // Send output to console channel ?
    Property SendOutputToConsole : Boolean Read FSendOutputToConsole Write FSendOutputToConsole;
    // Send a command to the process that started the worker.
    procedure SendCommand(aCommand: TCustomWorkerCommand);
    // Get the list of environment variables.
    procedure GetEnvironmentList(List: TStrings; NamesOnly: Boolean); override;
  end;

implementation

uses typinfo, js, types;

var
  EnvNames: TJSObject;

procedure ReloadEnvironmentStrings;

var
  I : Integer;
  S,N : String;
  A,P : TStringDynArray;

begin
  if Assigned(EnvNames) then
    FreeAndNil(EnvNames);
  EnvNames:=TJSObject.new;
  S:=self_.Location.search;
  S:=Copy(S,2,Length(S)-1);
  A:=TJSString(S).split('&');
  for I:=0 to Length(A)-1 do
    begin
    P:=TJSString(A[i]).split('=');
    N:=LowerCase(decodeURIComponent(P[0]));
    if Length(P)=2 then
      EnvNames[N]:=decodeURIComponent(P[1])
    else if Length(P)=1 then
      EnvNames[N]:=''
    end;
end;

function MyGetEnvironmentVariable(Const EnvVar: String): String;

Var
  aName : String;

begin
  aName:=Lowercase(EnvVar);
  if EnvNames.hasOwnProperty(aName) then
    Result:=String(EnvNames[aName])
  else
    Result:='';
end;

function MyGetEnvironmentVariableCount: Integer;
begin
  Result:=length(TJSOBject.getOwnPropertyNames(envNames));
end;

function MyGetEnvironmentString(Index: Integer): String;
begin
  Result:=String(EnvNames[TJSOBject.getOwnPropertyNames(envNames)[Index]]);
end;


constructor TWorkerApplication.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSendOutputToConsole:=true;
end;

procedure TWorkerApplication.ShowException(aError: Exception);
Var
  Ex : TWorkerExceptionCommand;

begin
  Ex:=TWorkerExceptionCommand.Create(aError.ClassName,aError.Message);
  SendCommand(Ex);
end;

function TWorkerApplication.GetConsoleApplication: boolean;
begin
  Result:=true;
end;

function TWorkerApplication.GetLocation: String;
begin
  Result:={$IFDEF FPC_DOTTEDUNITS}BrowserApi.Worker.{$ELSE}WebWorker.{$ENDIF}Location.pathname;
end;

procedure TWorkerApplication.SendCommand(aCommand: TCustomWorkerCommand);
begin
  TCommandDispatcher.Instance.SendCommand(aCommand);
end;

procedure TWorkerApplication.GetEnvironmentList(List: TStrings; NamesOnly: Boolean);
var
  Names: TStringDynArray;
  i: Integer;
begin
  Names:=TJSObject.getOwnPropertyNames(EnvNames);
  for i:=0 to length(Names)-1 do
  begin
    if NamesOnly then
      List.Add(Names[i])
    else
      List.Add(Names[i]+'='+String(EnvNames[Names[i]]));
  end;
end;

procedure TWorkerApplication.DoLog(EventType: TEventType; const Msg: String);
var
  S : String;
begin
  if not SendOutputToConsole then
    Exit;
  S:=GetEnumName(TypeInfo(TEventType),Ord(EventType));
  TCommandDispatcher.Instance.SendConsoleCommand(TConsoleOutputCommand.Create(Format('[%s] %s',[S,Msg])));
end;

initialization
  ReloadEnvironmentStrings;
  OnGetEnvironmentVariable:=@MyGetEnvironmentVariable;
  OnGetEnvironmentVariableCount:=@MyGetEnvironmentVariableCount;
  OnGetEnvironmentString:=@MyGetEnvironmentString;
end.

