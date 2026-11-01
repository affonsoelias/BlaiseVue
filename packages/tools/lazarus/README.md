# 🛡️ BlaiseVue IDE Package for Lazarus IDE (`blaisevue_ide.lpk`)

Pacote oficial de design-time para o **Lazarus IDE**, oferecendo suporte nativo de primeira classe ao desenvolvimento de aplicações com o framework reativo **BlaiseVue** e seus Single File Components (`.bv`).

---

## 🌟 Funcionalidades Nativas no Lazarus

### 1. 🎨 Multi-Syntax Highlighting Automático (`TSynMultiSyn`)
Reconhece e colore simultaneamente as três linguagens de um componente `.bv` em um único arquivo no Source Editor:
* **`<template>...</template>`**: Colorização HTML completa com suporte a tags personalizadas, atributos e diretivas reativas (`b-model`, `v-if`, `@click`, etc.).
* **`<script>...</script>`**: Colorização oficial do **TSynPasSyn** do Lazarus (palavras-chave Object Pascal, classes, propriedades, blocos `begin..end`, strings e comentários Pascal).
* **`<style>...</style>`**: Colorização **TSynCssSyn** (seletores, classes CSS, pseudo-classes, propriedades e regras `@media`).

### 2. 🪄 Assistente `File -> New...` do Lazarus
Adiciona a categoria **BlaiseVue** no assistente de novos itens do Lazarus (`TProjectFileDescriptor`):
* **BlaiseVue Component (.bv)**: Gera um componente reativo pronto com template, script tipado `class(TBVComponent)` e estilo escopado (`scoped`).
* **BlaiseVue View (.bv)**: Gera uma página de rota SPA com ciclo de vida `created` e layout estruturado.

### 3. 🛠️ Menu de Ferramentas Integrado (`Tools -> BlaiseVue`)
Permite executar tarefas do CLI diretamente do Lazarus, enviando os resultados para a aba **Messages** oficial da IDE:
* **Verificar Componente Ativo (.bv)**: Executa `bv check` no arquivo aberto, validando a integridade da árvore AST e diretivas com destaque de erros na janela de mensagens.
* **Listar Search Paths do Compilador (bv path)**: Exibe os caminhos de unidades ativas e pacotes Pas2JS mapeados no `app.cfg`.
* **Executar Suíte de Testes (bv test)**: Dispara a suíte de testes de componentes e serviços com relatório instantâneo.

---

## 🚀 Como Instalar no Lazarus IDE

A instalação é feita como qualquer pacote padrão do Lazarus:

1. Abra o **Lazarus IDE**.
2. No menu superior, clique em **Package $\rightarrow$ Open Package File (.lpk)...**
3. Navegue até o diretório do BlaiseVue e selecione:
   ```text
   packages/tools/lazarus/blaisevue_ide.lpk
   ```
4. Na janela do gerenciador de pacotes que se abrir:
   - Clique no botão **Compile** (para verificar a compilação).
   - Clique em **Use $\rightarrow$ Install**.
5. O Lazarus exibirá a mensagem perguntando se deseja recompilar a IDE. Clique em **Yes** (ou **Sim**).
6. A IDE do Lazarus será recompilada e reiniciada automaticamente em poucos segundos.

---

## 💻 Como Usar

### Colorização ao Abrir Arquivos `.bv`
Basta abrir qualquer arquivo `.bv` no Lazarus (via menu `File -> Open`, pelo Inspetor de Projetos ou arrastando o arquivo para dentro da IDE). O Lazarus associará automaticamente o **Multi-Highlighter** do BlaiseVue.

### Criando um Novo Componente
1. Clique em **File $\rightarrow$ New...** (ou `Ctrl + N`).
2. Na árvore de categorias à esquerda, selecione **BlaiseVue**.
3. Escolha **BlaiseVue Component (.bv)** ou **BlaiseVue View (.bv)**.
4. Clique em **OK** para abrir o arquivo gerado diretamente no editor.

### Validando a Sintaxe do Componente
1. Com um arquivo `.bv` ativo no Source Editor, clique em:
   **Tools $\rightarrow$ BlaiseVue $\rightarrow$ Verificar Componente Ativo (.bv)**
2. A janela inferior de **Messages** do Lazarus exibirá o diagnóstico completo do AST e validação de tags.

---

## 📂 Estrutura do Pacote

```text
packages/tools/lazarus/
├── blaisevue_ide.lpk           # Manifesto XML do pacote Lazarus
├── blaisevue_ide.pas           # Arquivo raiz gerado pelo Lazarus
├── README.md                   # Este guia de documentação
└── src/
    ├── uBVSynMultiSyn.pas      # Implementação do Multi-Highlighter (HTML + Pascal + CSS)
    ├── uBVFileDescriptor.pas   # Descritor do assistente File -> New...
    ├── uBVToolsMenu.pas        # Ações do menu Tools -> BlaiseVue
    └── uBlaiseVueIDEReg.pas    # Procedure Register e hooks no SourceEditorManagerIntf
```

---

## 🛡️ Compatibilidade
* **Lazarus**: 2.2, 3.0, 3.2, 4.0, 4.6+
* **Free Pascal (FPC)**: 3.2.2 ou superior
* **Sistemas Operacionais**: Windows, Linux, macOS
