# 38. Mobile-First Ecosystem (`blaise-ui-mobile` & `BlaiseIonic`)

BlaiseVue provides official mobile UI packaging and strongly typed Pascal controllers powered by the **Ionic Web Components** design language (`@ionic/core` aesthetics).

With `blaise-ui-mobile`, developers create responsive mobile apps with native touch feedback, smooth animations, safe area handling (notches and home bars), and automatic adaptive design switching between **iOS (Cupertino)** and **Android (Material Design)**.

> [!TIP]
> **Component Specs & API**: See [41. Package Components Catalog & Developer Manual](41-package-components-catalog.md#part-iii-blaiseui-mobile-suite-packagesblaise-ui-mobile) for the complete props, events, and slots reference for all 13 Ionic components.

---

## 📱 Architecture & Platform Adaptivity

```text
┌────────────────────────────────────────────────────────┐
│        BlaiseVue Universal Application (.bv)           │
│   Shared Pascal Business Logic + Reactive Templates    │
└──────────────────────────┬─────────────────────────────┘
                           │
         ┌─────────────────┼─────────────────┐
         ▼                 ▼                 ▼
   [ Android ]          [ iOS ]           [ Web ]
  Material Design      Cupertino       Responsive PWA
 (Elevations/Roboto)  (Blur/SF Pro)    (Auto-Detected)
```

The UI automatically detects the host device:
- **iOS Devices / Safari / macOS**: Uses Cupertino typography (`-apple-system`), translucent frosted headers (`backdrop-filter: blur(20px)`), centered toolbar titles, and rounded dialogs.
- **Android / Chrome / Linux / Windows**: Uses Material Design typography (`Roboto`), subtle elevation shadows, left-aligned titles, and ripple touches.

You can also force a specific design language declaratively or programmatically:

```html
<bv-ion-app mode="ios">
  <!-- Forced to Cupertino on any device -->
</bv-ion-app>
```

Or via Pascal / JavaScript:
```pascal
TIonicController.SetMode('ios'); // or 'md'
```

---

## 📦 Package Installation (`bv lib install mobile`)

To install the official mobile kit into any BlaiseVue project, run:

```bash
bv lib install mobile
# or:
bv lib install blaise-ui-mobile
```

This installs `lib/blaise-ui-mobile/` containing:
- `blaise-ui-mobile.css`: Production-ready styles, safe-area CSS variables, and transitions.
- Pascal Single File Components (`.bv`).
- Strongly typed Pascal controller unit `BlaiseIonic.pas`.

---

## 🧩 Mobile Components Reference

| Component Tag | Description | Props & Features |
|---|---|---|
| `<bv-ion-app>` | Root mobile container | `mode`: `'ios'` \| `'md'`. Configures viewport, safe areas, and mobile scroll bounds. |
| `<bv-ion-header>` | Sticky top header | Respects `safe-area-inset-top` (notches and status bars). Frosted glass blur on iOS. |
| `<bv-ion-toolbar>` | Mobile action bar | Slots `start`, `default`, `end`. Colors: `primary`, `secondary`, `dark`, etc. |
| `<bv-ion-title>` | App/Page title | Auto-centered on iOS, left-aligned with elevation on MD. |
| `<bv-ion-content>` | Native scroll container | `:padding="true"` prop for standard 16px touch margins; smooth touch momentum. |
| `<bv-ion-card>` | Elevated mobile card | `title`, `subtitle`. Includes rounded corners, card header, and card body. |
| `<bv-ion-button>` | Touch button | `label`, `color` (`primary`, `success`, `danger`, etc.), `fill` (`solid`, `outline`, `clear`), `expand` (`block`, `full`). |
| `<bv-ion-badge>` | Pill count/status indicator | `value`, `color` (`primary`, `success`, `danger`, `warning`, `dark`). |
| `<bv-ion-list>` | Mobile list container | `:inset="true"` creates rounded grouped lists common in iOS Settings and modern Android apps. |
| `<bv-ion-item>` | List row item | `title`, `subtitle`, `:detail="true"` (renders `›` chevron). Slots: `start`, `default`, `end`. |
| `<bv-ion-tabs>` | Bottom-tabbed application shell | Manages view content and fixed bottom navigation bar. |
| `<bv-ion-tab-bar>` | Fixed bottom navigation bar | Adheres to `safe-area-inset-bottom`. |
| `<bv-ion-tab-button>` | Tab navigation button | `label`, `tab`, `:active="true"`. Emits `tab-click`. |

---

## ⚡ Strongly Typed Pascal Controllers (`BlaiseIonic.pas`)

BlaiseVue eliminates the need for raw JavaScript manipulation when displaying mobile notifications and dialogs. All controllers are available directly in Object Pascal:

### 1. `TIonicToast` (Floating Notifications)

```pascal
// Display a bottom floating toast with auto-dismiss after 2 seconds
TIonicToast.Show('Record saved successfully!', 2000, 'bottom', 'success');

// Dismiss active toast immediately
TIonicToast.Dismiss;
```

### 2. `TIonicAlert` (Mobile Dialogs & Prompts)

```pascal
// Standard alert
TIonicAlert.Alert('Information', 'Data synchronization completed successfully.');

// Confirmation dialog with callbacks
TIonicAlert.Confirm('Delete Record', 'Are you sure you want to delete this customer?',
  procedure()
  begin
    // User clicked Confirm
    DeleteCustomer;
    TIonicToast.Show('Record deleted', 1500, 'bottom', 'danger');
  end,
  procedure()
  begin
    // User clicked Cancel
  end
);

// Prompt input dialog
TIonicAlert.Prompt('New Category', 'Enter category name:', 'e.g. Beverages',
  procedure(Value: JSValue)
  begin
    WriteLn('Category created: ', String(Value));
  end
);
```

### 3. `TIonicLoading` (Modal Loading Spinner)

```pascal
// Present fullscreen loading overlay
TIonicLoading.Present('Synchronizing with mORMot 2...');

// Check if currently displayed
if TIonicLoading.IsLoading then ...

// Dismiss when background request finishes
TIonicLoading.Dismiss;
```

### 4. `TIonicActionSheet` (Bottom Option Drawer)

```pascal
// Slide up bottom action sheet
TIonicActionSheet.Show('Document Options', ['Share', 'Edit', 'Archive'],
  procedure(Choice: JSValue; Index: JSValue)
  begin
    WriteLn('User selected option: ', String(Choice));
  end
);
```

---

## 🌐 Reactive `$ionic` Global Helper

The `$ionic` helper is injected into every BlaiseVue component and accessible globally via `this.$ionic` or `$ionic`:

```typescript
// Active mode
$ionic.mode            // 'ios' | 'md'
$ionic.isIos           // boolean
$ionic.isAndroid       // boolean
$ionic.setMode('ios')  // Dynamically toggles Cupertino / Material themes

// Controllers
$ionic.toast.show(message, duration, position, color)
$ionic.toast.dismiss()

$ionic.alert.alert(title, message, buttonText)
$ionic.alert.confirm(title, message, onConfirm, onCancel)
$ionic.alert.prompt(title, message, placeholder, onSubmit)

$ionic.loading.present(message, duration)
$ionic.loading.dismiss()
$ionic.loading.isLoading()

$ionic.actionSheet.show(title, optionsArray, onSelectCallback)
```

---

## 💡 Example: Complete Mobile View

```html
<template>
  <bv-ion-app>
    <bv-ion-header>
      <bv-ion-toolbar>
        <bv-ion-title title="mORMot 2 Mobile Client" />
      </bv-ion-toolbar>
    </bv-ion-header>

    <bv-ion-content :padding="true">
      <bv-ion-card title="Cloud Sync" subtitle="PostgreSQL + SQLite">
        <p>Real-time bidirectional synchronization with high-performance native server.</p>
        <bv-ion-button label="Sync Now" color="primary" expand="block" @click="handleSync" />
      </bv-ion-card>

      <bv-ion-list :inset="true">
        <bv-ion-item title="Biometric Security" subtitle="FaceID / Fingerprint" :detail="true" />
        <bv-ion-item title="Offline Storage" subtitle="Cache: 4.2 MB" :detail="true">
          <bv-ion-badge value="Active" color="success" slot="end" />
        </bv-ion-item>
      </bv-ion-list>
    </bv-ion-content>
  </bv-ion-app>
</template>

<script>
  methods:
    procedure handleSync;
    begin
      TIonicLoading.Present('Connecting to mORMot 2...');
      asm
        setTimeout(function() {
          pas.BlaiseIonic.TIonicLoading.Dismiss();
          pas.BlaiseIonic.TIonicToast.Show('Synchronized 42 records!', 2000, 'bottom', 'success');
        }, 800);
      end;
    end;
</script>
```
