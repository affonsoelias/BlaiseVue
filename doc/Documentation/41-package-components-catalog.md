# 41. Package Components Catalog & Developer Manual

> **BlaiseVue Official Component Reference**  
> Complete technical manual, props specification, events, slots, and idiomatic 100% Object Pascal (Zero-ASM) examples for all official ecosystem packages.

---

## 📚 Ecosystem Overview & Package Architecture

BlaiseVue provides a modular, package-based component architecture located in `/packages` (and loaded dynamically into `lib/` in application projects):

```text
packages/
├── blaise-ui/          # Core Web & Desktop UI (29 components)
├── blaise-charts/      # Reactive Chart.js Suite & Typed Pascal API (9 components)
├── blaise-ui-mobile/   # Mobile-First Ionic Design Language (13 components)
└── blaise-themes/      # 9 Bootswatch Themes & Reactive Switchers (2 components)
```

All package components follow strict design and typing guidelines:
1. **Universal Auto-Loading**: Any component in `lib/` starting with `bv-*` or `bv-ion-*` is auto-registered globally.
2. **Pure Object Pascal DX**: All component interactions, event handlers, and data bindings run in 100% pure Object Pascal without inline `asm ... end;` blocks.
3. **Reactive Two-Way Binding**: Form controls support `b-model` and validation directives (`b-validate`).
4. **Theme Awareness**: Built-in support for dark mode, custom palettes, and Bootswatch theme variables.

---

# 📦 PART I: BlaiseUI Component Kit (`packages/blaise-ui`)

The core UI kit provides 29 production-ready components inspired by modern enterprise design systems.

---

## 1. Responsive Grid & Layout

### 1.1 `<bv-container>`
Responsive centered layout container.

- **Props**:
  | Prop | Type | Default | Description |
  |---|---|---|---|
  | `fluid` | `boolean` | `false` | When `true`, container spans 100% width across all viewport sizes. |

- **Slots**:
  | Slot | Description |
  |---|---|
  | `default` | Inner grid content (typically `<bv-row>`). |

- **Pascal Example**:
  ```html
  <template>
    <bv-container :fluid="isFluid">
      <p>Content aligned with responsive breakpoints.</p>
    </bv-container>
  </template>

  <script>
    data:
      isFluid: boolean = false;
  </script>
  ```

---

### 1.2 `<bv-row>`
Flexbox grid row container for column alignment and gutter spacing.

- **Props**:
  | Prop | Type | Default | Description |
  |---|---|---|---|
  | `gutter` | `string` | `'md'` | Gutter spacing between columns: `'none'`, `'sm'`, `'md'`, `'lg'`. |
  | `align` | `string` | `''` | Vertical alignment: `'start'`, `'center'`, `'end'`, `'baseline'`, `'stretch'`. |
  | `justify` | `string` | `''` | Horizontal alignment: `'start'`, `'center'`, `'end'`, `'between'`, `'around'`. |
  | `noGutters` | `boolean` | `false` | Removes all gutters when `true`. |

- **Slots**:
  | Slot | Description |
  |---|---|
  | `default` | Grid column items (`<bv-col>`). |

---

### 1.3 `<bv-col>`
Adaptive 12-column grid item with responsive breakpoint controls.

- **Props**:
  | Prop | Type | Default | Description |
  |---|---|---|---|
  | `cols` | `string` | `'12'` | Default column span (1 to 12) for mobile-first viewport (<576px). |
  | `sm` | `string` | `''` | Column span for small viewports (≥576px). |
  | `md` | `string` | `''` | Column span for medium viewports (≥768px). |
  | `lg` | `string` | `''` | Column span for large viewports (≥992px). |
  | `xl` | `string` | `''` | Column span for extra large viewports (≥1200px). |
  | `offset` | `string` | `''` | Left column offset span (1 to 11). |

