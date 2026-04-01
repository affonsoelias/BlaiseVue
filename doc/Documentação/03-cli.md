# 🛡️ Manual Técnico do BlaiseCLI (bv.exe)

O `bv.exe` é o orquestrador nativo do BlaiseVue, responsável pela transpilação de componentes SFC, gerenciamento de dependências e sincronização do build.

---

## 🏗️ Comandos de Build e Run

### `bv run dev` (Desenvolvimento)
Executa o build em modo depuração.
- **Flags Internas**: `-d DEBUG` e `-d DEV_TOOLS`.
- **Cache Busting**: Injeta um `v={Timestamp}` em todos os links de recursos no `index.html`.
- **Unit DevTools**: Ativa automaticamente a unit de diagnóstico no bundle final.

### `bv run build` (Produção)
Gera o bundle otimizado para deploy.
- **Flags Internas**: `-d PRODUCTION`.
- **Hashing**: Aplica hash MD5 opcional ao arquivo `main.js`.
- **Minificação**: Invoca o minificador do Pas2JS se configurado.

### `bv test` 🧪 (Testes Unitários)
Executa a suíte de testes unitários automatizados.
- **Vitest + JSDOM**: Integração nativa para simular o ambiente de navegador via Node.js.
- **Transpile On-the-fly**: Transpila automaticamente todos os arquivos `.bv` em `generated/` e compila as units de teste `.pas` para JavaScript.
- **Assertions**: Suporte a `Describe`, `It`, `Expect` e ferramentas de simulação de DOM (`Mount`, `Find`, `Click`).

---

## 📂 Gerenciamento de Arquivos SFC

### `bv transpile`
Realiza apenas a fase de "tradução" do arquivo `.bv` para as unidades `.pas` correspondentes em `generated/`. Útil para inspeção de código transpilado.

### `bv clean`
Executa o `Purge` completo:
1. Esvazia a pasta `generated/`.
2. Remove o diretório `dist/` (exceto arquivos na pasta `public/`).

---

## 📜 Convenções de Mapeamento
| Origem | Destino Pascal | Tag de Componente |
|--------|----------------|-------------------|
| `src/views/*.bv` | `u*.pas` | `<*-page>` |
| `src/components/*.bv` | `u*.pas` | `<*>` (Lower Case) |

---

## ⚡ Performance do CLI
O compilador CLI é escrito em **Pascal Nativo**, garantindo uma velocidade de processamento de componentes SFC ~50x superior às ferramentas baseadas em Node.js. 🛡️✨🏆
