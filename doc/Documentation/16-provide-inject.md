# 🔗 Elo Sagrado (Provide/Inject)

O BlaiseVue PRO oferece suporte nativo para **Provide/Inject**, uma técnica avançada de injeção de dependências para componentes profundamente aninhados, eliminando a necessidade de passar props manualmente por múltiplos níveis (prop drilling).

---

## 🏗️ Como Funciona o Provide/Inject

- **O Ancestral PROVÊ**: Um componente de nível superior (como o `app.bv`) define dados, objetos ou funções que deseja disponibilizar para sua árvore descendente.
- **O Descendente INJETA**: Qualquer componente filho, neto ou bisneto pode declarar que deseja "injetar" essas dependências.

### 1. Provendo Dados (Componente Pai/Root)
No componente que detém o dado (usualmente o `app.bv`), utilize o bloco `provide`. O retorno deve ser um objeto `TJSObject` contendo as chaves que você deseja expor.

```pascal
{ app.bv }
<script>
  provide:
    var
      env: TJSObject;
    begin
       env := TJSObject.new;
       env['status'] := 'Produção 🛡️';
       env['id'] := 42;
       
       Result := TJSObject.new;
       Result['getAmbiente'] := function(): TJSObject
         begin
            Result := env;
         end;
    end;
</script>
```

### 2. Injetando Dependências (Componente Descendente)
No componente que precisa dos dados, liste as chaves desejadas no bloco `inject`. O BlaiseVue PRO as tornará disponíveis reativamente.

```pascal
{ MeuWidget.bv }
<script>
  inject:
    getAmbiente;

  methods:
    procedure logAmbiente;
    begin
       { Acesso via Pascal: use o prefixo 'this' }
       console.log('Ambiente Injetado: ' + string(this['getAmbiente']().status));
    end;
</script>
```

### 3. Acesso na Interface (Template)
O valor injetado se comporta como um dado do componente e pode ser usado diretamente nas chaves `{{ }}` ou diretivas.

```html
<template>
  <div class="footer">
    Status: <strong>{{ getAmbiente().status }}</strong> (ID: {{ getAmbiente().id }})
  </div>
</template>
```

---

## 🛡️ Benefícios Técnicos
1.  **Desacoplamento Profundo**: O filho não precisa saber a estrutura do pai, apenas que o ID da dependência existe.
2.  **Injeção de Serviços (Plugins)**: Ideal para injetar sistemas de tradução (i18n), motores de log ou configurações de API.
3.  **Prioridade Hierárquica**: Se múltiplos pais fornecerem a mesma chave, o componente filho injetará o valor do precursor mais próximo na árvore DOM.

---
_"BlaiseVue: Vertical DI with Pascal Safety."_ 🛡️✨🏆
