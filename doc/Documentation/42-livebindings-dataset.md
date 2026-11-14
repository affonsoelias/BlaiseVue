# 42. LiveBindings & Reactive Dataset (`TBVDataSet`)

**BlaiseVue** features an enterprise **LiveBindings** and **In-Memory Reactive Dataset (`TBVDataSet`)** engine, merging classic record-oriented data semantics from **Delphi / Lazarus (`TClientDataSet` / `TDataSet`)** with modern reactive architectures from **Vue 3 (`Proxy` and `effect`)**.

With `TBVDataSet`, Pascal developers build enterprise applications featuring cursor navigation, transactional edit buffering, real-time local filtering, column sorting, offline delta tracking, and automatic two-way LiveBindings via the `b-field` directive.

---

## 1. Architecture Overview

```
+-------------------------------------------------------------+
|                     BlaiseVue Template                      |
|  <bv-datagrid :dataset="myDS" />                            |
|  <input b-field="myDS.name" />                              |
|  <span>State: {{ myDS.StateStr }} | RecNo: {{ myDS.RecNo }} |
+------------------------------+------------------------------+
                               | Two-Way Reactivity (b-field)
                               v
+-------------------------------------------------------------+
|               TBVDataSet (In-Memory Reactive)               |
|  - States: dsInactive, dsBrowse, dsEdit, dsInsert           |
|  - Buffers: FEditBuffer, FOriginalBuffer, FDelta            |
|  - Cursor: RecNo, RecordCount, Bof, Eof, IsEmpty            |
|  - Methods: Append, Edit, Post, Cancel, Delete, Locate      |
|  - Typed Fields: AsString, AsInteger, AsFloat, AsBoolean    |
|  - Offline Sync: GetDeltaJSON(), SaveToStorage()            |
+-------------------------------------------------------------+
```

---

## 2. State Machine & Lifecycle

`TBVDataSet` adheres to the strict state machine of Object Pascal's `TDataSet`:

| State | Pascal Symbol | Reactive String (`StateStr`) | Description |
| :--- | :--- | :--- | :--- |
| **Inactive** | `dsInactive` | `'inactive'` | Newly created dataset or no data loaded. |
| **Browse** | `dsBrowse` | `'browse'` | Read-only mode / cursor navigation (`RecNo`). |
| **Edit** | `dsEdit` | `'edit'` | Current record under modification in isolated buffer (`FEditBuffer`). |
| **Insert** | `dsInsert` | `'insert'` | New record in buffer pending persistence. |

### State Transitions

```pascal
ds := TBVDataSet.Create;      // dsInactive
ds.LoadFromJSON(jsonString);  // dsBrowse
ds.Edit;                      // dsEdit
ds.FieldByName('price').AsFloat := 149.90;
ds.Post;                      // dsBrowse (with recorded delta!)

ds.Append;                    // dsInsert
ds.FieldByName('name').AsString := 'New Product';
ds.Cancel;                    // dsBrowse (buffer discarded)
```

---

## 3. Comprehensive `TBVDataSet` API

### 3.1. Cursor Navigation
- `ds.First`: Moves cursor to the first active record.
- `ds.Prior`: Moves cursor to the preceding record.
- `ds.Next`: Moves cursor to the subsequent record.
- `ds.Last`: Moves cursor to the final record.
- `ds.MoveBy(Distance: Integer)`: Jumps $N$ records forward or backward.
- `ds.RecNo: Integer`: 1-based index of the current active record.
- `ds.RecordCount: Integer`: Total count of active/filtered records.
- `ds.Bof: Boolean`: Returns `True` if cursor is at the beginning of the dataset.
- `ds.Eof: Boolean`: Returns `True` if cursor is at the end of the dataset.
- `ds.IsEmpty: Boolean`: Returns `True` if dataset contains no records.

### 3.2. CRUD Operations & Buffering
- `ds.Append` / `ds.Insert`: Creates a new blank record in the edit buffer.
- `ds.Edit`: Clones the current record into the edit buffer before field modification.
- `ds.Post`: Validates modifications, persists to record array, and records operation in the offline delta.
- `ds.Cancel`: Discards buffered changes and returns to `dsBrowse`.
- `ds.Delete`: Removes current record and logs a `'delete'` entry in the delta log.
- `ds.EmptyTable`: Clears all data, active filters, and delta history.

