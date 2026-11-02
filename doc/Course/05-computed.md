# 🧠 Módulo 05: O Poder do Cérebro (Computed Properties)
**Faça o BlaiseVue calcular fórmulas e tomar decisões automáticas para você.**

No módulo anterior, vimos que o `b-model` sincroniza o que o usuário digita diretamente em uma variável. Mas e quando você precisa fazer uma conta com esses dados — como somar dois números, calcular um desconto ou juntar o primeiro nome com o sobrenome?

É aí que entram as **Propriedades Calculadas (`computed`)**!

---

## 🧮 1. Por Que Usar `computed` em Vez de Contas no HTML?

Você poderia pensar em tentar colocar contas diretamente dentro do HTML:
```html
<!-- EVITE FAZER ISSO: Fica feio e difícil de entender -->
<p>Total: {{ (preco * quantidade) - ((preco * quantidade) * 0.1) }}</p>
```

Colocar fórmulas no meio do HTML tem dois grandes problemas:
1. **O código fica confuso e difícil de manter**.
2. **Desempenho**: O navegador teria que refazer essa conta o tempo todo!

Com o bloco `computed:`, nós criamos uma função em Pascal limpa e elegante. O BlaiseVue guarda o resultado em **Cache Inteligente**: ele só recalcula a conta se o preço ou a quantidade realmente mudarem!

---

## 📐 2. Como Declarar uma Função no Bloco `computed:`

No Pascal, uma função (`function`) é um bloco de código que faz um cálculo e devolve uma resposta através da palavra mágica `Result`:

```pascal
<script>
  data:
    primeiroNome: string = 'Blaise';
    sobrenome: string = 'Pascal';

  computed:
    // Uma propriedade calculada que junta os dois nomes:
    function nomeCompleto: string;
    begin
      Result := string(this['primeiroNome']) + ' ' + string(this['sobrenome']);
    end;
</script>
```

No HTML, usamos `{{ nomeCompleto }}` exatamente como se fosse uma variável comum:
```html
<h1>Bem-vindo, {{ nomeCompleto }}!</h1>
```

---

## 🚀 3. Exemplo Completo Passo a Passo: O Simulador de Compras

Vamos construir um simulador de compras em tempo real. O usuário escolhe o produto, ajusta a quantidade e o cupom de desconto, e o BlaiseVue calcula Subtotal, Desconto, Total e se tem direito a Frete Grátis!

Copie e cole este código no seu arquivo de visualização (ex: `src/views/Home.bv`):

