# 📖 BlaiseVue: Referência Técnica da API

Este documento serve como a fonte da verdade para as diretivas, eventos e tipos de dados suportados pelo BlaiseVue v1.3.0.

---

## 🛡️ Diretivas Estruturais e de Fluxo

| Diretiva | Descrição | Exemplo |
|----------|-----------|---------|
| `b-if` | Renderização condicional (DOM removal). | `<div b-if="show">...</div>` |
| `b-show` | Alternância de visibilidade (CSS display). | `<div b-show="visible">...</div>` |
| `b-for` | Iteração de listas. Suporta `$index`. | `<li b-for="item in list">...</li>` |
| `b-model` | Two-way binding para inputs/textareas. | `<input b-model="nome">` |
| `b-ref` | Referência ao elemento ou componente. | `<canvas b-ref="grafico"></canvas>` |

---

## ⚡ Eventos e Expressões

Os eventos são prefixados com `@` e aceitam expressões JavaScript ou referências a métodos Pascal.

| Evento | Contexto | Uso |
|--------|----------|-----|
| `@click` | Qualquer elemento | Chamar procedimento Pascal. |
| `@input` | Inputs e Textareas | Monitorar entrada de dados. |
| `@change` | Selects e Inputs | Ativado na perda de foco ou mudança. |
| `@header-clicked` | Componentes | Eventos disparados via `$emit`. |

---

## 🧬 Tipos Pascal Reativos (FData)

Para garantir a reatividade total, utilize os seguintes tipos em sua seção `data:`:

- **`string` / `integer` / `boolean`**: Tipos primitivos sempre reativos.
- **`TJSObject`**: Para objetos aninhados (ex: `user.profile.age`).
- **`TJSArray`**: Para listas que requerem diretivas `b-for`. Utilize métodos mutadores (`push`, `splice`) para atualização automática do DOM.

---

## 🧠 Ciclo de Vida (Hooks)

| Hook | Momento | Uso Recomendado |
|------|---------|-----------------|
| `created` | Dados injetados | Inicialização de arrays e objetos. |
| `mounted` | DOM renderizado | Uso de `$refs` e bibliotecas externas. |

---

**Nota**: Todas as diretivas BlaiseVue seguem o padrão **kebab-case** no HTML e os métodos Pascal seguem o padrão **camelCase** no Script. 🛡️✨🏆
