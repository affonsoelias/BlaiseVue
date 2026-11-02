# 🛰️ Módulo 07: Comunicação e Eventos ($emit)
**Fazendo os componentes conversarem entre si e reagirem ao usuário.**

No mundo real, quando alguém aperta a campainha da sua casa:
1. O **botão da campainha** não sabe quem está dentro da casa nem o que você vai fazer. Ele apenas faz: *Plim-Plom!*
2. **Você**, dentro da casa, ouve o som e decide o que fazer: levanta do sofá, olha no olho mágico ou abre o portão.

No BlaiseVue, esse mecanismo é a base de toda a arquitetura de eventos:
- **Props descem:** O pai passa dados para o filho.
- **Eventos sobem ($emit):** O filho avisa o pai quando algo aconteceu!

---

## 👂 1. Escutando Eventos com `@` (ou `b-on:`)

Para fazer um botão ou campo reagir às ações do usuário, usamos a arroba `@` seguida do nome do evento:

| Sintaxe | Quando Dispara? | Exemplo de Uso |
| :--- | :--- | :--- |
| `@click` | Quando o usuário clica com o mouse ou toca na tela | `@click="salvarDados"` |
| `@input` | Toda vez que uma letra é digitada no campo | `@input="verificarTexto"` |
| `@keyup.enter` | Quando o usuário pressiona a tecla **Enter** | `@keyup.enter="enviarMensagem"` |
| `@mouseenter` | Quando o ponteiro do mouse passa por cima | `@mouseenter="mostrarTooltip"` |

As ações que esses eventos chamam ficam sempre organizadas dentro do bloco `methods:` do seu código Pascal:

```pascal
<script>
  methods:
    procedure salvarDados;
    begin
      // Executa quando o botão for clicado!
      WriteLn('Salvando dados no sistema...');
    end;
</script>
```

---

## 📢 2. O Que É o `$emit` (O Filho Avisando o Pai)?

Quando criamos um componente filho — como um botão especial, um formulário ou um item de lista — ele não deve alterar dados do pai diretamente. Em vez disso, ele "grita" um evento para quem quiser ouvir usando `$emit`:

```pascal
// O filho dispara o evento 'comprar' levando o nome do item:
TJSFunction(this['$emit']).apply(this, ['comprar', 'Espada de Pascal']);
```

E no componente pai, nós escutamos com `@comprar`:
```html
<item-loja @comprar="adicionarAoCarrinho"></item-loja>
```

---

## 🚀 3. Exemplo Completo Passo a Passo: O Sistema de Curtidas (Likes)

Vamos construir um exemplo prático com dois arquivos:
1. Um componente filho reutilizável: um botão de curtir com coração (`LikeButton.bv`).
2. Uma página pai que coloca 3 botões na tela e mantém um placar com o **Total Geral de Curtidas**!

---

### Passo 1: Criar o Filho (`src/components/LikeButton.bv`)

Crie o arquivo `LikeButton.bv` na pasta `demo-app/src/components/`:

```html
<template>
  <button class="btn-like" :class="{ 'curtido': foiCurtido }" @click="darLike">
    <span class="icone-coracao">{{ foiCurtido ? '❤️' : '🤍' }}</span>
    <span class="rotulo">{{ rotulo }}</span>
    <span class="contador-badge">{{ contagem }}</span>
  </button>
</template>

<script>
  props:
    rotulo: string = 'Curtir';

  data:
    contagem: integer = 0;
    foiCurtido: boolean = false;

  methods:
    procedure darLike;
    begin
      // 1. Atualiza o estado interno do botão
      this['contagem'] := Integer(this['contagem']) + 1;
      this['foiCurtido'] := true;

      // 2. Avisa o componente Pai que uma curtida aconteceu!
      // Dispara o evento 'curtida-realizada' passando o rótulo do botão
      TJSFunction(this['$emit']).apply(this, ['curtida-realizada', this['rotulo']]);
    end;
</script>

<style>
  .btn-like {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 10px 16px;
    background: #f7fafc;
    border: 2px solid #e2e8f0;
    border-radius: 20px;
    cursor: pointer;
    font-weight: bold;
    font-size: 14px;
    transition: all 0.2s ease;
  }
  .btn-like:hover {
    border-color: #cbd5e0;
    transform: translateY(-2px);
  }
  .curtido {
    border-color: #feb2b2;
    background: #fff5f5;
  }
  .contador-badge {
    background: #edf2f7;
    padding: 2px 8px;
    border-radius: 10px;
    font-size: 12px;
  }
</style>
```

