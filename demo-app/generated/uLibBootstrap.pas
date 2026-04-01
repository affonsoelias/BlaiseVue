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
    '    <!-- NAVBAR INTERNA (DEMO) -->' +
    '    <b-navbar variant="dark" sticky="true" style="margin-bottom: 25px; border-radius: 8px;">' +
    '       <b-nav-item href="#/" active="true">Home</b-nav-item>' +
    '       <b-nav-item href="#/charts">Charts</b-nav-item>' +
    '       <b-nav-item href="#/pro">Pro Features</b-nav-item>' +
    '       <b-nav-item href="#" @click="clickNotif(''Settings Global'')">⚙️ Configurações</b-nav-item>' +
    '    </b-navbar>' +
    '' +
    '    <!-- CONTENT -->' +
    '    <div class="container-fluid p-0">' +
    '      <div class="row mb-5">' +
    '         <div class="col-8">' +
    '            <h1 class="mb-2">🚀 BlaiseVue Pro UI Kit</h1>' +
    '            <p class="text-muted mb-4">Demonstração de 45+ componentes reativos construídos 100% em Pascal.</p>' +
    '            ' +
    '            <b-breadcrumb>' +
    '               <b-breadcrumb-item href="#/">Home</b-breadcrumb-item>' +
    '               <b-breadcrumb-item href="#">Componentes</b-breadcrumb-item>' +
    '               <b-breadcrumb-item active="true">Bootstrap-BV</b-breadcrumb-item>' +
    '            </b-breadcrumb>' +
    '         </div>' +
    '         <div class="col-4 d-flex align-items-end justify-content-end p-2 gap-2">' +
    '            <b-btn label="Abrir Modal" variant="primary" size="lg" @click="showModal"></b-btn>' +
    '            <b-btn label="Toast Info" variant="info" size="lg" @click="clickNotif(''Manual Toast Trigger'')"></b-btn>' +
    '         </div>' +
    '      </div>' +
    '' +
    '      <div class="row">' +
    '         <!-- LEFT COL: Feedbacks e Status -->' +
    '         <div class="col-4">' +
    '            <b-card title="📊 Status do Sistema">' +
    '               <div class="mb-3">' +
    '                  <small>Carga do Motor (Reatividade)</small>' +
    '                  <b-progress :value="count" variant="success" animated="true"></b-progress>' +
    '               </div>' +
    '               <div class="mb-3">' +
    '                  <small>Uso de Memória ($Store)</small>' +
    '                  <b-progress :value="35" variant="info"></b-progress>' +
    '               </div>' +
    '               <div class="d-flex gap-2">' +
    '                  <b-btn label="Pulsar (Count++)" variant="outline-primary" @click="count = (count + 10) % 105"></b-btn>' +
    '                  <b-spinner variant="primary" small="true" v-if="count > 80"></b-spinner>' +
    '               </div>' +
    '            </b-card>' +
    '' +
    '            <b-card title="📋 Centro de Notificações" class="mt-4">' +
    '               <b-list-group>' +
    '                  <b-list-group-item badge="5" badgeVariant="danger" @click="clickNotif(''Novos E-mails'')">📨 Mensagens Entrada</b-list-group-item>' +
    '                  <b-list-group-item active="true" @click="clickNotif(''Destaque'')">🌟 Destaque Semanal</b-list-group-item>' +
    '                  <b-list-group-item badge="OFFLINE" badgeVariant="secondary" @click="clickNotif(''Legacy Sys'')">💾 Legado v1.0</b-list-group-item>' +
    '                  <b-list-group-item @click="clickNotif(''Cloud Sync'')">☁️ Cloud Synchronization</b-list-group-item>' +
    '               </b-list-group>' +
    '            </b-card>' +
    '         </div>' +
    '' +
    '         <!-- RIGHT COL: Tabs / Forms / Charts -->' +
    '         <div class="col-8">' +
    '            <b-card no-body style="height: 100%;">' +
    '               <b-tabs @change="tabChanged">' +
    '                  <b-tab id="forms" title="📝 Formulários" active="true">' +
    '                     <div class="p-4">' +
    '                        <h4>Controle de Entrada</h4>' +
    '                        <div class="row mt-4">' +
    '                           <div class="col-6">' +
    '                              <b-input label="Identificador da UI" b-model="libName" placeholder="Ex: Turbo_Node"></b-input>' +
    '                              <b-form-select label="Prioridade" b-model="category" :options="catOptions"></b-form-select>' +
    '                           </div>' +
    '                           <div class="col-6">' +
    '                              <b-input-group label="Custo da Operação" prepend="$" append=".00" b-model="count"></b-input-group>' +
    '                              <b-input-group label="API Key" append="Regenerar">' +
    '                                 <b-input b-model="libName" readonly="true"></b-input>' +
    '                              </b-input-group>' +
    '                           </div>' +
    '                        </div>' +
    '                        <div class="alert alert-info mt-3" style="border-radius: 8px;">' +
    '                           <strong>Observação:</strong> Todos os campos acima usam <code>b-model</code> vinculado diretamente ao estado reativo do Pascal.' +
    '                        </div>' +
    '                     </div>' +
    '                  </b-tab>' +
    '' +
    '                  <b-tab id="nav" title="📍 Paginação">' +
    '                     <div class="p-4 text-center">' +
    '                        <h5 class="mb-4">Navegação de Dados Atômica</h5>' +
    '                        <b-pagination :value="currentPage" :total="10" @input="updatePage"></b-pagination>' +
    '                        <p class="mt-3">Atualmente visualizando o segmento <strong>#{{ currentPage }}</strong></p>' +
    '                        <b-alert variant="warning" dismissible="true" class="mt-4">' +
    '                           Atenção: Segmento 7 contém instabilidades de rede simuladas.' +
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
    '    <!-- OVERLAYS -->' +
    '    <b-modal b-ref="mainModal" title="🔥 Confirmação System" okLabel="Processar" cancelLabel="Fechar" @ok="modalConfirm">' +
    '       <p>Você está prestes a processar uma atualização de estado via Pascal.</p>' +
    '       <div class="p-3 bg-light rounded text-center">' +
    '          <p>Valores Atuais:</p>' +
    '          <b-badge variant="info">{{ libName }}</b-badge>' +
    '          <b-badge variant="success">{{ count }}%</b-badge>' +
    '       </div>' +
    '    </b-modal>' +
    '' +
    '    <b-toast b-ref="mainToast" title="Notificação Global" variant="success" duration="4000">' +
    '       Ação executada: <strong>{{ lastAction }}</strong>' +
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
    d['lastAction'] := 'Sistema Pronto';
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
    
  m['showModal'] := procedure(_this: TJSObject)

    begin
       asm this.$refs.mainModal.show(); end;
    end;
    
  m['modalConfirm'] := procedure(_this: TJSObject)

    begin
       asm 
          this.libName = 'SYNC_' + Date.now();
          this.lastAction = 'Modal Confirmado';
          this.$refs.mainToast.show();
       end;
    end;
    
  m['updatePage'] := procedure(_this: TJSObject; p: integer)

    begin
       asm this.currentPage = p; end;
    end;
    
  m['tabChanged'] := procedure(_this: TJSObject; id: string)

    begin
       asm console.log("Aba alterada para: ", id); end;
    end;
    
  m['voltar'] := procedure(_this: TJSObject)

    begin
       asm window.location.hash = '#/'; end;
    end;

  comp['methods'] := m;

  comp['created'] := procedure(_this: TJSObject)
    begin
       asm
         this.faqItems = [
           { id: 'q1', title: 'Como funciona o Shared State?', content: 'O BlaiseVue utiliza o B-Store para gerenciar estado global de forma reativa e centralizada em Pascal.' },
           { id: 'q2', title: 'Integração Bootstrap?', content: 'Nossa biblioteca de componentes encapsula o CSS nativo em diretivas reativas amigáveis ao desenvolvedor Pascal.' },
           { id: 'q3', title: 'Otimização JIT?', content: 'O compilador gera bundles JavaScript minimalistas, resultando em tempos de carregamento instantâneos.' }
         ];
         this.catOptions = [
           { value: 'low', text: 'Prioridade Baixa' },
           { value: 'med', text: 'Prioridade Média' },
           { value: 'high', text: 'Prioridade Alta (Critical)' }
         ];
       end;
    end;

    ;

  RegisterComponent('lib-bootstrap-page', comp);
end;

end.
