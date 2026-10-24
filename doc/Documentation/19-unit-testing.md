# 🧪 Módulo de Testes Automatizados (TDD & BDD em Pascal)

O **BlaiseVue** possui um motor nativo de testes unitários e de integração escrito em **Object Pascal puro**, totalmente integrado ao **Vitest** e ao **JSDOM**.

Ele permite que você teste tanto **regras de negócio** (classes, cálculos e serviços em Pascal) quanto **componentes visuais e telas inteiras** (`.bv`), com a mesma facilidade e velocidade dos frameworks modernos da web.

---

## 🎯 Por que Testar no BlaiseVue?

Se você vem do Delphi ou Lazarus desktop, sabe como é frustrante clicar em um botão no formulário e descobrir em tempo de execução que um campo estava vazio ou uma função falhou.

No BlaiseVue, você não precisa abrir o navegador manualmente e preencher formulários toda vez que fizer uma alteração:
1. Você escreve o teste em **Pascal familiar** (`Describe`, `It`, `Expect`).
2. O BlaiseVue monta o componente ou tela em memória virtual (**JSDOM**).
3. O teste simula cliques de mouse, digitação de texto e valida se o resultado no DOM está correto.
4. Tudo roda em segundos diretamente no terminal!

---

## ⚡ Criação Automática de Testes (Zero Configuração)

A partir do BlaiseVue 4.4, **todo componente ou página criada já nasce acompanhada do seu arquivo de teste**:

### 1. Criando um Componente Visual com Teste Automático
```bash
bv new component ProductCard
# ou no atalho rápido:
bv new c ProductCard
```
O CLI cria automaticamente dois arquivos:
1. `src/components/ProductCard.bv` (O componente visual)
2. `tests/components/ProductCard.test.pas` (O teste pronto e configurado)

### 2. Criando uma View / Página com Teste Automático
```bash
bv new view OrderHistory
# ou no atalho rápido:
bv new v OrderHistory
```
O CLI cria automaticamente:
1. `src/views/OrderHistory.bv` (A página da aplicação)
2. `tests/views/OrderHistory.test.pas` (O teste de inicialização e renderização)

---

## 🚀 E se Eu Estiver Prototipando e Não Quiser o Teste Agora?

Basta passar a flag `--no-test` (ou `-nt`):

```bash
bv new component SimpleBadge --no-test
bv new view Dashboard --no-test
```
O arquivo `.bv` será criado normalmente sem gerar o arquivo de teste.

### 🧠 Detecção Inteligente (`Smart Detection`)
E se mais tarde você decidir que quer adicionar testes para aquele componente criado sem teste? **Basta rodar o comando padrão de teste**:

```bash
bv new test SimpleBadge
# ou:
bv new t SimpleBadge
```

O CLI do BlaiseVue analisa o seu projeto sozinho:
1. **Encontrou `SimpleBadge.bv` em `src/components/`?** Cria em `tests/components/SimpleBadge.test.pas` já configurado com a tag `<simple-badge>` e `Mount`.
2. **Encontrou em `src/views/`?** Cria em `tests/views/SimpleBadge.test.pas` com a tag da página e `Mount`.
3. **Não encontrou nenhum `.bv`?** Cria em `tests/unit/SimpleBadge.test.pas` para testar regras de negócio e serviços Pascal puros.

Você **não precisa decorar opções complicadas**: o framework entende o que você quer fazer!

---

## 📂 Estrutura Organizada da Pasta `tests/`

Para manter seu projeto limpo e profissional, os testes são separados por responsabilidade:

```text
meu-projeto/
├── tests/
│   ├── components/      <- Testes de botões, cards, modais, etc.
│   │   ├── ProductCard.test.pas
│   │   └── SimpleBadge.test.pas
│   │
│   ├── views/           <- Testes de páginas e telas inteiras
│   │   ├── DatasetView.test.pas
│   │   └── OrderHistory.test.pas
│   │
│   ├── unit/            <- Testes de classes, cálculos e regras em Pascal
│   │   ├── CalculoImposto.test.pas
│   │   └── AuthService.test.pas
│   │
│   └── framework/       <- Testes de bibliotecas ou extensões customizadas
│       └── MeuPlugin.test.pas
```

---

## 📝 Exemplo 1: Testando um Componente Visual (`.bv`)

Aqui está como fica um teste de componente em Pascal:

```pascal
program productcard_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, uProductCard;

var
  Wrapper: TWrapper;

begin
  { 1. Registra a unit do componente }
  Register_uProductCard;

  Describe('Component: ProductCard', procedure
    begin
       It('deve renderizar o componente no DOM', procedure
         begin
            { Monta o componente na tag HTML correspondente }
            Wrapper := Mount('product-card');

            { Valida se o elemento raiz foi criado com sucesso }
            Expect(Wrapper.Element <> nil).ToBe(True);
         end);

       It('deve exibir o titulo passado por prop', procedure
         var
           Props: TJSObject;
         begin
            Props := TJSObject.new;
            Props['title'] := 'Teclado Mecânico Pascal';

            Wrapper := Mount('product-card', Props);

            { Confere se o texto aparece dentro do componente }
            Expect(Wrapper.Text).ToContain('Teclado Mecânico Pascal');
         end);
    end);
end.
```

