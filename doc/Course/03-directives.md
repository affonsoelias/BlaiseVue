# 📜 Módulo 03: Diretivas Essenciais (b-if, b-for e b-show)
**Ensine a sua tela a tomar decisões e a exibir listas automaticamente.**

Imagine que você está criando uma loja virtual:
- Se o usuário estiver logado, você quer mostrar o botão **"Sair"**.
- Se ele não estiver logado, você quer mostrar o botão **"Entrar"**.
- Se ele tiver 10 produtos no carrinho, você não quer ter que escrever 10 vezes o mesmo bloco de HTML à mão!

Para resolver tudo isso de forma elegante, usamos as **Diretivas**!

---

## 🧭 1. O Que é uma Diretiva?

Uma diretiva é uma palavra especial (que começa com `b-` no BlaiseVue) que colocamos dentro de uma tag HTML para dar a ela um comportamento inteligente.

> [!TIP]
> **Compatibilidade com Vue.js:**  
> Se você já viu tutoriais de Vue.js na internet usando `v-if`, `v-for`, etc., fique tranquilo: o BlaiseVue aceita tanto o prefixo `b-` quanto o `v-` de forma intercambiável! Você pode usar `b-if` ou `v-if` com o mesmo resultado.

---

## 🔀 2. Decisões na Tela: `b-if`, `b-else-if` e `b-else`

Assim como na vida fazemos escolhas (*"Se chover, levo guarda-chuva; senão, levo óculos de sol"*), no BlaiseVue usamos o `b-if`:

```html
<!-- Se a variável usuarioLogado for verdadeira (true), mostra a saudação: -->
<p b-if="usuarioLogado">Bem-vindo de volta! 🛡️</p>

<!-- Se for falsa (false), mostra o botão de login: -->
<p b-else>Por favor, faça seu login para continuar. ⚔️</p>
```

Você também pode encadear várias opções com `b-else-if`:
```html
<span b-if="pontos >= 100" class="badge ouro">Nível Ouro 🏆</span>
<span b-else-if="pontos >= 50" class="badge prata">Nível Prata 🥈</span>
<span b-else class="badge bronze">Nível Iniciante 🥉</span>
```

---

## 👁️ 3. Qual a Diferença Entre `b-if` e `b-show`?

Tanto o `b-if` quanto o `b-show` servem para ocultar ou exibir coisas, mas eles funcionam de formas diferentes por baixo do capô:

| Diretiva | Como Funciona? | Quando Usar? |
| :--- | :--- | :--- |
| **`b-if`** | Destrói ou cria o elemento no HTML de verdade. | Quando a condição não muda com frequência (ex: usuário com permissão de administrador ou não). |
| **`b-show`** | O elemento sempre existe no HTML, mas fica invisível com CSS (`display: none`). | Quando você precisa alternar muitas vezes na tela (ex: abrir e fechar uma caixa de menu ou popup com um clique). |

---

## 🔁 4. Repetindo Listas Sem Esforço: `b-for`

Em vez de escrever linhas repetidas no HTML, guardamos os itens em uma lista no Pascal e pedimos para o `b-for` desenhar um por um:

```html
<ul>
  <!-- Para cada 'fruta' dentro da lista 'cesta', desenhe um item <li> -->
  <li b-for="fruta in cesta">
    🍎 {{ fruta }}
  </li>
</ul>
```

---

## 🚀 5. Exemplo Completo Passo a Passo: Lista de Tarefas Interativa

Vamos criar um aplicativo completo de tarefas onde podemos:
1. Listar tarefas cadastradas com `b-for`.
2. Mostrar um aviso com `b-if` se não houver tarefas.
3. Abrir e fechar a visualização usando `b-show`.
4. Marcar tarefas como concluídas com um clique.

Copie e cole este código no seu arquivo de visualização (ex: `src/views/Home.bv`):

