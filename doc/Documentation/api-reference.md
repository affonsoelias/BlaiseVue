# 📖 BlaiseVue: Referência Técnica da API (v2.1.0 PRO)

Este documento é a fonte oficial para diretivas, eventos, hooks e objetos globais suportados pelo motor de reatividade do BlaiseVue.

---

## 🛡️ Diretivas Estruturais e de Fluxo

| Diretiva | Descrição | Exemplo |
|----------|-----------|---------|
| `b-if` | Renderização condicional (Remoção total do DOM). | `<div b-if="show">...</div>` |
| `b-show` | Alternância de visibilidade (via CSS `display:none`). | `<div b-show="visible">...</div>` |
| `b-for` | Iteração reativa de listas (TJSArray). | `<li b-for="item in list">...</li>` |
| `b-model` | Two-way binding para inputs (e componentes customizados). | `<input b-model="nome">` |
| `b-ref` | Registra referência no objeto `$refs` do componente. | `<canvas b-ref="grafico"></canvas>` |
| `b-slot` | Define o destino de conteúdo injetado pelo pai. | `<slot name="header"></slot>` |
| `:attr` / `v-bind` | Sincroniza atributos HTML com expressões Pascal. | `<div :class="{active: isActive}"></div>` |

---

## ⚡ Eventos e Modificadores

Eventos são prefixados com `@` e podem chamar procedimentos Pascal diretamente ou executar expressões inline.

| Evento | Modificadores | Descrição |
|--------|---------------|-----------|
| `@click` | `.stop`, `.prevent` | Disparado ao clicar (suporta propagação). |
| `@input` | - | Atualização contínua de campos de texto. |
| `@change` | - | Mudança de valor confirmada (foco perdido). |
| `@custom` | - | Eventos disparados via `$emit(nome, valor)`. |

---

## 🧬 Objetos Globais Injetados

Acessíveis via `{{ double-mustache }}` no template ou `this['$obj']` no Pascal.

- **`$store`**: Acesso à **B-Store** global (Estado compartilhado).
- **`$router`**: Acesso ao roteador SPA (Navegação, Parâmetros).
- **`$refs`**: Dicionário de elementos marcados com `b-ref`.
- **`$emit`**: Procedimento para disparar eventos para o componente pai.

---

## 🧠 Ciclo de Vida (Hooks)

| Hook | Momento da Execução |
|------|---------|
| **`created`** | Dados e reatividade inicializados. DOM ainda não existe. |
| **`mounted`** | Componente inserido no documento. Seguro para usar `$refs`. |
| **`updated`** | Chamado após qualquer mudança nos dados atualizar o DOM. |
| **`unmounted`** | Componente removido da árvore. Limpeza de timers e listeners. |

---

## 🔗 Comunicação Inter-Componentes

- **`props`**: Dados passados de Pai para Filho (Fluxo descendente).
- **`provide`**: Dados disponibilizados por um ancestral para todos os seus descendentes.
- **`inject`**: Recebe dados providos por um ancestral distantes (Resolve "prop drilling").

---
🛡️ **"BlaiseVue: Stability, Typing, and Reactivity."** ✨🏆