- **Complete Grid Layout Example**:
  ```html
  <template>
    <bv-container>
      <bv-row gutter="md" align="center">
        <bv-col cols="12" md="4">
          <bv-card title="Sidebar">Navigation items...</bv-card>
        </bv-col>
        <bv-col cols="12" md="8">
          <bv-card title="Dashboard">Main analytic widgets...</bv-card>
        </bv-col>
      </bv-row>
    </bv-container>
  </template>
  ```

---

## 2. Actions, Cards & Badges

### 2.1 `<bv-btn>`
Interactive button with semantic styling, size variants, and disabled state handling.

- **Props**:
  | Prop | Type | Default | Description |
  |---|---|---|---|
  | `label` | `string` | `''` | Button text fallback if default slot is omitted. |
  | `variant` | `string` | `'primary'` | Theme variant: `'primary'`, `'secondary'`, `'success'`, `'danger'`, `'warning'`, `'info'`, `'dark'`, `'light'`. |
  | `size` | `string` | `'md'` | Size variant: `'sm'`, `'md'`, `'lg'`. |
  | `outline` | `boolean` | `false` | Renders outline button styling (`bui-btn-outline-*`). |
  | `disabled` | `boolean` | `false` | Disables button interactions and click events. |

- **Events**:
  | Event | Payload | Description |
  |---|---|---|
  | `@click` | `TJSEvent` | Dispatched when button is clicked (suppressed when `disabled=true`). |

- **Slots**:
  | Slot | Description |
  |---|---|
  | `default` | Custom button content (icons, text). |

- **Pascal Example**:
  ```html
  <template>
    <div class="btn-toolbar">
      <bv-btn variant="primary" size="md" @click="handleSave">💾 Save</bv-btn>
      <bv-btn variant="secondary" :outline="true" @click="handleCancel">Cancel</bv-btn>
      <bv-btn variant="danger" size="sm" :disabled="isBusy" @click="handleDelete">🗑️ Delete</bv-btn>
    </div>
  </template>

  <script>
    data:
      isBusy: boolean = false;

    methods:
      procedure handleSave;
      begin
        ShowToast('Record saved successfully!', 'success');
      end;

      procedure handleCancel;
      begin
        NavigateTo('#/');
      end;

      procedure handleDelete;
      begin
        if Confirm('Are you sure?') then
          ShowToast('Record deleted.', 'danger');
      end;
  </script>
  ```

---

### 2.2 `<bv-card>`
Structured surface container with header, body, and footer sections.

- **Props**:
  | Prop | Type | Default | Description |
  |---|---|---|---|
  | `title` | `string` | `''` | Header title string. If empty and no `header` slot, header is hidden. |
  | `hasFooter` | `boolean` | `false` | When `true`, displays the card footer container. |

- **Slots**:
  | Slot | Description |
  |---|---|
  | `header` | Custom header content (overrides `title` string). |
  | `default` | Main card body. |
  | `footer` | Custom footer actions/buttons (visible when `hasFooter="true"`). |

---

### 2.3 `<bv-badge>`
Colored status chip, counter badge, and pill marker.

- **Props**:
  | Prop | Type | Default | Description |
  |---|---|---|---|
  | `variant` | `string` | `'primary'` | Semantic variant: `'primary'`, `'secondary'`, `'success'`, `'danger'`, `'warning'`, `'info'`. |
  | `pill` | `boolean` | `false` | When `true`, applies rounded capsule styling (`bui-badge-pill`). |

- **Slots**:
  | Slot | Description |
  |---|---|
  | `default` | Badge text or numeric count. |

---

## 3. Feedback, Modals & Notifications

### 3.1 `<bv-modal>`
Interactive modal dialog rendered into `document.body` via `<teleport>` with backdrop dismiss and keyboard handling.

- **Props**:
  | Prop | Type | Default | Description |
  |---|---|---|---|
  | `title` | `string` | `'Modal'` | Modal header title. |
  | `okLabel` | `string` | `'Process'` | Primary action button label. |
  | `cancelLabel` | `string` | `'Close'` | Secondary cancel button label. |
  | `show` | `boolean` | `false` | Initial visibility state. |

