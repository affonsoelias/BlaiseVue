# 🛡️ Module 12: Declarative Form Validation (b-validate)
**Prevent bad data entry with clean, declarative validation rules in Object Pascal.**

In real-world business applications, user input can never be trusted blindly:
- Users might leave their name or email blank.
- Someone might type `invalid-email` instead of `user@company.com`.
- A password might be too short, or an age field might contain negative numbers.

Without a validation engine, developers are forced to write dozens of tedious `if/else` checks inside their submit methods. **BlaiseVue solves this with `b-validate`**: a declarative, reactive validation engine built right into the template!

---

## 🎯 1. How Does `b-validate` Work?

Instead of manual verification, you declare the validation rules directly on the input element:

```html
<input 
  type="text" 
  b-model="userName" 
  b-validate="'required|min:3'">
```

BlaiseVue automatically:
1. Validates the input on every keystroke or blur event.
2. Populates a reactive `$errors` dictionary with localized error messages.
3. Tracks touched state in `$v` so errors only show after the user interacts with the field!
4. Exposes `$validate()` for validating the entire form before submission.

---

## 📋 2. Available Validation Rules

Rules are chained together using the pipe character `|`:

| Rule | Description | Example |
| :--- | :--- | :--- |
| `required` | Field cannot be empty | `b-validate="'required'"` |
| `email` | Must be a valid email format | `b-validate="'required|email'"` |
| `min:N` | Minimum length (characters) or minimum numeric value | `b-validate="'required|min:5'"` |
| `max:N` | Maximum length (characters) or maximum numeric value | `b-validate="'max:50'"` |
| `numeric` | Must contain only numbers | `b-validate="'numeric'"` |
| `pattern:regex` | Validates against a custom regular expression | `b-validate="'pattern:^[A-Z]{3}-\\d{4}$'"` |

---

## 🚦 3. Displaying Error Messages Reactively

Every component with `b-validate` gains access to two reactive helpers:
- **`$errors.<fieldName>`**: Contains error text when a rule fails.
- **`$v.<fieldName>.dirty`**: `True` if the user has already focused and blurred the field.

```html
<div class="form-group">
  <label>Email Address:</label>
  <input 
    type="text" 
    b-model="userEmail" 
    b-validate="'required|email'">

  <!-- Display error badge only if the field is invalid: -->
  <span v-if="$errors.userEmail" class="error-badge">
    {{ $errors.userEmail }}
  </span>
</div>
```

---

## 🚀 4. Full Step-by-Step Example: An Enterprise Registration Form

Let's build a complete user registration form with validation, error badges, and submission protection.

Replace your view component (e.g. `src/views/Home.bv`) with:

```html
<template>
  <div class="form-card">
    <h2>📝 User Registration Form</h2>
    <p class="subtitle">Try submitting with empty fields or invalid values to see b-validate in action!</p>

    <!-- Field 1: Name -->
    <div class="form-group">
      <label>Full Name:</label>
      <input 
        type="text" 
        b-model="fullName" 
        b-validate="'required|min:3'" 
        placeholder="e.g. Alice Johnson">
      <span v-if="$errors.fullName" class="error-msg">{{ $errors.fullName }}</span>
    </div>

    <!-- Field 2: Email -->
    <div class="form-group">
      <label>Corporate Email:</label>
      <input 
        type="text" 
        b-model="email" 
        b-validate="'required|email'" 
        placeholder="alice@company.com">
      <span v-if="$errors.email" class="error-msg">{{ $errors.email }}</span>
    </div>

    <!-- Field 3: Password -->
    <div class="form-group">
      <label>Password (min 6 characters):</label>
      <input 
        type="password" 
        b-model="password" 
        b-validate="'required|min:6'" 
        placeholder="••••••••">
      <span v-if="$errors.password" class="error-msg">{{ $errors.password }}</span>
    </div>

    <!-- Submit Button: Disabled if invalid, or programmatically protected -->
    <button class="btn btn-primary" @click="submitRegistration">
      Register Account 🚀
    </button>

    <!-- Success Confirmation -->
    <div v-if="registrationSuccess" class="success-banner">
      ✅ Account successfully created for <b>{{ fullName }}</b>!
    </div>
  </div>
</template>

<script>
  data:
    fullName: string = '';
    email: string = '';
    password: string = '';
    registrationSuccess: boolean = false;

  methods:
    procedure submitRegistration;
    var
      IsValid: Boolean;
    begin
      // Validate all form fields at once:
      IsValid := Boolean(this['$validate']());
      
      if not IsValid then
      begin
        this['registrationSuccess'] := false;
        Exit;
      end;

      // All fields are valid! Process the business logic:
      this['registrationSuccess'] := true;
    end;
</script>

<style>
  .form-card {
    max-width: 440px;
    margin: 30px auto;
    padding: 28px;
    background: #ffffff;
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0,0,0,0.08);
    font-family: sans-serif;
  }
  .subtitle {
    font-size: 13px;
    color: #718096;
    margin-bottom: 20px;
  }
  .form-group {
    margin-bottom: 16px;
  }
  .form-group label {
    display: block;
    font-size: 13px;
    font-weight: bold;
    color: #4a5568;
    margin-bottom: 6px;
  }
  .form-group input {
    width: 100%;
    padding: 10px 12px;
    border: 1px solid #cbd5e0;
    border-radius: 6px;
    font-size: 14px;
    box-sizing: border-box;
  }
  .form-group input:focus {
    border-color: #3182ce;
    outline: none;
  }
  .error-msg {
    display: block;
    margin-top: 4px;
    font-size: 12px;
    color: #e53e3e;
    font-weight: bold;
  }
  .btn-primary {
    width: 100%;
    padding: 12px;
    background: #3182ce;
    color: white;
    border: none;
    border-radius: 6px;
    font-size: 15px;
    font-weight: bold;
    cursor: pointer;
    margin-top: 10px;
  }
  .btn-primary:hover { background: #2b6cb0; }
  .success-banner {
    margin-top: 18px;
    padding: 12px;
    background: #c6f6d5;
    color: #22543d;
    border-radius: 6px;
    font-size: 13px;
    text-align: center;
  }
</style>
```

---

## 🎯 5. Practical Exercise: Module 12

1. Save the code and open your browser at `http://localhost:8080`.
2. Click "Register Account" with empty fields. Observe how all three error messages appear simultaneously!
3. Type an invalid email like `hello` — notice the instant update: *"Must be a valid email"*.
4. **Challenge**: Add a fourth field for **"Age"** with `b-validate="'required|numeric|min:18'"` to ensure users are adults before signing up!

---

## 🏆 What You Learned Today
- Why declarative validation beats endless manual `if/else` checks.
- How to apply rules using `b-validate="'required|email|min:N'"`.
- How to display real-time reactive error messages via `$errors.<fieldName>`.
- How to trigger whole-form programmatic validation using `this['$validate']()`.

---

## 📖 Deeper Technical Reference
For advanced custom validation rules and validation event hooks:
- **[Chapter 09: Form Validation (b-validate)](../Documentation/09-form-validation.md)** — Architectural design of the validation engine, custom regular expressions, and internationalized error dictionary messages.

---

**Next up: state management that scales with your business! Advance to [Module 13: BlaiseX 2.0 & Finite State Machines](13-blaisex-fsm.md)!** ⚔️🛡️✨
