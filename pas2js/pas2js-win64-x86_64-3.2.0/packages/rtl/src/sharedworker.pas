{$IFNDEF FPC_DOTTEDUNITS}
unit sharedworker;
{$ENDIF}

{$mode ObjFPC}
{$modeswitch externalclass}

interface

uses
{$IFDEF FPC_DOTTEDUNITS}
  JSApi.JS, BrowserApi.WebOrWorker, BrowserApi.WorkerBase;
{$ELSE}
  js, weborworker, webworkerbase;
{$Endif}

Type
  {$IFDEF FPC_DOTTEDUNITS}
  TJSWorkerNavigator = BrowserApi.WebWorkerBase.TJSWorkerNavigator;
  TJSWorkerLocation = BrowserApi.WebWorkerBase.TJSWorkerLocation;
  TJSWorkerGlobalScope = BrowserApi.WebWorkerBase.TJSWorkerGlobalScope;
  {$ELSE}
  TJSWorkerNavigator = webworkerbase.TJSWorkerNavigator;
  TJSWorkerLocation = webworkerbase.TJSWorkerLocation;
  TJSWorkerGlobalScope = webworkerbase.TJSWorkerGlobalScope;
  {$ENDIF}
  { TJSServiceworkerGlobalScope }

  TJSSharedWorkerGlobalScope = class external name 'SharedWorkerGlobalScope' (TJSWorkerGlobalScope)
  private
    FName : String; external name 'name';
  Public
    procedure close;
    property name : string Read FName;
  end;

var
  Self_ : TJSSharedWorkerGlobalScope; external name 'self';


implementation

end.

