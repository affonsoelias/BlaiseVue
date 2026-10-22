# 42. LiveBindings & Dataset Reativo (`TBVDataSet`)

O **BlaiseVue** conta com o motor enterprise de **LiveBindings** e **Dataset Reativo em Memória (`TBVDataSet`)**, unindo a semântica clássica de dados orientada a registros do **Delphi / Lazarus (`TClientDataSet` / `TDataSet`)** com o modelo reativo de ponta do **Vue 3 (`Proxy` e `effect`)**.

Com o `TBVDataSet`, desenvolvedores Pascal criam aplicações empresariais com navegação por cursor, buffering de edição transacional, filtragem local em tempo real, ordenação por coluna, rastreamento offline de deltas e LiveBindings bidirecionais automáticos via diretiva `b-field`.

---

## 1. Visão Geral da Arquitetura

```
+-------------------------------------------------------------+
|                     Template BlaiseVue                      |
|  <bv-datagrid :dataset="myDS" />                            |
|  <input b-field="myDS.name" />                              |
|  <span>Estado: {{ myDS.StateStr }} | RecNo: {{ myDS.RecNo }}|
+------------------------------+------------------------------+
                               | Reatividade Bidirecional (b-field)
                               v
+-------------------------------------------------------------+
|                  TBVDataSet (Reativo em Memória)            |
|  - States: dsInactive, dsBrowse, dsEdit, dsInsert           |
|  - Buffers: FEditBuffer, FOriginalBuffer, FDelta            |
|  - Cursos: RecNo, RecordCount, Bof, Eof, IsEmpty            |
|  - Métodos: Append, Edit, Post, Cancel, Delete, Locate      |
|  - Typed Fields: AsString, AsInteger, AsFloat, AsBoolean    |
|  - Offline Sync: GetDeltaJSON(), SaveToStorage()            |
+-------------------------------------------------------------+
```

---

## 2. Máquina de Estados e Ciclo de Vida

O `TBVDataSet` adota a máquina de estados rigorosa do `TDataSet` do Object Pascal:

| Estado | Símbolo Pascal | String Reativa (`StateStr`) | Descrição |
| :--- | :--- | :--- | :--- |
| **Inativo** | `dsInactive` | `'inactive'` | Dataset recém-criado ou sem dados carregados. |
| **Navegação** | `dsBrowse` | `'browse'` | Modo de leitura / navegação pelo cursor (`RecNo`). |
| **Edição** | `dsEdit` | `'edit'` | Registro atual sob edição em buffer isolado (`FEditBuffer`). |
| **Inserção** | `dsInsert` | `'insert'` | Novo registro em buffer pendente de persistência. |

### Transições de Estado

```pascal
ds := TBVDataSet.Create;      // dsInactive
ds.LoadFromJSON(jsonString);  // dsBrowse
ds.Edit;                      // dsEdit
ds.FieldByName('price').AsFloat := 149.90;
ds.Post;                      // dsBrowse (com delta registrado!)

ds.Append;                    // dsInsert
ds.FieldByName('name').AsString := 'Novo Produto';
ds.Cancel;                    // dsBrowse (buffer descartado)
```

---

## 3. API Completa do `TBVDataSet`

### 3.1. Navegação de Cursor
- `ds.First`: Move o cursor para o primeiro registro ativo.
- `ds.Prior`: Move o cursor para o registro anterior.
- `ds.Next`: Move o cursor para o próximo registro.
- `ds.Last`: Move o cursor para o último registro.
- `ds.MoveBy(Distance: Integer)`: Salta $N$ registros para frente ou para trás.
- `ds.RecNo: Integer`: Índice 1-based do registro atual.
- `ds.RecordCount: Integer`: Quantidade total de registros ativos/filtrados.
- `ds.Bof: Boolean`: Retorna `True` se estiver no início do dataset.
- `ds.Eof: Boolean`: Retorna `True` se estiver no fim do dataset.
- `ds.IsEmpty: Boolean`: Retorna `True` se a tabela estiver vazia.

### 3.2. Operações CRUD e Buffering
- `ds.Append` / `ds.Insert`: Cria um novo registro limpo no buffer de edição.
- `ds.Edit`: Clona o registro atual em buffer de edição antes de modificar campos.
- `ds.Post`: Valida alterações, persiste no array de registros e adiciona a operação no delta offline.
- `ds.Cancel`: Aborta as alterações em buffer e retorna para `dsBrowse`.
- `ds.Delete`: Remove o registro atual e gera entrada `'delete'` no log de deltas.
- `ds.EmptyTable`: Limpa todos os dados, filtros e histórico de deltas.

### 3.3. Acesso Tipado a Campos (`TBVField`)
```pascal
ds.AddField('id', ftInteger);
ds.AddField('title', ftString);
ds.AddField('price', ftFloat);
ds.AddField('active', ftBoolean);

// Leitura Tipada
id    := ds.FieldByName('id').AsInteger;
title := ds.FieldByName('title').AsString;
price := ds.FieldByName('price').AsFloat;
ok    := ds.FieldByName('active').AsBoolean;

// Escrita Tipada (entra automaticamente em dsEdit se estiver em dsBrowse)
ds.FieldByName('title').AsString := 'Laptop Gamer';
ds.FieldByName('price').AsFloat  := 4500.00;
ds.Post;
```