```html
<template>
  <div class="caixa-compra">
    <h2>🛒 Simulador de Pedido Reativo</h2>

    <!-- Entradas do Usuário -->
    <div class="grid-campos">
      <div class="campo">
        <label>Preço Unitário (R$):</label>
        <input type="number" b-model="precoUnitario" min="0" step="10">
      </div>

      <div class="campo">
        <label>Quantidade:</label>
        <input type="number" b-model="quantidade" min="1" max="100">
      </div>
    </div>

    <div class="campo-cupom">
      <label>
        <input type="checkbox" b-model="temCupom">
        Aplicar Cupom Promocional (10% OFF) 🎟️
      </label>
    </div>

    <hr class="divisor">

    <!-- Resumo dos Cálculos Feitos pelo 'computed' -->
    <div class="resumo-financeiro">
      <div class="linha-resumo">
        <span>Subtotal:</span>
        <strong>R$ {{ subtotal.toFixed(2) }}</strong>
      </div>

      <div class="linha-resumo desconto" b-if="temCupom">
        <span>Desconto (10%):</span>
        <strong>- R$ {{ valorDesconto.toFixed(2) }}</strong>
      </div>

      <div class="linha-resumo total">
        <span>Total a Pagar:</span>
        <span class="valor-total">R$ {{ totalFinal.toFixed(2) }}</span>
      </div>

      <!-- Mensagem calculada dinamicamente -->
      <div class="aviso-frete" :class="freteGratis ? 'frete-ok' : 'frete-alerta'">
        {{ statusFrete }}
      </div>
    </div>

  </div>
</template>

<script>
  data:
    precoUnitario: real = 50.00;
    quantidade: integer = 2;
    temCupom: boolean = false;

  computed:
    // 1. Calcula o subtotal bruto (preço * quantidade)
    function subtotal: real;
    begin
      Result := Real(this['precoUnitario']) * Integer(this['quantidade']);
    end;

    // 2. Calcula o valor economizado com o cupom de 10%
    function valorDesconto: real;
    begin
      if Boolean(this['temCupom']) then
        Result := Real(this['subtotal']) * 0.10
      else
        Result := 0.0;
    end;

    // 3. Calcula o valor final a pagar
    function totalFinal: real;
    begin
      Result := Real(this['subtotal']) - Real(this['valorDesconto']);
    end;

    // 4. Retorna verdadeiro se a compra atingir R$ 150,00
    function freteGratis: boolean;
    begin
      Result := Real(this['totalFinal']) >= 150.00;
    end;

    // 5. Gera um texto amigável de incentivo
    function statusFrete: string;
    var
      falta: real;
    begin
      if Boolean(this['freteGratis']) then
        Result := '🚚 Parabéns! Você ganhou FRETE GRÁTIS!'
      else
      begin
        falta := 150.00 - Real(this['totalFinal']);
        Result := 'Faltam apenas R$ ' + falta.toFixed(2) + ' para FRETE GRÁTIS!';
      end;
    end;
</script>

<style>
  .caixa-compra {
    max-width: 460px;
    margin: 30px auto;
    background: #ffffff;
    padding: 24px;
    border-radius: 12px;
    box-shadow: 0 4px 18px rgba(0,0,0,0.08);
    font-family: sans-serif;
  }
  .grid-campos {
    display: flex;
    gap: 16px;
  }
  .campo {
    flex: 1;
    margin-bottom: 12px;
  }
  .campo label {
    display: block;
    font-size: 13px;
    font-weight: bold;
    color: #4a5568;
    margin-bottom: 4px;
  }
  .campo input {
    width: 100%;
    padding: 8px 12px;
    border: 1px solid #cbd5e0;
    border-radius: 6px;
    font-size: 15px;
    box-sizing: border-box;
  }
  .campo-cupom {
    margin: 10px 0 16px 0;
    font-size: 14px;
    color: #2b6cb0;
  }
  .divisor {
    border: 0;
    height: 1px;
    background: #e2e8f0;
    margin: 16px 0;
  }
  .linha-resumo {
    display: flex;
    justify-content: space-between;
    padding: 6px 0;
    font-size: 14px;
  }
  .desconto {
    color: #e53e3e;
  }
  .total {
    margin-top: 8px;
    padding-top: 10px;
    border-top: 2px dashed #cbd5e0;
    font-size: 18px;
    font-weight: bold;
  }
  .valor-total {
    color: #2b6cb0;
    font-size: 22px;
  }
  .aviso-frete {
    margin-top: 16px;
    padding: 10px;
    border-radius: 6px;
    font-size: 13px;
    text-align: center;
    font-weight: bold;
  }
  .frete-ok { background: #c6f6d5; color: #22543d; }
  .frete-alerta { background: #feebc8; color: #7b341e; }
</style>
```

---

## 🎯 4. Exercício Prático do Módulo 05

1. Experimente alterar a quantidade para `4`. Veja o total e a mensagem de frete mudarem na hora.
2. Marque a opção do cupom de desconto de 10% e veja o desconto e o valor final atualizarem juntos!
3. **Desafio**: Adicione uma nova propriedade calculada chamada `impostoEstimado` que calcule 5% sobre o `totalFinal`. Mostre esse valor no resumo!

---

## 🏆 Resumo do Que Você Aprendeu
- Por que usar `computed` para fórmulas em vez de sujar o HTML.
- Como escrever funções no Pascal usando `Result := ...`.
- Como propriedades calculadas dependem de outras e atualizam em cascata com alta velocidade e cache.

**Pronto para dividir sua aplicação em peças de LEGO organizadas? Siga para o [Módulo 06: Componentes SFC (.bv)](06-components.md)!** ⚔️🛡️✨