---

### Passo 2: Usar o Botão e Ouvir os Eventos no Pai (`src/views/Home.bv`)

Abra `src/views/Home.bv` e coloque o placar principal:

```html
<template>
  <div class="painel-votacao">
    <h2>🏆 Central de Votação da Comunidade</h2>
    
    <!-- Placar Central que escuta os botões -->
    <div class="placar-total">
      <p class="numero-placar">{{ totalGeral }}</p>
      <span class="legenda">Curtidas Registradas no Total</span>
    </div>

    <p class="ultima-acao" b-if="ultimaNoticia != ''">
      📢 Última novidade: {{ ultimaNoticia }}
    </p>

    <div class="grade-botoes">
      <!-- Escutamos o evento @curtida-realizada disparado pelo filho! -->
      <like-button 
        rotulo="BlaiseVue Framework" 
        @curtida-realizada="registrarVoto">
      </like-button>

      <like-button 
        rotulo="Free Pascal Compiler" 
        @curtida-realizada="registrarVoto">
      </like-button>

      <like-button 
        rotulo="Lazarus IDE" 
        @curtida-realizada="registrarVoto">
      </like-button>
    </div>

  </div>
</template>

<script>
  data:
    totalGeral: integer = 0;
    ultimaNoticia: string = '';

  methods:
    // Esta procedure recebe a mensagem enviada pelo filho via $emit!
    procedure registrarVoto(itemNome: string);
    begin
      // 1. Soma no total geral do placar
      this['totalGeral'] := Integer(this['totalGeral']) + 1;
      
      // 2. Atualiza a mensagem na tela
      this['ultimaNoticia'] := 'Alguém acabou de curtir "' + itemNome + '"!';
    end;
</script>

<style>
  .painel-votacao {
    max-width: 550px;
    margin: 30px auto;
    background: #ffffff;
    padding: 24px;
    border-radius: 16px;
    box-shadow: 0 4px 20px rgba(0,0,0,0.08);
    text-align: center;
    font-family: sans-serif;
  }
  .placar-total {
    background: #ebf8ff;
    padding: 20px;
    border-radius: 12px;
    margin: 20px 0;
  }
  .numero-placar {
    font-size: 48px;
    font-weight: bold;
    color: #2b6cb0;
    margin: 0;
  }
  .legenda {
    font-size: 13px;
    color: #4a5568;
    text-transform: uppercase;
    font-weight: bold;
    letter-spacing: 1px;
  }
  .ultima-acao {
    font-size: 13px;
    color: #2f855a;
    background: #f0fff4;
    padding: 8px;
    border-radius: 6px;
    margin-bottom: 20px;
  }
  .grade-botoes {
    display: flex;
    justify-content: center;
    gap: 12px;
    flex-wrap: wrap;
  }
</style>
```

---

## 🎯 4. Exercício Prático do Módulo 07

1. Clique em qualquer um dos três botões de like. Veja o número no próprio botão subir, o coração ficar vermelho (`❤️`) e, ao mesmo tempo, o placar total geral do pai aumentar!
2. **Desafio**: Adicione um quarto botão para `"mORMot 2 Framework"`. Sem precisar mexer em quase nada de código, ele já se integrará perfeitamente ao placar!

---

## 🏆 Resumo do Que Você Aprendeu
- Como escutar eventos nativos do navegador (`@click`, `@input`, `@keyup.enter`).
- Como organizar a lógica de ações dentro do bloco `methods:`.
- Como usar `$emit` para fazer componentes filhos avisarem seus pais com total desacoplamento.

**Agora que seus componentes conversam, como criamos um sistema com várias páginas sem recarregar a tela? Vamos para o [Módulo 08: Navegação sem Recarregar (Rotas SPA)](08-routing.md)!** ⚔️🛡️✨
