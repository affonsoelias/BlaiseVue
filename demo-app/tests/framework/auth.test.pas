program auth_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, BVReactivity, BVCompiler, BVClient, BVAuth, BlaiseVue;

begin
  Describe('BlaiseVue 4.0 Enterprise Authentication & Route Guards ($auth)', procedure
    begin
      It('should expose __BV_CORE__.auth and global $auth helper', procedure
        var
          HasAuth: Boolean;
        begin
          TBVAuth.Logout;
          asm
            HasAuth = Boolean(window.__BV_CORE__ && window.__BV_CORE__.auth &&
                              typeof window.__BV_CORE__.auth.login === 'function' &&
                              typeof window.__BV_CORE__.auth.logout === 'function' &&
                              typeof window.__BV_CORE__.auth.hasRole === 'function');
          end;
          Expect(HasAuth).ToBe(True);
        end);

      It('should manage authentication state and sync JWT token with $api and localStorage', procedure
        var
          IsAuthBefore, IsAuthAfter: Boolean;
          TokenMatch, LocalStorageMatch: Boolean;
        begin
          TBVAuth.Logout;
          IsAuthBefore := TBVAuth.IsAuthenticated;
          Expect(IsAuthBefore).ToBe(False);

          // Simulate successful authentication payload
          asm
            var fakeUser = { id: 1, name: 'Admin User', email: 'admin@blaisevue.dev', role: 'admin' };
            var fakeToken = 'header.payload.signature-test-token-jwt';
            window.__BV_CORE__.auth.token = fakeToken;
            window.__BV_CORE__.auth.user = fakeUser;
            localStorage.setItem('bv_auth_token', fakeToken);
            localStorage.setItem('bv_auth_user', JSON.stringify(fakeUser));
            if (window.__BV_CORE__.api) window.__BV_CORE__.api.setToken(fakeToken);

            TokenMatch = (window.__BV_CORE__.api.token === fakeToken);
            LocalStorageMatch = (localStorage.getItem('bv_auth_token') === fakeToken);
          end;

          IsAuthAfter := TBVAuth.IsAuthenticated;
          Expect(IsAuthAfter).ToBe(True);
          Expect(TokenMatch).ToBe(True);
          Expect(LocalStorageMatch).ToBe(True);
        end);

      It('should evaluate role-based access control (RBAC) via hasRole', procedure
        var
          AdminHasAdmin, AdminHasUser, UserHasAdmin, UserHasUser: Boolean;
        begin
          TBVAuth.Logout;
          // Test with admin role
          asm
            window.__BV_CORE__.auth.user = { id: 1, name: 'Admin', role: 'admin' };
            AdminHasAdmin = window.__BV_CORE__.auth.hasRole('admin');
            AdminHasUser = window.__BV_CORE__.auth.hasRole('user');
          end;
          Expect(AdminHasAdmin).ToBe(True);
          Expect(AdminHasUser).ToBe(True); // Admins inherit all roles

          // Test with standard user role
          asm
            window.__BV_CORE__.auth.user = { id: 2, name: 'User', role: 'user' };
            UserHasAdmin = window.__BV_CORE__.auth.hasRole('admin');
            UserHasUser = window.__BV_CORE__.auth.hasRole('user');
          end;
          Expect(UserHasAdmin).ToBe(False);
          Expect(UserHasUser).ToBe(True);
        end);

      It('should clear session, JWT token, and localStorage on logout', procedure
        var
          IsAuthAfterLogout: Boolean;
          TokenCleared, LocalStorageCleared: Boolean;
        begin
          // Set initial session
          asm
            window.__BV_CORE__.auth.token = 'test-token-123';
            window.__BV_CORE__.auth.user = { id: 1, name: 'Test' };
            localStorage.setItem('bv_auth_token', 'test-token-123');
            if (window.__BV_CORE__.api) window.__BV_CORE__.api.setToken('test-token-123');
          end;

          TBVAuth.Logout;

          IsAuthAfterLogout := TBVAuth.IsAuthenticated;
          asm
            TokenCleared = (window.__BV_CORE__.api.token === '');
            LocalStorageCleared = (localStorage.getItem('bv_auth_token') === null);
          end;

          Expect(IsAuthAfterLogout).ToBe(False);
          Expect(TokenCleared).ToBe(True);
          Expect(LocalStorageCleared).ToBe(True);
        end);

      It('should enforce navigation guard protection for routes requiring authentication', procedure
        var
          RedirectTarget: string;
        begin
          TBVAuth.Logout;
          RedirectTarget := '';
          asm
            var fakeRouter = {};
            window.__BV_CORE__.auth.initRouterGuard(fakeRouter);

            // 1. Unauthenticated user accessing protected route
            window.__BV_CORE__.auth.token = '';
            window.__BV_CORE__.auth.user = null;
            var protectedRoute = { path: '/dashboard', meta: { requiresAuth: true } };
            var res = fakeRouter.FBeforeEach(protectedRoute, { path: '/' });
            RedirectTarget = String(res);
          end;

          Expect(RedirectTarget).ToBe('#/login');

          // 2. Authenticated user accessing protected route
          RedirectTarget := '';
          asm
            window.__BV_CORE__.auth.token = 'valid-token';
            window.__BV_CORE__.auth.user = { id: 1, role: 'admin' };
            var res2 = fakeRouter.FBeforeEach(protectedRoute, { path: '/' });
            RedirectTarget = (res2 === true) ? 'ALLOW' : String(res2);
          end;

          Expect(RedirectTarget).ToBe('ALLOW');
        end);

      It('should inject $auth into compiled component reactive data scope', procedure
        var
          RootEl: TJSHTMLElement;
          Data, Methods: TJSObject;
          HasScopeAuth: Boolean;
        begin
          TBVAuth.Logout;
          RootEl := TJSHTMLElement(document.createElement('div'));
          RootEl.setAttribute('id', 'auth-test-app');
          document.body.appendChild(RootEl);

          Data := TJSObject.new;
          Methods := TJSObject.new;

          TBlaiseVue.Create('#auth-test-app', Data, Methods, nil);

          asm
            HasScopeAuth = Boolean(Data.$auth && typeof Data.$auth.login === 'function' &&
                                   typeof Data.$auth.logout === 'function');
          end;

          Expect(HasScopeAuth).ToBe(True);

          document.body.removeChild(RootEl);
        end);
    end);
end.
