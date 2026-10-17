unit uLibBootstrap;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils, BVRouting;

procedure Register_uLibBootstrap;

implementation

procedure Register_uLibBootstrap;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  _styleEl := TJSHTMLElement(document.createElement('style'));
  _styleEl.textContent := '.mt-4 { margin-top: 20px; }   .mb-2 { margin-bottom: 8px; }   .mb-3 { margin-bottom: 12px; }   .mb-4 { margin-bottom: 16px; }   .mb-5 { margin-bottom: 24px; }   .mt-3 { margin-top: 15px; }   .container-fluid { padding: 0 15px; }   .lib-bootstrap-page { background: #f8fafc; padding: 25px; min-height: 100vh; }   .row { display: flex; flex-wrap: wrap; margin-right: -15px; margin-left: -15px; }   .col-4 { flex: 0 0 33.333333%; max-width: 33.333333%; padding: 0 15px; }   .col-8 { flex: 0 0 66.666667%; max-width: 66.666667%; padding: 0 15px; }   .col-6 { flex: 0 0 50%; max-width: 50%; padding: 0 15px; }   .d-flex { display: flex; }   .align-items-end { align-items: flex-end; }   .justify-content-end { justify-content: flex-end; }   .gap-2 { gap: 10px; }   .text-muted { color: #64748b; }   .p-4 { padding: 20px; }   .text-center { text-align: center; }';
  document.head.appendChild(_styleEl);
  comp := TJSObject.new;
  comp['template'] :=
    '  <div class="lib-bootstrap-page">' +
    '    <!-- INTERNAL NAVIGATION (DEMO) -->' +
    '    <bv-navbar brand="BlaiseVue UI">' +
    '       <bv-nav-item href="#/" active="true" label="Home"></bv-nav-item>' +
    '       <bv-nav-item href="#/charts" label="Charts"></bv-nav-item>' +
    '       <bv-nav-item href="#/pro" label="Pro Features"></bv-nav-item>' +
    '       <bv-nav-item href="javascript:void(0)" label="⚙️ Settings" @click="clickNotif(''Global Settings'')"></bv-nav-item>' +
    '    </bv-navbar>' +
    '' +
    '    <!-- CONTENT CONTAINER (USING NATIVE BLAISEUI RESPONSIVE GRID) -->' +
    '    <bv-container fluid="true">' +
    '      <bv-row gutter="md" class="mb-5">' +
    '         <bv-col cols="12" md="7">' +
    '            <h1 class="mb-2">🎨 BlaiseUI Official Kit</h1>' +
    '            <p class="text-muted mb-4">Demonstration of unified reactive components built 100% in Pascal with native responsive grid layout.</p>' +
    '            ' +
    '            <bv-breadcrumb>' +
    '               <bv-breadcrumb-item href="#/">Home</bv-breadcrumb-item>' +
    '               <bv-breadcrumb-item href="#">Components</bv-breadcrumb-item>' +
    '               <bv-breadcrumb-item active="true">BlaiseUI</bv-breadcrumb-item>' +
    '            </bv-breadcrumb>' +
    '         </bv-col>' +
    '         <bv-col cols="12" md="5" class="d-flex align-items-end justify-content-end p-2 gap-2 flex-wrap">' +
    '            <bv-btn label="Open Drawer" variant="secondary" size="lg" @click="showDrawer"></bv-btn>' +
    '            <bv-btn label="Open Modal" variant="primary" size="lg" @click="showModal"></bv-btn>' +
    '            <bv-btn label="Trigger Toast" variant="info" size="lg" @click="clickNotif(''Manual Toast Trigger'')"></bv-btn>' +
    '         </bv-col>' +
    '      </bv-row>' +
    '' +
    '      <bv-row gutter="md">' +
    '         <!-- LEFT COLUMN: Feedback & Status (Responsive: 12 on mobile, 4 on desktop) -->' +
    '         <bv-col cols="12" md="4">' +
    '            <bv-card title="📊 System Status">' +
    '               <div class="mb-3">' +
    '                  <small>Engine Load (Reactivity)</small>' +
    '                  <bv-progress :value="count" variant="success"></bv-progress>' +
    '               </div>' +
    '               <div class="mb-3">' +
    '                  <small>Memory Usage ($Store)</small>' +
    '                  <bv-progress :value="35" variant="info"></bv-progress>' +
    '               </div>' +
    '               <div class="d-flex gap-2">' +
    '                  <bv-btn label="Pulse (Count++)" variant="outline-primary" @click="count = (count + 10) % 105"></bv-btn>' +
    '                  <bv-spinner variant="primary" small="true" v-if="count > 80"></bv-spinner>' +
    '               </div>' +
    '            </bv-card>' +
    '' +
    '            <bv-card title="📋 Notification Center" class="mt-4">' +
    '               <bv-list-group>' +
    '                  <bv-list-group-item badge="5" badgeVariant="danger" @click="clickNotif(''New Emails'')">📨 Inbox Messages</bv-list-group-item>' +
    '                  <bv-list-group-item active="true" @click="clickNotif(''Highlight'')">🌟 Weekly Highlight</bv-list-group-item>' +
    '                  <bv-list-group-item badge="ONLINE" badgeVariant="secondary" @click="clickNotif(''BlaiseUI Kit'')">💎 BlaiseUI v2.0</bv-list-group-item>' +
    '                  <bv-list-group-item @click="clickNotif(''Cloud Sync'')">☁️ Cloud Synchronization</bv-list-group-item>' +
    '               </bv-list-group>' +
    '            </bv-card>' +
    '         </div>' +
    '' +
    '         <!-- RIGHT COLUMN: Tabs / Forms / Navigation (Responsive: 12 on mobile, 8 on desktop) -->' +
    '         <bv-col cols="12" md="8">' +
    '            <bv-card style="height: 100%;">' +
    '               <bv-tabs @change="tabChanged">' +
    '                  <bv-tab id="forms" title="📝 Forms" active="true">' +
    '                     <div class="p-4">' +
    '                        <h4>Input Controls</h4>' +
    '                        <bv-row gutter="md" class="mt-4">' +
    '                           <bv-col cols="12" md="6">' +
    '                              <bv-input label="UI Identifier" b-model="libName" placeholder="Ex: Turbo_Node"></bv-input>' +
    '                              <bv-form-select label="Priority" b-model="category" :options="catOptions"></bv-form-select>' +
    '                           </bv-col>' +
    '                           <bv-col cols="12" md="6">' +
    '                              <bv-input-group label="Operation Cost" prepend="$" append=".00" b-model="count"></bv-input-group>' +
    '                              <bv-input-group label="API Key" append="Regenerate">' +
    '                                 <bv-input b-model="libName" readonly="true"></bv-input>' +
    '                              </bv-input-group>' +
    '                           </bv-col>' +
    '                        </bv-row>' +
    '                        <div class="bui-alert bui-alert-info mt-3" style="border-radius: 8px;">' +
    '                           <strong>Note:</strong> All fields above use <code>b-model</code> linked directly to the reactive Pascal state.' +
    '                        </div>' +
    '                     </div>' +
    '                  </bv-tab>' +
    '' +
    '                  <bv-tab id="nav" title="📍 Pagination">' +
    '                     <div class="p-4 text-center">' +
    '                        <h5 class="mb-4">Atomic Data Navigation</h5>' +
    '                        <bv-pagination :value="currentPage" :total="10" @input="updatePage"></bv-pagination>' +
    '                        <p class="mt-3">Currently viewing segment <strong>#{{ currentPage }}</strong></p>' +
    '                        <bv-alert variant="warning" dismissible="true" class="mt-4">' +
    '                           Attention: Segment 7 contains simulated network instabilities.' +
    '                        </bv-alert>' +
    '                     </div>' +
    '                  </bv-tab>' +
    '' +
    '                  <bv-tab id="extras" title="🔥 Accordions">' +
    '                     <div class="p-4">' +
    '                        <bv-accordion :items="faqItems" initialActiveId="q1"></bv-accordion>' +
    '                     </div>' +
    '                  </bv-tab>' +
    '' +
    '                  <bv-tab id="icons" title="⭐ Icons & Themes">' +
    '                     <div class="p-4">' +
    '                        <h5>Bootstrap Icons & Bootswatch Themes</h5>' +
    '                        <p class="text-muted">Over 1,800+ vector icons powered by <code>blaise-icons</code> and reactive Bootswatch styling.</p>' +
    '                        <div class="d-flex gap-4 align-items-center mb-4 flex-wrap" style="display: flex; gap: 16px; flex-wrap: wrap;">' +
    '                           <div class="d-flex align-items-center gap-2"><bv-icon name="check-circle" size="24" color="#28a745"></bv-icon> <span>check-circle</span></div>' +
    '                           <div class="d-flex align-items-center gap-2"><bv-icon name="star-fill" size="24" color="#ffc107"></bv-icon> <span>star-fill</span></div>' +
    '                           <div class="d-flex align-items-center gap-2"><bv-icon name="heart-fill" size="24" color="#dc3545"></bv-icon> <span>heart-fill</span></div>' +
    '                           <div class="d-flex align-items-center gap-2"><bv-icon name="gear-fill" size="24" color="#6c757d"></bv-icon> <span>gear-fill</span></div>' +
    '                           <div class="d-flex align-items-center gap-2"><bv-icon name="shield-check" size="24" color="#0d6efd"></bv-icon> <span>shield-check</span></div>' +
    '                           <div class="d-flex align-items-center gap-2"><bv-icon name="lightning-charge-fill" size="24" color="#fd7e14"></bv-icon> <span>lightning</span></div>' +
    '                        </div>' +
    '                     </div>' +
    '                  </bv-tab>' +
    '               </bv-tabs>' +
    '            </bv-card>' +
    '         </bv-col>' +
    '      </bv-row>' +
    '    </bv-container>' +
    '' +
    '    <!-- DRAWER: Programmatically triggered via $ref -->' +
    '    <bv-drawer ref="mainDrawer" title="🎨 BlaiseUI Drawer">' +
    '       <p class="mb-3">This is the new <strong>bv-drawer</strong> component! On desktop or mobile it smoothly slides out.</p>' +
    '       <bv-list-group>' +
    '          <bv-list-group-item active="true" @click="clickNotif(''Drawer Menu 1'')">🏠 Dashboard View</bv-list-group-item>' +
    '          <bv-list-group-item @click="clickNotif(''Drawer Menu 2'')">⚙️ Component Config</bv-list-group-item>' +
    '          <bv-list-group-item @click="clickNotif(''Drawer Menu 3'')">📱 Mobile Optimization</bv-list-group-item>' +
    '       </bv-list-group>' +
    '       <div class="mt-4">' +
    '          <bv-btn label="Close Drawer" variant="outline-primary" @click="closeDrawer"></bv-btn>' +
    '       </div>' +
    '    </bv-drawer>' +
    '' +
    '    <!-- OVERLAYS: Programmatically triggered via $ref -->' +
    '    <bv-modal b-ref="mainModal" title="🔥 System Confirmation" okLabel="Process" cancelLabel="Close" @ok="modalConfirm">' +
    '       <p>You are about to process a state update via Pascal.</p>' +
    '       <div class="p-3 bg-light rounded text-center" style="background: #f8fafc; padding: 12px; border-radius: 6px; margin-top: 10px;">' +
    '          <p>Current Values:</p>' +
    '          <bv-badge variant="info">{{ libName }}</bv-badge>' +
    '          <bv-badge variant="success">{{ count }}%</bv-badge>' +
    '       </div>' +
    '    </bv-modal>' +
    '' +
    '    <bv-toast b-ref="mainToast" title="Global Notification" variant="success" :duration="4000">' +
    '       Action performed: <strong>{{ lastAction }}</strong>' +
    '    </bv-toast>' +
    '  </div>';

  comp['data'] := function(): TJSObject
  var d: TJSObject;
  begin
    d := TJSObject.new;
    d['count'] := 45;
    d['libName'] := 'Blaise_Demo_2026';
    d['category'] := 'high';
    d['currentPage'] := 1;
    d['lastAction'] := 'System Ready';
    d['faqItems'] := '';
    d['catOptions'] := '';
    Result := d;
  end;


  m := TJSObject.new;
  m['clickNotif'] := procedure(_this: TJSObject; info: string)

    begin
       asm 
          this.lastAction = info;
          if (this.$refs.mainToast && this.$refs.mainToast.showToast) {
            this.$refs.mainToast.showToast();
          } else if (this.$refs.mainToast && this.$refs.mainToast.show) {
            this.$refs.mainToast.show();
          }
       end;
    end;
    { Opens the modal using the component reference }
    
  m['showModal'] := procedure(_this: TJSObject)

    begin
       asm 
          if (this.$refs.mainModal && this.$refs.mainModal.showModal) {
            this.$refs.mainModal.showModal();
          } else if (this.$refs.mainModal && this.$refs.mainModal.show) {
            this.$refs.mainModal.show();
          }
       end;
    end;
    { Callback executed when the modal OK button is clicked }
    
  m['modalConfirm'] := procedure(_this: TJSObject)

    begin
       asm 
          this.libName = 'SYNC_' + Date.now();
          this.lastAction = 'Modal Confirmed';
          if (this.$refs.mainToast && this.$refs.mainToast.showToast) {
            this.$refs.mainToast.showToast();
          } else if (this.$refs.mainToast && this.$refs.mainToast.show) {
            this.$refs.mainToast.show();
          }
       end;
    end;
    { Updates the current page index from the pagination component }
    
  m['updatePage'] := procedure(_this: TJSObject; p: integer)

    begin
       asm this.currentPage = p; end;
    end;
    
  m['tabChanged'] := procedure(_this: TJSObject; id: string)

    begin
       asm console.log("Tab changed to: ", id); end;
    end;
    
  m['showDrawer'] := procedure(_this: TJSObject)

    begin
       asm 
          if (this.$refs.mainDrawer && this.$refs.mainDrawer.open) {
            this.$refs.mainDrawer.open();
          } else if (this.$refs.mainDrawer && this.$refs.mainDrawer.toggle) {
            this.$refs.mainDrawer.toggle();
          }
       end;
    end;
    
  m['closeDrawer'] := procedure(_this: TJSObject)

    begin
       asm 
          if (this.$refs.mainDrawer && this.$refs.mainDrawer.close) {
            this.$refs.mainDrawer.close();
          }
       end;
    end;

  comp['methods'] := m;

  comp['created'] := procedure(_this: TJSObject)
    begin
       asm
         this.faqItems = [
           { id: 'q1', title: 'How does Shared State work?', content: 'BlaiseVue uses B-Store for centralized reactive state management in Pascal.' },
           { id: 'q2', title: 'Unified Design System?', content: 'BlaiseUI is 100% native Pascal with pure CSS variables and zero external dependencies.' },
           { id: 'q3', title: 'JIT Optimization?', content: 'The compiler generates minimalist JavaScript bundles, resulting in instant load times.' }
         ];
         this.catOptions = [
           { value: 'low', text: 'Low Priority' },
           { value: 'med', text: 'Medium Priority' },
           { value: 'high', text: 'High Priority (Critical)' }
         ];
       end;
    end;

    ;
  RegisterComponent('lib-bootstrap-page', comp);
end;

end.
