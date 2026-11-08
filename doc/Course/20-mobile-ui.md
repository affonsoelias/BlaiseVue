# 📲 Module 20: Mobile UI Components & Touch Gestures
**Design thumb-friendly mobile layouts with adaptive iOS Cupertino and Android Material Design themes.**

A common pitfall of hybrid mobile applications is looking like a desktop web page crammed into a phone screen: tiny text, unclickable buttons, content hidden under the device notch, and awkward scroll physics.

BlaiseVue solves this with **`blaise-ui-mobile`**: an official mobile UI library with adaptive components, native-feeling touch gestures, notch-aware safe areas, mobile form controls, floating action buttons, and strongly-typed Pascal controllers!

---

## 📦 1. Installing `@blaise-ui-mobile`

To add the official mobile component kit to your project, use the BlaiseVue package manager:

```bash
bv lib install mobile

# Alias:
bv lib install blaise-ui-mobile
```

This installs:
1. `lib/blaise-ui-mobile/blaise-ui-mobile.css`: Mobile reset stylesheets, adaptive theme variables, and CSS safe-area definitions.
2. Mobile Single File Components (`<bv-ion-app>`, `<bv-ion-input>`, `<bv-ion-toggle>`, `<bv-ion-refresher>`, `<bv-ion-fab>`, etc.).
3. `lib/blaise-ui-mobile/BlaiseIonic.pas`: Strongly-typed Pascal controller classes for Toasts, Alerts, and Loading overlays.

---

## 🎨 2. Adaptive Design: Material Design vs. Cupertino

The mobile kit automatically inspects the user agent:
- On **Android / Chrome**: It applies **Material Design** typography (Roboto), subtle elevations, and left-aligned titles.
- On **iOS / Safari / iPhone**: It applies **Apple Cupertino** styling (SF Pro), translucent frosted-glass blur (`backdrop-filter`), and centered toolbar titles.

You can also force a specific mode globally:

```html
<bv-ion-app mode="ios">
  <!-- Forces Cupertino aesthetics across all devices -->
</bv-ion-app>
```

Or programmatically in Pascal:
```pascal
TIonicController.SetMode('md'); // or 'ios'
```

---

## 📐 3. Screen Notches & Safe Areas

Modern smartphones feature screen cutouts (camera notches, Dynamic Islands) and bottom home indicator swipe bars. 

`blaise-ui-mobile` automatically respects these physical screen boundaries using CSS `env(safe-area-inset-*)`:
- `<bv-ion-header>` applies top padding for the status bar and notch.
- `<bv-ion-tab-bar>` adds bottom clearance so buttons are never obstructed by the home bar.
- `<bv-ion-content>` ensures scrollable content flows smoothly without getting clipped.

---

## ✍️ 4. Native Mobile Form Controls

Mobile users interact primarily with their thumbs. Form fields must have large touch targets, clear labels, and frictionless clearing buttons:

### 1. Mobile Text Input (`<bv-ion-input>`)
Adaptive single-line input with floating, stacked, or fixed labels and a one-tap clear button:
```html
<bv-ion-input 
  label="Phone Number" 
  labelPlacement="floating" 
  type="tel" 
  placeholder="+1 (555) 019-2834" 
  :clearInput="true" 
  b-model="customerPhone"
  @ionChange="handlePhoneChange">
</bv-ion-input>
```

### 2. Native Toggle Switch (`<bv-ion-toggle>`)
Renders an authentic Apple iOS rounded toggle or Material Design switch:
```html
<bv-ion-toggle 
  label="Enable Push Notifications" 
  color="primary" 
  b-model="pushEnabled"
  @ionChange="handleToggleNotifications">
</bv-ion-toggle>
```

### 3. Checkbox (`<bv-ion-checkbox>`)
Thumb-sized checkbox with animated vector checkmark supporting single or array multi-selection:
```html
<bv-ion-checkbox 
  label="Sync Offline via SQLite" 
  color="success" 
  b-model="offlineSync">
</bv-ion-checkbox>
```

### 4. Dialog Select (`<bv-ion-select>`)
Presents a native mobile selection dialog (Alert or Action Sheet interface) instead of clunky browser dropdowns:
```html
<bv-ion-select 
  label="Fulfillment Warehouse" 
  placeholder="Choose hub..." 
  :options="warehouseList" 
  b-model="selectedHub"
  @ionChange="onWarehouseChanged">
</bv-ion-select>
```

---

## 🔄 5. Mobile Gestures & Live Search

### Pull-to-Refresh (`<bv-ion-refresher>`)
Place `<bv-ion-refresher>` at the top of your scrollable `<bv-ion-content>`. When the user pulls down, it displays a spinning progress indicator and emits `@ionRefresh`:

```html
<bv-ion-content :padding="true">
  <!-- Native Pull-to-Refresh Gesture -->
  <bv-ion-refresher 
    pullingText="Pull to sync..." 
    refreshingText="Fetching latest dispatches..." 
    @ionRefresh="handleSync">
  </bv-ion-refresher>

  <!-- Rest of list content -->
</bv-ion-content>
```

In Pascal, close the animation once your async operation finishes:
```pascal
procedure handleSync(ev: JSValue);
begin
  RefreshRemoteData(procedure
    begin
      // Call detail.complete() to close the pull animation
      TJSFunction(TJSObject(TJSObject(ev)['detail'])['complete']).call(nil);
      TIonicToast.Show('Sync Complete!', 1500, 'bottom', 'success');
    end);
end;
```

### Mobile Search Bar (`<bv-ion-search-bar>`)
Includes a magnifying glass icon, real-time debouncing, and an animated **Cancel** button:
```html
<bv-ion-search-bar 
  placeholder="Search inventory..." 
  showCancelButton="focus" 
  cancelButtonText="Cancel" 
  :debounce="300"
  b-model="searchQuery"
  @ionInput="filterInventory">
</bv-ion-search-bar>
```

---

## ⚡ 6. Floating Action Buttons (FAB) & Back Navigation

### Floating Action Button (`<bv-ion-fab>` & `<bv-ion-fab-button>`)
Elevated circular button fixed to screen corners for primary user actions (such as adding a record or scanning a barcode):

```html
<bv-ion-fab vertical="bottom" horizontal="end">
  <bv-ion-fab-button color="success" size="lg" icon="+" @click="openCreateModal">
  </bv-ion-fab-button>
</bv-ion-fab>
```

### Toolbar Back Button (`<bv-ion-back-button>`)
Placed inside `<bv-ion-toolbar>` to navigate backward in the app router history:
```html
<bv-ion-toolbar color="primary">
  <div slot="start">
    <bv-ion-back-button defaultHref="#/" text="Back"></bv-ion-back-button>
  </div>
  <bv-ion-title>Order Details</bv-ion-title>
</bv-ion-toolbar>
```

---

## 📱 7. Full Real-World Application View: Logistics Mobile Hub

Here is a complete, production-grade mobile view uniting all components:

```html
<template>
  <bv-ion-app>
    <!-- Top Action Header (Notch-safe) -->
    <bv-ion-header>
      <bv-ion-toolbar color="primary">
        <div slot="start">
          <bv-ion-back-button defaultHref="#/" text="Hub"></bv-ion-back-button>
        </div>
        <bv-ion-title>📦 Field Dispatch</bv-ion-title>
      </bv-ion-toolbar>

      <!-- Integrated Search Bar -->
      <bv-ion-search-bar 
        placeholder="Filter by SKU or description..." 
        showCancelButton="focus"
        b-model="filterTerm">
      </bv-ion-search-bar>
    </bv-ion-header>

    <!-- Scrollable Mobile Content Container -->
    <bv-ion-content :padding="true">
      <!-- Pull to Refresh -->
      <bv-ion-refresher 
        pullingText="Pull down to refresh..." 
        refreshingText="Updating orders..." 
        @ionRefresh="onRefreshData">
      </bv-ion-refresher>

      <!-- Settings Card -->
      <bv-ion-card title="Operational Settings" subtitle="Scanner Configuration">
        <bv-ion-toggle 
          label="Auto-Confirm Barcode Scan" 
          color="success" 
          b-model="autoConfirm">
        </bv-ion-toggle>
        <bv-ion-checkbox 
          label="Enable Haptic Feedback on Scan" 
          color="primary" 
          b-model="hapticsEnabled">
        </bv-ion-checkbox>
      </bv-ion-card>

      <!-- Dispatch Items List -->
      <h3>Pending Shipments ({{ filteredOrders.length }})</h3>
      <bv-ion-list :inset="true">
        <bv-ion-item 
          b-for="order in filteredOrders"
          :title="order.item" 
          :subtitle="order.code" 
          :detail="true"
          @click="selectOrder(order)">
          <span slot="end" class="badge">{{ order.quantity }} un</span>
        </bv-ion-item>
      </bv-ion-list>
    </bv-ion-content>

    <!-- Floating Action Button for Barcode Scanner -->
    <bv-ion-fab vertical="bottom" horizontal="end">
      <bv-ion-fab-button color="primary" icon="📷" @click="startScanner">
      </bv-ion-fab-button>
    </bv-ion-fab>

    <!-- Fixed Bottom Tab Bar -->
    <bv-ion-tab-bar>
      <bv-ion-tab-button label="Orders" icon="📦" :active="activeTab = 'orders'" @click="activeTab = 'orders'"></bv-ion-tab-button>
      <bv-ion-tab-button label="Routes" icon="🗺️" :active="activeTab = 'routes'" @click="activeTab = 'routes'"></bv-ion-tab-button>
      <bv-ion-tab-button label="Profile" icon="👤" :active="activeTab = 'profile'" @click="activeTab = 'profile'"></bv-ion-tab-button>
    </bv-ion-tab-bar>
  </bv-ion-app>
</template>

<script>
uses BlaiseIonic;

data:
  activeTab: 'orders';
  filterTerm: '';
  autoConfirm: true;
  hapticsEnabled: true;
  orders: [
    (code: 'ORD-9021', item: 'Industrial Hand Truck', quantity: 2),
    (code: 'ORD-9022', item: 'Pallet Wrap 500m', quantity: 18),
    (code: 'ORD-9023', item: 'Barcode Label Printer', quantity: 4)
  ];

computed:
  function filteredOrders: JSValue;
  begin
    asm
      var term = (this.filterTerm || '').toLowerCase();
      if (!term) return this.orders;
      return this.orders.filter(function(o) {
        return o.item.toLowerCase().indexOf(term) !== -1 || o.code.toLowerCase().indexOf(term) !== -1;
      });
    end;
  end;

methods:
  procedure onRefreshData(ev: JSValue);
  begin
    // Simulate remote server sync
    asm
      setTimeout(() => {
        if (ev && ev.detail && ev.detail.complete) ev.detail.complete();
        pas.BlaiseIonic.TIonicToast.Show('Dispatches up to date!', 2000, 'bottom', 'success');
      }, 1000);
    end;
  end;

  procedure selectOrder(order: JSValue);
  begin
    TIonicAlert.Confirm('Dispatch Order', 'Dispatch ' + String(TJSObject(order)['code']) + ' now?',
      procedure
      begin
        TIonicToast.Show('Order dispatched successfully!', 1800, 'bottom', 'success');
      end);
  end;

  procedure startScanner;
  begin
    TIonicToast.Show('Initializing camera scanner...', 1500, 'bottom', 'primary');
  end;
</script>
```