- **Events**:
  | Event | Payload | Description |
  |---|---|---|
  | `@ok` | `void` | Dispatched when primary confirm button is clicked. |
  | `@cancel` | `void` | Dispatched when cancel button or backdrop is clicked. |
  | `@close` | `void` | Dispatched when header close button (`✕`) is clicked. |

- **Methods (Callable via `$refs` / `TriggerRef`)**:
  - `open`: Opens modal dialog.
  - `close`: Closes modal dialog.
  - `confirm`: Triggers primary OK action.

- **Pascal Example**:
  ```html
  <template>
    <div>
      <bv-btn variant="primary" @click="openDialog">Open Confirmation</bv-btn>

      <bv-modal 
        b-ref="confirmModal" 
        title="Authorize Payment" 
        okLabel="Approve ($150.00)" 
        cancelLabel="Cancel"
        @ok="onApproved"
        @cancel="onDismissed"
      >
        <p>Do you wish to authorize this transaction?</p>
      </bv-modal>
    </div>
  </template>

  <script>
    methods:
      procedure openDialog;
      begin
        TriggerRef(this, 'confirmModal', 'open');
      end;

      procedure onApproved;
      begin
        ShowToast('Payment approved!', 'success');
        TriggerRef(this, 'confirmModal', 'close');
      end;

      procedure onDismissed;
      begin
        ShowToast('Action cancelled.', 'secondary');
      end;
  </script>
  ```

---

### 3.2 `<bv-toast>`
Animated floating notification toast rendered directly to `document.body` via `<teleport>` with auto-dismiss timer.

- **Props**:
  | Prop | Type | Default | Description |
  |---|---|---|---|
  | `title` | `string` | `''` | Optional bold title displayed above the toast message. |
  | `message` | `string` | `''` | Notification message fallback if slot is empty. |
  | `duration` | `integer` | `3000` | Auto-dismiss duration in milliseconds. |
  | `variant` | `string` | `'success'` | Semantic variant: `'success'`, `'danger'`, `'warning'`, `'info'`, `'primary'`. |

- **Events**:
  | Event | Payload | Description |
  |---|---|---|
  | `@dismiss` | `void` | Dispatched when toast is dismissed or timer expires. |

- **Methods**:
  - `show`: Opens toast and begins auto-dismiss countdown.
  - `dismiss`: Immediately closes toast.

- **Pascal Example**:
  ```html
  <template>
    <div>
      <bv-btn @click="triggerNotification">Send Alert</bv-btn>
      <bv-toast b-ref="userToast" title="System Event" variant="info" :duration="4000">
        Operation completed successfully!
      </bv-toast>
    </div>
  </template>

  <script>
    methods:
      procedure triggerNotification;
      begin
        TriggerRef(this, 'userToast', 'show');
      end;
  </script>
  ```

---

### 3.3 `<bv-alert>`
In-page contextual feedback banner with dismissible button.

- **Props**:
  | Prop | Type | Default | Description |
  |---|---|---|---|
  | `variant` | `string` | `'primary'` | Semantic variant: `'primary'`, `'success'`, `'danger'`, `'warning'`, `'info'`. |
  | `dismissible` | `boolean` | `false` | When `true`, renders close button (`×`) to hide the banner. |
  | `show` | `boolean` | `true` | Initial visibility state. |

- **Events**:
  | Event | Payload | Description |
  |---|---|---|
  | `@close` | `void` | Dispatched when user clicks the dismiss button. |

---

### 3.4 `<bv-progress>` & `<bv-spinner>`
Reactive indicators for loading states and task completion percentages.

- **`<bv-progress>` Props**:
  | Prop | Type | Default | Description |
  |---|---|---|---|
  | `value` | `integer` | `0` | Progress percentage (0 to 100). |
  | `variant` | `string` | `'primary'` | Color variant (`primary`, `success`, `warning`, `danger`, `info`). |
  | `label` | `boolean` | `true` | Shows percentage text inside the progress bar. |

