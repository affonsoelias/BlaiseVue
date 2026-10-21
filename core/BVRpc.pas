unit BVRpc;

{
  BVRpc - BlaiseVue 4.3 End-to-End Type-Safe Pascal RPC with mORMot 2
  -------------------------------------------------------------------
  Provides a compile-time verified, zero-boilerplate remote procedure
  call (RPC) framework in pure Object Pascal.

  Features:
  - Transparent client proxies implementing mORMot 2 SOA interfaces
  - JSON-RPC 2.0 and mORMot SOA wire protocol compatibility
  - Multi-transport: HTTP POST and real-time bidirectional WebSockets
  - High-throughput packing and binary serialization options
  - Dual invocation models: Type-safe Callbacks and Promises (*Async)
  - Seamless injection into BlaiseVue reactive component scope ($rpc)
}

{$mode objfpc}

interface

uses
  JS, Web, SysUtils, BVReactivity;

type
  { Generic RPC Callbacks }
  TRpcSuccessProc = procedure(Result: JSValue);
  TRpcErrorProc = procedure(const ErrorMsg: string; Code: Integer);
  TRpcSimpleErrorProc = procedure(const ErrorMsg: string);

  { Base Remote Proxy class for all generated client service proxies }
  TBVRemoteProxy = class(TInterfacedObject)
  private
    FServiceName: string;
  public
    constructor Create(const AServiceName: string);
    property ServiceName: string read FServiceName;

    { Asynchronous Remote Invocations }
    function CallRemote(const AMethodName: string; Params: JSValue = nil; OnSuccess: JSValue = nil; OnError: JSValue = nil): JSValue;
    function CallRemoteAsync(const AMethodName: string; Params: JSValue = nil): JSValue;
  end;

  { Main RPC Client Manager & Bridge }
  TBVRpcClient = class
  public
    class procedure EnsureBridge;
    class procedure SetBaseUrl(const Url: string);
    class function GetBaseUrl: string;
    class procedure SetToken(const Token: string);
    class procedure ClearToken;
    class procedure SetHeader(const Key, Value: string);
    class procedure SetTimeout(TimeoutMs: Integer);
    class procedure SetTransport(const ATransport: string); { 'http' | 'ws' }
    class function GetTransport: string;
    class procedure SetUsePack(AValue: Boolean);
    class function GetUsePack: Boolean;
    class function Invoke(const ServiceName, MethodName: string; Params: JSValue = nil; OnSuccess: JSValue = nil; OnError: JSValue = nil): JSValue;
    class function InvokeAsync(const ServiceName, MethodName: string; Params: JSValue = nil): JSValue;
    class procedure RegisterService(const ServiceName: string; ServiceProxy: JSValue);
    class function GetService(const ServiceName: string): JSValue;
    class function IsWebSocketReady: Boolean;
  end;

implementation

{ TBVRemoteProxy }

constructor TBVRemoteProxy.Create(const AServiceName: string);
begin
  inherited Create;
  FServiceName := AServiceName;
  TBVRpcClient.EnsureBridge;
  TBVRpcClient.RegisterService(AServiceName, JSValue(Self));
end;

function TBVRemoteProxy.CallRemote(const AMethodName: string; Params: JSValue; OnSuccess: JSValue; OnError: JSValue): JSValue;
begin
  Result := TBVRpcClient.Invoke(FServiceName, AMethodName, Params, OnSuccess, OnError);
end;

function TBVRemoteProxy.CallRemoteAsync(const AMethodName: string; Params: JSValue): JSValue;
begin
  Result := TBVRpcClient.InvokeAsync(FServiceName, AMethodName, Params);
end;

{ TBVRpcClient }

