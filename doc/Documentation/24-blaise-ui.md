# 24. BlaiseUI (Official Component Kit)

**BlaiseUI** é a biblioteca de componentes oficial, unificada e nativa do BlaiseVue 2.0. Desenvolvida 100% em Object Pascal e Single File Components (`.bv`), ela reúne todo o sistema de design visual, controles de formulário, navegação, overlays e gráficos reativos em um único pacote coeso e com zero dependências externas de CSS.

---

## 📦 Arquitetura Unificada

O BlaiseUI substitui antigas bibliotecas fragmentadas (como `bootstrap-bv` e `chart-bv`) por uma **única pasta**:
- **Pacote Fonte**: [`packages/blaise-ui/`](file:///c:/Users/Pichau/Documents/BlaiseVue/packages/blaise-ui/)
- **Integração na Aplicação**: [`demo-app/lib/blaise-ui/`](file:///c:/Users/Pichau/Documents/BlaiseVue/demo-app/lib/blaise-ui/)

Graças ao mecanismo de autoloading da pasta `lib/` do BlaiseVue:
1. Todos os componentes com prefixo `bv-*` são **registrados globalmente** sem necessidade de `import`.
2. O stylesheet [`blaise-ui.css`](file:///c:/Users/Pichau/Documents/BlaiseVue/packages/blaise-ui/blaise-ui.css) é injetado automaticamente no `<head>`.
3. O script [`chart.min.js`](file:///c:/Users/Pichau/Documents/BlaiseVue/packages/blaise-ui/chart.min.js) incluído no pacote é injetado automaticamente no cabeçalho.

---

## 🎨 Sistema de Design & Variáveis CSS

O BlaiseUI utiliza variáveis CSS customizáveis (`--bui-*`):

```css
:root {
  --bui-primary: #42b883;
  --bui-primary-hover: #33a06f;
  --bui-secondary: #64748b;
  --bui-success: #10b981;
  --bui-danger: #ef4444;
  --bui-warning: #f59e0b;
  --bui-info: #0ea5e9;
  --bui-bg: #ffffff;
  --bui-card-bg: #ffffff;
  --bui-border: #e2e8f0;
  --bui-text: #1e293b;
  --bui-text-muted: #64748b;
  --bui-radius: 6px;
}
```

---

## 🧩 Catálogo Completo de Componentes

### 0. Layout & Grid Responsivo (Mobile & Desktop)
Construído com base no sistema de 12 colunas adaptativas para suportar telas de qualquer resolução:
- **`<bv-container>`**: Container centralizado com suporte a largura fixa responsiva ou fluida (`fluid="true"`).
- **`<bv-row>`**: Linha flexível com espaçamento entre colunas configurável via prop `gutter` (`none`, `sm`, `md`, `lg`).
- **`<bv-col>`**: Coluna adaptativa com suporte a breakpoints do Bootstrap (`cols`, `sm`, `md`, `lg`, `xl`) e deslocamento (`offset`).
  ```html
  <bv-container fluid="true">
    <bv-row gutter="md">
      <!-- 12 colunas no celular, 4 colunas a partir de telas médias -->
      <bv-col cols="12" md="4">
        <bv-card title="Sidebar / Resumo">...</bv-card>
      </bv-col>
      <!-- 12 colunas no celular, 8 colunas a partir de telas médias -->
      <bv-col cols="12" md="8">
        <bv-card title="Conteúdo Principal">...</bv-card>
      </bv-col>
    </bv-row>
  </bv-container>
  ```

### 1. Ações e Estrutura Básica
- **`<bv-btn>`**: Botão padronizado com variantes (`primary`, `secondary`, `success`, `danger`, `outline`), tamanhos (`sm`, `md`, `lg`) e estado `disabled`.
  ```html
  <bv-btn variant="primary" size="md" @click="salvar">Salvar Registro</bv-btn>
  ```
- **`<bv-card>`**: Container de superfície estruturado com slots `header`, padrão (corpo) e `footer`.
  ```html
  <bv-card title="Métricas do Sistema">
    <p>Conteúdo do Card</p>
    <template b-slot:footer>
      <bv-btn size="sm" variant="secondary">Atualizar</bv-btn>
    </template>
  </bv-card>
  ```
- **`<bv-badge>`**: Rótulos e marcadores visuais coloridos com opção `pill`.
  ```html
  <bv-badge variant="success" :pill="true">Ativo</bv-badge>
  ```

---

### 2. Feedback, Overlays e Notificações
- **`<bv-modal>`**: Diálogo modal interativo renderizado via `<teleport to="body">` com controle seguro via `b-show="isVisible"`, evitando problemas de `z-index`, layout shifts ou bloqueios indesejados. Inclui limpeza automática de nós filhos no ciclo de desmonte do roteador.
  ```html
  <bv-modal b-ref="meuModal" title="Confirmar Operação" okLabel="Confirmar" cancelLabel="Cancelar" @ok="aoConfirmar">
    <p>Tem certeza de que deseja continuar?</p>
  </bv-modal>
  ```
- **`<bv-drawer>`**: Menu lateral deslizante (*Off-Canvas Drawer*) ideal para navegação secundária e menus de aplicativos mobile.
  ```html
  <bv-drawer b-ref="meuDrawer" title="Menu Principal">
    <p>Conteúdo deslizante do menu lateral.</p>
  </bv-drawer>
  ```
- **`<bv-toast>`**: Notificações flutuantes com auto-dismiss temporizado.
  ```html
  <bv-toast b-ref="meuToast" title="Sucesso" variant="success" :duration="3000">
    Registro atualizado com sucesso!
  </bv-toast>
  ```
- **`<bv-alert>`**: Alertas com variantes de status e opção `dismissible`.
  ```html
  <bv-alert variant="warning" :dismissible="true">Atenção aos dados informados.</bv-alert>
  ```
- **`<bv-progress>`**: Barra de progresso reativa com animação suave e label percentual.
  ```html
  <bv-progress :value="porcentagem" variant="success"></bv-progress>
  ```
- **`<bv-spinner>`**: Indicador giratório de carregamento com opção `small`.
  ```html
  <bv-spinner variant="primary" :small="true"></bv-spinner>
  ```

---

### 3. Navegação e Coleções
- **`<bv-bottom-nav>` & `<bv-bottom-nav-item>`**: Barra de navegação inferior fixa para dispositivos móveis com suporte a ícones, labels e detecção de rota ativa.
  ```html
  <bv-bottom-nav>
    <bv-bottom-nav-item href="#/" icon="🏠" label="Início"></bv-bottom-nav-item>
    <bv-bottom-nav-item href="#/perfil" icon="👤" label="Perfil"></bv-bottom-nav-item>
  </bv-bottom-nav>
  ```
- **`<bv-navbar>` & `<bv-nav-item>`**: Barra de navegação superior com branding e links reativos. Trata cliques com `preventDefault` em rotas locais para evitar mutações indesejadas no hash da URL.
  ```html
  <bv-navbar brand="Meu Sistema">
    <bv-nav-item href="#/" active="true" label="Home"></bv-nav-item>
    <bv-nav-item href="#/relatorios" label="Relatórios"></bv-nav-item>
  </bv-navbar>
  ```
- **`<bv-breadcrumb>` & `<bv-breadcrumb-item>`**: Trilhas de navegação hierárquica.
  ```html
  <bv-breadcrumb>
    <bv-breadcrumb-item href="#/">Início</bv-breadcrumb-item>
    <bv-breadcrumb-item active="true">Detalhes</bv-breadcrumb-item>
  </bv-breadcrumb>
  ```
- **`<bv-tabs>` & `<bv-tab>`**: Sistema dinâmico de abas com registro automático via provide/inject.
  ```html
  <bv-tabs @change="abaMudou">
    <bv-tab id="tab1" title="Visão Geral" active="true">Conteúdo 1</bv-tab>
    <bv-tab id="tab2" title="Configurações">Conteúdo 2</bv-tab>
  </bv-tabs>
  ```
- **`<bv-accordion>`**: Sanfona interativa para seções expansíveis / FAQ.
  ```html
  <bv-accordion :items="listaFaq" initialActiveId="q1"></bv-accordion>
  ```
- **`<bv-pagination>`**: Navegador de páginas numérico com eventos `input` e `change`.
  ```html
  <bv-pagination :value="paginaAtual" :total="10" @input="mudarPagina"></bv-pagination>
  ```
- **`<bv-list-group>` & `<bv-list-group-item>`**: Listas estruturadas com suporte a badges e estado ativo.
  ```html
  <bv-list-group>
    <bv-list-group-item badge="3" badgeVariant="danger">Mensagens</bv-list-group-item>
  </bv-list-group>
  ```
- **`<bv-icon>`**: Ícones SVG vetoriais embutidos locais (`check-circle`, `warning`, `gear-fill`, `heart-fill`, `weather`, `code-slash`, `cpu`).
  ```html
  <bv-icon name="check-circle" size="24" class="text-success" />
  ```

---

### 4. Controles de Formulário
- **`<bv-input>`**: Campo de texto com `b-model`, label e feedback de erro.
  ```html
  <bv-input label="Nome Completo" b-model="nome" placeholder="Digite seu nome"></bv-input>
  ```
- **`<bv-form-select>`**: Dropdown de seleção reativa vinculado a opções dinâmicas.
  ```html
  <bv-form-select label="Prioridade" b-model="prioridade" :options="opcoes"></bv-form-select>
  ```
- **`<bv-input-group>`**: Campo de entrada com prefixos e sufixos visuais (`prepend` / `append`).
  ```html
  <bv-input-group label="Valor" prepend="R$" append=",00" b-model="valor"></bv-input-group>
  ```

---

### 5. Tabelas e Dados Complexos
- **`<bv-datagrid>`**: Tabela de dados de alta performance com busca, ordenação, paginação e suporte a **Scoped Slots**.
  ```html
  <bv-datagrid :columns="colunas" :items="usuarios">
    <template b-slot:cell(status)="scope">
      <bv-badge :variant="scope.row.ativo ? 'success' : 'danger'">
        {{ scope.row.ativo ? 'Ativo' : 'Inativo' }}
      </bv-badge>
    </template>
  </bv-datagrid>
  ```

---

### 6. Gráficos Reativos (`Chart.js`)
O BlaiseUI integra a visualização de dados diretamente no kit:
- **`<bv-chart>`**: Componente master de gráfico que aceita `:type="bar|line|pie|doughnut|radar|polarArea"`, `:data` e `:options`.
- **Atalhos Dedicados**:
  - `<bv-bar :data="dados" :options="opcoes"></bv-bar>`
  - `<bv-line :data="dados" :options="opcoes"></bv-line>`
  - `<bv-pie :data="dados" :options="opcoes"></bv-pie>`
  - `<bv-doughnut :data="dados" :options="opcoes"></bv-doughnut>`
  - `<bv-polar-area :data="dados" :options="opcoes"></bv-polar-area>`
  - `<bv-radar :data="dados" :options="opcoes"></bv-radar>`

```html
<template>
  <bv-bar :data="vendasData" :options="chartOptions"></bv-bar>
</template>
```

---

## 🛡️ Vantagens da Unificação

| Antes (Fragmentado) | Agora (BlaiseUI Unificado) |
|---|---|
| Três pastas separadas (`bootstrap-bv`, `chart-bv`, `blaise-ui`) | **Apenas uma pasta**: `lib/blaise-ui/` |
| Prefixos concorrentes (`b-btn`, `bv-btn`, `c-line`) | **Prefixo universal padronizado**: `bv-*` |
| Inclusão pesada do `bootstrap.css` (~230KB) | **CSS leve e customizável** (`blaise-ui.css`) |
| Conflitos conceituais (`BModal` vs `BVModal`) | **Componente único e definitivo com Teleport** |
