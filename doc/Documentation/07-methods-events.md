# 7. Methods and Events

## Defining Methods

Methods are defined in the `methods:` section of the `<script>`:

```html
<script>
  methods:
    procedure myMethod;
    begin
      window.alert('Hello!');
    end;
</script>
```

## Events with `@click`

Use `@click="methodName"` to call a method on click:

```html
<template>
  <button @click="greet">Click here</button>
  <button @click="increment">+1</button>
  <button @click="decrement">-1</button>
</template>

<script>
  data:
    counter: integer = 0;

  methods:
    procedure greet;
    begin
      window.alert('Hello from BlaiseVue!');
    end;

    procedure increment;
    begin
      this['counter'] := Integer(this['counter']) + 1;
    end;

    procedure decrement;
    begin
      this['counter'] := Integer(this['counter']) - 1;
    end;
</script>
```

## Accessing Reactive Data in Pascal

In BlaiseVue, you can access component data using the special `this` (or `State`) variable in pure Pascal. It is no longer necessary to use `asm` blocks:

```pascal
methods:
  procedure reset;
  begin
    this['name'] := '';
    this['counter'] := 0;
    this['active'] := False;
  end;
```

## Calling Browser APIs

BlaiseVue exposes global objects like `window`, `document`, and `console` via the Pas2JS `Web` unit, allowing direct use without `asm`:

```pascal
methods:
  procedure logToConsole;
  begin
    console.log('Current value:', this['name']);
  end;

  procedure navigate;
  begin
    window.location.hash := '#/about';
  end;

  procedure confirm;
  begin
    if window.confirm('Are you sure?') then
    begin
      this['confirmed'] := True;
    end;
  end;
```

## Full Example (Pure Pascal)

```html
<template>
  <div>
    <h2>Counter: {{ value }}</h2>
    <button @click="increment">+</button>
    <button @click="decrement">-</button>
    <button @click="reset">Clear</button>
  </div>
</template>

<script>
  data:
    value: integer = 0;

  methods:
    procedure increment;
    begin
      this['value'] := Integer(this['value']) + 1;
    end;

    procedure decrement;
    begin
      this['value'] := Integer(this['value']) - 1;
    end;

    procedure reset;
    begin
      this['value'] := 0;
    end;
</script>
```