- **`<bv-spinner>` Props**:
  | Prop | Type | Default | Description |
  |---|---|---|---|
  | `variant` | `string` | `'primary'` | Color variant. |
  | `small` | `boolean` | `false` | When `true`, renders compact 16px spinner (`bui-spinner-sm`). |

---

## 4. Navigation & Collapsible Panels

### 4.1 `<bv-navbar>` & `<bv-nav-item>`
Top navigation header with branding and link items.

- **`<bv-navbar>` Props**:
  | Prop | Type | Default | Description |
  |---|---|---|---|
  | `brand` | `string` | `'BlaiseVue UI'` | Brand logo or title text linking to `#/'`. |

- **`<bv-nav-item>` Props**:
  | Prop | Type | Default | Description |
  |---|---|---|---|
  | `href` | `string` | `''` | Navigation target hash (e.g. `'#/products'`). |
  | `label` | `string` | `''` | Link label fallback. |
  | `active` | `boolean` | `false` | Marks link with active highlight. |

- **Events**:
  | Event | Payload | Description |
  |---|---|---|
  | `@click` | `TJSEvent` | Dispatched when link is clicked. Automatically prevents hash resets on empty links. |

---

### 4.2 `<bv-drawer>`
Slide-out off-canvas navigation drawer with backdrop overlay.

- **Props**:
  | Prop | Type | Default | Description |
  |---|---|---|---|
  | `title` | `string` | `'Menu'` | Header title of the drawer. |
  | `width` | `string` | `'280px'` | Drawer panel width. |
  | `position` | `string` | `'left'` | Slide direction: `'left'` or `'right'`. |
  | `overlay` | `boolean` | `true` | Renders semi-transparent backdrop behind the drawer. |
  | `hasFooter` | `boolean` | `false` | Enables footer slot container. |
  | `show` | `boolean` | `false` | Initial open state. |

- **Methods**:
  - `open`: Slides drawer into view.
  - `close`: Slides drawer out of view.
  - `toggle`: Toggles between open and closed state.

---

### 4.3 `<bv-tabs>` & `<bv-tab>`
Tabbed navigation shell powered by BlaiseVue's reactive Provide/Inject architecture.

- **`<bv-tab>` Props**:
  | Prop | Type | Default | Description |
  |---|---|---|---|
  | `id` | `string` | `''` | Unique identifier of the tab. |
  | `title` | `string` | `'Tab'` | Title text displayed on the tab navigation header. |
  | `active` | `boolean` | `false` | Sets initial active tab. |

- **Pascal Example**:
  ```html
  <template>
    <bv-tabs>
      <bv-tab id="general" title="General Settings" :active="true">
        <p>Configure general system preferences.</p>
      </bv-tab>
      <bv-tab id="security" title="Security & Auth">
        <p>Manage passwords and two-factor authentication.</p>
      </bv-tab>
      <bv-tab id="billing" title="Billing & Plans">
        <p>View subscription tiers and invoices.</p>
      </bv-tab>
    </bv-tabs>
  </template>
  ```

---

### 4.4 `<bv-accordion>`
Collapsible accordion panels with single-item active expansion.

- **Props**:
  | Prop | Type | Default | Description |
  |---|---|---|---|
  | `items` | `JSValue` | `nil` | Array of records: `[{ id: '1', title: 'Q1', content: 'Ans 1' }, ...]`. |
  | `initialActiveId` | `string` | `''` | ID of the item initially expanded. |

---

### 4.5 `<bv-breadcrumb>` & `<bv-breadcrumb-item>`
Hierarchical trail navigation showing user navigation depth.

- **`<bv-breadcrumb-item>` Props**:
  | Prop | Type | Default | Description |
  |---|---|---|---|
  | `href` | `string` | `'#'` | Route target hash. |
  | `active` | `boolean` | `false` | When `true`, renders as current plain-text page marker. |

---

### 4.6 `<bv-bottom-nav>` & `<bv-bottom-nav-item>`
Mobile-first bottom navigation bar with automatic route tracking.