class procedure TBVRpcClient.EnsureBridge;
begin
  asm
    if (!window.__BV_CORE__) window.__BV_CORE__ = {};
    if (!window.__BV_CORE__.rpc) {
      window.__BV_CORE__.rpc = {
        baseUrl: 'http://localhost:8090/api/rpc',
        token: '',
        headers: {},
        timeout: 10000,
        transport: 'http',
        usePack: false,
        services: {},
        idCounter: 0,
        pendingCalls: {},

        setBaseUrl: function(url) {
          if (!url) return;
          this.baseUrl = String(url).replace(/\/$/, '');
        },

        getBaseUrl: function() {
          return this.baseUrl;
        },

        setToken: function(t) {
          this.token = t || '';
        },

        clearToken: function() {
          this.token = '';
        },

        setHeader: function(k, v) {
          if (k) this.headers[k] = v;
        },

        setTimeout: function(ms) {
          this.timeout = ms || 10000;
        },

        setTransport: function(t) {
          this.transport = (t === 'ws') ? 'ws' : 'http';
        },

        getTransport: function() {
          return this.transport;
        },

        setUsePack: function(p) {
          this.usePack = Boolean(p);
        },

        getUsePack: function() {
          return this.usePack;
        },

        registerService: function(name, proxy) {
          this.services[name] = proxy;
        },

        getService: function(name) {
          return this.services[name] || null;
        },

        isWebSocketReady: function() {
          return Boolean(window.__BV_CORE__.ws && window.__BV_CORE__.ws.isConnected());
        },

        // Core RPC dispatcher
        invoke: function(service, method, params, onSuccess, onError) {
          var self = this;
          var callId = ++this.idCounter;
          var normParams = (params !== undefined && params !== null) ? params : [];
          if (!Array.isArray(normParams)) {
            normParams = [normParams];
          }

          var payload = {
            jsonrpc: '2.0',
            service: service,
            method: method,
            params: normParams,
            id: callId
          };

          // 1. WebSocket Transport Branch
          if (this.transport === 'ws' && this.isWebSocketReady()) {
            var wsPromise = new Promise(function(resolve, reject) {
              var timer = setTimeout(function() {
                delete self.pendingCalls[callId];
                var err = new Error('RPC Timeout after ' + self.timeout + 'ms: ' + service + '.' + method);
                err.code = -32000;
                if (onError) onError(err.message, -32000);
                reject(err);
              }, self.timeout);

              self.pendingCalls[callId] = {
                resolve: function(val) {
                  clearTimeout(timer);
                  if (onSuccess) onSuccess(val);
                  resolve(val);
                },
                reject: function(err) {
                  clearTimeout(timer);
                  var msg = (err && err.message) ? err.message : String(err);
                  var code = (err && err.code) ? err.code : -32603;
                  if (onError) onError(msg, code);
                  reject(err);
                }
              };

              window.__BV_CORE__.ws.send({
                event: 'rpc_call',
                data: payload
              });
            });
            return wsPromise;
          }

          // 2. HTTP POST Transport Branch (Default & Resilient Fallback)
          var url = this.baseUrl + '/' + encodeURIComponent(service) + '/' + encodeURIComponent(method);
          var hdrs = Object.assign({
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'X-BlaiseVue-RPC': '2.0'
          }, this.headers);

          if (this.usePack) {
            hdrs['X-BlaiseVue-Pack'] = '1';
          }

          if (this.token) {
            hdrs['Authorization'] = 'Bearer ' + this.token;
          }

          var fetchPromise;
          if (typeof fetch === 'function') {
            var controller = (typeof AbortController !== 'undefined') ? new AbortController() : null;
            var timeoutId = null;
            var fetchOpts = {
              method: 'POST',
              headers: hdrs,
              body: JSON.stringify(payload)
            };
            if (controller) {
              fetchOpts.signal = controller.signal;
              timeoutId = setTimeout(function() {
                controller.abort();
              }, self.timeout);
            }

            fetchPromise = fetch(url, fetchOpts).then(function(res) {
              if (timeoutId) clearTimeout(timeoutId);
              return res.json().then(function(data) {
                if (!res.ok) {
                  var errMsg = (data && (data.error || data.message))
                    ? (typeof data.error === 'object' ? data.error.message : (data.error || data.message))
                    : ('HTTP ' + res.status);
                  var httpErr = new Error(errMsg);
                  httpErr.status = res.status;
                  httpErr.data = data;
                  httpErr.code = (data && data.error && data.error.code) ? data.error.code : res.status;
                  throw httpErr;
                }
                if (data && data.error) {
                  var rpcErr = new Error((typeof data.error === 'object') ? data.error.message : String(data.error));
                  rpcErr.code = (typeof data.error === 'object' && data.error.code) ? data.error.code : -32603;
                  throw rpcErr;
                }
                return (data && data.result !== undefined) ? data.result : data;
              });
            }).catch(function(err) {
              if (timeoutId) clearTimeout(timeoutId);
              throw err;
            });
          } else {
            fetchPromise = Promise.reject(new Error('Fetch API is not available'));
          }

          fetchPromise.then(function(result) {
            if (typeof onSuccess === 'function') {
              try { onSuccess(result); } catch(e) { console.error('[BVRpc Callback Error]', e); }
            }
          }).catch(function(err) {
            var msg = (err && err.message) ? err.message : String(err);
            var code = (err && err.code) ? err.code : -32603;
            if (typeof onError === 'function') {
              try { onError(msg, code); } catch(e) { console.error('[BVRpc Error Callback]', e); }
            } else {
              console.warn('[BVRpc Error]', service + '.' + method, msg);
            }
          });

          return fetchPromise;
        }
      };

      // Set up WebSocket RPC response listener if WebSocket helper is available
      if (window.__BV_CORE__.ws) {
        window.__BV_CORE__.ws.on('rpc_response', function(resData) {
          if (!resData) return;
          var rpcObj = resData.data !== undefined ? resData.data : resData;
          if (rpcObj && rpcObj.id && window.__BV_CORE__.rpc.pendingCalls[rpcObj.id]) {
            var pending = window.__BV_CORE__.rpc.pendingCalls[rpcObj.id];
            delete window.__BV_CORE__.rpc.pendingCalls[rpcObj.id];
            if (rpcObj.error) {
              var errObj = new Error(typeof rpcObj.error === 'object' ? rpcObj.error.message : String(rpcObj.error));
              errObj.code = (typeof rpcObj.error === 'object' && rpcObj.error.code) ? rpcObj.error.code : -32603;
              pending.reject(errObj);
            } else {
              pending.resolve(rpcObj.result !== undefined ? rpcObj.result : rpcObj);
            }
          }
        });
      }
    }
  end;
