# ✨ Transições CSS Nativa (`<transition>`)

Dê vida às suas interfaces com animações automáticas! O BlaiseVue Pro agora processa nativamente a tag `<transition>`, inspirada no poder visual do Vue.js.

## O Desafio: Animar Elementos Dinâmicos
Quando usamos `b-if` ou `b-show`, os elementos aparecem ou somem instantaneamente. Com a tag `<transition>`, o BlaiseVue injeta classes CSS especiais no ciclo de vida de montagem e desmontagem, permitindo suavidade total no movimento.

## Como Usar

### 1. No seu Template (.bv)
Envolva qualquer elemento que use `b-if` ou `b-show` com a tag `<transition>`. O atributo `name` define o prefixo das classes CSS:

```html
<transition name="maestria">
  <div v-show="painelVisivel" class="panel">
     Eu apareço com maestria! 🛡️
  </div>
</transition>

<button @click="alternar">Alternar Painel</button>
```

### 2. No seu Estilo (<style>)
Você precisa definir as classes que o BlaiseVue irá aplicar. O motor de animação injeta as seguintes classes:

- **`x-enter-active`**: Ativa durante toda a animação de entrada.
- **`x-leave-active`**: Ativa durante toda a animação de saída.
- **`x-enter-from`**: Ponto de partida da animação de entrada (ex: `opacity: 0`).
- **`x-enter-to`**: Ponto final da animação de entrada (ex: `opacity: 1`).
- **`x-leave-to`**: Ponto final da animação de saída (ex: `opacity: 0`).

#### Exemplo de Fade Vertical:
```css
<style>
  .maestria-enter-active, .maestria-leave-active {
     transition: opacity 0.5s, transform 0.5s;
  }
  .maestria-enter-from, .maestria-leave-to {
     opacity: 0;
     transform: translateY(-20px);
  }
  .maestria-enter-to, .maestria-leave-from {
     opacity: 1;
     transform: translateY(0);
  }
</style>
```

## Benefícios
- **Montagem Reativa**: O BlaiseVue detecta quando o elemento termina a animação para retirá-lo completamente do DOM (no caso do `b-if`).
- **Performance Nativa**: O motor usa `requestAnimationFrame` para garantir que o navegador faça o trabalho pesado de GPU de forma otimizada.
- **Micro-interações**: Perfeito para modais, menus laterais (sidebars) e notificações temporárias.
