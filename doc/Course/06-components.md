# 🏰 Módulo 06: Componentes SFC (.bv) - Construindo com Blocos de LEGO
**Divida o seu sistema em peças pequenas, reutilizáveis e fáceis de manter.**

Imagine que você está montando um castelo de LEGO. Em vez de moldar o castelo inteiro em uma única pedra gigante, você usa vários bloquinhos pequenos: tijolos, janelas, portas e telhados. Se uma janela quebrar, você só conserta aquela janela!

No desenvolvimento de software moderno, cada um desses bloquinhos é um **Componente**!

---

## 🧱 1. Por Que Usar Componentes?

Quando você começa um projeto sem componentes, o seu arquivo HTML rapidamente fica com 1.000 ou 2.000 linhas de código confuso e impossível de ler.

Com os componentes do BlaiseVue (`.bv`):
1. **Reutilização**: Você cria um `<cartao-usuario>` uma única vez e pode usá-lo 10, 50 ou 100 vezes em páginas diferentes.
2. **Organização**: Cada componente fica em seu próprio arquivo dentro da pasta `src/components/`.
3. **Foco**: Se você precisar mudar o estilo do botão, você só abre o arquivo daquele botão!

---

## 🏷️ 2. Como o BlaiseVue Dá Nome aos Componentes?

O BlaiseVue possui um compilador muito inteligente. Você não precisa ficar fazendo `import` manual de dezenas de arquivos!

Basta criar o arquivo dentro da pasta `src/components/`:
- Se o arquivo se chama `ProductCard.bv`, o BlaiseVue cria a tag `<product-card>`.
- Se o arquivo se chama `UserBadge.bv`, ele cria a tag `<user-badge>`.
- Se o arquivo se chama `AppHeader.bv`, ele cria a tag `<app-header>`.

---

## 🎁 3. O Que São `props:` (Passando Dados do Pai para o Filho)?

Pense em um crachá de identificação. O crachá tem sempre o mesmo formato físico de plástico, mas o **nome** e a **foto** impressos mudam para cada pessoa.

No BlaiseVue, essas informações que vêm de fora para dentro do componente são chamadas de **`props`**:

```pascal
<script>
  // Props: Dados que o componente recebe de quem o chamou
  props:
    titulo: string;
    preco: real;
    emPromocao: boolean;
</script>
```

---

## 🚀 4. Exemplo Completo Passo a Passo: Criando e Usando um Card de Produto

Vamos criar juntos um componente de vitrine de produtos!

### Passo 1: Criar o Componente Filho (`src/components/ProductCard.bv`)

Crie um novo arquivo chamado `ProductCard.bv` dentro da pasta `demo-app/src/components/`:

```html
<template>
  <div class="cartao-produto" :class="{ 'em-destaque': emDestaque }">
    <div class="icone-produto">{{ icone }}</div>
    <h3 class="nome-produto">{{ nome }}</h3>
    <p class="descricao-produto">{{ descricao }}</p>
    
    <div class="rodape-produto">
      <span class="preco-texto">R$ {{ preco.toFixed(2) }}</span>
      <button class="btn-comprar" @click="avisarClique">Comprar</button>
    </div>
  </div>
</template>

<script>
  // Declara os dados que o componente espera receber do pai:
  props:
    icone: string = '📦';
    nome: string = 'Produto';
    descricao: string = '';
    preco: real = 0.0;
    emDestaque: boolean = false;

  methods:
    procedure avisarClique;
    begin
      TJSFunction(this['$emit']).apply(this, ['adicionado', this['nome']]);
    end;
</script>

<style>
  .cartao-produto {
    background: #ffffff;
    border: 1px solid #e2e8f0;
    border-radius: 10px;
    padding: 16px;
    width: 220px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.05);
    text-align: center;
    font-family: sans-serif;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
  }
  .em-destaque {
    border: 2px solid #3182ce;
    background: #ebf8ff;
  }
  .icone-produto {
    font-size: 40px;
    margin-bottom: 8px;
  }
  .nome-produto {
    margin: 4px 0;
    font-size: 16px;
    color: #2d3748;
  }
  .descricao-produto {
    font-size: 12px;
    color: #718096;
    margin-bottom: 12px;
  }
  .rodape-produto {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
  .preco-texto {
    font-weight: bold;
    color: #2b6cb0;
    font-size: 15px;
  }
  .btn-comprar {
    background: #38a169;
    color: white;
    border: none;
    padding: 6px 12px;
    border-radius: 6px;
    cursor: pointer;
    font-weight: bold;
  }
  .btn-comprar:hover { background: #2f855a; }
</style>
```

---

### Passo 2: Usar o Componente na Página Principal (`src/views/Home.bv`)

Agora abra `src/views/Home.bv` e utilize o seu novo `<product-card>` passando os valores com facilidade:

```html
<template>
  <div class="vitrine-loja">
    <h2>🏪 Vitrine de Cursos Pascal</h2>

    <div class="grid-produtos">
      <!-- Usando o mesmo componente várias vezes com dados diferentes! -->
      <product-card 
        icone="🛡️" 
        nome="Pascal Básico" 
        descricao="Aprenda a sintaxe mais limpa da programação." 
        :preco="99.90"
        :em-destaque="false">
      </product-card>

      <product-card 
        icone="⚡" 
        nome="BlaiseVue Ninja" 
        descricao="Construa SPAs ultrarrápidas para Web e Mobile." 
        :preco="199.90"
        :em-destaque="true">
      </product-card>

      <product-card 
        icone="🚀" 
        nome="mORMot 2 Backend" 
        descricao="Servidores SOA de alta performance em Pascal." 
        :preco="249.90"
        :em-destaque="false">
      </product-card>
    </div>

  </div>
</template>

<style>
  .vitrine-loja {
    max-width: 800px;
    margin: 30px auto;
    font-family: sans-serif;
  }
  .grid-produtos {
    display: flex;
    gap: 20px;
    justify-content: center;
    flex-wrap: wrap;
  }
</style>
```

> [!TIP]
> **Por que tem dois pontos `:` antes de `:preco`?**  
> Quando você escreve `nome="Pascal"`, você está passando um texto simples. Mas quando você quer passar um número ou um valor de variável Pascal, colocamos dois pontos na frente: `:preco="199.90"`. Isso avisa o BlaiseVue para interpretar o valor como uma expressão Pascal!

---

## 🎯 5. Exercício Prático do Módulo 06

1. Adicione um quarto card de produto na vitrine (por exemplo: `"Banco de Dados com Pascal"`, preço `149.90`, ícone `💾`).
2. Mude `:em-destaque="true"` no novo card e observe a borda azul e o destaque visual aparecerem automaticamente nele!

---

## 🏆 Resumo do Que Você Aprendeu
- Como dividir sua aplicação em blocos modulares reutilizáveis.
- Como o BlaiseVue registra automaticamente seus arquivos `.bv` como tags HTML.
- Como passar informações de pai para filho através de `props:`.
- Como usar a sintaxe de ligação `:` para passar números e variáveis.

**Agora que os componentes sabem se vestir, como fazemos eles conversarem entre si? Vamos para o [Módulo 07: Comunicação e Eventos ($emit)](07-events.md)!** ⚔️🛡️✨
