# 🧠 Module 05: Project 03 - Automatic Profile
**Make BlaiseVue think for you!**

Computed Properties (Computed) are the brain of your application. They prevent you from writing the same code multiple times and ensure that complex calculations only happen when necessary.

---

## 🛠️ What are we building?
A profile form where the "Full Name" and "Age Status" update themselves as you type!

### 1. Defining the Brain (Computed)
Open your `.bv` file and add this block to the script:
```pascal
  computed:
    function fullName: string;
    begin
      // Pascal joins the strings and BlaiseVue handles the rest!
      Result := string(this['firstName']) + ' ' + string(this['lastName']);
    end;

    function socialStatus: string;
    begin
      if Integer(this['age']) >= 18 then Result := 'Adult 🛡️'
      else Result := 'Young Beginner ⚔️';
    end;
```

### 2. Displaying on Screen
In your template, use the properties as if they were common variables:
```html
<p>Full Name: <strong>{{ fullName }}</strong></p>
<p>Level: <span class="badge">{{ socialStatus }}</span></p>
```

---

## 👁️ What You Learned Today:
- **`computed`**: How to create variables that depend on others.
- **Smart Cache**: BlaiseVue only recalculates the name if the first or last name changes!
- **Pascal Logic**: How to use `if/then` to change what appears on the screen. 🛡️✨🏆

---

**Next Step: Learn to create your army of mini-apps with Components in Module 06!** ⚔️
