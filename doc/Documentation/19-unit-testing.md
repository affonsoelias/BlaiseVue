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

## 📂 Arquitetura de Testes em 4 Níveis (`tests/`)

Ao criar qualquer projeto com `bv create <NomeDoProjeto>`, o BlaiseVue gera nativamente uma estrutura padronizada em **4 níveis**:

```text
meu-projeto/
├── src/
│   ├── components/          <- Componentes visuais (.bv)
│   ├── views/               <- Páginas da aplicação (.bv)
│   └── services/            <- Regras de negócio, cálculos e serviços em Pascal puro
└── tests/
    ├── components/          <- Gerados automaticamente por "bv new c <Name>"
    │   ├── ProductCard.test.pas
    │   └── HeaderBar.test.pas
    │
    ├── views/               <- Gerados automaticamente por "bv new v <Name>"
    │   ├── DatasetView.test.pas
    │   └── CustomerView.test.pas
    │
    ├── unit/                <- Criados via "bv new t <Name>" (regras, cálculos, serviços)
    │   ├── CalculadoraFrete.test.pas
    │   └── Formatters.test.pas
    │
    └── framework/           <- Testes internos do BlaiseVue (Reactivity, Routing, DataSet, etc.)
        ├── dataset_offline.test.pas
        └── reactivity.test.pas
```

Essa separação garante que:
* **Testes de Componentes** fiquem isolados, validando props padrão, eventos emitidos e slots.
* **Testes de Views** simulem fluxos reais do usuário (abertura de modais, submissão de formulários).
* **Testes Unitários** testem funções matemáticas, regras tributárias e serviços sem custo de DOM.
* **Testes do Framework** garantam que o núcleo reativo e o roteamento permaneçam 100% íntegros.

---

## ⚡ Criação Automática de Testes (Zero Configuração)

Todo componente ou página criada com o CLI já nasce acompanhada do seu arquivo de teste:

### 1. Criando um Componente Visual com Teste Automático
```bash
bv new component ProductCard
# ou no atalho rápido:
bv new c ProductCard
```
O CLI cria automaticamente:
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
Se mais tarde você decidir adicionar testes para aquele componente criado sem teste, basta rodar o comando padrão:

```bash
bv new test SimpleBadge
# ou:
bv new t SimpleBadge
```

O CLI do BlaiseVue analisa o seu projeto sozinho:
1. **Encontrou `SimpleBadge.bv` em `src/components/`?** Cria em `tests/components/SimpleBadge.test.pas` configurado com a tag `<simple-badge>` e `Mount`.
2. **Encontrou em `src/views/`?** Cria em `tests/views/SimpleBadge.test.pas` com a tag da página e `Mount`.
3. **Não encontrou nenhum `.bv`?** Cria em `tests/unit/SimpleBadge.test.pas` para testar regras de negócio e serviços Pascal puros.

Você também pode especificar uma subpasta diretamente:
```bash
bv new t unit/CalculadoraFrete
bv new t framework/CustomReactivity
```

---

## 📝 Exemplo 1: Testando um Componente Visual com Props Padrão e `$emit`

O BlaiseVue suporta valores padrão em declarações de props (`props: title: string = 'Padrao'`). Os testes montam e validam tanto os valores padrão quanto valores customizados e eventos disparados:

```pascal
program formheader_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, uFormHeader;

var
  Wrapper: TWrapper;
  CustomProps: TJSObject;

begin
  Register_uFormHeader;

  Describe('Component: FormHeader', procedure
    begin
       It('deve montar o componente com os valores padrao de props', procedure
         begin
            Wrapper := Mount('form-header');
            Expect(Wrapper.Element <> nil).ToBe(True);
            Expect(Wrapper.Find('.form-header-title').textContent).ToContain('Formulário do Sistema');
         end);

       It('deve aceitar props customizadas', procedure
         begin
            CustomProps := TJSObject.new;
            CustomProps['title'] := 'Cadastro de Clientes';
            Wrapper := Mount('form-header', CustomProps);
            Expect(Wrapper.Find('.form-header-title').textContent).ToContain('Cadastro de Clientes');
         end);

       It('deve emitir evento header-clicked ao clicar no titulo', procedure
         begin
            Wrapper := Mount('form-header');
            TJSHTMLElement(Wrapper.Find('.form-header-title')).click;
            Expect(Wrapper.Emitted('header-clicked')).ToBe(True);
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
            TJSHTMLElement(Wrapper.Find('.crud-header-btns button:first-child')).click;

            { 3. Valida se a janela modal apareceu na tela }
            Expect(Wrapper.Find('.crud-modal-backdrop')).toBeDefined;
         end);
    end);
end.
```

---

## 📝 Exemplo 3: Testando Regras de Negócio e Serviços Pascal (Unit Test Puro)

Testes de serviços ficam em `tests/unit/` e utilizam units puras em `src/services/` (adicionadas automaticamente no `app.cfg` via `-Fusrc/services`):

