# 🛡️ BlaiseVue Framework v2.1.0 PRO
**The Power of Pascal, the Soul of Vue.**

BlaiseVue é um framework SPA (Single Page Application) reativo e moderno que traz o poder da tipagem forte do **Object Pascal** para o ecossistema Web, inspirado na simplicidade e elegância do Vue.js.

---

## ⚔️ O Padrão B (v2.1 PRO)
Nesta versão Pro, o BlaiseVue atinge sua maturidade com recursos de arquitetura de nível corporativo e ferramentas de produtividade avançadas.

### 🔥 Novidades da Versão 2.1:
- **Arsenal de Testes (`bv test`)**: Suite nativa para TDD (Test Driven Development) em Pascal.
- **Cache Busting Inteligente**: O build de desenvolvimento injeta timestamps (`v=123...`) automaticamente para evitar problemas de cache no navegador.
- **Roteamento Dinâmico Avançado**: Suporte total a parâmetros de URL (`:id`) e Query Strings integradas ao `data:`.
- **Global Store ($store)**: Gerenciamento de estado compartilhado via `TBVStore` (Singleton).
- **Slots Nomeados & Transições**: Composição flexível e animações CSS nativas de entrada/saída.
- **Provide/Inject**: Comunicação entre componentes distantes sem "prop drilling".
- **Bibliotecas Externas (/lib)**: Autoload de assets (CSS/JS) e componentes `.bv` externos.

---

## 📦 Bibliotecas Externas (/lib)
O BlaiseVue PRO permite integrar componentes e CSS de terceiros com facilidade:
- **Auto-Link**: Arquivos `.css` na pasta `lib/` são injetados automaticamente no `index.html` durante o build.
- **Auto-Registro**: Qualquer `.bv` dentro de `lib/` (ou subpastas) é registrado globalmente.
- **External JS**: Arquivos `.js` em `lib/` são incluídos como scripts no cabeçalho.

---

## 🧠 Estado Global ($store)
Centralize seus dados com a **B-Store**, acessível em qualquer componente via `$store` no template ou `this['$store']` no Pascal.

```html
<template>
  <div>Versão do App: {{ $store.appVersion }}</div>
</template>
```

---

## 🧪 Unit Testing (Pascal TDD)
Escreva testes para seus componentes e lógica de negócio diretamente em Pascal:

```pascal
begin
  Describe('Meu Componente', procedure
    begin
       It('deve validar o estado inicial', procedure
         begin
            Expect(myVar).ToEqual(True);
         end);
    end);
end.
```

---

## 🛠️ Ferramentas CLI (bv.exe)
- **`bv run dev`**: Build rápido com depuração ativa e injeção de timestamp.
- **`bv test`**: Executa a suíte de testes com integração **Vitest**.
- **`bv new t <Nome>`**: Cria um novo template de arquivo de teste unitário.
- **`bv clean`**: Purga as pastas `dist/` e `generated/` para uma build limpa.

---

## 🚀 Como Iniciar

1.  Clone o repositório.
2.  Navegue até a pasta `demo-app`.
3.  Execute `..\bin\bv.exe run dev`.
4.  Abra o `dist/index.html` no seu navegador.

---

**BlaiseVue: Estabilidade, Tipagem e Reatividade.**  
Desenvolvido por você e estabilizado pela IA. _"In Pascal we trust."_ 🛡️✨
