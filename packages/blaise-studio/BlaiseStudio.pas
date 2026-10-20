unit BlaiseStudio;

{$mode objfpc}

interface

uses
  JS, Web, SysUtils;

type
  { TBVStudioClient - Live Developer Telemetry & Studio Bridge }
  TBVStudioClient = class
  private
    class var FConnected: Boolean;
    class var FSocket: JSValue;
    class var FUrl: string;
    class procedure HandleOpen(ev: JSValue);
    class procedure HandleClose(ev: JSValue);
    class procedure HandleError(ev: JSValue);
    class procedure HandleMessage(ev: JSValue);
  public
    class procedure EnsureBridge;
    class procedure Connect(const AUrl: string = 'ws://localhost:9000/ws');
    class procedure Disconnect;
    class procedure SendEvent(const AEventName: string; const APayload: JSValue = nil);
    class procedure SendLog(const ALevel, AMessage: string; const AData: JSValue = nil);
    class procedure InspectState(const AComponentName: string; const AState: JSValue);
    class procedure TrackWebSocketFrame(const ADirection, AChannel: string; const APayload: JSValue);
    class function IsConnected: Boolean;
    class function GetUrl: string;
  end;

  TBVStudio = TBVStudioClient;

procedure InitStudio;

implementation

procedure InitStudio;
begin
  TBVStudioClient.EnsureBridge;
end;

class procedure TBVStudioClient.EnsureBridge;
begin
  asm
    if (!window.__BV_CORE__) window.__BV_CORE__ = {};
    if (!window.__BV_CORE__.studio) {
      const studioBridge = {
        connected: false,
        socket: null,
        url: 'ws://localhost:9000/ws',
        
        connect: function(url) {
          if (this.socket && this.connected) return;
          this.url = url || 'ws://localhost:9000/ws';
          try {
            this.socket = new WebSocket(this.url);
            this.socket.onopen = (e) => {
              this.connected = true;
              console.log('%c[BlaiseStudio]%c Connected to Studio at ' + this.url, 'background:#3b82f6;color:white;padding:2px 6px;border-radius:4px;', '');
              this.send('studio:client-connected', {
                userAgent: navigator.userAgent,
                time: new Date().toISOString(),
                url: window.location.href
              });
            };
            this.socket.onclose = () => {
              this.connected = false;
              this.socket = null;
            };
            this.socket.onerror = (err) => {
              this.connected = false;
            };
            this.socket.onmessage = (msg) => {
              try {
                const data = JSON.parse(msg.data);
                if (data.type === 'studio:eval') {
                  console.log('[BlaiseStudio Eval]', eval(data.code));
                }
              } catch(e) {}
            };
          } catch(e) {
            this.connected = false;
          }
        },

        disconnect: function() {
          if (this.socket) {
            try { this.socket.close(); } catch(e) {}
            this.socket = null;
            this.connected = false;
          }
        },

        send: function(type, payload) {
          if (!this.socket || this.socket.readyState !== 1) return;
          try {
            this.socket.send(JSON.stringify({
              type: type,
              payload: payload,
              time: new Date().toISOString(),
              source: 'blaisevue-client'
            }));
          } catch(e) {}
        },

        sendLog: function(level, message, data) {
          this.send('studio:log', { level: level || 'info', message: message, data: data });
        },

        sendEvent: function(eventName, payload) {
          this.send('studio:event', { name: eventName, payload: payload });
        },

        inspectState: function(componentName, state) {
          this.send('studio:inspect-state', { component: componentName, state: state });
        },

        trackWsFrame: function(direction, channel, payload) {
          this.send('studio:ws-frame', { direction: direction, channel: channel, payload: payload });
        },

        isConnected: function() {
          return this.connected && this.socket && this.socket.readyState === 1;
        }
      };

      // Connect DevTools hook to Studio if available
      if (window.__BV_DEVTOOLS_HOOK__) {
        window.__BV_DEVTOOLS_HOOK__.on('*', function(ev) {
          studioBridge.send('studio:devtools-event', ev);
        });
      }

      window.__BV_CORE__.studio = studioBridge;
      window.$studio = studioBridge;
    }
  end;
end;

class procedure TBVStudioClient.Connect(const AUrl: string);
begin
  EnsureBridge;
  FUrl := AUrl;
  asm
    window.$studio.connect(AUrl);
  end;
end;

class procedure TBVStudioClient.Disconnect;
begin
  EnsureBridge;
  asm
    window.$studio.disconnect();
  end;
end;

class procedure TBVStudioClient.SendEvent(const AEventName: string; const APayload: JSValue);
begin
  EnsureBridge;
  asm
    window.$studio.sendEvent(AEventName, APayload);
  end;
end;

class procedure TBVStudioClient.SendLog(const ALevel, AMessage: string; const AData: JSValue);
begin
  EnsureBridge;
  asm
    window.$studio.sendLog(ALevel, AMessage, AData);
  end;
end;

class procedure TBVStudioClient.InspectState(const AComponentName: string; const AState: JSValue);
begin
  EnsureBridge;
  asm
    window.$studio.inspectState(AComponentName, AState);
  end;
end;

class procedure TBVStudioClient.TrackWebSocketFrame(const ADirection, AChannel: string; const APayload: JSValue);
begin
  EnsureBridge;
  asm
    window.$studio.trackWsFrame(ADirection, AChannel, APayload);
  end;
end;

class function TBVStudioClient.IsConnected: Boolean;
begin
  EnsureBridge;
  asm
    return window.$studio.isConnected();
  end;
end;

class function TBVStudioClient.GetUrl: string;
begin
  EnsureBridge;
  asm
    return window.$studio.url;
  end;
end;

class procedure TBVStudioClient.HandleOpen(ev: JSValue);
begin
  FConnected := True;
end;

class procedure TBVStudioClient.HandleClose(ev: JSValue);
begin
  FConnected := False;
end;

class procedure TBVStudioClient.HandleError(ev: JSValue);
begin
  FConnected := False;
end;

class procedure TBVStudioClient.HandleMessage(ev: JSValue);
begin
end;

initialization
  InitStudio;

end.
