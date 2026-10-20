unit BVAuth;

{
  BVAuth - BlaiseVue 4.0 Enterprise Authentication & Session Manager
  -------------------------------------------------------------------
  Provides out-of-the-box JWT authentication, reactive session handling ($auth),
  role-based access control (RBAC), and route guard protection for BlaiseVue apps.

  Features:
  - $auth.login(email, password): authenticates against mORMot 2 /api/auth/login
  - $auth.logout(): clears session, flushes token, and redirects to #/login
  - $auth.user: reactive user profile (id, name, email, role, etc.)
  - $auth.token: persistent JWT token in localStorage
  - $auth.isAuthenticated: boolean flag indicating active session
  - $auth.hasRole(role): checks if current user possesses role or admin privileges
  - Route Guard: protects routes marked with requiresAuth: true and roles: [...]
}

{$mode objfpc}

interface

uses JS, Web, SysUtils, BVReactivity, BVClient;

type
  { Global Authentication Helper }
  TBVAuth = class
  public
    class procedure EnsureBridge;
    class function Login(const Email, Password: string): JSValue;
    class procedure Logout;
    class function GetUser: JSValue;
    class function GetToken: string;
    class function IsAuthenticated: Boolean;
    class function HasRole(const RoleName: string): Boolean;
    class function FetchMe: JSValue;
    class procedure InitRouterGuard(Router: JSValue);
  end;

implementation

{ TBVAuth }

class procedure TBVAuth.EnsureBridge;
begin
  asm
    if (!window.__BV_CORE__) window.__BV_CORE__ = {};
    if (!window.__BV_CORE__.auth) {
      let savedToken = '';
      let savedUser = null;
      try {
        savedToken = localStorage.getItem('bv_auth_token') || '';
        let uStr = localStorage.getItem('bv_auth_user');
        if (uStr) savedUser = JSON.parse(uStr);
      } catch(e) {}

      // If token exists, sync with $api immediately
      if (savedToken && window.__BV_CORE__.api) {
        window.__BV_CORE__.api.setToken(savedToken);
      }

      window.__BV_CORE__.auth = {
        token: savedToken,
        user: savedUser,
        redirectAfterLogin: '',
        onAuthChange: null,

        get isAuthenticated() {
          return Boolean(this.token && this.user);
        },

        login: function(email, password) {
          let self = this;
          let p = (window.__BV_CORE__.api && typeof window.__BV_CORE__.api.post === 'function')
            ? window.__BV_CORE__.api.post('/api/auth/login', { email: email, password: password })
            : fetch('http://localhost:8090/api/auth/login', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ email: email, password: password })
              }).then(function(r) { return r.json(); });

          return Promise.resolve(p).then(function(resp) {
            if (resp && (resp.success || resp.token)) {
              self.token = resp.token;
              self.user = resp.user || { email: email, name: email.split('@')[0], role: 'user' };
              try {
                localStorage.setItem('bv_auth_token', self.token);
                localStorage.setItem('bv_auth_user', JSON.stringify(self.user));
              } catch(e) {}

              if (window.__BV_CORE__.api) {
                window.__BV_CORE__.api.setToken(self.token);
              }
              if (typeof self.onAuthChange === 'function') {
                self.onAuthChange(self.user, self.token);
              }
              return resp;
            } else {
              let errMsg = (resp && (resp.error || resp.message)) || 'Invalid credentials';
              throw new Error(errMsg);
            }
          });
        },

        logout: function() {
          let self = this;
          if (this.token && window.__BV_CORE__.api) {
            try {
              let p = window.__BV_CORE__.api.post('/api/auth/logout', {});
              if (p && typeof p.catch === 'function') p.catch(function(){});
            } catch(e) {}
          }
          this.token = '';
          this.user = null;
          try {
            localStorage.removeItem('bv_auth_token');
            localStorage.removeItem('bv_auth_user');
          } catch(e) {}

          if (window.__BV_CORE__.api) {
            window.__BV_CORE__.api.clearToken();
          }
          if (typeof this.onAuthChange === 'function') {
            this.onAuthChange(null, '');
          }
          if (typeof window !== 'undefined' && window.location && window.location.hash !== '#/login') {
            window.location.hash = '#/login';
          }
        },

        hasRole: function(role) {
          if (!this.user) return false;
          let uRole = String(this.user.role || '').toLowerCase();
          let targetRole = String(role || '').toLowerCase();
          if (uRole === 'admin') return true; // Admins inherit all privileges
          if (uRole === targetRole) return true;
          if (Array.isArray(this.user.roles)) {
            return this.user.roles.some(function(r) { return String(r).toLowerCase() === targetRole; });
          }
          return false;
        },

        fetchMe: function() {
          let self = this;
          if (!this.token) return Promise.resolve(null);
          let p = (window.__BV_CORE__.api && typeof window.__BV_CORE__.api.get === 'function')
            ? window.__BV_CORE__.api.get('/api/auth/me')
            : fetch('http://localhost:8090/api/auth/me', {
                headers: { 'Authorization': 'Bearer ' + this.token }
              }).then(function(r) { return r.json(); });

          return Promise.resolve(p).then(function(resp) {
            if (resp && (resp.user || resp.id)) {
              self.user = resp.user || resp;
              try { localStorage.setItem('bv_auth_user', JSON.stringify(self.user)); } catch(e) {}
              return self.user;
            }
            return null;
          }).catch(function(err) {
            console.warn('[BVAuth] fetchMe failed:', err);
            return null;
          });
        },

        initRouterGuard: function(router) {
          let self = this;
          if (!router) return;
          router.FBeforeEach = function(to, from) {
            let meta = to.meta || {};
            // Check requiresAuth
            if (meta.requiresAuth && !self.isAuthenticated) {
              console.log('[BVAuth Guard] Route ' + to.path + ' requires authentication. Redirecting to #/login');
              self.redirectAfterLogin = to.fullPath || to.path;
              return '#/login';
            }
            // Check roles
            if (meta.roles && Array.isArray(meta.roles) && meta.roles.length > 0) {
              let hasAny = meta.roles.some(function(r) { return self.hasRole(r); });
              if (!hasAny) {
                console.warn('[BVAuth Guard] Access denied to ' + to.path + ' for user role: ' + (self.user ? self.user.role : 'guest'));
                return '#/'; // Redirect to home
              }
            }
            // If already authenticated and going to /login, redirect to home
            if (to.path === '/login' && self.isAuthenticated) {
              return '#/';
            }
            return true;
          };
        }
      };
    }
  end;