### 3.4. Filtragem, Ordenação e Pesquisa
- `ds.Locate(FieldName, Value): Boolean`: Varre o dataset procurando correspondência exata; se encontrar, posiciona o cursor no registro e sincroniza a UI.
- `ds.SetFilter(QueryString)`: Aplica filtro "full-text" instantâneo em todas as colunas e reposiciona o cursor no topo (`First`).
- `ds.ClearFilter`: Restaura a visão completa dos registros.
- `ds.SortBy(FieldName, Ascending: Boolean = True)`: Ordena numericamente ou alfabeticamente pela coluna indicada.

---

## 4. Diretiva de LiveBindings: `b-field`

A diretiva `b-field` conecta diretamente qualquer `<input>`, `<select>`, `<textarea>` ou componente Pascal a uma coluna do dataset atual.

```html
<template>
  <div class="card">
    <h3>Edição de Cliente</h3>
    
    <!-- Vinculação declarativa e bidirecional aos campos do DataSet -->
    <div class="form-group">
      <label>Nome:</label>
      <input type="text" b-field="customerDS.name" class="form-control" />
    </div>

    <div class="form-group">
      <label>E-mail:</label>
      <input type="email" b-field="customerDS.email" class="form-control" />
    </div>

    <!-- Barra de Controle do DataSet (VCL / Lazarus Style) -->
    <div class="dataset-navigator">
      <button @click="customerDS.Prior" :disabled="customerDS.Bof">« Anterior</button>
      <span>Registro {{ customerDS.RecNo }} de {{ customerDS.RecordCount }}</span>
      <button @click="customerDS.Next" :disabled="customerDS.Eof">Próximo »</button>
      <button @click="customerDS.Append">Novo</button>
      <button @click="customerDS.Post" :disabled="customerDS.StateStr == 'browse'">Salvar</button>
      <button @click="customerDS.Cancel" :disabled="customerDS.StateStr == 'browse'">Cancelar</button>
      <button @click="customerDS.Delete">Excluir</button>
    </div>
  </div>
</template>
```

---

## 5. Integração com `<bv-datagrid>`

O componente oficial `bv-datagrid` do pacote `@blaise-ui` possui suporte nativo a datasets reativos através da propriedade `:dataset`:

```html
<template>
  <div class="container">
    <h2>Catálogo de Produtos</h2>

    <!-- O DataGrid consome myDS diretamente, sincronizando paginação e colunas -->
    <bv-datagrid :dataset="productsDS" @row-select="onSelectProduct" />

    <!-- Formulário detalhado com LiveBindings ao registro selecionado na grade -->
    <div v-if="productsDS.Current" class="mt-4">
      <h4>Detalhes do Registro Selecionado</h4>
      <input type="text" b-field="productsDS.title" />
      <input type="number" b-field="productsDS.price" />
      <button @click="productsDS.Post">Atualizar</button>
    </div>
  </div>
</template>
```

---

## 6. Sincronização e Rastreamento Offline (Deltas)

O `TBVDataSet` rastreia silenciosamente todas as mutações sofridas pelos dados para sincronização com backends REST ou mORMot 2:

```pascal
procedure SyncWithServer;
var
  deltaJSON: string;
begin
  if productsDS.ChangeCount > 0 then
  begin
    deltaJSON := productsDS.GetDeltaJSON;
    // Envia lote de alterações (insert, update, delete) em uma única requisição
    ApiSave(this, '/api/products/batch', 0, False, JsonParse(deltaJSON), 'onSyncSuccess');
    productsDS.ApplyUpdates; // Limpa o delta após persistência confirmada
  end;
end;
```

Além disso, persistência local no `localStorage` é provida por duas chamadas:
- `productsDS.SaveToStorage('offline_products');`
- `productsDS.LoadFromStorage('offline_products');`

---

## 7. Zero-ASM Pascal DX (`BVPascalDX`)

Para manter conformidade com a arquitetura Zero-ASM do BlaiseVue, o unit `BVPascalDX` exporta utilitários fortemente tipados para manipulação de datasets em qualquer método de componente:

| Rotina PascalDX | Equivalente Direto no DataSet |
| :--- | :--- |
| `NewDataSet: JSValue` | `TBVDataSet.Create` |
| `DataSetLoad(ds, data)` | `ds.LoadFromData(data)` |
| `DataSetAppend(ds)` | `ds.Append` |
| `DataSetEdit(ds)` | `ds.Edit` |
| `DataSetPost(ds)` | `ds.Post` |
| `DataSetCancel(ds)` | `ds.Cancel` |
| `DataSetDelete(ds)` | `ds.Delete` |
| `DataSetFirst(ds)` | `ds.First` |
| `DataSetPrior(ds)` | `ds.Prior` |
| `DataSetNext(ds)` | `ds.Next` |
| `DataSetLast(ds)` | `ds.Last` |
| `DataSetLocate(ds, 'name', 'X')` | `ds.Locate('name', 'X')` |
| `DataSetFilter(ds, 'query')` | `ds.SetFilter('query')` |
| `DataSetSort(ds, 'price', True)` | `ds.SortBy('price', True)` |
| `DataSetFieldVal(ds, 'field')` | `ds.FieldByName('field').AsString` |
| `DataSetSetFieldVal(ds, 'field', val)` | `ds.FieldByName('field').AsString := val` |
| `DataSetDeltaJSON(ds)` | `ds.GetDeltaJSON` |
| `DataSetApplyUpdates(ds)` | `ds.ApplyUpdates` |
