{$IFNDEF FPC_DOTTEDUNITS}
unit wasiworkerthreadhost deprecated 'use rtl.threadrunner or rtl.workerthreadhost';
{$ENDIF}

{$mode ObjFPC}
{$modeswitch externalclass}
{ $define NOLOGAPICALLS}

interface

uses
{$IFDEF FPC_DOTTEDUNITS}
  System.SysUtils, JSApi.JS,  System.WebThreads,
  Rtl.ThreadController;
{$ELSE} 
  SysUtils, JS, Rtl.WebThreads, Rtl.ThreadController, WasiWorkerApp,
  rtl.workerthreadhost, rtl.threadrunner;
{$ENDIF}

const
  // no longer used
  ThreadRunnerScript = 'wasm_worker_runner.js';
  ThreadCount = 4;

Type
  TWASIThreadHost = TWASIThreadControllerHost;
  TWorkerThreadSupport = class(TWasmThreadSupportApi);
  TWorkerWASIHostApplication = Class(WasiWorkerApp.TWorkerWASIHostApplication);
  TWorkerThreadRunnerApplication = Class(Rtl.threadRunner.TWorkerThreadRunnerApplication);
  TWorkerThreadControllerHost = Class(TWASIThreadControllerHost);
  TWorkerThreadControllerApplication = class(rtl.workerthreadhost.TWorkerThreadControllerApplication);

function GetJSClassName(aObj : TJSObject) : string;

implementation

function GetJSClassName(aObj : TJSObject) : string;
begin
  Result:=JSClassName(aObj);
end;

Initialization
  TWasmThreadController.SetInstanceClass(TWorkerThreadRunner);
end.

