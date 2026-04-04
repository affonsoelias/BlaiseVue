{
    This file is part of the Free Component Library

    Webassembly Storage API - Demo program
    Copyright (c) 2025 by Michael Van Canneyt michael@freepascal.org

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

program storagehost;

{$mode objfpc}
{$modeswitch externalclass}

uses
  wasiworkerapp, JS, Classes, SysUtils, Web, wasm.pas2js.storage,
  rtl.WorkerCommands, pas2js.storagebridge.worker;

Type
  { TMyApplication }

  TMyApplication = class(TWorkerWASIHostApplication)
    FStorage : TStorageAPI;
  private
    procedure HandleConsoleWrite(Sender: TObject; aOutput: string);
  protected
    procedure RegisterMessageHandlers; override;
    procedure DoRun; override;
  public
    Constructor Create(aOwner : TComponent); override;
  end;

procedure TMyApplication.DoRun;

begin
  Terminate;
  StartWebAssembly('demostorage.wasm');
end;

procedure TMyApplication.HandleConsoleWrite(Sender: TObject; aOutput: string);
begin
  TCommandDispatcher.Instance.SendConsoleCommand(TConsoleOutputCommand.create(aOutput));
end;

procedure TMyApplication.RegisterMessageHandlers;
begin
  inherited RegisterMessageHandlers;
end;

constructor TMyApplication.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  Host.OnConsoleWrite:=@HandleConsoleWrite;
  FStorage:=TStorageAPI.Create(WasiEnvironment);
  FStorage.LogAPI:=FStorage.LogAPI or (TWorkerStorageBridge._LocalStorage.getItem('showlog')='1');
end;

var
  Application : TMyApplication;

begin
  Application:=TMyApplication.Create(nil);
  Application.Initialize;
  Application.Run;
end.