- **`<bv-bottom-nav-item>` Props**:
  | Prop | Type | Default | Description |
  |---|---|---|---|
  | `href` | `string` | `'#/'` | Target hash link. |
  | `label` | `string` | `'Item'` | Navigation button label. |
  | `icon` | `string` | `''` | Icon symbol, emoji, or vector glyph. |
  | `active` | `boolean` | `false` | Active state (auto-synced with `window.location.hash`). |

---

## 5. Form Controls & Inputs

### 5.1 `<bv-input>`
Reactive single-line text input with label and two-way data binding.

- **Props**:
  | Prop | Type | Default | Description |
  |---|---|---|---|
  | `label` | `string` | `''` | Field label displayed above input. |
  | `placeholder` | `string` | `''` | Input placeholder text. |
  | `type` | `string` | `'text'` | HTML input type: `'text'`, `'email'`, `'password'`, `'number'`, `'tel'`. |
  | `value` | `string` | `''` | Bound value (use via `b-model`). |
  | `readonly` | `boolean` | `false` | Disables text entry. |

- **Events**:
  | Event | Payload | Description |
  |---|---|---|
  | `@input` | `string` | Emitted whenever the user changes the text value. |

---

### 5.2 `<bv-input-group>`
Text input adorned with prepended or appended labels/icons.

- **Props**:
  | Prop | Type | Default | Description |
  |---|---|---|---|
  | `label` | `string` | `''` | Field label. |
  | `prepend` | `string` | `''` | Text or currency symbol prepended to input (e.g. `'$'`). |
  | `append` | `string` | `''` | Text or unit appended to input (e.g. `'.00'` or `'kg'`). |
  | `placeholder` | `string` | `''` | Input placeholder text. |
  | `value` | `string` | `''` | Input value bound via `b-model`. |

---

### 5.3 `<bv-form-select>`
Reactive selection dropdown bound to array options.

- **Props**:
  | Prop | Type | Default | Description |
  |---|---|---|---|
  | `label` | `string` | `''` | Field label. |
  | `value` | `string` | `''` | Selected option value. |
  | `options` | `JSValue` | `nil` | Array of items: `[{ value: '1', text: 'Option 1' }, ...]`. |

- **Events**:
  | Event | Payload | Description |
  |---|---|---|
  | `@input` | `string` | Emitted on selection. |
  | `@change` | `string` | Emitted on change. |

---

## 6. Complex Data & Grids

### 6.1 `<bv-datagrid>`
Enterprise data table with column headers, sorting, instant keyword filtering, pagination, and scoped slot cell customization.

- **Props / Reactive Data**:
  | Property | Type | Default | Description |
  |---|---|---|---|
  | `items` | `JSValue` | `[]` | Array of row objects to display in the table. |
  | `columns` | `JSValue` | `[]` | Array of column definitions: `[{ key: 'name', label: 'Name' }, ...]`. |
  | `pageSize` | `integer` | `5` | Number of rows displayed per page. |

- **Slots**:
  | Slot | Scope Props | Description |
  |---|---|---|
  | `cell` | `row`, `column`, `value` | Custom scoped slot to format individual cell contents. |

- **Complete DataGrid Pascal Example**:
  ```html
  <template>
    <div class="user-grid-page">
      <bv-datagrid :items="users" :columns="columns" :pageSize="5">
        <!-- Scoped Slot: Custom Status Badge Cell -->
        <template b-slot:cell="scope">
          <span v-if="scope.column.key === 'status'">
            <bv-badge :variant="scope.value === 'Active' ? 'success' : 'danger'" :pill="true">
              {{ scope.value }}
            </bv-badge>
          </span>
          <span v-else>
            {{ scope.value }}
          </span>
        </template>
      </bv-datagrid>
    </div>
  </template>

  <script>
    data:
      users: JSValue = [];
      columns: JSValue = [];

    mounted:
      begin
        this.columns := [
          NewObject('key', 'id', 'label', 'ID'),
          NewObject('key', 'name', 'label', 'Full Name'),
          NewObject('key', 'role', 'label', 'Role'),
          NewObject('key', 'status', 'label', 'Account Status')
        ];

        this.users := [
          NewObject('id', 1, 'name', 'Blaise Pascal', 'role', 'Admin', 'status', 'Active'),
          NewObject('id', 2, 'name', 'Ada Lovelace', 'role', 'Engineer', 'status', 'Active'),
          NewObject('id', 3, 'name', 'Niklaus Wirth', 'role', 'Architect', 'status', 'Inactive')
        ];
      end;
  </script>
  ```