---

## 📝 Exemplo 2: Testando uma Página / View Inteira (Ex: `DatasetView`)

Você pode testar telas completas simulando interações reais do usuário:

```pascal
program datasetview_view_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, uDatasetView;

var
  Wrapper: TWrapper;

begin
  Register_uDatasetView;

  Describe('View: DatasetView', procedure
    begin
       It('deve inicializar a tela sem erros', procedure
         begin
            Wrapper := Mount('dataset-view-page');
            Expect(Wrapper.Find('.dataset-view-page')).toBeDefined;
         end);

       It('deve abrir a janela modal ao clicar em Novo Produto', procedure
         begin
            Wrapper := Mount('dataset-view-page');

            { 1. Verifica que a modal está fechada no início }
            Expect(Wrapper.Find('.crud-modal-backdrop') = nil).ToBe(True);

            { 2. Simula o clique do usuário no botão de novo cadastro }
            Wrapper.Find('.crud-header-btns button:first-child').click();

            { 3. Valida se a janela modal apareceu na tela }
            Expect(Wrapper.Find('.crud-modal-backdrop')).toBeDefined;
         end);
    end);
end.
```

---

## 📝 Exemplo 3: Testando Regras de Negócio e Serviços Pascal (Unit Test Puro)

Se você tem uma classe em Pascal (como cálculo de frete, regras tributárias ou validação de documentos):

```bash
bv new t CalculoFrete
# Gera automaticamente tests/unit/CalculoFrete.test.pas
```

```pascal
program calculo_frete_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, Services;

var
  Calculadora: TCalculadoraFrete;
  ValorFinal: Double;

begin
  Describe('Serviço: Cálculo de Frete', procedure
    begin
       It('deve aplicar frete gratis para compras acima de 200 reais', procedure
         begin
            Calculadora := TCalculadoraFrete.Create;
            try
              ValorFinal := Calculadora.Calcular(250.00, 'SP');
              Expect(ValorFinal).ToBe(0.0);
            finally
              Calculadora.Free;
            end;
         end);
    end);
end.
```

---

## 🛠️ Métodos e Asserções Úteis (`BVTestUtils`)

### 🧩 Montagem e Busca de Elementos
| Comando | O que ele faz? |
|---|---|
| `Mount(TagName, Props)` | Monta o componente ou página no DOM virtual e retorna um `TWrapper`. |
| `Wrapper.Find(Selector)` | Busca um elemento filho por seletor CSS (ex: `button`, `.btn-primary`, `#meu-id`). |
| `Wrapper.Element` | Retorna o elemento HTML raiz do componente montado. |
| `Wrapper.Text` | Retorna todo o texto visível renderizado pelo componente. |
| `Wrapper.HTML` | Retorna o código HTML interno do componente (`innerHTML`). |

### 🖱️ Ações e Eventos
| Comando | O que ele faz? |
|---|---|
| `Wrapper.Find('button').click()` | Simula um clique do usuário em um botão ou link. |
| `Wrapper.SetValue(Valor)` | Preenche o valor de um `<input>` e dispara o evento de digitação reativa. |
| `WaitTick` | Aguarda o ciclo de reatividade do BlaiseVue atualizar o DOM após uma mudança de variável. |

### ⚖️ Asserções de Validação (`Expect`)
| Asserção | Descrição |
|---|---|
| `Expect(A).ToBe(B)` | Compara se `A` é estritamente igual a `B`. |
| `Expect(Texto).ToContain('Trecho')` | Confere se um texto ou lista contém um determinado valor. |
| `Expect(El).toBeDefined` | Garante que o elemento existe no DOM (não é nulo nem indefinido). |
| `Expect(Condicao).ToBe(True)` | Valida se a expressão é verdadeira. |

---

## 🚀 Como Executar os Testes

Para compilar e rodar todos os testes de todas as pastas recursivamente, execute na raiz do projeto:

```bash
bv test
```

O BlaiseVue fará tudo automaticamente em 3 passos:
1. **Transpila** todos os seus arquivos `.bv` para units Pascal em `generated/`.
2. **Compila** todos os seus arquivos `.test.pas` para JavaScript usando o Pas2JS.
3. **Executa o Vitest** e exibe na tela o relatório com quantos testes passaram!

Para manter os testes rodando em segundo plano enquanto você desenvolve (reexecutando sempre que salvar um arquivo):
```bash
bv test --watch
```

---

## 🗑️ Como Remover Componentes, Views e Testes

O comando `remove` remove tanto o arquivo de código quanto os testes associados para não deixar lixo no projeto:

```bash
# Remove o componente e também tests/components/ProductCard.test.pas
bv remove component ProductCard

# Remove a view e também tests/views/OrderHistory.test.pas
bv remove view OrderHistory

# Remove um teste específico em qualquer subpasta
bv remove test SimpleBadge
```

---
🛡️ **BlaiseVue:** Testes automatizados robustos em Pascal moderno, simples e sem complicações! 🧪✨
