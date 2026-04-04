program hostsimpletest;

{$mode objfpc}

uses
  BrowserConsole, JS, Types, Classes, SysUtils, Web, WasiEnv, WasiHostApp, JOB_Browser, JOB_Shared;

Type

  { TMyObject }

  TMyObject = Class(TObject)
  private
    fa: String;
  public
    Constructor Create(aValue : string);
    Property a : String Read fa write fa;
  end;

  { TMyApplication }

  TMyApplication = class(TBrowserWASIHostApplication)
  Private
    FWADomBridge : TJSObjectBridge;
    function CreateMyObject(const aName: String; aArgs: TJSValueDynArray): TObject;
    function CreateBrowserObject(const aName: String; aArgs: TJSValueDynArray): TJSObject;
  Public
    constructor Create(aOwner : TComponent); override;
    procedure DoRun; override;
  end;

{ TMyObject }

constructor TMyObject.Create(aValue: string);
begin
  fa:=aValue;
end;

{ TMyApplication }

function TMyApplication.CreateMyObject(const aName: String; aArgs: TJSValueDynArray): TObject;
begin
  Writeln('Host: Creating TMyObject with argument "',aArgs[0],'"');
  Result:=TMyObject.Create(String(aArgs[0]));
end;

function TMyApplication.CreateBrowserObject(const aName: String; aArgs: TJSValueDynArray): TJSObject;
begin
  Writeln('Host: Creating browserobject with argument "',aArgs[0],'"');
  Result:=TJSObject.New;
  Result['Aloha']:=String(aArgs[0]);
end;

constructor TMyApplication.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FWADomBridge:=TJSObjectBridge.Create(WasiEnvironment);
  RunEntryFunction:='_initialize';
  FWADomBridge.RegisterObjectFactory('MyObject',@CreateMyObject);
  FWADomBridge.RegisterJSObjectFactory('MyBrowserObject',@CreateBrowserObject);
end;

procedure TMyApplication.DoRun;
begin
  // Your code here
  Terminate;
  StartWebAssembly('wasmsimpletest.wasm');
end;

var
  Application : TMyApplication;
begin
  ConsoleStyle:=DefaultCRTConsoleStyle;
  HookConsole;
  Application:=TMyApplication.Create(nil);
  Application.Initialize;
  Application.Run;
end.
