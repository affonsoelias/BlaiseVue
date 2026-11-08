# 🗃️ Module 16: Scaffolding Enterprise CRUD & Reactive DataGrid
**From a single terminal command to a complete full-stack entity: ORM, REST API, WebSockets, and a reactive DataGrid.**

In conventional web development, creating a full-stack CRUD feature for a business entity (e.g. `Customer`, `Product`, or `Invoice`) is a tedious, multi-hour process:
1. Define the SQL schema and migration scripts.
2. Write the backend ORM entity and data transfer objects (DTOs).
3. Implement REST controllers for `GET`, `POST`, `PUT`, and `DELETE`.
4. Configure CORS and route handlers.
5. Create frontend API client functions.
6. Build a reactive UI table with search filtering, pagination, sorting, and modal forms.

With the **BlaiseVue Full-Stack CRUD & ORM Generator**, this entire workflow is automated in **less than two seconds**!

---

## 🛠️ 1. The `bv mormot crud` Command

To generate an entire full-stack entity, specify the model name followed by its fields and types:

```bash
# Customer Relationship Management (CRM)
bv mormot crud Customer name:string email:string phone:string active:boolean

# Product Inventory Catalog
bv mormot crud Product name:string price:currency stock:integer category:string

# Project Management Tasks
bv mormot crud Task title:string priority:integer done:boolean dueDate:date
```

### 📋 Supported Field Types

| Type Identifier | Pascal Backend Type | JavaScript Frontend Type | Rendered Input Element |
|---|---|---|---|
| `string` / `text` | `RawUtf8` | `string` | `<input type="text">` |
| `integer` / `int` | `Integer` | `number` | `<input type="number" step="1">` |
| `currency` / `money` | `Currency` | `number` | `<input type="number" step="0.01">` |
| `float` / `double` | `Double` | `number` | `<input type="number" step="any">` |
| `boolean` / `bool` | `Boolean` | `boolean` | `<input type="checkbox">` |
| `date` | `TDateTime` | `string` (YYYY-MM-DD) | `<input type="date">` |
| `datetime` | `TDateTime` | `string` (ISO 8601) | `<input type="datetime-local">` |

---

## 📂 2. What Gets Generated Automatically?

Running `bv mormot crud Customer name:string email:string phone:string active:boolean` scaffolds five interconnected layers:

```text
1. [Backend Model]   server/ServerModels.pas
   └── Defines TCustomer and TCustomerDynArray records with JSON serialization tags.

2. [Backend Service] server/CrudCustomer.pas
   └── Implements asynchronous REST endpoints:
       • GET    /api/customer       (List all with pagination and search query)
       • GET    /api/customer/:id   (Retrieve single record)
       • POST   /api/customer       (Create new record & broadcast WebSocket)
       • PUT    /api/customer/:id   (Update record & broadcast WebSocket)
       • DELETE /api/customer/:id   (Delete record & broadcast WebSocket)

3. [Backend Router]  server/ServerApp.pas
   └── Registers routes and WebSocket event emitters:
       • customer_created
       • customer_updated
       • customer_deleted

4. [Frontend View]   src/views/CustomerView.bv
   └── Complete Single File Component featuring:
       • Search bar with debounce filtering
       • Column sorting (ascending/descending)
       • Pagination controls
       • Modal dialog for creating and editing records
       • Automatic real-time synchronization over WebSockets!

5. [Frontend Router] src/app.bv
   └── Injects route: '/customers': 'customer-view-page'
```

---

## 🔬 3. Inside the Generated Code

### Backend Record (`server/ServerModels.pas`):
```pascal
type
  TCustomer = record
    id: Integer;
    name: RawUtf8;
    email: RawUtf8;
    phone: RawUtf8;
    active: Boolean;
    createdAt: RawUtf8;
    updatedAt: RawUtf8;
  end;
  TCustomerDynArray = array of TCustomer;
```

### Frontend Reactive View (`src/views/CustomerView.bv`):
The generated view is a production-grade component built entirely with BlaiseVue directives:

```html
<template>
  <div class="crud-container">
    <header class="crud-header">
      <h2>👥 Customer Management</h2>
      <button @click="openCreateModal" class="btn-primary">➕ New Customer</button>
    </header>

    <!-- Search & Filter Controls -->
    <div class="search-bar">
      <input 
        type="text" 
        b-model="searchQuery" 
        placeholder="🔍 Search customers by name or email..." 
      />
    </div>

    <!-- Reactive Data Table -->
    <table class="data-table">
      <thead>
        <tr>
          <th @click="sortBy('id')">ID</th>
          <th @click="sortBy('name')">Name</th>
          <th @click="sortBy('email')">Email</th>
          <th>Phone</th>
          <th>Status</th>
          <th>Actions</th>
        </tr>
      </thead>
      <tbody>
        <tr b-for="cust in filteredCustomers">
          <td>{{ cust.id }}</td>
          <td><strong>{{ cust.name }}</strong></td>
          <td>{{ cust.email }}</td>
          <td>{{ cust.phone }}</td>
          <td>
            <span class="status-badge" :class="cust.active ? 'active' : 'inactive'">
              {{ cust.active ? 'Active' : 'Inactive' }}
            </span>
          </td>
          <td class="action-buttons">
            <button @click="editCustomer(cust)" class="btn-sm">✏️ Edit</button>
            <button @click="deleteCustomer(cust.id)" class="btn-sm danger">🗑️ Delete</button>
          </td>
        </tr>
      </tbody>
    </table>

    <!-- Modal Form Dialog -->
    <div b-if="showModal" class="modal-overlay">
      <div class="modal-card">
        <h3>{{ isEditing ? 'Edit Customer' : 'Add New Customer' }}</h3>
        
        <div class="form-group">
          <label>Full Name:</label>
          <input type="text" b-model="form.name" />
        </div>
        <div class="form-group">
          <label>Email Address:</label>
          <input type="email" b-model="form.email" />
        </div>
        <div class="form-group">
          <label>Phone Number:</label>
          <input type="text" b-model="form.phone" />
        </div>
        <div class="form-check">
          <label>
            <input type="checkbox" b-model="form.active" />
            Active Account
          </label>
        </div>

        <div class="modal-actions">
          <button @click="saveCustomer" class="btn-primary">💾 Save</button>
          <button @click="closeModal" class="btn-secondary">Cancel</button>
        </div>
      </div>
    </div>
  </div>
</template>
```

---

## ⚡ 4. Real-Time Multi-User Synchronization

Notice something magical when running your application:
1. Open your browser to `http://localhost:8090/#/customers`.
2. Open a second browser window (or incognito tab) side-by-side to the same URL.
3. In Window A, add a new customer or edit an existing one.
4. **Window B updates immediately without refreshing the page!**

### How Does It Work?
When the mORMot 2 backend processes a `POST` or `PUT` request in `CrudCustomer.pas`, it dispatches a lightweight WebSocket frame (`customer_created` / `customer_updated`) via `TWebSocketServer`. The frontend component listens for these events and updates its reactive array in-place!

---

## 🏋️ Practical Exercise

1. Start your backend server using `bv mormot run`.
2. In a separate terminal, scaffold a Product catalog:
   ```bash
   bv mormot crud Product name:string price:currency stock:integer category:string
   ```
3. Open `http://localhost:8090/#/products` in your browser.
4. Add three products with different categories (`Electronics`, `Office`, `Hardware`).
5. Type `"Office"` in the search input and verify that the data table filters instantly in real time.
6. Edit the stock of one product and observe the update in the table.

---

## 📖 Deeper Technical Reference

- **[Full-Stack Pascal with mORMot 2 (CRUD Section)](../Documentation/37-mormot2-backend.md)**: Details on REST query parameters, SQL transactions, and custom validation hooks.
- **[Relational Master-Detail CRUD Specification](../Documentation/46-relational-master-detail-crud.md)**: Advanced master-detail models with nested line-items and foreign keys.

---

[⬅️ Module 15: Full-Stack mORMot 2 Setup & Architecture](15-mormot-init.md) | [🏠 Course Index](README.md) | [Module 17: Full-Stack JWT Authentication & Route Guards ➡️](17-mormot-auth.md)
