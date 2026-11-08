# 📊 Module 14: Enterprise Data Architecture & TDataSet
**Bridge classical Delphi/Lazarus record-buffered data architectures with modern Vue 3 reactivity.**

For decades, desktop enterprise systems developed in Delphi and Lazarus have relied on the battle-tested **`TDataSet`** architecture. Features like cursor navigation, transactional edit buffers (`Edit`, `Post`, `Cancel`), master-detail relationships, and field-level metadata enabled developers to build massive ERP, CRM, and banking applications with ease.

In BlaiseVue, you don't have to abandon these proven paradigms! BlaiseVue introduces **`TBVDataSet`**: a reactive, in-memory dataset engine written in 100% Object Pascal that combines classical `TDataSet` state semantics with the ultra-fast reactivity (`Proxy` and `effect`) of modern web frameworks.

---

## 🏛️ 1. Architectural Overview

```text
┌─────────────────────────────────────────────────────────────┐
│                     BlaiseVue Component                     │
│  <bv-datagrid :dataset="customerDS" />                      │
│  <input b-field="customerDS.name" />                        │
│  <span>Record: {{ customerDS.RecNo }} of {{ customerDS.RecordCount }}</span>
└──────────────────────────────┬──────────────────────────────┘
                               │ Bidirectional LiveBindings (b-field)
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                  TBVDataSet (In-Memory Engine)              │
│  - State Machine: dsInactive, dsBrowse, dsEdit, dsInsert    │
│  - Dual Buffers: Current Values, Edit Buffer, Original Delta│
│  - Navigation Cursor: First, Next, Prior, Last, Locate      │
│  - Strongly-Typed Fields: AsString, AsInteger, AsFloat      │
│  - Offline Persistence: GetDeltaJSON(), LoadFromJSON()      │
└─────────────────────────────────────────────────────────────┘
```

---

## 🚦 2. The TDataSet State Machine

`TBVDataSet` follows the strict, deterministic state machine familiar to every Pascal engineer:

| State | Pascal Enum | Reactive String (`StateStr`) | Description |
|---|---|---|---|
| **Inactive** | `dsInactive` | `'inactive'` | Dataset created but has no active schema or data. |
| **Browse** | `dsBrowse` | `'browse'` | Read-only cursor mode. Navigation is enabled. |
| **Edit** | `dsEdit` | `'edit'` | Current row is undergoing modifications in an isolated memory buffer. |
| **Insert** | `dsInsert` | `'insert'` | A new row has been appended or inserted and is pending validation. |

### State Transitions in Action:

```pascal
var
  ds: TBVDataSet;
begin
  ds := TBVDataSet.Create;           // State: dsInactive
  ds.LoadFromJSON(jsonArrayString);  // State: dsBrowse

  // Modify an existing record
  ds.Edit;                           // State: dsEdit
  ds.FieldByName('creditLimit').AsFloat := 7500.00;
  ds.Post;                           // State: dsBrowse (changes committed & delta logged!)

  // Append a brand new record
  ds.Append;                         // State: dsInsert
  ds.FieldByName('name').AsString := 'Acme Global';
  ds.FieldByName('active').AsBoolean := True;
  
  // Decide not to keep the new record
  ds.Cancel;                         // State: dsBrowse (buffer discarded instantly!)
end;
```

---

## ⚡ 3. Declarative LiveBindings with `b-field`

Rather than manually writing `@input` event listeners and synchronizing text values back and forth, BlaiseVue provides the **`b-field`** directive. 

When you bind an input with `b-field="myDS.fieldName"`:
1. The input displays the current value of that field for the active record (`RecNo`).
2. When the user types into the input, the dataset automatically transitions into `dsEdit` (if in `dsBrowse`) and updates the edit buffer.
3. When the user moves the cursor (`ds.Next` or clicking another row in the grid), the form fields automatically update to reflect the newly active record!

