# 9. Router SPA

O BlaiseVue inclui um router SPA baseado em **hash** (`#/rota`).

## Configuração Básica

No `app.bv`, defina as rotas na seção `router:`:

```html
<template>
  <div>
    <nav>
      <a href="#/">Home</a>
      <a href="#/about">Sobre</a>
    </nav>
    <router-view></router-view>
  </div>
</template>

<script>
  router:
    routes:
      '/': 'home-page';
      '/about': 'about-page';
</script>
```

A tag `<router-view></router-view>` é onde o conteúdo da página ativa é renderizado.

## Navegação

Use links com `href="#/rota"`:

```html
<a href="#/">Home</a>
<a href="#/about">Sobre</a>
<a href="#/user/42">User 42</a>
```

Ou navegue via Pascal:
 ```pascal
 methods:
   procedure irParaHome;
   begin
     window.location.hash := '#/';
   end;
 ```
 
 ## Params Dinâmicos
 
 Defina segmentos dinâmicos com `:nome`:
 
 ```
 router:
   routes:
     '/user/:id': 'user-profile-page';
 ```
 
 O valor do param é injetado automaticamente nos dados do componente pelo compilador:
 
 ```html
 <!-- src/views/UserProfile.bv -->
 <template>
   <div>
     <h1>Usuario #{{ id }}</h1>
   </div>
 </template>
 
 <script>
   data:
     id: string = '';
 </script>
 ```
 
 Ao navegar para `#/user/42`, o `{{ id }}` exibe `42`.
 
 ## Query Strings
 
 Query strings são parseadas automaticamente:
 
 ```
 URL: #/user/7?tab=config&tema=dark
 ```
 
 Os valores são injetados nos dados do componente se as chaves existirem no `data:`:
 
 ```html
 <template>
   <div>
     <p>ID: {{ id }}</p>
     <p>Tab: {{ tab }}</p>
     <p>Tema: {{ tema }}</p>
   </div>
 </template>
 
 <script>
   data:
     id: string = '';
     tab: string = '';
     tema: string = '';
 </script>
 ```
 
 ## Acessando Dados da Rota em Pascal
 
 Como o BlaiseVue injeta params e query strings diretamente no objeto de dados, você pode acessá-los em qualquer método usando o `this` (ou `State`) em Pascal puro:
 
 ```pascal
 methods:
   procedure checarPerfil;
   var
     userId: string;
   begin
     userId := string(this['id']);
     console.log('Visualizando perfil do usuario: ' + userId);
   end;
 ```
 
 ## Guards (Proteção de Rotas)
 
 > **Nota:** Guards avançados (beforeEach, beforeEnter) são funcionalidades para usuários experientes. O formato `.bv` suporta o mapeamento básico, mas lógica de proteção complexa deve ser implementada nos arquivos Pascal gerados ou estendendo o core.
 
 ### Guard Global (via Pascal)
 
 Para guards avançados, você pode assinar eventos no objeto `router` no arquivo gerado `uApp.pas`.
 
 ```pascal
 // No app code manual:
 router.BeforeEach := function(toRoute: TJSObject): JSValue
 begin
   if not isLoggedIn then Result := '/login' else Result := True;
 end;
 ```

## Exemplo Completo

```html
<template>
  <div>
    <nav>
      <a href="#/">Home</a>
      <a href="#/user/1">User 1</a>
      <a href="#/user/42?tab=posts">User 42</a>
    </nav>
    <router-view></router-view>
  </div>
</template>

<script>
  data:
    titulo: string = 'Minha App SPA';

  router:
    routes:
      '/': 'home-page';
      '/user/:id': 'user-profile-page';
</script>
```
