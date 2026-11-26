program mormot_client_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, BVReactivity, BVCompiler, BVClient, BlaiseVue;

begin
  Describe('BlaiseVue 3.5 Full-Stack Pascal ($api & $ws for mORMot 2)', procedure
    begin
      It('should expose __BV_CORE__.api and global $api helper', procedure
        var
          HasApi: Boolean;
        begin
          asm
            HasApi = Boolean(window.__BV_CORE__ && window.__BV_CORE__.api &&
                             typeof window.__BV_CORE__.api.get === 'function' &&
                             typeof window.__BV_CORE__.api.post === 'function' &&
                             typeof window.__BV_CORE__.api.put === 'function' &&
                             typeof window.__BV_CORE__.api.delete === 'function');
          end;
          Expect(HasApi).ToBe(True);
        end);

      It('should configure baseURL and Bearer authentication token on $api', procedure
        var
          BaseUrlMatches, TokenMatches: Boolean;
        begin
          TBVApi.SetBaseUrl('http://localhost:8090');
          TBVApi.SetToken('mock-jwt-token-123');
          asm
            BaseUrlMatches = (window.__BV_CORE__.api.baseUrl === 'http://localhost:8090');
            TokenMatches = (window.__BV_CORE__.api.token === 'mock-jwt-token-123');
          end;
          Expect(BaseUrlMatches).ToBe(True);
          Expect(TokenMatches).ToBe(True);

          TBVApi.ClearToken;
          asm
            TokenMatches = (window.__BV_CORE__.api.token === '');
          end;
          Expect(TokenMatches).ToBe(True);
        end);

      It('should configure custom request headers on $api', procedure
        var
          HeaderMatches: Boolean;
        begin
          TBVApi.SetHeader('X-Custom-Client', 'BlaiseVue-Pascal');
          asm
            HeaderMatches = (window.__BV_CORE__.api.headers['X-Custom-Client'] === 'BlaiseVue-Pascal');
          end;
          Expect(HeaderMatches).ToBe(True);
        end);

      It('should expose __BV_CORE__.ws and global $ws helper', procedure
        var
          HasWs: Boolean;
        begin
          asm
            HasWs = Boolean(window.__BV_CORE__ && window.__BV_CORE__.ws &&
                            typeof window.__BV_CORE__.ws.connect === 'function' &&
                            typeof window.__BV_CORE__.ws.send === 'function' &&
                            typeof window.__BV_CORE__.ws.on === 'function' &&
                            typeof window.__BV_CORE__.ws.off === 'function');
          end;
          Expect(HasWs).ToBe(True);
        end);

      It('should register and trigger custom real-time events on $ws', procedure
        var
          EventReceived: Boolean;
          PayloadData: string;
        begin
          EventReceived := False;
          PayloadData := '';

          TBVWebSocket.On('chat_message', procedure(Data: JSValue)
            begin
              EventReceived := True;
              asm
                PayloadData = Data ? String(Data.text) : '';
              end;
            end);

          asm
            window.__BV_CORE__.ws.emit('chat_message', { text: 'Hello from mORMot 2!' });
          end;

          Expect(EventReceived).ToBe(True);
          Expect(PayloadData).ToBe('Hello from mORMot 2!');
        end);

      It('should inject $api and $ws into compiled component reactive data scope', procedure
        var
          RootEl: TJSHTMLElement;
          Data, Methods: TJSObject;
          HasScopeApi, HasScopeWs: Boolean;
        begin
          RootEl := TJSHTMLElement(document.createElement('div'));
          RootEl.setAttribute('id', 'mormot-test-app');
          document.body.appendChild(RootEl);

          Data := TJSObject.new;
          Methods := TJSObject.new;

          TBlaiseVue.Create('#mormot-test-app', Data, Methods, nil);

          asm
            HasScopeApi = Boolean(Data.$api && typeof Data.$api.get === 'function');
            HasScopeWs = Boolean(Data.$ws && typeof Data.$ws.on === 'function');
          end;

          Expect(HasScopeApi).ToBe(True);
          Expect(HasScopeWs).ToBe(True);

          document.body.removeChild(RootEl);
        end);
    end);
end.