---

### 6.2 `<bv-pagination>`
Numbered pagination navigator emitting page changes.

- **Props**:
  | Prop | Type | Default | Description |
  |---|---|---|---|
  | `value` | `integer` | `1` | Current active page index (1-based). |
  | `total` | `integer` | `10` | Total number of available pages. |

- **Events**:
  | Event | Payload | Description |
  |---|---|---|
  | `@change` | `integer` | Emitted with new page index when clicked. |
  | `@input` | `integer` | Emitted for two-way binding. |

---

### 6.3 `<bv-icon>`
Vector SVG icon renderer supporting embedded SVGs and 2,000+ Bootstrap Icons.

- **Props**:
  | Prop | Type | Default | Description |
  |---|---|---|---|
  | `name` | `string` | `'check-circle'` | Icon identifier (e.g. `'check-circle'`, `'warning'`, `'gear-fill'`, `'heart-fill'`, or any Bootstrap icon name like `'star-fill'`). |
  | `size` | `string` | `'16'` | Dimension in pixels. |
  | `color` | `string` | `''` | CSS color (e.g. `'#42b883'`, `'red'`). |

---

# 📊 PART II: BlaiseCharts Suite (`packages/blaise-charts`)

High-performance data visualization powered by Chart.js and strongly typed Pascal structures in `BlaiseCharts.pas`.

## 1. Chart Components

| Component Tag | Chart Type | Key Props |
|---|---|---|
| `<bv-chart>` | Universal Chart | `:type` (`'bar'\|'line'\|'pie'\|'doughnut'\|'radar'\|'polarArea'\|'scatter'\|'bubble'`), `:data`, `:options`, `height`, `title` |
| `<bv-bar-chart>` | Bar / Column Chart | `:data`, `:options`, `height`, `title`, `description` |
| `<bv-line-chart>` | Line / Area Chart | `:data`, `:options`, `height`, `title`, `description` |
| `<bv-pie-chart>` | Pie Chart | `:data`, `:options`, `height`, `title`, `description` |
| `<bv-doughnut-chart>` | Ring / Doughnut Chart | `:data`, `:options`, `height`, `title`, `description` |
| `<bv-radar-chart>` | Spider / Radar Chart | `:data`, `:options`, `height`, `title`, `description` |
| `<bv-polar-area-chart>` | Polar Area Chart | `:data`, `:options`, `height`, `title`, `description` |
| `<bv-scatter-chart>` | XY Scatter Plot | `:data`, `:options`, `height`, `title`, `description` |
| `<bv-bubble-chart>` | 3D Bubble Chart (X, Y, R) | `:data`, `:options`, `height`, `title`, `description` |

- **Events**:
  | Event | Payload | Description |
  |---|---|---|
  | `@chart-click` | `(event, activeElements)` | Dispatched when user clicks a data point or bar. |

## 2. Strongly Typed Pascal API (`BlaiseCharts.pas`)

```pascal
uses BlaiseCharts;

var
  chartData: TBVChartData;
  ds: TBVChartDataset;
begin
  // Initialize dataset
  chartData := TBVChartData.Create(['Q1', 'Q2', 'Q3', 'Q4']);
  
  ds := TBVChartDataset.Create('Revenue ($k)');
  ds.SetData([120, 180, 240, 310]);
  ds.SetBackgroundColor(TBVChartPalette.Emerald);
  
  chartData.AddDataset(ds);
  this.salesData := chartData.ToJS;
end;
```

---

# 📱 PART III: BlaiseUI Mobile Suite (`packages/blaise-ui-mobile`)