```pascal
program calculadorafrete_unit_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, uCalculadoraFrete;

begin
  Describe('Unit: CalculadoraFrete (Calculos de Negocio)', procedure
    begin
       It('deve aplicar frete gratis para pedidos acima de R$ 250,00', procedure
         begin
            Expect(CalcularFrete('01001-000', 5.0, 300.0)).toBe(0.0);
            Expect(CalcularFrete('40000-000', 10.0, 250.0)).toBe(0.0);
         end);

       It('deve calcular tarifa base para Sudeste com peso ate 1kg', procedure
         begin
            Expect(CalcularFrete('01001-000', 0.5, 100.0)).toBe(15.0);
         end);

       It('deve identificar regiao correta e prazo de entrega a partir do CEP', procedure
         begin
            Expect(RegiaoPorCEP('01310-100')).toBe('Sudeste - SP');
            Expect(PrazoEntregaDias('01310-100')).toBe(2);
         end);
    end);
end.
```

---

## 💡 O Poder do Pascal com Acesso Opcional ao JavaScript (`asm`)

No BlaiseVue, o padrão absoluto é escrever código em **Object Pascal limpo, legível e tipado**. 

No entanto, o compilador Pas2JS permite blocos inline `asm ... end;`. Isso significa que, quando você precisar fazer mocks de bibliotecas externas do npm, interceptar APIs do navegador ou criar literais de objetos complexos em seus testes, você tem a flexibilidade total do JavaScript sem sair do seu arquivo Pascal:

```pascal
{ Exemplo: Mockando propriedades ou arrays complexos com asm }
MockData := TJSObject.new;
asm
  $mod.MockData.itens = [
    { id: 1, nome: 'Mouse Óptico', preco: 89.90 },
    { id: 2, nome: 'Teclado Mecânico', preco: 350.00 }
  ];
end;
```

O Pascal continua sendo o centro da experiência do desenvolvedor, e o `asm` atua como uma superpotência quando necessário.

---

## 🛠️ Métodos e Asserções Úteis (`BVTestUtils`)

### 🧩 Montagem e Busca de Elementos
| Comando | O que ele faz? |
|---|---|
| `Mount(TagName, Props)` | Monta o componente ou página no DOM virtual e retorna um `TWrapper`. |
| `Wrapper.Find(Selector)` | Busca o primeiro elemento filho por seletor CSS (ex: `button`, `.btn-primary`). |
| `Wrapper.FindAll(Selector)` | Retorna um `TJSArray` contendo todos os elementos que combinam com o seletor. |
| `Wrapper.Element` | Retorna o elemento HTML raiz do componente montado. |
| `Wrapper.Text` | Retorna todo o texto visível renderizado pelo componente. |
| `Wrapper.HTML` | Retorna o código HTML interno do componente (`innerHTML`). |

### 🖱️ Ações, Eventos e Emissões
| Comando | O que ele faz? |
|---|---|
| `TJSHTMLElement(El).click` | Simula um clique de mouse do usuário no elemento. |
| `Wrapper.SetValue(Valor)` | Preenche o valor de um `<input>` e dispara o evento de digitação reativa. |
| `Wrapper.Emitted(EventName)` | Retorna `True` se o componente emitiu o evento via `$emit(EventName)`. |
| `WaitTick` | Aguarda o ciclo de reatividade do BlaiseVue atualizar o DOM após uma mutação. |

### ⚖️ Asserções de Validação (`Expect`)
| Asserção | Descrição |
|---|---|
| `Expect(A).ToBe(B)` | Compara se `A` é estritamente igual a `B`. |
| `Expect(Texto).ToContain('Trecho')` | Confere se um texto ou classe contém um determinado valor. |
| `Expect(Texto).NotToContain('Trecho')`| Confere se um texto ou classe NÃO está presente (asserção negativa). |
| `Expect(El).toBeDefined` | Garante que o elemento existe no DOM (não é nulo nem indefinido). |
| `Expect(Condicao).ToBe(True)` | Valida se a expressão booleana é verdadeira. |
| `Expect(Lista).ToHaveLength(N)` | Confere a quantidade exata de itens em um array. |

---

## 🚀 Como Executar os Testes

Para compilar e rodar todos os testes de todas as pastas recursivamente, execute na raiz do projeto:

```bash
bv test
```

O BlaiseVue fará tudo automaticamente em 3 passos:
1. **Transpila** todos os seus arquivos `.bv` para units Pascal em `generated/`.
2. **Compila** todos os seus arquivos `.test.pas` preservando a estrutura de pastas em `generated/tests/`.
3. **Executa o Vitest** no ambiente JSDOM e exibe na tela o relatório com os resultados.

Para manter os testes rodando continuamente em segundo plano durante o desenvolvimento:
```bash
bv test --watch
```

---

## 🗑️ Como Remover Componentes, Views e Testes

O comando `remove` remove tanto o arquivo de código quanto os testes associados em suas respectivas pastas:

```bash
# Remove o componente e também tests/components/ProductCard.test.pas
bv remove component ProductCard

# Remove a view e também tests/views/OrderHistory.test.pas
bv remove view OrderHistory

# Remove um teste específico em qualquer subpasta
bv remove test SimpleBadge
```

---
🛡️ **BlaiseVue:** Testes automatizados robustos em Pascal moderno, organizados e prontos para produção! 🧪✨
