# 12. Depuração e Monitoramento

O BlaiseVue oferece recursos integrados para facilitar a identificação de erros e o rastreamento do estado da aplicação.

## 🛠️ BVDevTools

A unit `BVDevTools` é injetada automaticamente em **Modo de Depuração** (`bv run dev`).

### Recursos principais:
- **HUD (Overlay)**: Exibe uma sobreposição na tela do navegador caso ocorram erros fatais durante a compilação de templates ou diretivas reativas no runtime.
- **Rápida Investigação**: O HUD exibe a mensagem de erro, a origem (qual diretiva ou componente falhou) e o stack trace do JavaScript no navegador.

## 📜 Logs do Console

Com as novas atualizações, você pode usar os seguintes métodos da unit `BVDevTools` em seus componentes (`<script>`) para diagnósticos:

### `LogEvent(const Msg: string; Data: JSValue = nil)`
Registra um evento importante no console.
- **Estilo**: Texto branco em fundo verde (`EVENT`).
- **Uso**: Ideal para rastrear ações do usuário ou disparos de eventos.

### `LogTrace(const Msg: string; Data: JSValue = nil)`
Rastreia a execução de trechos de código detalhados.
- **Estilo**: Texto branco em fundo escuro (`TRACE`).
- **Uso**: Recomendado para monitorar fluxos de dados ou loops.

### `LogError(const Msg, Source: string; Err: JSValue)`
Usado internamente pelo framework, mas disponível para exibir erros customizados no HUD e no console (em vermelho).

## 📡 Monitoramento via CLI

O Novo workflow (`bv run dev` + `bv serve`) separa o monitoramento em dois canais:

### 1. Logs da Aplicação (`bv run dev`)
- Exibe o progresso do compilador Pascal para JavaScript.
- Identifica erros de sintaxe `.bv`, units faltantes ou erros no compilador Pascal (`pas2js`).
- **Dica:** Mantenha este comando aberto para verificar se o build foi bem sucedido.

### 2. Logs do Servidor (`bv serve`)
- Exibe todas as requisições HTTP recebidas pelo servidor.
- Mostra erros `404` caso você tente acessar um arquivo inexistente ou se uma imagem não carregar.
- Valida o carregamento dos arquivos compilados (`main.js` e `rtl.js`).

## 🛑 Remoção em Produção

Ao executar `bv run build`, o compilador remove TODA a unit `BVDevTools` e os comandos de log injetados (usando `$IFNDEF PRODUCTION`). Isso garante que sua aplicação final seja **leve, rápida e segura**, sem expor o HUD de erros ou logs internos aos usuários finais.