end;

class function TBVAuth.Login(const Email, Password: string): JSValue;
begin
  EnsureBridge;
  asm
    Result = window.__BV_CORE__.auth.login(Email, Password);
  end;
end;

class procedure TBVAuth.Logout;
begin
  EnsureBridge;
  asm
    window.__BV_CORE__.auth.logout();
  end;
end;

class function TBVAuth.GetUser: JSValue;
begin
  EnsureBridge;
  asm
    Result = window.__BV_CORE__.auth.user;
  end;
end;

class function TBVAuth.GetToken: string;
begin
  EnsureBridge;
  asm
    Result = window.__BV_CORE__.auth.token || '';
  end;
end;

class function TBVAuth.IsAuthenticated: Boolean;
begin
  EnsureBridge;
  asm
    Result = Boolean(window.__BV_CORE__.auth.isAuthenticated);
  end;
end;

class function TBVAuth.HasRole(const RoleName: string): Boolean;
begin
  EnsureBridge;
  asm
    Result = Boolean(window.__BV_CORE__.auth.hasRole(RoleName));
  end;
end;

class function TBVAuth.FetchMe: JSValue;
begin
  EnsureBridge;
  asm
    Result = window.__BV_CORE__.auth.fetchMe();
  end;
end;

class procedure TBVAuth.InitRouterGuard(Router: JSValue);
begin
  EnsureBridge;
  asm
    window.__BV_CORE__.auth.initRouterGuard(Router);
  end;
end;

initialization
  TBVAuth.EnsureBridge;

end.
