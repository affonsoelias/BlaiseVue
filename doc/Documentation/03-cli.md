# 🛡️ Manual Técnico do BlaiseCLI (bv.exe)

O `bv.exe` é o orquestrador nativo do BlaiseVue, responsável pela transpilação de componentes SFC, gerenciamento de bibliotecas e orquestração do ciclo de build.

---

## 🏗️ Comandos de Desenvolvimento e Build

### `bv run dev` (Desenvolvimento Express)
Executa o build completo e ativa recursos de depuração em tempo real.
- **Cache Busting (v=123...)**: Re-escreve todos os links de scripts e estilos no `index.html` injetando um parâmetro de versão baseado em timestamp para contornar o cache do navegador.
- **Unit DevTools**: Injeta e ativa automaticamente a barra lateral de diagnóstico (`BVDevTools`).
- **Debugging Flags**: Compila o Pascal com símbolos de depuração e saída verbosa no console do browser.

### `bv run build` (Produção Otimizada)
Gera o bundle final para deploy.
- **Purge Artifacts**: Limpa arquivos de depuração e unidades experimentais.
- **Optimized RTL**: Vincula apenas as units necessárias.

---

## 🧪 Arsenal de Testes Unitários

O comando `bv test` centraliza a execução de testes unitários automatizados suportados pela unit `BVTestUtils.pas`.

### `bv test`
Realiza o transpile de todos os componentes, compila as units de teste `.pas` em `tests/` para JS e executa a suíte via **Vitest**.

### `bv new t <Nome>`
Scaffolding instantâneo para arquivos de teste unitário.
- **Exemplo**: `bv new t User` cria o arquivo `tests/User.test.pas` com o template correto.

### `bv list t`
Enumera todos os testes unitários atualmente cadastrados na pasta `tests/`.

### `bv remove t <Nome>`
Remove com segurança um arquivo de teste e seus artefatos transpilados.

---

## 📦 Gerenciamento da Pasta /lib

O BlaiseVue PRO 2.1 introduz o gerenciamento inteligente de bibliotecas externas:
- **Auto-Autoload**: Quaisquer arquivos `.bv` dentro da pasta `lib/` (ou subdiretórios) são registrados como componentes globais no projeto.
- **Injeção de Assets**: Arquivos `.css` e `.js` detectados na pasta `lib/` são injetados automaticamente no `<head>` do `index.html` gerado no `dist/`, sem necessidade de importação manual no seu `app.bv`.

---

## 🛠️ Comandos de Manutenção

### `bv clean`
Limpeza completa do ambiente de build:
1.  Purga a pasta `generated/`.
2.  Purga a pasta `dist/js/` e `dist/css/`.
3.  Reseta o `index.html` no `dist/` para o estado original em `public/`.

---

## ⚡ Performance do CLI
O compilador CLI é escrito inteiramente em **Pascal Nativo**, garantindo uma velocidade de processamento de componentes SFC até **50x mais rápida** que ferramentas concorrentes baseadas em Node.js ou bundlers tradicionais. 🛡️✨🏆
