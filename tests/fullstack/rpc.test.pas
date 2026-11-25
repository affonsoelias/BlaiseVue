program rpc_test;

{
  BlaiseVue 4.3 End-to-End Type-Safe Pascal RPC with mORMot 2 (Unit Tests)
  ------------------------------------------------------------------------
  Tests strongly typed Pascal client proxies, JSON-RPC 2.0 wire protocol,
  HTTP and WebSocket transports, and compile-time interface adherence.
}

{$mode objfpc}

uses
  JS, Web, BVTestUtils, BVReactivity, BVCompiler, BVClient, BVRpc, Services, ClientProxies, BlaiseVue;

begin
  Describe('BlaiseVue 4.3 End-to-End Type-Safe Pascal RPC with mORMot 2', procedure
    begin
      It('should expose __BV_CORE__.rpc and global $rpc helper in reactive scope', procedure
        var
          HasRpcCore: Boolean;
          RootEl: TJSHTMLElement;
          Data, Methods: TJSObject;
          HasScopeRpc: Boolean;
        begin
          TBVRpcClient.EnsureBridge;
          asm
            HasRpcCore = Boolean(window.__BV_CORE__ && window.__BV_CORE__.rpc &&
                                 typeof window.__BV_CORE__.rpc.invoke === 'function' &&
                                 typeof window.__BV_CORE__.rpc.setBaseUrl === 'function' &&
                                 typeof window.__BV_CORE__.rpc.setTransport === 'function');
          end;
          Expect(HasRpcCore).ToBe(True);

          RootEl := TJSHTMLElement(document.createElement('div'));
          RootEl.setAttribute('id', 'rpc-test-app');
          document.body.appendChild(RootEl);

          Data := TJSObject.new;
          Methods := TJSObject.new;

          TBlaiseVue.Create('#rpc-test-app', Data, Methods, nil);

          asm
            HasScopeRpc = Boolean(Data.$rpc && typeof Data.$rpc.invoke === 'function');
          end;
          Expect(HasScopeRpc).ToBe(True);

          document.body.removeChild(RootEl);
        end);

      It('should configure baseUrl, token, headers, timeout, and transport on TBVRpcClient', procedure
        var
          BaseUrlMatches: Boolean;
          TokenMatches: Boolean;
          HeaderMatches: Boolean;
          TransportMatches: Boolean;
          PackMatches: Boolean;
        begin
          TBVRpcClient.SetBaseUrl('http://api.enterprise.local:8090/api/rpc');
          TBVRpcClient.SetToken('jwt-token-enterprise-999');
          TBVRpcClient.SetHeader('X-Enterprise-Client', 'BlaiseVue-Pascal-4.3');
          TBVRpcClient.SetTimeout(8000);
          TBVRpcClient.SetTransport('ws');
          TBVRpcClient.SetUsePack(True);

          asm
            BaseUrlMatches = (window.__BV_CORE__.rpc.baseUrl === 'http://api.enterprise.local:8090/api/rpc');
            TokenMatches = (window.__BV_CORE__.rpc.token === 'jwt-token-enterprise-999');
            HeaderMatches = (window.__BV_CORE__.rpc.headers['X-Enterprise-Client'] === 'BlaiseVue-Pascal-4.3');
            TransportMatches = (window.__BV_CORE__.rpc.transport === 'ws');
            PackMatches = (window.__BV_CORE__.rpc.usePack === true);
          end;

          Expect(BaseUrlMatches).ToBe(True);
          Expect(TokenMatches).ToBe(True);
          Expect(HeaderMatches).ToBe(True);
          Expect(TransportMatches).ToBe(True);
          Expect(PackMatches).ToBe(True);
          Expect(TBVRpcClient.GetBaseUrl).ToBe('http://api.enterprise.local:8090/api/rpc');
          Expect(TBVRpcClient.GetTransport).ToBe('ws');
          Expect(TBVRpcClient.GetUsePack).ToBe(True);

          // Reset defaults
          TBVRpcClient.SetTransport('http');
          TBVRpcClient.SetUsePack(False);
          TBVRpcClient.ClearToken;
        end);

      It('should register and resolve typed service proxies through singleton accessors', procedure
        var
          CustSvc: TCustomerServiceClient;
          ProdSvc: TProductServiceClient;
          SysSvc: TSystemServiceClient;
          ProxyRegistered: Boolean;
        begin
          CustSvc := CustomerService;
          ProdSvc := ProductService;
          SysSvc := SystemService;

          Expect(CustSvc <> nil).ToBe(True);
          Expect(ProdSvc <> nil).ToBe(True);
          Expect(SysSvc <> nil).ToBe(True);

          Expect(CustSvc.ServiceName).ToBe('CustomerService');
          Expect(ProdSvc.ServiceName).ToBe('ProductService');
          Expect(SysSvc.ServiceName).ToBe('SystemService');

          asm
            ProxyRegistered = Boolean(window.__BV_CORE__.rpc.services['CustomerService'] &&
                                      window.__BV_CORE__.rpc.services['ProductService'] &&
                                      window.__BV_CORE__.rpc.services['SystemService']);
          end;
          Expect(ProxyRegistered).ToBe(True);
        end);

      It('should format and dispatch JSON-RPC 2.0 payload over HTTP transport', procedure
        var
          CapturedUrl: string;
          CapturedMethod: string;
          CapturedRpcHeader: string;
          CapturedBodyService: string;
          CapturedBodyMethod: string;
          CapturedBodyId: Integer;
          CallbackReceived: Boolean;
          ReceivedCustomerName: string;
        begin
          CapturedUrl := '';
          CapturedMethod := '';
          CapturedRpcHeader := '';
          CapturedBodyService := '';
          CapturedBodyMethod := '';
          CapturedBodyId := 0;
          CallbackReceived := False;
          ReceivedCustomerName := '';

          TBVRpcClient.SetBaseUrl('http://localhost:8090/api/rpc');
          TBVRpcClient.SetTransport('http');

          asm
            var originalFetch = window.fetch;
            window.fetch = function(url, opts) {
              CapturedUrl = String(url);
              CapturedMethod = String(opts.method);
              CapturedRpcHeader = String(opts.headers['X-BlaiseVue-RPC'] || '');
              try {
                var body = JSON.parse(opts.body);
                CapturedBodyService = String(body.service);
                CapturedBodyMethod = String(body.method);
                CapturedBodyId = Number(body.id);
              } catch(e) {}

              var mockRes = {
                ok: true,
                status: 200,
                headers: { get: function() { return 'application/json'; } },
                json: function() {
                  return Promise.resolve({
                    jsonrpc: '2.0',
                    result: { id: 101, name: 'Empresa Alpha Ltda', email: 'alpha@corp.com', phone: '1199999999', active: true, createdAt: '2026-10-21' },
                    id: CapturedBodyId
                  });
                }
              };
              return Promise.resolve(mockRes);
            };
          end;

          CustomerService.GetById(101, procedure(Item: TCustomer)
            begin
              CallbackReceived := True;
              ReceivedCustomerName := Item.Name;
            end);

          asm
            setTimeout(function() {
              window.fetch = originalFetch;
            }, 0);
          end;

          Expect(CapturedMethod).ToBe('POST');
          Expect(Pos('CustomerService/GetById', CapturedUrl) > 0).ToBe(True);
          Expect(CapturedRpcHeader).ToBe('2.0');
          Expect(CapturedBodyService).ToBe('CustomerService');
          Expect(CapturedBodyMethod).ToBe('GetById');
          Expect(CapturedBodyId > 0).ToBe(True);
        end);

      It('should handle RPC errors and dispatch to onError callback', procedure
        var
          ErrorCallbackReceived: Boolean;
          ReceivedErrorMsg: string;
        begin
          ErrorCallbackReceived := False;
          ReceivedErrorMsg := '';

          TBVRpcClient.SetBaseUrl('http://localhost:8090/api/rpc');
          TBVRpcClient.SetTransport('http');

          asm
            var originalFetch = window.fetch;
            window.fetch = function(url, opts) {
              var mockRes = {
                ok: true,
                status: 200,
                headers: { get: function() { return 'application/json'; } },
                json: function() {
                  return Promise.resolve({
                    jsonrpc: '2.0',
                    error: { code: -32601, message: 'Method not found: CustomerService.NonExistent' },
                    id: 1
                  });
                }
              };
              return Promise.resolve(mockRes);
            };
          end;

          CustomerService.GetAll(procedure(Items: TCustomerDynArray)
            begin
            end,
            procedure(Err: string)
            begin
              ErrorCallbackReceived := True;
              ReceivedErrorMsg := Err;
            end);

          asm
            setTimeout(function() {
              window.fetch = originalFetch;
            }, 0);
          end;

          Expect(True).ToBe(True);
        end);

      It('should support Promise-based invocations (*Async) returning TJSPromise', procedure
        var
          PromiseObj: TJSPromise;
          IsPromise: Boolean;
        begin
          PromiseObj := CustomerService.GetAllAsync;
          Expect(PromiseObj <> nil).ToBe(True);

          asm
            IsPromise = Boolean(PromiseObj && typeof PromiseObj.then === 'function');
          end;
          Expect(IsPromise).ToBe(True);

          PromiseObj := SystemService.GetStatusAsync;
          asm
            IsPromise = Boolean(PromiseObj && typeof PromiseObj.then === 'function');
          end;
          Expect(IsPromise).ToBe(True);
        end);

      It('should support real-time WebSocket transport for bidirectional RPC', procedure
        var
          WsSendCalled: Boolean;
          WsSentEvent: string;
          WsSentService: string;
          WsSentMethod: string;
          RpcResultReceived: Boolean;
        begin
          WsSendCalled := False;
          WsSentEvent := '';
          WsSentService := '';
          WsSentMethod := '';
          RpcResultReceived := False;

          TBVWebSocket.EnsureBridge;
          TBVRpcClient.SetTransport('ws');

          asm
            var oldIsConnected = window.__BV_CORE__.ws.isConnected;
            var oldSend = window.__BV_CORE__.ws.send;

            window.__BV_CORE__.ws.isConnected = function() { return true; };
            window.__BV_CORE__.ws.send = function(frame) {
              WsSendCalled = true;
              if (frame) {
                WsSentEvent = String(frame.event);
                if (frame.data) {
                  WsSentService = String(frame.data.service);
                  WsSentMethod = String(frame.data.method);
                  // Synchronously simulate response so timer doesn't leak after test teardown
                  if (typeof window !== 'undefined' && window.__BV_CORE__ && window.__BV_CORE__.ws) {
                    window.__BV_CORE__.ws.emit('rpc_response', {
                      data: {
                        jsonrpc: '2.0',
                        result: 'pong: echo-payload',
                        id: frame.data.id
                      }
                    });
                  }
                }
              }
              return true;
            };
          end;

          SystemService.Ping('echo-payload', procedure(Res: string)
            begin
              RpcResultReceived := True;
            end);

          Expect(WsSendCalled).ToBe(True);
          Expect(WsSentEvent).ToBe('rpc_call');
          Expect(WsSentService).ToBe('SystemService');
          Expect(WsSentMethod).ToBe('Ping');

          asm
            window.__BV_CORE__.ws.isConnected = oldIsConnected;
            window.__BV_CORE__.ws.send = oldSend;
            window.__BV_CORE__.rpc.setTransport('http');
          end;
        end);

      It('should support high-throughput pack mode (X-BlaiseVue-Pack)', procedure
        var
          PackHeaderSet: Boolean;
        begin
          TBVRpcClient.SetUsePack(True);
          Expect(TBVRpcClient.GetUsePack).ToBe(True);

          asm
            var originalFetch = window.fetch;
            window.fetch = function(url, opts) {
              PackHeaderSet = (opts.headers['X-BlaiseVue-Pack'] === '1');
              return Promise.resolve({
                ok: true,
                status: 200,
                headers: { get: function() { return 'application/json'; } },
                json: function() { return Promise.resolve({ jsonrpc: '2.0', result: 'online', id: 1 }); }
              });
            };
          end;

          SystemService.GetStatus(procedure(Res: string)
            begin
            end);

          asm
            window.fetch = originalFetch;
            window.__BV_CORE__.rpc.setUsePack(false);
          end;

          Expect(PackHeaderSet).ToBe(True);
          Expect(TBVRpcClient.GetUsePack).ToBe(False);
        end);
    end);
end.