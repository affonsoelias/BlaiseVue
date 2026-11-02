# 🛡️ Módulo 11: Recursos Pro (Master Architecture)
**Aprenda as técnicas arquiteturais que os profissionais usam em aplicações de grande porte.**

Parabéns por chegar até aqui! Você já domina reatividade, diretivas, formulários, componentes e rotas. Agora vamos dar um salto de qualidade e aprender os padrões que mantêm sistemas corporativos gigantes organizados, elegantes e fáceis de evoluir.

---

## 🖼️ 1. Composição Avançada com `<slot>` (A Moldura de Quadro)

Nos módulos anteriores, vimos como passar dados para componentes usando `props:` (como texto ou números). Mas e se você quiser que um componente receba **pedaços inteiros de HTML** de fora?

Pense em uma **moldura de quadro**: a moldura tem a borda dourada, o vidro e o suporte na parede, mas a foto que vai dentro quem escolhe é você! No BlaiseVue, usamos a tag **`<slot>`** para deixar esse "espaço reservado":

### O Componente Moldura (`src/components/CardMoldura.bv`):
```html
<template>
  <div class="cartao-moldura">
    <div class="cabecalho-moldura">
      <!-- Slot nomeado para o título do cabeçalho -->
      <slot name="cabecalho"></slot>
    </div>

    <div class="corpo-moldura">
      <!-- Slot padrão para qualquer conteúdo que vier de fora -->
      <slot></slot>
    </div>
  </div>
</template>
```

### Usando a Moldura na Página:
```html
<card-moldura>
  <!-- Encaixa no slot name="cabecalho": -->
  <template #cabecalho>
    <h3>🔒 Área Restrita</h3>
  </template>

  <!-- Encaixa no slot padrão: -->
  <p>Digite sua senha para desbloquear os dados sigilosos.</p>
  <button class="btn btn-primary">Confirmar</button>
</card-moldura>
```

---

## 🧠 2. Estado Global Compartilhado ($store / B-Store)

Imagine que a sua aplicação tem um **Carrinho de Compras**:
- O menu superior precisa mostrar quantos itens estão no carrinho.
- A página do produto precisa ter um botão "Adicionar ao Carrinho".
- A página de checkout precisa listar os itens e calcular o valor final.

Ficar passando esses dados de pai para filho através de 10 níveis de componentes seria cansativo e fácil de errar (o chamado *Prop Drilling*).

Em vez disso, usamos a analogia da **caixa d'água central**: a caixa d'água fica no topo da casa e todos os cômodos pegam água diretamente dela através de canos! No BlaiseVue, esse repositório central é o **`$store`**:

```pascal
// Qualquer tela pode ler o estado central:
quantidadeItens := Integer(this['$store']['carrinhoTotal']);

// E qualquer botão pode alterar o estado central:
procedure adicionarAoCarrinho;
begin
  this['$store']['carrinhoTotal'] := Integer(this['$store']['carrinhoTotal']) + 1;
end;
```

---

## ✨ 3. Animações e Transições Suaves (`<transition>`)

Elementos que aparecem e somem da tela de forma instantânea e seca deixam a interface com cara de rascunho. Com a tag **`<transition>`**, o BlaiseVue injeta animações suaves de desvanecimento (*fade*) ou deslizamento (*slide*) automaticamente!

```html
<template>
  <div>
    <button @click="abrirAviso">Alternar Alerta</button>

    <!-- Envolva seu b-if com a tag transition -->
    <transition name="fade">
      <div b-if="mostrarAviso" class="caixa-alerta">
        🛡️ Notificação: Seu backup foi concluído com sucesso!
      </div>
    </transition>
  </div>
</template>

<style>
  /* O BlaiseVue controla estas classes de animação para você: */
  .fade-enter-active, .fade-leave-active {
    transition: opacity 0.4s ease, transform 0.4s ease;
  }
  .fade-enter, .fade-leave-to {
    opacity: 0;
    transform: translateY(-10px);
  }
</style>
```

---

## 💉 4. Injeção de Dependências (Provide / Inject)

Quando você quer que um componente de topo (como a raiz `App.bv`) disponibilize uma configuração global (por exemplo: o idioma ativo `'pt-BR'` ou um serviço de logs) para qualquer componente que estiver lá no fundo da árvore hierárquica, usamos **`provide`** no pai e **`inject`** no neto/bisneto:

```pascal
// No componente Pai (App.bv):
provide:
  appTema: 'dark';
  versaoApp: 'v4.4.0';

// No componente Filho em qualquer nível de profundidade:
inject:
  appTema: string;
```

---

## 🎯 5. Exercício Prático do Módulo 11

1. Crie um componente chamado `ModalDialog.bv` usando `<slot>` para o título e o corpo da mensagem.
2. Envolva a exibição desse modal com uma tag `<transition name="fade">`.
3. Adicione um botão para abrir e fechar o modal e veja como a transição suave faz toda a diferença na qualidade percebida da sua aplicação!

---

## 🏆 Resumo do Que Você Aprendeu
- Como criar estruturas flexíveis e reutilizáveis usando `<slot>` e slots nomeados.
- Como compartilhar informações entre telas distantes usando o B-Store central.
- Como transformar interfaces duras em experiências fluidas com `<transition>`.
- Como transmitir configurações de forma limpa usando `provide` e `inject`.

**Quer ter 100% de certeza de que o seu código nunca vai quebrar sem você perceber? Vamos aprender no [Módulo 12: Qualidade Marcial (Testes Unitários)](12-tests.md)!** ⚔️🛡️✨
