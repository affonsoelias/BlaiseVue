# 49 - Project Metadata, Licensing Suite & Clean Slate Reset

BlaiseVue provides dedicated CLI commands to manage project metadata, generate standard software licenses, automatically synchronize Pascal compilation units, and quickly reset starter projects into a pristine blank canvas.

---

## 🎯 Motivation & Architecture

When scaffolding new BlaiseVue projects with `bv create <name>`, the framework provides the rich `demo-app` starter template. This is ideal for exploring components, testing themes, and validating that the entire Pascal toolchain and web server are operational.

However, once ready to build custom business applications or libraries, developers need:
1. **License Management (`bv license`)**: Standardized open-source or commercial legal templates generated directly into `LICENSE` and synchronized with `package.json`.
2. **Metadata & SemVer Automation (`bv meta`)**: Automated Semantic Versioning bumping (`patch`, `minor`, `major`) and metadata querying.
3. **Pascal Compilation Sync (`src/uAppVersion.pas`)**: Strongly-typed constants (`APP_NAME`, `APP_VERSION`, `APP_AUTHOR`, `APP_LICENSE`, `APP_BUILD_DATE`) accessible across client Single File Components and backend mORMot services.
4. **Clean Slate Reset (`bv reset`)**: One-command project cleanup that safely archives existing demo views/components and configures a clean routing setup, complete with passing unit tests.
5. **Absolute Framework Safety Guards**: Air-tight protection mechanisms ensuring that the framework repository root and the framework's core `demo-app` are immune to accidental deletion.

---

## 📜 1. License Suite (`bv license`)

Manage software licenses easily without manually searching for license texts.

### Listing Supported Licenses

```bash
bv license list
```

Supported templates:
| Identifier | Name | Description |
|---|---|---|
| `mit` | MIT License | Permissive, open-source community standard |
| `apache-2.0` | Apache License 2.0 | Permissive with explicit patent grant protection |
| `lgpl-3.0` | GNU Lesser General Public License v3.0 | Traditional Pascal shared library copyleft |
| `gpl-3.0` | GNU General Public License v3.0 | Strong copyleft license |
| `bsd-3` | BSD 3-Clause License | Permissive with attribution clause |
| `commercial` | Commercial / Proprietary | All rights reserved, proprietary agreement |
| `unlicense` | The Unlicense | Dedicated public domain dedication |

### Applying a License (`bv license set` / `bv license <type>`)

Generate a `LICENSE` file in the project root, update `"license"` in `package.json`, and synchronize `src/uAppVersion.pas`:

```bash
# Standard MIT license
bv license set mit

# Shorthand notation
bv license apache-2.0

# Explicit author and copyright year
bv license set lgpl-3.0 --author "Acme Corporation" --year 2026

# Commercial proprietary license
bv license commercial --author "Enterprise Solutions LLC"
```

Options:
- `--author, -a <name>`: Author name or organization (defaults to `"author"` in `package.json`, current OS user, or `"BlaiseVue Developer"`).
- `--year, -y <year>`: Copyright year (defaults to current year).

### Inspecting Project License (`bv license show`)

```bash
bv license show
```

Output:
```text
  Project License Status
  ----------------------
  Identifier:   MIT
  LICENSE File: Found in project root

--- LICENSE Header Preview ---
  MIT License

  Copyright (c) 2026 Blaise Team

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
------------------------------
```

---

## 🏷️ 2. Project Metadata & SemVer (`bv meta`)

The `bv meta` command inspects, modifies, and synchronizes project metadata between `package.json` and Pascal units.

### Viewing Metadata (`bv meta show` / `bv meta`)

```bash
bv meta
```

Output:
```text
  BlaiseVue Project Metadata
  ==========================
  Name:        my-awesome-app
  Version:     1.1.0
  Author:      Jane Doe <jane@example.com>
  License:     MIT
  Description: Real-time telemetry dashboard in Pascal
  Pascal Unit: src/uAppVersion.pas (synchronized)
```

### Initializing Metadata (`bv meta init`)

