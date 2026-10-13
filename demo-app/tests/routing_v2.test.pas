program routing_v2_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, BVComponents, BVCompiler, BVRouting;

var
  Router: TBVRouter;
  RouterOpts, R1, R2, R3, R4, R5: TJSObject;
  RoutesList: TJSArray;
  AppRoot, RouterViewEl: TJSHTMLElement;
  HomeComp, UserComp, AdminComp, LoginComp: TJSObject;
  AfterEachCalls: Integer;
  LastAfterRoute: string;

procedure SetupRoutingEnvironment;
begin
  // Registra componentes de teste
  HomeComp := TJSObject.new;
  HomeComp['template'] := '<div class="home-page">Home Page View</div>';
  RegisterComponent('home-page', HomeComp);

  UserComp := TJSObject.new;
  UserComp['template'] := '<div class="user-page">User Profile</div>';
  RegisterComponent('user-page', UserComp);

  AdminComp := TJSObject.new;
  AdminComp['template'] := '<div class="admin-page">Admin Dashboard</div>';
  RegisterComponent('admin-page', AdminComp);

  LoginComp := TJSObject.new;
  LoginComp['template'] := '<div class="login-page">Login Page</div>';
  RegisterComponent('login-page', LoginComp);

  // Cria DOM para montagem do Router
  AppRoot := TJSHTMLElement(document.createElement('div'));
  AppRoot.id := 'test-app-root';
  RouterViewEl := TJSHTMLElement(document.createElement('router-view'));
  AppRoot.appendChild(RouterViewEl);
  document.body.appendChild(AppRoot);

  // Configuracao das rotas
  RoutesList := TJSArray.new;

  R1 := TJSObject.new;
  R1['path'] := '/home';
  R1['component'] := 'home-page';
  RoutesList.push(R1);

  R2 := TJSObject.new;
  R2['path'] := '/users/:id';
  R2['component'] := 'user-page';
  RoutesList.push(R2);

  R3 := TJSObject.new;
  R3['path'] := '/admin';
  R3['component'] := 'admin-page';
  RoutesList.push(R3);

  R4 := TJSObject.new;
  R4['path'] := '/login';
  R4['component'] := 'login-page';
  RoutesList.push(R4);

  R5 := TJSObject.new;
  R5['path'] := '/blocked';
  R5['component'] := 'home-page';
  RoutesList.push(R5);

  AfterEachCalls := 0;
  LastAfterRoute := '';

  RouterOpts := TJSObject.new;
  RouterOpts['mode'] := 'history';
  RouterOpts['routes'] := RoutesList;

  // Global Navigation Guard beforeEach
  RouterOpts['beforeEach'] := function(toR, fromR: JSValue): JSValue
  begin
    asm
      // Redireciona /admin para /login se nao autenticado
      if (toR.path === '/admin') {
        return '/login';
      }
      // Bloqueia /blocked
      if (toR.path === '/blocked') {
        return false;
      }
      return true;
    end;
  end;

  // Global Hook afterEach
  RouterOpts['afterEach'] := procedure(toR, fromR: JSValue)
  begin
    Inc(AfterEachCalls);
    LastAfterRoute := string(TJSObject(toR)['path']);
  end;

  Router := TBVRouter.Create(RouterOpts);
  Router.Install(AppRoot);
end;

begin
  SetupRoutingEnvironment;

  Describe('BlaiseVue 2.0 Advanced Routing (History Mode & Navigation Guards)', procedure
    begin
       It('deve operar em modo HTML5 History', procedure
         begin
            Expect(Router.Mode).ToBe('history');
         end);

       It('deve navegar via History API pushState e atualizar rota atual', procedure
         begin
            Router.Push('/home');
            Expect(Router.CurrentRoute.HashPath).ToBe('/home');
            Expect(Router.CurrentRoute.Name).ToBe('home-page');
            Expect(RouterViewEl.textContent).ToContain('Home Page View');
         end);

       It('deve extrair parametros de rota dinâmicos e query params', procedure
         begin
            Router.Push('/users/99?tab=settings');
            Expect(Router.CurrentRoute.HashPath).ToBe('/users/99');
            Expect(TJSObject(Router.CurrentRoute.Params)['id']).ToBe('99');
            Expect(TJSObject(Router.CurrentRoute.Query)['tab']).ToBe('settings');
         end);

       It('deve interceptar rota protegida via beforeEach guard e redirecionar', procedure
         begin
            Router.Push('/admin');
            // beforeEach deve redirecionar para /login
            Expect(Router.CurrentRoute.HashPath).ToBe('/login');
            Expect(Router.CurrentRoute.Name).ToBe('login-page');
            Expect(RouterViewEl.textContent).ToContain('Login Page');
         end);

       It('deve abortar navegacao quando beforeEach retorna false', procedure
         begin
            // Inicialmente estamos em /login
            Router.Push('/blocked');
            // Nao deve ter mudado para /blocked, continua em /login
            Expect(Router.CurrentRoute.HashPath).ToBe('/login');
         end);

       It('deve disparar hook afterEach apos navegacao bem sucedida', procedure
         begin
            Expect(AfterEachCalls).toBeDefined;
            Router.Push('/home');
            Expect(LastAfterRoute).ToBe('/home');
         end);
    end);
end.
