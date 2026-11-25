# 57. Developer Tools & Dynamic CLI Extension (`bv tool`)

The **`bv tool`** subsystem is BlaiseVue's native, pluggable extension engine.

Inspired by modern extensibility architectures like `git` subcommands (`git-lfs`) and Cargo extensions (`cargo-watch`), `bv tool` empowers the core CLI to seamlessly discover, install, update, and dynamically dispatch commands to external developer utilities, backend microframeworks, code generators, and linters without modifying the core compiler or CLI binary.

---

## 🏛️ Architecture: `bv tool` vs `bv lib`

Developers often ask how `bv tool` differs from `bv lib`:

| Aspect | `bv lib` (Component Libraries) | `bv tool` (Developer Tools & CLIs) |
|---|---|---|
| **Scope** | Project-specific (`my-app/lib/`) | Global developer environment (`~/.blaisevue/tools/`) |
| **Contents** | Pascal units (`.pas`), SFCs (`.bv`), CSS | Executables, CLIs, Python scripts, templates |
| **Execution** | Transpiled into the web/app bundle | Executed directly from terminal (`bv <tool>`) |
| **Manifest** | `package.json` | `tool.json` |
| **Examples** | `blaise-ui`, `blaise-themes`, `blaise-charts` | `blaise-horse`, custom code generators, linters |

---

## 🔌 Dynamic CLI Extension Pattern (Cargo/Git-Style)

When you install a tool that defines a `command` or `aliases` inside its `tool.json` manifest:

```json
{
  "name": "blaise-horse",
  "command": "horse",
  "aliases": ["horse"],
  "bin": "run.py"
}
```

BlaiseVue automatically binds `bv horse` to that tool! When you type:

```bash
bv horse run --port 9000
```

The BlaiseVue CLI detects that `horse` is not an internal core command, searches `~/.blaisevue/tools/` for a matching `tool.json`, and dynamically forwards execution:

```text
[Terminal: bv horse run]
          │
          ▼
┌─────────────────────────────────┐
│     BlaiseVue Core CLI (bv)     │
│  - Detects "horse" subcommand   │
│  - Inspects ~/.blaisevue/tools  │
└─────────────────┬───────────────┘
                  │ Dynamic Dispatch
                  ▼
┌─────────────────────────────────┐
│ blaise-horse (~/.blaisevue/tools)│
│  - Executes run.py via Python   │
│  - Passes arguments: run --port │
└─────────────────────────────────┘
```

This guarantees that third-party or co-official tools feel **100% native** to the developer, while keeping the core framework repository lightweight, focused, and decoupled.

---

## 📋 User Guide: Managing Developer Tools

The `bv tool` suite provides complete lifecycle management for development tools:

### 1. Discovering Tools (`bv tool search`)
Searches all registered repositories in the ecosystem (`~/.blaisevue/repos.json`):

```bash
bv tool search horse
```

**Output:**
```text
  Searching repositories for tools matching "horse"...
  Found in ecosystem:
    - blaise-horse (v1.0.0) [Backend Framework]
      Co-official Horse microframework backend integration for BlaiseVue with isolated server-horse/ scaffolding
      Repo: ecosystem

  1 tool(s) found. To install, run: bv tool install [<repo>:]<name>
```

### 2. Inspecting Tool Details (`bv tool info`)
Displays metadata, scripts, authors, and configuration:

```bash
bv tool info blaise-horse
```

### 3. Installing Tools (`bv tool install`)
Installs a tool from registered repositories, direct download URLs, or local `.zip` release archives:

```bash
# Install from default ecosystem:
bv tool install blaise-horse

# Install specific version:
bv tool install blaise-horse@1.0.0

# Install from custom repository:
bv tool install community:my-custom-tool

# Install from local archive:
bv tool install ./my-tool-1.0.0.zip
```

When installed, BlaiseVue:
1. Downloads and extracts the tool to `~/.blaisevue/tools/<name>/`.
2. Validates the `tool.json` manifest.
3. Automatically triggers the tool's `install.py` lifecycle hook (if present) to configure dependencies.

### 4. Listing Installed Tools (`bv tool list`)
Lists all active development tools on your system:

```bash
bv tool list
```

**Output:**
```text
=== BlaiseVue Development Tools (bv tool) ===
  Installed Tools (~/.blaisevue/tools):
    * blaise-horse (v1.0.0) [co-official]
      Category:    Backend Framework
      Command:     bv horse (aliases: horse)
      Location:    C:\Users\User\.blaisevue\tools\blaise-horse

Commands: bv tool <list|search|info|install|run|update|outdated|remove|pack|init>
```

### 5. Executing Tools (`bv tool run` or direct alias)
You can run any tool through `bv tool run`:

```bash
bv tool run blaise-horse init
```