Ensures `package.json` contains standard fields (`name`, `version`, `author`, `license`, `description`) and generates `src/uAppVersion.pas`.

```bash
bv meta init
```

### Querying Specific Fields (`bv meta get <field>`)

Extract field values directly for CI/CD pipelines, shell scripts, or GitHub Actions:

```bash
bv meta get version
# Output: 1.1.0

bv meta get author
# Output: Jane Doe <jane@example.com>
```

### Updating Metadata Fields (`bv meta set <field> <value>`)

Updates the field in `package.json` and updates `src/uAppVersion.pas`:

```bash
bv meta set author "Blaise Team "
bv meta set description "High performance Pascal web client"
```

### Automated SemVer Bumping (`bv meta bump <patch|minor|major>`)

Increments the project's Semantic Versioning (SemVer) tag according to standard specifications:

```bash
# Patch bump: 1.0.0 -> 1.0.1 (bug fixes and maintenance)
bv meta bump patch

# Minor bump: 1.0.1 -> 1.1.0 (new features, backward compatible)
bv meta bump minor

# Major bump: 1.1.0 -> 2.0.0 (breaking changes and architectural overhauls)
bv meta bump major
```

Output:
```text
  [+] Version bumped: 1.0.0 -> 1.1.0 (minor)
  [+] Synchronized Pascal unit: src/uAppVersion.pas (v1.1.0)
```

---

## 📦 3. Synchronized Pascal Unit (`src/uAppVersion.pas`)

Whenever `bv meta bump`, `bv meta set`, `bv license set`, or `bv reset` is executed, BlaiseVue automatically generates or updates `src/uAppVersion.pas`:

```pascal
unit uAppVersion;

{$mode objfpc}{$H+}

interface

const
  APP_NAME = 'my-awesome-app';
  APP_VERSION = '1.1.0';
  APP_AUTHOR = 'Blaise Team';
  APP_LICENSE = 'MIT';
  APP_BUILD_DATE = '2026-10-24';

implementation

end.
```

### Frontend Usage (Single File Components)

```html
<template>
  <footer class="footer">
    <p>{{ appTitle }} v{{ version }} ({{ license }} License)</p>
    <small>Built on {{ buildDate }} by {{ author }}</small>
  </footer>
</template>

<script>
uses uAppVersion;

type
  TAppFooter = class(TBVComponent)
  published
    property appTitle: string;
    property version: string;
    property author: string;
    property license: string;
    property buildDate: string;
  end;

procedure TAppFooter.Created;
begin
  appTitle := APP_NAME;
  version := APP_VERSION;
  author := APP_AUTHOR;
  license := APP_LICENSE;
  buildDate := APP_BUILD_DATE;
end;
</script>
```

### Backend Usage (mORMot 2 Service)

```pascal
unit ServiceAppInfo;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, mORMot2, uAppVersion;

type
  IAppInfoService = interface(IInvokable)
    ['{B89A4B3A-6842-4D95-A4F3-888A92EEF102}']
    function GetVersionInfo: string;
  end;

  TAppInfoService = class(TInterfacedObject, IAppInfoService)
  public
    function GetVersionInfo: string;
  end;

implementation

function TAppInfoService.GetVersionInfo: string;
begin
  Result := Format('{"name":"%s","version":"%s","build":"%s"}',
    [APP_NAME, APP_VERSION, APP_BUILD_DATE]);
end;

end.
```

---

## 🧹 4. Clean Slate Reset (`bv reset`)

Converts a project scaffolded with the demo app into a clean, minimal starting slate without requiring manual deletion of dozens of files.

```bash
bv reset
```

### Interactive Prompt & Confirmation

Before altering any files, `bv reset` requests confirmation:

```text
============================================================
  BlaiseVue Project Reset
============================================================
WARNING: This will reset the project to a clean blank slate.
All demo views, components, and demo tests will be removed.
A full backup of src/ and tests/ will be created in .bv-backup/

Are you sure you want to proceed? [y/N]:
```

### Non-Interactive / Force Mode (`--force` / `-f` / `-y`)

```bash
bv reset --force
```

### Automated Safety Backup (`.bv-backup/`)

