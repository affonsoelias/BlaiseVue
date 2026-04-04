# Global Mixins and Global Plugins in BlaiseVue 🛡️🔌

BlaiseVue v1.0.0 introduces support for Global Mixins and Global Plugins, allowing you to extend the framework's functionality and share logic across all components.

## 1. Global Mixins

Global Mixins allow you to inject options (data, methods, hooks, etc.) into every component registered with BlaiseVue.

### Usage

```pascal
uses BlaiseVue, JS;

var
  LogMixin: JSValue;
begin
  asm
    LogMixin = {
      created: function() {
        console.log("[Mixin] Component Created: " + this.tagName);
      },
      methods: {
        $log: function(msg) {
          console.log("[BlaiseLog] " + msg);
        }
      }
    };
  end;
  
  TBlaiseVue.Mixin(LogMixin);
end;
```

### Merging Strategy
*   **Data**: Merged recursively. Component data overrides mixin data.
*   **Methods/Computed/Watch/Inject**: Merged. Component properties override mixin properties.
*   **Lifecycle Hooks**: Both are executed. **Mixin hooks run BEFORE component hooks.**

---

## 2. Global Plugins

Plugins are objects or functions that extend the framework. They can register global components, add instance methods, or initialize external libraries.

### Creating a Plugin

A plugin is simply an object with an `install` method:

```pascal
uses BlaiseVue, JS, BVComponents;

var
  MyPlugin: JSValue;
begin
  asm
    MyPlugin = {
      install: function(BV, options) {
        console.log("Installing MyPlugin with options:", options);
        
        // 1. Add a global method or property
        // (Currently via window.__BV_CORE__ or by modifying component protos)
        
        // 2. Register a global component
        BV.RegisterComponent('my-global-comp', {
           template: '<div>Global Component!</div>'
        });
      }
    };
  end;
  
  TBlaiseVue.Use(MyPlugin, JSValue(TJSObject.new));
end;
```

---

## 3. Best Practices

> [!WARNING]
> Use Global Mixins sparingly! They affect every single component, which can lead to namespace collisions and side effects that are hard to debug.

> [!TIP]
> Plugins are the preferred way to distribute reusable functionality. They provide a clear entry point and can be configured via the `options` argument.
