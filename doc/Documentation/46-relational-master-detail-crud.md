# 🔗 Multi-Database ORM & Relational Master-Detail CRUD (`bv mormot crud`)

**BlaiseVue 4.4 — Pillar 3 Technical Specification & Developer Guide**

---

## 📌 Executive Summary

Enterprise business applications are fundamentally relational: Orders contain Order Items, Invoices have Line Items, Projects possess Tasks, and Customers link to Contracts. Generating isolated flat CRUD tables leaves developers with the burdensome task of manually constructing foreign key lookups, child table sub-grids, atomic transactional persistence, and parent-child total calculations.

**BlaiseVue 4.4 Pillar 3** introduces an enterprise **Multi-Database ORM & Relational Master-Detail CRUD** engine. With a single CLI command, BlaiseVue scaffolds:
1. **Pluggable Database Configurations** (SQLite, PostgreSQL, MySQL, Firebird).
2. **Relational Backend Schemas & Services** in Synopse mORMot 2 with atomic child collection serialization.
3. **Reactive Frontend Master-Detail Views** (`.bv`) featuring dual-grid selection synchronization, nested child line item tables, and dynamic subtotal calculations.

```
┌────────────────────────────────────────────────────────────────────────┐
│                        BLAISEVUE CLIENT VIEW                           │
│                                                                        │
│   ┌────────────────────────────────────────────────────────────────┐   │
│   │ Master Grid: Orders (customer: FK, orderDate, total, items: 3) │   │
│   │ [Row selected -> Order #101]                                   │   │
│   └───────────────────────────────┬────────────────────────────────┘   │
│                                   │ reactive selection sync            │
│                                   ▼                                    │
│   ┌────────────────────────────────────────────────────────────────┐   │
│   │ Detail Card: Items for Order #101                              │   │
│   │ - Item 1: License Pack ($499.00 x 2 = $998.00)                 │   │
│   │ - Item 2: Cloud Connector ($199.00 x 1 = $199.00)              │   │
│   │ Automatic Total: $1,197.00                                     │   │
│   └────────────────────────────────────────────────────────────────┘   │
└───────────────────────────────────┼────────────────────────────────────┘
                                    │ REST / Real-Time WebSockets
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                       SYNOPSE mORMot 2 BACKEND                         │
│                                                                        │
│   DatabaseConfig.pas: sqlite | postgres | mysql | firebird             │
│   ServerModels.pas: TOrderItem + TOrder (Items: array of TOrderItem)   │
│   CrudOrder.pas: Atomic Parent-Child Serialization & Auto-IDs          │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 🗄️ 1. Pluggable Database Engines (`bv mormot init --db`)

BlaiseVue projects support zero-config embedded SQLite for rapid development and enterprise SQL engines for production deployment.

### Supported Database Engines

| Engine | Flag | Default Port | Connection URL Scheme | Target Driver |
| :--- | :--- | :--- | :--- | :--- |
| **SQLite3** *(Default)* | `--db sqlite` | N/A (embedded) | `sqlite:///server/data.db` | Synopse SQLite3 Static |
| **PostgreSQL** | `--db postgres` | `5432` | `postgres://user:pass@localhost:5432/dbname` | Native `libpq` / mORMot |
| **MySQL / MariaDB** | `--db mysql` | `3306` | `mysql://root:pass@localhost:3306/dbname` | MySQL C API / mORMot |
| **Firebird SQL** | `--db firebird` | `3050` | `firebird://sysdba:masterkey@localhost:3050/dbname`| Native Firebird Client |

### CLI Usage

```bash
# Initialize with PostgreSQL
bv mormot init --db postgres

# Initialize with Firebird SQL
bv mormot init --db firebird

# Initialize with SQLite (default)
bv mormot init
```

### Environment-Driven Configuration (`.env`)

During initialization, BlaiseVue generates a `.env` file pre-configured for your chosen database engine:

```ini
# BlaiseVue mORMot 2 Database Configuration
DATABASE_ENGINE=postgres
DATABASE_URL=postgres://postgres:postgres@localhost:5432/blaisevue_db
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_NAME=blaisevue_db
DATABASE_USER=postgres
DATABASE_PASSWORD=postgres
```

The unified `DatabaseConfig.pas` unit parses environment variables with automatic fallback to embedded SQLite:

```pascal
unit DatabaseConfig;

interface

uses
  SysUtils;

type
  TDatabaseEngine = (deSqlite, dePostgres, deMySql, deFirebird);

  TDatabaseSettings = record
    Engine: TDatabaseEngine;
    ConnectionString: string;
    Host: string;
    Port: Integer;
    DatabaseName: string;
    User: string;
    Password: string;
  end;

function LoadDatabaseSettings: TDatabaseSettings;
function DatabaseEngineToString(Engine: TDatabaseEngine): string;
function ParseDatabaseEngine(const S: string): TDatabaseEngine;
```

---

## 🧬 2. Relational Master-Detail Declarations (`bv mormot crud`)

You can declare foreign keys and child detail collections directly in the `bv mormot crud` command.

### Field Syntax Modifiers

