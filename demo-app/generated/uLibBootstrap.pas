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
  _styleEl.textContent := '.mt-4 { margin-top: 20px; }   .mb-2 { margin-bottom: 8px; }   .mt-3 { margin-top: 15px; }   .container-fluid { padding: 0 15px; }   .lib-bootstrap-page { background: #f8fafc; padding: 25px; min-height: 100vh; }   .navbar-dark { background: #1e293b; }   .row { display: flex; flex-wrap: wrap; margin-right: -15px; margin-left: -15px; }   .col-4 { flex: 0 0 33.333333%; max-width: 33.333333%; padding: 0 15px; }   .col-8 { flex: 0 0 66.666667%; max-width: 66.666667%; padding: 0 15px; }   .col-6 { flex: 0 0 50%; max-width: 50%; padding: 0 15px; }   .gap-2 { gap: 10px; }';
  document.head.appendChild(_styleEl);
  comp := TJSObject.new;
  comp['template'] :=
    '  <div class="lib-bootstrap-page">' +
    '    <!-- INTERNAL NAVIGATION (DEMO) -->' +
    '    <b-navbar brand="BlaiseVue UI" variant="dark" sticky="true" style="margin-bottom: 25px; border-radius: 8px;">' +
    '       <b-nav-item href="#/" active="true">Home</b-nav-item>' +
    '       <b-nav-item href="#/charts">Charts</b-nav-item>' +
    '       <b-nav-item href="#/pro">Pro Features</b-nav-item>' +
    '       <b-nav-item href="#" @click="clickNotif(''Global Settings'')">⚙️ Settings</b-nav-item>' +
    '    </b-navbar>' +
    '' +
    '    <!-- CONTENT CONTAINER -->' +
    '    <div class="container-fluid p-0">' +
    '      <div class="row mb-5">' +
    '         <div class="col-8">' +
    '            <h1 class="mb-2">🚀 BlaiseVue Pro UI Kit</h1>' +
    '            <p class="text-muted mb-4">Demonstration of 45+ reactive components built 100% in Pascal.</p>' +
    '            ' +
    '            <b-breadcrumb>' +
    '               <b-breadcrumb-item href="#/">Home</b-breadcrumb-item>' +
    '               <b-breadcrumb-item href="#">Components</b-breadcrumb-item>' +
    '               <b-breadcrumb-item active="true">Bootstrap-BV</b-breadcrumb-item>' +
    '            </b-breadcrumb>' +
    '         </div>' +
    '         <div class="col-4 d-flex align-items-end justify-content-end p-2 gap-2">' +
    '            <b-btn label="Open Modal" variant="primary" size="lg" @click="showModal"></b-btn>' +
    '            <b-btn label="Trigger Toast" variant="info" size="lg" @click="clickNotif(''Manual Toast Trigger'')"></b-btn>' +
    '         </div>' +
    '      </div>' +
    '' +
    '      <div class="row">' +
    '         <!-- LEFT COLUMN: Feedback & Status -->' +
    '         <div class="col-4">' +
    '            <b-card title="📊 System Status">' +
    '               <div class="mb-3">' +
    '                  <small>Engine Load (Reactivity)</small>' +
    '                  <b-progress :value="count" variant="success" animated="true"></b-progress>' +
    '               </div>' +
    '               <div class="mb-3">' +
    '                  <small>Memory Usage ($Store)</small>' +
    '                  <b-progress :value="35" variant="info"></b-progress>' +
    '               </div>' +
    '               <div class="d-flex gap-2">' +
    '                  <b-btn label="Pulse (Count++)" variant="outline-primary" @click="count = (count + 10) % 105"></b-btn>' +
    '                  <b-spinner variant="primary" small="true" v-if="count > 80"></b-spinner>' +
    '               </div>' +
    '            </b-card>' +
    '' +
    '            <b-card title="📋 Notification Center" class="mt-4">' +
    '               <b-list-group>' +
    '                  <b-list-group-item badge="5" badgeVariant="danger" @click="clickNotif(''New Emails'')">📨 Inbox Messages</b-list-group-item>' +
    '                  <b-list-group-item active="true" @click="clickNotif(''Highlight'')">🌟 Weekly Highlight</b-list-group-item>' +
    '                  <b-list-group-item badge="OFFLINE" badgeVariant="secondary" @click="clickNotif(''Legacy Sys'')">💾 Legacy v1.0</b-list-group-item>' +
    '                  <b-list-group-item @click="clickNotif(''Cloud Sync'')">☁️ Cloud Synchronization</b-list-group-item>' +
    '               </b-list-group>' +
    '            </b-card>' +
    '         </div>' +
    '' +
    '         <!-- RIGHT COLUMN: Tabs / Forms / Navigation -->' +
    '         <div class="col-8">' +
    '            <b-card no-body style="height: 100%;">' +
    '               <b-tabs @change="tabChanged">' +
    '                  <b-tab id="forms" title="📝 Forms" active="true">' +
    '                     <div class="p-4">' +
    '                        <h4>Input Controls</h4>' +
    '                        <div class="row mt-4">' +
    '                           <div class="col-6">' +
    '                              <b-input label="UI Identifier" b-model="libName" placeholder="Ex: Turbo_Node"></b-input>' +
    '                              <b-form-select label="Priority" b-model="category" :options="catOptions"></b-form-select>' +
    '                           </div>' +
    '                           <div class="col-6">' +
    '                              <b-input-group label="Operation Cost" prepend="$" append=".00" b-model="count"></b-input-group>' +
    '                              <b-input-group label="API Key" append="Regenerate">' +
    '                                 <b-input b-model="libName" readonly="true"></b-input>' +
    '                              </b-input-group>' +
    '                           </div>' +
    '                        </div>' +
    '                        <div class="alert alert-info mt-3" style="border-radius: 8px;">' +
    '                           <strong>Note:</strong> All fields above use <code>b-model</code> linked directly to the reactive Pascal state.' +
    '                        </div>' +
    '                     </div>' +
    '                  </b-tab>' +
    '' +
    '                  <b-tab id="nav" title="📍 Pagination">' +
    '                     <div class="p-4 text-center">' +
    '                        <h5 class="mb-4">Atomic Data Navigation</h5>' +
    '                        <b-pagination :value="currentPage" :total="10" @input="updatePage"></b-pagination>' +
    '                        <p class="mt-3">Currently viewing segment <strong>#{{ currentPage }}</strong></p>' +
    '                        <b-alert variant="warning" dismissible="true" class="mt-4">' +
    '                           Attention: Segment 7 contains simulated network instabilities.' +
    '                        </b-alert>' +
    '                     </div>' +
    '                  </b-tab>' +
    '' +
    '                  <b-tab id="extras" title="🔥 Accordions">' +
    '                     <div class="p-4">' +
    '                        <b-accordion :items="faqItems" initialActiveId="q1"></b-accordion>' +
    '                     </div>' +
    '                  </b-tab>' +
    '               </b-tabs>' +
    '            </b-card>' +
    '         </div>' +
    '      </div>' +
    '    </div>' +
    '' +
    '    <!-- OVERLAYS: Programmatically triggered via $ref -->' +
    '    <b-modal b-ref="mainModal" title="🔥 System Confirmation" okLabel="Process" cancelLabel="Close" @ok="modalConfirm">' +
    '       <p>You are about to process a state update via Pascal.</p>' +
    '       <div class="p-3 bg-light rounded text-center">' +
    '          <p>Current Values:</p>' +
    '          <b-badge variant="info">{{ libName }}</b-badge>' +
    '          <b-badge variant="success">{{ count }}%</b-badge>' +
    '       </div>' +
    '    </b-modal>' +
    '' +
    '    <b-toast b-ref="mainToast" title="Global Notification" variant="success" duration="4000">' +
    '       Action performed: <strong>{{ lastAction }}</strong>' +
    '    </b-toast>' +
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
          this.$refs.mainToast.show();
       end;
    end;
    { Opens the modal using the component reference }
    
  m['showModal'] := procedure(_this: TJSObject)

    begin
       asm this.$refs.mainModal.show(); end;
    end;
    { Callback executed when the modal OK button is clicked }
    
  m['modalConfirm'] := procedure(_this: TJSObject)

    begin
       asm 
          this.libName = 'SYNC_' + Date.now();
          this.lastAction = 'Modal Confirmed';
          this.$refs.mainToast.show();
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

  comp['methods'] := m;

  comp['created'] := procedure(_this: TJSObject)
    begin
       asm
         this.faqItems = [
           { id: 'q1', title: 'How does Shared State work?', content: 'BlaiseVue uses B-Store for centralized reactive state management in Pascal.' },
           { id: 'q2', title: 'Bootstrap Integration?', content: 'Our component library wraps native CSS in reactive directives friendly to Pascal developers.' },
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
