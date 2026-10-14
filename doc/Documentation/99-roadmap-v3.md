# 🛡️ Technical Roadmap: BlaiseVue 2.5 & 3.0 (The Next Frontier)

Este documento define a estratégia técnica, metas arquiteturais e especificações para a próxima grande evolução do framework: **BlaiseVue 2.5 e 3.0**.

> [!NOTE]
> **Status Atual**: 📋 **Planejado / Em Especificação Arquitetural**. Nenhuma implementação do ciclo 2.5/3.0 foi iniciada.

---

## 🏆 Registro de Entrega: BlaiseVue 2.0 (✅ 100% Concluído)

A versão 2.0 do BlaiseVue atingiu maturidade corporativa com todas as 9 metas originais plenamente implementadas e cobertas por 22 testes unitários automatizados:

| Meta 2.0 | Status | Arquivos de Implementação |
|---|:---:|---|
| **1. Hot Module Replacement (HMR)** | ✅ Concluído | [`bin/dev-server.js`](file:///c:/Users/Pichau/Documents/BlaiseVue/bin/dev-server.js), [`core/BVCompiler.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/core/BVCompiler.pas) |
| **2. Advanced Routing (History & Nested)** | ✅ Concluído | [`core/BVRouting.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/core/BVRouting.pas) |
| **3. Scoped Slots** | ✅ Concluído | [`core/BVCompiler.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/core/BVCompiler.pas) |
| **4. Teleport & Suspense** | ✅ Concluído | [`core/BVCompiler.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/core/BVCompiler.pas) |
| **5. Static Hoisting & Compiler Pruning** | ✅ Concluído | [`core/BVCompiler.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/core/BVCompiler.pas) |
| **6. Browser DevTools Extension (Manifest V3)** | ✅ Concluído | [`devtools/`](file:///c:/Users/Pichau/Documents/BlaiseVue/devtools/), [`core/BVCompiler.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/core/BVCompiler.pas) |
| **7. BlaiseUI Component Kit** | ✅ Concluído | [`packages/blaise-ui/`](file:///c:/Users/Pichau/Documents/BlaiseVue/packages/blaise-ui/), [`demo-app/lib/blaise-ui/`](file:///c:/Users/Pichau/Documents/BlaiseVue/demo-app/lib/blaise-ui/) |
| **8. CLI Native Resource Scaffolding** | ✅ Concluído | [`bin/templates/`](file:///c:/Users/Pichau/Documents/BlaiseVue/bin/templates/), `{$R templates.res}` em [`bin/bv.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/bin/bv.pas) |
| **9. Suíte de Testes Automatizados** | ✅ Concluído | `demo-app/tests/`, Vitest runner (22/22 testes passando) |

---

## 🔮 O Próximo Horizonte: Metas Arquiteturais (v2.5 & v3.0)

Abaixo estão os novos pilares estratégicos desenhados para consolidar o BlaiseVue como o ecossistema frontend mais robusto e performático em Object Pascal:

```
                                  BLAISEVUE 3.0
                                        │
        ┌───────────────┬───────────────┼───────────────┬───────────────┐
        ▼               ▼               ▼               ▼               ▼
   [b-validate]    [transition-    [Blaise-i18n]    [bv doc]        [WebAssembly]
  (Form Engine)      group]        (Multilíngue)  (Docs/Storybook)   (FPC Wasm)
```

---

### 📋 1. Motor Nativo de Validação de Formulários (`b-validate` / Typed Form Engine)
**Objetivo**: Validação reativa de formulários sem boilerplate manual e com a segurança de tipos do Pascal.
- **Sintaxe Declarativa**: Diretiva `b-validate` ou bloco `validations:` nos componentes `.bv`:
  ```html
  <bv-input
    b-model="email"
    b-validate="required|email"
    label="E-mail"
    :error="$errors.email"
  ></bv-input>
  ```
- **Regras Tipadas em Pascal**: Criação de validadores customizados em Object Pascal:
  ```pascal
  function ValidateTaxId(Value: string): boolean;
  ```
- **Gerenciamento de Estado**: Injeção automática do objeto `$v` ou `$errors` contendo `$dirty`, `$invalid`, `$touch()` e mensagens de erro localizadas.

---

### 🎬 2. Transições em Listas Reativas (`<transition-group>`)
**Objetivo**: Animações suaves de entrada, remoção e reordenação de elementos em coleções.
- **Algoritmo FLIP (*First, Last, Invert, Play*)**: O compilador calcula a posição inicial e final de cada nó no DOM ao sofrer mutação via `b-for`, gerando transições CSS suaves sem recálculo pesado de layout.
- **Classes Automáticas**: Injeção de classes CSS `-move`, `-enter-active` e `-leave-to` com suporte a coordenadas `transform: translate(...)`.

---

### 🌐 3. Internacionalização Integrada (Blaise-i18n)
**Objetivo**: Suporte de primeira classe para aplicações multilíngues.
- **Helper Global `$t()`**: Acesso imediato no template (`{{ $t('common.save') }}`) e em métodos Pascal (`this['$t']('common.save')`).
- **Dicionários Reativos**: Arquivos de mensagens em `.json` ou unidades Pascal (`uLocalePT.pas`, `uLocaleEN.pas`).
- **Troca Dinâmica de Locale**: Mutação instantânea de idioma em tempo de execução sem recarregar a página e com atualização de todas as strings em tela.

---

### 📚 4. Gerador Automático de Documentação (`bv doc`)
**Objetivo**: Facilitar a criação de Design Systems e bibliotecas de componentes corporativas.
- **Comando CLI**: `bv doc` analisa a pasta `src/components/` e `lib/`.
- **AST Parser em Pascal**: Extrai automaticamente:
  - Props declaradas (nome, tipo, valor padrão).
  - Eventos emitidos (`$emit`).
  - Slots disponíveis (nomeados e escopados).
  - Docstrings de documentação escritas nos arquivos `.bv`.
- **Catálogo Interativo**: Gera um site estático moderno (estilo *Storybook* ou *VuePress*) com visualizador de componentes e playground interativo.

---

### ⚡ 5. Aceleração via WebAssembly (FPC Wasm Target)
**Objetivo**: Performance quase nativa para tarefas computacionalmente intensivas.
- **Pipeline Híbrido**: Permitir que rotinas de processamento de imagem, criptografia, cálculos matemáticos ou compressão sejam compiladas diretamente para WebAssembly (`.wasm`) usando o backend Wasm do FreePascal Compiler.
- **Interoperabilidade**: Chamada transparente de funções Wasm diretamente de métodos dos componentes `.bv` sem complexidade de wrappers manuais em JavaScript.

---

### 🚀 6. SSG & Pré-renderização Estática (Static Site Generation)
**Objetivo**: Tempo de primeiro carregamento instantâneo (FCP < 100ms) e indexação perfeita por motores de busca (SEO).
- **Comando `bv run ssg`**: Pré-renderiza as rotas do roteador em arquivos HTML estáticos com os dados iniciais injetados.
- **Hidratação Reativa (Hydration)**: Ao carregar no navegador, o cliente BlaiseVue associa a árvore reativa ao HTML pré-existente sem refazer a pintura da tela (zero flickering).

---

### 🧪 7. Driver de Testes Ponta a Ponta Headless (E2E Testing)
**Objetivo**: Testar fluxos completos de usuário em navegadores reais.
- **Integração no CLI**: Comando `bv test e2e`.
- **Validação de Fluxos Críticos**: Testes automatizados cobrindo autenticação, navegação com HTML5 History, submissão de formulários, abertura de modais com `<teleport>` e resolução assíncrona de `<suspense>`.

---

## 📅 Visão Geral do Cronograma

```
[ v2.0 - Concluída ✅ ]
       │
       ▼
[ v2.5 - Q1/Q2 ] ──► Form Validation Engine (b-validate)
                 ──► Transições em Listas (<transition-group>)
                 ──► Internacionalização (Blaise-i18n)
       │
       ▼
[ v3.0 - Q3/Q4 ] ──► Gerador de Documentação (bv doc)
                 ──► Aceleração WebAssembly (FPC Wasm)
                 ──► SSG & Pré-renderização Estática
                 ──► Suíte E2E Automatizada
```

---

🛡️ **"Architecture is the art of making the impossible inevitable."** ✨🏆🚀
