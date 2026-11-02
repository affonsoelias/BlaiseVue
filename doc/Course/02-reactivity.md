# 🧬 Módulo 02: O Motor Reativo
**Descubra como os dados ganham vida própria na tela.**

No módulo anterior, vimos que o Pascal é o "cérebro" da aplicação. Agora vamos entender o conceito mais importante de qualquer aplicação web moderna: a **Reatividade**.

---

## 📦 1. O Que é uma Variável? (Para Iniciantes)

Se você nunca programou antes, imagine uma variável como uma **caixa com uma etiqueta**:
- A **etiqueta** é o nome que você dá para ela (ex: `nome`, `idade`, `estaLigado`).
- O **conteúdo** é o que você guarda dentro da caixa (ex: o texto `'Carlos'`, o número `25`).
- O **tipo** define o que cabe nessa caixa. No Pascal, somos muito organizados com tipos!

Aqui estão os tipos mais comuns que você usará no dia a dia:

| Tipo em Pascal | O Que Guarda? | Exemplo |
| :--- | :--- | :--- |
| `string` | Textos e palavras (sempre entre aspas simples `'...'`) | `'Maria da Silva'`, `'São Paulo'` |
| `integer` | Números inteiros (positivos ou negativos, sem vírgula) | `0`, `42`, `100`, `-5` |
| `real` | Números com casas decimais (preços, medidas) | `19.90`, `3.1415` |
| `boolean` | Apenas duas opções: Verdadeiro (`true`) ou Falso (`false`) | `true`, `false` |

---

## ⚡ 2. O Que Significa "Reatividade"? (A Analogia do Excel)

Pense em uma planilha do Excel:
- Na célula **A1**, você digita o preço de um pão: `R$ 2,00`.
- Na célula **A2**, você digita a quantidade: `5`.
- Na célula **A3**, você coloca a fórmula de multiplicação: `=A1 * A2`. O Excel mostra `R$ 10,00`.

Se você for até a célula **A2** e mudar a quantidade de `5` para `10`, o que acontece com a célula **A3**?  
**Ela atualiza sozinha na mesma fração de segundo!**

O **BlaiseVue funciona exatamente assim**. Quando você altera o valor de uma variável no código Pascal, o BlaiseVue descobre automaticamente quais partes da página mostram aquele valor e atualiza a tela na hora para o usuário.

---

## 🛠️ 3. Onde Declaramos as Variáveis? (A Seção `data:`)

No arquivo `.bv`, dentro do bloco `<script>`, temos uma seção chamada `data:`. É nela que criamos as variáveis reativas da nossa tela:

```pascal
<script>
  data:
    // Uma caixa de texto para o nome do usuário:
    nomeUsuario: string = 'Ana';
    
    // Uma caixa numérica para contar cliques:
    contador: integer = 0;
    
    // Uma caixa lógica para saber se uma mensagem está visível:
    mensagemAtiva: boolean = true;
</script>
```

Para mostrar esses valores no HTML, usamos a interpolação com chaves duplas:
```html
<template>
  <div>
    <h1>Olá, {{ nomeUsuario }}!</h1>
    <p>O contador está em: {{ contador }}</p>
  </div>
</template>
```

---

## 🚀 4. Exemplo Completo Passo a Passo: O Contador Interativo

Vamos construir juntos um exemplo prático completo: uma tela com botões que somam, diminuem e zeram um contador.

Crie ou substitua o conteúdo do seu componente com este código:

```html
<template>
  <div class="painel-contador">
    <h2>Meu Contador Reativo 🛡️</h2>
    
    <!-- Mostra o valor atual da variável 'pontos' -->
    <div class="display-numero">
      {{ pontos }}
    </div>

    <div class="botoes">
      <!-- @click diz: quando o botão for clicado, execute esta ação -->
      <button class="btn btn-verde" @click="somar">Aumentar (+1)</button>
      <button class="btn btn-vermelho" @click="subtrair">Diminuir (-1)</button>
      <button class="btn btn-cinza" @click="zerar">Zerar</button>
    </div>
  </div>
</template>

<script>
  data:
    pontos: integer = 0;

  methods:
    // Ação 1: Somar 1 ponto
    procedure somar;
    begin
      this['pontos'] := Integer(this['pontos']) + 1;
    end;

    // Ação 2: Diminuir 1 ponto
    procedure subtrair;
    begin
      this['pontos'] := Integer(this['pontos']) - 1;
    end;

    // Ação 3: Voltar o contador para 0
    procedure zerar;
    begin
      this['pontos'] := 0;
    end;
</script>

<style>
  .painel-contador {
    max-width: 350px;
    margin: 40px auto;
    padding: 24px;
    background: #ffffff;
    border-radius: 12px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
    text-align: center;
    font-family: sans-serif;
  }
  .display-numero {
    font-size: 56px;
    font-weight: bold;
    color: #2b6cb0;
    margin: 20px 0;
  }
  .botoes {
    display: flex;
    gap: 8px;
    justify-content: center;
  }
  .btn {
    padding: 10px 16px;
    border: none;
    border-radius: 6px;
    font-size: 14px;
    font-weight: bold;
    cursor: pointer;
    color: white;
  }
  .btn-verde { background-color: #38a169; }
  .btn-vermelho { background-color: #e53e3e; }
  .btn-cinza { background-color: #718096; }
</style>
```

### Entendendo o Código Pascal:
- `data: pontos: integer = 0;`: Inicializa a variável `pontos` valendo zero.
- `this['pontos']`: É a forma como o Pascal acessa os dados do componente atual.
- `Integer(this['pontos']) + 1`: Pega o valor que está lá, soma 1 e guarda de volta na caixa.
- No mesmo instante em que a linha é executada, o BlaiseVue atualiza o número na tela sem piscar!

---

## 🎯 5. Exercício Prático do Módulo 02

Agora é a sua vez de praticar!

1. No código acima, adicione um novo botão chamado **"Dobrar"**.
2. No bloco `methods:`, crie a procedure para ele:
   ```pascal
   procedure dobrar;
   begin
     this['pontos'] := Integer(this['pontos']) * 2;
   end;
   ```
3. Teste no navegador: clique em "Aumentar" até chegar em 5 e depois clique em "Dobrar". O número virou 10? Parabéns, você acaba de programar a sua primeira lógica reativa!

---

## 🏆 Resumo do Que Você Aprendeu
- O que são variáveis e quais os tipos básicos em Pascal (`string`, `integer`, `boolean`).
- Como a reatividade funciona atualizando o HTML em tempo real.
- Como declarar dados em `data:` e criar ações em `methods:`.
- Como conectar o clique de um botão a uma ação usando `@click`.

**No próximo módulo, vamos ensinar nossa página a tomar decisões inteligentes com as Diretivas! Siga para o [Módulo 03: Diretivas Essenciais](03-directives.md)!** ⚔️🛡️✨
