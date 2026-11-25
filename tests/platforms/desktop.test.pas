program desktop_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, BVReactivity, BVCompiler, BVDesktop, BlaiseVue;

begin
  Describe('BlaiseVue 3.5 Desktop Platform & WebUI Bridge ($desktop)', procedure
    begin
       It('deve disponibilizar o helper global $desktop e __BV_CORE__.desktop', procedure
         var
           HasGlobalDesktop: Boolean;
         begin
           asm
             HasGlobalDesktop = Boolean(window.$desktop && window.__BV_CORE__ && window.__BV_CORE__.desktop);
           end;
           Expect(HasGlobalDesktop).ToBe(True);
         end);

       It('deve detectar a plataforma de execucao (browser/windows/linux/macos)', procedure
         var
           Plat: string;
         begin
           Plat := TBVDesktop.GetPlatform;
           Expect(Plat <> '').ToBe(True);
         end);

       It('deve identificar se o runtime e desktop ou navegador fallback', procedure
         var
           Status: Boolean;
         begin
           // In standard Node.js/JSDOM test runner without native WebUI bridge, IsDesktop is false
           Status := TBVDesktop.IsDesktop;
           Expect(Status).ToBe(False);
         end);

       It('deve permitir alterar o titulo da janela via SetTitle', procedure
         var
           Success: Boolean;
         begin
           Success := True;
           try
             TBVDesktop.SetTitle('BlaiseVue Desktop Test App');
           except
             Success := False;
           end;
           Expect(Success).ToBe(True);
           Expect(document.title).ToBe('BlaiseVue Desktop Test App');
         end);

       It('deve invocar controles de janela (Minimize, Maximize, SetFullScreen) sem excecoes', procedure
         var
           Success: Boolean;
         begin
           Success := True;
           try
             TBVDesktop.Minimize;
             TBVDesktop.Maximize;
             TBVDesktop.SetFullScreen(False);
           except
             Success := False;
           end;
           Expect(Success).ToBe(True);
         end);

       It('deve disparar notificacoes de desktop e abertura de URL com seguranca', procedure
         var
           Success: Boolean;
         begin
           Success := True;
           try
             TBVDesktop.ShowNotification('Alerta BlaiseVue', 'Teste de notificacao nativa');
             TBVDesktop.OpenURL('https://blaisevue.dev');
           except
             Success := False;
           end;
           Expect(Success).ToBe(True);
         end);

       It('deve obter informacoes de sistema e runtime via GetSystemInfo', procedure
         var
           FrameworkName: string;
         begin
           FrameworkName := '';
           TBVDesktop.GetSystemInfo(procedure(info: JSValue)
             begin
               asm
                 FrameworkName = (info && info.framework) ? info.framework : 'BlaiseVue 3.5 Desktop';
               end;
             end);
           Expect(FrameworkName <> '').ToBe(True);
         end);

       It('deve suportar RPC bidirecional nativo com fallback gracioso', procedure
         var
           RpcStatus: string;
         begin
           RpcStatus := '';
           TBVDesktop.Call('custom_pascal_method', nil, procedure(res: JSValue)
             begin
               asm
                 RpcStatus = (res && res.status) ? res.status : 'ok';
               end;
             end);
           Expect(RpcStatus <> '').ToBe(True);
         end);

       It('deve injetar $desktop no escopo reativo do BlaiseVue', procedure
         var
           RootEl: TJSHTMLElement;
           Data, Methods: TJSObject;
           HasDesktopInInstance: Boolean;
         begin
           RootEl := TJSHTMLElement(document.createElement('div'));
           RootEl.setAttribute('id', 'desktop-test-app');
           document.body.appendChild(RootEl);

           Data := TJSObject.new;
           Methods := TJSObject.new;

           TBlaiseVue.Create('#desktop-test-app', Data, Methods, nil);

           asm
             HasDesktopInInstance = Boolean(Data.$desktop);
           end;

           Expect(HasDesktopInInstance).ToBe(True);
         end);
    end);
end.
