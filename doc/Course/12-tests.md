# 🎓 Módulo 12: Qualidade Marcial (Testes Unitários Descomplicados)
**A espada que nunca falha: garanta que seu sistema funcione perfeitamente antes de ir para o ar.**

Você já passou pela experiência de alterar uma única linha de código e, sem querer, quebrar algo que já estava funcionando perfeitamente em outra parte do sistema? Isso é muito comum na vida de qualquer programador e se chama **Regressão**.

Para que você possa programar com total tranquilidade e dormir com a consciência limpa, usamos **Testes Automatizados**!

---

## ✈️ 1. O Que É um Teste Unitário? (A Analogia do Piloto de Avião)

Antes de qualquer avião decolar, os pilotos pegam uma prancheta com um *checklist*:
- As luzes estão acendendo? *Sim.*
- Os freios estão respondendo? *Sim.*
- O combustível está no nível certo? *Sim.*

Um **Teste Unitário** é exatamente esse checklist, só que executado por um robozinho em alta velocidade! Ele roda todas as funções e telas do seu sistema em poucos segundos e avisa imediatamente se algo der errado.

No BlaiseVue, o mais incrível é que **você escreve os testes na própria linguagem Object Pascal**!

---

## 🔬 2. A Estrutura de um Teste em Pascal

Os testes no BlaiseVue ficam guardados na pasta `tests/` com o formato de arquivo `nome.test.pas`. Eles são divididos em três blocos fáceis de ler:

1. **`Describe`**: Diz qual tela ou função você está testando (o título do teste).
2. **`It`**: Diz qual comportamento específico você espera que aconteça.
3. **`Expect`**: É a conferência final! *"Espero que o total seja 10"*, *"Espero que o texto contenha 'Sucesso'"*.

Veja como é claro:

```pascal
program teste_contador;
uses JS, Web, BVTestUtils, uMeuComponente;

begin
  Register_uMeuComponente; // Registra o componente para o teste

  Describe('Meu Componente de Contador', procedure
  begin
    
    // Teste 1: O estado inicial
    It('deve iniciar marcando zero pontos', procedure
    var
      Wrapper: TBVWrapper;
    begin
      Wrapper := Mount('meu-contador'); // Monta o componente na memória
      Expect(Wrapper.Text).ToContain('0'); // Confere se o número 0 está lá!
    end);

  end);
end.
```

---

## 🚀 3. Passo a Passo: Executando os Testes com o CLI `bv`

Rodar a bateria de testes do BlaiseVue é tão simples quanto digitar um único comando no terminal:

```bash
bv test
```

### O Que Acontece nos Bastidores:
1. O CLI procura todos os arquivos `.test.pas` do seu projeto.
2. Ele compila seus códigos Pascal e atualiza os componentes em milissegundos.
3. Ele executa cada teste e imprime na tela uma lista com os resultados em verde:
   ```text
   ✓ demo-app/generated/tests/components/Contador.test.js (1 test) 8ms
   ✓ demo-app/generated/tests/views/Home.test.js (3 tests) 15ms

   Test Files  2 passed (2)
        Tests  4 passed (4)
     Duration  1.20s
   ```

Se algum teste falhar (por exemplo, se você esperava que o total desse `100` e o cálculo resultou em `80`), o terminal avisa em vermelho exatamente em qual linha o erro aconteceu!

---

## 🎯 4. Exercício Prático do Módulo 12

1. Abra o terminal na pasta do seu projeto.
2. Execute o comando `bv test`.
3. Veja todos os testes do framework rodando e passando com sucesso (`passed`).
4. **Desafio mental**: Pense em uma funcionalidade que você criou (como o frete grátis do Módulo 05). Como você testaria se uma compra de R$ 200,00 realmente devolve a mensagem `'Frete Grátis'`? Escrever esse teste é a garantia de que nenhum desconto futuro vai quebrar essa regra!

---

## 🏆 Resumo do Que Você Aprendeu
- Por que os testes automatizados eliminam o medo de alterar código.
- A anatomia de um teste em Pascal com `Describe`, `It` e `Expect`.
- Como executar sua suíte de testes completa com um único comando: `bv test`.

**Você chegou ao momento ápice da sua jornada! É hora de juntar todas as peças e construir uma aplicação completa no [Módulo 13: O Desafio Final](13-final-challenge.md)!** ⚔️🛡️✨
