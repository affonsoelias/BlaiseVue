# 🧠 B-Store (Global Store / $store)

O BlaiseVue Pro resolve o problema clássico de "prop drilling" (passar dados de pai para filho muitas vezes) com a **B-Store**, um sistema de gerenciamento de estado global único acessível em qualquer componente.

## O Que é a B-Store?
Imagine que você tem uma variável `usuarioLogado` ou `versaoApp`. Ela é necessária em 50 componentes diferentes. Em vez de passar por todos os caminhos, todos eles apenas olham para o "Cérebro Central" do BlaiseVue: a B-Store.

## Como Usar

### 1. No seu App Principal (Root)
Você pode inicializar dados globais no hook `created` da sua `app.bv` ou no seu código Pascal:

```pascal
// app.bv
created:
  begin
    TJSObject(JSThis['$store'])['appVersion'] := '2.0.0-PRO';
    TJSObject(JSThis['$store'])['user'] := 'Pascal Master 🏆';
  end;
```

### 2. Acesso em Qualquer Componente (.bv)
Qualquer componente `.bv` pode ler ou escrever na store usando o prefixo `$store` dentro das chaves de interpolação:

```html
<template>
  <div>
    <p>Bem-vindo, <strong>{{ $store.user }}</strong></p>
    <p>Versão do App: {{ $store.appVersion }}</p>
  </div>
</template>
```

### 3. Mutação de Estado
Para mudar o valor, você pode fazer de dentro de um método Pascal:

```pascal
methods:
  procedure mudarNome;
  begin
    TJSObject(JSThis['$store'])['user'] := 'Novo Usuário ⚔️';
  end;
```

## Benefícios
- **Single Source of Truth**: Todos os componentes veem o mesmo valor instantaneamente.
- **Sincronia Global**: Quando um valor muda na store, **TODOS** os componentes que o usam se atualizam reativamente no mesmo milissegundo.
- **Redução de Acoplamento**: Componentes não precisam saber sobre seus pais para obter dados comuns de configuração ou estado.

---
**Nota**: A B-Store é persistente durante toda a sessão da aplicação SPA, sendo reiniciada apenas ao recarregar a página (F5).