end;

class procedure TBVRpcClient.SetBaseUrl(const Url: string);
begin
  EnsureBridge;
  asm
    window.__BV_CORE__.rpc.setBaseUrl(Url);
  end;
end;

class function TBVRpcClient.GetBaseUrl: string;
var
  Val: JSValue;
begin
  EnsureBridge;
  asm
    Val = window.__BV_CORE__.rpc.getBaseUrl();
  end;
  Result := String(Val);
end;

class procedure TBVRpcClient.SetToken(const Token: string);
begin
  EnsureBridge;
  asm
    window.__BV_CORE__.rpc.setToken(Token);
  end;
end;

class procedure TBVRpcClient.ClearToken;
begin
  EnsureBridge;
  asm
    window.__BV_CORE__.rpc.clearToken();
  end;
end;

class procedure TBVRpcClient.SetHeader(const Key, Value: string);
begin
  EnsureBridge;
  asm
    window.__BV_CORE__.rpc.setHeader(Key, Value);
  end;
end;

class procedure TBVRpcClient.SetTimeout(TimeoutMs: Integer);
begin
  EnsureBridge;
  asm
    window.__BV_CORE__.rpc.setTimeout(TimeoutMs);
  end;
end;

class procedure TBVRpcClient.SetTransport(const ATransport: string);
begin
  EnsureBridge;
  asm
    window.__BV_CORE__.rpc.setTransport(ATransport);
  end;
end;

class function TBVRpcClient.GetTransport: string;
var
  Val: JSValue;
begin
  EnsureBridge;
  asm
    Val = window.__BV_CORE__.rpc.getTransport();
  end;
  Result := String(Val);
end;

class procedure TBVRpcClient.SetUsePack(AValue: Boolean);
begin
  EnsureBridge;
  asm
    window.__BV_CORE__.rpc.setUsePack(AValue);
  end;
end;

class function TBVRpcClient.GetUsePack: Boolean;
var
  Val: JSValue;
begin
  EnsureBridge;
  asm
    Val = window.__BV_CORE__.rpc.getUsePack();
  end;
  Result := Boolean(Val);
end;

class function TBVRpcClient.Invoke(const ServiceName, MethodName: string; Params: JSValue; OnSuccess: JSValue; OnError: JSValue): JSValue;
begin
  EnsureBridge;
  asm
    Result = window.__BV_CORE__.rpc.invoke(ServiceName, MethodName, Params, OnSuccess, OnError);
  end;
end;

class function TBVRpcClient.InvokeAsync(const ServiceName, MethodName: string; Params: JSValue): JSValue;
begin
  EnsureBridge;
  asm
    Result = window.__BV_CORE__.rpc.invoke(ServiceName, MethodName, Params);
  end;
end;

class procedure TBVRpcClient.RegisterService(const ServiceName: string; ServiceProxy: JSValue);
begin
  EnsureBridge;
  asm
    window.__BV_CORE__.rpc.registerService(ServiceName, ServiceProxy);
  end;
end;

class function TBVRpcClient.GetService(const ServiceName: string): JSValue;
begin
  EnsureBridge;
  asm
    Result = window.__BV_CORE__.rpc.getService(ServiceName);
  end;
end;

class function TBVRpcClient.IsWebSocketReady: Boolean;
var
  Val: JSValue;
begin
  EnsureBridge;
  asm
    Val = window.__BV_CORE__.rpc.isWebSocketReady();
  end;
  Result := Boolean(Val);
end;

initialization
  TBVRpcClient.EnsureBridge;

end.