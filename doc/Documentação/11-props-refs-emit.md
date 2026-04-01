# Comunicação: Props, $refs e $emit

A partir da v1.1.0, o BlaiseVue suporta comunicação avançada entre componentes, seguindo os padrões do VueJS, mas mantendo a tipagem e a sintaxe do Object Pascal.

## Props (Pai -> Filho)
Utilizadas para passar dados do componente pai para o filho.

- **Props Estáticas:** Atributos comuns.
- **Props Dinâmicas:** Prefixo `:` ou `b-bind:`.

```html
<user-card name="Blaise" :id="userId"></user-card>
```

## $refs (Acesso Direto)
Permite ao pai chamar métodos que estão dentro do componente filho.

1. Adicione `ref="nome"` na tag.
2. No Pascal, use `TJSObject(this['$refs'])['nome']`.

```pascal
procedure ResetarFilho;
var
  filho: TJSObject;
begin
  filho := TJSObject(TJSObject(this['$refs'])['meuComp']);
  TJSFunction(filho['metodoDoFilho']).apply(filho['$data'], []);
end;
```

## $emit (Filho -> Pai)
Permite ao filho notificar o pai sobre eventos.

1. No filho, chame `this['$emit']('nome-evento', dado)`.
2. No pai, escute com `@nome-evento="metodoNoPai"`.

```html
<!-- No Pai -->
<child-comp @clique-no-filho="OnChildClick"></child-comp>
```

```pascal
// No Filho
procedure Clicado;
begin
  this['$emit']('clique-no-filho', 'Olá pai!');
end;
```
