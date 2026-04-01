unit wasiworkerapp;

{$mode ObjFPC}

interface

uses
  Classes, SysUtils, workerapp, wasienv;

Type
  { TWorkerWASIHostApplication }

  TWorkerWASIHostApplication = class(TWorkerApplication)
  private
    class var _WasiHostClass : TWasiHostClass;
  private
    FHost : TWASIHost;
    FOnHostCreated: TNotifyEvent;
    function GetEnv: TPas2JSWASIEnvironment;
  protected
    procedure RegisterMessageHandlers; virtual;
    procedure DoRun; override;
    function CreateHost: TWASIHost; virtual;
    procedure DoHostCreated; virtual;
  public
    Constructor Create(aOwner : TComponent); override;
    Destructor Destroy; override;
    class procedure SetWasiHostClass(aClass : TWasiHostClass);
    // WASI Host
    Property Host : TWASIHost Read FHost;
    // Load and start webassembly. If DoRun is true, then Webassembly entry point is called.
    // If aBeforeStart is specified, then it is called prior to calling run, and can disable running.
    // If aAfterStart is specified, then it is called after calling run. It is not called is running was disabled.
    // Runs simply the function of the same name on Host
    Procedure StartWebAssembly(aPath: string; DoRun : Boolean = True;  aBeforeStart : TBeforeStartCallback = Nil; aAfterStart : TAfterStartCallback = Nil);
    // Environment to be used
    Property WasiEnvironment : TPas2JSWASIEnvironment Read GetEnv;
    // Called after the WASI host was created, so you can customize its properties
    Property OnHostCreated : TNotifyEvent Read FOnHostCreated Write FOnHostCreated;
  end;


implementation

{ TWorkerWASIHostApplication }

function TWorkerWASIHostApplication.GetEnv: TPas2JSWASIEnvironment;
begin
  Result:=FHost.WasiEnvironment;
end;

procedure TWorkerWASIHostApplication.RegisterMessageHandlers;
begin
  // Do nothing
end;

function TWorkerWASIHostApplication.CreateHost: TWASIHost;
var
  C : TWASIHostClass;
begin
  C:=_WasiHostClass;
  if C=Nil then
    C:=TWASIHost;
  Result:=C.Create(Self);
end;

procedure TWorkerWASIHostApplication.DoHostCreated;
begin
  If Assigned(FonHostCreated) then
    FOnHostCreated(Self);
end;

procedure TWorkerWASIHostApplication.DoRun;
begin
  // Do nothing
end;

constructor TWorkerWASIHostApplication.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  RegisterMessageHandlers;
  FHost:=CreateHost;
  DoHostCreated;
end;

destructor TWorkerWASIHostApplication.Destroy;
begin
  FreeAndNil(FHost);
  inherited Destroy;
end;

class procedure TWorkerWASIHostApplication.SetWasiHostClass(aClass: TWasiHostClass);
begin
  _WasiHostClass:=aClass;
end;

procedure TWorkerWASIHostApplication.StartWebAssembly(aPath: string; DoRun: Boolean;
  aBeforeStart: TBeforeStartCallback = nil; aAfterStart: TAfterStartCallback = nil);

begin
  FHost.StartWebAssembly(aPath,DoRun,aBeforeStart,aAfterStart);
end;

end.

