# 24. BlaiseUI (Official Component Kit)

**BlaiseUI** is the official component library designed natively for BlaiseVue 2.0. Written in Object Pascal and `.bv` Single File Components, it provides a cohesive design system and high-performance UI widgets with zero external CSS dependencies.

---

## 📦 Architecture & Location

BlaiseUI is distributed in two locations:
- **Source Package**: [`packages/blaise-ui/`](file:///c:/Users/Pichau/Documents/BlaiseVue/packages/blaise-ui/)
- **Application Integration**: [`demo-app/lib/blaise-ui/`](file:///c:/Users/Pichau/Documents/BlaiseVue/demo-app/lib/blaise-ui/)

Because BlaiseVue automatically scans the `lib/` directory:
1. All `.bv` components are **globally registered** (no manual import statements needed).
2. The unified stylesheet [`blaise-ui.css`](file:///c:/Users/Pichau/Documents/BlaiseVue/packages/blaise-ui/blaise-ui.css) is automatically injected into the `<head>` of your `index.html`.

---

## 🎨 Design System & Theming

BlaiseUI uses modern CSS variables for rapid theme customization:

```css
:root {
  --bv-primary: #3b82f6;
  --bv-primary-hover: #2563eb;
  --bv-success: #10b981;
  --bv-danger: #ef4444;
  --bv-warning: #f59e0b;
  --bv-bg: #ffffff;
  --bv-surface: #f8fafc;
  --bv-border: #e2e8f0;
  --bv-text: #1e293b;
  --bv-radius: 8px;
}
```

---

## 🧩 Component Catalog

### 1. `<bv-btn>` (Button)
A flexible button supporting variants, sizes, and loading states.

| Prop | Type | Default | Description |
|---|---|---|---|
| `variant` | `string` | `'primary'` | `'primary'`, `'secondary'`, `'success'`, `'danger'`, `'warning'`, `'outline'`, `'ghost'` |
| `size` | `string` | `'md'` | `'sm'`, `'md'`, `'lg'` |
| `disabled`| `boolean` | `false` | Disables interaction and dims appearance |
| `loading` | `boolean` | `false` | Displays an animated loading spinner |
| `label` | `string` | `''` | Text label (fallback for slot) |

**Usage Example:**
```html
<bv-btn variant="primary" @click="saveRecord">Save Record</bv-btn>
<bv-btn variant="danger" :loading="isDeleting" @click="deleteRecord">Delete</bv-btn>
<bv-btn variant="outline" size="sm" @click="cancel">Cancel</bv-btn>
```

---

### 2. `<bv-card>` (Card Container)
A structured surface component with dedicated header, body, and footer sections.

| Prop | Type | Default | Description |
|---|---|---|---|
| `title` | `string` | `''` | Header card title |
| `subtitle`| `string` | `''` | Header secondary subtitle |
| `shadow` | `boolean` | `true` | Enables subtle box-shadow |

**Slots:**
- `header` — Custom header markup.
- `default` — Card main body.
- `footer` — Action bar or card footer.

**Usage Example:**
```html
<bv-card title="System Health" subtitle="Real-time Node Telemetry">
  <p>CPU Utilization: 24%</p>
  <p>Memory Free: 12.4 GB</p>

  <template b-slot:footer>
    <bv-btn size="sm" variant="secondary" @click="refreshStats">Refresh</bv-btn>
  </template>
</bv-card>
```

---

### 3. `<bv-input>` (Form Input)
A validated form input with reactive two-way binding.

| Prop | Type | Default | Description |
|---|---|---|---|
| `modelValue` / `value` | `string` | `''` | Two-way binding value (`b-model`) |
| `label` | `string` | `''` | Field label displayed above input |
| `placeholder` | `string` | `''` | Placeholder text |
| `type` | `string` | `'text'` | HTML input type (`'text'`, `'password'`, `'email'`, `'number'`) |
| `error` | `string` | `''` | Validation error message displayed below input |
| `disabled` | `boolean` | `false` | Disables user input |

**Usage Example:**
```html
<bv-input
  b-model="username"
  label="Username"
  placeholder="Enter your username"
  :error="userError"
></bv-input>
```

---

### 4. `<bv-modal>` (Teleport Dialog)
A modal dialog powered by `<teleport to="body">` that avoids CSS overflow issues.

| Prop | Type | Default | Description |
|---|---|---|---|
| `modelValue` / `isOpen` | `boolean` | `false` | Controls modal visibility (`b-model`) |
| `title` | `string` | `''` | Dialog header title |
| `size` | `string` | `'md'` | `'sm'`, `'md'`, `'lg'`, `'xl'` |

**Slots:**
- `header` — Custom dialog header.
- `default` — Modal body content.
- `footer` — Dialog action buttons.

**Usage Example:**
```html
<bv-modal b-model="showConfirmDialog" title="Confirm Transaction">
  <p>Are you sure you want to transfer $500.00?</p>

  <template b-slot:footer>
    <bv-btn variant="secondary" @click="showConfirmDialog = false">Cancel</bv-btn>
    <bv-btn variant="primary" @click="executeTransfer">Confirm</bv-btn>
  </template>
</bv-modal>
```

---

### 5. `<bv-toast>` (Notification Toast)
Auto-expiring toast alerts for user feedback.

| Prop | Type | Default | Description |
|---|---|---|---|
| `visible` | `boolean` | `false` | Toast visibility toggle |
| `title` | `string` | `''` | Toast heading |
| `message` | `string` | `''` | Main notification text |
| `variant` | `string` | `'info'` | `'info'`, `'success'`, `'warning'`, `'danger'` |
| `duration`| `number` | `3000` | Auto-dismiss duration in milliseconds |

**Usage Example:**
```html
<bv-toast
  :visible="toastVisible"
  variant="success"
  title="Saved!"
  message="Your settings have been updated successfully."
  @close="toastVisible = false"
></bv-toast>
```

---

### 6. `<bv-datagrid>` (Data Table with Scoped Slots)
A reactive table supporting column definitions, sorting, pagination, and **Scoped Slots** for custom cell rendering.

| Prop | Type | Default | Description |
|---|---|---|---|
| `columns` | `array` | `[]` | Array of column definitions: `{ key: 'id', label: 'ID', sortable: true }` |
| `items` | `array` | `[]` | Array of row data objects |
| `pageSize`| `number` | `10` | Rows to display per page |

**Scoped Slot Customization:**
You can override any cell's presentation using scoped slots:
```html
<bv-datagrid :columns="cols" :items="users">
  <!-- Customize the 'status' column using a scoped slot -->
  <template b-slot:cell(status)="slotProps">
    <span class="badge" :class="slotProps.row.active ? 'badge-success' : 'badge-danger'">
      {{ slotProps.row.active ? 'Active' : 'Suspended' }}
    </span>
  </template>

  <!-- Add an actions column -->
  <template b-slot:actions="slotProps">
    <bv-btn size="sm" variant="ghost" @click="editUser(slotProps.row)">Edit</bv-btn>
  </template>
</bv-datagrid>
```

---

## 🚀 Adding BlaiseUI to a New Project

To use BlaiseUI in any new BlaiseVue application:
1. Copy the `packages/blaise-ui` folder into your project's `lib/` directory:
   ```bash
   cp -r packages/blaise-ui my-project/lib/blaise-ui
   ```
2. Run your application:
   ```bash
   bv serve
   ```
3. Use `<bv-btn>`, `<bv-card>`, `<bv-input>`, `<bv-modal>`, `<bv-toast>`, and `<bv-datagrid>` anywhere in your `.bv` templates immediately!
