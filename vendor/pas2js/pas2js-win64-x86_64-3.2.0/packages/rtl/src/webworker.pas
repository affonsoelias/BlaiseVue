{
    This file is part of the Pas2JS run time library.
    Copyright (c) 2022 by Michael Van Canneyt
    
    Browser WebWorker API definitions.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
{$IFNDEF FPC_DOTTEDUNITS}
unit webworker;
{$ENDIF}

{$mode ObjFPC}
{$modeswitch externalclass}

interface

uses
{$IFDEF FPC_DOTTEDUNITS}
  JSApi.JS, BrowserApi.WebOrWorker, BrowserApi.WorkerBase;
{$ELSE}
  JS, weborworker, webworkerbase;
{$ENDIF}

Type
  {$IFDEF FPC_DOTTEDUNITS}
  TJSWorkerNavigator = BrowserApi.WorkerBase.TJSWorkerNavigator;
  TJSWorkerLocation = BrowserApi.WorkerBase.TJSWorkerLocation;
  TJSWorkerGlobalScope = BrowserApi.WorkerBase.TJSWorkerGlobalScope;
  {$ELSE}
  TJSWorkerNavigator = webworkerbase.TJSWorkerNavigator;
  TJSWorkerLocation = webworkerbase.TJSWorkerLocation;
  TJSWorkerGlobalScope = webworkerbase.TJSWorkerGlobalScope;
  {$ENDIF}

  { TJSDedicatedWorkerGlobalScope }
  TJSAnimationFrameCallBack = reference to procedure(aTimeStamp : TJSDOMHighResTimeStamp);

  TJSDedicatedWorkerGlobalScope = class external name 'DedicatedWorkerGlobalScope' (TJSWorkerGlobalScope)
  private
    FName: String; external name 'name';
  Public
    Procedure cancelAnimationFrame(handle : NativeInt);
    Procedure close;
    Procedure postMessage(aMessage : JSValue); overload;
    Procedure postMessage(aMessage : JSValue; TransferableObjects : Array of JSValue); overload;
    function RequestAnimationFrame(aCallback : TJSAnimationFrameCallBack) : NativeInt;
    Property name : String Read FName;
  end;



Var
  Self_ : TJSDedicatedWorkerGlobalScope; external name 'self';
  location : TJSWorkerLocation ; external name 'location';
  console : TJSConsole; external name 'console';
  navigator : TJSWorkerNavigator; external name 'navigator';
  caches : TJSCacheStorage; external name 'caches';

function fetch(resource: String; init: TJSObject): TJSPromise; overload; external name 'fetch';
//function fetch(resource: String): TJSPromise; overload; external name 'fetch';
function fetch(resource: String): TJSResponse; {$IFNDEF SkipAsync}async;{$ENDIF} overload; external name 'fetch';
function fetch(resource: TJSObject; init: TJSObject): TJSPromise; overload; external name 'fetch';
function fetch(resource: TJSObject): TJSPromise; overload; external name 'fetch';

implementation

end.

