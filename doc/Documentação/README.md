# 🛡️ BlaiseVue Framework v2.0.0 PRO
**The Power of Pascal, the Soul of Vue.**

BlaiseVue é um framework SPA (Single Page Application) reativo e moderno que traz o poder da tipagem forte do **Object Pascal** para o ecossistema Web, inspirado na simplicidade e elegância do Vue.js.

---

## ⚔️ O Padrão B (v2.0)
Nesta versão Pro, o BlaiseVue atinge sua maturidade com recursos de arquitetura de nível corporativo.

### 🔥 Novidades da Versão 2.0:
- **Slots Nomeados (`<slot name="x">`)**: Flexibilidade total na composição de componentes.
- **Transições (`<transition>`)**: Suporte nativo para animações CSS de entrada e saída.
- **Global Store ($store)**: Gerenciamento de estado compartilhado via `TBVStore`.
- **Provide/Inject**: Comunicação entre componentes distantes sem "prop drilling".
- **Advanced Lifecycle**: Novos hooks `updated` e `unmounted` para controle total do DOM.
- **Unit Testing (v2.0 PRO)**: Suíte nativa de testes unitários escrita em Pascal e baseada em **Vitest + JSDOM**.
- **Bibliotecas Externas (v2.1+)**: Gerenciador de pacotes nativo via pasta `/lib` e comando `bv lib install`.

---

## 📦 Bibliotecas Externas (/lib)
O BlaiseVue PRO agora permite instalar componentes e CSS de terceiros com um clique:
- **`bv lib install <url>`**: Baixa e extrai bibliotecas automaticamente.
- **Auto-Link**: Arquivos `.css` na pasta lib são injetados no HTML sem configuração.
- **Auto-Registro**: Arquivos `.bv` na pasta lib ficam disponíveis globalmente no app.

---

## 🏛️ Slots & Composição
O BlaiseVue agora suporta slots nomeados, permitindo injetar conteúdo em pontos específicos:

```html
<template>
  <card>
    <template slot="header">Título Customizado 🎨</template>
    <p>Conteúdo principal do card.</p>
    <template slot="footer">Rodapé do card</template>
  </card>
</template>
```

---

## ✨ Transições Visuais
Adicione magia às suas interfaces com o componente `<transition>`:

```html
<transition name="fade">
  <div v-show="isVisible">Surpresa! 🎭</div>
</transition>

<style>
  .fade-enter-active, .fade-leave-active { transition: opacity 0.5s; }
  .fade-enter-from, .fade-leave-to { opacity: 0; }
</style>
```

---

## 🧠 Estado Global ($store)
Centralize seus dados com a B-Store, acessível em qualquer componente via `$store`:

```pascal
// No código Pascal (uApp.pas ou similar)
TJSObject(JSThis['$store'])['appVersion'] := '2.0.0-PRO';
```

---

## 🛠️ Ferramentas CLI
O BlaiseVue vem com sua própria ferramenta de linha de comando (`bv.exe`) para acelerar o desenvolvimento:

- **`bv clean`**: Limpa a pasta `/dist` para uma build limpa.
- **`bv run dev`**: Inicia o modo de desenvolvimento com depuração hiper-verbosa e logs em tempo real.
- **`bv test`**: Executa a suíte de testes unitários escrita em Pascal com integração **Vitest**.
- **`bv serve`**: Sobe um servidor local para testar a aplicação compilada.

---

## 🚀 Como Iniciar

1.  Clone o repositório.
2.  Navegue até a pasta `demo-app`.
3.  Execute `..\bin\bv.exe run dev`.
4.  Abra o `dist/index.html` no seu navegador favorito.

---

**BlaiseVue: Estabilidade, Tipagem e Reatividade.**  
Desenvolvido por você e estabilizado pela IA. _"In Pascal we trust."_ 🛡️✨