Unless `--no-backup` is passed, `bv reset` automatically creates a full timestamped snapshot of `src/` and `tests/` before cleaning:

```text
.bv-backup/
└── backup_20261024_153301/
    ├── src/
    └── tests/
```

### What Gets Cleaned & Scaffolding

1. **Views (`src/views/`)**: Removes all demo fixtures (`CustomerView.bv`, `Charts.bv`, `DatasetView.bv`, `MobileView.bv`, etc.) and creates:
   - `src/views/Home.bv` (Clean welcome view)
   - `src/views/About.bv` (Clean about view)
2. **Components (`src/components/`)**: Purges demo components, leaving a clean workspace ready for your own components.
3. **Application Router (`src/app.bv`)**: Scaffolds a clean header with navigation between `/` (Home) and `/about` (About).
4. **Tests (`tests/`)**: Configures `tests/views/Home.test.pas` and `tests/views/About.test.pas` so that running `bv test` immediately passes 100% green.
5. **Pascal Sync**: Automatically updates `src/uAppVersion.pas`.

### Bare Mode (`--bare` / `-b`)

For ultra-minimal single-view starters without navigation bars or secondary views:

```bash
bv reset --bare --force
```

In bare mode:
- Only `src/views/Home.bv` is created.
- `src/app.bv` contains only the `<router-view></router-view>` root outlet.
- Single unit test: `tests/views/Home.test.pas`.

---

## 🛡️ 5. Built-in Double-Layered Safety Guards

To guarantee that the framework repository itself and its internal `demo-app` are **NEVER** accidentally erased or reset, `bv reset` includes hardcoded safety barriers:

```pascal
function IsFrameworkCoreDemoApp: Boolean;
var
  CurDir, ParentDir: string;
begin
  Result := False;
  CurDir := ExcludeTrailingPathDelimiter(GetCurrentDir);

  // 1. Target directory is the framework core demo-app
  if SameText(ExtractFileName(CurDir), 'demo-app') then
  begin
    ParentDir := ExtractFilePath(CurDir);
    if FileExists(ParentDir + 'bin' + DirectorySeparator + 'bv.pas') or
       FileExists(ParentDir + 'core' + DirectorySeparator + 'BVCompiler.pas') or
       FileExists(ParentDir + 'packages' + DirectorySeparator + 'blaise-charts' + DirectorySeparator + 'BVChart.bv') then
    begin
      Result := True;
      Exit;
    end;
  end;

  // 2. Target directory is the BlaiseVue root repository
  if FileExists('bin' + DirectorySeparator + 'bv.pas') and DirectoryExists('demo-app') then
  begin
    Result := True;
    Exit;
  end;
end;
```

If triggered, the CLI immediately halts with exit code 1:

```text
========================================================================
  [ERROR] SAFETY GUARD ACTIVE: OPERATION REFUSED!
  The framework repository ("C:\Users\Pichau\Documents\BlaiseVue\demo-app") is protected.
  "bv reset" cannot be executed in the framework core repository or its demo-app.
========================================================================
```

---

## 📊 Summary of Commands

| Command | Description |
|---|---|
| `bv license list` | Lists all available license templates |
| `bv license show` | Displays active license and `LICENSE` file header preview |
| `bv license set <type> [--author <name>] [--year <year>]` | Generates `LICENSE`, updates `package.json` and syncs `src/uAppVersion.pas` |
| `bv license <type>` | Shorthand for `bv license set <type>` |
| `bv meta` / `bv meta show` | Displays formatted project metadata and Pascal unit status |
| `bv meta init` | Initializes `package.json` metadata and creates `src/uAppVersion.pas` |
| `bv meta get <field>` | Retrieves value of `name`, `version`, `author`, `license`, or `description` |
| `bv meta set <field> <value>` | Updates metadata in `package.json` and syncs `src/uAppVersion.pas` |
| `bv meta bump <patch\|minor\|major>` | Automatically increments SemVer and syncs `src/uAppVersion.pas` |
| `bv reset [--bare] [--force] [--no-backup]` | Resets demo project to clean blank slate with backup and passing tests |