### 3.3. Typed Field Access (`TBVField`)
```pascal
ds.AddField('id', ftInteger);
ds.AddField('title', ftString);
ds.AddField('price', ftFloat);
ds.AddField('active', ftBoolean);

// Typed Reading
id    := ds.FieldByName('id').AsInteger;
title := ds.FieldByName('title').AsString;
price := ds.FieldByName('price').AsFloat;
ok    := ds.FieldByName('active').AsBoolean;

// Typed Writing (automatically enters dsEdit when in dsBrowse)
ds.FieldByName('title').AsString := 'Gaming Laptop';
ds.FieldByName('price').AsFloat  := 4500.00;
ds.Post;
```

### 3.4. Filtering, Sorting & Search
- `ds.Locate(FieldName, Value): Boolean`: Scans dataset for an exact match; if found, positions cursor and synchronizes UI.
- `ds.SetFilter(QueryString)`: Applies instant full-text filtering across all columns and resets cursor to top (`First`).
- `ds.ClearFilter`: Restores full view of all records.
- `ds.SortBy(FieldName, Ascending: Boolean = True)`: Sorts numerically or alphabetically by the specified column.

---

## 4. LiveBindings Directive: `b-field`

The `b-field` directive directly connects any `<input>`, `<select>`, `<textarea>`, or Pascal component to a column of the active dataset.

```html
<template>
  <div class="card">
    <h3>Customer Edit</h3>
    
    <!-- Declarative two-way binding to DataSet fields -->
    <div class="form-group">
      <label>Name:</label>
      <input type="text" b-field="customerDS.name" class="form-control" />
    </div>

    <div class="form-group">
      <label>Email:</label>
      <input type="email" b-field="customerDS.email" class="form-control" />
    </div>

    <!-- DataSet Controller Bar (VCL / Lazarus Style) -->
    <div class="dataset-navigator">
      <button @click="customerDS.Prior" :disabled="customerDS.Bof">« Prior</button>
      <span>Record {{ customerDS.RecNo }} of {{ customerDS.RecordCount }}</span>
      <button @click="customerDS.Next" :disabled="customerDS.Eof">Next »</button>
      <button @click="customerDS.Append">New</button>
      <button @click="customerDS.Post" :disabled="customerDS.StateStr == 'browse'">Save</button>
      <button @click="customerDS.Cancel" :disabled="customerDS.StateStr == 'browse'">Cancel</button>
      <button @click="customerDS.Delete">Delete</button>
    </div>
  </div>
</template>
```

---

## 5. Integration with `<bv-datagrid>`

The official `bv-datagrid` component from `@blaise-ui` provides native support for reactive datasets via the `:dataset` prop:

```html
<template>
  <div class="container">
    <h2>Product Catalog</h2>

    <!-- DataGrid directly consumes productsDS, synchronizing pagination and columns -->
    <bv-datagrid :dataset="productsDS" @row-select="onSelectProduct" />

    <!-- Detail form with LiveBindings to the active record selected in the grid -->
    <div v-if="productsDS.Current" class="mt-4">
      <h4>Selected Record Details</h4>
      <input type="text" b-field="productsDS.title" />
      <input type="number" b-field="productsDS.price" />
      <button @click="productsDS.Post">Update</button>
    </div>
  </div>
</template>
```

---

## 6. Offline Synchronization & Delta Tracking

`TBVDataSet` transparently tracks all data mutations for synchronization with REST or mORMot 2 backends:

```pascal
procedure SyncWithServer;
var
  deltaJSON: string;
begin
  if productsDS.ChangeCount > 0 then
  begin
    deltaJSON := productsDS.GetDeltaJSON;
    // Dispatches batch of mutations (insert, update, delete) in a single request
    ApiSave(this, '/api/products/batch', 0, False, JsonParse(deltaJSON), 'onSyncSuccess');
    productsDS.ApplyUpdates; // Clears delta buffer after confirmed persistence
  end;
end;
```

Additionally, local persistence in `localStorage` is provided via two simple calls:
- `productsDS.SaveToStorage('offline_products');`
- `productsDS.LoadFromStorage('offline_products');`

---

## 7. Zero-ASM Pascal DX (`BVPascalDX`)

To maintain conformity with BlaiseVue's Zero-ASM architecture, the `BVPascalDX` unit exports strongly typed helpers for dataset manipulation inside any component method:

| PascalDX Routine | Direct DataSet Equivalent |
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
