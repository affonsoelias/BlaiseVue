unit wasm.pas2js.timer;

{$mode ObjFPC}

// Uncomment/Define this if you do not want logging code
{ $DEFINE NOLOGAPICALLS}

interface

uses
  sysutils, js, wasienv,
  {$ifdef JOB_WORKER}
  webworker,
  {$ELSE}
  web, weborworker,
  {$ENDIF}
  wasm.timer.shared;

Type
  TWasmPointer = longint;
  TTimerTickCallback = Function (aTimerID : TWasmTimerID; UserData : TWasmPointer) : Boolean;

  { TWasmTimerAPI }

  TWasmTimerAPI = class(TImportExtension)
  private
    function AllocateTimer(ainterval: longint; userdata: TWasmPointer): TWasmTimerID;
    procedure DeallocateTimer(timerid: TWasmTimerID);
    function PerformanceNow(aNow : TWasmPointer) : Longint;
    function GetLogApiCalls: Boolean;
    procedure SetLogApiCalls(AValue: Boolean);
  Protected
    Procedure LogCall(const Msg : String);
    Procedure LogCall(Const Fmt : String; const Args : Array of const);
  Public
    function ImportName: String; override;
    procedure FillImportObject(aObject: TJSObject); override;
    property LogAPICalls : Boolean Read GetLogApiCalls Write SetLogApiCalls;
  end;


implementation


{ TWasmTimerAPI }

procedure TWasmTimerAPI.LogCall(const Msg: String);
begin
{$IFNDEF NOLOGAPICALLS}
  DoLog(Msg);
{$ENDIF}
end;

procedure TWasmTimerAPI.LogCall(const Fmt: String; const Args: array of const);
begin
{$IFNDEF NOLOGAPICALLS}
  if LogAPI then
    DoLog(Fmt,Args);
{$ENDIF}
end;


function TWasmTimerAPI.ImportName: String;
begin
  Result:=TimerExportName;
end;

procedure TWasmTimerAPI.FillImportObject(aObject: TJSObject);
begin
  aObject[TimerFN_Allocate]:=@AllocateTimer;
  aObject[TimerFN_DeAllocate]:=@DeAllocateTimer;
  aObject[TimerFN_Performance_Now]:=@PerformanceNow;
end;


function TWasmTimerAPI.AllocateTimer(ainterval: longint; userdata: TWasmPointer): TWasmTimerID;

var
  aTimerID : TWasmTimerID;
  CallBack:jsvalue;


  Procedure HandleTimer;

  var
    Continue : boolean;

  begin
    // The instance/timer could have disappeared
    Callback:=InstanceExports['__wasm_timer_tick'];
    Continue:=Assigned(Callback);
    if Continue then
      Continue:=TTimerTickCallback(CallBack)(aTimerID,userData)
    else
      Console.Error('No more tick callback !');
    if not Continue then
      begin
      {$IFNDEF NOLOGAPICALLS}
      If LogAPICalls then
        LogCall('TimerTick(%d), return value false, deactivate',[aTimerID]);
      {$ENDIF}
      DeAllocateTimer(aTimerID);
      end;
  end;

begin
  {$IFNDEF NOLOGAPICALLS}
  If LogAPICalls then
    LogCall('AllocateTimer(%d,[%x])',[aInterval,UserData]);
  {$ENDIF}
  Callback:=InstanceExports['__wasm_timer_tick'];
  if Not Assigned(Callback) then
    Exit(0);
  {$IFDEF JOB_WORKER}
  aTimerID:=self_.setInterval(@HandleTimer,aInterval);
  {$ELSE}
  aTimerID:=Window.setInterval(@HandleTimer,aInterval);
  {$ENDIF}
  Result:=aTimerID;
  {$IFNDEF NOLOGAPICALLS}
  If LogAPICalls then
    LogCall('AllocateTimer(%d,[%x] => %d)',[aInterval,UserData,Result]);
  {$ENDIF}
end;

procedure TWasmTimerAPI.DeallocateTimer(timerid: TWasmTimerID);
begin
  {$IFNDEF NOLOGAPICALLS}
  If LogAPICalls then
    LogCall('DeAllocateTimer(%d)',[TimerID]);
  {$ENDIF}
  {$IFDEF JOB_WORKER}
  self_.clearInterval(TimerID);
  {$else}
  window.clearInterval(TimerID);
  {$endif}
end;

function TWasmTimerAPI.PerformanceNow(aNow: TWasmPointer): Longint;

begin
  if assigned(self_.Performance) then
    begin
    env.SetMemInfoFloat64(aNow,self_.Performance.Now);
    Result:=ETIMER_SUCCESS;
    end
  else
    Result:=ETIMER_NOPERFORMANCE;

end;

function TWasmTimerAPI.GetLogApiCalls: Boolean;
begin
  Result:=LogAPI;
end;

procedure TWasmTimerAPI.SetLogApiCalls(AValue: Boolean);
begin
  LogAPI:=aValue;
end;


end.

