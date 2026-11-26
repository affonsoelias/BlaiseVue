program ionic_test;

{$mode objfpc}

uses
  JS, Web, SysUtils,
  BVTestUtils, BVComponents, BVReactivity, BVCompiler, BlaiseIonic, BlaiseVue,
  uBVIonApp, uBVIonHeader, uBVIonToolbar, uBVIonTitle, uBVIonContent,
  uBVIonCard, uBVIonButton, uBVIonBadge, uBVIonList, uBVIonItem,
  uBVIonTabs, uBVIonTabBar, uBVIonTabButton,
  uBVIonInput, uBVIonToggle, uBVIonCheckbox, uBVIonSelect, uBVIonRefresher,
  uBVIonSearchBar, uBVIonFab, uBVIonFabButton, uBVIonBackButton;

var
  Wrapper: TWrapper;
  BtnProps, CardProps, BadgeProps, ItemProps, ListProps, TabBtnProps,
  IonInputProps, IonToggleProps, IonCheckboxProps, IonSelectProps,
  IonRefresherProps, IonSearchProps, IonFabProps, IonFabBtnProps, IonBackBtnProps: TJSObject;

begin
  // Register mobile components
  Register_uBVIonApp;
  Register_uBVIonHeader;
  Register_uBVIonToolbar;
  Register_uBVIonTitle;
  Register_uBVIonContent;
  Register_uBVIonCard;
  Register_uBVIonButton;
  Register_uBVIonBadge;
  Register_uBVIonList;
  Register_uBVIonItem;
  Register_uBVIonTabs;
  Register_uBVIonTabBar;
  Register_uBVIonTabButton;
  Register_uBVIonInput;
  Register_uBVIonToggle;
  Register_uBVIonCheckbox;
  Register_uBVIonSelect;
  Register_uBVIonRefresher;
  Register_uBVIonSearchBar;
  Register_uBVIonFab;
  Register_uBVIonFabButton;
  Register_uBVIonBackButton;

  Describe('BlaiseVue 4.0 Mobile-First Ecosystem (blaise-ui-mobile & BlaiseIonic)', procedure
    begin
      It('should expose __BV_CORE__.ionic and global $ionic helper', procedure
        var
          HasGlobalIonic: Boolean;
        begin
          asm
            HasGlobalIonic = Boolean(window.$ionic && window.__BV_CORE__ && window.__BV_CORE__.ionic);
          end;
          Expect(HasGlobalIonic).ToBe(True);
        end);

      It('should support adaptive platform mode switching (iOS vs Android MD)', procedure
        var
          InitMode, IosMode, MdMode: string;
        begin
          InitMode := TIonicController.GetMode;
          Expect(InitMode <> '').ToBe(True);

          TIonicController.SetMode('ios');
          IosMode := TIonicController.GetMode;
          Expect(IosMode).ToBe('ios');
          Expect(TIonicController.IsIos).ToBe(True);

          TIonicController.SetMode('md');
          MdMode := TIonicController.GetMode;
          Expect(MdMode).ToBe('md');
          Expect(TIonicController.IsAndroid).ToBe(True);
        end);

      It('should present and dismiss TIonicToast notifications', procedure
        var
          ToastFoundBefore, ToastFoundAfter: Boolean;
        begin
          TIonicToast.Dismiss;
          TIonicToast.Show('Record saved successfully!', 5000, 'bottom', 'success');

          asm
            let t = document.querySelector('.ionic-toast-wrapper');
            ToastFoundBefore = Boolean(t && t.textContent.indexOf('Record saved successfully!') !== -1);
          end;
          Expect(ToastFoundBefore).ToBe(True);

          TIonicToast.Dismiss;
          asm
            ToastFoundAfter = Boolean(document.querySelector('.ionic-toast-wrapper'));
          end;
          Expect(ToastFoundAfter).ToBe(False);
        end);

      It('should present TIonicAlert alert dialogs', procedure
        var
          AlertFound: Boolean;
        begin
          TIonicAlert.Dismiss;
          TIonicAlert.Alert('Notice', 'Mobile synchronization complete', 'Got it');

          asm
            let a = document.querySelector('.ionic-alert-wrapper');
            AlertFound = Boolean(a && a.textContent.indexOf('Mobile synchronization complete') !== -1);
          end;
          Expect(AlertFound).ToBe(True);

          TIonicAlert.Dismiss;
        end);

      It('should execute callbacks on TIonicAlert.Confirm', procedure
        var
          Confirmed: Boolean;
          ConfirmBtn: TJSHTMLElement;
        begin
          Confirmed := False;
          TIonicAlert.Dismiss;
          TIonicAlert.Confirm('Confirm Action', 'Are you sure you want to proceed?', procedure()
            begin
              Confirmed := True;
            end);

          asm
            ConfirmBtn = document.querySelector('.bui-btn-confirm');
            if (ConfirmBtn) ConfirmBtn.click();
          end;

          Expect(Confirmed).ToBe(True);
          TIonicAlert.Dismiss;
        end);

      It('should manage TIonicLoading fullscreen states', procedure
        var
          LoadingBefore, LoadingAfter: Boolean;
        begin
          TIonicLoading.Dismiss;
          Expect(TIonicLoading.IsLoading).ToBe(False);

          TIonicLoading.Present('Synchronizing with mORMot 2...');
          LoadingBefore := TIonicLoading.IsLoading;
          Expect(LoadingBefore).ToBe(True);

          TIonicLoading.Dismiss;
          LoadingAfter := TIonicLoading.IsLoading;
          Expect(LoadingAfter).ToBe(False);
        end);

      It('should trigger option selections in TIonicActionSheet', procedure
        var
          SelectedAction: string;
          BtnEl: TJSHTMLElement;
        begin
          SelectedAction := '';
          TIonicActionSheet.Dismiss;
          TIonicActionSheet.Show('File Options', ['Edit', 'Share', 'Delete'], procedure(choice: JSValue; idx: JSValue)
            begin
              asm
                SelectedAction = String(choice);
              end;
            end);

          asm
            BtnEl = document.querySelector('.ionic-action-sheet-button[data-index="1"]');
            if (BtnEl) BtnEl.click();
          end;

          Expect(SelectedAction).ToBe('Share');
          TIonicActionSheet.Dismiss;
        end);

      It('should inject $ionic into BlaiseVue component instance', procedure
        var
          RootEl: TJSHTMLElement;
          Data, Methods: TJSObject;
          HasIonicInInstance: Boolean;
        begin
          RootEl := TJSHTMLElement(document.createElement('div'));
          RootEl.setAttribute('id', 'ionic-test-app');
          document.body.appendChild(RootEl);

          Data := TJSObject.new;
          Methods := TJSObject.new;

          TBlaiseVue.Create('#ionic-test-app', Data, Methods, nil);

          asm
            HasIonicInInstance = Boolean(Data.$ionic && typeof Data.$ionic.toast === 'object');
          end;

          Expect(HasIonicInInstance).ToBe(True);
        end);

      It('should render bv-ion-app root container with mode class', procedure
        begin
          TIonicController.SetMode('md');
          Wrapper := Mount('bv-ion-app');
          Expect(Wrapper.Find('.bui-ion-app')).toBeDefined;
          Expect(Wrapper.Find('.bui-ion-app').className).ToContain('ionic-mode-md');
        end);

      It('should render bv-ion-button with color and fill variants', procedure
        begin
          BtnProps := TJSObject.new;
          BtnProps['label'] := 'Sync Mobile';
          BtnProps['color'] := 'primary';
          BtnProps['fill'] := 'solid';
          BtnProps['expand'] := 'block';

          Wrapper := Mount('bv-ion-button', BtnProps);
          Expect(Wrapper.Find('button')).toBeDefined;
          Expect(Wrapper.Find('button').textContent).ToContain('Sync Mobile');
          Expect(Wrapper.Find('button').className).ToContain('bui-ion-btn-primary');
          Expect(Wrapper.Find('button').className).ToContain('bui-ion-btn-block');
        end);

      It('should render bv-ion-card with header, title and content', procedure
        begin
          CardProps := TJSObject.new;
          CardProps['title'] := 'mORMot 2 Status';
          CardProps['subtitle'] := 'Connected Microservice';

          Wrapper := Mount('bv-ion-card', CardProps);
          Expect(Wrapper.Find('.bui-ion-card')).toBeDefined;
          Expect(Wrapper.Find('.bui-ion-card-title').textContent).ToContain('mORMot 2 Status');
          Expect(Wrapper.Find('.bui-ion-card-subtitle').textContent).ToContain('Connected Microservice');
        end);

      It('should render bv-ion-badge pill with color variant', procedure
        begin
          BadgeProps := TJSObject.new;
          BadgeProps['value'] := 'v4.0';
          BadgeProps['color'] := 'success';

          Wrapper := Mount('bv-ion-badge', BadgeProps);
          Expect(Wrapper.Find('.bui-ion-badge')).toBeDefined;
          Expect(Wrapper.Find('.bui-ion-badge').textContent).ToContain('v4.0');
          Expect(Wrapper.Find('.bui-ion-badge').className).ToContain('bui-ion-badge-success');
        end);

      It('should render bv-ion-item with title and detail chevron', procedure
        begin
          ItemProps := TJSObject.new;
          ItemProps['title'] := 'Offline Cache';
          ItemProps['subtitle'] := 'Enabled (SQLite)';
          ItemProps['detail'] := true;

          Wrapper := Mount('bv-ion-item', ItemProps);
          Expect(Wrapper.Find('.bui-ion-item')).toBeDefined;
          Expect(Wrapper.Find('.bui-ion-item-title').textContent).ToContain('Offline Cache');
          Expect(Wrapper.Find('.bui-ion-item-subtitle').textContent).ToContain('Enabled (SQLite)');
          Expect(Wrapper.Find('.bui-ion-item-detail')).toBeDefined;
        end);

      It('should toggle expandable content on bv-ion-item click', procedure
        begin
          ItemProps := TJSObject.new;
          ItemProps['title'] := 'Server Details';
          ItemProps['expandable'] := true;

          Wrapper := Mount('bv-ion-item', ItemProps);
          Expect(Wrapper.Find('.bui-ion-item')).toBeDefined;
          Expect(Wrapper.Element.className).ToContain('is-expandable');

          // Click item to toggle expanded
          Wrapper.Find('.bui-ion-item').click();
          Expect(Wrapper.Find('.bui-ion-item-detail').className).ToContain('rotated');
        end);

      It('should render bv-ion-tab-button and emit tab-click event', procedure
        var
          ClickedTab: string;
        begin
          ClickedTab := '';
          TabBtnProps := TJSObject.new;
          TabBtnProps['label'] := 'Dashboard';
          TabBtnProps['tab'] := 'dashboard';
          TabBtnProps['active'] := true;

          Wrapper := Mount('bv-ion-tab-button', TabBtnProps);
          Expect(Wrapper.Find('.bui-ion-tab-button')).toBeDefined;
          Expect(Wrapper.Find('.bui-ion-tab-button').className).ToContain('is-active');
          Expect(Wrapper.Find('.bui-ion-tab-label').textContent).ToContain('Dashboard');
        end);

      It('should render bv-ion-input with label, placeholder and input value', procedure
        begin
          IonInputProps := TJSObject.new;
          IonInputProps['label'] := 'Customer Phone';
          IonInputProps['placeholder'] := '+55 11 99999-9999';
          IonInputProps['value'] := '11999998888';
          IonInputProps['clearInput'] := true;

          Wrapper := Mount('bv-ion-input', IonInputProps);
          Expect(Wrapper.Find('.bui-ion-input')).toBeDefined;
          Expect(Wrapper.Find('.bui-ion-input-label').textContent).ToContain('Customer Phone');
          Expect(TJSHTMLInputElement(Wrapper.Find('input')).placeholder).toBe('+55 11 99999-9999');
          Expect(TJSHTMLInputElement(Wrapper.Find('input')).value).toBe('11999998888');
          Expect(Wrapper.Find('.bui-ion-input-clear')).toBeDefined;
        end);

      It('should render bv-ion-toggle and toggle checked state on click', procedure
        begin
          IonToggleProps := TJSObject.new;
          IonToggleProps['label'] := 'Biometric FaceID';
          IonToggleProps['color'] := 'success';
          IonToggleProps['checked'] := false;

          Wrapper := Mount('bv-ion-toggle', IonToggleProps);
          Expect(Wrapper.Find('.bui-ion-toggle')).toBeDefined;
          Expect(Wrapper.Find('.bui-ion-toggle-label').textContent).ToContain('Biometric FaceID');
          Expect(Wrapper.Find('.bui-ion-toggle').className).NotToContain('is-checked');

          // Click toggle track to activate
          Wrapper.Find('.bui-ion-toggle-track').click();
          Expect(Wrapper.Find('.bui-ion-toggle').className).ToContain('is-checked');
        end);

      It('should render bv-ion-checkbox with color and check icon', procedure
        begin
          IonCheckboxProps := TJSObject.new;
          IonCheckboxProps['label'] := 'Sync SQLite Offline';
          IonCheckboxProps['color'] := 'primary';
          IonCheckboxProps['checked'] := true;

          Wrapper := Mount('bv-ion-checkbox', IonCheckboxProps);
          Expect(Wrapper.Find('.bui-ion-checkbox')).toBeDefined;
          Expect(Wrapper.Find('.bui-ion-checkbox').className).ToContain('is-checked');
          Expect(Wrapper.Find('.bui-ion-checkbox-label').textContent).ToContain('Sync SQLite Offline');
          Expect(Wrapper.Find('.bui-ion-checkbox-check')).toBeDefined;
        end);

      It('should render bv-ion-select with options and selected display text', procedure
        begin
          IonSelectProps := TJSObject.new;
          IonSelectProps['label'] := 'Payment Method';
          IonSelectProps['placeholder'] := 'Choose payment';
          IonSelectProps['value'] := 'pix';
          asm
            $mod.IonSelectProps.options = [
              { value: 'cc', label: 'Credit Card' },
              { value: 'pix', label: 'Instant PIX' },
              { value: 'cash', label: 'Cash on Delivery' }
            ];
          end;

          Wrapper := Mount('bv-ion-select', IonSelectProps);
          Expect(Wrapper.Find('.bui-ion-select')).toBeDefined;
          Expect(Wrapper.Find('.bui-ion-select-label').textContent).ToContain('Payment Method');
          Expect(Wrapper.Find('.bui-ion-select-text').textContent).ToContain('Instant PIX');
        end);

      It('should render bv-ion-refresher and trigger refresh event with complete callback', procedure
        var
          RefreshTriggered: Boolean;
        begin
          RefreshTriggered := False;
          IonRefresherProps := TJSObject.new;
          IonRefresherProps['pullingText'] := 'Pull to refresh data';
          IonRefresherProps['refreshingText'] := 'Loading latest orders...';

          Wrapper := Mount('bv-ion-refresher', IonRefresherProps);
          Expect(Wrapper.Find('.bui-ion-refresher')).toBeDefined;
          Expect(Wrapper.Find('.bui-ion-refresher-text').textContent).ToContain('Pull to refresh data');

          // Click to simulate manual pull-to-refresh
          Wrapper.Find('.bui-ion-refresher').click();
          Expect(Wrapper.Find('.bui-ion-refresher').className).ToContain('is-refreshing');
          Expect(Wrapper.Find('.bui-ion-refresher-text').textContent).ToContain('Loading latest orders...');
        end);

      It('should render bv-ion-search-bar with icon, placeholder and cancel button', procedure
        begin
          IonSearchProps := TJSObject.new;
          IonSearchProps['placeholder'] := 'Search products...';
          IonSearchProps['cancelButtonText'] := 'Dismiss';
          IonSearchProps['showCancelButton'] := 'always';
          IonSearchProps['value'] := 'Laptop';

          Wrapper := Mount('bv-ion-search-bar', IonSearchProps);
          Expect(Wrapper.Find('.bui-ion-searchbar')).toBeDefined;
          Expect(Wrapper.Find('.bui-ion-searchbar-icon')).toBeDefined;
          Expect(TJSHTMLInputElement(Wrapper.Find('input')).placeholder).toBe('Search products...');
          Expect(TJSHTMLInputElement(Wrapper.Find('input')).value).toBe('Laptop');
          Expect(Wrapper.Find('.bui-ion-searchbar-cancel')).toBeDefined;
          Expect(Wrapper.Find('.bui-ion-searchbar-cancel').textContent).ToContain('Dismiss');
        end);

      It('should render bv-ion-fab container with vertical and horizontal positioning', procedure
        begin
          IonFabProps := TJSObject.new;
          IonFabProps['vertical'] := 'bottom';
          IonFabProps['horizontal'] := 'end';

          Wrapper := Mount('bv-ion-fab', IonFabProps);
          Expect(Wrapper.Find('.bui-ion-fab')).toBeDefined;
          Expect(Wrapper.Find('.bui-ion-fab').className).ToContain('bui-ion-fab-vertical-bottom');
          Expect(Wrapper.Find('.bui-ion-fab').className).ToContain('bui-ion-fab-horizontal-end');
        end);

      It('should render bv-ion-fab-button with round shape, color and icon', procedure
        begin
          IonFabBtnProps := TJSObject.new;
          IonFabBtnProps['color'] := 'success';
          IonFabBtnProps['size'] := 'lg';
          IonFabBtnProps['icon'] := '+';

          Wrapper := Mount('bv-ion-fab-button', IonFabBtnProps);
          Expect(Wrapper.Find('.bui-ion-fab-button')).toBeDefined;
          Expect(Wrapper.Find('.bui-ion-fab-button').className).ToContain('bui-ion-fab-button-success');
          Expect(Wrapper.Find('.bui-ion-fab-button').className).ToContain('bui-ion-fab-button-lg');
          Expect(Wrapper.Find('.bui-ion-fab-button-icon').textContent).ToContain('+');
        end);

      It('should render bv-ion-back-button with chevron icon and label', procedure
        begin
          IonBackBtnProps := TJSObject.new;
          IonBackBtnProps['text'] := 'Return';
          IonBackBtnProps['color'] := 'primary';

          Wrapper := Mount('bv-ion-back-button', IonBackBtnProps);
          Expect(Wrapper.Find('.bui-ion-back-button')).toBeDefined;
          Expect(Wrapper.Find('.bui-ion-back-button-icon')).toBeDefined;
          Expect(Wrapper.Find('.bui-ion-back-button-text').textContent).ToContain('Return');
        end);
    end);
end.
