unit BVClient;

{
  BVClient - BlaiseVue 3.5 Full-Stack Client for Synopse mORMot 2
  --------------------------------------------------------------
  Provides high-throughput HTTP REST API ($api) and real-time
  bidirectional WebSocket ($ws) client integration for BlaiseVue
  applications connecting to mORMot 2 Pascal backends.

  Features:
  - $api: GET, POST, PUT, DELETE with automatic JSON parsing
  - $api: Bearer Token injection & custom headers
  - $api: Base URL configuration (defaults to http://localhost:8090)
  - $ws: Real-time WebSocket connection to ws://localhost:8090/ws
  - $ws: Event-based pub/sub pub-sub architecture (on, off, emit)
  - $ws: Status tracking ('connecting', 'open', 'closed')
}

{$mode objfpc}

interface

uses JS, Web, SysUtils, BVReactivity;

type
  { REST API Client Helper }
  TBVApi = class
  public
    class procedure EnsureBridge;
    class function Get(const Url: string; Options: JSValue = nil): JSValue;
    class function Post(const Url: string; Body: JSValue; Options: JSValue = nil): JSValue;
    class function Put(const Url: string; Body: JSValue; Options: JSValue = nil): JSValue;
    class function Delete(const Url: string; Options: JSValue = nil): JSValue;
    class procedure SetBaseUrl(const Url: string);
    class procedure SetToken(const Token: string);
    class procedure ClearToken;
    class procedure SetHeader(const Key, Value: string);
  end;

  { Real-time WebSocket Client Helper }
  TBVWebSocket = class
  public
    class procedure EnsureBridge;
    class function Connect(const Url: string = ''): JSValue;
    class function Send(Data: JSValue): Boolean;
    class procedure On(const EventName: string; Callback: JSValue);
    class procedure Off(const EventName: string; Callback: JSValue = nil);
    class procedure Close;
    class function IsConnected: Boolean;
    class function GetStatus: string;
  end;

implementation

{ TBVApi }

class procedure TBVApi.EnsureBridge;
begin
  asm
    if (!window.__BV_CORE__) window.__BV_CORE__ = {};
    if (!window.__BV_CORE__.api) {
      window.__BV_CORE__.api = {
        baseUrl: 'http://localhost:8090',
        token: '',
        headers: {},

        setBaseUrl: function(url) {
          if (!url) return;
          this.baseUrl = String(url).replace(/\/$/, '');
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

        request: function(method, url, body, options) {
          options = options || {};
          var fullUrl = (String(url).indexOf('http://') === 0 || String(url).indexOf('https://') === 0)
            ? url
            : (this.baseUrl + (String(url).indexOf('/') === 0 ? '' : '/') + url);

          var hdrs = Object.assign({
            'Accept': 'application/json'
          }, this.headers, options.headers || {});

          if (this.token) {
            hdrs['Authorization'] = 'Bearer ' + this.token;
          }

          var fetchOpts = {
            method: method,
            headers: hdrs
          };

          if (body !== undefined && body !== null) {
            if (typeof body === 'object' && !(body instanceof FormData) && !(body instanceof Blob)) {
              hdrs['Content-Type'] = 'application/json';
              fetchOpts.body = JSON.stringify(body);
            } else {
              fetchOpts.body = body;
            }
          }

          if (typeof fetch === 'function') {
            return fetch(fullUrl, fetchOpts).then(function(res) {
              var ct = res.headers.get('content-type') || '';
              if (ct.indexOf('application/json') !== -1) {
                return res.json().then(function(data) {
                  if (!res.ok) {
                    var err = new Error(data.message || data.error || ('HTTP ' + res.status));
                    err.status = res.status;
                    err.data = data;
                    throw err;
                  }
                  return data;
                });
              }
              return res.text().then(function(text) {
                if (!res.ok) {
                  var err = new Error(text || ('HTTP ' + res.status));
                  err.status = res.status;
                  throw err;
                }
                return text;
              });
            });
          } else {
            return Promise.reject(new Error('Fetch API is not supported in this browser environment.'));
          }
        },

        get: function(url, options) {
          return this.request('GET', url, null, options);
        },

        post: function(url, body, options) {
          return this.request('POST', url, body, options);
        },

        put: function(url, body, options) {
          return this.request('PUT', url, body, options);
        },

        delete: function(url, options) {
          return this.request('DELETE', url, null, options);
        }
      };
    }
  end;
end;

class function TBVApi.Get(const Url: string; Options: JSValue): JSValue;
begin
  EnsureBridge;
  asm
    Result = window.__BV_CORE__.api.get(Url, Options);
  end;
end;

class function TBVApi.Post(const Url: string; Body: JSValue; Options: JSValue): JSValue;
begin
  EnsureBridge;
  asm
    Result = window.__BV_CORE__.api.post(Url, Body, Options);
  end;
end;

class function TBVApi.Put(const Url: string; Body: JSValue; Options: JSValue): JSValue;
begin
  EnsureBridge;
  asm
    Result = window.__BV_CORE__.api.put(Url, Body, Options);
  end;
end;

class function TBVApi.Delete(const Url: string; Options: JSValue): JSValue;
begin
  EnsureBridge;
  asm
    Result = window.__BV_CORE__.api.delete(Url, Options);
  end;
end;

class procedure TBVApi.SetBaseUrl(const Url: string);
begin
  EnsureBridge;
  asm
    window.__BV_CORE__.api.setBaseUrl(Url);
  end;
end;

class procedure TBVApi.SetToken(const Token: string);
begin
  EnsureBridge;
  asm
    window.__BV_CORE__.api.setToken(Token);
  end;
end;

class procedure TBVApi.ClearToken;
begin
  EnsureBridge;
  asm
    window.__BV_CORE__.api.clearToken();
  end;
end;

class procedure TBVApi.SetHeader(const Key, Value: string);
begin
  EnsureBridge;
  asm
    window.__BV_CORE__.api.setHeader(Key, Value);
  end;
end;

{ TBVWebSocket }

class procedure TBVWebSocket.EnsureBridge;
begin
  asm
    if (!window.__BV_CORE__) window.__BV_CORE__ = {};
    if (!window.__BV_CORE__.ws) {
      window.__BV_CORE__.ws = {
        socket: null,
        listeners: {},
        url: 'ws://localhost:8090/ws',
        status: 'closed',

        connect: function(url) {
          if (url) this.url = url;
          var self = this;
          if (this.socket && (this.socket.readyState === 0 || this.socket.readyState === 1)) {
            return this.socket;
          }
          try {
            this.status = 'connecting';
            this.socket = new WebSocket(this.url);
            this.socket.onopen = function(ev) {
              self.status = 'open';
              self.emit('open', ev);
            };
            this.socket.onmessage = function(ev) {
              var payload = ev.data;
              try { payload = JSON.parse(ev.data); } catch(e) {}
              self.emit('message', payload);
              if (payload && typeof payload === 'object' && payload.event) {
                self.emit(payload.event, payload.data !== undefined ? payload.data : payload);
              }
            };
            this.socket.onerror = function(err) {
              self.emit('error', err);
            };
            this.socket.onclose = function(ev) {
              self.status = 'closed';
              self.emit('close', ev);
            };
          } catch(ex) {
            self.status = 'closed';
            console.warn('[BVClient WS] Connection attempt error:', ex);
          }
          return this.socket;
        },

        send: function(data) {
          if (!this.socket || this.socket.readyState !== 1) {
            console.warn('[BVClient WS] WebSocket is not connected.');
            return false;
          }
          var msg = (typeof data === 'object') ? JSON.stringify(data) : String(data);
          this.socket.send(msg);
          return true;
        },

        on: function(event, callback) {
          if (!this.listeners[event]) this.listeners[event] = [];
          this.listeners[event].push(callback);
        },

        off: function(event, callback) {
          if (!this.listeners[event]) return;
          if (!callback) {
            delete this.listeners[event];
            return;
          }
          this.listeners[event] = this.listeners[event].filter(function(cb) {
            return cb !== callback;
          });
        },

        emit: function(event, data) {
          var cbs = this.listeners[event];
          if (cbs) {
            for (var i = 0; i < cbs.length; i++) {
              try { cbs[i](data); } catch(e) { console.error(e); }
            }
          }
        },

        close: function() {
          if (this.socket) {
            this.socket.close();
          }
          this.status = 'closed';
        },

        isConnected: function() {
          return this.socket && this.socket.readyState === 1;
        }
      };
    }
  end;
end;

class function TBVWebSocket.Connect(const Url: string): JSValue;
begin
  EnsureBridge;
  asm
    Result = window.__BV_CORE__.ws.connect(Url);
  end;
end;

class function TBVWebSocket.Send(Data: JSValue): Boolean;
var
  ResVal: JSValue;
begin
  EnsureBridge;
  asm
    ResVal = window.__BV_CORE__.ws.send(Data);
  end;
  Result := Boolean(ResVal);
end;

class procedure TBVWebSocket.On(const EventName: string; Callback: JSValue);
begin
  EnsureBridge;
  asm
    window.__BV_CORE__.ws.on(EventName, Callback);
  end;
end;

class procedure TBVWebSocket.Off(const EventName: string; Callback: JSValue);
begin
  EnsureBridge;
  asm
    window.__BV_CORE__.ws.off(EventName, Callback);
  end;
end;

class procedure TBVWebSocket.Close;
begin
  EnsureBridge;
  asm
    window.__BV_CORE__.ws.close();
  end;
end;

class function TBVWebSocket.IsConnected: Boolean;
var
  ResVal: JSValue;
begin
  EnsureBridge;
  asm
    ResVal = window.__BV_CORE__.ws.isConnected();
  end;
  Result := Boolean(ResVal);
end;

class function TBVWebSocket.GetStatus: string;
var
  ResVal: JSValue;
begin
  EnsureBridge;
  asm
    ResVal = window.__BV_CORE__.ws.status;
  end;
  Result := String(ResVal);
end;

initialization
  TBVApi.EnsureBridge;
  TBVWebSocket.EnsureBridge;

end.
