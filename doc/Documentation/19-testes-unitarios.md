# 🧪 Módulo de Testes Unitários PRO

O BlaiseVue 2.1 PRO inclui uma engine de testes nativa escrita em Pascal, integrada ao **Vitest** e **JSDOM**, permitindo a validação de componentes SFC com a mesma facilidade de frameworks modernos como Vue/React.

---

## 🏗️ Ciclo de Vida do Teste (TDD Pascal)

1.  **Criação**: Use o comando `bv new t MeuComponente`.
2.  **Transpilação**: O CLI transpila `.bv` -> `.pas` em `generated/`.
3.  **Execução**: O comando `bv test` compila o Pascal de teste para JS e roda no Node.js.

---

## 📝 Exemplo de Teste Reativo

Os testes no BlaiseVue são assíncronos por natureza devido ao ciclo de reatividade. Use `WaitTick` para garantir que o DOM foi atualizado após uma mudança de estado.

```pascal
program counter_test;

uses JS, Web, BVTestUtils, uCounter;

begin
  { 1. Registrar o componente para que o compilador o reconheça no DOM Virtual }
  Register_uCounter;

  Describe('Feature: Contador Reativo', procedure
    var
      Wrapper: TWrapper;
    begin
       It('deve incrementar o valor e atualizar o DOM', procedure
         begin
            { 2. Montar o componente na Tag 'u-counter' }
            Wrapper := Mount('u-counter');

            { 3. Simular interação: Encontrar o botão e clicar }
            Wrapper.Find('button').click();

            { 4. IMPORTANTE: Aguardar o ciclo de reatividade (Tick) }
            WaitTick;

            { 5. Asserção final no DOM atualizado }
            Expect(Wrapper.Text).ToContain('Valor: 1');
         end);
    end);
end.
```

---

## 🛠️ API de Testes (BVTestUtils)

### 🧩 Montagem e Seleção
| Método | Descrição |
|--------|-----------|
| `Mount(TagName)` | Cria o componente no JSDOM e retorna um `TWrapper`. |
| `Wrapper.Find(Selector)` | Retorna o primeiro `TJSHTMLElement` que coincide com o seletor. |
| `Wrapper.FindAll(Selector)` | Retorna um array de elementos. |

### ⌨️ Interação
| Método | Descrição |
|--------|-----------|
| `Wrapper.Click(Selector)` | Atalho para disparar o evento de clique em um elemento. |
| `Wrapper.Fill(Selector, Val)` | Preenche um input e dispara o evento `input` reativo. |
| `WaitTick` | Pausa a execução do teste até que o motor de reatividade processe os jobs pendentes. |

### ⚖️ Asserções (Expect)
| Asserção | Descrição |
|----------|-----------|
| `.ToEqual(val)` | Igualdade estrita (JS ===). |
| `.ToContain(str)` | Verifica se a string ou HTML contém o trecho. |
| `.ToBeTrue / .ToBeFalse` | Validações booleanas rápidas. |

---

## 🚀 Comandos Úteis
- **`bv new t MyTest`**: Cria o template inicial em `tests/MyTest.test.pas`.
- **`bv test`**: Executa todos os testes da pasta `tests/`.
- **`bv test --watch`**: Mantém os testes rodando e re-executa a cada mudança no código.

---
🛡️ **"Code is cheap, tests are gold."** ✨🧪🏆
