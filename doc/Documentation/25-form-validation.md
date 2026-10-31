# 25. Form Validation Engine (`b-validate`)

BlaiseVue provides a native, declarative, and typed form validation engine that removes boilerplate and simplifies input validation in enterprise applications.

---

## 🎯 Key Capabilities

- **Declarative Directive**: Attach validation rules directly to template inputs via `b-validate="required|email|min:5"` (or `v-validate="required|email|min:5"`).
- **Reactive Errors Tracking (`$errors`)**: Automatic reactive map of validation error messages per field (`$errors.email`).
- **Validation State (`$v`)**: Access `$dirty`, `$invalid`, `$touch()`, `$reset()`, and `$validate()`.
- **Custom Rules**: Register custom validation logic in Object Pascal with custom localized message templates.
- **Zero-Boilerplate UI Binding**: Automatically sets CSS state classes (`is-invalid` / `is-valid`) on blurred inputs.

> [!TIP]
> **Vue-Style Aliases (`v-validate` e `v-model`)**
> Assim como as demais diretivas do BlaiseVue, o motor de validação aceita indistintamente tanto o prefixo `b-` quanto o prefixo `v-`. Você pode usar `v-validate` em conjunto com `v-model`:
> ```html
> <input type="email" v-model="email" v-validate="required|email" />
> ```

---

## 🚀 Quick Example

```html
<template>
  <form @submit.prevent="submitForm">
    <!-- E-mail input with required and email validation -->
    <div class="form-group">
      <label>Email Address</label>
      <input 
        type="email" 
        b-model="email" 
        b-validate="required|email" 
        placeholder="Enter your email"
      />
      <span b-if="$errors.email" class="bv-error-msg">
        {{ $errors.email }}
      </span>
    </div>

    <!-- Password input with min length -->
    <div class="form-group">
      <label>Password</label>
      <input 
        type="password" 
        b-model="password" 
        b-validate="required|min:8" 
        placeholder="Minimum 8 characters"
      />
      <span b-if="$errors.password" class="bv-error-msg">
        {{ $errors.password }}
      </span>
    </div>

    <button type="submit" :disabled="$v.$invalid">Save Account</button>
  </form>
</template>

<script>
  data:
    email: string = '';
    password: string = '';

  methods:
    procedure submitForm;
    begin
      // Validates all registered fields and marks them dirty
      if this.$validate() then
      begin
        // Form is completely valid!
        console.log('Submitted successfully:', this['email']);
      end;
    end;
</script>
```

---

## 📋 Built-in Validation Rules

| Rule | Description | Example |
|---|---|---|
| `required` | Ensures value is not empty, null, or whitespace. For booleans, must be `true`. | `b-validate="required"` |
| `email` | Validates standard e-mail format. | `b-validate="email"` |
| `min:n` | Minimum string character length or minimum numeric value. | `b-validate="min:6"` |
| `max:n` | Maximum string character length or maximum numeric value. | `b-validate="max:30"` |
| `numeric` | Requires all characters to be digits (integer or decimal). | `b-validate="numeric"` |
| `alpha` | Requires all characters to be alphabetical letters. | `b-validate="alpha"` |
| `alphanumeric` | Allows letters and numbers only. | `b-validate="alphanumeric"` |
| `url` | Ensures input is a valid HTTP/HTTPS URL. | `b-validate="url"` |
| `sameAs:field` | Ensures input matches another field's value (e.g. password confirmation). | `b-validate="sameAs:password"` |

Multiple rules can be chained together using the pipe (`|`) delimiter:
```html
<input b-model="username" b-validate="required|alphanumeric|min:4|max:20">
```

---

## 🛠️ Validation State (`$v` and `$errors`)

Every component that uses validation automatically receives:

### 1. `$errors`
A reactive object mapping field names to error messages:
- `$errors.fieldName`: String containing the error message, or empty string `''` if valid.

### 2. `$v`
A reactive form state controller:
- `$v.$invalid`: Boolean, `true` if any field in the component has an active validation error.
- `$v.$dirty`: Boolean, `true` if any field has been touched/interacted with.
- `$v.$validate()` / `this.$validate()`: Triggers full validation across all fields, marks all fields dirty, and returns `true` if valid.
- `$v.$touch()`: Marks all fields dirty and re-evaluates rules.
- `$v.$reset()`: Clears all error states and marks fields clean (`$dirty := false`).
- `$v[fieldName].$invalid`: Field-specific validity.
- `$v[fieldName].$dirty`: Field-specific interaction state.

---

## 🧩 Custom Validator Rules in Pascal

You can register custom validator rules anywhere in your application:

```pascal
uses BVValidation, JS;

procedure RegisterCustomValidators;
var
  TaxIdValidator: JSValue;
begin
  asm
    TaxIdValidator = function(value) {
      if (!value) return true; // optional unless required
      return /^\d{3}\.\d{3}\.\d{3}\-\d{2}$/.test(String(value).trim());
    };
  end;

  TBVValidation.RegisterRule('taxId', TaxIdValidator, '{field} must be a valid CPF (000.000.000-00)');
end;
```

Then use it directly in any `.bv` template:
```html
<input b-model="cpf" b-validate="required|taxId" />
<span b-if="$errors.cpf">{{ $errors.cpf }}</span>
```