---

## ⚡ 8. Strongly Typed Pascal Mobile Controllers (`BlaiseIonic.pas`)

BlaiseVue lets you control mobile UI feedback natively in Pascal:

### Floating Toasts:
```pascal
// Show bottom floating toast auto-dismissed after 2 seconds
TIonicToast.Show('Record saved successfully!', 2000, 'bottom', 'success');

// Dismiss active toast
TIonicToast.Dismiss;
```

### Confirmation & Prompt Alerts:
```pascal
TIonicAlert.Confirm('Delete Customer', 'Are you sure you want to delete this customer?',
  procedure
  begin
    // User pressed Confirm
    DeleteCurrentRecord;
    TIonicToast.Show('Customer deleted', 1500, 'bottom', 'danger');
  end,
  procedure
  begin
    // User pressed Cancel
  end
);
```

### Loading Spinners:
```pascal
// Block UI with native loading spinner
TIonicLoading.Present('Syncing data with mORMot 2 server...');

// Dismiss when finished
TIonicLoading.Dismiss;
```

---

## 🏋️ Practical Exercise

1. Install `@blaise-ui-mobile` in your project with `bv lib install mobile`.
2. Create a mobile view using `<bv-ion-app>`, `<bv-ion-header>`, `<bv-ion-search-bar>`, and `<bv-ion-content>`.
3. Add a `<bv-ion-refresher>` that simulates an async data reload.
4. Add a `<bv-ion-card>` containing a `<bv-ion-toggle>` and `<bv-ion-checkbox>`.
5. Add a `<bv-ion-fab>` with `<bv-ion-fab-button icon="+">` that triggers a `TIonicToast`.
6. Run `bv mobile emulator` to preview the app in an Android or iOS device simulator!

---

## 📖 Deeper Technical Reference

- **[Mobile-First Ecosystem (blaise-ui-mobile & BlaiseIonic)](../Documentation/38-mobile-ionic.md)**: Exhaustive props, events, and styling options for all mobile components.
- **[Package Components Catalog](../Documentation/41-package-components-catalog.md#part-iii-blaiseui-mobile-suite-packagesblaise-ui-mobile)**: Detailed technical specifications of the mobile suite.
- **[Mobile Capacitor Integration](../Documentation/35-mobile-capacitor.md)**: Hardware device features (Camera, Haptics, SQLite) and native Android/iOS deployment.

---

[⬅️ Module 19: Mobile Architecture & Capacitor Setup](19-mobile-architecture.md) | [🏠 Course Index](README.md) | [Module 21: Emulation, Live Debugging & Device Build ➡️](21-mobile-build.md)
