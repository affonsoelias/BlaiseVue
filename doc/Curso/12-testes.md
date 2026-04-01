# 🎓 Módulo 12: Qualidade Marcial (Testes Unitários)
**A Espada que Nunca Falha: Sua Lógica Validada.**

Neste módulo, você vai aprender como garantir que o seu código BlaiseVue funcione antes mesmo de abrir o navegador. O verdadeiro Ninja não confia apenas nos seus olhos; ele confia nos seus testes!

---

### 🛡️ Por que testar em Pascal?
Diferente de outros frameworks, no BlaiseVue você escreve os testes na própria linguagem de backend: **Object Pascal**. 

Isso garante que ao validar o comportamento de um componente `.bv`, você está testando a lógica transpilada exata que será enviada para o usuário final.

---

### 🔥 O Comando Sagrado
Para rodar seus testes, use:
```bash
bv test
```

Este comando:
1.  **Observa**: Encontra todos os arquivos `.test.pas` na pasta `tests/`.
2.  **Transpila**: Garante que os componentes usados nos testes estejam atualizados.
3.  **Executa**: Inoca o Vitest e mostra os acertos e erros no terminal.

---

### 📝 Estrutura de um Teste Ninja

```pascal
program meu_teste;
uses JS, Web, BVTestUtils, uMeuComponente;

begin
  Register_uMeuComponente; // Importante!

  Describe('Meu Componente', procedure
    begin
       It('deve iniciar com estado limpo', procedure
         begin
            var Wrapper := Mount('meu-componente');
            Expect(Wrapper.Text).ToContain('Vazio');
         end);
    end);
end.
```

---

### ⚔️ Desafio da Qualidade
1.  Crie um componente de `TodoList`.
2.  Escreva um teste que simula a adição de um item.
3.  Verifique se o item aparece na lista do DOM usando `Wrapper.Text`.

🛡️ **Seja persistente. Testes salvam vidas (e noites de sono)!**  
✨🚀🏆
