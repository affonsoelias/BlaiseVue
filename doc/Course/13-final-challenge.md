# 🛡️ Módulo 13: O Desafio Final - Painel de Controle de Vendas
**Consolide todo o seu conhecimento construindo uma aplicação real e completa.**

Parabéns, aventureiro! Você percorreu toda a trilha de aprendizado do BlaiseVue: desde os conceitos básicos de variáveis e reatividade até diretivas, formulários, componentes, rotas e testes.

Agora é a hora de provar para si mesmo que você domina as runas do Object Pascal para a Web. Vamos construir juntos uma aplicação completa: um **Painel de Controle Financeiro e de Vendas**!

---

## 🎯 1. O Que o Seu Painel Deve Conter?

1. **Cards de Métricas Reutilizáveis**: Componentes que exibem o Total de Vendas, a Média por Pedido e o Status da Meta.
2. **Formulário com `b-model`**: Onde o usuário digita a descrição da venda, o valor em reais e seleciona a categoria.
3. **Lista Dinâmica com `b-for`**: Exibindo todas as vendas cadastradas com botão para remover.
4. **Cálculos Automáticos com `computed:`**:
   - Soma total das vendas em tempo real.
   - Cálculo da média por venda.
   - Verificação automática se a meta de R$ 1.000,00 foi batida.
5. **Decisões Visuais com `b-if`**: Mensagem comemorativa com troféu (`🏆`) caso a meta seja atingida!

---

## 🚀 2. O Código Completo do Projeto (Pronto Para Rodar)

Copie e cole este código completo dentro do seu arquivo principal (ex: `src/views/Home.bv`) para ver a aplicação funcionando na íntegra:

```html
<template>
  <div class="dashboard-container">
    
    <!-- Cabeçalho -->
    <header class="topo-dashboard">
      <h1>💼 Painel de Controle de Vendas</h1>
      <p class="subtitulo">Gerencie suas vendas em tempo real com a reatividade do Object Pascal.</p>
    </header>

    <!-- Linha de Cards de Resumo (Métricas) -->
    <section class="grade-cards">
      <div class="card-metrica">
        <span class="icone-card">💰</span>
        <div class="info-card">
          <small>Faturamento Total</small>
          <h3>R$ {{ totalVendas.toFixed(2) }}</h3>
        </div>
      </div>

      <div class="card-metrica">
        <span class="icone-card">📊</span>
        <div class="info-card">
          <small>Ticket Médio</small>
          <h3>R$ {{ ticketMedio.toFixed(2) }}</h3>
        </div>
      </div>

      <div class="card-metrica">
        <span class="icone-card">📦</span>
        <div class="info-card">
          <small>Total de Vendas</small>
          <h3>{{ listaVendas.length }} pedidos</h3>
        </div>
      </div>
    </section>

    <!-- Aviso Condicional com b-if se a meta foi batida -->
    <div b-if="metaBatida" class="alerta-meta">
      🏆 <strong>Parabéns!</strong> A meta de R$ 1.000,00 foi superada com sucesso!
    </div>

    <!-- Área Principal Dividida em Duas Colunas -->
    <div class="corpo-dashboard">
      
      <!-- Coluna Esquerda: Formulário de Nova Venda -->
      <div class="painel-formulario">
        <h3>➕ Nova Venda</h3>

        <div class="campo">
          <label>Descrição do Item:</label>
          <input type="text" b-model="novaDescricao" placeholder="Ex: Consultoria Pascal">
        </div>

        <div class="campo">
          <label>Valor (R$):</label>
          <input type="number" b-model="novoValor" min="1" step="10" placeholder="0.00">
        </div>

        <div class="campo">
          <label>Categoria:</label>
          <select b-model="novaCategoria">
            <option value="Software">Software</option>
            <option value="Treinamento">Treinamento</option>
            <option value="Suporte">Suporte</option>
          </select>
        </div>

        <button class="btn btn-adicionar" @click="adicionarVenda">
          Registrar Venda
        </button>
      </div>

      <!-- Coluna Direita: Lista de Vendas Realizadas -->
      <div class="painel-tabela">
        <h3>📋 Histórico de Transações</h3>

        <!-- Aviso se não houver vendas cadastradas -->
        <p b-if="listaVendas.length == 0" class="tabela-vazia">
          Nenhuma venda cadastrada ainda. Registre uma nova venda ao lado!
        </p>

        <!-- Tabela desenhada com b-for -->
        <table b-else class="tabela-dados">
          <thead>
            <tr>
              <th>Descrição</th>
              <th>Categoria</th>
              <th>Valor</th>
              <th>Ação</th>
            </tr>
          </thead>
          <tbody>
            <tr b-for="venda in listaVendas">
              <td><strong>{{ venda.item }}</strong></td>
              <td><span class="tag-categoria">{{ venda.categoria }}</span></td>
              <td class="coluna-preco">R$ {{ venda.valor.toFixed(2) }}</td>
              <td>
                <button class="btn-excluir" @click="removerVenda(venda)">Remover</button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

    </div>

  </div>
</template>

<script>
  data:
    novaDescricao: string = '';
    novoValor: real = 150.00;
    novaCategoria: string = 'Software';
    listaVendas: TJSArray;

  computed:
    // 1. Calcula a soma de todas as vendas da lista
    function totalVendas: real;
    var
      i: integer;
      soma: real;
      venda: TJSObject;
    begin
      soma := 0.0;
      if Assigned(this['listaVendas']) then
      begin
        for i := 0 to TJSArray(this['listaVendas']).length - 1 do
        begin
          venda := TJSObject(TJSArray(this['listaVendas'])[i]);
          soma := soma + Real(venda['valor']);
        end;
      end;
      Result := soma;
    end;

    // 2. Calcula o valor médio por venda
    function ticketMedio: real;
    begin
      if (not Assigned(this['listaVendas'])) or (TJSArray(this['listaVendas']).length = 0) then
        Result := 0.0
      else
        Result := Real(this['totalVendas']) / TJSArray(this['listaVendas']).length;
    end;

    // 3. Informa se atingiu a meta de R$ 1.000,00
    function metaBatida: boolean;
    begin
      Result := Real(this['totalVendas']) >= 1000.00;
    end;

  methods:
    // Ação: Adiciona uma nova venda à lista
    procedure adicionarVenda;
    var
      nova: TJSObject;
    begin
      if Trim(string(this['novaDescricao'])) = '' then Exit;

      nova := TJSObject.new;
      nova['item'] := this['novaDescricao'];
      nova['valor'] := Real(this['novoValor']);
      nova['categoria'] := this['novaCategoria'];

      TJSArray(this['listaVendas']).push(nova);

      // Limpa os campos para a próxima entrada
      this['novaDescricao'] := '';
      this['novoValor'] := 100.00;
    end;

    // Ação: Remove a venda clicada da lista
    procedure removerVenda(itemParaRemover: TJSObject);
    var
      i: integer;
      venda: TJSObject;
    begin
      for i := 0 to TJSArray(this['listaVendas']).length - 1 do
      begin
        venda := TJSObject(TJSArray(this['listaVendas'])[i]);
        if venda['item'] = itemParaRemover['item'] then
        begin
          TJSArray(this['listaVendas']).splice(i, 1);
          Break;
        end;
      end;
    end;

  mounted:
    // Inicializa a lista com 3 vendas de exemplo para começar bem
    procedure;
    var
      v1, v2, v3: TJSObject;
    begin
      this['listaVendas'] := TJSArray.new;

      v1 := TJSObject.new;
      v1['item'] := 'Licença BlaiseVue Pro';
      v1['valor'] := 450.00;
      v1['categoria'] := 'Software';
      TJSArray(this['listaVendas']).push(v1);

      v2 := TJSObject.new;
      v2['item'] := 'Curso do Zero ao Ninja';
      v2['valor'] := 250.00;
      v2['categoria'] := 'Treinamento';
      TJSArray(this['listaVendas']).push(v2);

      v3 := TJSObject.new;
      v3['item'] := 'Suporte Mensal Dedicado';
      v3['valor'] := 200.00;
      v3['categoria'] := 'Suporte';
      TJSArray(this['listaVendas']).push(v3);
    end;
</script>

<style>
  .dashboard-container {
    max-width: 950px;
    margin: 30px auto;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    color: #2d3748;
  }
  .topo-dashboard {
    margin-bottom: 24px;
    text-align: center;
  }
  .topo-dashboard h1 { margin: 0 0 6px 0; color: #2b6cb0; font-size: 28px; }
  .subtitulo { margin: 0; color: #718096; font-size: 14px; }

  /* Cards de Métricas */
  .grade-cards {
    display: flex;
    gap: 16px;
    margin-bottom: 24px;
  }
  .card-metrica {
    flex: 1;
    background: #ffffff;
    border-radius: 12px;
    padding: 18px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.05);
    display: flex;
    align-items: center;
    gap: 16px;
    border: 1px solid #e2e8f0;
  }
  .icone-card { font-size: 36px; }
  .info-card small { display: block; color: #718096; font-weight: bold; font-size: 11px; text-transform: uppercase; }
  .info-card h3 { margin: 4px 0 0 0; color: #1a202c; font-size: 22px; }

  .alerta-meta {
    background: #c6f6d5;
    color: #22543d;
    padding: 14px 20px;
    border-radius: 10px;
    margin-bottom: 24px;
    text-align: center;
    font-size: 15px;
    border: 1px solid #9ae6b4;
    animation: pulse 2s infinite;
  }

  /* Corpo com Duas Colunas */
  .corpo-dashboard {
    display: flex;
    gap: 24px;
  }
  .painel-formulario {
    flex: 1;
    background: #ffffff;
    padding: 20px;
    border-radius: 12px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.05);
    border: 1px solid #e2e8f0;
  }
  .painel-formulario h3 { margin-top: 0; margin-bottom: 16px; font-size: 16px; color: #2b6cb0; }
  .campo { margin-bottom: 14px; }
  .campo label { display: block; font-size: 12px; font-weight: bold; margin-bottom: 4px; color: #4a5568; }
  .campo input, .campo select {
    width: 100%;
    padding: 8px 12px;
    border: 1px solid #cbd5e0;
    border-radius: 6px;
    font-size: 14px;
    box-sizing: border-box;
  }
  .btn-adicionar {
    width: 100%;
    background: #3182ce;
    color: white;
    border: none;
    padding: 10px;
    border-radius: 6px;
    font-weight: bold;
    cursor: pointer;
    margin-top: 10px;
  }
  .btn-adicionar:hover { background: #2b6cb0; }

  /* Tabela de Dados */
  .painel-tabela {
    flex: 2;
    background: #ffffff;
    padding: 20px;
    border-radius: 12px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.05);
    border: 1px solid #e2e8f0;
  }
  .painel-tabela h3 { margin-top: 0; margin-bottom: 16px; font-size: 16px; color: #2b6cb0; }
  .tabela-vazia { color: #a0aec0; text-align: center; padding: 30px; font-style: italic; }
  .tabela-dados {
    width: 100%;
    border-collapse: collapse;
    font-size: 14px;
  }
  .tabela-dados th {
    text-align: left;
    padding: 10px;
    border-bottom: 2px solid #edf2f7;
    color: #718096;
    font-size: 12px;
    text-transform: uppercase;
  }
  .tabela-dados td {
    padding: 12px 10px;
    border-bottom: 1px solid #edf2f7;
  }
  .tag-categoria {
    background: #edf2f7;
    color: #4a5568;
    padding: 3px 8px;
    border-radius: 6px;
    font-size: 11px;
    font-weight: bold;
  }
  .coluna-preco { font-weight: bold; color: #2b6cb0; }
  .btn-excluir {
    background: #fff5f5;
    color: #e53e3e;
    border: 1px solid #feb2b2;
    padding: 4px 10px;
    border-radius: 4px;
    cursor: pointer;
    font-size: 12px;
    font-weight: bold;
  }
  .btn-excluir:hover { background: #fed7d7; }
</style>
```

---

## 🏆 3. Parabéns, Desenvolvedor BlaiseVue!

Você completou o curso com honras! Olhe para trás e veja tudo o que você conquistou:
- Aprendeu como o Pascal ganha superpoderes na Web.
- Construiu interfaces reativas sem precisar decorar frameworks complexos de JavaScript.
- Entendeu como componentes, rotas, formulários e eventos trabalham em harmonia.

### 📚 Para Onde Ir Agora?
- Explore a **[Documentação Técnica Oficial](../Documentation/README.md)** para conhecer recursos avançados como formulários de validação (`b-validate`), internacionalização (`blaise-i18n`), micro-containers Docker e backends de alta performance com **mORMot 2**.
- Visite os exemplos e o código fonte em `demo-app/` para ver aplicações corporativas completas.

**O mundo da Web em Pascal está aberto para você. Vá em frente e construa grandes aplicações!** 🛡️✨🚀🏆