```html
<template>
  <div class="dataset-card">
    <header class="card-header">
      <h3>Customer Manager</h3>
      <div class="state-pill" :class="ds.StateStr">Status: {{ ds.StateStr }}</div>
    </header>

    <!-- Master Form Bound with b-field -->
    <div class="form-grid">
      <div class="form-group">
        <label>Customer Name:</label>
        <input type="text" b-field="ds.name" />
      </div>

      <div class="form-group">
        <label>Email Address:</label>
        <input type="email" b-field="ds.email" />
      </div>

      <div class="form-group">
        <label>Credit Limit ($):</label>
        <input type="number" b-field="ds.creditLimit" />
      </div>
    </div>

    <!-- Navigation & Transaction Toolbar -->
    <div class="toolbar">
      <button @click="ds.First" :disabled="ds.Bof">⏮️ First</button>
      <button @click="ds.Prior" :disabled="ds.Bof">◀️ Prior</button>
      <span class="cursor-counter">Row {{ ds.RecNo }} of {{ ds.RecordCount }}</span>
      <button @click="ds.Next" :disabled="ds.Eof">▶️ Next</button>
      <button @click="ds.Last" :disabled="ds.Eof">⏭️ Last</button>

      <span class="divider"></span>

      <button @click="ds.Append" class="btn-new">➕ Append</button>
      <button @click="ds.Post" :disabled="not (ds.State in [dsEdit, dsInsert])" class="btn-save">💾 Post</button>
      <button @click="ds.Cancel" :disabled="not (ds.State in [dsEdit, dsInsert])" class="btn-cancel">❌ Cancel</button>
      <button @click="ds.Delete" class="btn-del">🗑️ Delete</button>
    </div>
  </div>
</template>

<script>
uses SysUtils, BVDataSet;

var
  ds: TBVDataSet;

mounted:
  procedure;
  begin
    ds := TBVDataSet.Create;
    // Define field schema
    ds.FieldDefs.Add('id', ftInteger);
    ds.FieldDefs.Add('name', ftString);
    ds.FieldDefs.Add('email', ftString);
    ds.FieldDefs.Add('creditLimit', ftFloat);
    ds.FieldDefs.Add('active', ftBoolean);

    // Load initial seed data
    ds.LoadFromJSON('[' +
      '{"id": 1, "name": "Alpha Corp", "email": "contact@alpha.com", "creditLimit": 5000.0, "active": true},' +
      '{"id": 2, "name": "Beta Logistics", "email": "info@beta.com", "creditLimit": 12000.0, "active": true},' +
      '{"id": 3, "name": "Gamma Tech", "email": "ops@gamma.com", "creditLimit": 8500.0, "active": false}' +
    ']');
  end;
</script>

<style>
.dataset-card {
  max-width: 600px;
  margin: 20px auto;
  padding: 20px;
  border-radius: 10px;
  background: #ffffff;
  box-shadow: 0 4px 12px rgba(0,0,0,0.06);
}
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid #eee;
  padding-bottom: 10px;
}
.state-pill {
  padding: 4px 10px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: bold;
  text-transform: uppercase;
}
.state-pill.browse { background: #e0f2fe; color: #0369a1; }
.state-pill.edit { background: #fef3c7; color: #b45309; }
.state-pill.insert { background: #dcfce7; color: #15803d; }
.form-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 15px;
  margin: 15px 0;
}
.form-group label { display: block; font-size: 13px; margin-bottom: 4px; color: #555; }
.form-group input { width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 6px; box-sizing: border-box; }
.toolbar { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; margin-top: 15px; }
.toolbar button { padding: 6px 12px; border-radius: 6px; border: 1px solid #ccc; cursor: pointer; }
.toolbar button:disabled { opacity: 0.5; cursor: not-allowed; }
.btn-save { background: #16a34a; color: #fff; border: none; font-weight: bold; }
.btn-cancel { background: #64748b; color: #fff; border: none; }
.btn-del { background: #ef4444; color: #fff; border: none; }
.divider { width: 1px; height: 24px; background: #ddd; margin: 0 4px; }
</style>
```

---

## 🔎 4. Searching and Fast In-Memory Locating

Just like standard `TDataSet.Locate`, you can instantly jump the cursor to any record matching your criteria:

```pascal
procedure FindCustomer(const AName: string);
begin
  if ds.Locate('name', AName, [loCaseInsensitive, loPartialKey]) then
    WriteLn('Customer located at record #', ds.RecNo)
  else
    ShowMessage('Customer not found!');
end;
```

---

## 💾 5. Offline Delta Sync & Change Tracking

One of the greatest advantages of `TBVDataSet` is its built-in transactional delta tracking. Every time you call `Post` on an updated or newly inserted record, `TBVDataSet` does not overwrite the baseline original. Instead, it logs an entry in its internal **Delta Log**:

```pascal
var
  DeltaJSON: string;
begin
  // Generates a compact payload containing ONLY modified, added, and deleted rows!
  DeltaJSON := ds.GetDeltaJSON;
  
  // Send the delta packet to your backend REST or RPC endpoint:
  StoreDispatch('customers/syncDeltas', DeltaJSON);
  
  // Once the server confirms persistence, commit changes locally:
  ds.AcceptChanges;
end;
```

If the user goes offline or loses network connectivity, call `ds.SaveToStorage('customers_offline')` to serialize the entire dataset and its delta log into the browser's indexed storage!

---

## 🏋️ Practical Exercise

1. Create a `TBVDataSet` in your project view with fields `sku` (string), `description` (string), `quantity` (integer), and `unitPrice` (float).
2. Load seed data representing five warehouse items.
3. Build a reactive UI with `b-field` inputs for editing the selected item.
4. Add a computed property or Pascal function that computes the **Total Inventory Value** (`quantity * unitPrice`) summing across all records by iterating from `ds.First` to `ds.Next` until `ds.Eof`.
5. Verify that editing any quantity immediately reflects in the live UI!

---

## 📖 Deeper Technical Reference

- **[LiveBindings & Reactive TDataSet Manual](../Documentation/42-livebindings-dataset.md)**: Complete API specification for `TBVDataSet`, typed fields (`AsInteger`, `AsFloat`, `AsDateTime`), and state transitions.
- **[Offline TDataSet & Delta Synchronization](../Documentation/45-offline-dataset-delta-sync.md)**: Deep-dive into delta packets, optimistic concurrency, and local storage serialization.

---

[⬅️ Module 13: BlaiseX 2.0 & Finite State Machines](13-blaisex-fsm.md) | [🏠 Course Index](README.md) | [Module 15: Full-Stack mORMot 2 Setup & Architecture ➡️](15-mormot-init.md)