Or directly via its registered command alias:

```bash
bv horse init
bv horse run
```

You can also initialize an external backend tool directly during project creation with `--backend=<tool>`:

```bash
bv create my-app --backend=horse
```

When `--backend=<name>` does not match a built-in backend (`mormot` or `zephyr`), BlaiseVue searches installed developer tools in `~/.blaisevue/tools/` for a matching command/alias and invokes `<tool> init` automatically inside the new project.

### 6. Checking for Updates (`bv tool outdated`)
Compares installed tools against registered ecosystem catalogs:

```bash
bv tool outdated
```

### 7. Updating Tools (`bv tool update`)
Updates one or all installed tools to their latest versions:

```bash
# Update specific tool:
bv tool update blaise-horse

# Update all tools:
bv tool update
```

### 8. Removing Tools (`bv tool remove`)
Safely uninstalls a tool from `~/.blaisevue/tools/`:

```bash
bv tool remove blaise-horse
```
If the tool defines a `remove.py` script, it runs automatically before directory deletion to clean up any external background processes or sockets.

---

## 🛠️ Author Guide: Creating Your Own Tool

BlaiseVue provides first-class scaffolding and release packagers to build and distribute custom tools.

### 1. Scaffold a Tool Project (`bv tool init`)
Run `bv tool init` to create a production-ready starter template:

```bash
bv tool init my-generator
```

This creates a clean structure:

```text
my-generator/
├── tool.json          # Tool metadata, command aliases, and scripts
├── run.py             # Main entry point (invoked by bv tool run or bv <cmd>)
├── install.py         # Post-installation hook
├── update.py          # Post-update hook
├── remove.py          # Pre-removal cleanup hook
├── status.py          # Health check hook
└── README.md          # Tool documentation and usage guide
```

### 2. The `tool.json` Manifest Specification

Every tool must include a valid `tool.json` in its root:

```json
{
  "name": "my-generator",
  "version": "1.0.0",
  "category": "Code Generation",
  "description": "Enterprise Pascal entity and DTO generator for BlaiseVue",
  "author": "Acme Corp",
  "license": "MIT",
  "homepage": "https://github.com/acme/my-generator",
  "type": "third-party",
  "command": "generate",
  "aliases": ["gen", "entity"],
  "bin": "run.py",
  "scripts": {
    "status": "status.py",
    "install": "install.py",
    "update": "update.py",
    "remove": "remove.py",
    "pack": "pack.py"
  }
}
```

#### Manifest Fields:
- **`name`** *(string, required)*: Unique tool identifier (kebab-case).
- **`version`** *(string, required)*: Semantic version (`1.0.0`).
- **`command`** *(string, optional)*: Primary CLI command bound to this tool (`bv <command>`).
- **`aliases`** *(array of strings, optional)*: Additional command shortcuts (`bv gen`, `bv entity`).
- **`bin`** *(string, required)*: Main executable or Python script invoked on execution.
- **`scripts`** *(object, optional)*: Lifecycle scripts called during `install`, `update`, `remove`, and `status`.

### 3. Writing Cross-Platform Logic (`run.py`)

Tools can be written in **Python** (recommended for cross-platform simplicity) or compiled Pascal binaries.

Example `run.py`:

```python
#!/usr/bin/env python3
import sys

def main():
    args = sys.argv[1:]
    if not args:
        print("Usage: bv generate <entity-name>")
        return 0
    
    entity = args[0]
    print(f"[+] Generating Pascal model and DTO for: {entity}...")
    # Business logic here
    return 0

if __name__ == "__main__":
    sys.exit(main())
```

### 4. Packaging Release Archives (`bv tool pack`)
To package your tool into a distributable archive with SHA-256 integrity verification:

```bash
bv tool pack my-generator
```

**Output:**
```text
  Validating tool manifest (tool.json)... OK
  Generating release package: my-generator-1.0.0.zip
  Calculating SHA-256 integrity digest...
  SHA-256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
  [SUCCESS] Tool packaged successfully in dist/my-generator-1.0.0.zip!
```

### 5. Publishing to an Ecosystem Catalog

To distribute your tool via `bv tool search` and `bv tool install`:
1. Host the release `.zip` on GitHub Releases or any HTTPS file server.
2. Add an entry to the repository's `ecosystem.json`:

```json
{
  "tools": [
    {
      "name": "my-generator",
      "version": "1.0.0",
      "category": "Code Generation",
      "description": "Enterprise Pascal entity and DTO generator for BlaiseVue",
      "download": "https://github.com/acme/my-generator/releases/download/v1.0.0/my-generator-1.0.0.zip",
      "sha256": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
    }
  ]
}
```

Once registered, any developer running `bv tool search my-generator` or `bv tool install my-generator` can install and run your tool instantly! 🚀
