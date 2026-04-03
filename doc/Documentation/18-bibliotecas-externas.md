# 📦 Gerenciamento de Bibliotecas (/lib)

O BlaiseVue PRO (v2.1+) introduz um sistema de **Gerenciamento de Bibliotecas Externas** com o conceito de "Zero Configuration", permitindo a criação e o compartilhamento de UI Kits e plugins sem a necessidade de importações manuais.

---

## 🏛️ O Conceito da Pasta `/lib`
A pasta `/lib/` na raiz do seu projeto é monitorada automaticamente pelo BlaiseCLI (`bv.exe`). Cada subpasta dentro dela é tratada como um pacote de recursos independente.

### Estrutura Padrão de uma Lib:
```text
/lib
  /bootstrap-bv/
    - BBtn.bv       (Componente Reativo)
    - BCard.bv
    - style.css     (Injetado no Header)
    - vendor.js     (Injetado no Header)
```

---

## 🚀 Poderes Automáticos (Zero Config)

### 1. Auto-Registro de Componentes
Arquivos `.bv` encontrados em qualquer nível dentro de `/lib/` são registrados como **Componentes Globais**.
- **Mapeamento**: O nome do arquivo determina a tag (kebab-case).
- **Sem Sufixo**: Diferente das views em `src/views/`, componentes da biblioteca **NÃO** recebem o sufixo `-page`.
- **Exemplo**: `BBtn.bv` -> utilizável como `<b-btn>` em qualquer template da aplicação.

### 2. Injeção Automática de Assets (CSS/JS)
O BlaiseCLI detecta arquivos de estilo e scripts dentro da pasta lib e realiza o seguinte fluxo durante o `bv run dev` ou `bv run build`:
1.  **Cópia**: Move os arquivos para `dist/css/lib/` ou `dist/js/lib/`.
2.  **Asset Linking**: Insere automaticamente as tags `<link>` e `<script>` no `index.html`.
3.  **Cache-Busting**: Aplica o timestamp de versão (`v=...`) para garantir que o navegador sempre carregue a versão mais recente após alterações.

---

## 🛠️ Comandos do CLI para Bibliotecas

### Instalar via ZIP URL
```bash
bv lib install https://dominio.com/minha-lib.zip
```
O CLI baixa, extrai o conteúdo diretamente na pasta `/lib/` e limpa os arquivos temporários.

### Listar Bibliotecas Ativas
```bash
bv lib list
```

### Remover Biblioteca
```bash
bv lib remove nome-da-pasta
```

---

## 💡 Exemplo Prático: UI Kit Interno
Se você criar um componente `StatusBadge.bv` em `lib/meu-kit/`, você poderá usá-lo imediatamente em sua página `Home.bv`:

```html
<!-- Home.bv -->
<template>
  <div>
    Status: <status-badge variant="success">Online</status-badge>
  </div>
</template>
```
Nenhum `import` ou `uses` é necessário; o BlaiseCLI cuida de toda a orquestração de registro Pascal por baixo dos panos. 🛡️✨🏆

---
_"BlaiseVue: Distribute with Pascal, Run with Zero Config."_ 🛡️📦🚀
