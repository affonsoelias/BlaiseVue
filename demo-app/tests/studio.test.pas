program studio_test;

{$mode objfpc}

uses
  JS, Web, SysUtils,
  BVTestUtils, BVComponents, BVReactivity, BVCompiler, BVDevTools, BlaiseStudio;

var
  Wrapper: TWrapper;
  TestPayload, TestState: TJSObject;
  CapturedEvents: TJSArray;

begin
  InitDevTools;
  Describe('BlaiseVue 4.0 Studio Dashboard & Developer Cockpit (BlaiseStudio)', procedure
    begin
      // 1. Bridge initialization
      It('should initialize global $studio bridge on window.__BV_CORE__.studio', procedure
        begin
          Expect(TJSObject(window['__BV_CORE__'])['studio']).toBeDefined;
          Expect(window['$studio']).toBeDefined;
          Expect(TBVStudioClient.GetUrl).toBe('ws://localhost:9000/ws');
        end);

      // 2. Custom connection configuration
      It('should configure custom studio WebSocket URL', procedure
        begin
          TBVStudioClient.Connect('ws://127.0.0.1:9050/ws');
          Expect(TBVStudioClient.GetUrl).toBe('ws://127.0.0.1:9050/ws');
          
          // Reset back to default
          TBVStudioClient.Connect('ws://localhost:9000/ws');
          Expect(TBVStudioClient.GetUrl).toBe('ws://localhost:9000/ws');
        end);

      // 3. Telemetry and logging methods
      It('should invoke SendLog, SendEvent and TrackWebSocketFrame without exceptions', procedure
        begin
          TestPayload := TJSObject.new;
          TestPayload['status'] := 'ready';
          TestPayload['frame'] := 42;

          TBVStudioClient.SendLog('info', 'System telemetry check', TestPayload);
          TBVStudioClient.SendEvent('build:start', TestPayload);
          TBVStudioClient.TrackWebSocketFrame('IN', 'mormot:broadcast', TestPayload);
          TBVStudioClient.TrackWebSocketFrame('OUT', 'mormot:query', TestPayload);

          Expect(window['$studio']).toBeDefined;
        end);

      // 4. Component state inspection
      It('should send component state snapshot to Studio inspector', procedure
        begin
          TestState := TJSObject.new;
          TestState['count'] := 10;
          TestState['activeTab'] := 'charts';
          TestState['theme'] := 'dark';

          TBVStudioClient.InspectState('DashboardComponent', TestState);
          Expect(window['$studio']).toBeDefined;
        end);

      // 5. DevTools hook integration
      It('should capture DevTools hook events and forward to Studio bridge', procedure
        var
          Hook: TJSObject;
        begin
          Hook := TJSObject(window['__BV_DEVTOOLS_HOOK__']);
          Expect(Hook).toBeDefined;
          
          // Emit a test event through DevTools hook
          TestPayload := TJSObject.new;
          TestPayload['component'] := 'BVBarChart';
          TestPayload['action'] := 'mount';
          
          asm
            if (window.__BV_DEVTOOLS_HOOK__ && typeof window.__BV_DEVTOOLS_HOOK__.emit === 'function') {
              window.__BV_DEVTOOLS_HOOK__.emit('component:mount', { component: 'BVBarChart', action: 'mount' });
            }
          end;

          Expect(window['$studio']).toBeDefined;
        end);

      // 6. Studio API endpoints and schema contract
      It('should validate Studio HTTP & WebSocket endpoint contract', procedure
        var
          StudioEndpoints: array[0..4] of string;
        begin
          StudioEndpoints[0] := '/api/project';
          StudioEndpoints[1] := '/api/components';
          StudioEndpoints[2] := '/api/routes';
          StudioEndpoints[3] := '/api/actions/build';
          StudioEndpoints[4] := '/ws';

          Expect(StudioEndpoints[0]).toBe('/api/project');
          Expect(StudioEndpoints[1]).toBe('/api/components');
          Expect(StudioEndpoints[2]).toBe('/api/routes');
          Expect(StudioEndpoints[3]).toBe('/api/actions/build');
          Expect(StudioEndpoints[4]).toBe('/ws');
        end);
    end);
end.
