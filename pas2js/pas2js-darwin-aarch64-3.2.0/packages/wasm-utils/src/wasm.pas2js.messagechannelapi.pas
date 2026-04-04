{
    This file is part of the Free Component Library

    Webassembly message channel API - WASM import API
    Copyright (c) 2024 by Michael Van Canneyt michael@freepascal.org

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
unit wasm.pas2js.messagechannelapi;

interface

uses js, sysutils, wasienv, wasm.messagechannel.shared, weborworker, contnrs;

Type

  { TWasmChannel }
  TWasmOnChannelMessage = procedure(aSender : TObject; aID : TWasmMessageChannelID; aMsg : JSValue) of object;

  TWasmChannel = class(TObject)
  private
    FChannelType: TWasmChannelType;
    FID: TWasmMessageChannelID;
    FOnMessage: TWasmOnChannelMessage;
    procedure SetOnMessage(AValue: TWasmOnChannelMessage);
  protected
    procedure HandleMessage(aEvent: TJSEvent);
    Procedure StartListening; virtual; abstract;
  public
    constructor create(aID : TWasmMessageChannelID; aType : TWasmChannelType);
    Procedure SendMessage(Msg : JSValue); virtual; abstract;
    property OnMessage : TWasmOnChannelMessage Read FOnMessage Write SetOnMessage;
    property ChannelType : TWasmChannelType Read FChannelType;
    property ID : TWasmMessageChannelID read FID;
  end;

  { TWasmBroadCastChannel }

  TWasmBroadCastChannel = class(TWasmChannel)
  Private
    FChannel : TJSBroadcastChannel;
  protected
    procedure StartListening; override;
  Public
    constructor create(aID : TWasmMessageChannelID; const aName : string); reintroduce;
    destructor destroy; override;
    Procedure SendMessage(Msg : JSValue); override;
    Property Channel : TJSBroadcastChannel Read FChannel;
  end;

//  TWasmWorkerChannel = class();

  { TMessageChannelAPI }

  TMessageChannelAPI = class(TImportExtension)
  private
    FChannels:TFPObjectHashTable;
  protected
    // internal methods
    procedure DoOnChannelMessageUTF8(aSender: TObject; aID: TWasmMessageChannelID; aMsg: JSValue); virtual;
    procedure DoOnChannelMessageUTF16(aSender: TObject; aID: TWasmMessageChannelID; aMsg: JSValue);virtual;
    function FindChannel(aID: TWasmMessageChannelID): TWasmChannel;
    procedure AddChannel(aChannel : TWasmChannel);
    procedure RemoveChannel(aChannel : TWasmChannel);
    function CreateChannel(aType : TWasmChannelType; aID: TWasmMessageChannelID; aName : String) : TWasmChannel; virtual;
    // callable methods
    function SendMessageUtf8(aID: TWasmMessageChannelID; aData: TWasmPointer; aDataLen: Longint; aDeserialize: Longint): TWasmMessageChannelResult;
    function SendMessageUtf16(aID: TWasmMessageChannelID; aData: TWasmPointer; aDataCharLen: Longint; aDeserialize: Longint): TWasmMessageChannelResult;
    function AllocateMessageChannel(aID: TWasmMessageChannelID; aType: Longint; aName: TWasmPointer; aNameLen: Longint): TWasmMessageChannelResult;
    function DeAllocateMessageChannel(aID: TWasmMessageChannelID): TWasmMessageChannelResult;
    function ListenToMessages(aID: TWasmMessageChannelID; aUseUTF16 : Integer): TWasmMessageChannelResult;
  public
    constructor Create(aEnv: TPas2JSWASIEnvironment); override;
    procedure FillImportObject(aObject: TJSObject); override;
    function ImportName: String; override;
  end;

implementation

{ TWasmChannel }

procedure TWasmChannel.SetOnMessage(AValue: TWasmOnChannelMessage);
begin
  if FOnMessage=AValue then Exit;
  FOnMessage:=AValue;
  if Assigned(FOnMessage) then
    StartListening;
end;


constructor TWasmChannel.create(aID : TWasmMessageChannelID;aType: TWasmChannelType);
begin
  FID:=aID;
  FChannelType:=aType;
end;


procedure TWasmChannel.HandleMessage(aEvent : TJSEvent);

var
  lEvent : TJSMessageEvent absolute aEvent;

begin
  if assigned(OnMessage) then
    OnMessage(Self,ID,lEvent.Data);
end;

{ TWasmBroadCastChannel }

procedure TWasmBroadCastChannel.StartListening;
begin
  FChannel.addEventListener('message',@HandleMessage);
end;

constructor TWasmBroadCastChannel.create(aID : TWasmMessageChannelID; const aName: string);
begin
  inherited create(aID,ctBroadcast);
  FChannel:=TJSBroadcastChannel.New(aName);
end;

destructor TWasmBroadCastChannel.destroy;
begin
  FChannel.Close;
  FChannel:=Nil;
  inherited destroy;
end;

procedure TWasmBroadCastChannel.SendMessage(Msg: JSValue);
begin
  FChannel.postMessage(Msg);
end;

procedure TMessageChannelAPI.DoOnChannelMessageUTF8(aSender: TObject; aID: TWasmMessageChannelID; aMsg: JSValue);
Type
  TMsgProc = procedure(aID : TWasmMessageChannelID; aMsg : TWasmPointer; aMsgLen : Longint);

var
  lMsgProcExp : JSValue;
  lMsgProc: TMsgProc absolute lMsgProcExp;
  lMem : TWasmPointer;
  lLen : Longint;
  S : string;

begin
  lMsgProcExp:=InstanceExports[MsgChannelFN_OnMessageUTF8];
  if not Assigned(lMsgProcExp) then
    Exit;
  S:=TJSJSON.stringify(aMsg);
  lLen:=env.GetUTF8ByteLength(S);
  lMem:=InstanceExports.AllocMem(lLen);
  try
    Env.SetUTF8StringInMem(lMem,lLen,S);
    lMsgproc(aID,lMem,lLen);
  finally
    InstanceExports.freeMem(lMem);
  end;
end;

procedure TMessageChannelAPI.DoOnChannelMessageUTF16(aSender: TObject; aID: TWasmMessageChannelID; aMsg: JSValue);
Type
  TMsgProc = procedure(aID : TWasmMessageChannelID; aMsg : TWasmPointer; aMsgLen : Longint);

var
  lMsgProcExp : JSValue;
  lMsgProc: TMsgProc absolute lMsgProcExp;
  lMem : TWasmPointer;
  lLen : Longint;
  sMsg : string absolute aMsg; // Avoid a typecast
  S : string;

begin
  lMsgProcExp:=InstanceExports[MsgChannelFN_OnMessageUtf16];
  if not Assigned(lMsgProcExp) then
    Exit;
  if isString(aMsg) then
    s:=sMsg
  else
    S:=TJSJSON.stringify(aMsg);
  lLen:=Length(S);
  lMem:=InstanceExports.AllocMem(lLen*2);
  try
    Env.SetUTF16StringInMem(lMem,S);
    lMsgproc(aID,lMem,lLen);
  finally
    InstanceExports.freeMem(lMem);
  end;
end;

{ TMessageChannelAPI }
function TMessageChannelAPI.FindChannel(aID : TWasmMessageChannelID) : TWasmChannel;

begin
  Result:=TWasmChannel(FChannels.Items[IntToStr(aID)]);
end;

procedure TMessageChannelAPI.AddChannel(aChannel: TWasmChannel);
begin
  FChannels.Add(IntToStr(aChannel.ID),aChannel);
end;

procedure TMessageChannelAPI.RemoveChannel(aChannel: TWasmChannel);
begin
  FChannels.Delete(IntToStr(aChannel.ID));
end;

function TMessageChannelAPI.CreateChannel(aType: TWasmChannelType; aID: TWasmMessageChannelID; aName: String): TWasmChannel;
begin
  if aType=ctBroadcast then
    Result:=TWasmBroadCastChannel.Create(aID,aName)
  else
    Result:=Nil;
end;

function TMessageChannelAPI.DeAllocateMessageChannel(aID : TWasmMessageChannelID) : TWasmMessageChannelResult;
var
  lChannel : TWasmChannel;
begin
  lChannel:=FindChannel(aID);
  if (lChannel=Nil) then
    exit(WASMMSGCHANNEL_RESULT_INVALIDCHANNEL);
  RemoveChannel(lChannel);
  Result:=WASMMSGCHANNEL_RESULT_SUCCESS;
end;

function TMessageChannelAPI.ListenToMessages(aID: TWasmMessageChannelID;  aUseUTF16 : Integer): TWasmMessageChannelResult;
var
  lChannel : TWasmChannel;
begin
  lChannel:=FindChannel(aID);
  if (lChannel=Nil) then
    exit(WASMMSGCHANNEL_RESULT_INVALIDCHANNEL);
  if aUseUTF16=0 then
    lChannel.OnMessage:=@DoOnChannelMessageUTF8
  else
    lChannel.OnMessage:=@DoOnChannelMessageUTF16;
end;

constructor TMessageChannelAPI.Create(aEnv: TPas2JSWASIEnvironment);
begin
  FChannels:=TFPObjectHashTable.Create(True);
  inherited Create(aEnv);
end;

function TMessageChannelAPI.AllocateMessageChannel(aID : TWasmMessageChannelID; aType : Longint; aName : TWasmPointer; aNameLen : Longint) : TWasmMessageChannelResult;
var
  lType : TWasmChannelType;
  lName : String;
  lChannel : TWasmChannel;
begin
  if (aType<0) or (aType>Ord(High(TWasmChannelType))) then
    Exit(WASMMSGCHANNEL_RESULT_INVALIDTYPE);
  lType:=TWasmChannelType(aType);
  lChannel:=FindChannel(aID);
  if (lChannel<>Nil) then
    exit(WASMMSGCHANNEL_RESULT_INVALIDCHANNEL);
  if (aNameLen<0) then
    exit(WASMMSGCHANNEL_RESULT_INVALIDDATALEN);
  lName:=Env.GetUTF8StringFromMem(aName,aNameLen);
  lChannel:=CreateChannel(lType,aID,lName);
  if (lChannel=Nil) then
    exit(WASMMSGCHANNEL_RESULT_UNSUPPORTEDTYPE);
  AddChannel(lChannel);
  Result:=WASMMSGCHANNEL_RESULT_SUCCESS;
end;

function TMessageChannelAPI.SendMessageUtf8(aID: TWasmMessageChannelID; aData: TWasmPointer; aDataLen: Longint;
  aDeserialize: Longint): TWasmMessageChannelResult;
var
  lStringData : String;
  lData : JSValue;
  lChannel : TWasmChannel;
begin
  lChannel:=FindChannel(aID);
  if (lChannel=Nil) then
    exit(WASMMSGCHANNEL_RESULT_INVALIDCHANNEL);
  if (aDataLen<0) then
    exit(WASMMSGCHANNEL_RESULT_INVALIDDATALEN);
  lStringData:=Env.GetUTF8StringFromMem(aData,aDataLen);
  if aDeserialize=0 then
    lData:=lStringData
  else
    lData:=TJSJSON.parse(LStringData);
  try
    lChannel.SendMessage(lData);
  except
    console.error(Format('Error sending message data to channel %d: %s',[aID,lStringData]));
  end;
  Result:=WASMMSGCHANNEL_RESULT_SUCCESS;
end;

function TMessageChannelAPI.SendMessageUtf16(aID: TWasmMessageChannelID; aData: TWasmPointer; aDataCharLen: Longint;
  aDeserialize: Longint): TWasmMessageChannelResult;
var
  lStringData : String;
  lData : JSValue;
  lChannel : TWasmChannel;
begin
  lChannel:=FindChannel(aID);
  if (lChannel=Nil) then
    exit(WASMMSGCHANNEL_RESULT_INVALIDCHANNEL);
  if (aDataCharLen<0) then
    exit(WASMMSGCHANNEL_RESULT_INVALIDDATALEN);
  lStringData:=Env.GetUTF16StringFromMem(aData,aDataCharLen);
  if aDeserialize=0 then
    lData:=lStringData
  else
    lData:=TJSJSON.parse(LStringData);
  try
    lChannel.SendMessage(lData);
  except
    console.error(Format('Error sending message data to channel %d: %s',[aID,lStringData]));
  end;
  Result:=WASMMSGCHANNEL_RESULT_SUCCESS;
end;


procedure TMessageChannelAPI.FillImportObject(aObject: TJSObject);
begin
  aObject[MsgChannelFN_Allocate]:=@AllocateMessageChannel;
  aObject[MsgChannelFN_DeAllocate]:=@DeAllocateMessageChannel;
  aObject[MsgChannelFN_SendUtf8]:=@SendMessageUtf8;
  aObject[MsgChannelFN_SendUtf16]:=@SendMessageUtf16;
  aObject[MsgChannelFN_Listen]:=@ListenToMessages;
end;

function TMessageChannelAPI.ImportName: String;
begin
  Result:=MsgChannelExportName;
end;

end.
