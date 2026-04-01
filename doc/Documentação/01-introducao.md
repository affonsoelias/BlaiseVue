# 🛡️ BlaiseVue: Arquitetura e Missão (Referência Técnica)

O BlaiseVue é um framework **SPA (Single Page Application)** construído em **Object Pascal** e transpilado para JavaScript via **pas2js**. Ele foi desenhado para trazer a robustez de tipos do Pascal para o ecossistema frontend moderno.

---

## 🏗️ Stack Tecnológica
- **Linguagem**: Object Pascal (FreePascal 3.2+)
- **Transpilador**: [pas2js 3.2.0](https://wiki.freepascal.org/pas2js)
- **Runtime**: Proxy-based DOM manipulation (idêntico ao Vue.js 3 internals).
- **Tooling**: `bv.exe` (CLI nativo compilado em FPC).

---

## 🧬 Princípios de Engenharia

### 1. Sistema de Proxies
O BlaiseVue mapeia o estado Pascal (`FData`) para um objeto Proxy em JavaScript. Isso permite detecção de mudanças granular sem a necessidade de um Virtual DOM pesado, permitindo atualizações cirúrgicas no DOM real.

### 2. SFC (Single File Components)
Componentes BlaiseVue (`.bv`) são arquivos de estrutura tripla (template, script, style) processados pelo CLI. O CLI extrai o template HTML, traduz o código Pascal para Pas2JS e injeta o CSS no header da aplicação de forma dinâmica.

### 3. Roteamento Hash-Based
O ecossistema utiliza um roteador baseado em Hash para garantir compatibilidade com servidores estáticos, gerenciando o ciclo de vida dos componentes conforme a URL muda no cliente.

---

## ⚡ Performance Inicial
O tempo de inicialização do motor reativo BlaiseVue é inferior a **10ms**, graças à ausência de overhead de renderização virtual na primeira montagem. 🛡️✨🏆
