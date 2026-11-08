# 📲 Module 20: Mobile UI Components & Touch Gestures
**Design thumb-friendly mobile layouts with adaptive iOS Cupertino and Android Material Design themes.**

A common pitfall of hybrid mobile applications is looking like a desktop web page crammed into a phone screen: tiny text, unclickable buttons, content hidden under the device notch, and awkward scroll physics.

BlaiseVue solves this with **`blaise-ui-mobile`**: an official mobile UI library with adaptive components, native-feeling touch gestures, notch-aware safe areas, and strongly-typed Pascal controllers!

---

## 📦 1. Installing `@blaise-ui-mobile`

To add the official mobile component kit to your project, use the BlaiseVue package manager:

```bash
bv lib install mobile

# Alias:
bv lib install blaise-ui-mobile
```

This installs:
1. `lib/blaise-ui-mobile/blaise-ui-mobile.css`: Mobile reset stylesheets and CSS safe-area variables.
2. Mobile Single File Components (`<bv-ion-app>`, `<bv-ion-card>`, etc.).
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

## 📱 4. Building a Complete Mobile Application Shell

Here is a full mobile view featuring sticky headers, cards, grouped lists, and bottom tab navigation:

```html
<template>
  <bv-ion-app>
    <!-- Top Action Header (Notch-safe) -->
    <bv-ion-header>
      <bv-ion-toolbar color="primary">
        <bv-ion-title>📦 Inventory Mobile</bv-ion-title>
      </bv-ion-toolbar>
    </bv-ion-header>

    <!-- Scrollable Mobile Content Container -->
    <bv-ion-content :padding="true">
      
      <!-- Summary Card -->
      <bv-ion-card title="Daily Operations" subtitle="Warehouse Section 4">
        <p>34 orders ready for picking. 3 express shipments pending.</p>
        <bv-ion-button 
          label="Process Next Batch" 
          color="success" 
          expand="block" 
          @click="handleProcess">
        </bv-ion-button>
      </bv-ion-card>

      <!-- Inset Grouped List (iOS Settings / Modern Android Style) -->
      <h3>Pending Dispatches</h3>
      <bv-ion-list :inset="true">
        <bv-ion-item 
          b-for="item in dispatchList"
          :title="item.title" 
          :subtitle="item.sku" 
          :detail="true"
          @click="inspectItem(item)">
          <span slot="end" class="badge">{{ item.qty }} pcs</span>
        </bv-ion-item>
      </bv-ion-list>

    </bv-ion-content>

    <!-- Fixed Bottom Tab Bar -->
    <bv-ion-tab-bar>
      <bv-ion-tab-button label="Orders" icon="📦" :active="activeTab = 'orders'" @click="activeTab = 'orders'"></bv-ion-tab-button>
      <bv-ion-tab-button label="Scanner" icon="📷" :active="activeTab = 'scan'" @click="activeTab = 'scan'"></bv-ion-tab-button>
      <bv-ion-tab-button label="Profile" icon="👤" :active="activeTab = 'profile'" @click="activeTab = 'profile'"></bv-ion-tab-button>
    </bv-ion-tab-bar>
  </bv-ion-app>
</template>

<script>
uses BlaiseIonic;

data:
  activeTab: 'orders';
  dispatchList: [
    (title: 'Wireless Barcode Scanner', sku: 'SKU-8821', qty: 12),
    (title: 'Thermal Receipt Rolls', sku: 'SKU-1049', qty: 50),
    (title: 'Heavy Duty Shipping Tape', sku: 'SKU-4412', qty: 24)
  ];

methods:
  procedure handleProcess;
  begin
    // Present a native mobile confirmation dialog
    TIonicAlert.Confirm('Confirm Batch', 'Are you ready to lock and dispatch this batch?',
      procedure
      begin
        TIonicLoading.Present('Dispatching orders...');
        // Simulate async operation
        asm
          setTimeout(() => {
            pas.BlaiseIonic.TIonicLoading.Dismiss();
            pas.BlaiseIonic.TIonicToast.Show('Batch dispatched successfully!', 2000, 'bottom', 'success');
          }, 1200);
        end;
      end,
      procedure
      begin
        // Cancelled
      end
    );
  end;

  procedure inspectItem(Item: JSValue);
  begin
    TIonicToast.Show('Selected: ' + String(TJSObject(Item)['title']), 1500, 'bottom', 'primary');
  end;
</script>
```

---

## ⚡ 5. Strongly Typed Pascal Mobile Controllers (`BlaiseIonic.pas`)

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
2. Create a mobile view using `<bv-ion-app>`, `<bv-ion-header>`, and `<bv-ion-content>`.
3. Add a `<bv-ion-list :inset="true">` with five contact names.
4. On item click, display a `TIonicToast` showing the contact's name.
5. Add a delete action that prompts with `TIonicAlert.Confirm` before removing the item from the list.

---

## 📖 Deeper Technical Reference

- **[Mobile-First Ecosystem (blaise-ui-mobile & BlaiseIonic)](../Documentation/38-mobile-ionic.md)**: Props, events, and styling options for all mobile components.
- **[Package Components Catalog](../Documentation/41-package-components-catalog.md#part-iii-blaiseui-mobile-suite-packagesblaise-ui-mobile)**: Detailed technical specifications of the mobile suite.

---

[⬅️ Module 19: Mobile Architecture & Capacitor Setup](19-mobile-architecture.md) | [🏠 Course Index](README.md) | [Module 21: Emulation, Live Debugging & Device Build ➡️](21-mobile-build.md)
