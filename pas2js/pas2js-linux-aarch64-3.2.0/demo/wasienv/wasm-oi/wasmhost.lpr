program wasmhost;

{$mode objfpc}

uses
  BrowserConsole, BrowserApp, JS, Classes, SysUtils, Web, WasiHostApp, debug.objectinspector.wasm, debug.objectinspector.html;

type

  { TDemoApplication }

  TDemoApplication = class(TBrowserWASIHostApplication)
  private
    function DoShowOUtputChange(Event: TEventListenerEvent): boolean;
    procedure DoWrite(Sender: TObject; const aOutput: String);
    function HookWasmConsole: boolean;
  protected
    FTreeView : THTMLObjectTree;
    FInspector : THTMLObjectInspector;
    FInspectorAPI : TWasmObjectInspectorApi;
    CBShowOutput : TJSHTMLInputElement;
    procedure DoRun; override;
  public
    constructor create(aOwner : TComponent); override;

  end;

function TDemoApplication.HookWasmConsole : boolean;

begin
  Result:=CBShowOutput.Checked;
  if Result then
    begin
    WasiEnvironment.OnStdOutputWrite:=@DoWrite;
    WasiEnvironment.OnStdErrorWrite:=@DoWrite;
    end
  else
    begin
    WasiEnvironment.OnStdOutputWrite:=Nil;
    WasiEnvironment.OnStdErrorWrite:=Nil;
    end;
end;

function TDemoApplication.DoShowOUtputChange(Event: TEventListenerEvent): boolean;
begin
  HookWasmConsole;
end;

procedure TDemoApplication.DoWrite(Sender: TObject; const aOutput: String);
begin
  Writeln('Wasm ',aOutput);
end;

procedure TDemoApplication.DoRun;

var
  wasmModule : string;

begin
 wasmmodule:='oidemo.wasm';
 RunEntryFunction:='_initialize';
 StartWebAssembly(WasmModule,true);
end;

constructor TDemoApplication.create(aOwner: TComponent);
begin
  Inherited;
  FTreeView:=THTMLObjectTree.Create(Self);
  FTreeView.ParentElementID:='Tree';
  FInspector:=THTMLObjectInspector.Create(Self);
  FInspector.ParentElementID:='Inspector';
  FInspectorApi:=TWasmObjectInspectorApi.Create(WasiEnvironment);
  FInspectorApi.DefaultInspector:=FInspector;
  FInspectorApi.DefaultObjectTree:=FTReeview;
  FInspectorApi.HandleObjectSelection:=True;
  CBShowOutput:=TJSHTMLInputElement(GetHTMLElement('cbconsole'));
  CBShowOutput.onchange:=@DoShowOUtputChange;
  HookWasmConsole;
end;

var
  Application : TDemoApplication;

begin
  Application:=TDemoApplication.Create(nil);
  Application.Initialize;
  Application.Run;
end.
