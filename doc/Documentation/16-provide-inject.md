# 🔗 Sacred Link (Provide/Inject)

BlaiseVue PRO offers native support for **Provide/Inject**, an advanced dependency injection technique for deeply nested components, eliminating the need to pass props manually through multiple levels (prop drilling).

---

## 🏗️ How Provide/Inject Works

- **The Ancestor PROVIDES**: A top-level component (such as `app.bv`) defines data, objects, or functions that it wants to make available to its descendant tree.
- **The Descendant INJECTS**: Any child, grandchild, or great-grandchild component can declare that it wants to "inject" these dependencies.

### 1. Providing Data (Parent/Root Component)
In the component that holds the data (usually `app.bv`), use the `provide` block. The return must be a `TJSObject` containing the keys you want to expose.

```pascal
{ app.bv }
<script>
  provide:
    var
      env: TJSObject;
    begin
       env := TJSObject.new;
       env['status'] := 'Production 🛡️';
       env['id'] := 42;
       
       Result := TJSObject.new;
       Result['getEnvironment'] := function(): TJSObject
         begin
            Result := env;
         end;
    end;
</script>
```

### 2. Injecting Dependencies (Descendant Component)
In the component that needs the data, list the desired keys in the `inject` block. BlaiseVue PRO will make them available reactively.

```pascal
{ MyWidget.bv }
<script>
  inject:
    getEnvironment;

  methods:
    procedure logEnvironment;
    begin
       { Access via Pascal: use the 'this' prefix }
       console.log('Injected Environment: ' + string(this['getEnvironment']().status));
    end;
</script>
```

### 3. Access in the Interface (Template)
The injected value behaves like component data and can be used directly in `{{ }}` curly braces or directives.

```html
<template>
  <div class="footer">
    Status: <strong>{{ getEnvironment().status }}</strong> (ID: {{ getEnvironment().id }})
  </div>
</template>
```

---

## 🛡️ Technical Benefits
1.  **Deep Decoupling**: The child does not need to know the parent's structure, only that the dependency ID exists.
2.  **Service Injection (Plugins)**: Ideal for injecting translation systems (i18n), logging engines, or API configurations.
3.  **Hierarchical Priority**: If multiple parents provide the same key, the child component will inject the value from the nearest ancestor in the DOM tree.

---
_"BlaiseVue: Vertical DI with Pascal Safety."_ 🛡️✨🏆
