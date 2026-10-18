{
    This file is part of the Free Component Library

    Webassembly Websocket API - Provide the API to a webassembly module.
    Copyright (c) 2024 by Michael Van Canneyt michael@freepascal.org

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

unit wasm.pas2js.websocketapi;

{$mode ObjFPC}

{ $DEFINE NOLOGAPICALLS}

interface

uses
  SysUtils, js, wasienv, web,weborworker, wasm.websocket.shared;

Type
  TWasmBaseWebSocketAPI = Class;

  { TWasmWebsocket }

  TWasmWebsocket = class
  private
    FAPI : TWasmBaseWebSocketAPI;
    FWebsocketID : TWasmWebsocketID;
    FWS : TJSWebSocket;
    FUserData: TWasmPointer;
  Public
    Constructor Create(aAPI : TWasmBaseWebSocketAPI; aID : TWasmWebsocketID; aUserData : TWasmPointer;const aURL : String; const aProtocols : String = ''); virtual;
    destructor Destroy; override;
    Procedure Close(aCode : Integer; aReason : String);
    procedure SendText(aData: String); virtual;
    procedure SendBinary(aData: TJSArrayBuffer); virtual;
    procedure HandleClose(Event: TJSEvent); virtual;
    procedure HandleError(Event: TJSEvent); virtual;
    procedure HandleMessage(Event: TJSEvent); virtual;
    procedure HandleOpen(Event: TJSEvent); virtual;
    function ToString : String; override;
    Property UserData : TWasmPointer Read FUserData;
    Property WebsocketID : TWasmWebSocketID Read FWebSocketID;
  end;
  TWasmWebsocketClass = Class of TWasmWebsocket;

  { TWasmBaseWebSocketAPI }
  TWasmWebSocketErrorHandler = Function (aWebsocketID : TWasmWebSocketID; aUserData : TWasmPointer) : TWebsocketCallBackResult;
  TWasmWebSocketMessageHandler = Function (aWebsocketID : TWasmWebSocketID; aUserData : TWasmPointer; aMessageType : TWasmWebSocketMessageType; aMessage : TWasmPointer; aMessageLen : Integer) : TWebsocketCallBackResult;
  TWasmWebSocketOpenHandler = Function (aWebsocketID : TWasmWebSocketID; aUserData : TWasmPointer) : TWebsocketCallBackResult;
  TWasmWebSocketCloseHandler = Function (aWebsocketID : TWasmWebSocketID; aUserData : TWasmPointer; aCode: Longint; aReason : PByte; aReasonLen : Longint; aClean : Longint) : TWebsocketCallBackResult;
  TWasmWebsocketAllocateBuffer = Function (aWebsocketID : TWasmWebSocketID; aUserData : TWasmPointer; aBufferLen : Longint) : TWasmPointer;


  TWasmBaseWebSocketAPI = class(TImportExtension)
  private
    FNextID : TWasmWebsocketID;
    FSockets : TJSObject;
    FEncoder : TJSTextEncoder;
    FDecoder : TJSTextDecoder;
    function CheckCallbackRes(Res: TWebsocketCallBackResult; const aOperation: string): Boolean;
    function GetLogAPICalls: Boolean;
    procedure HandleSendMessage(aSocket: TWasmWebSocket; aMessage: TJSUInt8Array; aType: TWasmWebSocketMessageType);
    procedure SetLogAPICalls(AValue: Boolean);
  Protected
    Procedure LogCall(const Msg : String);
    Procedure LogCall(Const Fmt : String; const Args : Array of const);
    Function GetNextID : TWasmWebsocketID;
    Function GetWebsocket(aID : TWasmWebSocketID) : TWasmWebSocket;
    function GetWebSocketClass: TWasmWebsocketClass; virtual;
    function FreeWebSocket(aID: TWasmWebSocketID) : boolean;
    Procedure HandleOpen(aSocket : TWasmWebSocket);
    Procedure HandleClose(aSocket : TWasmWebSocket; aCode : Integer; aReason : String; aWasClean : Boolean);
    Procedure HandleError(aSocket : TWasmWebSocket);
    Procedure HandleBinaryMessage(aSocket : TWasmWebSocket; aMessage : TJSArrayBuffer);
    Procedure HandleStringMessage(aSocket : TWasmWebSocket; aMessage : String);
    function WebsocketAllocate(aURL : PByte; aUrlLen : Longint; aProtocols : PByte; aProtocolLen : Longint; aUserData : TWasmPointer; aWebsocketID : TWasmWebSocketID) : TWasmWebsocketResult; virtual; abstract;
    function WebsocketDeAllocate(aWebsocketID : TWasmWebSocketID) : TWasmWebsocketResult; virtual; abstract;
    function WebsocketClose(aWebsocketID : TWasmWebSocketID; aCode : Longint; aReason : PByte; aReasonLen : Longint) : TWasmWebsocketResult; virtual; abstract;
    function WebsocketSend(aWebsocketID : TWasmWebSocketID; aData : PByte; aDataLen : Longint; aType : Longint) : TWasmWebsocketResult; virtual; abstract;
    property Encoder : TJSTextEncoder Read FEncoder;
    property Decoder : TJSTextDecoder Read FDecoder;
  public
    constructor Create(aEnv: TPas2JSWASIEnvironment); override;
    procedure FillImportObject(aObject: TJSObject); override;
    function AllocateBuffer(aSocket: TWasmWebSocket; aLen: Longint): TWasmPointer;
    function ImportName: String; override;
    property LogAPICalls : Boolean Read GetLogAPICalls Write SetLogAPICalls;
  end;

  { TWasmWebSocketAPI }
  // This API handles everything locally.
  // When using this, the javascript must be able to handle the main event loop,
  // Meaning that the websockets
  TWasmWebSocketAPI = class(TWasmBaseWebSocketAPI)
  private
  Protected
    function CreateWebSocket(aID: Integer; aUserData: TWasmPointer; aUrl, aProtocols: string): TWasmWebSocket;
    function WebsocketAllocate(aURL : PByte; aUrlLen : Longint; aProtocols : PByte; aProtocolLen : Longint; aUserData : TWasmPointer; aWebsocketID : TWasmWebSocketID) : TWasmWebsocketResult; override;
    function WebsocketDeAllocate(aWebsocketID : TWasmWebSocketID) : TWasmWebsocketResult; override;
    function WebsocketClose(aWebsocketID : TWasmWebSocketID; aCode : Longint; aReason : PByte; aReasonLen : Longint) : TWasmWebsocketResult; override;
    function WebsocketSend(aWebsocketID : TWasmWebSocketID; aData : PByte; aDataLen : Longint; aType : Longint) : TWasmWebsocketResult; override;
  end;



implementation

{ ---------------------------------------------------------------------
  TWasmBaseWebSocketAPI
  ---------------------------------------------------------------------}

// Auxiliary calls

procedure TWasmBaseWebSocketAPI.LogCall(const Msg: String);
begin
  {$IFNDEF NOLOGAPICALLS}
  if LogAPI then
    DoLog('WebSocket: '+Msg);
  {$ENDIF}
end;


procedure TWasmBaseWebSocketAPI.LogCall(const Fmt: String; const Args: array of const);

begin
  {$IFNDEF NOLOGAPICALLS}
  If LogAPI then
    DoLog(Format(Fmt,Args));
  {$ENDIF}
end;


function TWasmBaseWebSocketAPI.GetNextID: TWasmWebsocketID;
begin
  Inc(FNextID);
  Result:=FNextID;
end;



function TWasmBaseWebSocketAPI.GetWebsocket(aID: TWasmWebSocketID): TWasmWebSocket;

var
  Value : JSValue;

begin
  Value:=FSockets[IntToStr(aID)];
  if isObject(Value) then
    Result:=TWasmWebSocket(Value)
  else
    Result:=Nil;
end;


function TWasmBaseWebSocketAPI.GetWebSocketClass: TWasmWebsocketClass;
begin
  Result:=TWasmWebsocket;
end;

function TWasmBaseWebSocketAPI.FreeWebSocket(aID: TWasmWebSocketID): boolean;

var
  lSocket : TWasmWebsocket;

begin
  lSocket:=GetWebsocket(aID);
  Result:=lSocket<>Nil;
  if Result then
    begin
    lSocket.Destroy;
    FSockets[IntToStr(aID)]:=undefined;
    end;
end;


function TWasmBaseWebSocketAPI.CheckCallbackRes(Res : TWebsocketCallBackResult; const aOperation : string) : Boolean;
begin
  Result:=(Res=WASMWS_CALLBACK_SUCCESS);
  if not Result then
    DoError('Error during %s call, exit status %d',[aOperation,Res]);
end;

function TWasmBaseWebSocketAPI.GetLogAPICalls: Boolean;
begin
  Result:=LogAPI;
end;


// Callbacks for TWasmWebSocket, calls exported routines from webassembly module.

function TWasmBaseWebSocketAPI.AllocateBuffer(aSocket: TWasmWebSocket; aLen : Longint) : TWasmPointer;

var
  aValue : JSValue;
  Callback : TWasmWebsocketAllocateBuffer absolute aValue;

begin
  aValue:=InstanceExports['__wasm_websocket_allocate_buffer'];
  if Assigned(CallBack) then
    With aSocket do
      Result:=CallBack(WebSocketID,UserData,aLen);
  if Result=0 then
    DoError('Socket %s: Failed to allocate buffer for ',[aSocket.ToString]);
end;


procedure TWasmBaseWebSocketAPI.HandleOpen(aSocket: TWasmWebSocket);

var
  value : JSValue;
  callback : TWasmWebSocketOpenHandler absolute Value;
  Res : TWebsocketCallBackResult;

begin
  value:=InstanceExports['__wasm_websocket_on_open'];
  if not Assigned(CallBack) then
    exit;
  With aSocket do
    begin
    Res:=(CallBack)(WebSocketID,UserData);
    CheckCallbackRes(Res,'open');
    end;
end;


procedure TWasmBaseWebSocketAPI.HandleClose(aSocket: TWasmWebSocket; aCode: Integer; aReason: String; aWasClean: Boolean);

var
  aValue : JSValue;
  Callback : TWasmWebSocketCloseHandler absolute aValue;
  StrBuf : TJSUint8Array;
  Buf : TWasmPointer;
  Res : TWebsocketCallBackResult;
  bufLen : Longint;

begin
  if aReason<>'' then
    begin
    StrBuf:=FEncoder.encode(aReason);
    if not Assigned(StrBuf) then
      begin
      Buf:=0;
      bufLen:=0;
      end
    else
      begin
      bufLen:=StrBuf.byteLength;
      Buf:=AllocateBuffer(aSocket,bufLen);
      if Buf=0 then
        begin
        DoError('Socket %d: Failed to allocate buffer for close reason: %s',[aSocket.WebsocketID,aReason]);
        exit;
        end;
      end;
    end
  else
    begin
    Buflen:=0;
    Buf:=0;
    end;
  aValue:=InstanceExports['__wasm_websocket_on_close'];
  if isFunction(aValue) then
    With aSocket do
      begin
      if BufLen<>0 then
        Env.SetUTF8StringInMem(Buf,Buflen,StrBuf);
      Res:=CallBack(WebSocketID,UserData,aCode,Buf,Buflen,Ord(aWasClean));
      CheckCallBackRes(Res,'close');
      end;
end;


procedure TWasmBaseWebSocketAPI.HandleError(aSocket: TWasmWebSocket);
var
  Callback : JSValue;

begin
  CallBack:=InstanceExports['__wasm_websocket_on_error'];
  if Assigned(CallBack) then
    With aSocket do
      TWasmWebSocketErrorHandler(CallBack)(WebSocketID,UserData);
end;


procedure TWasmBaseWebSocketAPI.HandleSendMessage(aSocket: TWasmWebSocket; aMessage: TJSUInt8Array; aType : TWasmWebSocketMessageType);

//begin
//  TWasmWebSocketMessageHandler = Function (aWebsocketID : TWasmWebSocketID; aUserData : Pointer; aMessageType : TWasmWebSocketMessageType; aMessage : Pointer; aMessageLen : Integer) : TWebsocketCallBackResult;

var
  Value: JSValue;
  CallBack : TWasmWebSocketMessageHandler absolute Value;
  lBuf : TWasmPointer;
  WasmMem: TJSUint8Array;
  lLen : Longint;
  Res : TWebsocketCallBackResult;

begin
  Value:=InstanceExports['__wasm_websocket_on_message'];
  if Not Assigned(Value) then
    begin
    DoError('Socket %s: Failed no export to handle message',[aSocket.ToString]);
    exit;
    end;
  lLen:=aMessage.byteLength;
  lBuf:=AllocateBuffer(aSocket,lLen);
  if Lbuf=0 then
    begin
    DoError('Socket %s: Failed to allocate buffer for message',[aSocket.ToString]);
    Exit;
    end;
  With aSocket do
    begin
    WasmMem:=TJSUint8Array.New(getModuleMemoryDataView.buffer,lBuf,lLen);
    WasmMem._set(aMessage);
    Res:=CallBack(WebSocketID,UserData,aType,lBuf,lLen);
    CheckCallbackRes(Res,'sendmessage');
    end;
end;

procedure TWasmBaseWebSocketAPI.SetLogAPICalls(AValue: Boolean);
begin
  LogAPI:=aValue;
end;


procedure TWasmBaseWebSocketAPI.HandleBinaryMessage(aSocket: TWasmWebSocket; aMessage: TJSArrayBuffer);

var
  lMessage : TJSUint8array;

begin
  lMessage:=TJSUint8array.New(aMessage);
  HandleSendMessage(aSocket,lMessage,WASMWS_MESSAGE_TYPE_BINARY);
end;


procedure TWasmBaseWebSocketAPI.HandleStringMessage(aSocket: TWasmWebSocket; aMessage: String);
var
  lMessage : TJSUint8array;

begin
  lMessage:=FEncoder.encode(aMessage);
  HandleSendMessage(aSocket,lMessage,WASMWS_MESSAGE_TYPE_TEXT);
end;

// API methods called from within webassembly
function TWasmWebSocketAPI.CreateWebSocket(aID : Integer; aUserData : TWasmPointer; aUrl,aProtocols : string) :TWasmWebSocket;

begin
  Result:=GetWebSocketClass.Create(Self,aID,aUserData,aURL,aProtocols);
  FSockets[IntToStr(aID)]:=Result;
end;

function TWasmWebSocketAPI.WebsocketAllocate(aURL: PByte; aUrlLen: Longint; aProtocols: PByte; aProtocolLen: Longint;
  aUserData: TWasmPointer; aWebsocketID: TWasmWebSocketID): TWasmWebsocketResult;

var
  lURL,lProtocols : String;
  lSocket : TWasmWebSocket;

begin
  lURL:=env.GetUTF8StringFromMem(aURL,aUrlLen);
  lProtocols:=env.GetUTF8StringFromMem(aProtocols,aProtocolLen);
  {$IFNDEF NOLOGAPICALLS}
  If LogAPICalls then
    LogCall('HTTP.WebSocketAllocate("%s","%s",%d,%d)',[lURL,lProtocols,aUserData,aWebSocketID]);
  {$ENDIF}
  if (lUrl='') then
    Exit(WASMWS_RESULT_NO_URL);
  if Assigned(GetWebsocket(aWebSocketID)) then
    Exit(WASMWS_RESULT_DUPLICATEID);
  lSocket:=CreateWebSocket(aWebsocketID,aUserData,lURL,lProtocols);
  if Assigned(lSocket) then
    Result:=WASMWS_RESULT_SUCCESS
  else
    Result:=WASMWS_RESULT_ERROR;
{$IFNDEF NOLOGAPICALLS}
  If LogAPICalls then
    LogCall('HTTP.WebSocketAllocate("%s","%s",%d,%d) => %d',[lURL,lProtocols,aUserData,aWebSocketID,Result]);
{$ENDIF}
end;


function TWasmWebSocketAPI.WebsocketDeAllocate(aWebsocketID: TWasmWebSocketID): TWasmWebsocketResult;

begin
  {$IFNDEF NOLOGAPICALLS}
  If LogAPICalls then
    LogCall('HTTP.WebSocketDeAllocate(%d)',[aWebSocketID]);
  {$ENDIF}
  if FreeWebSocket(aWebSocketID) then
    Result:=WASMWS_RESULT_SUCCESS
  else
    Result:=WASMWS_RESULT_INVALIDID;
end;


function TWasmWebSocketAPI.WebsocketClose(aWebsocketID: TWasmWebSocketID; aCode: Longint; aReason: PByte; aReasonLen: Longint): TWasmWebsocketResult;

var
  lSocket : TWasmWebSocket;
  lReason : String;

begin
  lReason:=Env.GetUTF8StringFromMem(aReason,aReasonLen);
  {$IFNDEF NOLOGAPICALLS}
  If LogAPICalls then
    LogCall('HTTP.WebSocketClose(%d,%d,"%s")',[aWebSocketID,aCode,aReason]);
  {$ENDIF}
  lSocket:=GetWebsocket(aWebSocketID);
  if lSocket=Nil then
    Exit(WASMWS_RESULT_INVALIDID);
  lSocket.Close(aCode,lReason);
  Result:=WASMWS_RESULT_SUCCESS;
end;


function TWasmWebSocketAPI.WebsocketSend(aWebsocketID: TWasmWebSocketID; aData: PByte; aDataLen: Longint; aType: Longint
  ): TWasmWebsocketResult;
var
  lSocket : TWasmWebSocket;
  lData : TJSArrayBuffer;
  lText : String;

begin
  {$IFNDEF NOLOGAPICALLS}
  If LogAPICalls then
    LogCall('HTTP.WebSocketSend(%d,[%x],%d,%d)',[aWebSocketID,aData,aDataLen,aType]);
  {$ENDIF}
  lSocket:=GetWebsocket(aWebSocketID);
  if lSocket=Nil then
    Exit(WASMWS_RESULT_INVALIDID);
  lData:=getModuleMemoryDataView.buffer.slice(aData,aData+aDatalen);
  if aType=WASMWS_MESSAGE_TYPE_BINARY then
    lSocket.SendBinary(lData)
  else
    begin
    lText:=FDecoder.Decode(SharedToNonShared(lData));
    lSocket.SendText(lText);
    end;
  Result:=WASMWS_RESULT_SUCCESS;
end;



constructor TWasmBaseWebSocketAPI.Create(aEnv: TPas2JSWASIEnvironment);
begin
  inherited Create(aEnv);
  FNextID:=0;
  FSockets:=TJSObject.New;
  FEncoder:=TJSTextEncoder.New;
  FDecoder:=TJSTextDecoder.New;
end;


procedure TWasmBaseWebSocketAPI.FillImportObject(aObject: TJSObject);
begin
  aObject[websocketFN_Allocate]:=@WebsocketAllocate;
  aObject[websocketFN_DeAllocate]:=@WebsocketDeAllocate;
  aObject[websocketFN_Close]:=@WebsocketClose;
  aObject[websocketFN_Send]:=@WebsocketSend;
end;


function TWasmBaseWebSocketAPI.ImportName: String;
begin
  Result:=websocketExportName;
end;

{ ---------------------------------------------------------------------
  TWasmWebsocket
  ---------------------------------------------------------------------}


procedure TWasmWebsocket.HandleOpen(Event : TJSEvent);

begin
  if not Assigned(FAPI) then
    exit;
  FAPI.HandleOpen(Self);
  if assigned(Event) then;
end;

function TWasmWebsocket.ToString: String;
begin
  Result:=Format('WebSocket %d: %s',[WebSocketID,FWS.url])
end;


procedure TWasmWebsocket.HandleClose(Event : TJSEvent);

var
  lEvent : TJSWebsocketCloseEvent absolute event;

begin
  if not Assigned(FAPI) then
    exit;
  FAPI.HandleClose(Self,lEvent.Code,lEvent.Reason,lEvent.WasClean);
end;


procedure TWasmWebsocket.HandleMessage(Event : TJSEvent);

var
  lEvent : TJSMessageEvent absolute event;

begin
  if Not Assigned(FAPI) then
    exit;
  if isString(lEvent.Data) then
    FAPI.HandleStringMessage(Self,String(lEvent.Data))
  else if isObject(lEvent.Data) then
    FAPI.HandleBinaryMessage(Self,TJSArrayBuffer(lEvent.Data))
  else
    FAPI.DoError('Received empty message');
end;


procedure TWasmWebsocket.HandleError(Event : TJSEvent);

begin
  if not Assigned(FAPI) then
    exit;
  FAPI.HandleError(Self);
  if assigned(Event) then;
end;


constructor TWasmWebsocket.Create(aAPI: TWasmBaseWebSocketAPI; aID: TWasmWebsocketID; aUserData : TWasmPointer;const aURL: String; const aProtocols: String);
begin
  FAPI:=aAPI;
  FWebsocketID:=aID;
  FUserData:=aUserData;
  // We cannot pass an empty protocol string, it results in an error...
  if aProtocols<>'' then
    FWS:=TJSWebSocket.new(aUrl,aProtocols)
  else
    FWS:=TJSWebSocket.new(aUrl);
  FWS.binaryType:='arraybuffer';
  FWS.addEventListener('open',@HandleOpen);
  FWS.addEventListener('close',@HandleClose);
  FWS.addEventListener('error',@HandleError);
  FWS.addEventListener('message',@HandleMessage);
end;


destructor TWasmWebsocket.Destroy;
begin
  FAPI:=Nil;
  if FWS.readyState=TJSWebsocket.OPEN then
    FWS.close;
  inherited Destroy;
end;


procedure TWasmWebsocket.Close(aCode: Integer; aReason: String);
begin
  if (aReason<>'') then
    FWS.Close(aCode,aReason)
  else
    FWS.Close(aCode)
end;


procedure TWasmWebsocket.SendText(aData: String);

begin
  FWS.send(aData);
end;


procedure TWasmWebsocket.SendBinary(aData: TJSArrayBuffer);

begin
  FWS.send(aData);
end;

end.

