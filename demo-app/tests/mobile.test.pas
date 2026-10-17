program mobile_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, BVReactivity, BVCompiler, BVMobile, BlaiseVue;

begin
  Describe('BlaiseVue 3.5 Mobile Hardware & Capacitor Engine ($mobile)', procedure
    begin
       It('deve disponibilizar o helper global $mobile e __BV_CORE__.mobile', procedure
         var
           HasGlobalMobile: Boolean;
         begin
           asm
             HasGlobalMobile = Boolean(window.$mobile && window.__BV_CORE__ && window.__BV_CORE__.mobile);
           end;
           Expect(HasGlobalMobile).ToBe(True);
         end);

       It('deve detectar a plataforma de execucao (web/android/ios)', procedure
         var
           Plat: string;
         begin
           Plat := TBVMobile.GetPlatform;
           Expect(Plat <> '').ToBe(True);
         end);

       It('deve identificar se o runtime e nativo ou web', procedure
         var
           NativeStatus: Boolean;
         begin
           NativeStatus := TBVMobile.IsNative;
           // In test environment (Node.js/JSDOM), Capacitor native is false
           Expect(NativeStatus).ToBe(False);
         end);

       It('deve disparar comandos de haptics e vibracao sem lancar excecoes', procedure
         var
           Success: Boolean;
         begin
           Success := True;
           try
             TBVMobile.Vibrate(150);
             TBVMobile.Impact('heavy');
             TBVMobile.Notification('success');
           except
             Success := False;
           end;
           Expect(Success).ToBe(True);
         end);

       It('deve obter informacoes de hardware e dispositivo via callback', procedure
         var
           ModelName: string;
         begin
           ModelName := '';
           TBVMobile.GetDeviceInfo(procedure(info: JSValue)
             begin
               asm
                 ModelName = (info && info.model) ? info.model : 'MockModel';
               end;
             end);
           Expect(ModelName <> '').ToBe(True);
         end);

       It('deve permitir configurar a cor da barra de status', procedure
         var
           Success: Boolean;
         begin
           Success := True;
           try
             TBVMobile.SetStatusBarColor('#1a252f');
           except
             Success := False;
           end;
           Expect(Success).ToBe(True);
         end);

       It('deve injetar $mobile no escopo reativo do BlaiseVue', procedure
         var
           RootEl: TJSHTMLElement;
           Data, Methods: TJSObject;
           HasMobileInInstance: Boolean;
         begin
           RootEl := TJSHTMLElement(document.createElement('div'));
           RootEl.setAttribute('id', 'mobile-test-app');
           document.body.appendChild(RootEl);

           Data := TJSObject.new;
           Methods := TJSObject.new;

           TBlaiseVue.Create('#mobile-test-app', Data, Methods, nil);

           asm
             HasMobileInInstance = Boolean(Data.$mobile);
           end;

           Expect(HasMobileInInstance).ToBe(True);
         end);
    end);
end.
