# 📦 Library Management (/lib)

BlaiseVue PRO (v1.0+) introduces an **External Library Management** system with a "Zero Configuration" concept, allowing the creation and sharing of UI Kits and plugins without the need for manual imports.

---

## 🏛️ The `/lib` Folder Concept
The `/lib/` folder at the root of your project is automatically monitored by BlaiseCLI (`bv.exe`). Each subfolder within it is treated as an independent resource package.

### Standard Library Structure:
```text
/lib
  /bootstrap-bv/
    - BBtn.bv       (Reactive Component)
    - BCard.bv
    - style.css     (Injected into Header)
    - vendor.js     (Injected into Header)
```

---

## 🚀 Automatic Powers (Zero Config)

### 1. Automatic Component Registration
`.bv` files found at any level within `/lib/` are registered as **Global Components**.
- **Mapping**: The filename determines the tag (kebab-case).
- **No Suffix**: Unlike views in `src/views/`, library components **DO NOT** receive the `-page` suffix.
- **Example**: `BBtn.bv` -> usable as `<b-btn>` in any application template.

### 2. Automatic Asset Injection (CSS/JS)
BlaiseCLI detects style and script files within the `lib` folder and performs the following workflow during `bv run dev` or `bv run build`:
1.  **Copy**: Moves files to `dist/css/lib/` or `dist/js/lib/`.
2.  **Asset Linking**: Automatically inserts `<link>` and `<script>` tags in `index.html`.
3.  **Cache-Busting**: Applies a version timestamp (`v=...`) to ensure the browser always loads the latest version after changes.

---

## 🛠️ CLI Commands for Libraries

### Install via ZIP URL
```bash
bv lib install https://domain.com/my-lib.zip
```
The CLI downloads and extracts the content directly into the `/lib/` folder and cleans up temporary files.

### List Active Libraries
```bash
bv lib list
```

### Remove Library
```bash
bv lib remove folder-name
```

---

## ⚙️ Advanced Setup: The `setup.pas` Standard

To allow for complex installation tasks (like creating custom folders or registering project-level files), a library can include an optional **Setup Script**.

### Rules for `setup.pas`:
1.  **Placement**: Must be at the root of your library's folder: `/lib/my-lib/setup.pas`.
2.  **Execution**: BlaiseCLI (`bv.exe`) will automatically compile and run this script when triggered.
3.  **The Action Parameter**: Your script **must** check `ParamStr(1)` for the current action being performed.

### 📜 Boilerplate Example (`setup.pas`):
```pascal
program my_lib_setup;
uses SysUtils;

var
  Action: string;
begin
  if ParamCount < 1 then Halt(1);
  Action := LowerCase(ParamStr(1));

  if Action = 'install' then
  begin
    WriteLn('Initializing MyLib resources...');
    // Add logic to create folders or files...
  end
  else if Action = 'reinstall' then
  begin
    WriteLn('Reinstalling MyLib...');
  end
  else if Action = 'remove' then
  begin
    WriteLn('Cleaning up MyLib before removal...');
  end;
end.
```

### 🔄 CLI Integration
- **Manual Setup**: Run `bv s <folder-name>` to open an interactive menu for that library.
- **Automatic Cleanup**: When running `bv lib remove <name>`, if a `setup.pas` is detected, the `remove` action is **automatically** called before folder deletion.

---

## 💡 Practical Example: Internal UI Kit
If you create a `StatusBadge.bv` component in `lib/my-kit/`, you can use it immediately in your `Home.bv` page:

```html
<!-- Home.bv -->
<template>
  <div>
    Status: <status-badge variant="success">Online</status-badge>
  </div>
</template>
```
No `import` or `uses` is required; BlaiseCLI handles all the Pascal registration orchestration behind the scenes. 🛡️✨🏆

---
_"BlaiseVue: Distribute with Pascal, Run with Zero Config."_ 🛡️📦🚀
