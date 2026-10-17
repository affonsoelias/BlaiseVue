# 34. VS Code Extension & Professional DX (.vsix) - Phase 1

A **Fase 1 da plataforma universal BlaiseVue (v3.5)** entrega uma experiência de desenvolvimento de primeira classe (DX - *Developer Experience*) para o ecossistema Object Pascal moderno. A extensão oficial para Visual Studio Code e editores baseados em Chromium/VSCodium transforma o desenvolvimento de Single File Components (`.bv`) em um fluxo ágil, com autocompletar inteligente, validação visual e snippets completos.

---

## 🎯 Objetivos da Fase 1

1. **Reconhecimento Nativo do Formato `.bv`**:
   - Destaque de sintaxe triplo dentro do mesmo arquivo: tags HTML no `<template>`, sintaxe moderna Object Pascal no `<script>` e estilos CSS no `<style>`.
2. **Autocompletar Inteligente de Diretivas**:
   - Sugestões imediatas ao digitar diretivas do BlaiseVue: `b-model`, `b-for`, `b-if`, `b-show`, `b-validate`, `@click`, `:class`, `:style`, etc.
3. **Catálogo Completo do BlaiseUI Integrado**:
   - Sugestões de todos os componentes oficiais (`<bv-btn>`, `<bv-card>`, `<bv-container>`, `<bv-row>`, `<bv-col>`, `<bv-modal>`, `<bv-drawer>`, `<bv-bottom-nav>`, `<bv-icon>`, etc.) com documentação embutida de *props* e *slots*.
4. **Coleção de Snippets Produtivos**:
   - Criação instantânea de scaffolds para componentes, páginas, formulários validados e grids responsivos.
5. **Distribuição Autônoma via CLI**:
   - Empacotamento em arquivo `.vsix` independente sem necessidade de dependências pesadas do Node.js ou contas externas de marketplace.

---

## 📦 Comandos da CLI para a Extensão

A CLI nativa `bv` gerencia o ciclo de empacotamento e instalação da extensão:

```bash
# Empacota a extensão oficial gerando o arquivo .vsix distribuível
bv vsix

# Ou utilizando o subcomando extension:
bv extension package

# Instala a extensão diretamente no VS Code da máquina local
bv extension install
```

O comando gera o arquivo `blaisevue-language-tools-1.0.0.vsix` pronto para distribuição em equipes corporativas ou instalação manual no VS Code (`code --install-extension blaisevue-language-tools-1.0.0.vsix`).

---

## 🧩 Recursos em Detalhe

### 1. Destaque de Sintaxe Híbrido (`.bv`)

Single File Components combinam três linguagens no mesmo documento. A extensão define gramáticas TextMate especializadas:
- Seção `<template>`: HTML5 avançado com suporte a sintaxe de templates Vue/BlaiseVue (`{{ }}`, `@`, `:`, `b-`).
- Seção `<script>`: Object Pascal completo (Free Pascal / Delphi syntax), destacando palavras-chave (`interface`, `implementation`, `var`, `procedure`, `function`, `asm`, `end`), tipos e identificadores reativos.
- Seção `<style>`: CSS3 padrão com suporte a escopo e variáveis CSS (`--bui-*`).

### 2. Autocompletar de Diretivas BlaiseVue

Ao digitar em elementos de template, o IntelliSense sugere as diretivas do framework com documentação contextual:

| Diretiva | Descrição |
| :--- | :--- |
| `b-model="field"` | Two-way data binding reativo bidirecional para inputs e componentes |
| `b-validate="rules"` | Validação reativa (`required`, `email`, `min:N`, `max:N`, etc.) |
| `b-if="cond"` | Renderização condicional com inserção/remoção do DOM e limpeza de ciclo de vida |
| `b-show="cond"` | Controle visual de visibilidade via alternância de `display: none` |
| `b-for="item in list"` | Renderização de coleções reativas com suporte a `$index` |
| `b-ref="nome"` | Registro de referência no objeto `$refs` para acesso a métodos de componentes |
| `@click="metodo"` | Vinculação declarativa de eventos com suporte a modificadores (`.stop`, `.prevent`) |
| `:prop="expressao"` | Passagem reativa de propriedades calculadas ou dados do estado Pascal |

### 3. Autocompletar do Kit de Componentes BlaiseUI

Ao abrir tags com `<bv-`, o editor exibe a lista completa de componentes com suas respectivas propriedades tipadas:

```html
<!-- Exemplo de autocompletar ao digitar <bv-r... -->
<bv-row gutter="md">
  <bv-col cols="12" md="6">
    <bv-card title="Painel de Controle">
      ...
    </bv-card>
  </bv-col>
</bv-row>
```

### 4. Biblioteca de Snippets Rápidos

A extensão inclui atalhos de código para aceleração do desenvolvimento:

- **`bv-comp`**: Estrutura básica de um componente SFC (`<template>`, `<script>`, `<style>`).
- **`bv-page`**: Página completa de visualização com roteador, breadcrumbs e cabeçalho.
- **`bv-form`**: Formulário de entrada com campos validados via `b-validate` e botão de envio.
- **`bv-grid`**: Estrutura responsiva com `bv-container`, `bv-row` e colunas adaptativas.
- **`bv-modal`**: Diálogo modal interativo com slots de corpo e rodapé configurados.
- **`bv-drawer`**: Menu lateral deslizante (*off-canvas*) com controle reativo.
- **`bv-bottom-nav`**: Barra de navegação inferior otimizada para dispositivos móveis.

---

## 🛠️ Estrutura Interna da Extensão

A extensão está localizada no repositório em [`vscode-extension/`](file:///c:/Users/Pichau/Documents/BlaiseVue/vscode-extension/):

```text
vscode-extension/
├── package.json               # Manifesto da extensão, ativação e comandos
├── language-configuration.json # Regras de auto-fechamento de tags e comentários
├── syntaxes/
│   └── blaisevue.tmLanguage.json # Gramática TextMate híbrida (HTML + Pascal + CSS)
├── snippets/
│   └── blaisevue.json        # Coleção de snippets produtivos para .bv
└── README.md                  # Guia de uso para desenvolvedores
```

Com a Fase 1 concluída, a edição de aplicações BlaiseVue no VS Code oferece suporte ergonômico e profissional equivalente aos ecossistemas web mais maduros do mercado. 🛡️✨
