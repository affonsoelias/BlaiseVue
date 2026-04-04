program js_leaflet;

{$mode objfpc}

uses
  BrowserConsole, BrowserApp, WASIHostApp, JOB_Browser,JS,
  Classes, SysUtils, Web, wasitypes, wasizenfs, libzenfs, libzenfsdom,wasienv;

type

 { Tjs_leaflet }

 Tjs_leaflet
 =
  class(TWASIHostApplication)
  protected
    FS :TWASIZenFS;
    procedure RunWasm ; async;
    procedure DoRun; override;
  private
    ob: TJSObjectBridge;
    sd: TWebAssemblyStartDescriptor;
    function wasmBeforeStart(_Sender: TObject; _Descriptor: TWebAssemblyStartDescriptor): Boolean;
    procedure wasmWrite(Sender: TObject; const aOutput: String);
  public
    constructor Create(aOwner : TComponent); override;
  end;

var
  Application : Tjs_leaflet;

  constructor Tjs_leaflet.Create(aOwner: TComponent);
  begin
       inherited Create(aOwner);
       ob:= TJSObjectBridge.Create( WasiEnvironment);
       RunEntryFunction:='_initialize';

       WasiEnvironment.OnStdErrorWrite :=@wasmWrite;
       WasiEnvironment.OnStdOutputWrite:=@wasmWrite;
       //WasiEnvironment.LogAPI:=True;
       //Writeln('Enabling logging');
  end;

function Tjs_leaflet.wasmBeforeStart( _Sender: TObject; _Descriptor: TWebAssemblyStartDescriptor): Boolean;
begin
     //WriteLn(ClassName+'.wasmBeforeStart');

     sd:= _Descriptor;

     ob.InstanceExports:=_Descriptor.Exported;
     Result:=true;
end;

procedure Tjs_leaflet.DoRun;
begin
     RunWasm;
end;

procedure Tjs_leaflet.wasmWrite(Sender: TObject; const aOutput: String);
begin
     Writeln( aOutput);
end;

procedure Tjs_leaflet.RunWasm;
begin
     // Writeln('Enabling logging');
     // WasiEnvironment.LogAPI:=True;
     FS:=TWASIZenFS.Create;
     WasiEnvironment.FS:=FS;
     StartWebAssembly('wasm_leaflet.wasm',true,@wasmBeforeStart);
end;

begin
     //ConsoleStyle:=DefaultConsoleStyle;
     ConsoleStyle:=DefaultCRTConsoleStyle;
     HookConsole;
     Application:=Tjs_leaflet.Create(nil);
     Application.Initialize;
     Application.Run;
end.