Mobile-first component kit matching **Ionic Framework** aesthetics with automatic iOS Cupertino and Android Material Design adaptation.

## 1. Mobile Component Reference

| Component Tag | Description | Props & Features |
|---|---|---|
| `<bv-ion-app>` | Root mobile container | `mode`: `'ios'` \| `'md'`. Configures safe areas and momentum scroll bounds. |
| `<bv-ion-header>` | Sticky top header | Respects `safe-area-inset-top` (notches). Translucent blur on iOS. |
| `<bv-ion-toolbar>` | Action bar | Slots `start`, `default`, `end`. Colors: `primary`, `secondary`, `dark`. |
| `<bv-ion-title>` | Page title | Centered on iOS, left-aligned on Android. |
| `<bv-ion-content>` | Scrollable body | `:padding="true"` applies standard 16px touch margins. |
| `<bv-ion-card>` | Mobile card | `title`, `subtitle`. Rounded corners and elevation shadows. |
| `<bv-ion-button>` | Touch button | `label`, `color` (`primary`, `success`, `danger`), `fill` (`solid`, `outline`, `clear`), `expand` (`block`, `full`). |
| `<bv-ion-badge>` | Badge pill | `value`, `color` (`primary`, `success`, `warning`, `danger`). |
| `<bv-ion-list>` | Mobile list container | `:inset="true"` creates rounded inset grouped lists (iOS Settings style). |
| `<bv-ion-item>` | List row item | `title`, `subtitle`, `:detail="true"` (renders `›` chevron). Slots: `start`, `default`, `end`. |
| `<bv-ion-tabs>` | Tabbed mobile shell | Coordinates view content and bottom navigation bar. |
| `<bv-ion-tab-bar>` | Bottom tab bar | Adheres to `safe-area-inset-bottom`. |
| `<bv-ion-tab-button>`| Tab button | `label`, `tab`, `:active="true"`. Emits `@tab-click`. |

## 2. Strongly Typed Pascal Controller (`BlaiseIonic.pas`)

End-user views call high-level Pascal helpers from `BVPascalDX.pas`:

```pascal
// Native Toast
IonicToast('Profile updated!', 2000, 'bottom', 'success');

// Native Alert Dialog
IonicAlert('Update Available', 'A new version is ready to install.', 'OK');

// Native Confirmation Dialog
IonicConfirm(this, 'Confirm Delete', 'Delete this record permanently?', 'onDeleteConfirmed');

// Toggle Platform Design Mode at Runtime
IonicSetMode('ios'); // or 'md'
```

---

# 🎨 PART IV: BlaiseThemes (`packages/blaise-themes`)

Bootswatch theme management and dark mode switching engine.

## 1. Components

- **`<bv-theme-toggle>`**:
  Quick toggle button between Light and Dark mode.
  - Automatically updates root `data-bs-theme="dark|light"`.
  - Persists preference in `localStorage`.

- **`<bv-theme-select>`**:
  Dropdown selector for the 9 integrated Bootswatch themes:
  - `flatly` (Clean Flat Light)
  - `cosmo` (Modern Metro Light)
  - `lux` (Elegant Minimalist Light)
  - `zephyr` (Airy Modern Light)
  - `darkly` (Sleek Dark)
  - `cyborg` (Jet Black Dark)
  - `solar` (Subtle Forest Dark)
  - `vapor` (Cyberpunk Neon Dark)
  - `pulse` (Vibrant Purple Light)

## 2. Pascal Controller API (`$theme`)

In any component:
```pascal
// Set specific theme (Pure Pascal)
ThemeSet('darkly');

// Programmatic toggle (Pure Pascal)
ThemeToggle;

// Alternative via template or JS:
// @click="$theme.toggle()"

// Check dark state
if Boolean(this['$theme']['isDark']) then
  ShowToast('Dark Mode Engaged 🌙', 'info');
```

---

🛡️ **"BlaiseVue: Unified Object Pascal Component Architecture for Enterprise Scale."** ✨🏆🚀
