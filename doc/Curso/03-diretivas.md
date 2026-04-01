# 📜 Módulo 03: Projeto 02 - A Lista de Tarefas Épica
**Domine as Diretivas b-for, b-if e b-show na Prática!**

Nesta aula, vamos sair da teoria e construir uma aplicação real. Você aprenderá como o BlaiseVue gerencia listas e condicionais de forma automática.

---

## 🛠️ O Que Vamos Construir?
Uma lista onde você pode adicionar tarefas, vê-las na tela e ocultar a lista quando quiser.

### 1. Preparando o Template
Abra sua `Home.bv` e adicione este código:
```html
<template>
  <div class="list-container">
    <h1>Minhas Tarefas 🛡️</h1>
    
    <!-- b-show: Para esconder a lista toda -->
    <button @click="toggleVisibilidade">Alternar Visibilidade</button>

    <div b-show="visivel">
      <ul>
        <!-- b-for: Onde a mágica acontece -->
        <li b-for="task in lista">
          {{ task.nome }} - {{ task.status }}
        </li>
      </ul>
      
      <!-- b-if: Só aparece quando a lista está vazia -->
      <p b-if="lista.length == 0">Nenhuma tarefa por enquanto! ⚔️</p>
    </div>
  </div>
</template>
```

---

## 👁️ O Que Você Aprendeu Hoje:
- **`b-for`**: Como repetir elementos com base em um Array Pascal.
- **`b-if`**: Como mostrar mensagens apenas quando condições são atendidas.
- **`b-show`**: Como alternar visibilidade instantaneamente sem recarregar! ✨✨✨

**Desafio Extra:** Tente adicionar um botão de "Remover" dentro do `b-for` usando o que aprendeu no módulo anterior! 🛡️✨🏆

---

**Próximo Passo: Aprenda a dominar formulários com b-model no Módulo 04!** ⚔️
