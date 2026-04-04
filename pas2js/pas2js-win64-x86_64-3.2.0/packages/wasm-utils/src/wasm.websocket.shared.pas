{
    This file is part of the Free Component Library

    Webassembly Websocket API - Definitions shared with host implementation.
    Copyright (c) 2024 by Michael Van Canneyt michael@freepascal.org

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
unit wasm.websocket.shared;

{$mode ObjFPC}{$H+}

interface

Type
  TWasmWebsocketResult = longint;
  TWasmWebsocketID = longint;
  TWasmWebSocketMessageType = Longint;
  TWebsocketCallBackResult = Longint;

  {$IFNDEF PAS2JS}
  PWasmWebSocketID = ^TWasmWebsocketID;
  {$ELSE}
  TWasmPointer = longint;

  PByte = TWasmPointer;
  PWasmWebSocketID = TWasmPointer;
  {$endif}

Const
  WASMWS_RESULT_SUCCESS     = 0;
  WASMWS_RESULT_ERROR       = -1;
  WASMWS_RESULT_NO_URL      = -2;
  WASMWS_RESULT_INVALIDID   = -3;
  WASMWS_RESULT_FAILEDLOCK  = -4;
  WASMWS_RESULT_INVALIDSIZE = -5;
  WASMWS_RESULT_NOSHAREDMEM = -6;
  WASMWS_RESULT_DUPLICATEID = -7;

  WASMWS_CALLBACK_SUCCESS   = 0;
  WASMWS_CALLBACK_NOHANDLER = -1;
  WASMWS_CALLBACK_ERROR     = -2;

  WASMWS_MESSAGE_TYPE_TEXT   = 0;
  WASMWS_MESSAGE_TYPE_BINARY = 1;

const
  websocketExportName  = 'websocket';
  websocketFN_Allocate = 'allocate_websocket';
  websocketFN_DeAllocate = 'deallocate_websocket';
  websocketFN_close = 'close_websocket';
  websocketFN_send = 'send_websocket';

const
  {
    Worker websockets use a dedicated worker to be able to handle callbacks.
    Communication with this worker happens through shared memory.

    The shared memory is at least 1024 bytes large, and has the following layout:

    Index 0 : Semaphore (4 bytes)
    Index 4 : ID of websocket (4 bytes)
    Index 8 : Operation (1 byte)
      0 : Create
      1 : Send
      2 : Close
    Index 9 : Unused
    Depending on operation:
    create:
      Index 10 : User data (4 bytes)
      Index 14 : Length of URL (4 bytes)
      Index 18 : Length of protocol (4 bytes)
      Index 22 : URL data  (URL length bytes)
      Index 22+URL length : Protocol data (protocol length bytes)
    send:
      Index 10 : Length of data (4 bytes)
      Index 14 : Address of data (4 bytes)
    close:
      Index 10 : Close code (4 bytes)
      Index 14 : Reason length  (4 bytes)
      Index 18 : Reason data (reason length bytes)
    note that this means that the length of URL+Protocol is limited to shared memory length minus 22 bytes.
  }

  // Common
  WASM_SHMSG_SEMAPHORE   = 0;
  WASM_SHMSG_RESULT      = 4;
  WASM_SHMSG_WEBSOCKETID = 8;
  WASM_SHMSG_OPERATION   = 12;
  // Create
  WASM_SHMSG_CREATE_USERDATA = 14;
  WASM_SHMSG_CREATE_URL_LENGTH = 18;
  WASM_SHMSG_CREATE_PROTOCOL_LENGTH = 22;
  WASM_SHMSG_CREATE_URL_DATA = 26;
  WASM_SHMSG_CREATE_PROTOCOL_DATA_OFFSET = WASM_SHMSG_CREATE_URL_DATA;
  // Send
  WASM_SHMSG_SEND_DATA_LENGTH = 14;
  WASM_SHMSG_SEND_DATA_TYPE = 18;
  WASM_SHMSG_SEND_DATA_ADDRESS = 22;
  // Close
  WASM_SHMSG_CLOSE_CODE = 14;
  WASM_SHMSG_CLOSE_REASON_LENGTH = 18;
  WASM_SHMSG_CLOSE_REASON_DATA = 22;

  WASM_SEM_NOT_SET = 0;
  WASM_SEM_SET   = 1;

  // Operation (goes in WASM_SHMSG_OPERATION);
  WASM_WSOPERATION_NONE   = 0;
  WASM_WSOPERATION_CREATE = 1;
  WASM_WSOPERATION_FREE   = 2;
  WASM_WSOPERATION_SEND   = 3;
  WASM_WSOPERATION_CLOSE  = 4;

  WASM_SHMSG_FIXED_LEN = WASM_SHMSG_CREATE_URL_DATA+4;

const
  // These are for workers. Must be lowercase. Command names are lowercased.
  cmdEnableLog = 'enablelog';
  cmdDisableLog = 'disablelog';
  cmdWebsocketSharedMem = 'websocketmem';

implementation

end.