```html
<template>
  <div class="cartao-tarefas">
    <h2>Minha Lista de Tarefas 🛡️</h2>

    <!-- Botão para alternar a visualização da lista inteira -->
    <button class="btn-toggle" @click="alternarVisibilidade">
      {{ visivel ? 'Esconder Tarefas' : 'Mostrar Tarefas' }}
    </button>

    <!-- b-show: Mostra ou esconde o container suavemente -->
    <div b-show="visivel" class="conteudo-lista">
      
      <!-- b-if: Se a lista estiver vazia, mostra esta mensagem de descanso -->
      <div b-if="tarefas.length == 0" class="aviso-vazio">
        🎉 Parabéns! Você não tem nenhuma tarefa pendente.
      </div>

      <!-- b-else: Se a lista NÃO estiver vazia, desenha as tarefas -->
      <ul b-else class="lista">
        <li b-for="item in tarefas" class="item-tarefa">
          <span :class="{ 'concluida': item.feita }">
            {{ item.titulo }}
          </span>
          <button class="btn-acao" @click="concluir(item)">
            {{ item.feita ? 'Desfazer' : 'Concluir' }}
          </button>
        </li>
      </ul>

    </div>
  </div>
</template>

<script>
  data:
    visivel: boolean = true;
    tarefas: TJSArray;

  methods:
    // Alterna entre verdadeiro e falso
    procedure alternarVisibilidade;
    begin
      this['visivel'] := not Boolean(this['visivel']);
    end;

    // Alterna o status da tarefa clicada
    procedure concluir(item: TJSObject);
    begin
      item['feita'] := not Boolean(item['feita']);
    end;

  mounted:
    // Quando a tela carregar, colocamos 3 tarefas iniciais na lista:
    procedure;
    var
      t1, t2, t3: TJSObject;
    begin
      this['tarefas'] := TJSArray.new;
      
      t1 := TJSObject.new;
      t1['titulo'] := 'Instalar o BlaiseVue com bv doctor';
      t1['feita'] := true;
      TJSArray(this['tarefas']).push(t1);

      t2 := TJSObject.new;
      t2['titulo'] := 'Aprender variáveis no Módulo 02';
      t2['feita'] := true;
      TJSArray(this['tarefas']).push(t2);

      t3 := TJSObject.new;
      t3['titulo'] := 'Dominar diretivas no Módulo 03';
      t3['feita'] := false;
      TJSArray(this['tarefas']).push(t3);
    end;
</script>

<style>
  .cartao-tarefas {
    max-width: 480px;
    margin: 30px auto;
    background: #fff;
    padding: 24px;
    border-radius: 12px;
    box-shadow: 0 4px 15px rgba(0,0,0,0.08);
    font-family: sans-serif;
  }
  .btn-toggle {
    background: #3182ce;
    color: white;
    border: none;
    padding: 8px 14px;
    border-radius: 6px;
    cursor: pointer;
    margin-bottom: 16px;
    font-weight: bold;
  }
  .lista {
    list-style: none;
    padding: 0;
    margin: 0;
  }
  .item-tarefa {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 12px;
    border-bottom: 1px solid #edf2f7;
  }
  .concluida {
    text-decoration: line-through;
    color: #a0aec0;
  }
  .btn-acao {
    background: #edf2f7;
    border: 1px solid #cbd5e0;
    padding: 4px 10px;
    border-radius: 4px;
    cursor: pointer;
    font-size: 12px;
  }
  .btn-acao:hover {
    background: #e2e8f0;
  }
  .aviso-vazio {
    padding: 20px;
    background: #f0fff4;
    color: #276749;
    border-radius: 8px;
    text-align: center;
  }
</style>
```

---

## 🎯 6. Exercício Prático do Módulo 03

Para exercitar suas novas habilidades:

1. No código acima, adicione um botão **"Limpar Todas as Tarefas"**.
2. Na seção `methods:`, crie a procedure para limpar a lista:
   ```pascal
   procedure limparTudo;
   begin
     this['tarefas'] := TJSArray.new;
   end;
   ```
3. Teste no navegador: ao clicar em "Limpar Todas as Tarefas", o `b-else` vai sumir e o `b-if="tarefas.length == 0"` vai aparecer instantaneamente com a mensagem verde comemorativa!

---

## 🏆 Resumo do Que Você Aprendeu
- O que são diretivas e como facilitam o controle do HTML.
- Como tomar decisões com `b-if`, `b-else-if` e `b-else`.
- Quando preferir `b-show` para itens que abrem e fecham frequentemente.
- Como desenhar listas dinâmicas com `b-for`.

**Quer receber dados que o usuário digita no teclado? Siga em frente para o [Módulo 04: Sincronização com b-model](04-synchronization.md)!** ⚔️🛡️✨
