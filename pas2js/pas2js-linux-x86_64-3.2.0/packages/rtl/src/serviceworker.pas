{$IFNDEF FPC_DOTTEDUNITS}
unit serviceworker;
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
  TJSWorkerNavigator = BrowserApi.WorkerBase.TJSWorkerNavigator;
  TJSWorkerLocation = BrowserApi.WorkerBase.TJSWorkerLocation;
  TJSWorkerGlobalScope = BrowserApi.WorkerBase.TJSWorkerGlobalScope;
  {$ELSE}
  TJSWorkerNavigator = webworkerbase.TJSWorkerNavigator;
  TJSWorkerLocation = webworkerbase.TJSWorkerLocation;
  TJSWorkerGlobalScope = webworkerbase.TJSWorkerGlobalScope;
  {$ENDIF}

  { TJSServiceworkerGlobalScope }

  TJSClientsMatchAllOptions = class external name 'Object'
    includeUncontrolled : Boolean;
    type_ : string; external name 'type';
  end;

  TJSClients = class external name 'Clients' (TJSObject)
    function claim : TJSPromise;
    function get(ID : String) : TJSPromise;
    function matchAll : TJSPromise;
    function matchAll(Options : TJSClientsMatchAllOptions) : TJSPromise;
    function matchAll(Options : TJSObject) : TJSPromise;
    function openWindow(url : string) : TJSPromise;
  end;

  TJSServiceworkerGlobalScope = class external name 'ServiceWorkerGlobalScope' (TJSWorkerGlobalScope)
  private
    FClients: TJSClients; external name 'clients';
    FRegistration: TJSServiceWorkerRegistration; external name 'registration';
  Public
    Function SkipWaiting : TJSPromise; external name 'skipWaiting';
    property registration : TJSServiceWorkerRegistration Read FRegistration;
    property clients : TJSClients Read FClients;
  end;

var
  Self_ : TJSServiceworkerGlobalScope; external name 'self';

implementation

end.