- **Foreign Key**: `field:FK(TargetModel)`
  - Denotes a foreign key reference to another model entity.
  - Scaffolds a string/integer reference field and renders an enterprise relationship badge in grids.
- **Child Detail Collection**: `field:Detail(ChildModel)`
  - Scaffolds a nested array of child records.
  - Automatically defines the child record stub in `ServerModels.pas` if not already present.
  - Scaffolds child item serialization, atomic ID assignment, and reactive sub-tables.

### Command Example

```bash
bv mormot crud Order "customer:FK(Customer)" "orderDate:date" "total:currency" "items:Detail(OrderItem)"
```

> [!TIP]
> In PowerShell, surround arguments containing parentheses in quotes (e.g. `"customer:FK(Customer)"` `"items:Detail(OrderItem)"`) to prevent PowerShell from interpreting parentheses as sub-expressions.

---

## 🛠️ 3. Backend Scaffolding

### Automatic Type Declarations (`ServerModels.pas`)

When a child model is referenced via `Detail(OrderItem)`, `bv` generates the child record type before the master model:

```pascal
type
  TOrderItem = record
    Id: Integer;
    OrderId: Integer;
    Description: string;
    Quantity: Integer;
    UnitPrice: Double;
  end;
  TOrderItemArray = array of TOrderItem;

  TOrder = record
    Id: Integer;
    Customer: string; // Foreign Key to Customer
    OrderDate: string;
    Total: Double;
    Items: TOrderItemArray; // Child Detail Collection
  end;
  TOrderList = array of TOrder;
```

### Relational Service & Serialization (`CrudOrder.pas`)

The generated CRUD unit provides:
1. **JSON Serialization (`ItemToJson`)**: Encodes the master record along with the nested array of child records.
2. **JSON Deserialization (`CreateItemFromJson` / `UpdateItemFromJson`)**:
   - Parses the parent fields.
   - Extracts child JSON items, assigns atomic child IDs if absent, and links `OrderId`.
3. **Atomic Total Calculation**: Automatically computes totals across child records.
4. **WebSocket Broadcasting**: Broadcasts `order_created`, `order_updated`, and `order_deleted` real-time events.

---

## 🖥️ 4. Frontend Master-Detail View (`OrderView.bv`)

The generated `.bv` component delivers an interactive dual-view experience:

### Features
- **Master Grid**: Displays top-level fields, formatted currency totals, foreign key relationship badges, and child items count badges.
- **Row Selection Synchronization**: Clicking any row triggers `selectMaster(item)` which binds the order to the detail section.
- **Nested Child Table**: Displays line items with descriptions, quantities, unit prices, and line subtotals.
- **Dynamic Totals**: Computed properties recalculate totals instantly when line items change.

```html
<template>
  <div class="crud-view">
    <!-- Master Grid -->
    <bv-card title="Order Management">
      <table class="table table-hover">
        <thead>
          <tr>
            <th>ID</th>
            <th>Customer</th>
            <th>Order Date</th>
            <th>Total</th>
            <th>Items</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr b-for="item in items" :key="item.id" @click="selectMaster(item)" :class="{ 'table-active': selectedMaster && selectedMaster.id === item.id }">
            <td>#{{ item.id }}</td>
            <td><span class="badge bg-info">{{ item.customer }}</span></td>
            <td>{{ item.orderDate }}</td>
            <td><strong>{{ formatCurrency(item.total) }}</strong></td>
            <td><span class="badge bg-secondary">{{ item.items ? item.items.length : 0 }} items</span></td>
            <td>
              <bv-btn size="sm" variant="danger" @click.stop="deleteItem(item.id)">Delete</bv-btn>
            </td>
          </tr>
        </tbody>
      </table>
    </bv-card>

    <!-- Detail Child Collection View -->
    <bv-card v-if="selectedMaster" :title="'Order #' + selectedMaster.id + ' - Line Items'" class="mt-4">
      <table class="table table-sm">
        <thead>
          <tr>
            <th>#</th>
            <th>Description</th>
            <th>Quantity</th>
            <th>Unit Price</th>
            <th>Subtotal</th>
          </tr>
        </thead>
        <tbody>
          <tr b-for="(line, idx) in selectedMaster.items" :key="idx">
            <td>{{ line.id || (idx + 1) }}</td>
            <td>{{ line.description }}</td>
            <td>{{ line.quantity }}</td>
            <td>{{ formatCurrency(line.unitPrice) }}</td>
            <td>{{ formatCurrency((line.quantity || 1) * (line.unitPrice || 0)) }}</td>
          </tr>
        </tbody>
      </table>
      <div class="text-end">
        <h5>Total: {{ formatCurrency(computeDetailTotal(selectedMaster.items)) }}</h5>
      </div>
    </bv-card>
  </div>
</template>
```

---

## 🧪 5. Automated Verification

The relational engine and database configurations are validated by the test suite in `demo-app/tests/framework/mormot_relational.test.pas`:
- Multi-database engine and port mapping resolution.
- Relational foreign key and detail constraints.
- Master-detail child serialization and parsing.
- Dynamic child item total computation.
- Reactive selection synchronization.

Run the test suite with:
```bash
bv test
```
