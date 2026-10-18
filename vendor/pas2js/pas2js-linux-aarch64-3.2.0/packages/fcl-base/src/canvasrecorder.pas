{
    This file is part of the Free Pascal run time library.
    Copyright (c) 2025 by the Free Pascal development team

    Class to record canvas commands and replay them.
    
    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
{$IFNDEF FPC_DOTTEDUNITS} 
unit canvasrecorder;
{$ENDIF}

{$mode ObjFPC}
{$modeswitch externalclass}

interface

uses
{$IFDEF FPC_DOTTEDUNITS}
  System.SysUtils, System.Types, JSApi.JS, BrowserApi.WebOrWorker;
{$ELSE}  
  SysUtils, JS, Types, WebOrWorker;
{$ENDIF}

Type
  ECanvasRecorder = class(Exception);

  TCommandObject = class external name 'Object' (TJSObject)
    typ : string;
    prop : string;
    timestamp : TJSDOMHighResTimeStamp;
  end;
  TCommandObjectDynArray = array of TCommandObject;

  TCallObject = class external name 'Object' (TCommandObject)
    args : TJSValueDynArray;
  end;

  { TCallObjectHelper }

  TCallObjectHelper = class helper for TCallObject
    class function create(aProp : String; aArgs : TJSValueDynArray) : TCallObject; static;
    function tostring : string;
  end;
  TSetObject = class external name 'Object' (TCommandObject)
    value : JSValue;
  end;

  { TSetObjectHelper }

  TSetObjectHelper = class helper for TSetObject
    class function create(aProp : String; aValue : JSValue) : TSetObject; static;
    function tostring : string;
  end;

  { TCanvasRecorder }
  TCanvasRecorderLogEvent = procedure(const aMsg : string) of object;

  TCanvasRecorder = Class(TObject)
  Type
    TReplay = record
      FromIndex,ToIndex : Integer;
    end;

  Private
    FOnLog: TCanvasRecorderLogEvent;
    FCommands: TCommandObjectDynArray;
    FRecording :  Boolean;
    FCurrentCommand,
    FMaxCommand : Integer;
    FSourceContext,
    FProxyContext,
    FTargetContext :TJSBaseCanvasRenderingContext2D;
    FIntervalID : NativeInt;
    function GetCommand(aIndex : Integer): TCommandObject;
    function GetCommandCount: Integer;
    function GetDuration: TJSDOMHighResTimeStamp;
    procedure logMessage(aMessage: String);
  protected
    function CreateRecordingProxy(aSourceContext: TJSBaseCanvasRenderingContext2D): TJSBaseCanvasRenderingContext2D; virtual;
  Public
    constructor Create;
    // Set the canvas context to render. Returns a proxified version of the canvas, which must be used as canvas.
    function CaptureCanvas(aSource : TJSBaseCanvasRenderingContext2D) : TJSBaseCanvasRenderingContext2D;
    // Set the context on which to replay the commands.
    Procedure SetReplayContext(aTarget : TJSBaseCanvasRenderingContext2D);
    // Start recording. Resets the command array
    procedure StartRecording;
    // Stop recording. Resets the command array
    procedure StopRecording;
    // Replay commands from index aFrom to aTo, inclusive.
    // If aInterval is given, it is an interval in milliseconds between commands.
    procedure ReplayRange(aFrom, aTo: Integer; aInterval: Integer = 0);
    // Replay all commands. If aInterval is given, it is an interval in milliseconds between commands.
    procedure Replay(aInterval : Integer = 0);
    // Replay a single command, the command at CurrentCommandIndex
    procedure ReplayCommand;
    // Cancel replay: resets the start/stop/interval settings
    procedure CancelReplay;
    // Convert a relative DOMHighResTimeStamp to the index in the array of commands.
    function TimeToIndex(aRelativeTime: TJSDOMHighResTimeStamp) : Integer;
    // Are there still commands to be replayed ?
    function HaveReplayCommand : Boolean;
    // is a replay in progress ?
    function ReplayInProgress : Boolean;
    // Return the array of commands, resets the commands
    function ExtractCommands : TCommandObjectDynArray;
    // Number of recorded commands
    property CommandCount : Integer Read GetCommandCount;
    // Current command index during replay.
    property CurrentCommandIndex : Integer Read FCurrentCommand;
    // Indexed access to all commands.
    property Commands[aIndex : Integer] : TCommandObject read GetCommand;
    // Total duration of the commands.
    property Duration : TJSDOMHighResTimeStamp read GetDuration;
    // Logs the commands that are being replayed.
    property OnLog : TCanvasRecorderLogEvent read FOnLog Write FOnLog;
  end;

implementation

{ TCallObjectHelper }

class function TCallObjectHelper.create(aProp: String; aArgs: TJSValueDynArray): TCallObject;
begin
  Result:=TCallObject.New;
  Result.typ:='call';
  Result.timestamp:=self_.Performance.now;
  Result.prop:=aProp;
  Result.args:=aArgs;
end;

function TCallObjectHelper.tostring: string;
begin
  Result:='Call '+Prop+'('+TJSJSON.stringify(args)+')';

end;

{ TSetObjectHelper }

class function TSetObjectHelper.create(aProp: String; aValue: JSValue): TSetObject;
begin
  Result:=TSetObject.New;
  Result.typ:='set';
  Result.timestamp:=self_.Performance.now;
  Result.prop:=aProp;
  Result.value:=aValue;
end;

function TSetObjectHelper.tostring: string;
begin
  Result:='Set '+prop+' = ' +TJSJSON.stringify(value);
end;

constructor TCanvasRecorder.Create;
begin
  FCommands:=[];
  FCurrentCommand:=0;
end;

function TCanvasRecorder.CaptureCanvas(aSource : TJSBaseCanvasRenderingContext2D) : TJSBaseCanvasRenderingContext2D;

begin
  FSourceContext:=aSource;
  FProxyContext:=CreateRecordingProxy(FSourceContext);
  FCommands:=[];
  FCurrentCommand:=0;
  Result:=FProxyContext;
end;

procedure TCanvasRecorder.StartRecording;
begin
  if FProxyContext=Nil then
    raise ECanvasRecorder.Create('No canvas to record');
  FRecording:=True;
end;

procedure TCanvasRecorder.StopRecording;
begin
  FRecording:=False;
  FMaxCommand:=CommandCount-1;
end;

function TCanvasRecorder.CreateRecordingProxy(aSourceContext: TJSBaseCanvasRenderingContext2D) : TJSBaseCanvasRenderingContext2D;

  function handleGet (aTarget : TJSObject; aProperty: string) : JSValue;
   var
     aValue : JSValue;
     aFunc : TJSFunction absolute aValue;

   begin
     aValue:=aTarget[aproperty];
     if (jsTypeOf(aValue)<>'function') then
       exit(aValue);
     // Construct wrapper
      Result:=Function () : JSValue
          var
            args : TJSValueDynArray;
            rec : TJSObject;
          begin
          asm
          args=arguments;
          end;
          if (FRecording) then
            begin
            rec:=TCallObject.Create(aProperty,args);
            TJSArray(FCommands).push(rec);
            end;
          Result:=aFunc.apply(aTarget,args);
          end;
    end;

    function handleSet (aTarget : TJSObject; aProperty : string; aValue : JSValue) : JSValue;
    var
      rec : TJSObject;
    begin
      aTarget[aProperty]:=aValue;
      if (FRecording) then
        begin
        rec:=TSetObject.Create(aProperty,aValue);
        TJSArray(FCommands).push(rec);
        end;
      Result:=True;
    end;

var
  aHandler: TJSObject;

begin
  aHandler:=TJSObject.New;
  aHandler['get']:=@handleGet;
  aHandler['set']:=@handleSet;
  Result:=TJSBaseCanvasRenderingContext2D(TJSProxy.New(aSourceContext,aHandler));
end;

procedure TCanvasRecorder.SetReplayContext(aTarget: TJSBaseCanvasRenderingContext2D);

begin
  FTargetContext:=aTarget;
end;

function TCanvasRecorder.TimeToIndex(aRelativeTime: TJSDOMHighResTimeStamp): Integer;

var
  lMin,lMax : integer;

begin
  Result:=-1;
  lMax:=CommandCount;
  if lMax=0 then exit;
  aRelativeTime:=aRelativeTime+FCommands[0].timestamp;
  lMin:=0;
  Dec(lMax);
  While lMin<lMax do
    begin
    Result:=Trunc((lMin+lMax) div 2);
    if (aRelativeTime<FCommands[Result].Timestamp) then
      lMax:=Result-1
    else if (aRelativeTime>FCommands[Result].Timestamp) then
      lMin:=Result+1
    end;
  if FCommands[Result].Timestamp>aRelativeTime then
    Result:=-1;
end;

function TCanvasRecorder.HaveReplayCommand: Boolean;
begin
  Result:=FCurrentCommand<=FMaxCommand
end;

function TCanvasRecorder.ReplayInProgress: Boolean;
begin
  Result:=(FIntervalID>0);
end;

function TCanvasRecorder.ExtractCommands: TCommandObjectDynArray;
begin
  Result:=FCommands;
  FCommands:=Nil;
end;

procedure TCanvasRecorder.logMessage(aMessage: String);

begin
  if Assigned(FOnLog) then
    FOnLog(aMessage);
end;

function TCanvasRecorder.GetCommandCount: Integer;
begin
  Result:=Length(FCommands);
end;

function TCanvasRecorder.GetCommand(aIndex : Integer): TCommandObject;
begin
  if (aIndex>=0) and (aIndex<Length(FCommands)) then
    Result:=FCommands[aIndex]
  else
    Result:=Nil;
end;

function TCanvasRecorder.GetDuration: TJSDOMHighResTimeStamp;
var
  lCount : integer;
begin
  Result:=0;
  lCount:=CommandCount;
  if lCount=0 then
    exit;
  Result:=FCommands[lCount-1].timestamp-FCommands[0].timestamp;
end;

procedure TCanvasRecorder.Replay(aInterval: Integer);

begin
  ReplayRange(0,CommandCount-1,aInterval);
end;

procedure TCanvasRecorder.ReplayRange(aFrom,aTo: Integer; aInterval : Integer);

  procedure DoStep;
  begin
    if HaveReplayCommand then
      ReplayCommand
    else
      CancelReplay;
  end;

begin
  if FRecording then
    exit;
  if ReplayInProgress then
    raise ECanvasRecorder.Create('Replay is already in progress');
  FCurrentCommand:=aFrom;
  FMaxCommand:=aTo;
  if aInterval=0 then
    begin
    while HaveReplayCommand do
       ReplayCommand;
    end
  else
    FIntervalID:=self_.setInterval(@DoStep,aInterval);
end;

procedure TCanvasRecorder.ReplayCommand;
var
  lStep : TCommandObject;
  lCall : TCallObject absolute lStep;
  lSet : TSetObject absolute lStep;
begin
  if FRecording then
    exit;
  if (FCurrentCommand>=CommandCount) then
    exit;
  lStep:=FCommands[FCurrentCommand];
  inc(FCurrentCommand);
  if (lStep.typ='call') then
    begin
    try
       TJSFunction(FtargetContext[lStep.prop]).apply(FtargetContext,lCall.args);
       logMessage('Call['+IntTostr(FCurrentCommand)+']: '+lCall.ToString);
    except
      // cannot be pascal error
      on E : TJSError do
        logMessage('Error calling '+lStep.prop+': '+E.Message);
    end;
    end
  else if (lStep.typ='set') then
    begin
    try
      FtargetContext[lStep.prop]:=lSet.value;
      logMessage('Set['+IntTostr(FCurrentCommand)+']: '+lSet.ToString);
    except
      on E : TJSError do
        logMessage('Error calling '+lStep.prop+': '+E.Message);
    end;
    end;
end;

procedure TCanvasRecorder.CancelReplay;
begin
  FCurrentCommand:=0;
  FMaxCommand:=CommandCount-1;
  if FIntervalID=0 then
    exit;
  self_.clearInterval(FIntervalID);
  FIntervalID:=0;
end;

end.

