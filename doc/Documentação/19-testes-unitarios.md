# 🧪 Módulo de Testes Unitários PRO

O BlaiseVue 2.0 PRO agora inclui uma suíte completa de testes unitários baseada em **Vitest** e **JSDOM**, permitindo a validação de componentes Pascal de forma profissional.

---

## 🏗️ Filosofia de Testes
No BlaiseVue, os testes são escritos em **Pascal**, compilados para JavaScript e executados em um ambiente Node.js que simula o navegador (JSDOM).

- **`Describe` / `It`**: Agrupamento e definição de testes.
- **`Mount`**: Montagem de um componente SFC (`.bv`) no DOM virtal.
- **`Wrapper`**: Objeto retornado pelo `Mount` que permite interagir com o componente.
- **`Expect`**: Asserções fluentes no estilo BDD.

---

## 📝 Exemplo de Teste Unitário

Para testar um componente `Counter.bv`, crie um arquivo `tests/counter.test.pas`:

```pascal
program counter_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, uCounter;

var
  Wrapper: TWrapper;

begin
  // Registra o componente transpilado
  Register_uCounter;

  Describe('Componente Counter', procedure
    begin
       It('deve renderizar o valor inicial zero', procedure
         begin
            Wrapper := Mount('counter');
            Expect(Wrapper.Text).ToContain('Count: 0');
         end);
         
       It('deve incrementar o valor ao clicar no botão', procedure
         begin
            Wrapper := Mount('counter');
            Wrapper.Find('button').click(); // Simula clique
            Expect(Wrapper.Text).ToContain('Count: 1');
         end);
    end);
end.
```

---

## ⚡ Execução
Basta rodar o comando na raiz do projeto:

```bash
bv test
```

O CLI irá realizar o **Auto-Transpile**, compilar suas units de teste e mostrar o resultado em tempo real.

---

## 🛠️ BVTestUtils (Referência)

| Função | Descrição |
|--------|-----------|
| `Mount(Tag, Props)` | Monta o componente e retorna um `TWrapper`. |
| `Wrapper.Find(Selector)` | Retorna o `TJSHTMLElement` encontrado. |
| `Wrapper.Text` | Retorna o `textContent` do componente montado. |
| `Wrapper.HTML` | Retorna o `innerHTML` do componente montado. |
| `Expect(Val).ToEqual(X)` | Verifica igualdade estrita. |
| `Expect(Val).ToContain(X)`| Verifica se uma string contém uma substring. |

🛡️ **Teste agora, confie sempre.** ✨🧪
