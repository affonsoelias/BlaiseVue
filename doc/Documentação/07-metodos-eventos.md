# 7. Métodos e Eventos

## Definindo Métodos

Métodos são definidos na seção `methods:` do `<script>`:

```html
<script>
  methods:
    procedure meuMetodo;
    begin
      window.alert('Ola!');
    end;
</script>
```

## Eventos com `@click`

Use `@click="nomeDoMetodo"` para chamar um método ao clicar:

```html
<template>
  <button @click="saudar">Clique aqui</button>
  <button @click="incrementar">+1</button>
  <button @click="decrementar">-1</button>
</template>

<script>
  data:
    contador: integer = 0;

  methods:
    procedure saudar;
    begin
      window.alert('Ola do BlaiseVue!');
    end;

    procedure incrementar;
    begin
      this['contador'] := Integer(this['contador']) + 1;
    end;

    procedure decrementar;
    begin
      this['contador'] := Integer(this['contador']) - 1;
    end;
</script>
```

## Acessando Dados Reativos em Pascal

No BlaiseVue, você pode acessar os dados do componente usando a variável especial `this` (ou `State`) em puro Pascal. Não é mais necessário usar blocos `asm`:

```pascal
methods:
  procedure resetar;
  begin
    this['nome'] := '';
    this['contador'] := 0;
    this['ativo'] := False;
  end;
```

## Chamando APIs do Navegador

O BlaiseVue expõe objetos globais como `window`, `document` e `console` via unit `Web` do Pas2JS, permitindo uso direto sem `asm`:

```pascal
methods:
  procedure logarNoConsole;
  begin
    console.log('Valor atual:', this['nome']);
  end;

  procedure navegar;
  begin
    window.location.hash := '#/about';
  end;

  procedure confirmar;
  begin
    if window.confirm('Tem certeza?') then
    begin
      this['confirmado'] := True;
    end;
  end;
```

## Exemplo Completo (Puro Pascal)

```html
<template>
  <div>
    <h2>Contador: {{ valor }}</h2>
    <button @click="incrementar">+</button>
    <button @click="decrementar">-</button>
    <button @click="resetar">Zerar</button>
  </div>
</template>

<script>
  data:
    valor: integer = 0;

  methods:
    procedure incrementar;
    begin
      this['valor'] := Integer(this['valor']) + 1;
    end;

    procedure decrementar;
    begin
      this['valor'] := Integer(this['valor']) - 1;
    end;

    procedure resetar;
    begin
      this['valor'] := 0;
    end;
</script>
```
