# 10. Estrutura de Projeto

## Visão Geral

```
meu-app/
├── app.cfg                # Config do pas2js (gerado pelo bv create)
│
├── public/                # Arquivos estáticos (nunca mudam)
│   └── index.html         # HTML base com <div id="app">
│
├── src/                   # CÓDIGO FONTE (trabalhe aqui!)
│   ├── app.bv             # Componente raiz + config de router
│   ├── components/        # Componentes reutilizáveis
│   │   ├── Counter.bv
│   │   └── InfoCard.bv
│   └── views/             # Páginas (uma por rota)
│       ├── Home.bv
│       └── About.bv
│
├── generated/             # Pascal gerado (NÃO EDITAR!)
│   ├── main.pas           # Ponto de entrada
│   ├── uApp.pas           # app.bv → Pascal
│   ├── uHome.pas          # Home.bv → Pascal
│   └── uCounter.pas       # Counter.bv → Pascal
│
└── dist/                  # Bundle final (para deploy)
    ├── index.html         # Atualizado com hashes
    └── js/
        ├── rtl.js         # Runtime do pas2js
        └── main.[hash].js # App compilado com cache busting
```

## Detalhes de Cada Pasta

### `src/` - Código Fonte

**Onde você trabalha.** Contém apenas arquivos `.bv`.

- `app.bv` — Componente raiz. Define o layout global, dados do app e configuração de rotas
- `views/` — Páginas que correspondem a rotas. Cada arquivo gera uma tag com sufixo `-page`
- `components/` — Blocos reutilizáveis. Cada arquivo gera uma tag com o nome natural (kebab-case)

### `generated/` - Pascal Gerado

**Nunca edite estes arquivos.** São recriados a cada `bv build` ou `bv transpile`.

O pré-processador converte cada `.bv` em uma unit Pascal com:
- Template como string
- Data como função
- Methods como procedures
- Style como injeção CSS

### `dist/` - Bundle Final (Produção)

**Para deploy.** Gerado via `bv run build`.
- `index.html` — Injeta automaticamente o script com hash
- `js/main.[hash].js` — Versão com hash para evitar problemas de cache no navegador
- DevTools é removido automaticamente neste build

---

## Fluxo de Desenvolvimento Profissional

```bash
# 1. Limpar arquivos antigos (opcional)
bv clean

# 2. Iniciar servidor em um terminal (com logs de rede)
bv serve

# 3. Em outro terminal, compilar seus .bv (com modo depuracao e logs da app)
bv run dev

# 4. Gerar build de produção otimizado com hashes
bv run build

# 5. Testar o build de produção localmente
bv run preview
```
