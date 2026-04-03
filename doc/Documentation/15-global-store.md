# 🧠 B-Store (Global Store / $store)

O BlaiseVue PRO resolve o problema de "prop drilling" (passar dados por múltiplos níveis de componentes) com a **B-Store**: um sistema de gerenciamento de estado global reativo, acessível de qualquer ponto da aplicação.

---

## 🏛️ Arquitetura da B-Store
A B-Store é implementada como um **Singleton** reativo baseado em **JS Proxy**. Isso significa que qualquer alteração em uma propriedade da store dispara uma re-renderização em todos os componentes que dependem daquele dado específico.

### 🔥 Vantagens Técnicas:
1.  **Reatividade Global**: Diferente do `data:` (privado), a `$store` é pública para todos os componentes.
2.  **Proxy Mapping**: O BlaiseVue intercepta acessos à store para rastrear dependências automaticamente.
3.  **Persistência SPA**: O estado é mantido durante toda a navegação do roteador, limpando apenas no F5.

---

## 🛠️ Como Utilizar

### 1. Inicializando Dados no App Root (`app.bv`)
Você deve popular a store no hook `created` ou no bloco `provide` do seu componente raiz.

```pascal
{ app.bv }
<script>
  created:
    begin
       { Inicializa chaves globais que serão usadas por toda a UI }
       TJSObject(this['$store'])['appVersion'] := '2.1.0-PRO';
       TJSObject(this['$store'])['user'] := 'Pascal Master 🏆';
    end;
</script>
```

### 2. Acessando na Interface (`<template>`)
Qualquer componente `.bv` pode ler a store diretamente usando o prefixo `$store`:

```html
<template>
  <div class="user-info">
    <p>Bem-vindo, 👤 <strong>{{ $store.user }}</strong></p>
    <p>Build: <code>{{ $store.appVersion }}</code></p>
  </div>
</template>
```

### 3. Modificando o Estado via Pascal
As mutações são síncronas e refletem instantaneamente em todos os componentes.

```pascal
methods:
  procedure atualizarPerfil;
  begin
     { Atualizando o estado global: a UI de outros componentes mudará na hora! }
     TJSObject(this['$store'])['user'] := 'Mestre Blaise ⚔️';
  end;
```

---

## 💡 Boas Práticas
- **Centralização**: Use a B-Store para dados compartilhados (user info, configurações de tema, flags de autenticação).
- **Namespacing**: Se sua app for grande, prefira agrupar dados em objetos, ex: `$store.config.tema`.
- **Performance**: Evite colocar objetos pesados (blobs, buffers grandes) na store reativa para não sobrecarregar o ciclo de re-renderização.

---
_"BlaiseVue: Global State, Local Syntax."_ 🛡️✨🏆
