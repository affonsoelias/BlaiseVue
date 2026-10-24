# Communication: Props, $refs, and $emit

BlaiseVue supports comprehensive component communication patterns aligned with Vue.js, maintaining complete Object Pascal typing and syntax.

---

## 📥 Props (Parent -> Child)
Used to pass data from a parent component down to a child.

- **Static Props:** Plain HTML attributes: `label="Save"`, `variant="primary"`.
- **Dynamic Props:** Prefixed with `:` or `b-bind:`: `:value="count"`, `b-bind:items="userList"`.
- **Case-Insensitive & Kebab-to-Camel Auto-Mapping:** Because browser DOM normalizes HTML attributes to lowercase, the BlaiseVue compiler automatically maps attributes (`initialactiveid`, `initial-active-id`) to the component's declared Pascal/JS prop name (`initialActiveId`).

```html
<!-- In Child (BVCard.bv) -->
<script>
  props:
    title: string = 'Default Title';
    userCount: integer = 0;
</script>

<!-- In Parent -->
<template>
  <bv-card title="System Status" :user-count="totalUsers"></bv-card>
</template>
```

---

## 🎯 $refs (Direct Component & DOM Access)
Allows parent components to programmatically access child components or DOM elements.

1. Add `b-ref="identifier"` (or `ref="identifier"`) to any component or element in the template.
2. In Pascal, you can interact with the reference in two ways:

### Approach A: 100% Pure Pascal (Zero-ASM — Recommended)
Use the high-level `TriggerRef` helper from `BVPascalDX` to cleanly execute methods on child components without writing any JavaScript:

```html
<template>
  <bv-btn variant="primary" @click="openConfirmModal">Open Confirmation</bv-btn>
  <bv-modal b-ref="mainModal" title="Confirm" @ok="processData">
    <p>Are you sure you want to proceed?</p>
  </bv-modal>
</template>

<script>
  methods:
    procedure openConfirmModal;
    begin
      // Pure Pascal: cleanly triggers 'showModal' on the child component
      TriggerRef(this, 'mainModal', 'showModal');
    end;
</script>
```

### Approach B: Advanced Power-User (`asm` Interop)
When you need to interact directly with raw DOM elements, HTML5 canvas contexts, or third-party JavaScript libraries, BlaiseVue allows inline `asm` blocks:

```pascal
procedure openConfirmModalWithJS;
begin
  asm
    if (this.$refs.mainModal && this.$refs.mainModal.showModal) {
      this.$refs.mainModal.showModal();
    }
  end;
end;
```

> [!NOTE]
> When `b-ref` is applied to a custom component, `$refs[name]` resolves to the **reactive proxy instance** of that component, allowing direct invocation of its declared `methods`.

---

## 📤 $emit (Child -> Parent)
Allows child components to trigger custom events and pass payloads upward to the parent.

1. **In the Child:** Trigger an event using pure Pascal `Emit(this, 'event-name', payload)`.
2. **In the Parent:** Listen to the event using `@event-name="handler"`, `v-on:event-name`, or `b-on:event-name`.

### Example: Child Component (`FormHeader.bv`)
```html
<template>
  <header class="header-box">
    <h3>{{ title }}</h3>
    <button class="bui-btn bui-btn-primary" @click="notifyParent">Refresh Data</button>
  </header>
</template>

<script>
  props:
    title: string = '';

  methods:
    procedure notifyParent;
    var
      payload: TJSObject;
    begin
      // 100% Pure Pascal (Zero-ASM)
      payload := NewObject;
      payload['timestamp'] := NowTimestampStr;
      Emit(this, 'refresh', payload);
    end;
</script>
```

> [!TIP]
> **Power-User JavaScript Alternative:** You can also emit events directly in `asm` if interfacing with external JS:
> ```pascal
> procedure notifyParentJS;
> begin
>   asm
>     this.$emit('refresh', { timestamp: Date.now() });
>   end;
> end;
> ```

### Example: Parent Component Listening to the Event
```html
<template>
  <div>
    <!-- Method handler with payload -->
    <form-header title="Dashboard" @refresh="onRefresh"></form-header>

    <!-- Inline expression mutation -->
    <form-header title="Compact" @refresh="lastSync = $event.timestamp"></form-header>

    <!-- Event modifiers -->
    <form-header title="Stop Bubbling" @refresh.stop="onRefresh"></form-header>
  </div>
</template>

<script>
  methods:
    procedure onRefresh(data: JSValue);
    begin
      ConsoleLog('Parent received refresh event!');
      ShowToast('Data refreshed successfully!');
    end;
</script>
```
